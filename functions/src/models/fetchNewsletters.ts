import {
  Browser as BrowserEnum,
  computeExecutablePath,
  detectBrowserPlatform,
  getInstalledBrowsers,
  install,
} from "@puppeteer/browsers";
import * as admin from "firebase-admin";
import * as cheerio from "cheerio";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import * as fs from "node:fs";
import * as path from "node:path";
import puppeteer, { type Browser, type Page } from "puppeteer";

const BASE_URL = "https://www.inje.go.kr";
const NEWSLETTER_LIST_PATH = "/portal/inje-news/inje-pr/newsletter";

const USER_AGENT =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";

const CHROME_BUILD_ID = "131.0.6778.204";

/**
 * [메모리 사용 원인]
 * - Chrome/Chromium: 헤드리스 브라우저 단일 프로세스만으로 수백 MB~1GB 이상 사용.
 * - PDF 이중 복사: page.evaluate 내부에서 arrayBuffer → Array로 복사 후 CDP로 Node에 전달 → Buffer 생성.
 *   동시에 브라우저 힙 + Node 버퍼로 동일 PDF가 2배 분량 메모리 점유.
 * - 업로드 시 전체 버퍼를 한 번에 file.save(buffer)로 전달하므로 스트리밍 없이 전체 파일 상주.
 * - 목록 페이지마다 새 탭으로 HTML 수백 KB + Cheerio 파싱으로 추가 메모리.
 * → 함수 메모리는 4GiB 권장. 장기적으로는 브라우저로 쿠키만 확보 후 Node에서 PDF 다운로드+스트림 업로드로 개선 가능.
 */

/** 목록 파싱 결과 한 건 */
export interface ParsedNewsletterItem {
  title: string;
  thumbnailUrl?: string;
  thumbnailAlt?: string;
  pdfDownloadUrl: string;
  pdfArticleSeq: string;
  pdfMetaDataID?: string;
}

/** Firestore newsletters 문서 필드 */
export interface NewsletterDoc {
  articleSeq: string;
  title: string;
  thumbnailUrl?: string;
  thumbnailAlt?: string;
  sourcePdfUrl: string;
  pdfStoragePath: string;
  /** Storage에 저장된 PDF의 공개 다운로드 URL (앱에서 바로 사용) */
  pdfStorageUrl?: string;
  pdfMetaDataID?: string;
  createdAt: Timestamp;
  updatedAt: Timestamp;
}

/**
 * Puppeteer 브라우저 설정 및 실행 (fetchWeekschedule 패턴 재사용)
 */
async function setupBrowser(): Promise<Browser> {
  let executablePath: string | undefined;

  if (process.env.PUPPETEER_EXECUTABLE_PATH) {
    executablePath = process.env.PUPPETEER_EXECUTABLE_PATH;
    logger.info("[fetchNewsletters] Using PUPPETEER_EXECUTABLE_PATH", { executablePath });
  } else {
    const defaultCacheDir = path.join(process.cwd(), ".cache", "puppeteer");
    const tmpCacheDir = "/tmp/.cache/puppeteer";
    const cacheDir =
      process.env.PUPPETEER_CACHE_DIR ?? (fs.existsSync(defaultCacheDir) ? defaultCacheDir : tmpCacheDir);

    if (!fs.existsSync(cacheDir)) {
      fs.mkdirSync(cacheDir, { recursive: true });
    }

    try {
      const pptrPath = puppeteer.executablePath();
      if (pptrPath && fs.existsSync(pptrPath)) {
        executablePath = pptrPath;
        logger.info("[fetchNewsletters] Using puppeteer.executablePath()", { executablePath });
      }
    } catch (e) {
      logger.info("[fetchNewsletters] puppeteer.executablePath() not available, will install Chrome", {
        err: String(e),
      });
    }

    if (!executablePath) {
      try {
        const platform = detectBrowserPlatform();
        if (!platform) throw new Error("Could not detect browser platform");

        const installed = await getInstalledBrowsers({ cacheDir });
        let chromeBrowser = installed.find((b) => b.browser === BrowserEnum.CHROME);

        if (!chromeBrowser) {
          await install({
            browser: BrowserEnum.CHROME,
            buildId: CHROME_BUILD_ID,
            cacheDir,
            platform,
          });
          chromeBrowser = (await getInstalledBrowsers({ cacheDir })).find(
            (b) => b.browser === BrowserEnum.CHROME
          );
        }

        if (chromeBrowser) {
          const buildId = chromeBrowser.buildId ?? CHROME_BUILD_ID;
          const resolved = computeExecutablePath({
            browser: BrowserEnum.CHROME,
            buildId,
            cacheDir,
            platform,
          });
          if (resolved && fs.existsSync(resolved)) {
            executablePath = resolved;
            logger.info("[fetchNewsletters] Using Chrome from @puppeteer/browsers", {
              executablePath,
              cacheDir,
            });
          }
        }
      } catch (err) {
        logger.warn("[fetchNewsletters] Chrome install/setup failed", { err: String(err) });
      }
    }
  }

  const launchOptions: { headless: true; args: string[]; executablePath?: string } = {
    headless: true,
    args: [
      "--no-sandbox",
      "--disable-setuid-sandbox",
      "--disable-dev-shm-usage",
      "--disable-accelerated-2d-canvas",
      "--no-first-run",
      "--no-zygote",
      "--disable-gpu",
      "--single-process",
      "--disable-background-timer-throttling",
      "--disable-backgrounding-occluded-windows",
      "--disable-renderer-backgrounding",
      "--ignore-certificate-errors",
      "--ignore-ssl-errors",
    ],
  };
  if (executablePath) {
    launchOptions.executablePath = executablePath;
  }

  logger.info("[fetchNewsletters] Launching browser");
  const browser = await puppeteer.launch(launchOptions);
  logger.info("[fetchNewsletters] Browser launched");
  return browser;
}

/**
 * 목록 페이지 HTML 가져오기
 */
async function fetchNewsletterListHtml(browser: Browser, pageIndex: number): Promise<string> {
  const url =
    pageIndex <= 1
      ? BASE_URL + NEWSLETTER_LIST_PATH
      : `${BASE_URL}${NEWSLETTER_LIST_PATH}?pageIndex=${pageIndex}`;
  let page: Page | null = null;
  try {
    page = await browser.newPage();
    await page.setViewport({ width: 1920, height: 1080 });
    await page.setUserAgent(USER_AGENT);
    logger.info("[fetchNewsletters] List page fetch start", { pageIndex, url });
    const response = await page.goto(url, {
      waitUntil: "domcontentloaded",
      timeout: 60000,
    });
    const status = response?.status();
    if (!response || !response.ok()) {
      logger.warn("[fetchNewsletters] List page fetch failed", { url, status });
      return "";
    }
    try {
      await page.waitForSelector("ul.boGallery.ebook", { timeout: 30000 });
    } catch (e) {
      logger.warn("[fetchNewsletters] ul.boGallery.ebook not found, continuing", { url });
    }
    const html = await page.content();
    const liCount = (html.match(/<li>/g) || []).length;
    logger.info("[fetchNewsletters] List page fetched", { pageIndex, url, length: html.length, liCount });
    return html;
  } finally {
    if (page) {
      try {
        await page.close();
      } catch {
        // ignore
      }
    }
  }
}

/**
 * 목록 HTML 파싱 (크롤링_합강소식지_항목.md 반영)
 */
function parseNewsletterList(html: string): ParsedNewsletterItem[] {
  const $ = cheerio.load(html);
  const items: ParsedNewsletterItem[] = [];
  $("ul.boGallery.ebook > li").each((_, el) => {
    const $li = $(el);
    const title = $li.find(".boGallery-sbj").text().trim();
    const thumbnailUrlRaw = $li.find(".boGallery-img img").attr("src")?.trim();
    const thumbnailAlt = $li.find(".boGallery-img img").attr("alt")?.trim();
    const $pdfLink = $li.find('.boGallery-btnGroup a.boGallery-link[href*="/egf/bp/board/meta/download"]');
    const pdfHref = $pdfLink.attr("href")?.trim();
    if (!pdfHref) return;
    const articleSeqMatch = pdfHref.match(/articleSeq=([^&]+)/);
    const pdfArticleSeq = articleSeqMatch ? articleSeqMatch[1] : "";
    if (!pdfArticleSeq) return;
    const metaMatch = pdfHref.match(/metaDataID=([^&]+)/);
    const pdfMetaDataID = metaMatch ? metaMatch[1] : undefined;
    const pdfDownloadUrl = pdfHref.startsWith("http") ? pdfHref : BASE_URL + pdfHref;
    const thumbnailUrl = thumbnailUrlRaw
      ? thumbnailUrlRaw.startsWith("http")
        ? thumbnailUrlRaw
        : BASE_URL + thumbnailUrlRaw
      : undefined;
    items.push({
      title: title || `합강소식 ${pdfArticleSeq}`,
      thumbnailUrl,
      thumbnailAlt: thumbnailAlt || undefined,
      pdfDownloadUrl,
      pdfArticleSeq,
      pdfMetaDataID,
    });
  });
  return items;
}

const NEWSLETTER_LIST_FULL_URL = BASE_URL + NEWSLETTER_LIST_PATH;

/**
 * PDF 다운로드용 공용 페이지 준비
 * - 목록 페이지를 한 번 방문해 쿠키/세션을 확보해 둔다.
 */
async function prepareDownloadPage(browser: Browser): Promise<Page> {
  logger.info("[fetchNewsletters] prepareDownloadPage start");
  const page = await browser.newPage();
  await page.setUserAgent(USER_AGENT);
  try {
    const nav = await page.goto(NEWSLETTER_LIST_FULL_URL, {
      waitUntil: "domcontentloaded",
      timeout: 15000,
    });
    if (!nav?.ok()) {
      logger.warn("[fetchNewsletters] PDF download: list page nav failed", {
        listUrl: NEWSLETTER_LIST_FULL_URL,
        status: nav?.status(),
      });
    }
  } catch (e) {
    logger.warn("[fetchNewsletters] PDF download: list page nav error", {
      listUrl: NEWSLETTER_LIST_FULL_URL,
      err: String(e),
    });
  }
  logger.info("[fetchNewsletters] prepareDownloadPage done");
  return page;
}

/**
 * 브라우저 컨텍스트에서 fetch로 PDF 다운로드 (TLS/세션 회피)
 * - 준비된 공용 페이지에서 Referer를 붙여 다운로드 요청
 */
async function downloadPdfWithBrowser(page: Page, pdfUrl: string): Promise<Buffer | null> {
  const url = pdfUrl.startsWith("http") ? pdfUrl : BASE_URL + pdfUrl;
  logger.info("[fetchNewsletters] PDF fetch start", { url });
  try {
    const result = await page.evaluate(
      async (args: { fetchUrl: string; referer: string }) => {
        try {
          const res = await fetch(args.fetchUrl, {
            credentials: "include",
            headers: { Referer: args.referer },
          });
          if (!res.ok) return { ok: false, status: res.status };
          const ab = await res.arrayBuffer();
          return { ok: true, data: Array.from(new Uint8Array(ab)) };
        } catch (e) {
          return { ok: false, status: 0, message: (e as Error).message };
        }
      },
      { fetchUrl: url, referer: NEWSLETTER_LIST_FULL_URL }
    );
    if (result && result.ok && Array.isArray(result.data)) {
      const buffer = Buffer.from(result.data);
      logger.info("[fetchNewsletters] PDF fetch ok", { url, size: buffer.length });
      return buffer;
    }
    logger.warn("[fetchNewsletters] PDF download not ok", {
      url,
      status: result && "status" in result ? (result as { status: number }).status : undefined,
      message: result && "message" in result ? (result as { message: string }).message : undefined,
    });
    return null;
  } catch (err) {
    const e = err as Error;
    logger.warn("[fetchNewsletters] PDF download error", { url, message: e.message });
    return null;
  }
}

/**
 * PDF를 Cloud Storage에 업로드 후 공개 URL 반환
 */
async function uploadPdfToStorage(
  articleSeq: string,
  buffer: Buffer
): Promise<{ storagePath: string; pdfStorageUrl: string }> {
  const storagePath = `newsletters/${articleSeq}.pdf`;
  logger.info("[fetchNewsletters] Storage upload start", { articleSeq, storagePath, size: buffer.length });
  const bucket = admin.storage().bucket();
  const file = bucket.file(storagePath);
  await file.save(buffer, {
    contentType: "application/pdf",
    metadata: { cacheControl: "public, max-age=31536000" },
  });
  try {
    await file.makePublic();
  } catch (e) {
    logger.warn("[fetchNewsletters] makePublic failed (URL may require auth)", { storagePath, err: String(e) });
  }
  const pdfStorageUrl = `https://storage.googleapis.com/${bucket.name}/${storagePath}`;
  logger.info("[fetchNewsletters] Storage upload done", {
    storagePath,
    size: buffer.length,
    pdfStorageUrl,
  });
  return { storagePath, pdfStorageUrl };
}

/**
 * Firestore newsletters 컬렉션에 메타데이터 저장
 */
async function saveNewsletterMeta(doc: NewsletterDoc): Promise<void> {
  logger.info("[fetchNewsletters] Firestore save start", { articleSeq: doc.articleSeq, title: doc.title });
  const db = getFirestore();
  const col = db.collection("newsletters");
  const docRef = col.doc(doc.articleSeq);
  const existing = await docRef.get();
  const now = Timestamp.now();
  const payload: Record<string, unknown> = {
    articleSeq: doc.articleSeq,
    title: doc.title,
    sourcePdfUrl: doc.sourcePdfUrl,
    pdfStoragePath: doc.pdfStoragePath,
    updatedAt: now,
  };
  if (doc.pdfStorageUrl) payload.pdfStorageUrl = doc.pdfStorageUrl;
  if (doc.thumbnailUrl) payload.thumbnailUrl = doc.thumbnailUrl;
  if (doc.thumbnailAlt) payload.thumbnailAlt = doc.thumbnailAlt;
  if (doc.pdfMetaDataID) payload.pdfMetaDataID = doc.pdfMetaDataID;
  if (!existing.exists) {
    payload.createdAt = now;
    await docRef.set(payload);
    logger.info("[fetchNewsletters] Firestore save done (created)", {
      articleSeq: doc.articleSeq,
      title: doc.title,
    });
  } else {
    await docRef.set(payload, { merge: true });
    logger.info("[fetchNewsletters] Firestore save done (updated)", {
      articleSeq: doc.articleSeq,
      title: doc.title,
    });
  }
}

/**
 * 합강소식지 목록 크롤링 → PDF Storage 저장 → Firestore 메타데이터 저장
 */
export async function fetchNewsletters(options?: {
  maxListPages?: number;
}): Promise<{
  pagesProcessed: number;
  itemsProcessed: number;
  pdfUploaded: number;
  skippedExisting: number;
}> {
  const maxListPages = options?.maxListPages ?? 1;
  const db = getFirestore();
  const newslettersRef = db.collection("newsletters");

  let pagesProcessed = 0;
  let itemsProcessed = 0;
  let pdfUploaded = 0;
  let skippedExisting = 0;

  logger.info("[fetchNewsletters] Start", { maxListPages });

  const browser = await setupBrowser();
  let downloadPage: Page | null = null;
  try {
    // PDF 다운로드용 공용 페이지를 미리 만들어 두고 재사용해 메모리 사용을 줄인다.
    downloadPage = await prepareDownloadPage(browser);

    for (let pageIndex = 1; pageIndex <= maxListPages; pageIndex++) {
      logger.info("[fetchNewsletters] List page loop start", { pageIndex, maxListPages });
      const html = await fetchNewsletterListHtml(browser, pageIndex);
      const items = parseNewsletterList(html);
      if (items.length === 0) {
        logger.info("[fetchNewsletters] No items on page, stop", { pageIndex });
        break;
      }
      pagesProcessed++;
      logger.info("[fetchNewsletters] Page parsed", { pageIndex, itemCount: items.length });

      let itemIndex = 0;
      for (const item of items) {
        itemIndex++;
        const { pdfArticleSeq, title, pdfDownloadUrl, thumbnailUrl, thumbnailAlt, pdfMetaDataID } = item;
        logger.info("[fetchNewsletters] Item start", {
          pageIndex,
          itemIndex,
          itemCount: items.length,
          articleSeq: pdfArticleSeq,
          title,
        });

        const existing = await newslettersRef.doc(pdfArticleSeq).get();
        if (existing.exists) {
          skippedExisting++;
          logger.info("[fetchNewsletters] Duplicate by articleSeq, skip", {
            articleSeq: pdfArticleSeq,
            title,
          });
          continue;
        }

        if (!downloadPage) {
          logger.info("[fetchNewsletters] Recreating download page");
          downloadPage = await prepareDownloadPage(browser);
        }

        const buffer = await downloadPdfWithBrowser(downloadPage, pdfDownloadUrl);
        if (!buffer) {
          logger.warn("[fetchNewsletters] PDF buffer null, skip", { articleSeq: pdfArticleSeq, title });
          continue;
        }

        const { storagePath: pdfStoragePath, pdfStorageUrl } = await uploadPdfToStorage(pdfArticleSeq, buffer);
        const now = Timestamp.now();
        await saveNewsletterMeta({
          articleSeq: pdfArticleSeq,
          title,
          thumbnailUrl,
          thumbnailAlt,
          sourcePdfUrl: pdfDownloadUrl,
          pdfStoragePath,
          pdfStorageUrl,
          pdfMetaDataID,
          createdAt: now,
          updatedAt: now,
        });
        itemsProcessed++;
        pdfUploaded++;
        logger.info("[fetchNewsletters] Item done", {
          articleSeq: pdfArticleSeq,
          title,
          itemsProcessed,
          pdfUploaded,
        });
      }
      logger.info("[fetchNewsletters] List page loop done", { pageIndex, pagesProcessed });
    }

    logger.info("[fetchNewsletters] Done", {
      pagesProcessed,
      itemsProcessed,
      pdfUploaded,
      skippedExisting,
    });
    return { pagesProcessed, itemsProcessed, pdfUploaded, skippedExisting };
  } finally {
    logger.info("[fetchNewsletters] Cleanup start");
    try {
      if (downloadPage) {
        logger.info("[fetchNewsletters] Closing download page");
        await downloadPage.close();
      }
    } catch (e) {
      logger.warn("[fetchNewsletters] Download page close error", { err: String(e) });
    }
    try {
      logger.info("[fetchNewsletters] Closing browser");
      await browser.close();
      logger.info("[fetchNewsletters] Browser closed");
    } catch (e) {
      logger.warn("[fetchNewsletters] Browser close error", { err: String(e) });
    }
    logger.info("[fetchNewsletters] Cleanup done");
  }
}

import {
  Browser as BrowserEnum,
  computeExecutablePath,
  detectBrowserPlatform,
  getInstalledBrowsers,
  install,
} from "@puppeteer/browsers";
import * as cheerio from "cheerio";
import { getFirestore } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import * as fs from "node:fs";
import * as path from "node:path";
import puppeteer, { type Browser, type Page } from "puppeteer";
import type { Article, Attachment } from "../types/article.js";
import { truncateToMaxBytes } from "../utils/truncateBytes.js";

const BASE_URL = "https://www.inje.go.kr";
const LIST_PATH = "/portal/adm/notice";
const LIST_URL = BASE_URL + LIST_PATH;

const USER_AGENT =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";

const CHROME_BUILD_ID = "131.0.6778.204";

/**
 * Puppeteer 브라우저 설정 및 실행.
 * PUPPETEER_EXECUTABLE_PATH 없으면 @puppeteer/browsers로 Chrome 설치 후 실행 (캐시: /tmp 또는 .cache).
 */
async function setupBrowser(): Promise<Browser> {
  let executablePath: string | undefined;

  if (process.env.PUPPETEER_EXECUTABLE_PATH) {
    executablePath = process.env.PUPPETEER_EXECUTABLE_PATH;
    logger.info("[fetchNotice] Using PUPPETEER_EXECUTABLE_PATH", { executablePath });
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
        logger.info("[fetchNotice] Using puppeteer.executablePath()", { executablePath });
      }
    } catch (e) {
      logger.info("[fetchNotice] puppeteer.executablePath() not available, will install Chrome", { err: String(e) });
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
            logger.info("[fetchNotice] Using Chrome from @puppeteer/browsers", { executablePath, cacheDir });
          }
        }
      } catch (err) {
        logger.warn("[fetchNotice] Chrome install/setup failed", { err: String(err) });
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

  logger.info("[fetchNotice] Launching browser");
  return await puppeteer.launch(launchOptions);
}

/**
 * Puppeteer로 URL HTML 가져오기
 */
async function fetchHtmlWithBrowser(browser: Browser, url: string): Promise<string> {
  let page: Page | null = null;
  try {
    page = await browser.newPage();
    await page.setViewport({ width: 1920, height: 1080 });
    await page.setUserAgent(USER_AGENT);
    logger.info("[fetchNotice] Fetching HTML", { url });
    const response = await page.goto(url, {
      waitUntil: "domcontentloaded",
      timeout: 60000,
    });
    const status = response?.status();
    if (!response || !response.ok()) {
      logger.warn("[fetchNotice] HTML fetch failed", { url, status });
      return "";
    }
    const html = await page.content();
    logger.info("[fetchNotice] HTML fetched", { url, status, length: html.length });
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
 * 상세 URL 방문하여 HTML 가져오기
 */
async function fetchDetailHtml(browser: Browser, detailUrl: string): Promise<string> {
  let page: Page | null = null;
  try {
    page = await browser.newPage();
    await page.setViewport({ width: 1920, height: 1080 });
    await page.setUserAgent(USER_AGENT);
    logger.info("[fetchNotice] Fetching detail", { url: detailUrl });
    const response = await page.goto(detailUrl, {
      waitUntil: "domcontentloaded",
      timeout: 60000,
    });
    const status = response?.status();
    if (!response || !response.ok()) {
      logger.warn("[fetchNotice] Detail fetch failed", { url: detailUrl, status });
      return "";
    }
    const html = await page.content();
    logger.info("[fetchNotice] Detail fetched", { url: detailUrl, status, length: html.length });
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

/** 목록 페이지 한 페이지에서 추출한 글 요약 */
interface ListRow {
  articleSeq: string;
  title: string;
  author: string;
  registeredAt: string;
}

/**
 * 목록 HTML에서 글 목록 추출
 */
function parseListHtml(html: string): ListRow[] {
  const $ = cheerio.load(html);
  const rows: ListRow[] = [];
  $("table.skinTb tbody tr").each((_, tr) => {
    const $tr = $(tr);
    const $link = $tr.find("td.skinTb-sbj a[href*='articleSeq']").first();
    const href = $link.attr("href") ?? "";
    const match = href.match(/articleSeq=(\d+)/);
    if (!match) return;
    const articleSeq = match[1];
    const title = $link.text().trim();
    const author = $tr.find("td.skinTb-name").text().trim();
    const registeredAt = $tr.find("td.skinTb-date").text().trim();
    if (articleSeq && title) {
      rows.push({ articleSeq, title, author, registeredAt });
    }
  });
  return rows;
}

/**
 * 상세 HTML에서 Article 추출 (type: "notice")
 */
function parseDetailHtml(html: string, articleSeq: string, url: string): Article | null {
  const $ = cheerio.load(html);
  const title = $(".skinTb-sbj").first().text().trim();
  if (!title) return null;

  const author = $(".skinTb-name").first().text().trim();
  const registeredAt = $(".skinTb-date").first().text().trim();
  // HTML 포함하여 추출 (Firestore 필드 1MB 제한으로 잘림)
  const rawContent = $(".skinTb-conts").first().html()?.trim() || "";
  const content = truncateToMaxBytes(rawContent);

  // 모든 첨부파일 추출
  const attachments: Attachment[] = [];
  $("div.attachFile a[href*='download']").each((_, el) => {
    const $attach = $(el);
    const href = $attach.attr("href")?.trim();
    const attachmentName = $attach.text().trim().replace(/\s+/g, " ").trim();
    const fileSeqMatch = href?.match(/fileSeq=(\d+)/);
    if (href && attachmentName) {
      const attachmentUrl = href.startsWith("http") ? href : BASE_URL + href;
      attachments.push({
        attachmentUrl,
        attachmentName,
        fileSeq: fileSeqMatch ? fileSeqMatch[1] : undefined,
      });
    }
  });

  const boardCode = $("input[name='boardCode']").attr("value")?.trim();

  return {
    type: "notice",
    url,
    articleSeq,
    boardCode,
    title,
    author,
    registeredAt,
    content,
    attachments,
  };
}


/**
 * Firestore는 undefined 값을 허용하지 않으므로 저장 전 제거
 */
function removeUndefined<T extends Record<string, unknown>>(obj: T): Record<string, unknown> {
  const out: Record<string, unknown> = {};
  for (const key of Object.keys(obj)) {
    const v = obj[key];
    if (v !== undefined) out[key] = v;
  }
  return out;
}

/**
 * 공지사항 목록·상세 크롤링 후 articles 컬렉션에 저장 (type: 'notice')
 * Puppeteer 사용 (TLS/인증서 이슈 회피)
 * @param options.maxListPages 최대 목록 페이지 수 (기본 1)
 */
export async function fetchNotice(options?: { maxListPages?: number }): Promise<{
  articlesCount: number;
}> {
  const maxListPages = options?.maxListPages ?? 1;
  const db = getFirestore();
  const articlesRef = db.collection("articles");

  let articlesCount = 0;

  logger.info("[fetchNotice] Start", { maxListPages });
  const browser = await setupBrowser();
  try {
    for (let page = 1; page <= maxListPages; page++) {
      const listUrl = page === 1 ? LIST_URL : `${LIST_URL}?pageIndex=${page}`;
      logger.info("[fetchNotice] List page", { page, listUrl });
      const listHtml = await fetchHtmlWithBrowser(browser, listUrl);
      if (!listHtml) throw new Error(`List fetch failed: ${listUrl}`);
      const listRows = parseListHtml(listHtml);
      logger.info("[fetchNotice] List parsed", { page, count: listRows.length });
      if (listRows.length === 0) break;

      for (const row of listRows) {
        const detailUrl = `${BASE_URL}${LIST_PATH}?articleSeq=${row.articleSeq}`;
        logger.info("[fetchNotice] Article detail", { articleSeq: row.articleSeq, title: row.title });
        const existingByUrl = await articlesRef.where("url", "==", detailUrl).limit(1).get();
        if (!existingByUrl.empty) {
          logger.info("[fetchNotice] Duplicate by url, skip before detail fetch", {
            articleSeq: row.articleSeq,
            title: row.title,
            url: detailUrl,
          });
          continue;
        }
        const detailHtml = await fetchDetailHtml(browser, detailUrl);
        if (!detailHtml) {
          logger.warn("[fetchNotice] Detail HTML empty, skip", {
            articleSeq: row.articleSeq,
            title: row.title,
            url: detailUrl,
          });
          continue;
        }
        const article = parseDetailHtml(detailHtml, row.articleSeq, detailUrl);
        if (!article) {
          logger.warn("[fetchNotice] Detail parse failed, skip", {
            articleSeq: row.articleSeq,
            title: row.title,
            url: detailUrl,
          });
          continue;
        }

        await articlesRef
          .doc(row.articleSeq)
          .set(removeUndefined(article as unknown as Record<string, unknown>), { merge: true });
        articlesCount++;
        logger.info("[fetchNotice] Article saved", {
          articleSeq: row.articleSeq,
          title: article.title,
          attachmentsCount: article.attachments.length,
          articlesCount,
        });
      }
    }
    logger.info("[fetchNotice] Done", { articlesCount });
  } finally {
    try {
      await browser.close();
      logger.info("[fetchNotice] Browser closed");
    } catch (e) {
      logger.warn("[fetchNotice] Browser close error", { err: String(e) });
    }
  }

  return { articlesCount };
}

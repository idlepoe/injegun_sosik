import {
  Browser as BrowserEnum,
  computeExecutablePath,
  detectBrowserPlatform,
  getInstalledBrowsers,
  install,
} from "@puppeteer/browsers";
import * as cheerio from "cheerio";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import { defineString } from "firebase-functions/params";
import * as fs from "node:fs";
import * as path from "node:path";
import puppeteer, { type Browser, type Page } from "puppeteer";
import * as XLSX from "xlsx";
import type { Article, Attachment } from "../types/article.js";
import { truncateToMaxBytes } from "../utils/truncateBytes.js";
import type { WeekScheduleRow } from "../types/weekSchedule.js";

const BASE_URL = "https://www.inje.go.kr";
const LIST_PATH = "/portal/inje-news/event/weekschedule";
const LIST_URL = BASE_URL + LIST_PATH;

const USER_AGENT =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";

const CHROME_BUILD_ID = "131.0.6778.204";

const googleGeocodingApiKeyParam = defineString("GOOGLE_GEOCODING_API_KEY");
const GOOGLE_GEOCODING_API_URL = "https://maps.googleapis.com/maps/api/geocode/json";

/**
 * Puppeteer 브라우저 설정 및 실행.
 * PUPPETEER_EXECUTABLE_PATH 없으면 @puppeteer/browsers로 Chrome 설치 후 실행 (캐시: /tmp 또는 .cache).
 */
async function setupBrowser(): Promise<Browser> {
  let executablePath: string | undefined;

  if (process.env.PUPPETEER_EXECUTABLE_PATH) {
    executablePath = process.env.PUPPETEER_EXECUTABLE_PATH;
    logger.info("[fetchWeekschedule] Using PUPPETEER_EXECUTABLE_PATH", { executablePath });
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
        logger.info("[fetchWeekschedule] Using puppeteer.executablePath()", { executablePath });
      }
    } catch (e) {
      logger.info("[fetchWeekschedule] puppeteer.executablePath() not available, will install Chrome", { err: String(e) });
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
            logger.info("[fetchWeekschedule] Using Chrome from @puppeteer/browsers", { executablePath, cacheDir });
          }
        }
      } catch (err) {
        logger.warn("[fetchWeekschedule] Chrome install/setup failed", { err: String(err) });
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

  logger.info("[fetchWeekschedule] Launching browser");
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
    logger.info("[fetchWeekschedule] Fetching HTML", { url });
    const response = await page.goto(url, {
      waitUntil: "domcontentloaded",
      timeout: 60000,
    });
    const status = response?.status();
    if (!response || !response.ok()) {
      logger.warn("[fetchWeekschedule] HTML fetch failed", { url, status });
      return "";
    }
    const html = await page.content();
    logger.info("[fetchWeekschedule] HTML fetched", { url, status, length: html.length });
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
 * 상세 URL 방문 후 같은 페이지에서 첫 번째 xlsx 첨부 다운로드 (세션 유지로 ERR_ABORTED 방지)
 */
async function fetchDetailAndAttachment(
  browser: Browser,
  detailUrl: string
): Promise<{ html: string; buffer: Buffer | null; firstXlsxAttachment: Attachment | null }> {
  let page: Page | null = null;
  let html = "";
  let buffer: Buffer | null = null;
  let firstXlsxAttachment: Attachment | null = null;
  try {
    page = await browser.newPage();
    await page.setViewport({ width: 1920, height: 1080 });
    await page.setUserAgent(USER_AGENT);
    logger.info("[fetchWeekschedule] Detail+attachment: fetching detail", { url: detailUrl });
    const response1 = await page.goto(detailUrl, {
      waitUntil: "domcontentloaded",
      timeout: 60000,
    });
    const status1 = response1?.status();
    if (!response1 || !response1.ok()) {
      logger.warn("[fetchWeekschedule] Detail+attachment: detail fetch failed", { url: detailUrl, status: status1 });
      return { html: "", buffer: null, firstXlsxAttachment: null };
    }
    html = await page.content();
    logger.info("[fetchWeekschedule] Detail+attachment: detail fetched", { url: detailUrl, status: status1, length: html.length });

    const $ = cheerio.load(html);
    // 첫 번째 .xlsx 첨부파일 찾기
    const attachmentElements = $("div.attachFile a[href*='download']").toArray();
    for (const el of attachmentElements) {
      const $attach = $(el);
      const href = $attach.attr("href")?.trim();
      const linkText = $attach.text().trim();
      const attachmentName = linkText.replace(/\s+/g, " ").trim();
      const isXlsx = attachmentName.toLowerCase().endsWith(".xlsx") || (href?.includes("download") && href.includes("fileSeq"));
      
      if (href && isXlsx) {
        const fileSeqMatch = href.match(/fileSeq=(\d+)/);
        const fullAttachmentUrl = href.startsWith("http") ? href : BASE_URL + href;
        firstXlsxAttachment = {
          attachmentUrl: fullAttachmentUrl,
          attachmentName,
          fileSeq: fileSeqMatch ? fileSeqMatch[1] : undefined,
        };
        
        const downloadUrl = href.startsWith("http") ? href : BASE_URL + href;
        logger.info("[fetchWeekschedule] Detail+attachment: same page download (first xlsx)", { downloadUrl, attachmentName });
        if (!page) {
          logger.warn("[fetchWeekschedule] Detail+attachment: page is null, cannot download");
          break;
        }
        try {
          // fetch()로 수신하면 리다이렉트(302)·ERR_ABORTED 없이 최종 응답 body 확보
          const bytes = await page.evaluate(
            async (url: string) => {
              const res = await fetch(url, { credentials: "include" });
              if (!res.ok) return { ok: false, status: res.status };
              const ab = await res.arrayBuffer();
              return { ok: true, data: Array.from(new Uint8Array(ab)) };
            },
            downloadUrl
          );
          if (bytes && bytes.ok && Array.isArray(bytes.data)) {
            buffer = Buffer.from(bytes.data);
            logger.info("[fetchWeekschedule] Detail+attachment: binary received", {
              downloadUrl,
              size: buffer.length,
            });
          } else {
            logger.warn("[fetchWeekschedule] Detail+attachment: download not ok", {
              downloadUrl,
              status: bytes && "status" in bytes ? (bytes as { status: number }).status : undefined,
            });
          }
        } catch (err) {
          const e = err as Error;
          logger.warn("[fetchWeekschedule] Detail+attachment: download error", {
            downloadUrl: href.startsWith("http") ? href : BASE_URL + href,
            message: e.message,
          });
        }
        break; // 첫 번째 xlsx만 처리
      }
    }
    
    return { html, buffer, firstXlsxAttachment };
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
 * 상세 HTML에서 Article 추출 (type: "weekschedule")
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
    type: "weekschedule",
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
 * 2행 C열 "(2026. 2. 16. ~ ...)" 에서 연도 추출
 */
function parseYearFromSheet(data: string[][]): number | null {
  const row2 = data[1];
  if (!row2) return null;
  const c2 = String(row2[2] ?? "").trim();
  const match = c2.match(/(\d{4})/);
  return match ? parseInt(match[1], 10) : null;
}

/**
 * 엑셀 시간 셀 값 정규화. Excel은 시간을 하루 비율(0~1)로 저장하므로 0.375 → "09:00" 변환.
 * 이미 "9:00" 형태 문자열이면 그대로 반환.
 */
function normalizeTimeCell(value: unknown): string {
  const s = String(value ?? "").trim();
  if (!s) return s;
  const n = Number(s);
  if (!Number.isFinite(n) || n < 0 || n >= 1) return s;
  const totalMinutes = Math.round(n * 24 * 60);
  const hours = Math.floor(totalMinutes / 60);
  const minutes = totalMinutes % 60;
  return `${String(hours).padStart(2, "0")}:${String(minutes).padStart(2, "0")}`;
}

/**
 * "2.16.(월)" 형태를 yyyy-mm-dd로 변환. 빈 문자열이면 null
 */
function parseDateCell(value: string, year: number): string | null {
  const trimmed = value.trim();
  if (!trimmed) return null;
  const match = trimmed.match(/^(\d{1,2})\.(\d{1,2})\.\([^)]*\)$/);
  if (!match) return null;
  const month = parseInt(match[1], 10);
  const day = parseInt(match[2], 10);
  if (month < 1 || month > 12 || day < 1 || day > 31) return null;
  return `${year}-${String(month).padStart(2, "0")}-${String(day).padStart(2, "0")}`;
}

/**
 * Google Geocoding API를 사용하여 장소명을 좌표로 변환
 * 결과 주소에 '인제'가 포함된 경우에만 좌표 반환
 */
async function geocodePlace(place: string): Promise<{ lat: number; lng: number } | null> {
  if (!place || !place.trim()) {
    return null;
  }

  try {
    const apiKey = googleGeocodingApiKeyParam.value();
    if (!apiKey) {
      logger.warn("[fetchWeekschedule] GOOGLE_GEOCODING_API_KEY not set, skipping geocode", { place });
      return null;
    }
    const encodedPlace = encodeURIComponent(place.trim());
    const url = `${GOOGLE_GEOCODING_API_URL}?address=${encodedPlace}&key=${apiKey}&language=ko`;

    logger.info("[fetchWeekschedule] Geocoding request", { place, url: url.replace(apiKey, "***") });

    const response = await fetch(url);
    
    if (!response.ok) {
      logger.warn("[fetchWeekschedule] Geocoding API request failed", {
        place,
        status: response.status,
        statusText: response.statusText,
      });
      return null;
    }

    const data = await response.json() as {
      status: string;
      results?: Array<{
        formatted_address: string;
        geometry: {
          location: {
            lat: number;
            lng: number;
          };
        };
      }>;
    };

    if (data.status !== "OK" || !data.results || data.results.length === 0) {
      logger.info("[fetchWeekschedule] Geocoding no results", { place, status: data.status });
      return null;
    }

    const firstResult = data.results[0];
    const formattedAddress = firstResult.formatted_address || "";
    
    // '인제'가 포함되어 있는지 확인 (대소문자 구분 없이)
    if (!formattedAddress.toLowerCase().includes("인제")) {
      logger.info("[fetchWeekschedule] Geocoding result does not contain '인제'", {
        place,
        formattedAddress,
      });
      return null;
    }

    const location = firstResult.geometry.location;
    logger.info("[fetchWeekschedule] Geocoding success", {
      place,
      formattedAddress,
      lat: location.lat,
      lng: location.lng,
    });

    return {
      lat: location.lat,
      lng: location.lng,
    };
  } catch (err) {
    const e = err as Error;
    logger.warn("[fetchWeekschedule] Geocoding error", {
      place,
      message: e.message,
      stack: e.stack,
    });
    return null;
  }
}

/**
 * 엑셀 버퍼에서 4행부터 A~E열 추출 (일자→yyyy-mm-dd, 시간, 행사내용, 장소, 소관)
 * 연도는 2행 C열 "(2026. 2. 16. ~ ...)" 에서 추출. 일자 빈 칸은 직전 행 일자 유지.
 * place에 대해 Google Geocoding을 수행하여 '인제'가 포함된 경우 lat/lng 저장.
 */
async function parseExcelRows(buffer: Buffer, articleSeq: string): Promise<WeekScheduleRow[]> {
  let step = "start";
  try {
    logger.info("[fetchWeekschedule] Excel parse start", { articleSeq, bufferLength: buffer.length });
    step = "XLSX.read";
    const workbook = XLSX.read(buffer, { type: "buffer" });
    step = "SheetNames";
    const sheetName = workbook.SheetNames[0];
    logger.info("[fetchWeekschedule] Excel workbook read", {
      articleSeq,
      sheetNames: workbook.SheetNames,
      firstSheet: sheetName,
    });
    if (!sheetName) {
      logger.warn("[fetchWeekschedule] Excel no sheet name", { articleSeq });
      return [];
    }
    step = "Sheets[sheetName]";
    const sheet = workbook.Sheets[sheetName];
    step = "sheet_to_json";
    const data = XLSX.utils.sheet_to_json<string[]>(sheet, { header: 1 }) as string[][];
    logger.info("[fetchWeekschedule] Excel sheet to json", {
      articleSeq,
      dataRows: data?.length ?? 0,
    });
    step = "parseYearFromSheet";
    const year = parseYearFromSheet(data) ?? new Date().getFullYear();
    logger.info("[fetchWeekschedule] Excel year parsed", { articleSeq, year });
    const rows: WeekScheduleRow[] = [];
    let skippedEmptyEventContent = 0;
    let lastDate = "";
    step = "row loop";
    for (let i = 3; i < data.length; i++) {
      const row = data[i] ?? [];
      const dateCell = String(row[0] ?? "").trim();
      const parsed = parseDateCell(dateCell, year);
      if (parsed) lastDate = parsed;
      const date = lastDate;
      const time = normalizeTimeCell(row[1]);
      const eventContent = String(row[2] ?? "").trim();
      if (!eventContent) {
        skippedEmptyEventContent++;
        continue;
      }
      const place = String(row[3] ?? "").trim();
      const department = String(row[4] ?? "").trim();
      
      // place에 대해 geocoding 수행
      let lat: number | undefined;
      let lng: number | undefined;
      if (place) {
        const geocodeResult = await geocodePlace(place);
        if (geocodeResult) {
          lat = geocodeResult.lat;
          lng = geocodeResult.lng;
        }
      }
      
      const rowData: WeekScheduleRow = {
        date,
        time,
        eventContent,
        place,
        department,
        articleSeq,
      };
      
      // lat, lng가 있는 경우에만 추가
      if (lat !== undefined && lng !== undefined) {
        rowData.lat = lat;
        rowData.lng = lng;
      }
      
      rows.push(rowData);
    }
    logger.info("[fetchWeekschedule] Excel parse done", {
      articleSeq,
      rowsCount: rows.length,
      skippedEmptyEventContent,
    });
    return rows;
  } catch (err) {
    const e = err as Error;
    logger.warn("[fetchWeekschedule] Excel parse error", {
      articleSeq,
      step,
      bufferLength: buffer.length,
      message: e.message,
      stack: e.stack,
    });
    throw err;
  }
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
 * 주간일정 목록·상세 크롤링 후 articles 저장, 첨부 엑셀 파싱 후 weekschedules 저장
 * Puppeteer 사용 (TLS/인증서 이슈 회피, fetchList.ts 형태)
 * @param options.maxListPages 최대 목록 페이지 수 (기본 1)
 */
export async function fetchWeekschedule(options?: { maxListPages?: number }): Promise<{
  articlesCount: number;
  weekschedulesCount: number;
}> {
  const maxListPages = options?.maxListPages ?? 1;
  const db = getFirestore();
  const articlesRef = db.collection("articles");
  const weekschedulesRef = db.collection("weekschedules");

  let articlesCount = 0;
  let weekschedulesCount = 0;

  logger.info("[fetchWeekschedule] Start", { maxListPages });
  const browser = await setupBrowser();
  try {
    for (let page = 1; page <= maxListPages; page++) {
      const listUrl = page === 1 ? LIST_URL : `${LIST_URL}?pageIndex=${page}`;
      logger.info("[fetchWeekschedule] List page", { page, listUrl });
      const listHtml = await fetchHtmlWithBrowser(browser, listUrl);
      if (!listHtml) throw new Error(`List fetch failed: ${listUrl}`);
      const listRows = parseListHtml(listHtml);
      logger.info("[fetchWeekschedule] List parsed", { page, count: listRows.length });
      if (listRows.length === 0) break;

      for (const row of listRows) {
        const detailUrl = `${BASE_URL}${LIST_PATH}?articleSeq=${row.articleSeq}`;
        logger.info("[fetchWeekschedule] Article detail", { articleSeq: row.articleSeq, title: row.title });
        const existingByUrlAndTitle = await articlesRef
          .where("url", "==", detailUrl)
          .where("title", "==", row.title)
          .limit(1)
          .get();
        if (!existingByUrlAndTitle.empty) {
          logger.info("[fetchWeekschedule] Duplicate by url and title, skip before detail fetch", {
            articleSeq: row.articleSeq,
            title: row.title,
            url: detailUrl,
          });
          continue;
        }
        const { html: detailHtml, buffer: attachmentBuffer, firstXlsxAttachment } = await fetchDetailAndAttachment(browser, detailUrl);
        if (!detailHtml) {
          logger.warn("[fetchWeekschedule] Detail HTML empty, skip", {
            articleSeq: row.articleSeq,
            title: row.title,
            url: detailUrl,
          });
          continue;
        }
        const article = parseDetailHtml(detailHtml, row.articleSeq, detailUrl);
        if (!article) {
          logger.warn("[fetchWeekschedule] Detail parse failed, skip", {
            articleSeq: row.articleSeq,
            title: row.title,
            url: detailUrl,
          });
          continue;
        }

        await articlesRef
          .doc(row.articleSeq)
          .set(
            { ...removeUndefined(article as unknown as Record<string, unknown>), updatedAt: Timestamp.now() },
            { merge: true }
          );
        articlesCount++;
        logger.info("[fetchWeekschedule] Article saved", {
          articleSeq: row.articleSeq,
          title: article.title,
          attachmentsCount: article.attachments.length,
          articlesCount,
        });

        // 첫 번째 첨부파일이 .xlsx인지 확인하고 파싱
        if (firstXlsxAttachment && firstXlsxAttachment.attachmentName.toLowerCase().endsWith(".xlsx")) {
          logger.info("[fetchWeekschedule] First attachment is xlsx, using buffer from same-page download", {
            articleSeq: row.articleSeq,
            title: article.title,
            attachmentName: firstXlsxAttachment.attachmentName,
          });
          if (!attachmentBuffer) {
            logger.warn("[fetchWeekschedule] Attachment download returned null (same page), skip", {
              articleSeq: row.articleSeq,
              title: article.title,
              attachmentName: firstXlsxAttachment.attachmentName,
            });
          } else {
            try {
              logger.info("[fetchWeekschedule] Excel buffer received, start parse", {
                articleSeq: row.articleSeq,
                title: article.title,
                bufferLength: attachmentBuffer.length,
              });
              const scheduleRows = await parseExcelRows(attachmentBuffer, row.articleSeq);
              logger.info("[fetchWeekschedule] Excel parsed", {
                articleSeq: row.articleSeq,
                title: article.title,
                rows: scheduleRows.length,
              });
              let skippedEmptyEventContent = 0;
              for (const scheduleRow of scheduleRows) {
                if (!scheduleRow.eventContent?.trim()) {
                  skippedEmptyEventContent++;
                  continue;
                }
                await weekschedulesRef.add({ ...scheduleRow, updatedAt: Timestamp.now() });
                weekschedulesCount++;
              }
              if (skippedEmptyEventContent > 0) {
                logger.info("[fetchWeekschedule] Excel rows skipped (empty eventContent)", {
                  articleSeq: row.articleSeq,
                  title: article.title,
                  skippedEmptyEventContent,
                });
              }
            } catch (err) {
              const e = err as Error;
              logger.warn("[fetchWeekschedule] Excel parse failed, skip", {
                articleSeq: row.articleSeq,
                title: article.title,
                attachmentName: firstXlsxAttachment.attachmentName,
                message: e.message,
                stack: e.stack,
              });
            }
          }
        } else {
          logger.info("[fetchWeekschedule] No xlsx attachment (first attachment)", {
            articleSeq: row.articleSeq,
            title: article.title,
            attachmentsCount: article.attachments.length,
            firstAttachmentName: article.attachments[0]?.attachmentName,
          });
        }
      }
    }
    logger.info("[fetchWeekschedule] Done", { articlesCount, weekschedulesCount });
  } finally {
    try {
      await browser.close();
      logger.info("[fetchWeekschedule] Browser closed");
    } catch (e) {
      logger.warn("[fetchWeekschedule] Browser close error", { err: String(e) });
    }
  }

  return { articlesCount, weekschedulesCount };
}

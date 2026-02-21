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
import type { DashboardSliderItem } from "../types/dashboardSlider.js";

const BASE_URL = "https://www.inje.go.kr";
const PORTAL_URL = "https://www.inje.go.kr/portal";

const USER_AGENT =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";

const CHROME_BUILD_ID = "131.0.6778.204";

/**
 * 상대 경로를 https://www.inje.go.kr 기준 절대 URL로 정규화
 */
function normalizeUrl(url: string): string {
  const trimmed = url?.trim() || "";
  if (!trimmed) return "";
  if (trimmed.startsWith("http://") || trimmed.startsWith("https://")) {
    return trimmed;
  }
  const pathStart = trimmed.startsWith("/") ? trimmed : `/${trimmed}`;
  return BASE_URL + pathStart;
}

/**
 * linkUrl에서 inje.go.kr 포함 시 articleSeq 쿼리 파라미터 추출
 */
function getArticleSeqFromLinkUrl(linkUrl: string): string | null {
  if (!linkUrl || !linkUrl.includes("inje.go.kr")) return null;
  try {
    const u = new URL(linkUrl);
    const seq = u.searchParams.get("articleSeq");
    return seq ?? null;
  } catch {
    return null;
  }
}

/**
 * linkUrl이 빈 값 또는 http:// 만 있으면 null로 처리
 */
function normalizeLinkUrl(href: string | undefined): string | null {
  const trimmed = href?.trim() || "";
  if (!trimmed || trimmed === "http://" || trimmed === "https://") return null;
  return normalizeUrl(trimmed);
}

async function setupBrowser(): Promise<Browser> {
  let executablePath: string | undefined;

  if (process.env.PUPPETEER_EXECUTABLE_PATH) {
    executablePath = process.env.PUPPETEER_EXECUTABLE_PATH;
    logger.info("[fetchDashboardSlider] Using PUPPETEER_EXECUTABLE_PATH", { executablePath });
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
        logger.info("[fetchDashboardSlider] Using puppeteer.executablePath()", { executablePath });
      }
    } catch (e) {
      logger.info("[fetchDashboardSlider] puppeteer.executablePath() not available, will install Chrome", {
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
            logger.info("[fetchDashboardSlider] Using Chrome from @puppeteer/browsers", {
              executablePath,
              cacheDir,
            });
          }
        }
      } catch (err) {
        logger.warn("[fetchDashboardSlider] Chrome install/setup failed", { err: String(err) });
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

  logger.info("[fetchDashboardSlider] Launching browser");
  return await puppeteer.launch(launchOptions);
}

async function fetchHtmlWithBrowser(browser: Browser, url: string): Promise<string> {
  let page: Page | null = null;
  try {
    page = await browser.newPage();
    await page.setViewport({ width: 1920, height: 1080 });
    await page.setUserAgent(USER_AGENT);
    logger.info("[fetchDashboardSlider] Fetching HTML", { url });
    const response = await page.goto(url, {
      waitUntil: "domcontentloaded",
      timeout: 60000,
    });
    const status = response?.status();
    if (!response || !response.ok()) {
      logger.warn("[fetchDashboardSlider] HTML fetch failed", { url, status });
      return "";
    }
    const html = await page.content();
    logger.info("[fetchDashboardSlider] HTML fetched", { url, status, length: html.length });
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
 * 포털 HTML에서 슬라이더 아이템 추출 (.slick-track 직계 자식, slick-cloned 제외)
 */
function parseSliderHtml(html: string): DashboardSliderItem[] {
  const $ = cheerio.load(html);
  const items: DashboardSliderItem[] = [];
  const $track = $(".slick.slick-initialized.slick-slider .slick-list .slick-track");
  if (!$track.length) {
    logger.warn("[fetchDashboardSlider] No .slick-track found");
    return items;
  }

  let order = 0;
  $track.children().each((_, el) => {
    const $el = $(el);
    if ($el.hasClass("slick-cloned")) return;

    const imgSrc = $el.find("img").attr("src");
    const imageUrl = imgSrc ? normalizeUrl(imgSrc) : "";
    const imageAlt = $el.find("img").attr("alt")?.trim() ?? "";
    const hiddenTxt = $el.find("div.hidden_txt").text().trim();
    const title = (hiddenTxt || imageAlt).trim();
    if (!title) return;

    let linkUrl: string | null = null;
    if ($el.is("a")) {
      const href = $el.attr("href");
      linkUrl = normalizeLinkUrl(href);
    }
    if (!linkUrl) return;

    const articleSeq = linkUrl ? getArticleSeqFromLinkUrl(linkUrl) : null;
    const dataSeq = $el.attr("data-seq")?.trim() ?? null;

    items.push({
      imageUrl,
      imageAlt,
      title,
      linkUrl,
      articleSeq,
      dataSeq,
      order: order++,
    });
  });

  return items;
}

/**
 * 대시보드 슬라이더 크롤링: 포털 메인 페이지에서 배너 슬라이더 추출 후 Firestore 저장
 * 크롤링마다 dashboardSliders 컬렉션에 새 문서 추가 (doc id 자동 생성)
 */
export async function fetchDashboardSlider(): Promise<{
  docId: string;
  itemsCount: number;
  updatedAt: string;
}> {
  const db = getFirestore();
  const ref = db.collection("dashboardSliders").doc();

  logger.info("[fetchDashboardSlider] Start");
  const browser = await setupBrowser();
  try {
    const html = await fetchHtmlWithBrowser(browser, PORTAL_URL);
    if (!html) {
      throw new Error(`Portal fetch failed: ${PORTAL_URL}`);
    }
    const items = parseSliderHtml(html);
    logger.info("[fetchDashboardSlider] Parsed", { count: items.length });

    const updatedAt = new Date().toISOString();
    await ref.set({ items, updatedAt });
    logger.info("[fetchDashboardSlider] Saved", { docId: ref.id, itemsCount: items.length, updatedAt });

    return { docId: ref.id, itemsCount: items.length, updatedAt };
  } finally {
    try {
      await browser.close();
      logger.info("[fetchDashboardSlider] Browser closed");
    } catch (e) {
      logger.warn("[fetchDashboardSlider] Browser close error", { err: String(e) });
    }
  }
}

import {
  Browser as BrowserEnum,
  computeExecutablePath,
  detectBrowserPlatform,
  getInstalledBrowsers,
  install,
} from "@puppeteer/browsers";
import * as cheerio from "cheerio";
import * as crypto from "node:crypto";
import { getFirestore, Timestamp } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import * as fs from "node:fs";
import * as path from "node:path";
import puppeteer, { type Browser, type Page } from "puppeteer";
import type { Soldier, SoldierCategory } from "../types/soldier.js";
import { encodeGeohash, geocodeAddress } from "../utils/geocoding.js";

const BASE_URL = "https://www.inje.go.kr";
const USER_AGENT =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36";
const CHROME_BUILD_ID = "131.0.6778.204";

const SOLDIER_URLS: { category: SoldierCategory; path: string }[] = [
  { category: "restaurant", path: "/portal/inje-news/soldier/givePreference/restaurant" },
  { category: "lodgingIndustry", path: "/portal/inje-news/soldier/givePreference/lodgingIndustry" },
  { category: "hair", path: "/portal/inje-news/soldier/givePreference/hair" },
  { category: "pcroom", path: "/portal/inje-news/soldier/givePreference/pcroom" },
];

async function setupBrowser(): Promise<Browser> {
  let executablePath: string | undefined;

  if (process.env.PUPPETEER_EXECUTABLE_PATH) {
    executablePath = process.env.PUPPETEER_EXECUTABLE_PATH;
    logger.info("[fetchSoldiers] Using PUPPETEER_EXECUTABLE_PATH", { executablePath });
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
        logger.info("[fetchSoldiers] Using puppeteer.executablePath()", { executablePath });
      }
    } catch (e) {
      logger.info("[fetchSoldiers] puppeteer.executablePath() not available, will install Chrome", {
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
            logger.info("[fetchSoldiers] Using Chrome from @puppeteer/browsers", {
              executablePath,
              cacheDir,
            });
          }
        }
      } catch (err) {
        logger.warn("[fetchSoldiers] Chrome install/setup failed", { err: String(err) });
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

  logger.info("[fetchSoldiers] Launching browser");
  return await puppeteer.launch(launchOptions);
}

async function fetchHtmlWithBrowser(browser: Browser, url: string): Promise<string> {
  let page: Page | null = null;
  try {
    page = await browser.newPage();
    await page.setViewport({ width: 1920, height: 1080 });
    await page.setUserAgent(USER_AGENT);
    logger.info("[fetchSoldiers] Fetching HTML", { url });
    const response = await page.goto(url, {
      waitUntil: "domcontentloaded",
      timeout: 60000,
    });
    const status = response?.status();
    if (!response || !response.ok()) {
      logger.warn("[fetchSoldiers] HTML fetch failed", { url, status });
      return "";
    }
    const html = await page.content();
    logger.info("[fetchSoldiers] HTML fetched", { url, status, length: html.length });
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

/** thead th 텍스트로 4열(패턴 A) vs 5열(패턴 B) 구분 */
function detectTablePattern(
  $table: ReturnType<ReturnType<typeof cheerio.load>>
): "patternA" | "patternB" | null {
  const $ths = $table.find("thead tr:first th");
  const count = $ths.length;
  const firstText = $ths.eq(0).text().trim();
  const secondText = $ths.eq(1).text().trim();

  if (count === 4 && firstText === "행정동") return "patternA";
  if (count === 5 && firstText === "구분" && secondText === "업종") return "patternB";
  return null;
}

/**
 * 테이블 HTML에서 군장병 우대업소 행 추출 (패턴 A: 4열, 패턴 B: 5열 지원)
 */
function parseTable(html: string, category: SoldierCategory): Soldier[] {
  const $ = cheerio.load(html);
  const rows: Soldier[] = [];
  let $table = $(".listy1 .tbtype1.ml20px.mb20px table").first();
  if (!$table.length) {
    $table = $(".tbtype1.ml20px.mb20px table").first();
  }
  if (!$table.length) {
    logger.warn("[fetchSoldiers] No table found", { category });
    return rows;
  }

  const pattern = detectTablePattern($table);
  if (!pattern) {
    logger.warn("[fetchSoldiers] Unknown table pattern", { category });
    return rows;
  }

  let currentDistrict = "";
  const $trs = $table.find("tbody tr");

  $trs.each((_, tr) => {
    const $tr = $(tr);
    const $tds = $tr.find("td");
    const tdTexts = $tds.map((__, td) => $(td).text().trim()).get();

    if (pattern === "patternA") {
      // 4열: 행정동 | 업소명 | 주소 | 전화번호
      if (tdTexts.length === 4) {
        currentDistrict = tdTexts[0] || "";
        const name = tdTexts[1] || "";
        const address = tdTexts[2] || "";
        const phone = tdTexts[3] || "";
        if (name) {
          rows.push({ district: currentDistrict, category, name, address, phone });
        }
      } else if (tdTexts.length === 3) {
        const name = tdTexts[0] || "";
        const address = tdTexts[1] || "";
        const phone = tdTexts[2] || "";
        if (name) {
          rows.push({ district: currentDistrict, category, name, address, phone });
        }
      }
    } else {
      // 5열: 구분 | 업종 | 업소명 | 주소 | 전화번호
      if (tdTexts.length === 5) {
        currentDistrict = tdTexts[0] || "";
        const name = tdTexts[2] || "";
        const address = tdTexts[3] || "";
        const phone = tdTexts[4] || "";
        if (name) {
          rows.push({ district: currentDistrict, category, name, address, phone });
        }
      } else if (tdTexts.length === 4) {
        const name = tdTexts[1] || "";
        const address = tdTexts[2] || "";
        const phone = tdTexts[3] || "";
        if (name) {
          rows.push({ district: currentDistrict, category, name, address, phone });
        }
      } else if (tdTexts.length === 3) {
        const name = tdTexts[0] || "";
        const address = tdTexts[1] || "";
        const phone = tdTexts[2] || "";
        if (name) {
          rows.push({ district: currentDistrict, category, name, address, phone });
        }
      }
    }
  });

  return rows;
}

function stableDocId(category: string, district: string, name: string, address: string): string {
  const raw = [category, district, name, address].map((s) => s.trim()).join("|");
  return crypto.createHash("sha256").update(raw).digest("hex").slice(0, 20);
}

const BATCH_SIZE = 500;

/**
 * 군장병 우대업소 4개 URL 크롤링 후 Firestore soldiers 컬렉션에 전체 교체 저장
 */
export async function fetchSoldiers(): Promise<{
  saved: number;
  byCategory: Record<SoldierCategory, number>;
}> {
  const db = getFirestore();
  const soldiersRef = db.collection("soldiers");

  const byCategory: Record<SoldierCategory, number> = {
    restaurant: 0,
    lodgingIndustry: 0,
    hair: 0,
    pcroom: 0,
  };

  logger.info("[fetchSoldiers] Start");

  // 취득 전에 soldiers 컬렉션 전체 삭제 (스케줄/수동 공통)
  let snap = await soldiersRef.limit(BATCH_SIZE).get();
  while (!snap.empty) {
    const batch = db.batch();
    snap.docs.forEach((doc) => batch.delete(doc.ref));
    await batch.commit();
    snap = await soldiersRef.limit(BATCH_SIZE).get();
  }
  logger.info("[fetchSoldiers] Soldiers collection cleared");

  const browser = await setupBrowser();
  const allRows: Soldier[] = [];

  try {
    for (const { category, path: listPath } of SOLDIER_URLS) {
      const url = BASE_URL + listPath;
      const html = await fetchHtmlWithBrowser(browser, url);
      if (!html) {
        logger.warn("[fetchSoldiers] Skip category, no HTML", { category, url });
        continue;
      }
      const rows = parseTable(html, category);
      byCategory[category] = rows.length;
      allRows.push(...rows);
      logger.info("[fetchSoldiers] Parsed", { category, count: rows.length });
    }

    if (allRows.length === 0) {
      logger.warn("[fetchSoldiers] No rows to save");
      return { saved: 0, byCategory };
    }

    // 한글 주소 → 좌표·geohash 보강 (주소가 있는 행만, 실패 시 해당 필드 미포함)
    for (const row of allRows) {
      const addr = row.address?.trim();
      if (!addr) continue;
      const geo = await geocodeAddress(addr);
      if (geo) {
        row.lat = geo.lat;
        row.lng = geo.lng;
        row.geohash = encodeGeohash(geo.lat, geo.lng);
        if (geo.placeId) row.placeId = geo.placeId;
      }
    }
    logger.info("[fetchSoldiers] Geocoding done");

    // 새 문서 일괄 쓰기 (배치 500건 제한)
    const now = Timestamp.now();
    let written = 0;
    for (let i = 0; i < allRows.length; i += BATCH_SIZE) {
      const chunk = allRows.slice(i, i + BATCH_SIZE);
      const batch = db.batch();
      for (const row of chunk) {
        const id = stableDocId(row.category, row.district, row.name, row.address);
        batch.set(soldiersRef.doc(id), { ...row, updatedAt: now });
      }
      await batch.commit();
      written += chunk.length;
      logger.info("[fetchSoldiers] Batch write", { written, total: allRows.length });
    }

    logger.info("[fetchSoldiers] Done", { saved: written, byCategory });
    return { saved: written, byCategory };
  } finally {
    try {
      await browser.close();
      logger.info("[fetchSoldiers] Browser closed");
    } catch (e) {
      logger.warn("[fetchSoldiers] Browser close error", { err: String(e) });
    }
  }
}

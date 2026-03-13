import * as logger from "firebase-functions/logger";
import { setupBrowser } from "../types/browser";

interface CgvApiResponse {
  [key: string]: unknown;
}

interface DailyCgvScreenInfo {
  scnYmd: string;
  data: CgvApiResponse;
}

interface FetchCgvScreenInfoResult {
  success: boolean;
  days: number;
  items: DailyCgvScreenInfo[];
}

const CGV_URL = "https://m.cgv.co.kr/";
const CGV_API_BASE_URL = "https://api.cgv.co.kr/cnm/atkt/searchMovScnInfo";
const CO_CD = "A420";
const SITE_NO = "0281";
const RTCTL_SCOP_CD = "08";

function formatYmd(date: Date): string {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, "0");
  const day = String(date.getDate()).padStart(2, "0");
  return `${year}${month}${day}`;
}

function getSeoulToday(): Date {
  const now = new Date();
  const seoulNow = new Date(now.toLocaleString("en-US", { timeZone: "Asia/Seoul" }));
  return new Date(seoulNow.getFullYear(), seoulNow.getMonth(), seoulNow.getDate());
}

export async function fetchCgvScreenInfoWeek(): Promise<FetchCgvScreenInfoResult> {
  const browser = await setupBrowser();

  try {
    const page = await browser.newPage();
    await page.goto(CGV_URL, { waitUntil: "domcontentloaded" });

    const seoulToday = getSeoulToday();
    const dates = Array.from({ length: 7 }, (_, i) => {
      const d = new Date(seoulToday);
      d.setDate(seoulToday.getDate() + i);
      return formatYmd(d);
    });

    const items: DailyCgvScreenInfo[] = [];

    for (const scnYmd of dates) {
      const data = await page.evaluate(
        async ({
          apiBaseUrl,
          coCd,
          siteNo,
          rtctlScopCd,
          targetDate,
        }: {
          apiBaseUrl: string;
          coCd: string;
          siteNo: string;
          rtctlScopCd: string;
          targetDate: string;
        }) => {
          const url = `${apiBaseUrl}?coCd=${coCd}&siteNo=${siteNo}&scnYmd=${targetDate}&rtctlScopCd=${rtctlScopCd}`;

          const res = await fetch(url, {
            method: "GET",
            headers: {
              accept: "application/json",
            },
          });

          if (!res.ok) {
            throw new Error(`CGV API request failed: ${res.status} ${res.statusText}`);
          }

          return res.json();
        },
        {
          apiBaseUrl: CGV_API_BASE_URL,
          coCd: CO_CD,
          siteNo: SITE_NO,
          rtctlScopCd: RTCTL_SCOP_CD,
          targetDate: scnYmd,
        },
      );

      items.push({ scnYmd, data: data as CgvApiResponse });
    }

    logger.info("[fetchCgvScreenInfoWeek] completed", { days: items.length });

    return {
      success: true,
      days: items.length,
      items,
    };
  } catch (err) {
    logger.error("[fetchCgvScreenInfoWeek] failed", err);
    throw err;
  } finally {
    await browser.close();
  }
}

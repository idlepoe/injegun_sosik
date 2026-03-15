import { onRequest } from "firebase-functions/v2/https";
import { onSchedule } from "firebase-functions/v2/scheduler";
import * as logger from "firebase-functions/logger";
import { fetchWeather } from "./models/fetchWeather.js";
import { fetchWeekschedule } from "./models/fetchWeekschedule.js";
import { fetchLivelihood } from "./models/fetchLivelihood.js";
import { fetchJob } from "./models/fetchJob.js";
import { fetchFree } from "./models/fetchFree.js";
import { fetchNotice } from "./models/fetchNotice.js";
import { fetchPraise } from "./models/fetchPraise.js";
import { fetchNewsletters } from "./models/fetchNewsletters.js";
import { fetchDashboardSlider } from "./models/fetchDashboardSlider.js";
import { fetchSoldiers } from "./models/fetchSoldiers.js";
import { sendPushForArticlesUpdatedInLastHour } from "./pushArticleByTopic.js";

const OPT = { maxListPages: 1 } as const;

/** 스케줄 A와 동일한 순서로 fetch 실행 (날씨 → 주간일정 → 생활장터 → 구인구직 → 자유 → 공지) */
async function runFetchEveryThreeHours(): Promise<{ success: boolean; error?: string }> {
  try {
    await fetchWeather();
    await fetchWeekschedule(OPT);
    await fetchLivelihood(OPT);
    await fetchJob(OPT);
    await fetchFree(OPT);
    await fetchNotice(OPT);
    await fetchPraise(OPT);
    logger.info("runFetchEveryThreeHours: fetch done");
    try {
      await sendPushForArticlesUpdatedInLastHour();
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      logger.error("runFetchEveryThreeHours: push failed (non-fatal)", { error: msg });
    }
    return { success: true };
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    logger.error("runFetchEveryThreeHours failed", { error: msg });
    return { success: false, error: msg };
  }
}

/**
 * 스케줄 A: 매일 6, 9, 12, 15, 18시(Asia/Seoul) — 날씨·주간일정·생활장터·구인구직·자유·공지 순차 실행 후, 새 글 건수/최신 정보로 토픽 푸시
 */
export const scheduledFetchEveryThreeHours = onSchedule(
  {
    region: "asia-northeast3",
    schedule: "0 6,9,12,15,18 * * *",
    timeZone: "Asia/Seoul",
    timeoutSeconds: 1800,
    memory: "2GiB",
  },
  async () => {
    const r = await runFetchEveryThreeHours();
    if (!r.success) {
      logger.error("scheduledFetchEveryThreeHours failed", r);
      throw new Error(r.error ?? "scheduledFetchEveryThreeHours failed");
    }
    logger.info("scheduledFetchEveryThreeHours done", r);
  }
);

/**
 * 스케줄 A와 동일한 fetch를 수동 실행하는 public GET 엔드포인트
 */
export const runFetchEveryThreeHoursFn = onRequest(
  { region: "asia-northeast3", maxInstances: 2, memory: "2GiB", timeoutSeconds: 3600 },
  async (req, res) => {
    if (req.method !== "GET") {
      res.status(405).set("Allow", "GET").send("Method Not Allowed");
      return;
    }
    const r = await runFetchEveryThreeHours();
    if (!r.success) {
      res.status(500).json(r);
      return;
    }
    res.status(200).json(r);
  }
);

/**
 * 스케줄 B: 매일 6시, 18시(Asia/Seoul) — 합강소식지·대시보드 슬라이더 순차 실행
 */
export const scheduledFetchTwiceDaily = onSchedule(
  {
    region: "asia-northeast3",
    schedule: "0 6,18 * * *",
    timeZone: "Asia/Seoul",
    timeoutSeconds: 600,
    memory: "4GiB",
  },
  async () => {
    try {
      const r1 = await fetchNewsletters(OPT);
      logger.info("scheduledFetchTwiceDaily: fetchNewsletters done", r1);
      const r2 = await fetchDashboardSlider();
      logger.info("scheduledFetchTwiceDaily: fetchDashboardSlider done", r2);
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      logger.error("scheduledFetchTwiceDaily failed", { error: msg });
      throw new Error(msg);
    }
  }
);

/**
 * 스케줄 C: 매월 1일 6시(Asia/Seoul) — 군장병 우대업소 크롤링 (한 달에 한 번)
 */
export const scheduledFetchSoldiersMonthly = onSchedule(
  {
    region: "asia-northeast3",
    schedule: "0 6 1 * *",
    timeZone: "Asia/Seoul",
    timeoutSeconds: 600,
    memory: "1GiB",
  },
  async () => {
    try {
      const r = await fetchSoldiers();
      logger.info("scheduledFetchSoldiersMonthly done", r);
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      logger.error("scheduledFetchSoldiersMonthly failed", { error: msg });
      throw new Error(msg);
    }
  }
);

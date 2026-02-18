/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import * as admin from "firebase-admin";
import { setGlobalOptions } from "firebase-functions";
import { onRequest } from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";
import { fetchWeekschedule } from "./models/fetchWeekschedule.js";

if (!admin.apps.length) {
  admin.initializeApp();
}

setGlobalOptions({ maxInstances: 10 });

/**
 * 주간일정 크롤링: 목록/상세를 articles에, 엑셀 데이터를 weekschedules에 저장
 * GET 호출. 쿼리: maxListPages (최대 목록 페이지 수, 기본 1)
 * Puppeteer/Chrome 사용으로 메모리 1GB, 타임아웃 5분
 */
export const fetchWeekscheduleFn = onRequest(
  { maxInstances: 5, memory: "1GiB", timeoutSeconds: 300 },
  async (req, res) => {
    if (req.method !== "GET") {
      res.status(405).set("Allow", "GET").send("Method Not Allowed");
      return;
    }
    const maxListPages = req.query.maxListPages
      ? Number(req.query.maxListPages)
      : 1;
    try {
      const result = await fetchWeekschedule({ maxListPages });
      logger.info("fetchWeekschedule completed", result);
      res.status(200).json(result);
    } catch (err) {
      logger.error("fetchWeekschedule failed", err);
      res.status(500).json({ error: (err as Error).message });
    }
  }
);

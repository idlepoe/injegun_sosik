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
import { fetchNewsletters } from "./models/fetchNewsletters.js";
import { fetchWeekschedule } from "./models/fetchWeekschedule.js";
import { fetchWeather } from "./models/fetchWeather.js";
import { fetchNotice } from "./models/fetchNotice.js";
import { fetchJob } from "./models/fetchJob.js";
import { fetchLivelihood } from "./models/fetchLivelihood.js";
import { fetchFree } from "./models/fetchFree.js";

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

/**
 * 합강소식지 크롤링: 목록 파싱 후 PDF를 Storage에 저장, 메타데이터를 newsletters 컬렉션에 저장
 * GET 호출. 쿼리: maxListPages (최대 목록 페이지 수, 기본 1)
 * Puppeteer/Chrome + PDF 버퍼로 메모리 사용이 커서 4GB 권장 (fetchNewsletters.ts 주석 참고)
 */
export const fetchNewslettersFn = onRequest(
  { maxInstances: 5, memory: "4GiB", timeoutSeconds: 300 },
  async (req, res) => {
    if (req.method !== "GET") {
      res.status(405).set("Allow", "GET").send("Method Not Allowed");
      return;
    }
    const maxListPages = req.query.maxListPages ? Number(req.query.maxListPages) : 1;
    try {
      const result = await fetchNewsletters({ maxListPages });
      logger.info("fetchNewsletters completed", result);
      res.status(200).json(result);
    } catch (err) {
      logger.error("fetchNewsletters failed", err);
      res.status(500).json({ error: (err as Error).message });
    }
  }
);

/**
 * 날씨 데이터 가져오기: OpenWeatherMap Current Weather Data API를 사용하여 현재 날씨를 가져와서 weathers 컬렉션에 저장
 * GET 호출. 날짜 기준으로 중복된 경우 기존 데이터를 업데이트
 */
export const fetchWeatherFn = onRequest(
  { maxInstances: 10, memory: "256MiB", timeoutSeconds: 60 },
  async (req, res) => {
    if (req.method !== "GET") {
      res.status(405).set("Allow", "GET").send("Method Not Allowed");
      return;
    }
    try {
      const result = await fetchWeather();
      logger.info("fetchWeather completed", result);
      res.status(200).json(result);
    } catch (err) {
      logger.error("fetchWeather failed", err);
      res.status(500).json({ error: (err as Error).message });
    }
  }
);

/**
 * 공지사항 크롤링: 목록/상세를 articles 컬렉션에 저장 (type: 'notice')
 * GET 호출. 쿼리: maxListPages (최대 목록 페이지 수, 기본 1)
 * Puppeteer/Chrome 사용으로 메모리 1GB, 타임아웃 5분
 */
export const fetchNoticeFn = onRequest(
  { maxInstances: 5, memory: "1GiB", timeoutSeconds: 300 },
  async (req, res) => {
    if (req.method !== "GET") {
      res.status(405).set("Allow", "GET").send("Method Not Allowed");
      return;
    }
    const maxListPages = req.query.maxListPages ? Number(req.query.maxListPages) : 1;
    try {
      const result = await fetchNotice({ maxListPages });
      logger.info("fetchNotice completed", result);
      res.status(200).json(result);
    } catch (err) {
      logger.error("fetchNotice failed", err);
      res.status(500).json({ error: (err as Error).message });
    }
  }
);

/**
 * 구인구직 크롤링: 목록/상세를 articles 컬렉션에 저장 (type: 'job')
 * GET 호출. 쿼리: maxListPages (최대 목록 페이지 수, 기본 1)
 */
export const fetchJobFn = onRequest(
  { maxInstances: 5, memory: "1GiB", timeoutSeconds: 300 },
  async (req, res) => {
    if (req.method !== "GET") {
      res.status(405).set("Allow", "GET").send("Method Not Allowed");
      return;
    }
    const maxListPages = req.query.maxListPages ? Number(req.query.maxListPages) : 1;
    try {
      const result = await fetchJob({ maxListPages });
      logger.info("fetchJob completed", result);
      res.status(200).json(result);
    } catch (err) {
      logger.error("fetchJob failed", err);
      res.status(500).json({ error: (err as Error).message });
    }
  }
);

/**
 * 생활장터 크롤링: 목록/상세를 articles 컬렉션에 저장 (type: 'livelihood')
 * GET 호출. 쿼리: maxListPages (최대 목록 페이지 수, 기본 1)
 */
export const fetchLivelihoodFn = onRequest(
  { maxInstances: 5, memory: "1GiB", timeoutSeconds: 300 },
  async (req, res) => {
    if (req.method !== "GET") {
      res.status(405).set("Allow", "GET").send("Method Not Allowed");
      return;
    }
    const maxListPages = req.query.maxListPages ? Number(req.query.maxListPages) : 1;
    try {
      const result = await fetchLivelihood({ maxListPages });
      logger.info("fetchLivelihood completed", result);
      res.status(200).json(result);
    } catch (err) {
      logger.error("fetchLivelihood failed", err);
      res.status(500).json({ error: (err as Error).message });
    }
  }
);

/**
 * 자유게시판 크롤링: 목록/상세를 articles 컬렉션에 저장 (type: 'free')
 * GET 호출. 쿼리: maxListPages (최대 목록 페이지 수, 기본 1)
 */
export const fetchFreeFn = onRequest(
  { maxInstances: 5, memory: "1GiB", timeoutSeconds: 300 },
  async (req, res) => {
    if (req.method !== "GET") {
      res.status(405).set("Allow", "GET").send("Method Not Allowed");
      return;
    }
    const maxListPages = req.query.maxListPages ? Number(req.query.maxListPages) : 1;
    try {
      const result = await fetchFree({ maxListPages });
      logger.info("fetchFree completed", result);
      res.status(200).json(result);
    } catch (err) {
      logger.error("fetchFree failed", err);
      res.status(500).json({ error: (err as Error).message });
    }
  }
);

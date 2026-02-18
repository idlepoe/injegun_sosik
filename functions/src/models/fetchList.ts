import * as functions from "firebase-functions/v1";
import * as logger from "firebase-functions/logger";
import {getFirestore, Timestamp} from "firebase-admin/firestore";
import * as cheerio from "cheerio";
import type {Element} from "domhandler";
import puppeteer from "puppeteer";
import {
  install,
  Browser,
  detectBrowserPlatform,
  getInstalledBrowsers,
  computeExecutablePath,
} from "@puppeteer/browsers";
import {EventData} from "./utils/types";
import {
  generateEventId,
  toAbsoluteUrl,
  parseDate,
  parseTime,
  cleanText,
  BASE_URL,
} from "./utils/utils";

/**
 * Firestore Timestamp 생성 헬퍼 함수
 */
function getFirestoreTimestamp(): Timestamp {
  return Timestamp.now();
}

/**
 * JSON-LD 스키마에서 이벤트 데이터 추출
 */
function parseJsonLdEvents(html: string): Partial<EventData>[] {
  const events: Partial<EventData>[] = [];
  const $ = cheerio.load(html);

  // JSON-LD 스키마 찾기
  $('script[type="application/ld+json"]').each((_: number, element: Element) => {
    try {
      const jsonText = $(element).html();
      if (!jsonText) return;

      const jsonData = JSON.parse(jsonText);
      const eventArray = Array.isArray(jsonData) ? jsonData : [jsonData];

      for (const event of eventArray) {
        if (event["@type"] === "Event") {
          const eventData: Partial<EventData> = {};

          // 기본 정보
          if (event.name) eventData.title = cleanText(event.name);
          if (event.url) {
            eventData.detailUrl = event.url;
            eventData.eventId = generateEventId(event.url);
          }
          if (event.image) eventData.imageUrl = event.image;

          // 날짜 정보
          if (event.startDate) {
            eventData.startDate = parseDate(event.startDate);
            eventData.startTime = parseTime(event.startDate);
          }
          if (event.endDate) {
            eventData.endDate = parseDate(event.endDate);
            eventData.endTime = parseTime(event.endDate);
          }

          // 설명 (HTML 태그 포함 저장)
          if (event.description) {
            eventData.description = event.description;
          }

          // 가격 정보
          if (event.offers) {
            const price = event.offers.price;
            const currency = event.offers.priceCurrency || "USD";
            if (price === "0" || price === 0) {
              eventData.priceDisplay = "Free";
            } else if (price) {
              eventData.priceDisplay = `${currency === "USD" ? "$" : ""}${price}`;
            }
          }

          // 장소 정보
          if (event.location) {
            if (event.location.name) eventData.venueName = event.location.name;
            if (event.location.url) eventData.venueUrl = event.location.url;
            if (event.location.address) {
              const addr = event.location.address;
              if (addr.streetAddress)
                eventData.venueStreetAddress = addr.streetAddress;
              if (addr.addressLocality)
                eventData.venueLocality = addr.addressLocality;
              if (addr.addressRegion) eventData.venueRegion = addr.addressRegion;
              if (addr.postalCode) eventData.venuePostalCode = addr.postalCode;
              if (addr.addressCountry)
                eventData.venueCountry = addr.addressCountry;
            }
            if (event.location.telephone)
              eventData.venuePhone = event.location.telephone;
            if (event.location.sameAs) eventData.venueWebsite = event.location.sameAs;
          }

          // 주최자 정보
          if (event.organizer) {
            if (event.organizer.name)
              eventData.organizerName = event.organizer.name;
            if (event.organizer.url) eventData.organizerUrl = event.organizer.url;
            if (event.organizer.telephone)
              eventData.organizerPhone = event.organizer.telephone;
            if (event.organizer.email)
              eventData.organizerEmail = event.organizer.email;
          }

          if (eventData.eventId && eventData.title) {
            events.push(eventData);
          }
        }
      }
    } catch (error) {
      logger.warn(`Error parsing JSON-LD: ${error}`);
    }
  });

  return events;
}

/**
 * 리스트 페이지에서 이벤트 기본 정보 추출
 */
async function fetchEventListFromPage(
  browser: any,
  pageNum: number = 1
): Promise<{events: Partial<EventData>[]; html: string}> {
  let url = `${BASE_URL}/community/events-calendar/`;
  if (pageNum > 1) {
    url = `${BASE_URL}/events/photo/page/${pageNum}/?hide_subsequent_recurrences=1&shortcode=e89a5463`;
  }

  logger.info(`Fetching event list from page ${pageNum}: ${url}`);

  let page: any = null;
  let html: string = "";

  try {
    // 새 페이지 생성
    page = await browser.newPage();
    await page.setViewport({width: 1920, height: 1080});
    await page.setUserAgent(
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    );

    // 페이지 로딩 (더 안정적인 옵션 사용)
    try {
      await page.goto(url, {
        waitUntil: "domcontentloaded",
        timeout: 60000,
      });
    } catch (gotoError: any) {
      // 프레임 분리 오류 발생 시 페이지 재생성
      if (
        gotoError.message?.includes("frame was detached") ||
        gotoError.message?.includes("Target closed")
      ) {
        logger.warn("Frame detached, creating new page...");
        try {
          if (page) {
            try {
              await page.close();
            } catch (e) {
              // 무시
            }
          }
          page = await browser.newPage();
          await page.setViewport({width: 1920, height: 1080});
          await page.setUserAgent(
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
          );
          await page.goto(url, {
            waitUntil: "domcontentloaded",
            timeout: 60000,
          });
          // 재시도 후 최소 대기
          await new Promise((resolve) => setTimeout(resolve, 500));
        } catch (retryError: any) {
          logger.error(`Retry failed: ${retryError?.message}`);
          if (page) {
            try {
              await page.close();
            } catch (e) {
              // 무시
            }
          }
          return {events: [], html: ""};
        }
      } else {
        throw gotoError;
      }
    }

    // 이벤트 리스트가 로드될 때까지 대기
    try {
      await page.waitForSelector(
        "li.tribe-events-pro-photo__event, script[type='application/ld+json']",
        {timeout: 30000}
      );
      // 최소 대기 시간 (동적 콘텐츠 로딩을 위해)
      await new Promise((resolve) => setTimeout(resolve, 500));
    } catch (e: any) {
      logger.warn(
        `Event list selector not found, continuing anyway: ${e?.message}`
      );
      // HTML이 로드되었는지 확인
      const bodyText = await page.evaluate(() => document.body?.innerText || "");
      if (!bodyText || bodyText.trim().length === 0) {
        logger.warn("Page body is empty, may not have loaded correctly");
      }
    }

    // HTML 가져오기 (에러 핸들링)
    try {
      html = await page.content();
    } catch (contentError: any) {
      logger.error(`Error getting page content: ${contentError?.message}`);
      if (page) {
        try {
          await page.close();
        } catch (e) {
          // 무시
        }
      }
      return {events: [], html: ""};
    }
    const $ = cheerio.load(html);

    // 디버깅: HTML 길이와 이벤트 개수 확인
    const eventCount = $("li.tribe-events-pro-photo__event").length;
    logger.info(`HTML length: ${html.length}, Found ${eventCount} event items`);

    // JSON-LD 스키마에서 이벤트 추출 (우선)
    const jsonLdEvents = parseJsonLdEvents(html);
    const eventMap = new Map<string, Partial<EventData>>();

    // JSON-LD 이벤트를 맵에 추가
    for (const event of jsonLdEvents) {
      if (event.eventId) {
        eventMap.set(event.eventId, event);
      }
    }
    logger.info(`Found ${jsonLdEvents.length} events from JSON-LD`);

    // HTML에서 추가 정보 추출
    $("li.tribe-events-pro-photo__event").each((_: number, element: Element) => {
      const $event = $(element);

      // 이벤트 상세 페이지 링크
      const detailLink =
        $event
          .find("a.tribe-events-pro-photo__event-featured-image-link")
          .attr("href") ||
        $event.find("a.tribe-events-pro-photo__event-title-link").attr("href");
      if (!detailLink) return;

      const detailUrl = toAbsoluteUrl(detailLink);
      const eventId = generateEventId(detailUrl);

      // 기존 이벤트 가져오기 또는 새로 생성
      let eventData = eventMap.get(eventId) || {
        eventId,
        detailUrl,
      };

      // 제목
      const title =
        $event.find("h3.tribe-events-pro-photo__event-title a").text().trim() ||
        $event
          .find("span.tribe-events-pro-photo__event-featured-image-link-inner")
          .text()
          .trim();
      if (title) eventData.title = cleanText(title);

      // 이미지
      const imageUrl = $event
        .find("img.tribe-events-pro-photo__event-featured-image")
        .attr("src");
      if (imageUrl && !imageUrl.includes("tribe-event-placeholder-image")) {
        eventData.imageUrl = toAbsoluteUrl(imageUrl);
      }

      // 날짜 태그 (이벤트 날짜)
      const dateDatetime = $event
        .find("time.tribe-events-pro-photo__event-date-tag-datetime")
        .attr("datetime");
      if (dateDatetime) {
        eventData.dateDatetime = dateDatetime;
        eventData.startDate = dateDatetime; // yyyy-MM-dd 형식
        eventData.endDate = dateDatetime; // 기본적으로 같은 날짜
      }

      // 시간 정보 (div.tribe-events-pro-photo__event-datetime 안의 time 태그들)
      const datetimeDiv = $event.find("div.tribe-events-pro-photo__event-datetime");
      const timeTags = datetimeDiv.find("time[datetime]");

      if (timeTags.length >= 1) {
        // 시작 시간
        const startTimeValue = $(timeTags[0]).attr("datetime");
        if (startTimeValue && startTimeValue.match(/^\d{2}:\d{2}$/)) {
          eventData.startTime = startTimeValue + ":00";
        }
      }

      if (timeTags.length >= 2) {
        // 종료 시간
        const endTimeValue = $(timeTags[1]).attr("datetime");
        if (endTimeValue && endTimeValue.match(/^\d{2}:\d{2}$/)) {
          eventData.endTime = endTimeValue + ":00";
        }
      }

      // 가격
      const priceText = $event
        .find("span.tribe-events-c-small-cta__price")
        .text()
        .trim();
      if (priceText) eventData.priceDisplay = priceText;

      // 반복 이벤트 여부
      const isRecurring =
        $event.hasClass("tribe-recurring-event") ||
        $event.hasClass("tribe-recurring-event-parent");
      eventData.isRecurring = isRecurring;

      // 시리즈 URL
      if (isRecurring) {
        const seriesUrl = $event
          .find("a.tribe-events-calendar-series-archive__link")
          .attr("href");
        if (seriesUrl) eventData.seriesUrl = toAbsoluteUrl(seriesUrl);
      }

      eventMap.set(eventId, eventData);
    });

    const events = Array.from(eventMap.values());
    logger.info(`Found ${events.length} events on page ${pageNum}`);
    return {events, html};
  } catch (error: any) {
    logger.error(`Error fetching event list from page ${pageNum}:`, error);
    return {events: [], html: ""};
  } finally {
    // 페이지 정리
    if (page) {
      try {
        await page.close();
      } catch (e) {
        // 무시
      }
    }
  }
}

/**
 * 상세 페이지에서 추가 정보 추출
 */
async function fetchEventDetail(
  browser: any,
  detailUrl: string
): Promise<Partial<EventData>> {
  const url = toAbsoluteUrl(detailUrl);
  logger.info(`Fetching event detail: ${url}`);

  let page: any = null;
  let html: string = "";

  try {
    // 새 페이지 생성
    page = await browser.newPage();
    await page.setViewport({width: 1920, height: 1080});
    await page.setUserAgent(
      "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
    );

    // 페이지 로딩 (더 안정적인 옵션 사용)
    try {
      await page.goto(url, {
        waitUntil: "domcontentloaded",
        timeout: 60000,
      });
    } catch (gotoError: any) {
      // 프레임 분리 오류 발생 시 페이지 재생성
      if (
        gotoError.message?.includes("frame was detached") ||
        gotoError.message?.includes("Target closed")
      ) {
        logger.warn("Frame detached, creating new page...");
        try {
          if (page) {
            try {
              await page.close();
            } catch (e) {
              // 무시
            }
          }
          page = await browser.newPage();
          await page.setViewport({width: 1920, height: 1080});
          await page.setUserAgent(
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
          );
          await page.goto(url, {
            waitUntil: "domcontentloaded",
            timeout: 60000,
          });
          // 재시도 후 최소 대기
          await new Promise((resolve) => setTimeout(resolve, 500));
        } catch (retryError: any) {
          logger.error(`Retry failed: ${retryError?.message}`);
          if (page) {
            try {
              await page.close();
            } catch (e) {
              // 무시
            }
          }
          return {};
        }
      } else {
        throw gotoError;
      }
    }

    // 페이지 로드 대기
    try {
      await page.waitForSelector(
        "h1.tribe-events-single-event-title, div.tribe-events-meta-group-details",
        {timeout: 30000}
      );
      // 최소 대기 시간 (동적 콘텐츠 로딩을 위해)
      await new Promise((resolve) => setTimeout(resolve, 500));
    } catch (e) {
      logger.warn(`Detail page selectors not found, continuing anyway`);
    }

    // HTML 가져오기 (에러 핸들링)
    try {
      html = await page.content();
    } catch (contentError: any) {
      logger.error(`Error getting page content: ${contentError?.message}`);
      if (page) {
        try {
          await page.close();
        } catch (e) {
          // 무시
        }
      }
      return {};
    }
    const $ = cheerio.load(html);
    const detail: Partial<EventData> = {};

    // 제목
    const title = $("h1.tribe-events-single-event-title").text().trim();
    if (title) detail.title = cleanText(title);

    // 이미지
    const imageUrl = $("div.tribe-events-event-image img").attr("src");
    if (imageUrl) {
      detail.imageUrl = toAbsoluteUrl(imageUrl);
    }

    // 설명 (HTML 태그 포함 저장)
    const description = $("div.tribe-events-single-event-description").html();
    if (description) {
      detail.description = description.trim();
    }

    // Details 섹션
    const detailsSection = $("div.tribe-events-meta-group-details");

    // 시작 날짜/시간
    const startAbbr = detailsSection.find("abbr.tribe-events-start-datetime");
    if (startAbbr.length > 0) {
      const startTitle = startAbbr.attr("title");
      if (startTitle) {
        detail.startDate = parseDate(startTitle);
      }
      const startText = startAbbr.text().trim();
      const timeMatch = startText.match(/(\d{1,2}):(\d{2})\s*(am|pm)/i);
      if (timeMatch) {
        let hours = parseInt(timeMatch[1]);
        const minutes = timeMatch[2];
        const ampm = timeMatch[3].toLowerCase();
        if (ampm === "pm" && hours !== 12) hours += 12;
        if (ampm === "am" && hours === 12) hours = 0;
        detail.startTime = `${String(hours).padStart(2, "0")}:${minutes}:00`;
      }
    }

    // 종료 날짜/시간
    const endAbbr = detailsSection.find("abbr.tribe-events-end-datetime");
    if (endAbbr.length > 0) {
      const endTitle = endAbbr.attr("title");
      if (endTitle) {
        detail.endDate = parseDate(endTitle);
      }
      const endText = endAbbr.text().trim();
      const timeMatch = endText.match(/(\d{1,2}):(\d{2})\s*(am|pm)/i);
      if (timeMatch) {
        let hours = parseInt(timeMatch[1]);
        const minutes = timeMatch[2];
        const ampm = timeMatch[3].toLowerCase();
        if (ampm === "pm" && hours !== 12) hours += 12;
        if (ampm === "am" && hours === 12) hours = 0;
        detail.endTime = `${String(hours).padStart(2, "0")}:${minutes}:00`;
      }
    }

    // 가격
    const price = detailsSection.find("span.tribe-events-event-cost").text().trim();
    if (price) detail.priceDisplay = price;

    // 카테고리
    const categories: string[] = [];
    detailsSection
      .find("span.tribe-events-event-categories a")
      .each((_: number, el: Element) => {
        const cat = $(el).text().trim();
        if (cat) categories.push(cat);
      });
    if (categories.length > 0) detail.categories = categories;

    // 태그
    const tags: string[] = [];
    detailsSection.find("span.tribe-event-tags a").each((_: number, el: Element) => {
      const tag = $(el).text().trim();
      if (tag) tags.push(tag);
    });
    if (tags.length > 0) detail.tags = tags;

    // 웹사이트
    const eventWebsite = detailsSection
      .find("span.tribe-events-event-url a")
      .attr("href");
    if (eventWebsite) detail.eventWebsite = eventWebsite;

    // Venue 섹션
    const venueSection = $("div.tribe-events-meta-group-venue");

    // 장소 이름
    const venueName = venueSection.find("li.tribe-venue a").text().trim();
    if (venueName) detail.venueName = venueName;

    // 장소 URL
    const venueUrl = venueSection.find("li.tribe-venue a").attr("href");
    if (venueUrl) detail.venueUrl = toAbsoluteUrl(venueUrl);

    // 주소
    const streetAddress = venueSection
      .find("span.tribe-street-address")
      .text()
      .trim();
    if (streetAddress) detail.venueStreetAddress = streetAddress;

    const locality = venueSection.find("span.tribe-locality").text().trim();
    if (locality) detail.venueLocality = locality;

    const region = venueSection.find("abbr.tribe-region").attr("title");
    if (region) detail.venueRegion = region;

    const postalCode = venueSection.find("span.tribe-postal-code").text().trim();
    if (postalCode) detail.venuePostalCode = postalCode;

    const country = venueSection.find("span.tribe-country-name").text().trim();
    if (country) detail.venueCountry = country;

    // Google Map URL
    const googleMapUrl = venueSection.find("a.tribe-events-gmap").attr("href");
    if (googleMapUrl) detail.venueGoogleMapUrl = googleMapUrl;

    // 전화번호
    const venuePhone = venueSection.find("span.tribe-venue-tel").text().trim();
    if (venuePhone) detail.venuePhone = venuePhone;

    // 장소 웹사이트
    const venueWebsite = venueSection
      .find("span.tribe-venue-url a")
      .attr("href");
    if (venueWebsite) detail.venueWebsite = venueWebsite;

    // Other 섹션 (소셜 미디어)
    const otherSection = $("div.tribe-events-meta-group-other");
    otherSection.find("dl dt").each((_: number, dtEl: Element) => {
      const label = $(dtEl).text().trim();
      const link = $(dtEl).next("dd").find("a").attr("href");
      if (link) {
        if (label.toLowerCase().includes("facebook")) {
          detail.facebookUrl = link;
        } else if (label.toLowerCase().includes("instagram")) {
          detail.instagramUrl = link;
        }
      }
    });

    return detail;
  } catch (error: any) {
    logger.error(`Error fetching event detail from ${url}:`, error);
    return {};
  } finally {
    // 페이지 정리
    if (page) {
      try {
        await page.close();
      } catch (e) {
        // 무시
      }
    }
  }
}

/**
 * 객체에서 undefined 값을 재귀적으로 제거
 */
function removeUndefined(obj: any): any {
  if (obj === null || obj === undefined) {
    return undefined;
  }

  if (Array.isArray(obj)) {
    const cleaned = obj
      .map((item) => removeUndefined(item))
      .filter((item) => item !== undefined);
    return cleaned.length > 0 ? cleaned : undefined;
  }

  if (typeof obj === "object" && obj.constructor === Object) {
    const cleaned: any = {};
    for (const key in obj) {
      if (obj.hasOwnProperty(key)) {
        const value = removeUndefined(obj[key]);
        if (value !== undefined) {
          cleaned[key] = value;
        }
      }
    }
    return Object.keys(cleaned).length > 0 ? cleaned : undefined;
  }

  return obj;
}

/**
 * 이벤트를 Firestore에 저장 (doc id는 Firestore 자동 생성)
 * detailUrl + startDate 기준 중복 체크 → 중복이면 skip, 없으면 새 문서 추가
 */
async function saveEventToFirestore(event: EventData): Promise<void> {
  const db = getFirestore();
  const col = db.collection("events");

  // detailUrl + startDate 기준 중복 체크
  const existingSnapshot = await col
    .where("detailUrl", "==", event.detailUrl)
    .where("startDate", "==", event.startDate)
    .limit(1)
    .get();

  if (!existingSnapshot.empty) {
    logger.info(`Skipped duplicate event: ${event.title} (detailUrl: ${event.detailUrl}, startDate: ${event.startDate})`);
    return;
  }

  const {countView, ...eventWithoutCountView} = event;
  const cleanedEvent = removeUndefined(eventWithoutCountView);
  const payload = {
    ...cleanedEvent,
    updatedAt: getFirestoreTimestamp(),
  };

  const docRef = await col.add({
    ...payload,
    countView: 0,
  });
  logger.info(`Saved event to Firestore: ${event.title} (doc: ${docRef.id})`);
}

/**
 * Puppeteer 브라우저 설정 및 실행
 */
async function setupBrowser(): Promise<any> {
  let executablePath: string | undefined;

  if (process.env.PUPPETEER_EXECUTABLE_PATH) {
    executablePath = process.env.PUPPETEER_EXECUTABLE_PATH;
    logger.info(`Using Chrome from environment: ${executablePath}`);
  } else {
    try {
      const fs = require("fs");
      const path = require("path");

      const defaultCacheDir = path.join(process.cwd(), ".cache", "puppeteer");
      const tmpCacheDir = "/tmp/.cache/puppeteer";
      const cacheDir = fs.existsSync(defaultCacheDir)
        ? defaultCacheDir
        : tmpCacheDir;

      if (!fs.existsSync(cacheDir)) {
        fs.mkdirSync(cacheDir, {recursive: true});
      }

      try {
        const puppeteerExecutablePath = puppeteer.executablePath();
        if (
          puppeteerExecutablePath &&
          fs.existsSync(puppeteerExecutablePath)
        ) {
          executablePath = puppeteerExecutablePath;
          logger.info(`Using Chrome from Puppeteer: ${executablePath}`);
        }
      } catch (e) {
        logger.info(`puppeteer.executablePath() not available, will install Chrome`);
      }

      if (!executablePath) {
        logger.info(`Installing Chrome using @puppeteer/browsers...`);

        try {
          const platform = detectBrowserPlatform();
          if (!platform) {
            throw new Error("Could not detect browser platform");
          }

          const installedBrowsers = await getInstalledBrowsers({
            cacheDir: cacheDir,
          });

          let chromeBrowser = installedBrowsers.find(
            (b: any) => b.browser === Browser.CHROME
          );

          if (!chromeBrowser) {
            logger.info(`Chrome not found, installing...`);

            const buildId = "142.0.7444.162";

            const installResult = await install({
              browser: Browser.CHROME,
              buildId: buildId,
              cacheDir: cacheDir,
              platform: platform,
            });

            chromeBrowser = installResult as any;
            logger.info(`Chrome installed successfully`);
          } else {
            logger.info(`Chrome already installed`);
          }

          if (chromeBrowser) {
            try {
              const buildId = (chromeBrowser as any).buildId || "142.0.7444.162";

              const chromeExecutablePath = computeExecutablePath({
                browser: Browser.CHROME,
                buildId: buildId,
                cacheDir: cacheDir,
                platform: platform,
              });

              if (
                chromeExecutablePath &&
                fs.existsSync(chromeExecutablePath)
              ) {
                executablePath = chromeExecutablePath;
                logger.info(
                  `Using Chrome from @puppeteer/browsers: ${executablePath}`
                );
              }
            } catch (pathError: any) {
              logger.warn(
                `Failed to compute Chrome executable path: ${pathError?.message}`
              );
            }
          }
        } catch (installError: any) {
          logger.warn(`Chrome installation failed: ${installError?.message}`);
        }
      }
    } catch (e: any) {
      logger.warn(`Error setting up Chrome: ${e?.message}`);
    }
  }

  const launchOptions: any = {
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
    ],
  };

  if (executablePath) {
    launchOptions.executablePath = executablePath;
  }

  return await puppeteer.launch(launchOptions);
}

/**
 * 다음 페이지 URL 찾기
 */
function findNextPageUrl(html: string): string | null {
  const $ = cheerio.load(html);
  const nextLink = $("a.tribe-events-c-nav__next").attr("href");
  return nextLink ? toAbsoluteUrl(nextLink) : null;
}

/**
 * 크롤링 실행 로직
 */
export async function runFetchList(
  startPage: number = 1,
  maxPages: number = 3
): Promise<{
  success: boolean;
  message?: string;
  error?: string;
  totalProcessed?: number;
  pagesProcessed?: number;
  lastPage?: number;
}> {
  let browser: any = null;

  try {
    logger.info(`Starting fetchList from page ${startPage}`);

    // Puppeteer 브라우저 실행
    logger.info(`Launching Puppeteer browser...`);
    browser = await setupBrowser();

    let totalProcessed = 0;
    let currentPage = startPage;
    let hasMorePages = true;

    while (hasMorePages && currentPage <= maxPages) {
      try {
        logger.info(`Processing page ${currentPage}`);

        // 리스트 페이지에서 기본 정보 추출
        const {events: eventList, html: pageHtml} = await fetchEventListFromPage(
          browser,
          currentPage
        );

        if (eventList.length === 0) {
          logger.info(`No more events found at page ${currentPage}. Stopping.`);
          hasMorePages = false;
          break;
        }

        // 각 이벤트의 상세 정보 추출 및 저장
        for (const eventBasic of eventList) {
          try {
            if (!eventBasic.detailUrl) continue;

            // 상세 정보 추출
            const eventDetail = await fetchEventDetail(browser, eventBasic.detailUrl);

            // 기본 정보와 상세 정보 병합 (상세 정보 우선)
            const eventData: EventData = {
              eventId: eventBasic.eventId || generateEventId(eventBasic.detailUrl),
              title: eventDetail.title || eventBasic.title || "",
              detailUrl: eventBasic.detailUrl,
              imageUrl: eventDetail.imageUrl || eventBasic.imageUrl,
              startDate:
                eventDetail.startDate ||
                eventBasic.startDate ||
                new Date().toISOString().split("T")[0],
              startTime: eventDetail.startTime || eventBasic.startTime,
              endDate:
                eventDetail.endDate ||
                eventBasic.endDate ||
                new Date().toISOString().split("T")[0],
              endTime: eventDetail.endTime || eventBasic.endTime,
              dateDatetime: eventBasic.dateDatetime,
              priceDisplay: eventDetail.priceDisplay || eventBasic.priceDisplay,
              description: eventDetail.description,
              categories: eventDetail.categories || eventBasic.categories || [],
              tags: eventDetail.tags || [],
              venueName: eventDetail.venueName || eventBasic.venueName,
              venueUrl: eventDetail.venueUrl || eventBasic.venueUrl,
              venueStreetAddress: eventDetail.venueStreetAddress,
              venueLocality: eventDetail.venueLocality || eventBasic.venueLocality,
              venueRegion: eventDetail.venueRegion || eventBasic.venueRegion,
              venuePostalCode: eventDetail.venuePostalCode,
              venueCountry: eventDetail.venueCountry,
              venuePhone: eventDetail.venuePhone,
              venueWebsite: eventDetail.venueWebsite,
              venueGoogleMapUrl: eventDetail.venueGoogleMapUrl,
              organizerName: eventDetail.organizerName || eventBasic.organizerName,
              organizerUrl: eventDetail.organizerUrl || eventBasic.organizerUrl,
              organizerPhone: eventDetail.organizerPhone,
              organizerEmail: eventDetail.organizerEmail,
              isRecurring: eventBasic.isRecurring || false,
              seriesUrl: eventDetail.seriesUrl || eventBasic.seriesUrl,
              eventWebsite: eventDetail.eventWebsite,
              facebookUrl: eventDetail.facebookUrl || eventBasic.facebookUrl,
              instagramUrl: eventDetail.instagramUrl || eventBasic.instagramUrl,
              updatedAt: getFirestoreTimestamp(),
              countView: 0,
            };

            // Firestore에 저장
            await saveEventToFirestore(eventData);
            totalProcessed++;

            // 요청 간 최소 딜레이 (서버 부하 방지)
            await new Promise((resolve) => setTimeout(resolve, 300));
          } catch (error) {
            logger.error(
              `Error processing event ${eventBasic.eventId}:`,
              error
            );
          }
        }

        // 다음 페이지 확인
        const nextPageUrl = findNextPageUrl(pageHtml);

        if (nextPageUrl && currentPage < maxPages) {
          currentPage++;
        } else {
          hasMorePages = false;
        }

        // 페이지 간 최소 딜레이
        await new Promise((resolve) => setTimeout(resolve, 500));
      } catch (error) {
        logger.error(`Error processing page ${currentPage}:`, error);
        hasMorePages = false;
        break;
      }
    }

    return {
      success: true,
      message: `Processed ${totalProcessed} events from pages ${startPage} to ${currentPage - 1}`,
      totalProcessed,
      pagesProcessed: currentPage - startPage,
      lastPage: currentPage - 1,
    };
  } catch (error: any) {
    logger.error("Error in fetchList:", error);
    return {
      success: false,
      error: error instanceof Error ? error.message : "Unknown error",
    };
  } finally {
    if (browser) {
      try {
        await browser.close();
        logger.info(`Browser closed`);
      } catch (e) {
        logger.error(`Error closing browser: ${e}`);
      }
    }
  }
}

/**
 * HTTP 요청으로 호출 가능한 크롤링 함수
 */
export const fetchList = functions.runWith({
  timeoutSeconds: 540,
  memory: "2GB",
  maxInstances: 10,
}).region("europe-central2").https.onRequest(async (req, res) => {
  let responseSent = false;

  const sendResponse = (status: number, data: object) => {
    if (!responseSent) {
      responseSent = true;
      res.status(status).json(data);
    }
  };

  const startPage = req.query.page ? parseInt(req.query.page as string) : 1;
  const maxPages = req.query.maxPages
    ? parseInt(req.query.maxPages as string)
    : 3;

  const result = await runFetchList(startPage, maxPages);

  if (result.success) {
    sendResponse(200, result);
  } else {
    sendResponse(500, result);
  }
});

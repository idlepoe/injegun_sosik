import puppeteer from "puppeteer";
import {
  install,
  Browser,
  detectBrowserPlatform,
  getInstalledBrowsers,
  computeExecutablePath,
} from "@puppeteer/browsers";
import * as logger from "firebase-functions/logger";

/**
 * Puppeteer 브라우저 설정 및 실행
 * (루트 fetchList.ts의 setupBrowser를 기반으로 함)
 */
export async function setupBrowser(): Promise<any> {
  let executablePath: string | undefined;

  if (process.env.PUPPETEER_EXECUTABLE_PATH) {
    executablePath = process.env.PUPPETEER_EXECUTABLE_PATH;
    logger.info(
      `Using Puppeteer executable from environment: ${executablePath}`,
    );
  } else {
    try {
      // eslint-disable-next-line @typescript-eslint/no-var-requires
      const fs = require("fs");
      // eslint-disable-next-line @typescript-eslint/no-var-requires
      const path = require("path");

      const cacheDir = path.join(process.cwd(), ".cache", "puppeteer");
      if (!fs.existsSync(cacheDir)) {
        fs.mkdirSync(cacheDir, { recursive: true });
      }

      logger.info("Installing browser using @puppeteer/browsers...");
      const platform = detectBrowserPlatform();
      if (!platform) throw new Error("Could not detect browser platform.");

      let installedBrowser = (await getInstalledBrowsers({ cacheDir })).find(
        (b: any) => b.browser === Browser.CHROME,
      );

      if (!installedBrowser) {
        logger.info("Chrome not found, installing...");
        installedBrowser = await install({
          browser: Browser.CHROME,
          buildId: "126.0.6478.126", // 최근 안정 버전
          cacheDir,
          platform,
        });
        logger.info("Chrome installed successfully.");
      } else {
        logger.info("Chrome is already installed.");
      }

      executablePath = computeExecutablePath({
        browser: Browser.CHROME,
        buildId: installedBrowser.buildId,
        cacheDir,
        platform,
      });
      logger.info(`Using browser from: ${executablePath}`);
    } catch (error) {
      logger.error(
        "Error setting up browser with @puppeteer/browsers:",
        error,
      );
      logger.info("Falling back to puppeteer's default browser.");
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
      "--single-process",
      "--disable-gpu",
    ],
  };

  if (executablePath) {
    launchOptions.executablePath = executablePath;
  }

  return await puppeteer.launch(launchOptions);
}


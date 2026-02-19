import { getFirestore } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";
import type { FetchWeatherOptions, WeatherData } from "../types/weather.js";

// API 응답 타입 (중첩 구조)
interface ApiWeatherResponse {
  coord: { lon: number; lat: number };
  weather: Array<{
    id: number;
    main: string;
    description: string;
    icon: string;
  }>;
  base: string;
  main: {
    temp: number;
    feels_like: number;
    temp_min: number;
    temp_max: number;
    pressure: number;
    humidity: number;
    sea_level?: number;
    grnd_level?: number;
  };
  visibility: number;
  wind: {
    speed: number;
    deg: number;
    gust?: number;
  };
  clouds: { all: number };
  dt: number;
  sys: {
    country: string;
    sunrise: number;
    sunset: number;
  };
  timezone: number;
  id: number;
  name: string;
  cod: number;
}

const API_KEY = "24ba0d721e0b2c23baad5221d14b1fd2";
const LAT = 38.06697222;
const LON = 128.1726972;
const BASE_URL = "https://api.openweathermap.org/data/2.5/weather";

/**
 * OpenWeatherMap Current Weather Data API를 사용하여 현재 날씨 데이터를 가져와서 Firestore의 weathers 컬렉션에 저장
 * 날짜 기준으로 중복된 경우 기존 데이터를 업데이트
 * @param options - 파라미터 없음
 * @returns 저장된 날씨 데이터 정보
 */
export async function fetchWeather(
  options: FetchWeatherOptions = {}
): Promise<{ success: boolean; timestamp: string; saved: boolean; updated: boolean; data?: WeatherData }> {
  try {
    const now = new Date();
    const timestamp = now.toISOString();
    const dateStr = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-${String(now.getDate()).padStart(2, "0")}`;

    logger.info("[fetchWeather] Fetching current weather data", { lat: LAT, lon: LON });

    // API 호출 URL 구성
    const url = `${BASE_URL}?lat=${LAT}&lon=${LON}&units=metric&lang=kr&appid=${API_KEY}`;
    logger.info("[fetchWeather] API URL", { url: url.replace(API_KEY, "***") });

    const response = await fetch(url);

    if (!response.ok) {
      const errorText = await response.text();
      logger.error("[fetchWeather] API request failed", {
        status: response.status,
        statusText: response.statusText,
        error: errorText,
      });
      throw new Error(`OpenWeatherMap API error: ${response.status} ${response.statusText}`);
    }

    const apiResponse: ApiWeatherResponse = await response.json();
    
    // cod 필드 확인 (200이면 성공)
    if (apiResponse.cod !== 200) {
      logger.error("[fetchWeather] API returned error code", { cod: apiResponse.cod });
      throw new Error(`OpenWeatherMap API error: cod ${apiResponse.cod}`);
    }

    // 첫 번째 weather 항목 가져오기
    const firstWeather = apiResponse.weather[0];
    if (!firstWeather) {
      throw new Error("Weather data is missing weather array");
    }

    logger.info("[fetchWeather] Weather data received", {
      name: apiResponse.name,
      temp: apiResponse.main.temp,
      weather: firstWeather.main,
      description: firstWeather.description,
    });

    // 중첩 구조를 평면화하여 WeatherData로 변환
    const weatherData: WeatherData = {
      // Coord 필드
      lon: apiResponse.coord.lon,
      lat: apiResponse.coord.lat,
      
      // WeatherCondition 필드 (첫 번째 항목만)
      weatherId: firstWeather.id,
      weatherMain: firstWeather.main,
      weatherDescription: firstWeather.description,
      weatherIcon: firstWeather.icon,
      
      // Main 필드
      temp: apiResponse.main.temp,
      feelsLike: apiResponse.main.feels_like,
      tempMin: apiResponse.main.temp_min,
      tempMax: apiResponse.main.temp_max,
      pressure: apiResponse.main.pressure,
      humidity: apiResponse.main.humidity,
      seaLevel: apiResponse.main.sea_level,
      grndLevel: apiResponse.main.grnd_level,
      
      // Wind 필드
      windSpeed: apiResponse.wind.speed,
      windDeg: apiResponse.wind.deg,
      windGust: apiResponse.wind.gust,
      
      // Clouds 필드
      cloudsAll: apiResponse.clouds.all,
      
      // Sys 필드
      country: apiResponse.sys.country,
      sunrise: apiResponse.sys.sunrise,
      sunset: apiResponse.sys.sunset,
      
      // 기타 필드
      base: apiResponse.base,
      visibility: apiResponse.visibility,
      dt: apiResponse.dt,
      timezone: apiResponse.timezone,
      id: apiResponse.id,
      name: apiResponse.name,
      cod: apiResponse.cod,
    };

    // Firestore에 저장 (날짜를 문서 ID로 사용)
    const db = getFirestore();
    const weatherRef = db.collection("weathers").doc(dateStr);

    // 기존 문서 확인
    const existingDoc = await weatherRef.get();
    const exists = existingDoc.exists;

    // 날씨 데이터 저장 (timestamp 포함)
    // merge: true 옵션으로 중복된 경우 기존 데이터를 업데이트
    const docData = {
      ...weatherData,
      fetchedAt: new Date(),
      fetchedTimestamp: timestamp,
    };

    await weatherRef.set(docData, { merge: true });
    
    const action = exists ? "updated" : "created";
    logger.info(`[fetchWeather] Weather data ${action} in Firestore`, {
      date: dateStr,
      existed: exists,
      name: weatherData.name,
      temp: weatherData.temp,
    });

    return {
      success: true,
      timestamp: timestamp,
      saved: true, // 항상 저장/업데이트됨
      updated: exists, // 업데이트된 경우 true, 새로 생성된 경우 false
      data: weatherData,
    };
  } catch (err) {
    logger.error("[fetchWeather] Failed to fetch weather", err);
    throw err;
  }
}

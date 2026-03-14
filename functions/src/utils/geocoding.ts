import * as crypto from "node:crypto";
import { getFirestore } from "firebase-admin/firestore";
import * as logger from "firebase-functions/logger";

export const GOOGLE_GEOCODING_API_KEY =
  process.env.GOOGLE_GEOCODING_API_KEY || "";

const GEOCODE_CACHE_COLLECTION = "geocodeCache";

/** 지오코딩 결과 (place_id는 API/캐시에 있을 때만) */
export interface GeocodeResult {
  lat: number;
  lng: number;
  placeId?: string;
}

/** 검색어(주소) → GeocodeResult 메모리 캐시. 동일 주소 반복 요청 시 API/ Firestore 조회 없이 반환 */
const geocodeCache = new Map<string, GeocodeResult>();

/** 좌표(lat,lng) → 주소 캐시. 동일 좌표 반복 요청 시 API 호출 없이 반환 */
const reverseGeocodeCache = new Map<string, string>();

function cacheKey(address: string): string {
  return address.trim();
}

/** Firestore geocodeCache 문서 ID용: 주소 문자열의 해시 (동일 주소면 동일 ID) */
function geocodeDocId(address: string): string {
  return crypto.createHash("sha256").update(cacheKey(address)).digest("hex").slice(0, 32);
}

function reverseCacheKey(lat: number, lng: number): string {
  return `${lat.toFixed(6)},${lng.toFixed(6)}`;
}

/**
 * 주소를 기반으로 위도/경도·place_id 조회 (Google Geocoding API 사용).
 * 한 번 조회된 주소는 캐시되어 재요청 시 API를 호출하지 않음.
 */
export async function geocodeAddress(address: string): Promise<GeocodeResult | null> {
  const key = cacheKey(address);
  if (!key) {
    return null;
  }

  const cached = geocodeCache.get(key);
  if (cached) {
    logger.info(`Geocode 메모리 캐시 hit: address="${address}"`);
    return cached;
  }

  // Firestore geocodeCache 컬렉션 조회 (추후 재실행 시 API 호출 없이 활용)
  try {
    const db = getFirestore();
    const docRef = db.collection(GEOCODE_CACHE_COLLECTION).doc(geocodeDocId(key));
    const docSnap = await docRef.get();
    if (docSnap.exists) {
      const data = docSnap.data();
      const lat = data?.lat;
      const lng = data?.lng;
      const placeId = typeof data?.placeId === "string" ? data.placeId : undefined;
      if (typeof lat === "number" && typeof lng === "number" && Number.isFinite(lat) && Number.isFinite(lng)) {
        const result: GeocodeResult = { lat, lng, ...(placeId && { placeId }) };
        geocodeCache.set(key, result);
        logger.info(`Geocode Firestore 캐시 hit: address="${address}" -> lat=${lat}, lng=${lng}`);
        return result;
      }
    }
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : String(e);
    logger.warn(`Geocode Firestore 캐시 조회 실패, API 호출 진행: address="${address}"`, msg);
  }

  if (!GOOGLE_GEOCODING_API_KEY) {
    logger.warn(
      `Geocoding skipped because GOOGLE_GEOCODING_API_KEY is not set. address="${address}"`,
    );
    return null;
  }

  logger.info(`Geocode API 요청: address="${address}"`);
  const url = `https://maps.googleapis.com/maps/api/geocode/json?address=${encodeURIComponent(
    address,
  )}&language=ko&region=KR&key=${GOOGLE_GEOCODING_API_KEY}`;

  try {
    const res = await fetch(url);
    const data = (await res.json()) as {
      status: string;
      results?: Array<{
        place_id?: string;
        geometry?: { location?: { lat: number; lng: number } };
      }>;
    };

    if (data.status === "OK" && data.results?.[0]?.geometry?.location) {
      const first = data.results[0];
      const loc = first.geometry!.location!;
      const placeId = typeof first.place_id === "string" ? first.place_id : undefined;
      const result: GeocodeResult = { lat: loc.lat, lng: loc.lng, ...(placeId && { placeId }) };
      geocodeCache.set(key, result);
      logger.info(
        `Geocode 성공: address="${address}" -> lat=${loc.lat}, lng=${loc.lng}${placeId ? `, place_id=${placeId}` : ""}`,
      );
      // Firestore geocodeCache 컬렉션에 저장 (추후 동일 주소 조회 시 활용)
      try {
        const db = getFirestore();
        await db.collection(GEOCODE_CACHE_COLLECTION).doc(geocodeDocId(key)).set({
          address: key,
          lat: loc.lat,
          lng: loc.lng,
          ...(placeId && { placeId }),
        });
        logger.info(`Geocode Firestore 캐시 저장: address="${address}"`);
      } catch (writeErr: unknown) {
        const msg = writeErr instanceof Error ? writeErr.message : String(writeErr);
        logger.warn(`Geocode Firestore 캐시 저장 실패 (무시): address="${address}"`, msg);
      }
      return result;
    }

    if (data.status !== "OK") {
      logger.warn(`Geocoding failed for "${address}": ${data.status}`);
    }

    return null;
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : String(e);
    logger.warn(`Geocoding error for "${address}":`, msg);
    return null;
  }
}

/**
 * 위도/경도를 기반으로 주소(Formatted address) 조회 (Google Geocoding API 사용).
 * 한 번 조회된 좌표는 캐시되어 재요청 시 API를 호출하지 않음.
 */
export async function reverseGeocodeLatLng(
  lat: number,
  lng: number,
): Promise<string | null> {
  if (!Number.isFinite(lat) || !Number.isFinite(lng)) {
    return null;
  }

  if (!GOOGLE_GEOCODING_API_KEY) {
    logger.warn(
      `Reverse geocoding skipped because GOOGLE_GEOCODING_API_KEY is not set. lat=${lat}, lng=${lng}`,
    );
    return null;
  }

  const key = reverseCacheKey(lat, lng);
  const cached = reverseGeocodeCache.get(key);
  if (cached) {
    logger.info(`Reverse geocode 캐시 hit: lat=${lat}, lng=${lng}`);
    return cached;
  }

  logger.info(`Reverse geocode 요청: lat=${lat}, lng=${lng}`);
  const url = `https://maps.googleapis.com/maps/api/geocode/json?latlng=${encodeURIComponent(
    `${lat},${lng}`,
  )}&language=ko&region=KR&key=${GOOGLE_GEOCODING_API_KEY}`;

  try {
    const res = await fetch(url);
    const data = (await res.json()) as {
      status: string;
      results?: Array<{ formatted_address?: string }>;
    };

    if (data.status === "OK" && data.results && data.results[0]?.formatted_address) {
      const formatted = data.results[0].formatted_address;
      reverseGeocodeCache.set(key, formatted);
      logger.info(
        `Reverse geocode 성공: lat=${lat}, lng=${lng} -> address="${formatted}"`,
      );
      return formatted;
    }

    if (data.status !== "OK") {
      logger.warn(
        `Reverse geocoding failed for lat=${lat}, lng=${lng}: ${data.status}`,
      );
    }

    return null;
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : String(e);
    logger.warn(`Reverse geocoding error for lat=${lat}, lng=${lng}:`, msg);
    return null;
  }
}

const GEOHASH_BASE32 = "0123456789bcdefghjkmnpqrstuvwxyz";

export function encodeGeohash(latitude: number, longitude: number, precision = 9): string {
  let latMin = -90;
  let latMax = 90;
  let lonMin = -180;
  let lonMax = 180;
  let hash = "";
  let bit = 0;
  let ch = 0;
  let evenBit = true;

  while (hash.length < precision) {
    if (evenBit) {
      const lonMid = (lonMin + lonMax) / 2;
      if (longitude >= lonMid) {
        ch = (ch << 1) + 1;
        lonMin = lonMid;
      } else {
        ch = ch << 1;
        lonMax = lonMid;
      }
    } else {
      const latMid = (latMin + latMax) / 2;
      if (latitude >= latMid) {
        ch = (ch << 1) + 1;
        latMin = latMid;
      } else {
        ch = ch << 1;
        latMax = latMid;
      }
    }

    evenBit = !evenBit;

    if (++bit === 5) {
      hash += GEOHASH_BASE32.charAt(ch);
      bit = 0;
      ch = 0;
    }
  }

  return hash;
}


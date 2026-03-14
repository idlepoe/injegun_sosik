import * as logger from "firebase-functions/logger";
import { GOOGLE_GEOCODING_API_KEY } from "./geocoding.js";

const SEARCH_TEXT_URL = "https://places.googleapis.com/v1/places:searchText";

/**
 * 상호명(및 주소)으로 Text Search 후, photo가 있는 첫 번째 장소의 첫 사진으로 즉시 사용 가능한 이미지 URL(photoUri) 조회.
 * 400x400 크기로 요청. 한국어/한국 지역 기준.
 * @see 군장병우대업소장소크롤링.md
 */
export async function fetchPlacePhotoUrlByQuery(
  placeName: string,
  address?: string
): Promise<string | null> {
  const name = placeName?.trim();
  if (!name) return null;
  if (!GOOGLE_GEOCODING_API_KEY) {
    logger.warn("[fetchPlacePhotoUrlByQuery] GOOGLE_GEOCODING_API_KEY not set");
    return null;
  }

  const textQuery = address?.trim() ? `${name} ${address.trim()}` : name;

  try {
    const searchRes = await fetch(SEARCH_TEXT_URL, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-Goog-Api-Key": GOOGLE_GEOCODING_API_KEY,
        "X-Goog-FieldMask": "places.id,places.photos",
      },
      body: JSON.stringify({
        textQuery,
        languageCode: "ko",
        regionCode: "KR",
      }),
    });

    if (!searchRes.ok) {
      logger.warn("[fetchPlacePhotoUrlByQuery] searchText failed", {
        placeName: name,
        status: searchRes.status,
      });
      return null;
    }

    const searchData = (await searchRes.json()) as {
      places?: Array<{ id?: string; photos?: Array<{ name?: string }> }>;
    };
    const places = searchData?.places ?? [];
    let firstPhotoName: string | null = null;
    for (const place of places) {
      const photoName = place?.photos?.[0]?.name;
      if (typeof photoName === "string" && photoName) {
        firstPhotoName = photoName;
        break;
      }
    }
    if (!firstPhotoName) {
      return null;
    }

    const mediaUrl = `https://places.googleapis.com/v1/${firstPhotoName}/media?maxWidthPx=400&maxHeightPx=400&skipHttpRedirect=true&key=${encodeURIComponent(GOOGLE_GEOCODING_API_KEY)}`;
    const mediaRes = await fetch(mediaUrl);

    if (!mediaRes.ok) {
      logger.warn("[fetchPlacePhotoUrlByQuery] getMedia failed", {
        placeName: name,
        status: mediaRes.status,
      });
      return null;
    }

    const mediaData = (await mediaRes.json()) as { photoUri?: string };
    let photoUri = mediaData?.photoUri;
    if (typeof photoUri === "string" && photoUri) {
      if (photoUri.startsWith("//")) {
        photoUri = "https:" + photoUri;
      }
      return photoUri;
    }
    return null;
  } catch (e: unknown) {
    const msg = e instanceof Error ? e.message : String(e);
    logger.warn("[fetchPlacePhotoUrlByQuery] error", { placeName: name, error: msg });
    return null;
  }
}

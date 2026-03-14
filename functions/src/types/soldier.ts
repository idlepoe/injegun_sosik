/**
 * 군장병 우대업소 한 건 타입 (Firestore soldiers 컬렉션)
 * @see 군장병우대업소.md
 */

export type SoldierCategory = "restaurant" | "lodgingIndustry" | "hair" | "pcroom";

export interface Soldier {
  /** 행정동(구분) */
  district: string;
  /** 업종 코드 (URL 기준) */
  category: SoldierCategory;
  /** 업소명 */
  name: string;
  /** 주소 */
  address: string;
  /** 전화번호 (빈 문자열 가능) */
  phone: string;
  /** 위도 (geocoding 성공 시만) */
  lat?: number;
  /** 경도 (geocoding 성공 시만) */
  lng?: number;
  /** geohash (encodeGeohash 결과, geocoding 성공 시만) */
  geohash?: string;
  /** Google Geocoding API place_id (geocoding 성공 시만) */
  placeId?: string;
}

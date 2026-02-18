/**
 * fetchList.ts에서 공용으로 쓰는 유틸리티 모음 (빌드 통과용 최소 구현)
 */

export const BASE_URL = process.env.FETCHLIST_BASE_URL ?? "https://example.com";

export function cleanText(input: string): string {
  return String(input ?? "")
    .replace(/\s+/g, " ")
    .trim();
}

export function toAbsoluteUrl(url: string): string {
  const raw = String(url ?? "").trim();
  if (!raw) return raw;
  try {
    // 이미 절대 URL이면 그대로
    return new URL(raw).toString();
  } catch {
    // 상대 URL이면 BASE_URL 기준으로 결합
    return new URL(raw, BASE_URL).toString();
  }
}

export function generateEventId(url: string): string {
  const u = toAbsoluteUrl(url);
  // Firestore doc id로도 사용 가능한 형태로 간단히 정규화
  return Buffer.from(u).toString("base64url");
}

/**
 * ISO/다양한 날짜 문자열에서 YYYY-MM-DD 추출
 */
export function parseDate(value: string): string {
  const v = String(value ?? "").trim();
  // YYYY-MM-DD
  const m1 = v.match(/(\d{4})-(\d{2})-(\d{2})/);
  if (m1) return `${m1[1]}-${m1[2]}-${m1[3]}`;
  // YYYY/MM/DD
  const m2 = v.match(/(\d{4})\/(\d{1,2})\/(\d{1,2})/);
  if (m2) return `${m2[1]}-${m2[2].padStart(2, "0")}-${m2[3].padStart(2, "0")}`;
  // Date 파싱 fallback
  const d = new Date(v);
  if (!Number.isNaN(d.getTime())) return d.toISOString().split("T")[0];
  // 마지막 fallback: 오늘 날짜
  return new Date().toISOString().split("T")[0];
}

/**
 * ISO/다양한 날짜 문자열에서 HH:MM 추출
 */
export function parseTime(value: string): string | undefined {
  const v = String(value ?? "").trim();
  const m = v.match(/(\d{1,2}):(\d{2})/);
  if (!m) return undefined;
  return `${m[1].padStart(2, "0")}:${m[2]}`;
}


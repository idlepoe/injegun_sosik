/**
 * Firestore 필드 값 제한: 1,048,576 bytes (1 MiB)
 * 여유를 두고 1,000,000 bytes 이하로 자름
 */
export const FIRESTORE_MAX_FIELD_BYTES = 1_000_000;

/**
 * UTF-8 바이트 길이 기준으로 문자열을 잘라 반환.
 * 중간에 잘리지 않도록 문자 단위로 자름.
 */
export function truncateToMaxBytes(str: string, maxBytes: number = FIRESTORE_MAX_FIELD_BYTES): string {
  if (typeof str !== "string" || str.length === 0) return str;
  const buf = Buffer.from(str, "utf8");
  if (buf.length <= maxBytes) return str;
  let end = str.length;
  while (end > 0 && Buffer.from(str.slice(0, end), "utf8").length > maxBytes) {
    end -= 1;
  }
  return str.slice(0, end);
}

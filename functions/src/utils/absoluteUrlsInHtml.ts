/**
 * HTML 문자열 내 상대 경로 src/href를 baseUrl을 붙인 절대 URL로 변환.
 * 클라이언트에서 이미지/링크가 정상 로드되도록 함.
 */
export function absoluteUrlsInHtml(html: string, baseUrl: string): string {
  if (!html || !baseUrl) return html;
  const base = baseUrl.replace(/\/$/, "");
  return html
    .replace(/\ssrc="\//g, ` src="${base}/`)
    .replace(/\shref="\//g, ` href="${base}/`)
    .replace(/\ssrc='\//g, ` src='${base}/`)
    .replace(/\shref='\//g, ` href='${base}/`);
}

/**
 * 대시보드 슬라이더 한 건 타입 (인제군 포털 메인 배너 슬라이더)
 * @see 크롤링_대시보드_항목.md
 */

export interface DashboardSliderItem {
  /** 이미지 절대 URL */
  imageUrl: string;
  /** 이미지 alt 텍스트 */
  imageAlt: string;
  /** 제목 (div.hidden_txt, 없으면 imageAlt) */
  title: string;
  /** 링크 URL (아이템이 <a>일 때만, 빈/http:// 는 null) */
  linkUrl: string | null;
  /** linkUrl 쿼리 articleSeq (inje.go.kr 포함 시) */
  articleSeq: string | null;
  /** data-seq 속성 */
  dataSeq: string | null;
  /** slick-cloned 제외 후 순서 (0부터) */
  order: number;
}

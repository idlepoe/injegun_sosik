/**
 * 게시글 공통 타입 (articles 컬렉션)
 * weekschedule과 notice를 통합한 Article 타입
 */

export interface Attachment {
  /** 첨부 다운로드 URL (상대 경로 또는 절대 경로) */
  attachmentUrl: string;
  /** 첨부 파일명 */
  attachmentName: string;
  /** 첨부 fileSeq */
  fileSeq?: string;
}

export interface Article {
  /** 게시글 타입 */
  type: "weekschedule" | "notice";
  /** 상세 페이지 URL */
  url?: string;
  /** 글 번호 (상세 진입 키) */
  articleSeq: string;
  /** 게시판 코드 */
  boardCode?: string;
  /** 제목 */
  title: string;
  /** 작성자 */
  author: string;
  /** 등록일 (YYYY-MM-DD) */
  registeredAt: string;
  /** 본문 (HTML 포함) */
  content: string;
  /** 첨부파일 리스트 */
  attachments: Attachment[];
}

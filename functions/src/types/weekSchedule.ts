/**
 * 주간일정 게시글 (articles 컬렉션)
 * @see 크롤링_주간일정_항목.md
 */
export interface WeekSchedule {
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
  /** 본문 (HTML 제거 후 텍스트) */
  content: string;
  /** 첨부 다운로드 URL (상대 경로) */
  attachmentUrl?: string;
  /** 첨부 파일명 */
  attachmentName?: string;
  /** 첨부 fileSeq */
  fileSeq?: string;
}

/**
 * 주간일정 엑셀 행 (weekschedules 컬렉션)
 * 엑셀 4행부터: A=일자, B=시간, C=행사내용, D=장소, E=소관
 * 일자는 yyyy-mm-dd 형태로 저장 (예: 2026-02-16)
 */
export interface WeekScheduleRow {
  /** 일자 (A열, yyyy-mm-dd) */
  date: string;
  /** 시간 (B열) */
  time: string;
  /** 행사내용 (C열) */
  eventContent: string;
  /** 장소 (D열) */
  place: string;
  /** 소관 (E열) */
  department: string;
  /** 출처 게시글 articleSeq */
  articleSeq: string;
}

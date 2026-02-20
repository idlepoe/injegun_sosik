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
  /** 위도 (Google Geocoding 결과, '인제' 포함 시만 저장) */
  lat?: number;
  /** 경도 (Google Geocoding 결과, '인제' 포함 시만 저장) */
  lng?: number;
}

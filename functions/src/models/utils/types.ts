import type { Timestamp } from "firebase-admin/firestore";

/**
 * fetchList.ts에서 사용하는 이벤트 데이터 타입
 * (Firestore `events` 컬렉션 저장용)
 */
export interface EventData {
  eventId: string;
  title: string;
  detailUrl: string;

  imageUrl?: string;

  startDate: string;
  startTime?: string;
  endDate: string;
  endTime?: string;
  /** 원문(페이지)에서 파싱된 날짜/시간 문자열 보관용 */
  dateDatetime?: string;

  priceDisplay?: string;
  /** HTML 포함 가능 */
  description?: string;

  categories?: string[];
  tags?: string[];

  venueName?: string;
  venueUrl?: string;
  venueStreetAddress?: string;
  venueLocality?: string;
  venueRegion?: string;
  venuePostalCode?: string;
  venueCountry?: string;
  venuePhone?: string;
  venueWebsite?: string;
  venueGoogleMapUrl?: string;

  organizerName?: string;
  organizerUrl?: string;
  organizerPhone?: string;
  organizerEmail?: string;

  isRecurring?: boolean;
  seriesUrl?: string;

  eventWebsite?: string;
  facebookUrl?: string;
  instagramUrl?: string;

  updatedAt: Timestamp;
  countView: number;
}


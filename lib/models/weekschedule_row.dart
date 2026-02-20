import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'weekschedule_row.freezed.dart';

/// weekschedules 컬렉션 1건 (일자, 시간, 행사내용, 장소, 소관, articleSeq)
@freezed
abstract class WeekScheduleRow with _$WeekScheduleRow {
  const factory WeekScheduleRow({
    required String date,
    required String time,
    required String eventContent,
    required String place,
    required String department,
    String? articleSeq,
    /// 위도 (Google Geocoding 결과, '인제' 포함 시만 저장)
    double? lat,
    /// 경도 (Google Geocoding 결과, '인제' 포함 시만 저장)
    double? lng,
  }) = _WeekScheduleRow;

  factory WeekScheduleRow.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return WeekScheduleRow(
      date: (data['date'] as String?) ?? '',
      time: (data['time'] as String?) ?? '',
      eventContent: (data['eventContent'] as String?) ?? '',
      place: (data['place'] as String?) ?? '',
      department: (data['department'] as String?) ?? '',
      articleSeq: data['articleSeq'] as String?,
      lat: data['lat'] != null ? (data['lat'] as num).toDouble() : null,
      lng: data['lng'] != null ? (data['lng'] as num).toDouble() : null,
    );
  }
}

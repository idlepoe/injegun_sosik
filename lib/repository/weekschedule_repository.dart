import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/weekschedule_row.dart';

/// Firestore weekschedules 컬렉션 GET 전용
class WeekscheduleRepository {
  WeekscheduleRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// pageSize개 조회. startAfter 있으면 그 다음부터.
  Future<List<WeekScheduleRow>> getPage({
    int pageSize = 20,
    DocumentSnapshot? startAfter,
  }) async {
    var query = _firestore
        .collection('weekschedules')
        .orderBy('date', descending: true)
        .limit(pageSize);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    final snapshot = await query.get();
    return snapshot.docs.map(WeekScheduleRow.fromFirestore).toList();
  }

  /// 이번 주 등 특정 날짜 구간의 행사만 조회. start, end는 "YYYY-MM-DD". 날짜·시간 오름차순(asc) 반환.
  /// getOptions: 캐시 우선 등 소스 지정 시 사용 (미지정 시 서버·캐시 기본)
  Future<List<WeekScheduleRow>> getRowsInDateRange(
    String start,
    String end, {
    GetOptions? getOptions,
  }) async {
    final snapshot = await _firestore
        .collection('weekschedules')
        .orderBy('date', descending: false)
        .startAt([start]).endAt([end])
        .limit(100)
        .get(getOptions ?? const GetOptions());
    final list = snapshot.docs.map(WeekScheduleRow.fromFirestore).toList();
    list.sort((a, b) {
      final dateCompare = a.date.compareTo(b.date);
      if (dateCompare != 0) return dateCompare;
      return a.time.compareTo(b.time);
    });
    return list;
  }
}

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
}

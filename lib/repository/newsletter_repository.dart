import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/newsletter.dart';

/// Firestore newsletters 컬렉션 GET 전용
class NewsletterRepository {
  NewsletterRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// pageSize개 조회. startAfter 있으면 그 다음부터.
  /// getOptions: 캐시 우선 등 소스 지정 시 사용 (미지정 시 서버·캐시 기본)
  Future<List<Newsletter>> getPage({
    int pageSize = 20,
    DocumentSnapshot? startAfter,
    GetOptions? getOptions,
  }) async {
    var query = _firestore
        .collection('newsletters')
        .orderBy(FieldPath.documentId, descending: true)
        .limit(pageSize);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    final snapshot = await query.get(getOptions ?? const GetOptions());
    return snapshot.docs.map(Newsletter.fromFirestore).toList();
  }
}

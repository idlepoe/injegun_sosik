import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/article.dart';

/// Firestore articles 컬렉션 중 type=='notice' GET 전용 (페이징)
class NoticeRepository {
  NoticeRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// articleSeq(문서 ID)로 단건 조회. 없으면 null.
  Future<Article?> getByArticleSeq(String articleSeq) async {
    final doc = await _firestore.collection('articles').doc(articleSeq).get();
    if (!doc.exists || doc.data() == null) return null;
    return Article.fromFirestore(doc);
  }

  /// pageSize개 조회. startAfter 있으면 그 다음부터.
  /// 정렬: registeredAt 내림차순 (최신순)
  Future<NoticePageResult> getPage({
    int pageSize = 20,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    var query = _firestore
        .collection('articles')
        .where('type', isEqualTo: 'notice')
        .orderBy('registeredAt', descending: true)
        .limit(pageSize);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    final snapshot = await query.get();
    final docs = snapshot.docs;
    final items = docs.map((doc) => Article.fromFirestore(doc)).toList();
    final lastDoc = docs.isEmpty ? null : docs.last;
    return NoticePageResult(items, lastDoc);
  }
}

/// 한 페이지 조회 결과 (리스트 + 커서)
class NoticePageResult {
  NoticePageResult(this.items, this.lastDoc);
  final List<Article> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDoc;
}

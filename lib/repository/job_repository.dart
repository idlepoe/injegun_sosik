import 'package:cloud_firestore/cloud_firestore.dart';

import 'article_repository.dart';
import '../models/article.dart';

/// Firestore articles 컬렉션 중 type=='job' GET 전용 (페이징)
class JobRepository implements ArticleRepository {
  JobRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  @override
  Future<Article?> getByArticleSeq(String articleSeq) async {
    final doc = await _firestore.collection('articles').doc(articleSeq).get();
    if (!doc.exists || doc.data() == null) return null;
    return Article.fromFirestore(doc);
  }

  /// pageSize개 조회. startAfter 있으면 그 다음부터.
  /// 정렬: registeredAt 내림차순 (최신순)
  Future<JobPageResult> getPage({
    int pageSize = 20,
    DocumentSnapshot<Map<String, dynamic>>? startAfter,
  }) async {
    var query = _firestore
        .collection('articles')
        .where('type', isEqualTo: 'job')
        .orderBy('registeredAt', descending: true)
        .limit(pageSize);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    final snapshot = await query.get();
    final docs = snapshot.docs;
    final items = docs.map((doc) => Article.fromFirestore(doc)).toList();
    final lastDoc = docs.isEmpty ? null : docs.last;
    return JobPageResult(items, lastDoc);
  }
}

/// 한 페이지 조회 결과 (리스트 + 커서)
class JobPageResult {
  JobPageResult(this.items, this.lastDoc);
  final List<Article> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDoc;
}

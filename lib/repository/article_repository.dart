import '../models/article.dart';

/// articles 컬렉션 단건 조회용 공통 타입 (상세 화면 진입용)
abstract class ArticleRepository {
  /// articleSeq(문서 ID)로 단건 조회. 없으면 null.
  Future<Article?> getByArticleSeq(String articleSeq);
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'article.freezed.dart';

/// 게시글 공통 타입 (articles 컬렉션)
/// weekschedule과 notice를 통합한 Article 타입

/// 첨부파일 정보
@freezed
abstract class Attachment with _$Attachment {
  const factory Attachment({
    /// 첨부 다운로드 URL (상대 경로 또는 절대 경로)
    required String attachmentUrl,
    /// 첨부 파일명
    required String attachmentName,
    /// 첨부 fileSeq
    String? fileSeq,
  }) = _Attachment;

  factory Attachment.fromFirestore(Map<String, dynamic> data) {
    return Attachment(
      attachmentUrl: (data['attachmentUrl'] as String?) ?? '',
      attachmentName: (data['attachmentName'] as String?) ?? '',
      fileSeq: data['fileSeq'] as String?,
    );
  }
}

/// 게시글 (articles 컬렉션)
@freezed
abstract class Article with _$Article {
  const factory Article({
    /// 게시글 타입 ("weekschedule" | "notice")
    required String type,
    /// 상세 페이지 URL
    String? url,
    /// 글 번호 (상세 진입 키)
    required String articleSeq,
    /// 게시판 코드
    String? boardCode,
    /// 제목
    required String title,
    /// 작성자
    required String author,
    /// 등록일 (YYYY-MM-DD)
    required String registeredAt,
    /// 본문 (HTML 포함)
    required String content,
    /// 첨부파일 리스트
    @Default([]) List<Attachment> attachments,
  }) = _Article;

  factory Article.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final attachmentsData = data['attachments'] as List<dynamic>? ?? [];
    final attachments = attachmentsData
        .map((item) => Attachment.fromFirestore(item as Map<String, dynamic>))
        .toList();

    return Article(
      type: (data['type'] as String?) ?? '',
      url: data['url'] as String?,
      articleSeq: (data['articleSeq'] as String?) ?? doc.id,
      boardCode: data['boardCode'] as String?,
      title: (data['title'] as String?) ?? '',
      author: (data['author'] as String?) ?? '',
      registeredAt: (data['registeredAt'] as String?) ?? '',
      content: (data['content'] as String?) ?? '',
      attachments: attachments,
    );
  }

  /// FCM payload / SharedPreferences 등 Map에서 복원. attachments는 전달되지 않을 수 있어 빈 리스트로 처리.
  factory Article.fromMap(Map<String, dynamic> data) {
    return Article(
      type: (data['type'] as String?) ?? '',
      url: data['url'] as String?,
      articleSeq: (data['articleSeq'] as String?) ?? '',
      boardCode: data['boardCode'] as String?,
      title: (data['title'] as String?) ?? '',
      author: (data['author'] as String?) ?? '',
      registeredAt: (data['registeredAt'] as String?) ?? '',
      content: (data['content'] as String?) ?? '',
      attachments: const [], // 푸시 등에서는 전달되지 않음
    );
  }
}

/// Article을 Map으로 직렬화 (SharedPreferences 등 저장용).
extension ArticleMapExt on Article {
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      if (url != null) 'url': url,
      'articleSeq': articleSeq,
      if (boardCode != null) 'boardCode': boardCode,
      'title': title,
      'author': author,
      'registeredAt': registeredAt,
      'content': content,
      'attachments': <Map<String, dynamic>>[], // 푸시 저장 시 첨부 미전달
    };
  }
}

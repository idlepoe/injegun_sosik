import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'newsletter.freezed.dart';

/// newsletters 컬렉션 1건
@freezed
abstract class Newsletter with _$Newsletter {
  const factory Newsletter({
    required String articleSeq,
    required String title,
    String? thumbnailUrl,
    String? pdfStorageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _Newsletter;

  factory Newsletter.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final createdAt = data['createdAt'] as Timestamp?;
    final updatedAt = data['updatedAt'] as Timestamp?;
    return Newsletter(
      articleSeq: (data['articleSeq'] as String?) ?? doc.id,
      title: (data['title'] as String?) ?? '',
      thumbnailUrl: data['thumbnailUrl'] as String?,
      pdfStorageUrl: data['pdfStorageUrl'] as String?,
      createdAt: createdAt?.toDate(),
      updatedAt: updatedAt?.toDate(),
    );
  }
}

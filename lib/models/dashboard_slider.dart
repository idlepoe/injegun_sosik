import 'package:freezed_annotation/freezed_annotation.dart';

part 'dashboard_slider.freezed.dart';

/// 대시보드 슬라이더 한 건 (인제군 포털 메인 배너 슬라이더)
/// @see 크롤링_대시보드_항목.md
@freezed
abstract class DashboardSliderItem with _$DashboardSliderItem {
  const factory DashboardSliderItem({
    /// 이미지 절대 URL
    required String imageUrl,
    /// 이미지 alt 텍스트
    required String imageAlt,
    /// 제목 (div.hidden_txt, 없으면 imageAlt)
    required String title,
    /// 링크 URL (아이템이 <a>일 때만, 빈/http:// 는 null)
    required String? linkUrl,
    /// linkUrl 쿼리 articleSeq (inje.go.kr 포함 시)
    String? articleSeq,
    /// data-seq 속성
    String? dataSeq,
    /// slick-cloned 제외 후 순서 (0부터)
    required int order,
  }) = _DashboardSliderItem;

  /// Firestore 문서의 items 배열 요소(Map)에서 생성
  factory DashboardSliderItem.fromMap(Map<String, dynamic> map) {
    return DashboardSliderItem(
      imageUrl: (map['imageUrl'] as String?) ?? '',
      imageAlt: (map['imageAlt'] as String?) ?? '',
      title: (map['title'] as String?) ?? '',
      linkUrl: map['linkUrl'] as String?,
      articleSeq: map['articleSeq'] as String?,
      dataSeq: map['dataSeq'] as String?,
      order: (map['order'] as int?) ?? 0,
    );
  }
}

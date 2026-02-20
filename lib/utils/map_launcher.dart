import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// 장소명으로 네이버 지도 검색을 외부 앱/브라우저에서 엽니다.
/// 대시보드·주간일정 목록 등에서 장소 탭 시 공통 사용.
Future<void> openNaverMap(String place) async {
  try {
    final encodedPlace = Uri.encodeComponent(place);
    final webUrl = Uri.parse('https://map.naver.com/p/search/$encodedPlace');
    await launchUrl(webUrl, mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint('Error opening Naver Map: $e');
  }
}

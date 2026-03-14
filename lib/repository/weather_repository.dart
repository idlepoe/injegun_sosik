import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/weather.dart';

/// Firestore weathers 컬렉션 GET 전용
class WeatherRepository {
  WeatherRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// fetchedAt desc로 정렬하여 최신 1건 조회
  /// getOptions: 캐시 우선 등 소스 지정 시 사용 (미지정 시 서버·캐시 기본)
  Future<WeatherData?> getLatest({GetOptions? getOptions}) async {
    final snapshot = await _firestore
        .collection('weathers')
        .orderBy('fetchedAt', descending: true)
        .limit(1)
        .get(getOptions ?? const GetOptions());
    
    if (snapshot.docs.isEmpty) {
      return null;
    }
    
    return WeatherData.fromFirestore(snapshot.docs.first);
  }
}

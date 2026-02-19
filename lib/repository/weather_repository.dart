import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/weather.dart';

/// Firestore weathers 컬렉션 GET 전용
class WeatherRepository {
  WeatherRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// fetchedAt desc로 정렬하여 최신 1건 조회
  Future<WeatherData?> getLatest() async {
    final snapshot = await _firestore
        .collection('weathers')
        .orderBy('fetchedAt', descending: true)
        .limit(1)
        .get();
    
    if (snapshot.docs.isEmpty) {
      return null;
    }
    
    return WeatherData.fromFirestore(snapshot.docs.first);
  }
}

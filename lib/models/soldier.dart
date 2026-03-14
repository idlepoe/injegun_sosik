import 'package:freezed_annotation/freezed_annotation.dart';

part 'soldier.freezed.dart';

/// 군장병 우대업소 업종 코드 (Firestore soldiers 컬렉션 category)
/// @see 군장병우대업소.md
abstract class SoldierCategory {
  static const String restaurant = 'restaurant';
  static const String lodgingIndustry = 'lodgingIndustry';
  static const String hair = 'hair';
  static const String pcroom = 'pcroom';

  static const List<String> values = [
    restaurant,
    lodgingIndustry,
    hair,
    pcroom,
  ];
}

/// 군장병 우대업소 한 건 (Firestore soldiers 컬렉션)
/// @see 군장병우대업소.md
@freezed
abstract class Soldier with _$Soldier {
  const factory Soldier({
    /// 행정동(구분)
    required String district,
    /// 업종 코드 (URL 기준)
    required String category,
    /// 업소명
    required String name,
    /// 주소
    required String address,
    /// 전화번호 (빈 문자열 가능)
    required String phone,
    /// 위도 (geocoding 성공 시만)
    double? lat,
    /// 경도 (geocoding 성공 시만)
    double? lng,
    /// geohash (encodeGeohash 결과, geocoding 성공 시만)
    String? geohash,
    /// Google Geocoding API place_id (geocoding 성공 시만)
    String? placeId,
    /// Place 사진 1장 URL (getMedia photoUri, 400x400)
    String? photoUrl,
  }) = _Soldier;

  /// Firestore 문서(Map)에서 생성
  factory Soldier.fromMap(Map<String, dynamic> map) {
    return Soldier(
      district: (map['district'] as String?) ?? '',
      category: (map['category'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      address: (map['address'] as String?) ?? '',
      phone: (map['phone'] as String?) ?? '',
      lat: _toDouble(map['lat']),
      lng: _toDouble(map['lng']),
      geohash: map['geohash'] as String?,
      placeId: map['placeId'] as String?,
      photoUrl: map['photoUrl'] as String?,
    );
  }
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return null;
}

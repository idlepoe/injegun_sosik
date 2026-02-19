import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather.freezed.dart';

/// OpenWeatherMap Current Weather Data API 응답 모델 (평면화된 구조)
/// @see https://api.openweathermap.org/data/2.5/weather
/// 
/// 중첩된 구조를 평면화하여 Firestore에 저장
/// weather 배열의 첫 번째 항목만 사용

@Freezed(fromJson: false, toJson: false)
abstract class WeatherData with _$WeatherData {
  const factory WeatherData({
    // Coord 필드
    required double lon,
    required double lat,
    
    // WeatherCondition 필드 (첫 번째 항목만)
    required int weatherId,
    required String weatherMain,
    required String weatherDescription,
    required String weatherIcon,
    
    // Main 필드
    required double temp,
    required double feelsLike,
    required double tempMin,
    required double tempMax,
    required int pressure,
    required int humidity,
    int? seaLevel,
    int? grndLevel,
    
    // Wind 필드
    required double windSpeed,
    required int windDeg,
    double? windGust,
    
    // Clouds 필드
    required int cloudsAll,
    
    // Sys 필드
    required String country,
    required int sunrise,
    required int sunset,
    
    // 기타 필드
    required String base,
    required int visibility,
    required int dt,
    required int timezone,
    required int id,
    required String name,
    required int cod,
  }) = _WeatherData;

  factory WeatherData.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    return WeatherData(
      // Coord 필드
      lon: (data['lon'] as num?)?.toDouble() ?? 0.0,
      lat: (data['lat'] as num?)?.toDouble() ?? 0.0,
      
      // WeatherCondition 필드
      weatherId: data['weatherId'] as int? ?? 0,
      weatherMain: data['weatherMain'] as String? ?? '',
      weatherDescription: data['weatherDescription'] as String? ?? '',
      weatherIcon: data['weatherIcon'] as String? ?? '',
      
      // Main 필드
      temp: (data['temp'] as num?)?.toDouble() ?? 0.0,
      feelsLike: (data['feelsLike'] as num?)?.toDouble() ?? 0.0,
      tempMin: (data['tempMin'] as num?)?.toDouble() ?? 0.0,
      tempMax: (data['tempMax'] as num?)?.toDouble() ?? 0.0,
      pressure: data['pressure'] as int? ?? 0,
      humidity: data['humidity'] as int? ?? 0,
      seaLevel: data['seaLevel'] as int?,
      grndLevel: data['grndLevel'] as int?,
      
      // Wind 필드
      windSpeed: (data['windSpeed'] as num?)?.toDouble() ?? 0.0,
      windDeg: data['windDeg'] as int? ?? 0,
      windGust: data['windGust'] != null ? (data['windGust'] as num).toDouble() : null,
      
      // Clouds 필드
      cloudsAll: data['cloudsAll'] as int? ?? 0,
      
      // Sys 필드
      country: data['country'] as String? ?? '',
      sunrise: data['sunrise'] as int? ?? 0,
      sunset: data['sunset'] as int? ?? 0,
      
      // 기타 필드
      base: data['base'] as String? ?? '',
      visibility: data['visibility'] as int? ?? 0,
      dt: data['dt'] as int? ?? 0,
      timezone: data['timezone'] as int? ?? 0,
      id: data['id'] as int? ?? 0,
      name: data['name'] as String? ?? '',
      cod: data['cod'] as int? ?? 0,
    );
  }
}

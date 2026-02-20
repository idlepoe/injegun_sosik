import 'package:flutter/material.dart';

import '../models/weather.dart';
import 'dashboard_style.dart';

/// 대시보드 최상단 날씨 1줄
class DashboardWeatherRow extends StatelessWidget {
  const DashboardWeatherRow({
    super.key,
    required this.dateStr,
    this.weatherData,
    this.isLoading = false,
  });

  final String dateStr;
  final WeatherData? weatherData;
  final bool isLoading;

  static String _getWeatherIconPath(String weatherIcon) {
    final iconMap = {
      '01d': 'assets/weather_icon/imgi_7_01d.png',
      '01n': 'assets/weather_icon/imgi_8_01n.png',
      '02d': 'assets/weather_icon/imgi_9_02d.png',
      '02n': 'assets/weather_icon/imgi_10_02n.png',
      '03d': 'assets/weather_icon/imgi_11_03d.png',
      '03n': 'assets/weather_icon/imgi_12_03n.png',
      '04d': 'assets/weather_icon/imgi_13_04d.png',
      '04n': 'assets/weather_icon/imgi_14_04n.png',
      '09d': 'assets/weather_icon/imgi_15_09d.png',
      '09n': 'assets/weather_icon/imgi_16_09n.png',
      '10d': 'assets/weather_icon/imgi_17_10d.png',
      '10n': 'assets/weather_icon/imgi_18_10n.png',
      '11d': 'assets/weather_icon/imgi_19_11d.png',
      '11n': 'assets/weather_icon/imgi_20_11n.png',
      '13d': 'assets/weather_icon/imgi_21_13d.png',
      '13n': 'assets/weather_icon/imgi_22_13n.png',
      '50d': 'assets/weather_icon/imgi_23_50d.png',
      '50n': 'assets/weather_icon/imgi_24_50n.png',
    };
    return iconMap[weatherIcon] ?? 'assets/weather_icon/imgi_7_01d.png';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Colors.white),
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: tossBlue,
                strokeWidth: 2,
              ),
            )
          : weatherData == null
              ? Text(
                  '날씨 정보를 불러올 수 없습니다.',
                  style: TextStyle(fontSize: 14, color: tossGreyText),
                )
              : Row(
                  children: [
                    Text(
                      '📍 인제군 | 오늘 $dateStr',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Image.asset(
                      _getWeatherIconPath(weatherData!.weatherIcon),
                      width: 22,
                      height: 22,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.wb_sunny, size: 22);
                      },
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${weatherData!.temp.round()}℃',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '| ${weatherData!.weatherDescription}',
                      style: TextStyle(fontSize: 14, color: tossGreyText),
                    ),
                  ],
                ),
    );
  }
}

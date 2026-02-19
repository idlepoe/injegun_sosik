import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../models/weather.dart';
import '../repository/newsletter_repository.dart';
import '../repository/weekschedule_repository.dart';
import '../repository/weather_repository.dart';
import 'newsletter_list_screen.dart';
import 'weekschedule_list_screen.dart';

/// 대시보드: 빈 화면 + Drawer 메뉴 (행사소식 / 합강소식지)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.weekscheduleRepository,
    required this.newsletterRepository,
    required this.weatherRepository,
  });

  final WeekscheduleRepository weekscheduleRepository;
  final NewsletterRepository newsletterRepository;
  final WeatherRepository weatherRepository;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  WeatherData? _weatherData;
  bool _isLoadingWeather = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final weather = await widget.weatherRepository.getLatest();
      if (mounted) {
        setState(() {
          _weatherData = weather;
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWeather = false;
        });
      }
    }
  }

  /// OpenWeatherMap icon 코드를 assets/weather_icon 파일명으로 변환
  /// 예: "01d" -> "assets/weather_icon/imgi_7_01d.png"
  String _getWeatherIconPath(String weatherIcon) {
    // OpenWeatherMap icon 형식: "01d", "02n" 등
    // assets 파일명 형식: "imgi_X_YYd.png" 또는 "imgi_X_YYn.png"

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

    return iconMap[weatherIcon] ?? 'assets/weather_icon/imgi_7_01d.png'; // 기본값
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('M.dd (E)', 'ko_KR');
    final dateStr = dateFormat.format(now);

    return Scaffold(
      appBar: AppBar(title: const Text('인제군 소식')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                '인제군 소식',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.event_note),
              title: const Text('행사소식 (주간일정)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  SwipeablePageRoute<void>(
                    builder: (_) => WeekscheduleListScreen(
                      repository: widget.weekscheduleRepository,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.newspaper),
              title: const Text('합강소식지'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  SwipeablePageRoute<void>(
                    builder: (_) => NewsletterListScreen(
                      repository: widget.newsletterRepository,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 날씨 정보 Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16.0),
            margin: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: _isLoadingWeather
                ? const Center(child: CircularProgressIndicator())
                : _weatherData == null
                ? const Text('날씨 정보를 불러올 수 없습니다.')
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📍 인제군 | 오늘 $dateStr',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Image.asset(
                            _getWeatherIconPath(_weatherData!.weatherIcon),
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.wb_sunny, size: 24);
                            },
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_weatherData!.temp.round()}℃',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '| ${_weatherData!.weatherDescription}',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          const Expanded(child: Center(child: Text('대시보드'))),
        ],
      ),
    );
  }
}

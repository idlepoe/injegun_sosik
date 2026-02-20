import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../models/article.dart';
import '../models/newsletter.dart';
import '../models/weather.dart';
import '../models/weekschedule_row.dart';
import '../repository/newsletter_repository.dart';
import '../repository/notice_repository.dart';
import '../repository/weekschedule_repository.dart';
import '../repository/weather_repository.dart';
import 'article_detail_screen.dart';
import 'newsletter_list_screen.dart';
import 'notice_list_screen.dart';
import 'pdf_viewer_screen.dart';
import 'weekschedule_list_screen.dart';

/// 대시보드: 빈 화면 + Drawer 메뉴 (행사소식 / 합강소식지)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.weekscheduleRepository,
    required this.newsletterRepository,
    required this.noticeRepository,
    required this.weatherRepository,
  });

  final WeekscheduleRepository weekscheduleRepository;
  final NewsletterRepository newsletterRepository;
  final NoticeRepository noticeRepository;
  final WeatherRepository weatherRepository;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  WeatherData? _weatherData;
  bool _isLoadingWeather = true;

  List<WeekScheduleRow>? _thisWeekEvents;
  List<Article>? _recentNotices;
  Newsletter? _latestNewsletter;
  bool _isLoadingDashboard = true;

  static final _dateOnlyFormat = DateFormat('yyyy-MM-dd');

  /// 이번 주 월요일 00:00, 일요일 23:59의 날짜 문자열 "YYYY-MM-DD"
  static (String start, String end) thisWeekRange() {
    final now = DateTime.now();
    final monday = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));
    final sunday = monday.add(const Duration(days: 6));
    return (_dateOnlyFormat.format(monday), _dateOnlyFormat.format(sunday));
  }

  /// 오늘 기준 7일 전 "YYYY-MM-DD"
  static String sevenDaysAgo() {
    final d = DateTime.now().subtract(const Duration(days: 7));
    return _dateOnlyFormat.format(d);
  }

  @override
  void initState() {
    super.initState();
    _loadWeather();
    _loadDashboard();
  }

  /// 날씨 + 행사/공지/소식지 전체 새로고침 (RefreshIndicator용)
  Future<void> _refreshAll() async {
    await Future.wait([_loadWeather(), _loadDashboard()]);
  }

  Future<void> _loadDashboard() async {
    final (weekStart, weekEnd) = thisWeekRange();
    final sinceStr = sevenDaysAgo();
    List<WeekScheduleRow>? events;
    List<Article>? notices;
    Newsletter? newsletter;
    try {
      events = await widget.weekscheduleRepository.getRowsInDateRange(
        weekStart,
        weekEnd,
      );
    } catch (_) {}
    try {
      final result = await widget.noticeRepository.getPage(pageSize: 50);
      notices = result.items
          .where((a) => a.registeredAt.compareTo(sinceStr) >= 0)
          .toList();
    } catch (_) {}
    try {
      final list = await widget.newsletterRepository.getPage(pageSize: 1);
      newsletter = list.isNotEmpty ? list.first : null;
    } catch (_) {}
    if (mounted) {
      setState(() {
        _thisWeekEvents = events ?? [];
        _recentNotices = notices ?? [];
        _latestNewsletter = newsletter;
        _isLoadingDashboard = false;
      });
    }
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
              leading: const Icon(Icons.campaign),
              title: const Text('공지사항'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  SwipeablePageRoute<void>(
                    builder: (_) =>
                        NoticeListScreen(repository: widget.noticeRepository),
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
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
              // 날씨 아래: 행사/공지/소식지
              ..._buildSectionChildren(),
            ],
          ),
        ),
      ),
    );
  }

  /// 행사/공지/소식지 섹션 위젯 목록 (ListView children용)
  List<Widget> _buildSectionChildren() {
    if (_isLoadingDashboard) {
      return [
        const SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    final sections = <Widget>[];
    final hasEvents = _thisWeekEvents != null && _thisWeekEvents!.isNotEmpty;
    final hasNotices = _recentNotices != null && _recentNotices!.isNotEmpty;
    final hasNewsletter = _latestNewsletter != null;
    if (!hasEvents && !hasNotices && !hasNewsletter) {
      return [const SizedBox(height: 120, child: Center(child: Text('대시보드')))];
    }
    const padding = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    if (hasEvents) {
      sections.add(_sectionHeader('이번 주 행사 ${_thisWeekEvents!.length}건'));
      for (final row in _thisWeekEvents!) {
        sections.add(_eventTile(row, padding));
      }
    }
    if (hasNotices) {
      sections.add(_sectionHeader('새 공지 ${_recentNotices!.length}건'));
      for (final article in _recentNotices!) {
        sections.add(_noticeTile(article, padding));
      }
    }
    if (hasNewsletter) {
      sections.add(_sectionHeader('합강소식지 ${_latestNewsletter!.title}'));
      sections.add(_newsletterTile(_latestNewsletter!, padding));
    }
    return sections;
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, right: 16, bottom: 4),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  /// "2026-02-19" -> "2/19" (년도 제외)
  String _formatDateShort(String dateStr) {
    final d = DateTime.tryParse(dateStr);
    if (d == null) return dateStr;
    return DateFormat('M/d').format(d);
  }

  /// row.date(YYYY-MM-DD) 기준 오늘과의 일 수 차이. null이면 파싱 실패.
  int? _relativeDayDiff(String dateStr) {
    final d = DateTime.tryParse(dateStr);
    if (d == null) return null;
    final today = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
    );
    final eventDate = DateTime(d.year, d.month, d.day);
    return eventDate.difference(today).inDays;
  }

  /// row.date(YYYY-MM-DD) 기준 오늘과의 차이: "N일 남음", "오늘", "N일 지남"
  String _relativeDayLabel(String dateStr) {
    final diff = _relativeDayDiff(dateStr);
    if (diff == null) return '';
    if (diff > 0) return '$diff일 남음';
    if (diff == 0) return '오늘';
    return '${-diff}일 지남';
  }

  Widget _eventTile(WeekScheduleRow row, EdgeInsets padding) {
    final label = _relativeDayLabel(row.date);
    final diff = _relativeDayDiff(row.date);
    final chipColor = diff == null
        ? Colors.grey.shade700
        : diff == 0
        ? Colors.green
        : diff > 0
        ? Colors.blue
        : Colors.grey.shade700;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: padding,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (label.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Chip(
                    backgroundColor: chipColor,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 0,
                    ),
                    labelPadding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 0,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: const VisualDensity(
                      horizontal: -1,
                      vertical: -1,
                    ),
                    label: Text(
                      label,
                      style: const TextStyle(fontSize: 10, color: Colors.white),
                    ),
                  ),
                ),
              Text(row.eventContent, style: const TextStyle(fontSize: 12)),
            ],
          ),
          subtitle: Text(
            '${row.date} ${row.time} · ${row.place}',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          onTap: () {
            Navigator.of(context).push(
              SwipeablePageRoute<void>(
                builder: (_) => WeekscheduleListScreen(
                  repository: widget.weekscheduleRepository,
                ),
              ),
            );
          },
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _noticeTile(Article article, EdgeInsets padding) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: padding,
          title: Text(
            article.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
          trailing: Text(
            _formatDateShort(article.registeredAt),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
          onTap: () {
            Navigator.of(context).push(
              SwipeablePageRoute<void>(
                builder: (_) => ArticleDetailScreen(
                  articleSeq: article.articleSeq,
                  repository: widget.noticeRepository,
                ),
              ),
            );
          },
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _newsletterTile(Newsletter newsletter, EdgeInsets padding) {
    final hasPdf =
        newsletter.pdfStorageUrl != null &&
        newsletter.pdfStorageUrl!.isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: padding,
          child: SizedBox(
            height: 140,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: hasPdf
                    ? () {
                        Navigator.of(context).push(
                          SwipeablePageRoute<void>(
                            builder: (_) => PdfViewerScreen(
                              pdfUrl: newsletter.pdfStorageUrl!,
                              title: newsletter.title,
                            ),
                          ),
                        );
                      }
                    : () {
                        Navigator.of(context).push(
                          SwipeablePageRoute<void>(
                            builder: (_) => NewsletterListScreen(
                              repository: widget.newsletterRepository,
                            ),
                          ),
                        );
                      },
                borderRadius: BorderRadius.circular(4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 100,
                      child: ClipRRect(
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(4),
                        ),
                        child: newsletter.thumbnailUrl != null
                            ? CachedNetworkImage(
                                imageUrl: newsletter.thumbnailUrl!,
                                httpHeaders: const {
                                  'User-Agent':
                                      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                                },
                                fit: BoxFit.cover,
                                placeholder: (context, url) => const Center(
                                  child: SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Center(
                                      child: Icon(
                                        Icons.image_not_supported,
                                        size: 40,
                                      ),
                                    ),
                              )
                            : const Center(
                                child: Icon(Icons.picture_as_pdf, size: 48),
                              ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            newsletter.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

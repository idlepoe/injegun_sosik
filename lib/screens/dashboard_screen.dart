import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../models/article.dart';
import '../models/newsletter.dart';
import '../models/weather.dart';
import '../models/weekschedule_row.dart';
import '../repository/free_repository.dart';
import '../repository/job_repository.dart';
import '../repository/livelihood_repository.dart';
import '../repository/newsletter_repository.dart';
import '../repository/notice_repository.dart';
import '../repository/weekschedule_repository.dart';
import '../repository/weather_repository.dart';
import '../utils/map_launcher.dart';
import '../widgets/dashboard_drawer.dart';
import '../widgets/dashboard_newsletter_tile.dart';
import '../widgets/dashboard_notice_tile.dart';
import '../widgets/dashboard_section_header.dart';
import '../widgets/dashboard_slider_banner.dart';
import '../widgets/dashboard_style.dart';
import '../widgets/dashboard_weather_row.dart';
import '../widgets/dashboard_weekschedule_tile.dart';
import 'article_detail_screen.dart';
import 'newsletter_list_screen.dart';
import 'notification_list_screen.dart';
import 'notice_list_screen.dart';
import 'pdf_viewer_screen.dart';
import 'setting_screen.dart';
import 'weekschedule_list_screen.dart';

/// 대시보드: 빈 화면 + Drawer 메뉴 (행사소식 / 합강소식지)
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.weekscheduleRepository,
    required this.newsletterRepository,
    required this.noticeRepository,
    required this.freeRepository,
    required this.jobRepository,
    required this.livelihoodRepository,
    required this.weatherRepository,
  });

  final WeekscheduleRepository weekscheduleRepository;
  final NewsletterRepository newsletterRepository;
  final NoticeRepository noticeRepository;
  final FreeRepository freeRepository;
  final JobRepository jobRepository;
  final LivelihoodRepository livelihoodRepository;
  final WeatherRepository weatherRepository;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  WeatherData? _weatherData;
  bool _isLoadingWeather = true;

  List<Article>? _recentNotices;
  Newsletter? _latestNewsletter;
  List<WeekScheduleRow>? _futureWeekschedules;
  bool _isLoadingDashboard = true;

  static final _dateOnlyFormat = DateFormat('yyyy-MM-dd');

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPendingArticleSeq());
  }

  /// 앱이 종료 상태에서 알림으로 켜진 경우 pending_article_seq 처리
  Future<void> _checkPendingArticleSeq() async {
    final prefs = await SharedPreferences.getInstance();
    final articleSeq = prefs.getString('pending_article_seq');
    if (articleSeq == null || articleSeq.isEmpty) return;
    await prefs.remove('pending_article_seq');
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ArticleDetailScreen(
          articleSeq: articleSeq,
          repository: widget.noticeRepository,
        ),
      ),
    );
  }

  /// 날씨 + 행사/공지/소식지 전체 새로고침 (RefreshIndicator용)
  Future<void> _refreshAll() async {
    await Future.wait([_loadWeather(), _loadDashboard()]);
  }

  Future<void> _loadDashboard() async {
    final sinceStr = sevenDaysAgo();
    final now = DateTime.now();
    final todayStr = _dateOnlyFormat.format(now);
    final endDate = now.add(const Duration(days: 60));
    final endStr = _dateOnlyFormat.format(endDate);

    List<Article>? notices;
    Newsletter? newsletter;
    List<WeekScheduleRow>? futureSchedules;
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
    try {
      futureSchedules = await widget.weekscheduleRepository.getRowsInDateRange(
        todayStr,
        endStr,
      );
    } catch (_) {}
    if (mounted) {
      setState(() {
        _recentNotices = notices ?? [];
        _latestNewsletter = newsletter;
        _futureWeekschedules = futureSchedules ?? [];
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

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateFormat = DateFormat('M.dd (E)', 'ko_KR');
    final dateStr = dateFormat.format(now);

    return Scaffold(
      backgroundColor: tossBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: Colors.grey.shade800,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.grey.shade900,
        ),
        title: const Text('인제군 소식'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.of(context).push(
                SwipeablePageRoute<void>(
                  builder: (_) => NotificationListScreen(
                    noticeRepository: widget.noticeRepository,
                    freeRepository: widget.freeRepository,
                    jobRepository: widget.jobRepository,
                    livelihoodRepository: widget.livelihoodRepository,
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                SwipeablePageRoute<void>(
                  builder: (_) => const SettingScreen(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: DashboardDrawer(
        weekscheduleRepository: widget.weekscheduleRepository,
        newsletterRepository: widget.newsletterRepository,
        noticeRepository: widget.noticeRepository,
        freeRepository: widget.freeRepository,
        jobRepository: widget.jobRepository,
        livelihoodRepository: widget.livelihoodRepository,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshAll,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              DashboardWeatherRow(
                dateStr: dateStr,
                weatherData: _weatherData,
                isLoading: _isLoadingWeather,
              ),
              const SizedBox(height: 12),
              ..._buildSectionChildren(),
            ],
          ),
        ),
      ),
    );
  }

  /// 행사/공지/소식지 섹션 위젯 목록 (ListView children용)
  List<Widget> _buildSectionChildren() {
    final sections = <Widget>[
      const DashboardSliderBanner(),
    ];
    if (_isLoadingDashboard) {
      sections.add(
        SizedBox(
          height: 120,
          child: Center(child: CircularProgressIndicator(color: tossBlue)),
        ),
      );
      return sections;
    }
    final hasNotices = _recentNotices != null && _recentNotices!.isNotEmpty;
    final hasNewsletter = _latestNewsletter != null;
    final hasFutureSchedules =
        _futureWeekschedules != null && _futureWeekschedules!.isNotEmpty;
    if (!hasNotices && !hasNewsletter && !hasFutureSchedules) {
      return [const SizedBox(height: 120, child: Center(child: Text('대시보드')))];
    }
    if (hasNotices) {
      final noticeCount = _recentNotices!.length;
      final displayCount = noticeCount > 3 ? 3 : noticeCount;
      sections.add(
        DashboardSectionHeader(
          title: '새 공지 $displayCount건',
          onSeeAllTap: () {
            Navigator.of(context).push(
              SwipeablePageRoute<void>(
                builder: (_) =>
                    NoticeListScreen(repository: widget.noticeRepository),
              ),
            );
          },
        ),
      );
      for (final article in _recentNotices!.take(3)) {
        sections.add(
          DashboardNoticeTile(
            article: article,
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
        );
      }
    }
    if (hasFutureSchedules) {
      sections.add(
        DashboardSectionHeader(
          title: '다가오는 행사 ${_futureWeekschedules!.length}건',
          onSeeAllTap: () {
            Navigator.of(context).push(
              SwipeablePageRoute<void>(
                builder: (_) => WeekscheduleListScreen(
                  repository: widget.weekscheduleRepository,
                ),
              ),
            );
          },
        ),
      );
      final todayStr = _dateOnlyFormat.format(DateTime.now());
      for (final row in _futureWeekschedules!) {
        sections.add(
          DashboardWeekscheduleTile(
            row: row,
            isToday: row.date == todayStr,
            onPlaceTap: openNaverMap,
            onEventTap: (articleSeq) {
              Navigator.of(context).push(
                SwipeablePageRoute<void>(
                  builder: (_) => ArticleDetailScreen(
                    articleSeq: articleSeq,
                    repository: widget.noticeRepository,
                  ),
                ),
              );
            },
          ),
        );
      }
    }
    if (hasNewsletter) {
      sections.add(
        DashboardSectionHeader(
          title: '최신 합강소식지',
          onSeeAllTap: () {
            Navigator.of(context).push(
              SwipeablePageRoute<void>(
                builder: (_) => NewsletterListScreen(
                  repository: widget.newsletterRepository,
                ),
              ),
            );
          },
        ),
      );
      final newsletter = _latestNewsletter!;
      final hasPdf =
          newsletter.pdfStorageUrl != null &&
          newsletter.pdfStorageUrl!.isNotEmpty;
      sections.add(
        DashboardNewsletterTile(
          newsletter: newsletter,
          onTap: () {
            if (hasPdf) {
              Navigator.of(context).push(
                SwipeablePageRoute<void>(
                  builder: (_) => PdfViewerScreen(
                    pdfUrl: newsletter.pdfStorageUrl!,
                    title: newsletter.title,
                  ),
                ),
              );
            } else {
              Navigator.of(context).push(
                SwipeablePageRoute<void>(
                  builder: (_) => NewsletterListScreen(
                    repository: widget.newsletterRepository,
                  ),
                ),
              );
            }
          },
        ),
      );
    }
    return sections;
  }
}

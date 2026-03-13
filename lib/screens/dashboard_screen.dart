import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';
import 'package:upgrader/upgrader.dart';

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
import '../services/fcm_service.dart';
import '../utils/toast_utils.dart';
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

  /// 뒤로가기 두 번으로 종료: 마지막 뒤로가기 누른 시각
  DateTime? _lastBackPress;

  List<Article>? _recentNotices;
  bool _isLoadingNotices = true;
  Newsletter? _latestNewsletter;
  bool _isLoadingNewsletter = true;
  List<WeekScheduleRow>? _futureWeekschedules;
  bool _isLoadingWeekschedules = true;

  int _unreadNotificationCount = 0;

  late final PageController _noticePageController;
  int _currentNoticePage = 0;

  late final PageController _weekschedulePageController;
  int _currentWeekschedulePage = 0;

  static final _dateOnlyFormat = DateFormat('yyyy-MM-dd');

  /// 오늘 기준 7일 전 "YYYY-MM-DD"
  static String sevenDaysAgo() {
    final d = DateTime.now().subtract(const Duration(days: 7));
    return _dateOnlyFormat.format(d);
  }

  @override
  void initState() {
    super.initState();
    _noticePageController = PageController();
    _weekschedulePageController = PageController();
    _loadWeather();
    _loadDashboard();
    _loadUnreadNotificationCount();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkPendingArticleSeq());
  }

  @override
  void dispose() {
    _noticePageController.dispose();
    _weekschedulePageController.dispose();
    super.dispose();
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
  Future<void> _refreshAll() {
    return Future.wait<void>([
      _loadWeather(),
      _loadDashboard(),
      _loadUnreadNotificationCount(),
    ]);
  }

  Future<void> _loadUnreadNotificationCount() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getString(keyPushNotificationList);
    int count = 0;
    if (jsonList != null && jsonList.isNotEmpty) {
      try {
        final list = jsonDecode(jsonList) as List<dynamic>;
        for (final e in list) {
          final map = e as Map<String, dynamic>;
          final isRead = map['isRead'] as bool? ?? false;
          if (!isRead) {
            count++;
          }
        }
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        _unreadNotificationCount = count;
      });
    }
  }

  Future<void> _loadDashboard() async {
    final sinceStr = sevenDaysAgo();
    final now = DateTime.now();
    final todayStr = _dateOnlyFormat.format(now);
    final endDate = now.add(const Duration(days: 60));
    final endStr = _dateOnlyFormat.format(endDate);

    if (mounted) {
      setState(() {
        _isLoadingNotices = true;
        _isLoadingNewsletter = true;
        _isLoadingWeekschedules = true;
        _recentNotices = null;
        _latestNewsletter = null;
        _futureWeekschedules = null;
      });
    }

    List<Article> notices = [];
    try {
      final result = await widget.noticeRepository.getPage(pageSize: 50);
      notices = result.items
          .where((a) => a.registeredAt.compareTo(sinceStr) >= 0)
          .toList();
    } catch (_) {}

    if (mounted) {
      setState(() {
        _recentNotices = notices;
        _isLoadingNotices = false;
      });
    }

    Newsletter? newsletter;
    try {
      final list = await widget.newsletterRepository.getPage(pageSize: 1);
      newsletter = list.isNotEmpty ? list.first : null;
    } catch (_) {}

    if (mounted) {
      setState(() {
        _latestNewsletter = newsletter;
        _isLoadingNewsletter = false;
      });
    }

    List<WeekScheduleRow> futureSchedules = [];
    try {
      futureSchedules = await widget.weekscheduleRepository.getRowsInDateRange(
        todayStr,
        endStr,
      );
    } catch (_) {}

    if (mounted) {
      setState(() {
        _futureWeekschedules = futureSchedules;
        _isLoadingWeekschedules = false;
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastBackPress != null &&
            now.difference(_lastBackPress!).inSeconds < 3) {
          SystemNavigator.pop();
          return;
        }
        ToastUtils.show(context, "'뒤로' 버튼을 한번 더 누르면 종료됩니다.");
        setState(() => _lastBackPress = now);
      },
      child: Scaffold(
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
            icon: Badge.count(
              count: _unreadNotificationCount,
              isLabelVisible: _unreadNotificationCount > 0,
              child: const Icon(Icons.notifications_outlined),
            ),
            onPressed: () {
              Navigator.of(context)
                  .push(
                    SwipeablePageRoute<void>(
                      builder: (_) => NotificationListScreen(
                        noticeRepository: widget.noticeRepository,
                        freeRepository: widget.freeRepository,
                        jobRepository: widget.jobRepository,
                        livelihoodRepository: widget.livelihoodRepository,
                      ),
                    ),
                  )
                  .then((_) => _loadUnreadNotificationCount());
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
        child: UpgradeAlert(
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
      ),
      ),
    );
  }

  /// 행사/공지/소식지 섹션 위젯 목록 (ListView children용)
  List<Widget> _buildSectionChildren() {
    final sections = <Widget>[
      const DashboardSliderBanner(),
    ];

    final hasNotices = _recentNotices != null && _recentNotices!.isNotEmpty;
    final hasNewsletter = _latestNewsletter != null;
    final hasFutureSchedules =
        _futureWeekschedules != null && _futureWeekschedules!.isNotEmpty;

    if (_isLoadingNotices) {
      sections.add(_buildLoadingSection());
      return sections;
    }

    if (hasNotices) {
      final notices = _recentNotices!;
      final noticeCount = notices.length;
      final pages = <List<Article>>[];
      for (var i = 0; i < noticeCount; i += 3) {
        final end = (i + 3 < noticeCount) ? i + 3 : noticeCount;
        pages.add(notices.sublist(i, end));
      }

      sections.add(
        DashboardSectionHeader(
          title: '새 공지 ${noticeCount}건',
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

      sections.add(
        SizedBox(
          height: 230,
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _noticePageController,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentNoticePage = index;
                    });
                  },
                  itemBuilder: (context, pageIndex) {
                    final pageArticles = pages[pageIndex];
                    return Column(
                      children: [
                        for (final article in pageArticles)
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
                      ],
                    );
                  },
                ),
              ),
              if (pages.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (index) => Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentNoticePage
                            ? tossBlue
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (_isLoadingWeekschedules) {
      sections.add(_buildLoadingSection());
      return sections;
    }

    if (!hasNotices && !hasNewsletter && !hasFutureSchedules) {
      return [const SizedBox(height: 120, child: Center(child: Text('대시보드')))];
    }

    if (hasFutureSchedules) {
      final schedules = _futureWeekschedules!;
      final total = schedules.length;
      final pages = <List<WeekScheduleRow>>[];
      for (var i = 0; i < total; i += 3) {
        final end = (i + 3 < total) ? i + 3 : total;
        pages.add(schedules.sublist(i, end));
      }

      sections.add(
        DashboardSectionHeader(
          title: '다가오는 행사 ${total}건',
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

      sections.add(
        SizedBox(
          height: 245,
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _weekschedulePageController,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentWeekschedulePage = index;
                    });
                  },
                  itemBuilder: (context, pageIndex) {
                    final pageRows = pages[pageIndex];
                    return Column(
                      children: [
                        for (final row in pageRows)
                          DashboardWeekscheduleTile(
                            row: row,
                            isToday: row.date == todayStr,
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
                      ],
                    );
                  },
                ),
              ),
              if (pages.length > 1)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    pages.length,
                    (index) => Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: index == _currentWeekschedulePage
                            ? tossBlue
                            : Colors.grey.shade300,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    }

    if (_isLoadingNewsletter) {
      sections.add(_buildLoadingSection());
      return sections;
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

  Widget _buildLoadingSection() {
    return SizedBox(
      height: 120,
      child: Center(child: CircularProgressIndicator(color: tossBlue)),
    );
  }
}

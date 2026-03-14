import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../repository/free_repository.dart';
import '../repository/job_repository.dart';
import '../repository/livelihood_repository.dart';
import '../repository/newsletter_repository.dart';
import '../repository/notice_repository.dart';
import '../repository/praise_repository.dart';
import '../repository/soldier_repository.dart';
import '../repository/weekschedule_repository.dart';
import '../screens/free_list_screen.dart';
import '../screens/job_list_screen.dart';
import '../screens/livelihood_list_screen.dart';
import '../screens/newsletter_list_screen.dart';
import '../screens/notice_list_screen.dart';
import '../screens/praise_list_screen.dart';
import '../screens/soldiers_list_screen.dart';
import '../screens/weekschedule_list_screen.dart';
import 'dashboard_style.dart';

/// 대시보드 Drawer (행사소식, 공지사항, 합강소식지, 자유게시판, 구인구직, 생활장터)
class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({
    super.key,
    required this.weekscheduleRepository,
    required this.newsletterRepository,
    required this.noticeRepository,
    required this.praiseRepository,
    required this.freeRepository,
    required this.jobRepository,
    required this.livelihoodRepository,
    required this.soldierRepository,
  });

  final WeekscheduleRepository weekscheduleRepository;
  final NewsletterRepository newsletterRepository;
  final NoticeRepository noticeRepository;
  final PraiseRepository praiseRepository;
  final FreeRepository freeRepository;
  final JobRepository jobRepository;
  final LivelihoodRepository livelihoodRepository;
  final SoldierRepository soldierRepository;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Drawer(
        backgroundColor: Colors.white,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(color: tossBackground),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '인제군 소식',
                          style: TextStyle(
                            color: Colors.grey.shade900,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '필요한 정보만 쏙쏙, 알림으로 받을수 있어요.',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: Icon(Icons.campaign, color: tossGreyText),
                    title: Text(
                      '공지사항',
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        SwipeablePageRoute<void>(
                          builder: (_) =>
                              NoticeListScreen(repository: noticeRepository),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.newspaper, color: tossGreyText),
                    title: Text(
                      '합강소식지',
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        SwipeablePageRoute<void>(
                          builder: (_) => NewsletterListScreen(
                            repository: newsletterRepository,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.forum, color: tossGreyText),
                    title: Text(
                      '자유게시판',
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        SwipeablePageRoute<void>(
                          builder: (_) =>
                              FreeListScreen(repository: freeRepository),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.work, color: tossGreyText),
                    title: Text(
                      '구인구직',
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        SwipeablePageRoute<void>(
                          builder: (_) =>
                              JobListScreen(repository: jobRepository),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.store, color: tossGreyText),
                    title: Text(
                      '생활장터',
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        SwipeablePageRoute<void>(
                          builder: (_) => LivelihoodListScreen(
                            repository: livelihoodRepository,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.event_note, color: tossGreyText),
                    title: Text(
                      '행사소식 (주간일정)',
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        SwipeablePageRoute<void>(
                          builder: (_) => WeekscheduleListScreen(
                            repository: weekscheduleRepository,
                          ),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.thumb_up, color: tossGreyText),
                    title: Text(
                      '칭찬합니다',
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        SwipeablePageRoute<void>(
                          builder: (_) =>
                              PraiseListScreen(repository: praiseRepository),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.card_giftcard, color: tossGreyText),
                    title: Text(
                      '군장병우대업소(상품권환급)',
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(
                        SwipeablePageRoute<void>(
                          builder: (_) => SoldiersListScreen(
                            repository: soldierRepository,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(context);
                        final uri = Uri.parse('mailto:idlepoe@gmail.com');
                        try {
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (_) {}
                      },
                      icon: const Icon(Icons.mail_outline, size: 18),
                      label: const Text('문의하기'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '2026. 황금풍뎅이',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

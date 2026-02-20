import 'package:flutter/material.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../repository/free_repository.dart';
import '../repository/job_repository.dart';
import '../repository/livelihood_repository.dart';
import '../repository/newsletter_repository.dart';
import '../repository/notice_repository.dart';
import '../repository/weekschedule_repository.dart';
import '../screens/free_list_screen.dart';
import '../screens/job_list_screen.dart';
import '../screens/livelihood_list_screen.dart';
import '../screens/newsletter_list_screen.dart';
import '../screens/notice_list_screen.dart';
import '../screens/weekschedule_list_screen.dart';
import 'dashboard_style.dart';

/// 대시보드 Drawer (행사소식, 공지사항, 합강소식지, 자유게시판, 구인구직, 생활장터)
class DashboardDrawer extends StatelessWidget {
  const DashboardDrawer({
    super.key,
    required this.weekscheduleRepository,
    required this.newsletterRepository,
    required this.noticeRepository,
    required this.freeRepository,
    required this.jobRepository,
    required this.livelihoodRepository,
  });

  final WeekscheduleRepository weekscheduleRepository;
  final NewsletterRepository newsletterRepository;
  final NoticeRepository noticeRepository;
  final FreeRepository freeRepository;
  final JobRepository jobRepository;
  final LivelihoodRepository livelihoodRepository;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: tossBackground),
            child: Text(
              '인제군 소식',
              style: TextStyle(
                color: Colors.grey.shade900,
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
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
        ],
      ),
    );
  }
}

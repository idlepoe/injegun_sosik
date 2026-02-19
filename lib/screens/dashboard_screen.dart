import 'package:flutter/material.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../repository/newsletter_repository.dart';
import '../repository/weekschedule_repository.dart';
import 'newsletter_list_screen.dart';
import 'weekschedule_list_screen.dart';

/// 대시보드: 빈 화면 + Drawer 메뉴 (행사소식 / 합강소식지)
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.weekscheduleRepository,
    required this.newsletterRepository,
  });

  final WeekscheduleRepository weekscheduleRepository;
  final NewsletterRepository newsletterRepository;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('인제군 소식'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('인제군 소식', style: TextStyle(color: Colors.white, fontSize: 24)),
            ),
            ListTile(
              leading: const Icon(Icons.event_note),
              title: const Text('행사소식 (주간일정)'),
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
              leading: const Icon(Icons.newspaper),
              title: const Text('합강소식지'),
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
          ],
        ),
      ),
      body: const Center(child: Text('대시보드')),
    );
  }
}

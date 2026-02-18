import 'package:flutter/material.dart';

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
              title: const Text('행사소식 (weekschedule)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
                    builder: (_) => WeekscheduleListScreen(
                      repository: weekscheduleRepository,
                    ),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('합강소식지 (newsletters)'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute<void>(
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

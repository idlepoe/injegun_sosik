import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'repository/free_repository.dart';
import 'repository/job_repository.dart';
import 'repository/livelihood_repository.dart';
import 'repository/newsletter_repository.dart';
import 'repository/notice_repository.dart';
import 'repository/weekschedule_repository.dart';
import 'repository/weather_repository.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // SSL 인증서 검증 우회 (개발 환경용)
  HttpOverrides.global = MyHttpOverrides();
  
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('ko_KR', null);
  runApp(const MyApp());
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '인제군 소식',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      home: DashboardScreen(
        weekscheduleRepository: WeekscheduleRepository(),
        newsletterRepository: NewsletterRepository(),
        noticeRepository: NoticeRepository(),
        freeRepository: FreeRepository(),
        jobRepository: JobRepository(),
        livelihoodRepository: LivelihoodRepository(),
        weatherRepository: WeatherRepository(),
      ),
    );
  }
}

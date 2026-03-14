import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'firebase_options.dart';
import 'repository/free_repository.dart';
import 'repository/job_repository.dart';
import 'repository/livelihood_repository.dart';
import 'repository/newsletter_repository.dart';
import 'repository/notice_repository.dart';
import 'repository/praise_repository.dart';
import 'repository/weekschedule_repository.dart';
import 'repository/weather_repository.dart';
import 'screens/dashboard_screen.dart';
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final navigatorKey = GlobalKey<NavigatorState>();
  final weekscheduleRepository = WeekscheduleRepository();
  final newsletterRepository = NewsletterRepository();
  final noticeRepository = NoticeRepository();
  final praiseRepository = PraiseRepository();
  final freeRepository = FreeRepository();
  final jobRepository = JobRepository();
  final livelihoodRepository = LivelihoodRepository();
  final weatherRepository = WeatherRepository();

  final homeWidget = DashboardScreen(
    weekscheduleRepository: weekscheduleRepository,
    newsletterRepository: newsletterRepository,
    noticeRepository: noticeRepository,
    praiseRepository: praiseRepository,
    freeRepository: freeRepository,
    jobRepository: jobRepository,
    livelihoodRepository: livelihoodRepository,
    weatherRepository: weatherRepository,
  );

  FcmService().setNavigationDeps(navigatorKey, () => DashboardScreen(
        weekscheduleRepository: weekscheduleRepository,
        newsletterRepository: newsletterRepository,
        noticeRepository: noticeRepository,
        praiseRepository: praiseRepository,
        freeRepository: freeRepository,
        jobRepository: jobRepository,
        livelihoodRepository: livelihoodRepository,
        weatherRepository: weatherRepository,
      ));
  await FcmService().initialize();

  await initializeDateFormatting('ko_KR', null);
  runApp(MyApp(navigatorKey: navigatorKey, home: homeWidget));
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.navigatorKey, required this.home});

  final GlobalKey<NavigatorState> navigatorKey;
  final Widget home;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '인제군 소식',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: home,
    );
  }
}

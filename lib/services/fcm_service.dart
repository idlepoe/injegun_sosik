import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

import '../models/article.dart';
import '../repository/notice_repository.dart';
import '../screens/article_detail_screen.dart';

/// 푸시 알림 리스트 SharedPreferences 키 (알림 목록 화면에서 읽기/쓰기용)
const String keyPushNotificationList = 'push_notification_list';

/// FCM 서비스 클래스
class FcmService {
  static final FcmService _instance = FcmService._internal();
  factory FcmService() => _instance;
  FcmService._internal();

  GlobalKey<NavigatorState>? _navigatorKey;
  Widget Function()? _homeBuilder;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// 네비게이션 의존성 설정 (main에서 호출)
  void setNavigationDeps(
    GlobalKey<NavigatorState> navigatorKey,
    Widget Function() homeBuilder,
  ) {
    _navigatorKey = navigatorKey;
    _homeBuilder = homeBuilder;
  }

  /// FCM 초기화
  Future<void> initialize() async {
    // 로컬 알림 초기화
    await _initializeLocalNotifications();

    // 알림 권한 요청 (iOS)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      debugPrint('User granted provisional permission');
    } else {
      debugPrint('User declined or has not accepted permission');
    }

    // iOS: 포그라운드에서도 알림 배너/뱃지/사운드 표시
    if (!kIsWeb && Platform.isIOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // FCM 토큰 가져오기
    String? token;

    // iOS에서는 APNS 토큰이 준비되기 전에 getToken()을 호출하면
    // [firebase_messaging/apns-token-not-set] 에러가 발생하므로,
    // 먼저 APNS 토큰이 있는지 확인한 뒤에만 getToken()을 호출한다.
    if (!kIsWeb && Platform.isIOS) {
      final apnsToken = await _messaging.getAPNSToken();
      debugPrint('APNS Token: $apnsToken');

      if (apnsToken == null) {
        debugPrint(
          'APNS token is not available yet. Skipping FCM getToken() on iOS.',
        );
      } else {
        token = await _messaging.getToken();
      }
    } else {
      // Android, Web 등은 바로 FCM 토큰을 요청
      token = await _messaging.getToken();
    }

    debugPrint('FCM Token: $token');

    // 토큰 갱신 리스너
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM Token refreshed: $newToken');
    });

    // 포그라운드 메시지 핸들러
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 백그라운드 메시지 핸들러 (앱이 백그라운드에서 푸시 탭 시)
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundMessage);

    // 앱이 종료된 상태에서 알림을 탭하여 앱이 시작된 경우 처리
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      debugPrint('App opened from terminated state via notification');
      debugPrint('Initial message data: ${initialMessage.data}');
      await _saveArticleSeqIfPresent(initialMessage.data);
    }
  }

  /// 로컬 알림 초기화
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/push_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsIOS,
        );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );

    // Android 알림 채널 생성
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// 로컬 알림 표시
  Future<void> _showLocalNotification(RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    // 이미지 URL 가져오기 (data 필드에서)
    final imageUrl = message.data['imageUrl'] as String?;
    BigPictureStyleInformation? bigPictureStyleInformation;

    // 이미지가 있으면 다운로드하여 BigPictureStyleInformation 생성
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        bigPictureStyleInformation = await _createBigPictureStyle(imageUrl);
      } catch (e) {
        debugPrint('Error creating big picture style: $e');
      }
    }

    // articleSeq를 payload로 저장 (알림 탭 시 사용)
    final articleSeq = message.data['articleSeq'] as String?;
    final payload = articleSeq ?? '';

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'high_importance_channel',
      'High Importance Notifications',
      channelDescription: 'This channel is used for important notifications.',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@drawable/push_icon',
      styleInformation: bigPictureStyleInformation,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
        DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _localNotifications.show(
      id: message.hashCode,
      title: notification.title ?? 'New Event',
      body: notification.body ?? 'You have a new notification',
      notificationDetails: platformChannelSpecifics,
      payload: payload,
    );
  }

  /// 이미지를 다운로드하여 BigPictureStyleInformation 생성
  Future<BigPictureStyleInformation?> _createBigPictureStyle(
    String imageUrl,
  ) async {
    try {
      // 이미지 다운로드
      final response = await http.get(Uri.parse(imageUrl));
      if (response.statusCode != 200) {
        debugPrint('Failed to download image: ${response.statusCode}');
        return null;
      }

      // 임시 디렉토리에 파일 저장
      final directory = await getTemporaryDirectory();
      final fileName =
          'notification_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final filePath = path.join(directory.path, fileName);
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      // BigPictureStyleInformation 생성
      return BigPictureStyleInformation(
        FilePathAndroidBitmap(filePath),
        largeIcon: FilePathAndroidBitmap(filePath),
      );
    } catch (e) {
      debugPrint('Error creating big picture style: $e');
      return null;
    }
  }

  /// 포그라운드 메시지 처리
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    await savePushNotificationFromData(message.data);
    if (message.notification != null) {
      debugPrint(
        'Foreground notification: ${message.notification!.title} / ${message.notification!.body}',
      );
      // Android: 포그라운드에서는 FCM이 자동으로 알림을 안 보여주므로 로컬 알림 표시
      // iOS: setForegroundNotificationPresentationOptions로 이미 시스템 알림 표시됨 → 중복 방지 위해 Android만 로컬 알림
      if (!kIsWeb && Platform.isAndroid) {
        try {
          await _showLocalNotification(message);
        } catch (e) {
          debugPrint('Foreground local notification error: $e');
        }
      }
    }
  }

  /// 백그라운드 메시지 처리 (앱이 백그라운드 상태에서 알림 탭)
  Future<void> _handleBackgroundMessage(RemoteMessage message) async {
    debugPrint('Got a message whilst app was opened!');
    debugPrint('Message data: ${message.data}');

    await savePushNotificationFromData(message.data);

    final articleSeq = message.data['articleSeq'] as String?;
    if (articleSeq == null || articleSeq.isEmpty) {
      debugPrint('No articleSeq found in message data');
      return;
    }

    debugPrint('Extracted articleSeq: $articleSeq');
    await _navigateToArticleDetailOrSavePending(articleSeq);
  }

  /// 알림 탭 처리
  Future<void> _handleNotificationTap(NotificationResponse response) async {
    debugPrint('Notification tapped: ${response.payload}');

    String? articleSeq;
    final payload = response.payload;

    if (payload == null || payload.isEmpty) {
      debugPrint('No payload in notification');
      return;
    }

    try {
      if (payload.startsWith('{') && payload.contains('"articleSeq"')) {
        final jsonData = jsonDecode(payload) as Map<String, dynamic>;
        articleSeq = jsonData['articleSeq'] as String?;
      } else if (payload.contains('articleSeq:')) {
        final regex = RegExp(r'articleSeq:\s*([^\s,}]+)');
        final match = regex.firstMatch(payload);
        if (match != null && match.groupCount >= 1) {
          articleSeq = match.group(1);
        }
      } else {
        articleSeq = payload;
      }
    } catch (e) {
      debugPrint('Failed to parse payload, trying regex: $e');
      try {
        final regex = RegExp(r'articleSeq[:\s]*([^\s,}]+)');
        final match = regex.firstMatch(payload);
        if (match != null && match.groupCount >= 1) {
          articleSeq = match.group(1);
        } else if (payload.isNotEmpty &&
            !payload.contains('{') &&
            !payload.contains('}')) {
          articleSeq = payload;
        }
      } catch (e2) {
        debugPrint('Failed to extract articleSeq from payload: $e2');
      }
    }

    if (articleSeq == null || articleSeq.isEmpty) {
      debugPrint('No articleSeq found in notification payload');
      return;
    }

    debugPrint('Extracted articleSeq: $articleSeq');
    await _navigateToArticleDetailOrSavePending(articleSeq);
  }

  /// 대시보드로 이동 후 글 상세로 이동, 불가 시 pending_article_seq 저장
  Future<void> _navigateToArticleDetailOrSavePending(String articleSeq) async {
    final nav = _navigatorKey?.currentState;
    final homeBuilder = _homeBuilder;

    if (nav != null && homeBuilder != null) {
      nav.pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => homeBuilder()),
        (_) => false,
      );
      nav.push(
        MaterialPageRoute<void>(
          builder: (_) => ArticleDetailScreen(
            articleSeq: articleSeq,
            repository: NoticeRepository(),
          ),
        ),
      );
      debugPrint('Navigated to article detail: $articleSeq');
    } else {
      debugPrint('Navigator not ready, saving pending_article_seq');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('pending_article_seq', articleSeq);
    }
  }

  /// payload에 Article 전체가 있으면 푸시 리스트에 추가 (isRead: false). 백그라운드 핸들러에서도 호출 가능.
  static Future<void> savePushNotificationFromData(
    Map<String, dynamic> data,
  ) async {
    try {
      final articleSeq = data['articleSeq'] as String?;
      final title = data['title'] as String?;
      if (articleSeq == null ||
          articleSeq.isEmpty ||
          title == null ||
          title.isEmpty) {
        return;
      }
      final article = Article.fromMap(data);
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getString(keyPushNotificationList);
      final List<dynamic> list = jsonList != null && jsonList.isNotEmpty
          ? (jsonDecode(jsonList) as List<dynamic>)
          : [];
      list.add({
        'article': article.toMap(),
        'isRead': false,
      });
      await prefs.setString(keyPushNotificationList, jsonEncode(list));
      debugPrint('Saved push notification to list: ${article.articleSeq}');
    } catch (e) {
      debugPrint('Error saving push notification to list: $e');
    }
  }

  /// articleSeq가 있으면 SharedPreferences에 저장 (푸시 리스트 추가 시도 후 pending_article_seq)
  Future<void> _saveArticleSeqIfPresent(Map<String, dynamic> data) async {
    try {
      await savePushNotificationFromData(data);
      if (data.containsKey('articleSeq') && data['articleSeq'] != null) {
        final articleSeq = data['articleSeq'] as String;
        if (articleSeq.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('pending_article_seq', articleSeq);
          debugPrint('Saved pending articleSeq: $articleSeq');
        }
      }
    } catch (e) {
      debugPrint('Error saving articleSeq to SharedPreferences: $e');
    }
  }

  /// Topic 구독
  Future<void> subscribeToTopic(String topic) async {
    try {
      // 알림 설정 확인
      final prefs = await SharedPreferences.getInstance();
      final isNotificationEnabled = prefs.getBool('event_notification') ?? true;
      
      // 알림이 비활성화되어 있으면 skip
      if (!isNotificationEnabled) {
        debugPrint('Notification is disabled, skipping topic subscription: $topic');
        return;
      }
      
      await _messaging.subscribeToTopic(topic);
      debugPrint('Subscribed to topic: $topic');
    } catch (e) {
      debugPrint('Error subscribing to topic $topic: $e');
    }
  }

  /// Topic 구독 해제
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _messaging.unsubscribeFromTopic(topic);
      debugPrint('Unsubscribed from topic: $topic');
    } catch (e) {
      debugPrint('Error unsubscribing from topic $topic: $e');
    }
  }

  /// FCM 토큰 가져오기
  Future<String?> getToken() async {
    return await _messaging.getToken();
  }
}

/// 백그라운드 메시지 핸들러 (앱이 완전히 종료된 상태에서 메시지 수신)
/// 이 함수는 반드시 top-level 함수여야 합니다.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling a background message: ${message.messageId}');
  debugPrint('Message data: ${message.data}');

  await FcmService.savePushNotificationFromData(message.data);

  if (message.notification != null) {
    debugPrint('Message notification: ${message.notification}');
  }
}

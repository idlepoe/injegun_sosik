import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/fcm_service.dart';
import '../widgets/dashboard_style.dart';

/// 토픽 구독 설정 화면. 알림 설정 마스터 토글 + 5개 토픽별 토글.
class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  static const List<({String topic, String label})> _topics = [
    (topic: 'notice', label: '공지사항'),
    (topic: 'job', label: '구인구직'),
    (topic: 'livelihood', label: '생활장터'),
    (topic: 'free', label: '자유게시판'),
    (topic: 'weekschedule', label: '행사소식(주간일정)'),
  ];

  bool _masterEnabled = true;
  final Map<String, bool> _topicEnabled = {
    for (final e in _topics) e.topic: true,
  };
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// 설정 화면 진입 시 저장된 값만 UI에 반영. FCM 구독/해제는 토글 변경 시에만 수행.
  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final master = prefs.getBool('event_notification') ?? false;
    final Map<String, bool> topicEnabled = {};
    for (final e in _topics) {
      topicEnabled[e.topic] = prefs.getBool('topic_${e.topic}') ?? false;
    }
    if (mounted) {
      setState(() {
        _masterEnabled = master;
        _topicEnabled.clear();
        _topicEnabled.addAll(topicEnabled);
        _loading = false;
      });
    }
  }

  Future<void> _setMaster(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('event_notification', value);
    setState(() => _masterEnabled = value);

    final fcm = FcmService();
    if (value) {
      for (final e in _topics) {
        if (_topicEnabled[e.topic] ?? true) {
          await fcm.subscribeToTopic(e.topic);
        } else {
          await fcm.unsubscribeFromTopic(e.topic);
        }
      }
    } else {
      for (final e in _topics) {
        await fcm.unsubscribeFromTopic(e.topic);
      }
    }
  }

  Future<void> _setTopic(String topic, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('topic_$topic', value);
    setState(() => _topicEnabled[topic] = value);

    final fcm = FcmService();
    if (value) {
      await fcm.subscribeToTopic(topic);
    } else {
      await fcm.unsubscribeFromTopic(topic);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
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
          title: const Text('설정'),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

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
        title: const Text('설정'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '알림 설정',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ),
          Material(
            color: Colors.white,
            child: ListTile(
              title: const Text('알림 받기'),
              trailing: Switch(value: _masterEnabled, onChanged: _setMaster),
            ),
          ),
          const SizedBox(height: 8),
          ..._topics.map((e) {
            final enabled = _topicEnabled[e.topic] ?? true;
            return Material(
              color: Colors.white,
              child: ListTile(
                title: Text(e.label),
                trailing: Switch(
                  value: enabled,
                  onChanged: _masterEnabled
                      ? (value) => _setTopic(e.topic, value)
                      : null,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/article.dart';
import '../repository/article_repository.dart';
import '../repository/free_repository.dart';
import '../repository/job_repository.dart';
import '../repository/livelihood_repository.dart';
import '../repository/notice_repository.dart';
import '../services/fcm_service.dart';
import '../widgets/article_list_tile.dart';
import '../widgets/dashboard_style.dart';

/// 푸시 알림 목록 화면. SharedPreferences에 저장된 푸시를 article_list_tile 형태로 표시.
class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({
    super.key,
    required this.noticeRepository,
    required this.freeRepository,
    required this.jobRepository,
    required this.livelihoodRepository,
  });

  final NoticeRepository noticeRepository;
  final FreeRepository freeRepository;
  final JobRepository jobRepository;
  final LivelihoodRepository livelihoodRepository;

  @override
  State<NotificationListScreen> createState() => _NotificationListScreenState();
}

class _NotificationListScreenState extends State<NotificationListScreen> {
  List<({Article article, bool isRead})> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getString(keyPushNotificationList);
    List<({Article article, bool isRead})> items = [];
    if (jsonList != null && jsonList.isNotEmpty) {
      try {
        final list = jsonDecode(jsonList) as List<dynamic>;
        for (final e in list) {
          final map = e as Map<String, dynamic>;
          final articleMap = map['article'] as Map<String, dynamic>?;
          final isRead = map['isRead'] as bool? ?? false;
          if (articleMap != null) {
            try {
              items.add((article: Article.fromMap(articleMap), isRead: isRead));
            } catch (_) {}
          }
        }
        // 최신순 (리스트에 append 되므로 뒤가 최신)
        items = items.reversed.toList();
      } catch (_) {}
    }
    if (mounted) {
      setState(() {
        _items = items;
        _loading = false;
      });
    }
  }

  ArticleRepository _repositoryForType(String type) {
    switch (type) {
      case 'job':
        return widget.jobRepository;
      case 'livelihood':
        return widget.livelihoodRepository;
      case 'free':
        return widget.freeRepository;
      case 'notice':
      case 'weekschedule':
      default:
        return widget.noticeRepository;
    }
  }

  Future<void> _markAllRead() async {
    if (_items.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    // 저장 형식은 append 순서(오래된 것 먼저) 유지
    final updated = _items.reversed
        .map((e) => {'article': e.article.toMap(), 'isRead': true})
        .toList();
    await prefs.setString(keyPushNotificationList, jsonEncode(updated));
    if (mounted) {
      setState(() {
        _items = [for (final e in _items) (article: e.article, isRead: true)];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
        title: const Text('알림'),
        actions: [
          TextButton(
            onPressed: _items.isEmpty ? null : _markAllRead,
            child: const Text('모두 읽음'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: _items.isEmpty
                  ? const SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: 400,
                        child: Center(child: Text('알림이 없습니다.')),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        final entry = _items[index];
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Stack(
                              children: [
                                ArticleListTile(
                                  article: entry.article,
                                  repository: _repositoryForType(
                                    entry.article.type,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: Badge(
                                      backgroundColor: entry.isRead
                                          ? Colors.grey.shade400
                                          : tossBlue,
                                      label: Text(
                                        entry.isRead ? '읽음' : '읽지 않음',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (index < _items.length - 1)
                              Divider(height: 1, color: Colors.grey.shade300),
                          ],
                        );
                      },
                    ),
            ),
    );
  }
}

import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../models/article.dart';
import '../repository/article_repository.dart';
import '../repository/free_repository.dart';
import '../repository/job_repository.dart';
import '../repository/livelihood_repository.dart';
import '../repository/notice_repository.dart';
import '../repository/praise_repository.dart';
import '../screens/article_detail_screen.dart';
import '../services/fcm_service.dart';
import '../widgets/dashboard_style.dart';

/// 푸시 알림 목록 화면. SharedPreferences에 저장된 푸시를 article_list_tile 형태로 표시.
class NotificationListScreen extends StatefulWidget {
  const NotificationListScreen({
    super.key,
    required this.noticeRepository,
    required this.praiseRepository,
    required this.freeRepository,
    required this.jobRepository,
    required this.livelihoodRepository,
  });

  final NoticeRepository noticeRepository;
  final PraiseRepository praiseRepository;
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

  static const double _leadingSize = 56;
  static const _imageExtensions = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'};

  bool _isImageAttachment(Attachment a) {
    final ext = a.attachmentName.split('.').lastOrNull?.toLowerCase() ?? '';
    return _imageExtensions.contains(ext);
  }

  Widget _buildLeading(BuildContext context, Article article) {
    if (article.attachments.isNotEmpty) {
      final first = article.attachments.first;
      if (first.attachmentUrl.isNotEmpty && _isImageAttachment(first)) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            width: _leadingSize,
            height: _leadingSize,
            child: CachedNetworkImage(
              imageUrl: first.attachmentUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Colors.grey.shade200,
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
              errorWidget: (_, __, ___) => _leadingFallback(),
            ),
          ),
        );
      }
    }
    return _leadingFallback();
  }

  Widget _leadingFallback() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: _leadingSize,
        height: _leadingSize,
        child: Image.asset(
          'assets/icon/icon.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  ArticleRepository _repositoryForType(String type) {
    switch (type) {
      case 'job':
        return widget.jobRepository;
      case 'livelihood':
        return widget.livelihoodRepository;
      case 'free':
        return widget.freeRepository;
      case 'praise':
        return widget.praiseRepository;
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

  /// keyPushNotificationList 전체 삭제
  Future<void> _deleteAll() async {
    if (_items.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyPushNotificationList, '[]');
    if (mounted) {
      setState(() => _items = []);
    }
  }

  /// 해당 인덱스 알림 한 건 삭제
  Future<void> _deleteAt(int index) async {
    if (index < 0 || index >= _items.length) return;
    final newList = [..._items]..removeAt(index);
    final prefs = await SharedPreferences.getInstance();
    final updated = newList.reversed
        .map((e) => {'article': e.article.toMap(), 'isRead': e.isRead})
        .toList();
    await prefs.setString(keyPushNotificationList, jsonEncode(updated));
    if (mounted) {
      setState(() => _items = newList);
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
          TextButton(
            onPressed: _items.isEmpty ? null : _deleteAll,
            child: const Text('모두 삭제'),
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
                        final repository =
                            _repositoryForType(entry.article.type);
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Material(
                              color: Colors.white,
                              child: InkWell(
                                onTap: () {
                                  Navigator.of(context).push(
                                    SwipeablePageRoute<void>(
                                      builder: (_) => ArticleDetailScreen(
                                        articleSeq: entry.article.articleSeq,
                                        repository: repository,
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          _buildLeading(
                                            context,
                                            entry.article,
                                          ),
                                          Positioned(
                                            right: -4,
                                            bottom: -4,
                                            child: Container(
                                              padding: const EdgeInsets
                                                  .symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: entry.isRead
                                                    ? Colors.grey.shade400
                                                    : Colors.redAccent,
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                entry.isRead
                                                    ? '읽음'
                                                    : '읽지 않음',
                                                style: const TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              entry.article.title,
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                Text(
                                                  entry.article.author,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    height: 1.2,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  entry.article.registeredAt,
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    height: 1.2,
                                                    color: Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Colors.grey.shade600,
                                        ),
                                        onPressed: () => _deleteAt(index),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            if (index < _items.length - 1)
                              Divider(
                                height: 1,
                                color: Colors.grey.shade300,
                              ),
                          ],
                        );
                      },
                    ),
            ),
    );
  }
}

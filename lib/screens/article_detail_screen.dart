import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article.dart';
import '../repository/article_repository.dart';
import '../services/fcm_service.dart';
import '../widgets/dashboard_style.dart';

/// articleSeq만 전달받아 상세 조회 후 표시
class ArticleDetailScreen extends StatefulWidget {
  const ArticleDetailScreen({
    super.key,
    required this.articleSeq,
    required this.repository,
  });

  final String articleSeq;
  final ArticleRepository repository;

  @override
  State<ArticleDetailScreen> createState() => _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends State<ArticleDetailScreen> {
  Article? _article;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _markAsReadInPushNotificationList();
    _load();
  }

  Future<void> _markAsReadInPushNotificationList() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getString(keyPushNotificationList);
    if (jsonList == null || jsonList.isEmpty) return;

    try {
      final list = jsonDecode(jsonList) as List<dynamic>;
      var changed = false;

      for (var i = 0; i < list.length; i++) {
        final item = list[i];
        if (item is! Map<String, dynamic>) continue;

        final article = item['article'];
        final articleMap = article is Map<String, dynamic> ? article : null;
        if (articleMap == null) continue;

        final articleSeq = articleMap['articleSeq']?.toString();
        if (articleSeq == widget.articleSeq && (item['isRead'] as bool? ?? false) == false) {
          list[i] = {
            ...item,
            'isRead': true,
          };
          changed = true;
        }
      }

      if (changed) {
        await prefs.setString(keyPushNotificationList, jsonEncode(list));
      }
    } catch (_) {
      // push_notification_list 파싱 실패 시 읽음 처리만 건너뜀
    }
  }

  Future<void> _load() async {
    try {
      final article = await widget.repository.getByArticleSeq(
        widget.articleSeq,
      );
      if (mounted) {
        setState(() {
          _article = article;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  static String _resolveImageUrl(String src) {
    if (src.isEmpty) return src;
    if (src.startsWith('http://') || src.startsWith('https://')) return src;
    final base = 'https://www.inje.go.kr';
    return src.startsWith('/') ? '$base$src' : '$base/$src';
  }

  void _openPhotoView(BuildContext context, String imageUrl) {
    final resolved = _resolveImageUrl(imageUrl);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            title: const Text('이미지'),
          ),
          body: PhotoView(
            imageProvider: NetworkImage(resolved),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        backgroundColor: tossBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey.shade900,
          elevation: 0,
          title: Text(
            _article?.title ?? '',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade900,
            ),
          ),
        ),
        body: Center(
          child: CircularProgressIndicator(color: tossBlue),
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: tossBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey.shade900,
          elevation: 0,
          title: Text(
            _article?.title ?? '',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade900,
            ),
          ),
        ),
        body: Center(
          child: Text(
            _error!,
            style: TextStyle(fontSize: 14, color: tossGreyText),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    final article = _article;
    if (article == null) {
      return Scaffold(
        backgroundColor: tossBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey.shade900,
          elevation: 0,
          title: Text(
            "게시글을 찾을 수 없습니다.",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade900,
            ),
          ),
        ),
        body: Center(
          child: Text(
            '게시글을 찾을 수 없습니다.',
            style: TextStyle(fontSize: 14, color: tossGreyText),
          ),
        ),
      );
    }
    final hasUrl = article.url != null && article.url!.isNotEmpty;
    return Scaffold(
      backgroundColor: tossBackground,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.grey.shade900,
        elevation: 0,
        title: Text(
          article.title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
        actions: [
          if (hasUrl)
            TextButton(
              onPressed: () => _openUrl(article.url!),
              child: Text(
                '원본보기',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: tossBlue,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.title,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade900,
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          article.author,
                          style: TextStyle(
                            fontSize: 14,
                            color: tossGreyText,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          article.registeredAt,
                          style: TextStyle(
                            fontSize: 14,
                            color: tossGreyText,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade300),
              if (article.content.isNotEmpty)
                SelectionArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Html(
                      data: article.content,
                      style: {
                        'body': Style(
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                          fontSize: FontSize(15),
                          color: Colors.grey.shade800,
                          lineHeight: const LineHeight(1.5),
                        ),
                        'a': Style(
                          color: tossBlue,
                          textDecoration: TextDecoration.underline,
                        ),
                      },
                      onLinkTap: (url, _, __) {
                        if (url != null) _openUrl(url);
                      },
                      extensions: [
                        TagExtension(
                          tagsToExtend: {'img'},
                          builder: (ctx) {
                            final src = ctx.attributes['src'] ?? '';
                            if (src.isEmpty) return const SizedBox.shrink();
                            final resolved = _resolveImageUrl(src);
                            final buildContext = ctx.buildContext;
                            return GestureDetector(
                              onTap: buildContext != null
                                  ? () => _openPhotoView(buildContext, src)
                                  : null,
                              child: Image.network(
                                resolved,
                                fit: BoxFit.contain,
                                loadingBuilder: (_, child, progress) {
                                  if (progress == null) return child;
                                  return SizedBox(
                                    height: 120,
                                    child: Center(
                                      child: progress.expectedTotalBytes != null
                                          ? CircularProgressIndicator(
                                              value: progress.cumulativeBytesLoaded /
                                                  progress.expectedTotalBytes!,
                                              color: tossBlue,
                                            )
                                          : const CircularProgressIndicator(color: tossBlue),
                                    ),
                                  );
                                },
                                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                )
              else
                SelectionArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Text(
                      '내용 없음',
                      style: TextStyle(fontSize: 15, color: tossGreyText),
                    ),
                  ),
                ),
              if (article.attachments.isNotEmpty) ...[
                Divider(height: 1, color: Colors.grey.shade300),
                Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 8),
                  child: Text(
                    '첨부파일',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B365D),
                    ),
                  ),
                ),
                ...article.attachments.map(
                  (a) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          a.attachmentName,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        trailing: Icon(
                          Icons.download,
                          size: 22,
                          color: tossGreyText,
                        ),
                        onTap: () => _openUrl(a.attachmentUrl),
                      ),
                      Divider(height: 1, color: Colors.grey.shade200),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

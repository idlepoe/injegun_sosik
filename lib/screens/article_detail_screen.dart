import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article.dart';
import '../repository/notice_repository.dart';

/// articleSeq만 전달받아 상세 조회 후 표시
class ArticleDetailScreen extends StatefulWidget {
  const ArticleDetailScreen({
    super.key,
    required this.articleSeq,
    required this.repository,
  });

  final String articleSeq;
  final NoticeRepository repository;

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
    _load();
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

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('공지 상세')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('공지 상세')),
        body: Center(child: Text(_error!)),
      );
    }
    final article = _article;
    if (article == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('공지 상세')),
        body: const Center(child: Text('게시글을 찾을 수 없습니다.')),
      );
    }
    final hasUrl = article.url != null && article.url!.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('공지 상세'),
        actions: [
          if (hasUrl)
            TextButton(
              onPressed: () => _openUrl(article.url!),
              child: const Text('원본보기'),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  article.author,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
                const SizedBox(width: 12),
                Text(
                  article.registeredAt,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (article.content.isNotEmpty)
              Html(
                data: article.content,
                onLinkTap: (url, _, __) {
                  if (url != null) _openUrl(url);
                },
              )
            else
              const Text('내용 없음'),
            if (article.attachments.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                '첨부파일',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...article.attachments.map(
                (a) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(a.attachmentName),
                  trailing: const Icon(Icons.download),
                  onTap: () => _openUrl(a.attachmentUrl),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

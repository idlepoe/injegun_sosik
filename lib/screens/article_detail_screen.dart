import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/article.dart';
import '../repository/article_repository.dart';
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
        backgroundColor: tossBackground,
        appBar: AppBar(
          backgroundColor: Colors.white,
          foregroundColor: Colors.grey.shade900,
          elevation: 0,
          title: Text(
            '공지 상세',
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
            '공지 상세',
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
            '공지 상세',
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
          '공지 상세',
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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(tossCardRadius),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
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
              const SizedBox(height: 16),
              if (article.content.isNotEmpty)
                SelectionArea(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(tossCardRadius),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
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
                    ),
                  ),
                )
              else
                SelectionArea(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(tossCardRadius),
                    ),
                    child: Text(
                      '내용 없음',
                      style: TextStyle(fontSize: 15, color: tossGreyText),
                    ),
                  ),
                ),
              if (article.attachments.isNotEmpty) ...[
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 8),
                  child: Text(
                    '첨부파일',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1B365D),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(tossCardRadius),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: article.attachments.map(
                      (a) => ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
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
                    ).toList(),
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

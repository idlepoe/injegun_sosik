import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../models/article.dart';
import '../repository/article_repository.dart';
import '../screens/article_detail_screen.dart';

/// 게시글 목록용 타일 (articleSeq, 제목, 작성자, 등록일 표시, 탭 시 상세 이동)
class ArticleListTile extends StatelessWidget {
  const ArticleListTile({
    super.key,
    required this.article,
    required this.repository,
  });

  final Article article;
  final ArticleRepository repository;

  static const double _leadingSize = 56;

  static final _imageExtensions = {'jpg', 'jpeg', 'png', 'gif', 'webp', 'bmp'};

  bool _isImageAttachment(Attachment a) {
    final ext = a.attachmentName.split('.').lastOrNull?.toLowerCase() ?? '';
    return _imageExtensions.contains(ext);
  }

  Widget _buildLeading(BuildContext context) {
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
              errorWidget: (_, __, ___) => _leadingArticleSeqFallback(),
            ),
          ),
        );
      }
    }
    return _leadingArticleSeqFallback();
  }

  Widget _leadingArticleSeqFallback() {
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

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          SwipeablePageRoute<void>(
            builder: (_) => ArticleDetailScreen(
              articleSeq: article.articleSeq,
              repository: repository,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildLeading(context),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
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
                        article.author,
                        style: TextStyle(
                          fontSize: 11,
                          height: 1.2,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        article.registeredAt,
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
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/article.dart';
import 'dashboard_style.dart';

/// 대시보드 새 공지 타일 (탭 시 상세 이동)
class DashboardNoticeTile extends StatelessWidget {
  const DashboardNoticeTile({
    super.key,
    required this.article,
    required this.onTap,
  });

  final Article article;
  final VoidCallback onTap;

  static String _formatDateShort(String dateStr) {
    final d = DateTime.tryParse(dateStr);
    if (d == null) return dateStr;
    return DateFormat('M/d').format(d);
  }

  @override
  Widget build(BuildContext context) {
    final dateShort = _formatDateShort(article.registeredAt);
    final subtitle = '${article.author} | $dateShort';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.white,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    article.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: tossGreyText),
                  ),
                ],
              ),
            ),
          ),
        ),
        Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }
}

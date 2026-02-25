import 'package:flutter/material.dart';

import '../models/weekschedule_row.dart';
import 'dashboard_style.dart';

/// 대시보드 다가오는 행사 타일 (행사명 탭 시 상세 이동, 장소 탭 시 지도)
class DashboardWeekscheduleTile extends StatelessWidget {
  const DashboardWeekscheduleTile({
    super.key,
    required this.row,
    this.isToday = false,
    required this.onPlaceTap,
    this.onEventTap,
  });

  final WeekScheduleRow row;
  final bool isToday;
  final void Function(String place) onPlaceTap;

  /// articleSeq가 있을 때 행사명 탭 시 호출 (ArticleDetailScreen 이동용)
  final void Function(String articleSeq)? onEventTap;

  Widget _buildTitle() {
    final text = Text(
      row.eventContent,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade900,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final hasArticleSeq = row.articleSeq != null && row.articleSeq!.isNotEmpty;
    if (hasArticleSeq && onEventTap != null) {
      return GestureDetector(
        onTap: () => onEventTap!(row.articleSeq!),
        behavior: HitTestBehavior.opaque,
        child: text,
      );
    }
    return text;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Material(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    row.date,
                    style: TextStyle(
                      fontSize: 12,
                      color: isToday ? Colors.blue : tossGreyText,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: isToday ? Colors.blue : tossGreyText,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        row.time,
                        style: TextStyle(
                          fontSize: 12,
                          color: isToday ? Colors.blue : tossGreyText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              title: _buildTitle(),
              subtitle: GestureDetector(
                onTap: () => onPlaceTap(row.place),
                child: Row(
                  children: [
                    Icon(Icons.place, size: 13, color: tossGreyText),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        row.place,
                        style: const TextStyle(
                          color: Colors.blue,
                          decoration: TextDecoration.underline,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Divider(height: 1, color: Colors.grey.shade200),
      ],
    );
  }
}

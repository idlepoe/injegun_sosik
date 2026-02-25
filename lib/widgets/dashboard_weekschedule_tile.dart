import 'package:flutter/material.dart';

import '../models/weekschedule_row.dart';
import 'dashboard_style.dart';

/// 대시보드 다가오는 행사 타일. 타일 전체 탭 시 행사소식 목록 화면으로 이동.
class DashboardWeekscheduleTile extends StatelessWidget {
  const DashboardWeekscheduleTile({
    super.key,
    required this.row,
    this.isToday = false,
    required this.onTap,
  });

  final WeekScheduleRow row;
  final bool isToday;
  final VoidCallback onTap;

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
              onTap: onTap,
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
              title: Text(
                row.eventContent,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade900,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Row(
                children: [
                  Icon(Icons.place, size: 13, color: tossGreyText),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      row.place,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 11,
                      ),
                    ),
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

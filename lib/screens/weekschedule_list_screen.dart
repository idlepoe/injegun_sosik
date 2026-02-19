import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/weekschedule_list_bloc.dart';
import '../repository/weekschedule_repository.dart';

/// 행사소식: weekschedules 컬렉션 20개씩 리스트 (기본 위젯만)
class WeekscheduleListScreen extends StatelessWidget {
  const WeekscheduleListScreen({super.key, required this.repository});

  final WeekscheduleRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              WeekscheduleListBloc(repository)
                ..add(WeekscheduleListLoadRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('행사소식')),
        body: BlocBuilder<WeekscheduleListBloc, WeekscheduleListState>(
          builder: (context, state) {
            if (state is WeekscheduleListLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is WeekscheduleListFailure) {
              return Center(child: Text(state.message));
            }
            if (state is WeekscheduleListSuccess) {
              final items = state.items;
              return RefreshIndicator(
                onRefresh: () async {
                  context
                      .read<WeekscheduleListBloc>()
                      .add(WeekscheduleListLoadRequested());
                  // BLoC이 상태를 업데이트할 때까지 대기
                  await context.read<WeekscheduleListBloc>().stream.firstWhere(
                        (state) =>
                            state is! WeekscheduleListLoading &&
                            state is WeekscheduleListSuccess,
                      );
                },
                child: items.isEmpty
                    ? const SingleChildScrollView(
                        physics: AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: 400,
                          child: Center(child: Text('목록이 없습니다.')),
                        ),
                      )
                    : ListView.builder(
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final row = items[index];
                          // date를 mm/dd 형식으로 변환
                          String formattedDate = row.date;
                          DateTime? dateTime;
                          Color? dateColor;
                          bool isToday = false;

                          try {
                            // 다양한 날짜 형식 시도
                            if (row.date.contains('-')) {
                              dateTime = DateTime.tryParse(row.date);
                            } else if (row.date.contains('/')) {
                              final parts = row.date.split('/');
                              if (parts.length >= 2) {
                                final year = int.tryParse(parts[0]);
                                final month = int.tryParse(parts[1]);
                                final day =
                                    parts.length > 2 ? int.tryParse(parts[2]) : null;
                                if (year != null && month != null && day != null) {
                                  dateTime = DateTime(year, month, day);
                                } else if (year != null && month != null) {
                                  dateTime = DateTime(year, month, 1);
                                }
                              }
                            }
                            if (dateTime != null) {
                              formattedDate = DateFormat('MM/dd').format(dateTime);
                              // 오늘 날짜 확인
                              final now = DateTime.now();
                              isToday =
                                  dateTime.year == now.year &&
                                  dateTime.month == now.month &&
                                  dateTime.day == now.day;
                              // 요일 확인 (weekday: 1=월요일, 7=일요일)
                              final weekday = dateTime.weekday;
                              if (weekday == 6) {
                                // 토요일 - 파란색
                                dateColor = Colors.blue;
                              } else if (weekday == 7) {
                                // 일요일 - 빨간색
                                dateColor = Colors.red;
                              }
                            }
                          } catch (e) {
                            // 파싱 실패 시 원본 사용
                          }

                          return Container(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: isToday ? Colors.blue : Colors.grey.shade300,
                                width: isToday ? 3.0 : 1.0,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Stack(
                              children: [
                                ListTile(
                                  leading: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        formattedDate,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: dateColor,
                                        ),
                                      ),
                                      Text(
                                        row.time,
                                        style: Theme.of(context).textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                  title: Text(row.eventContent),
                                  subtitle: Text(row.place),
                                ),
                                if (isToday)
                                  Positioned(
                                    top: 0,
                                    left: 0,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.blue,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        '오늘',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

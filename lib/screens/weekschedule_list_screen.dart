import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:url_launcher/url_launcher.dart';

import '../bloc/weekschedule_list_bloc.dart';
import '../models/weekschedule_row.dart';
import '../repository/weekschedule_repository.dart';
import '../utils/map_launcher.dart';

/// 행사소식: weekschedules 컬렉션을 TableCalendar + 리스트로 표시
class WeekscheduleListScreen extends StatefulWidget {
  const WeekscheduleListScreen({super.key, required this.repository});

  final WeekscheduleRepository repository;

  @override
  State<WeekscheduleListScreen> createState() => _WeekscheduleListScreenState();
}

class _WeekscheduleListScreenState extends State<WeekscheduleListScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();

  List<WeekScheduleRow> _getEventsForDay(
    DateTime day,
    List<WeekScheduleRow> items,
  ) {
    return items.where((row) {
      final parsed = DateTime.tryParse(row.date);
      if (parsed == null) return false;
      return parsed.year == day.year &&
          parsed.month == day.month &&
          parsed.day == day.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          WeekscheduleListBloc(widget.repository)
            ..add(WeekscheduleListLoadRequested()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('행사소식'),
          actions: [
            TextButton(
              onPressed: () async {
                final uri = Uri.parse(
                  'https://www.inje.go.kr/portal/inje-news/event/weekschedule',
                );
                await launchUrl(uri, mode: LaunchMode.externalApplication);
              },
              child: const Text('원본보기'),
            ),
          ],
        ),
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

              // firstDay: 오늘 기준 3개월 전, lastDay: 마지막 이벤트로부터 1개월 뒤
              final now = DateTime.now();
              final firstDay = DateTime(now.year, now.month - 3, 1);

              DateTime? lastEventDate;
              for (final row in items) {
                final parsed = DateTime.tryParse(row.date);
                if (parsed == null) continue;
                if (lastEventDate == null || parsed.isAfter(lastEventDate)) {
                  lastEventDate = parsed;
                }
              }
              var lastDayBase = lastEventDate ?? now;
              var lastDay = DateTime(
                lastDayBase.year,
                lastDayBase.month + 1,
                lastDayBase.day,
              );

              if (lastDay.isBefore(firstDay)) {
                lastDay = DateTime(
                  firstDay.year,
                  firstDay.month + 1,
                  firstDay.day,
                );
              }

              // TableCalendar 제약: focusedDay/selectedDay 는 범위 안이어야 함
              var focusedDay = _focusedDay;
              if (focusedDay.isBefore(firstDay) ||
                  focusedDay.isAfter(lastDay)) {
                focusedDay = firstDay;
              }
              var selectedDay = _selectedDay;
              if (selectedDay.isBefore(firstDay) ||
                  selectedDay.isAfter(lastDay)) {
                selectedDay = focusedDay;
              }

              final selectedEvents = _getEventsForDay(selectedDay, items);

              return Column(
                children: [
                  TableCalendar<WeekScheduleRow>(
                    firstDay: firstDay,
                    lastDay: lastDay,
                    focusedDay: focusedDay,
                    calendarFormat: _calendarFormat,
                    daysOfWeekHeight: 30,
                    locale: 'ko_KR',
                    selectedDayPredicate: (day) => isSameDay(selectedDay, day),
                    onDaySelected: (selectedDay, focusedDay) {
                      setState(() {
                        _selectedDay = selectedDay;
                        _focusedDay = focusedDay;
                      });
                    },
                    onFormatChanged: (format) {
                      setState(() {
                        _calendarFormat = format;
                      });
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                    eventLoader: (day) => _getEventsForDay(day, items),
                    headerStyle: const HeaderStyle(formatButtonVisible: false),
                    calendarStyle: CalendarStyle(
                      todayDecoration: BoxDecoration(
                        border: Border.all(color: Colors.blue, width: 2.0),
                        shape: BoxShape.rectangle,
                        color: Colors.blue.withOpacity(0.8),
                      ),
                      selectedDecoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.blue.withOpacity(0.5),
                      ),
                    ),
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, day, events) {
                        if (events.isEmpty) return null;
                        const markerColors = [
                          Colors.blue,
                          Colors.orange,
                          Colors.green,
                          Colors.purple,
                          Colors.teal,
                        ];
                        return Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            events.length > 5 ? 5 : events.length,
                            (index) => Container(
                              width: 6,
                              height: 6,
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color:
                                    markerColors[index % markerColors.length],
                              ),
                            ),
                          ),
                        );
                      },
                      dowBuilder: (context, day) {
                        final weekday = day.weekday;
                        Color textColor;
                        if (weekday == DateTime.saturday) {
                          textColor = Colors.blue;
                        } else if (weekday == DateTime.sunday) {
                          textColor = Colors.red;
                        } else {
                          textColor = Colors.black;
                        }
                        return Center(
                          child: Text(
                            DateFormat.E('ko_KR').format(day),
                            style: TextStyle(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  Expanded(
                    child: selectedEvents.isEmpty
                        ? const Center(child: Text('해당 날짜의 일정이 없습니다.'))
                        : ListView.separated(
                            itemCount: selectedEvents.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final row = selectedEvents[index];
                              return ListTile(
                                leading: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.access_time, size: 16),
                                    const SizedBox(width: 4),
                                    Text(row.time),
                                  ],
                                ),
                                title: Text(
                                  row.eventContent,
                                  style: const TextStyle(fontSize: 12),
                                ),
                                subtitle: GestureDetector(
                                  onTap: () => openNaverMap(row.place),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.place, size: 16),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          row.place,
                                          style: const TextStyle(
                                            color: Colors.blue,
                                            fontSize: 11,
                                            decoration:
                                                TextDecoration.underline,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

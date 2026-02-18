import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/weekschedule_list_bloc.dart';
import '../repository/weekschedule_repository.dart';

/// 행사소식: weekschedules 컬렉션 20개씩 리스트 (기본 위젯만)
class WeekscheduleListScreen extends StatelessWidget {
  const WeekscheduleListScreen({
    super.key,
    required this.repository,
  });

  final WeekscheduleRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          WeekscheduleListBloc(repository)..add(WeekscheduleListLoadRequested()),
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
              if (items.isEmpty) {
                return const Center(child: Text('목록이 없습니다.'));
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final row = items[index];
                  return ListTile(
                    title: Text(row.eventContent),
                    subtitle: Text('${row.date} ${row.time} ${row.place}'),
                  );
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

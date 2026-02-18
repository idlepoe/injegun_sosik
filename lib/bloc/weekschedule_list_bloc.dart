import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/weekschedule_row.dart';
import '../repository/weekschedule_repository.dart';

// Event
sealed class WeekscheduleListEvent {}

final class WeekscheduleListLoadRequested extends WeekscheduleListEvent {}

// State
sealed class WeekscheduleListState {}

final class WeekscheduleListInitial extends WeekscheduleListState {}

final class WeekscheduleListLoading extends WeekscheduleListState {}

final class WeekscheduleListSuccess extends WeekscheduleListState {
  WeekscheduleListSuccess(this.items);
  final List<WeekScheduleRow> items;
}

final class WeekscheduleListFailure extends WeekscheduleListState {
  WeekscheduleListFailure(this.message);
  final String message;
}

// Bloc
class WeekscheduleListBloc
    extends Bloc<WeekscheduleListEvent, WeekscheduleListState> {
  WeekscheduleListBloc(this._repository) : super(WeekscheduleListInitial()) {
    on<WeekscheduleListLoadRequested>(_onLoadRequested);
  }

  final WeekscheduleRepository _repository;

  Future<void> _onLoadRequested(
    WeekscheduleListLoadRequested event,
    Emitter<WeekscheduleListState> emit,
  ) async {
    emit(WeekscheduleListLoading());
    try {
      final items = await _repository.getPage(pageSize: 20);
      emit(WeekscheduleListSuccess(items));
    } catch (e) {
      emit(WeekscheduleListFailure(e.toString()));
    }
  }
}

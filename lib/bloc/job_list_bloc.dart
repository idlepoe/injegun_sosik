import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/article.dart';
import '../repository/job_repository.dart';

// Event
sealed class JobListEvent {}

/// 초기 로드 또는 당겨서 새로고침
final class JobListLoadRequested extends JobListEvent {}

/// 하단 스크롤 시 추가 로드
final class JobListLoadMoreRequested extends JobListEvent {}

// State
sealed class JobListState {}

final class JobListInitial extends JobListState {}

final class JobListLoading extends JobListState {}

final class JobListSuccess extends JobListState {
  JobListSuccess(this.items, this.lastDoc, this.hasMore);
  final List<Article> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  final bool hasMore;
}

/// 추가 로드 중 (리스트는 유지, 하단 인디케이터 표시)
final class JobListLoadingMore extends JobListState {
  JobListLoadingMore(this.items);
  final List<Article> items;
}

final class JobListFailure extends JobListState {
  JobListFailure(this.message);
  final String message;
}

const int _pageSize = 20;

class JobListBloc extends Bloc<JobListEvent, JobListState> {
  JobListBloc(this._repository) : super(JobListInitial()) {
    on<JobListLoadRequested>(_onLoadRequested);
    on<JobListLoadMoreRequested>(_onLoadMoreRequested);
  }

  final JobRepository _repository;

  Future<void> _onLoadRequested(
    JobListLoadRequested event,
    Emitter<JobListState> emit,
  ) async {
    emit(JobListLoading());
    try {
      final result = await _repository.getPage(pageSize: _pageSize);
      final hasMore = result.items.length >= _pageSize;
      emit(JobListSuccess(result.items, result.lastDoc, hasMore));
    } catch (e) {
      emit(JobListFailure(e.toString()));
    }
  }

  Future<void> _onLoadMoreRequested(
    JobListLoadMoreRequested event,
    Emitter<JobListState> emit,
  ) async {
    final current = state;
    if (current is! JobListSuccess ||
        !current.hasMore ||
        current.lastDoc == null) {
      return;
    }
    emit(JobListLoadingMore(current.items));
    try {
      final result = await _repository.getPage(
        pageSize: _pageSize,
        startAfter: current.lastDoc,
      );
      final newItems = [...current.items, ...result.items];
      final newHasMore = result.items.length >= _pageSize;
      emit(JobListSuccess(newItems, result.lastDoc, newHasMore));
    } catch (e) {
      emit(JobListFailure(e.toString()));
    }
  }
}

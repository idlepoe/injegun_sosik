import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/article.dart';
import '../repository/notice_repository.dart';

// Event
sealed class NoticeListEvent {}

/// 초기 로드 또는 당겨서 새로고침
final class NoticeListLoadRequested extends NoticeListEvent {}

/// 하단 스크롤 시 추가 로드
final class NoticeListLoadMoreRequested extends NoticeListEvent {}

// State
sealed class NoticeListState {}

final class NoticeListInitial extends NoticeListState {}

final class NoticeListLoading extends NoticeListState {}

final class NoticeListSuccess extends NoticeListState {
  NoticeListSuccess(this.items, this.lastDoc, this.hasMore);
  final List<Article> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  final bool hasMore;
}

/// 추가 로드 중 (리스트는 유지, 하단 인디케이터 표시)
final class NoticeListLoadingMore extends NoticeListState {
  NoticeListLoadingMore(this.items);
  final List<Article> items;
}

final class NoticeListFailure extends NoticeListState {
  NoticeListFailure(this.message);
  final String message;
}

const int _pageSize = 20;

class NoticeListBloc extends Bloc<NoticeListEvent, NoticeListState> {
  NoticeListBloc(this._repository) : super(NoticeListInitial()) {
    on<NoticeListLoadRequested>(_onLoadRequested);
    on<NoticeListLoadMoreRequested>(_onLoadMoreRequested);
  }

  final NoticeRepository _repository;

  Future<void> _onLoadRequested(
    NoticeListLoadRequested event,
    Emitter<NoticeListState> emit,
  ) async {
    emit(NoticeListLoading());
    try {
      final result = await _repository.getPage(pageSize: _pageSize);
      final hasMore = result.items.length >= _pageSize;
      emit(NoticeListSuccess(result.items, result.lastDoc, hasMore));
    } catch (e) {
      emit(NoticeListFailure(e.toString()));
    }
  }

  Future<void> _onLoadMoreRequested(
    NoticeListLoadMoreRequested event,
    Emitter<NoticeListState> emit,
  ) async {
    final current = state;
    if (current is! NoticeListSuccess ||
        !current.hasMore ||
        current.lastDoc == null) {
      return;
    }
    emit(NoticeListLoadingMore(current.items));
    try {
      final result = await _repository.getPage(
        pageSize: _pageSize,
        startAfter: current.lastDoc,
      );
      final newItems = [...current.items, ...result.items];
      final newHasMore = result.items.length >= _pageSize;
      emit(NoticeListSuccess(newItems, result.lastDoc, newHasMore));
    } catch (e) {
      emit(NoticeListFailure(e.toString()));
    }
  }
}

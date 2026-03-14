import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/article.dart';
import '../repository/praise_repository.dart';

// Event
sealed class PraiseListEvent {}

/// 초기 로드 또는 당겨서 새로고침
final class PraiseListLoadRequested extends PraiseListEvent {}

/// 하단 스크롤 시 추가 로드
final class PraiseListLoadMoreRequested extends PraiseListEvent {}

// State
sealed class PraiseListState {}

final class PraiseListInitial extends PraiseListState {}

final class PraiseListLoading extends PraiseListState {}

final class PraiseListSuccess extends PraiseListState {
  PraiseListSuccess(this.items, this.lastDoc, this.hasMore);
  final List<Article> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  final bool hasMore;
}

/// 추가 로드 중 (리스트는 유지, 하단 인디케이터 표시)
final class PraiseListLoadingMore extends PraiseListState {
  PraiseListLoadingMore(this.items);
  final List<Article> items;
}

final class PraiseListFailure extends PraiseListState {
  PraiseListFailure(this.message);
  final String message;
}

const int _pageSize = 20;

class PraiseListBloc extends Bloc<PraiseListEvent, PraiseListState> {
  PraiseListBloc(this._repository) : super(PraiseListInitial()) {
    on<PraiseListLoadRequested>(_onLoadRequested);
    on<PraiseListLoadMoreRequested>(_onLoadMoreRequested);
  }

  final PraiseRepository _repository;

  Future<void> _onLoadRequested(
    PraiseListLoadRequested event,
    Emitter<PraiseListState> emit,
  ) async {
    emit(PraiseListLoading());
    try {
      final result = await _repository.getPage(pageSize: _pageSize);
      final hasMore = result.items.length >= _pageSize;
      emit(PraiseListSuccess(result.items, result.lastDoc, hasMore));
    } catch (e) {
      emit(PraiseListFailure(e.toString()));
    }
  }

  Future<void> _onLoadMoreRequested(
    PraiseListLoadMoreRequested event,
    Emitter<PraiseListState> emit,
  ) async {
    final current = state;
    if (current is! PraiseListSuccess ||
        !current.hasMore ||
        current.lastDoc == null) {
      return;
    }
    emit(PraiseListLoadingMore(current.items));
    try {
      final result = await _repository.getPage(
        pageSize: _pageSize,
        startAfter: current.lastDoc,
      );
      final newItems = [...current.items, ...result.items];
      final newHasMore = result.items.length >= _pageSize;
      emit(PraiseListSuccess(newItems, result.lastDoc, newHasMore));
    } catch (e) {
      emit(PraiseListFailure(e.toString()));
    }
  }
}

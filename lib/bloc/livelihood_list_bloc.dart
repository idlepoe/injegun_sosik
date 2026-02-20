import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/article.dart';
import '../repository/livelihood_repository.dart';

// Event
sealed class LivelihoodListEvent {}

/// 초기 로드 또는 당겨서 새로고침
final class LivelihoodListLoadRequested extends LivelihoodListEvent {}

/// 하단 스크롤 시 추가 로드
final class LivelihoodListLoadMoreRequested extends LivelihoodListEvent {}

// State
sealed class LivelihoodListState {}

final class LivelihoodListInitial extends LivelihoodListState {}

final class LivelihoodListLoading extends LivelihoodListState {}

final class LivelihoodListSuccess extends LivelihoodListState {
  LivelihoodListSuccess(this.items, this.lastDoc, this.hasMore);
  final List<Article> items;
  final DocumentSnapshot<Map<String, dynamic>>? lastDoc;
  final bool hasMore;
}

/// 추가 로드 중 (리스트는 유지, 하단 인디케이터 표시)
final class LivelihoodListLoadingMore extends LivelihoodListState {
  LivelihoodListLoadingMore(this.items);
  final List<Article> items;
}

final class LivelihoodListFailure extends LivelihoodListState {
  LivelihoodListFailure(this.message);
  final String message;
}

const int _pageSize = 20;

class LivelihoodListBloc extends Bloc<LivelihoodListEvent, LivelihoodListState> {
  LivelihoodListBloc(this._repository) : super(LivelihoodListInitial()) {
    on<LivelihoodListLoadRequested>(_onLoadRequested);
    on<LivelihoodListLoadMoreRequested>(_onLoadMoreRequested);
  }

  final LivelihoodRepository _repository;

  Future<void> _onLoadRequested(
    LivelihoodListLoadRequested event,
    Emitter<LivelihoodListState> emit,
  ) async {
    emit(LivelihoodListLoading());
    try {
      final result = await _repository.getPage(pageSize: _pageSize);
      final hasMore = result.items.length >= _pageSize;
      emit(LivelihoodListSuccess(result.items, result.lastDoc, hasMore));
    } catch (e) {
      emit(LivelihoodListFailure(e.toString()));
    }
  }

  Future<void> _onLoadMoreRequested(
    LivelihoodListLoadMoreRequested event,
    Emitter<LivelihoodListState> emit,
  ) async {
    final current = state;
    if (current is! LivelihoodListSuccess ||
        !current.hasMore ||
        current.lastDoc == null) {
      return;
    }
    emit(LivelihoodListLoadingMore(current.items));
    try {
      final result = await _repository.getPage(
        pageSize: _pageSize,
        startAfter: current.lastDoc,
      );
      final newItems = [...current.items, ...result.items];
      final newHasMore = result.items.length >= _pageSize;
      emit(LivelihoodListSuccess(newItems, result.lastDoc, newHasMore));
    } catch (e) {
      emit(LivelihoodListFailure(e.toString()));
    }
  }
}

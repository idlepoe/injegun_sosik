import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/newsletter.dart';
import '../repository/newsletter_repository.dart';

// Event
sealed class NewsletterListEvent {}

final class NewsletterListLoadRequested extends NewsletterListEvent {}

// State
sealed class NewsletterListState {}

final class NewsletterListInitial extends NewsletterListState {}

final class NewsletterListLoading extends NewsletterListState {}

final class NewsletterListSuccess extends NewsletterListState {
  NewsletterListSuccess(this.items);
  final List<Newsletter> items;
}

final class NewsletterListFailure extends NewsletterListState {
  NewsletterListFailure(this.message);
  final String message;
}

// Bloc
class NewsletterListBloc
    extends Bloc<NewsletterListEvent, NewsletterListState> {
  NewsletterListBloc(this._repository) : super(NewsletterListInitial()) {
    on<NewsletterListLoadRequested>(_onLoadRequested);
  }

  final NewsletterRepository _repository;

  Future<void> _onLoadRequested(
    NewsletterListLoadRequested event,
    Emitter<NewsletterListState> emit,
  ) async {
    emit(NewsletterListLoading());
    try {
      final items = await _repository.getPage(pageSize: 20);
      emit(NewsletterListSuccess(items));
    } catch (e) {
      emit(NewsletterListFailure(e.toString()));
    }
  }
}

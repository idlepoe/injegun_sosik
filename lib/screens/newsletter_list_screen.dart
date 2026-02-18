import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/newsletter_list_bloc.dart';
import '../repository/newsletter_repository.dart';

/// 합강소식지: newsletters 컬렉션 20개씩 리스트 (기본 위젯만)
class NewsletterListScreen extends StatelessWidget {
  const NewsletterListScreen({super.key, required this.repository});

  final NewsletterRepository repository;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          NewsletterListBloc(repository)..add(NewsletterListLoadRequested()),
      child: Scaffold(
        appBar: AppBar(title: const Text('합강소식지')),
        body: BlocBuilder<NewsletterListBloc, NewsletterListState>(
          builder: (context, state) {
            if (state is NewsletterListLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is NewsletterListFailure) {
              return Center(child: Text(state.message));
            }
            if (state is NewsletterListSuccess) {
              final items = state.items;
              if (items.isEmpty) {
                return const Center(child: Text('목록이 없습니다.'));
              }
              return ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final newsletter = items[index];
                  return ListTile(
                    title: Text(newsletter.title),
                    subtitle: Text(newsletter.articleSeq),
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

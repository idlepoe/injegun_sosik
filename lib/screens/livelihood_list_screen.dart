import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/livelihood_list_bloc.dart';
import '../models/article.dart';
import '../repository/livelihood_repository.dart';
import '../widgets/article_list_tile.dart';

/// 생활장터: articles 컬렉션 type==livelihood, Container 리스트, RefreshIndicator, 하단 페이징
class LivelihoodListScreen extends StatefulWidget {
  const LivelihoodListScreen({super.key, required this.repository});

  final LivelihoodRepository repository;

  @override
  State<LivelihoodListScreen> createState() => _LivelihoodListScreenState();
}

class _LivelihoodListScreenState extends State<LivelihoodListScreen> {
  final ScrollController _scrollController = ScrollController();
  static const double _loadMoreThreshold = 200;
  LivelihoodListBloc? _bloc;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final bloc = _bloc;
    if (bloc == null) return;
    final state = bloc.state;
    if (state is! LivelihoodListSuccess && state is! LivelihoodListLoadingMore) return;
    final success = state is LivelihoodListSuccess ? state : null;
    if (success == null || !success.hasMore) return;
    if (state is LivelihoodListLoadingMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      bloc.add(LivelihoodListLoadMoreRequested());
    }
  }

  Future<void> _onRefresh() async {
    _bloc?.add(LivelihoodListLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = LivelihoodListBloc(widget.repository)..add(LivelihoodListLoadRequested());
        _bloc = bloc;
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('생활장터')),
        body: BlocConsumer<LivelihoodListBloc, LivelihoodListState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is LivelihoodListLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is LivelihoodListFailure) {
              return Center(child: Text(state.message));
            }
            final items = state is LivelihoodListSuccess
                ? state.items
                : state is LivelihoodListLoadingMore
                    ? state.items
                    : <Article>[];
            final isLoadingMore = state is LivelihoodListLoadingMore;

            if (items.isEmpty) {
              return const Center(child: Text('목록이 없습니다.'));
            }

            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: items.length + (isLoadingMore ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == items.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  final article = items[index];
                  return ArticleListTile(
                    article: article,
                    repository: widget.repository,
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

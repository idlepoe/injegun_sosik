import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/free_list_bloc.dart';
import '../models/article.dart';
import '../repository/free_repository.dart';
import '../widgets/article_list_tile.dart';

/// 자유게시판: articles 컬렉션 type==free, Container 리스트, RefreshIndicator, 하단 페이징
class FreeListScreen extends StatefulWidget {
  const FreeListScreen({super.key, required this.repository});

  final FreeRepository repository;

  @override
  State<FreeListScreen> createState() => _FreeListScreenState();
}

class _FreeListScreenState extends State<FreeListScreen> {
  final ScrollController _scrollController = ScrollController();
  static const double _loadMoreThreshold = 200;
  FreeListBloc? _bloc;

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
    if (state is! FreeListSuccess && state is! FreeListLoadingMore) return;
    final success = state is FreeListSuccess ? state : null;
    if (success == null || !success.hasMore) return;
    if (state is FreeListLoadingMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      bloc.add(FreeListLoadMoreRequested());
    }
  }

  Future<void> _onRefresh() async {
    _bloc?.add(FreeListLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = FreeListBloc(widget.repository)..add(FreeListLoadRequested());
        _bloc = bloc;
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('자유게시판')),
        body: BlocConsumer<FreeListBloc, FreeListState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is FreeListLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is FreeListFailure) {
              return Center(child: Text(state.message));
            }
            final items = state is FreeListSuccess
                ? state.items
                : state is FreeListLoadingMore
                    ? state.items
                    : <Article>[];
            final isLoadingMore = state is FreeListLoadingMore;

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

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../bloc/notice_list_bloc.dart';
import '../models/article.dart';
import '../repository/notice_repository.dart';
import 'article_detail_screen.dart';

/// 공지사항: articles 컬렉션 type==notice, Container 리스트, RefreshIndicator, 하단 페이징
class NoticeListScreen extends StatefulWidget {
  const NoticeListScreen({super.key, required this.repository});

  final NoticeRepository repository;

  @override
  State<NoticeListScreen> createState() => _NoticeListScreenState();
}

class _NoticeListScreenState extends State<NoticeListScreen> {
  final ScrollController _scrollController = ScrollController();
  static const double _loadMoreThreshold = 200;
  NoticeListBloc? _bloc;

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
    if (state is! NoticeListSuccess && state is! NoticeListLoadingMore) return;
    final success = state is NoticeListSuccess ? state : null;
    if (success == null || !success.hasMore) return;
    if (state is NoticeListLoadingMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      bloc.add(NoticeListLoadMoreRequested());
    }
  }

  Future<void> _onRefresh() async {
    _bloc?.add(NoticeListLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = NoticeListBloc(widget.repository)..add(NoticeListLoadRequested());
        _bloc = bloc;
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('공지사항')),
        body: BlocConsumer<NoticeListBloc, NoticeListState>(
          listener: (context, state) {},
          builder: (context, state) {
            if (state is NoticeListLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state is NoticeListFailure) {
              return Center(child: Text(state.message));
            }
            final items = state is NoticeListSuccess
                ? state.items
                : state is NoticeListLoadingMore
                    ? state.items
                    : <Article>[];
            final isLoadingMore = state is NoticeListLoadingMore;

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
                  return _NoticeItem(
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

class _NoticeItem extends StatelessWidget {
  const _NoticeItem({
    required this.article,
    required this.repository,
  });

  final Article article;
  final NoticeRepository repository;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(
          SwipeablePageRoute<void>(
            builder: (_) => ArticleDetailScreen(
              articleSeq: article.articleSeq,
              repository: repository,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              article.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  article.author,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  article.registeredAt,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

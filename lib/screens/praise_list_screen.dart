import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/praise_list_bloc.dart';
import '../models/article.dart';
import '../repository/praise_repository.dart';
import '../services/fcm_service.dart';
import '../widgets/article_list_tile.dart';
import '../widgets/empty_list_with_refresh.dart';

/// 칭찬합니다: articles 컬렉션 type==praise, Container 리스트, RefreshIndicator, 하단 페이징
class PraiseListScreen extends StatefulWidget {
  const PraiseListScreen({super.key, required this.repository});

  final PraiseRepository repository;

  @override
  State<PraiseListScreen> createState() => _PraiseListScreenState();
}

class _PraiseListScreenState extends State<PraiseListScreen> {
  final ScrollController _scrollController = ScrollController();
  static const double _loadMoreThreshold = 200;
  PraiseListBloc? _bloc;
  bool _praiseEnabled = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadPraisePreference();
  }

  Future<void> _loadPraisePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('topic_praise') ?? true;
    if (mounted) setState(() => _praiseEnabled = enabled);
  }

  Future<void> _togglePraise() async {
    final next = !_praiseEnabled;
    setState(() => _praiseEnabled = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('topic_praise', next);
    final fcm = FcmService();
    if (next) {
      await fcm.subscribeToTopic('praise');
    } else {
      await fcm.unsubscribeFromTopic('praise');
    }
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
    if (state is! PraiseListSuccess && state is! PraiseListLoadingMore) return;
    final success = state is PraiseListSuccess ? state : null;
    if (success == null || !success.hasMore) return;
    if (state is PraiseListLoadingMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      bloc.add(PraiseListLoadMoreRequested());
    }
  }

  Future<void> _onRefresh() async {
    _bloc?.add(PraiseListLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = PraiseListBloc(widget.repository)
          ..add(PraiseListLoadRequested());
        _bloc = bloc;
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('칭찬합니다'),
          actions: [
            IconButton(
              icon: Icon(
                _praiseEnabled ? Icons.notifications : Icons.notifications_off,
                color: _praiseEnabled ? null : Colors.grey,
              ),
              tooltip: _praiseEnabled ? '알림 받기 끄기' : '알림 받기',
              onPressed: _togglePraise,
            ),
          ],
        ),
        body: SafeArea(
          child: BlocConsumer<PraiseListBloc, PraiseListState>(
            listener: (context, state) {},
            builder: (context, state) {
              if (state is PraiseListLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is PraiseListFailure) {
                return Center(child: Text(state.message));
              }
              final items = state is PraiseListSuccess
                  ? state.items
                  : state is PraiseListLoadingMore
                  ? state.items
                  : <Article>[];
              final isLoadingMore = state is PraiseListLoadingMore;

              if (items.isEmpty) {
                return EmptyListWithRefresh(onRefresh: _onRefresh);
              }

              return RefreshIndicator(
                onRefresh: _onRefresh,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  itemCount: items.length + (isLoadingMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == items.length) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    final article = items[index];
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ArticleListTile(
                          article: article,
                          repository: widget.repository,
                        ),
                        if (index < items.length - 1)
                          Divider(height: 1, color: Colors.grey.shade300),
                      ],
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

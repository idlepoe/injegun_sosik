import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../bloc/job_list_bloc.dart';
import '../models/article.dart';
import '../repository/job_repository.dart';
import '../services/fcm_service.dart';
import '../widgets/article_list_tile.dart';
import '../widgets/empty_list_with_refresh.dart';

/// 구인구직: articles 컬렉션 type==job, Container 리스트, RefreshIndicator, 하단 페이징
class JobListScreen extends StatefulWidget {
  const JobListScreen({super.key, required this.repository});

  final JobRepository repository;

  @override
  State<JobListScreen> createState() => _JobListScreenState();
}

class _JobListScreenState extends State<JobListScreen> {
  final ScrollController _scrollController = ScrollController();
  static const double _loadMoreThreshold = 200;
  JobListBloc? _bloc;
  bool _noticeEnabled = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadNoticePreference();
  }

  Future<void> _loadNoticePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('topic_job') ?? true;
    if (mounted) setState(() => _noticeEnabled = enabled);
  }

  Future<void> _toggleNotice() async {
    final next = !_noticeEnabled;
    setState(() => _noticeEnabled = next);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('topic_job', next);
    final fcm = FcmService();
    if (next) {
      await fcm.subscribeToTopic('job');
    } else {
      await fcm.unsubscribeFromTopic('job');
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
    if (state is! JobListSuccess && state is! JobListLoadingMore) return;
    final success = state is JobListSuccess ? state : null;
    if (success == null || !success.hasMore) return;
    if (state is JobListLoadingMore) return;
    final position = _scrollController.position;
    if (position.pixels >= position.maxScrollExtent - _loadMoreThreshold) {
      bloc.add(JobListLoadMoreRequested());
    }
  }

  Future<void> _onRefresh() async {
    _bloc?.add(JobListLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        final bloc = JobListBloc(widget.repository)
          ..add(JobListLoadRequested());
        _bloc = bloc;
        return bloc;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('구인구직'),
          actions: [
            IconButton(
              icon: Icon(
                _noticeEnabled ? Icons.notifications : Icons.notifications_off,
                color: _noticeEnabled ? null : Colors.grey,
              ),
              tooltip: _noticeEnabled ? '알림 받기 끄기' : '알림 받기',
              onPressed: _toggleNotice,
            ),
          ],
        ),
        body: SafeArea(
          child: BlocConsumer<JobListBloc, JobListState>(
            listener: (context, state) {},
            builder: (context, state) {
              if (state is JobListLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              if (state is JobListFailure) {
                return Center(child: Text(state.message));
              }
              final items = state is JobListSuccess
                  ? state.items
                  : state is JobListLoadingMore
                  ? state.items
                  : <Article>[];
              final isLoadingMore = state is JobListLoadingMore;

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

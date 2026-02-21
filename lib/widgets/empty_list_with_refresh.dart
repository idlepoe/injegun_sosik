import 'package:flutter/material.dart';

/// 빈 목록일 때 당겨서 새로고침 가능한 영역.
/// 리스트 화면(free/job/livelihood/notice 등)에서 items.isEmpty일 때 공통 사용.
class EmptyListWithRefresh extends StatelessWidget {
  const EmptyListWithRefresh({
    super.key,
    required this.onRefresh,
    this.message = '목록이 없습니다.',
  });

  final Future<void> Function() onRefresh;
  final String message;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height - 200,
          ),
          child: Center(child: Text(message)),
        ),
      ),
    );
  }
}

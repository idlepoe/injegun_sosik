import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../bloc/newsletter_list_bloc.dart';
import '../repository/newsletter_repository.dart';
import 'pdf_viewer_screen.dart';

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
              return GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                  childAspectRatio: 0.55,
                ),
                padding: const EdgeInsets.all(0),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final newsletter = items[index];
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: InkWell(
                      onTap: newsletter.pdfStorageUrl != null
                          ? () {
                              Navigator.of(context).push(
                                SwipeablePageRoute(
                                  builder: (_) => PdfViewerScreen(
                                    pdfUrl: newsletter.pdfStorageUrl!,
                                    title: newsletter.title,
                                  ),
                                ),
                              );
                            }
                          : null,
                      borderRadius: BorderRadius.circular(4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            child: newsletter.thumbnailUrl != null
                                ? CachedNetworkImage(
                                    imageUrl: newsletter.thumbnailUrl!,
                                    httpHeaders: const {
                                      'User-Agent':
                                          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
                                    },
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) {
                                      debugPrint('[NewsletterList] Image placeholder: $url');
                                      return const Center(child: CircularProgressIndicator());
                                    },
                                    errorWidget: (context, url, error) {
                                      debugPrint('[NewsletterList] Image errorWidget: $url');
                                      debugPrint('[NewsletterList] ErrorWidget error: $error');
                                      return const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          size: 56,
                                        ),
                                      );
                                    },
                                  )
                                : const Center(
                                    child: Icon(Icons.picture_as_pdf, size: 56),
                                  ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  newsletter.title,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
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

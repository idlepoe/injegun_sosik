import 'dart:async';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:swipeable_page_route/swipeable_page_route.dart';

import '../bloc/newsletter_list_bloc.dart';
import '../models/newsletter.dart';
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
                  final createdAtText = newsletter.createdAt != null
                      ? DateFormat('yyyy-MM-dd').format(newsletter.createdAt!)
                      : '';
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
                                  builder: (_) => _PdfViewerScreen(
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

/// PDF 전체화면 뷰어
class _PdfViewerScreen extends StatefulWidget {
  const _PdfViewerScreen({
    required this.pdfUrl,
    required this.title,
  });

  final String pdfUrl;
  final String title;

  @override
  State<_PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<_PdfViewerScreen> {
  String? _filePath;
  bool _isLoading = true;
  String? _error;
  final Completer<PDFViewController> _controller = Completer<PDFViewController>();

  @override
  void initState() {
    super.initState();
    _downloadAndLoadPdf();
  }

  Future<void> _downloadAndLoadPdf() async {
    try {
      final response = await http.get(Uri.parse(widget.pdfUrl));
      if (response.statusCode != 200) {
        setState(() {
          _error = 'PDF 다운로드 실패: ${response.statusCode}';
          _isLoading = false;
        });
        return;
      }

      final directory = await getTemporaryDirectory();
      final fileName = widget.pdfUrl.split('/').last;
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        _filePath = file.path;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'PDF 로드 실패: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _filePath == null
                  ? const Center(child: Text('PDF 파일을 찾을 수 없습니다.'))
                  : PDFView(
                      filePath: _filePath!,
                      enableSwipe: true,
                      autoSpacing: false,
                      pageFling: false,
                      backgroundColor: Colors.grey,
                      onRender: (pages) {
                        if (pages != null) {
                          debugPrint('PDF 렌더링 완료: $pages 페이지');
                        }
                      },
                      onError: (error) {
                        setState(() {
                          _error = error.toString();
                        });
                      },
                      onPageError: (page, error) {
                        debugPrint('$page: ${error.toString()}');
                      },
                      onViewCreated: (PDFViewController pdfViewController) {
                        _controller.complete(pdfViewController);
                      },
                    ),
    );
  }
}

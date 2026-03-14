import 'dart:async';
import 'dart:io';

import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../utils/toast_utils.dart';

/// PDF 전체화면 뷰어 (다운로드 후 로컬 파일로 표시)
class PdfViewerScreen extends StatefulWidget {
  const PdfViewerScreen({
    super.key,
    required this.pdfUrl,
    required this.title,
  });

  final String pdfUrl;
  final String title;

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  String? _filePath;
  bool _isLoading = true;
  String? _error;
  final Completer<PDFViewController> _controller = Completer<PDFViewController>();
  int _currentPage = 0;
  int _totalPages = 0;
  bool _isSliding = false;
  final GlobalKey _shareButtonKey = GlobalKey();

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
      final fileName = _pdfFileName;
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

  String get _pdfFileName {
    final fromUrl = widget.pdfUrl.split('/').last;
    return fromUrl.contains('.pdf') ? fromUrl : '$fromUrl.pdf';
  }

  Widget _buildPageSlider() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      color: Colors.grey.shade200,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_currentPage + 1} / $_totalPages',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                trackHeight: 4,
              ),
              child: Slider(
                value: _currentPage.clamp(0, _totalPages > 0 ? _totalPages - 1 : 0).toDouble(),
                min: 0,
                max: _totalPages > 0 ? (_totalPages - 1).toDouble() : 0,
                divisions: _totalPages > 1 ? _totalPages - 1 : 1,
                onChanged: (value) {
                  setState(() {
                    _isSliding = true;
                    _currentPage = value.round();
                  });
                },
                onChangeEnd: (value) async {
                  final page = value.round();
                  try {
                    final ctrl = await _controller.future;
                    await ctrl.setPage(page);
                  } catch (_) {}
                  if (mounted) {
                    setState(() {
                      _isSliding = false;
                      _currentPage = page;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// share_plus로 PDF 공유 (iPad에서는 sharePositionOrigin으로 팝오버 위치 지정)
  Future<void> _sharePdf() async {
    if (_filePath == null) return;
    try {
      final box = _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
      final shareOrigin = box != null
          ? Rect.fromPoints(
              box.localToGlobal(Offset.zero),
              box.localToGlobal(Offset(box.size.width, box.size.height)),
            )
          : null;
      await Share.shareXFiles(
        [XFile(_filePath!, name: _pdfFileName)],
        subject: widget.title,
        sharePositionOrigin: shareOrigin,
      );
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, '공유 실패: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          if (_filePath != null)
            IconButton(
              key: _shareButtonKey,
              icon: const Icon(Icons.share),
              tooltip: '공유',
              onPressed: _sharePdf,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _filePath == null
                  ? const Center(child: Text('PDF 파일을 찾을 수 없습니다.'))
                  : Column(
                      children: [
                        Expanded(
                          child: PDFView(
                            filePath: _filePath!,
                            enableSwipe: true,
                            swipeHorizontal: true,
                            autoSpacing: true,
                            pageFling: true,
                            pageSnap: true,
                            backgroundColor: Colors.grey,
                            onRender: (pages) {
                              if (pages != null && mounted) {
                                setState(() {
                                  _totalPages = pages;
                                  if (_currentPage >= pages) _currentPage = pages > 0 ? pages - 1 : 0;
                                });
                              }
                            },
                            onPageChanged: (page, total) {
                              if (!_isSliding && page != null && total != null && mounted) {
                                setState(() {
                                  _currentPage = page;
                                  _totalPages = total;
                                });
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
                        ),
                        if (_totalPages > 1) _buildPageSlider(),
                      ],
                    ),
    );
  }
}

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

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

  /// 기기에 저장(다운로드 폴더 등) 후 토스트 표시
  Future<void> _downloadToDevice() async {
    if (_filePath == null) return;
    try {
      final downloadsDir = await getDownloadsDirectory();
      final dir = downloadsDir ?? await getApplicationDocumentsDirectory();
      final destFile = File('${dir.path}/$_pdfFileName');
      await File(_filePath!).copy(destFile.path);
      if (mounted) {
        ToastUtils.showSuccess(context, '다운받았습니다.');
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, '저장 실패: $e');
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
              icon: const Icon(Icons.download),
              tooltip: '다운로드',
              onPressed: _downloadToDevice,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _filePath == null
                  ? const Center(child: Text('PDF 파일을 찾을 수 없습니다.'))
                  : PDFView(
                      filePath: _filePath!,
                      enableSwipe: true,
                      swipeHorizontal: true,
                      autoSpacing: true,
                      pageFling: true,
                      pageSnap: true,
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

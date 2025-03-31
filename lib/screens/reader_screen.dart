// lib/screens/reader_screen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../services/pdf_service.dart';

class ReaderScreen extends StatefulWidget {
  const ReaderScreen({super.key});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  String extractedText = "PDF 파일을 선택해주세요.";
  double progress = 0.0;
  bool isExtracting = false;

  @override
  void initState() {
    super.initState();
    _loadCachedText();
  }

  Future<void> _loadCachedText() async {
    final cached = await PdfService.loadSavedText();
    if (cached != null) {
      setState(() {
        extractedText = cached;
      });
    }
  }

  Future<void> _pickAndExtractText() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      setState(() {
        isExtracting = true;
        progress = 0.0;
        extractedText = "텍스트를 추출 중...";
      });

      final text = await PdfService.extractTextByPage(file, (p) {
        setState(() {
          progress = p;
        });
      });

      setState(() {
        isExtracting = false;
      });

      if (text != null && text.isNotEmpty) {
        await PdfService.saveTextToFile(text);
        setState(() {
          extractedText = text;
        });
      } else {
        setState(() {
          extractedText = "⚠ 텍스트를 추출할 수 없습니다.";
        });
      }
    } else {
      setState(() {
        extractedText = "⚠ 파일을 선택하지 않았습니다.";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("PDF 속독기")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: isExtracting ? null : _pickAndExtractText,
              child: const Text("📂 PDF 선택"),
            ),
            const SizedBox(height: 20),
            if (isExtracting) ...[
              LinearProgressIndicator(value: progress),
              const SizedBox(height: 8),
              Text("진행률: ${(progress * 100).toStringAsFixed(1)}%"),
              const SizedBox(height: 20),
            ],
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  extractedText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

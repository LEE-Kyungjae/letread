// lib/services/pdf_service.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class PdfService {
  static Future<String?> extractTextByPage(
    File file,
    void Function(double progress) onProgress,
  ) async {
    try {
      final Uint8List bytes = await file.readAsBytes();
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final int pageCount = document.pages.count;
      final buffer = StringBuffer();

      for (int i = 0; i < pageCount; i++) {
        final text = PdfTextExtractor(document).extractText(
          startPageIndex: i,
          endPageIndex: i,
        );
        buffer.writeln(text);

        onProgress((i + 1) / pageCount);
        await Future.delayed(const Duration(milliseconds: 100));
      }

      document.dispose();
      return buffer.toString();
    } catch (e) {
      return null;
    }
  }

  static Future<void> saveTextToFile(String text) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/last_pdf_text.txt');
    await file.writeAsString(text);
  }

  static Future<String?> loadSavedText() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/last_pdf_text.txt');
    if (await file.exists()) {
      return await file.readAsString();
    }
    return null;
  }
}

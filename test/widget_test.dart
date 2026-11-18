import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:letread/main.dart';

void main() {
  late Directory documentsDir;

  setUp(() {
    documentsDir = Directory.systemTemp.createTempSync('letread_test');
    // ReaderScreen loads cached text from the documents directory on start.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (call) async => documentsDir.path,
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      null,
    );
    documentsDir.deleteSync(recursive: true);
  });

  testWidgets('shows the PDF reader with a pick prompt',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('PDF 속독기'), findsOneWidget);
    expect(find.text('PDF 파일을 선택해주세요.'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '📂 PDF 선택'), findsOneWidget);
  });

  testWidgets('shows previously saved text on start',
      (WidgetTester tester) async {
    File('${documentsDir.path}/last_pdf_text.txt')
        .writeAsStringSync('cached page text');

    await tester.runAsync(() async {
      await tester.pumpWidget(const MyApp());
      // Let the real file read in initState complete.
      await Future<void>.delayed(const Duration(milliseconds: 200));
    });
    await tester.pump();

    expect(find.text('cached page text'), findsOneWidget);
  });
}

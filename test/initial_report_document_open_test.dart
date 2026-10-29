import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/documents/services/initial_report_document_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('abak/directory_access');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('macOS sends the exact DOCX path to the native editor opener', () async {
    MethodCall? received;
    messenger.setMockMethodCallHandler(channel, (call) async {
      received = call;
      return null;
    });
    const path = '/tmp/Rapports synthétiques/Rapport avec espaces.docx';
    await const InitialReportDocumentService().open(path);
    expect(received?.method, 'openDocx');
    expect(received?.arguments, {'path': path});
  }, skip: !Platform.isMacOS);

  test(
    'native opening failure reaches the caller instead of reporting success',
    () async {
      messenger.setMockMethodCallHandler(channel, (call) async {
        throw PlatformException(
          code: 'DOCX_OPEN_FAILED',
          message: 'Application indisponible',
        );
      });
      await expectLater(
        const InitialReportDocumentService().open('/tmp/rapport.docx'),
        throwsA(
          isA<PlatformException>().having(
            (e) => e.code,
            'code',
            'DOCX_OPEN_FAILED',
          ),
        ),
      );
    },
    skip: !Platform.isMacOS,
  );
}

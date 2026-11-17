import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/link.dart';
// ignore: depend_on_referenced_packages
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:abak_desktop_companion/features/documents/services/initial_report_document_service.dart';

class DocumentLauncher extends UrlLauncherPlatform {
  @override
  LinkDelegate? get linkDelegate => null;

  bool result = true;
  PlatformException? failure;
  final urls = <String>[];
  final modes = <PreferredLaunchMode>[];
  @override
  Future<bool> launchUrl(String url, LaunchOptions options) async {
    urls.add(url);
    modes.add(options.mode);
    if (failure != null) throw failure!;
    return result;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('abak/directory_access');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test(
    'macOS sends the exact DOCX path to the native editor opener',
    () async {
      MethodCall? received;
      messenger.setMockMethodCallHandler(channel, (call) async {
        received = call;
        return null;
      });
      const path = '/tmp/Rapports synthétiques/Rapport avec espaces.docx';
      await const InitialReportDocumentService().open(path);
      expect(received?.method, 'openDocx');
      expect(received?.arguments, {'path': path});
    },
    skip: !Platform.isMacOS,
  );

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

  group('Windows document opening', () {
    late UrlLauncherPlatform previous;
    late DocumentLauncher launcher;
    late Directory temporary;
    late File file;
    setUp(() async {
      previous = UrlLauncherPlatform.instance;
      launcher = DocumentLauncher();
      UrlLauncherPlatform.instance = launcher;
      temporary = await Directory.systemTemp.createTemp('abak-document-open-');
      file = File(
        p.join(temporary.path, 'Rapport Élodie & détails #1 (test).pdf'),
      );
      await file.writeAsString('%PDF-synthetic fixture');
    });
    tearDown(() async {
      UrlLauncherPlatform.instance = previous;
      await temporary.delete(recursive: true);
    });
    test(
      'opens the exact file with the default external application',
      () async {
        await const InitialReportDocumentService().open(file.path);
        final uri = Uri.parse(launcher.urls.single);
        expect(uri.scheme, 'file');
        expect(uri.toFilePath(windows: true), file.absolute.path);
        expect(launcher.modes.single, PreferredLaunchMode.externalApplication);
      },
    );
    test('missing default application reaches the caller', () async {
      launcher.result = false;
      await expectLater(
        const InitialReportDocumentService().open(file.path),
        throwsStateError,
      );
    });
    test('native launch errors remain visible to the caller', () async {
      launcher.failure = PlatformException(code: 'open_error', message: 'test');
      await expectLater(
        const InitialReportDocumentService().open(file.path),
        throwsA(isA<PlatformException>()),
      );
    });
    test('missing file is rejected before asking Windows to open it', () async {
      await file.delete();
      await expectLater(
        const InitialReportDocumentService().open(file.path),
        throwsA(isA<FileSystemException>()),
      );
      expect(launcher.urls, isEmpty);
    });
  }, skip: !Platform.isWindows);
}

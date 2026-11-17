import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:abak_desktop_companion/features/patients/services/document_windows_execution.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final source = Uint8List.fromList(utf8.encode('synthetic DOCX bytes'));
  final pdf = Uint8List.fromList(utf8.encode('%PDF-synthetic-test'));
  Map<String, dynamic> response(String operation, Uint8List input) => {
    'protocol': 1,
    'operation': operation,
    'requestId': List.filled(32, 'a').join(),
    'pid': 25,
    'exitCode': 0,
    'stdout': '',
    'stderr': '',
    'inputHash': operation == 'version'
        ? ''
        : WindowsDocumentExecution.digest(input),
    'sourceHash': WindowsDocumentExecution.digest(input),
    'pdfHash': operation == 'docx' ? WindowsDocumentExecution.digest(pdf) : '',
    'pdf': operation == 'docx' ? pdf : Uint8List(0),
    'reportedPath':
        r'C:\ProgramData\ABAK\DocumentControls\work\job-test\document.pdf',
    'officeVersion': '26.8.2.2',
    'officeLauncherHash': List.filled(64, 'a').join(),
    'officeBinaryHash': List.filled(64, 'b').join(),
    'engineSignatureVerified': true,
    'networkDenied': true,
    'privateProfile': true,
    'macrosDisabled': true,
    'isolation': {
      'platform': 'windows',
      'serviceIdentifier': 'ABAKDocumentControls',
      'networkDenied': true,
      'writeRestricted': true,
      'jobObject': true,
      'restrictingSids': 'service+World',
    },
  };
  tearDown(
    () => messenger.setMockMethodCallHandler(
      WindowsDocumentExecution.channel,
      null,
    ),
  );

  test(
    'DOCX sends bytes without caller directory or executable arguments',
    () async {
      messenger.setMockMethodCallHandler(WindowsDocumentExecution.channel, (
        call,
      ) async {
        expect(call.method, 'runWindows');
        final args = call.arguments as Map;
        expect(args.keys.toSet(), {
          'protocol',
          'operation',
          'input',
          'inputHash',
          'office',
        });
        expect(args['input'], source);
        return response('docx', source);
      });
      final result = await WindowsDocumentExecution.convert(
        source,
        r'C:\Program Files\LibreOffice\program\soffice.exe',
      );
      expect(base64Decode(result['pdf'] as String), pdf);
    },
  );

  test('changed bytes, missing guards and macOS claims reject conversion', () {
    for (final key in [
      'protocol',
      'requestId',
      'inputHash',
      'sourceHash',
      'officeVersion',
      'officeLauncherHash',
      'officeBinaryHash',
      'engineSignatureVerified',
      'privateProfile',
      'macrosDisabled',
      'pdfHash',
      'pdf',
    ]) {
      final broken = response('docx', source)..remove(key);
      expect(
        () => WindowsDocumentExecution.validate(
          broken,
          operation: 'docx',
          input: source,
        ),
        throwsStateError,
      );
    }
    for (final key in [
      'networkDenied',
      'writeRestricted',
      'jobObject',
      'platform',
      'serviceIdentifier',
      'restrictingSids',
    ]) {
      final broken = response('docx', source);
      (broken['isolation'] as Map)[key] = false;
      expect(
        () => WindowsDocumentExecution.validate(
          broken,
          operation: 'docx',
          input: source,
        ),
        throwsStateError,
      );
    }
    final changed = response('docx', source)
      ..['pdf'] = Uint8List.fromList(utf8.encode('%PDF-other'));
    expect(
      () => WindowsDocumentExecution.validate(
        changed,
        operation: 'docx',
        input: source,
      ),
      throwsStateError,
    );
  });

  test(
    'PDF/A retains original report path bound to the exact input digest',
    () async {
      final job = await Directory.systemTemp.createTemp(
        'abak-windows-execution-',
      );
      try {
        final input = File(p.join(job.path, 'document.pdf'));
        await input.writeAsBytes(pdf);
        final report = response('pdfa', pdf)..['stdout'] = '<report/>';
        messenger.setMockMethodCallHandler(
          WindowsDocumentExecution.channel,
          (_) async => report,
        );
        final result = await WindowsDocumentExecution.run('pdfa', job);
        expect(result.stdout, '<report/>');
        expect(
          WindowsDocumentExecution.reportedInputPath(input),
          report['reportedPath'],
        );
        await input.writeAsBytes([...pdf, 0]);
        expect(
          () => WindowsDocumentExecution.reportedInputPath(input),
          throwsStateError,
        );
      } finally {
        await job.delete(recursive: true);
      }
    },
  );

  test(
    'unsupported operations and malformed responses produce no evidence',
    () async {
      final job = await Directory.systemTemp.createTemp('abak-windows-failed-');
      try {
        await expectLater(
          WindowsDocumentExecution.run('arbitrary', job),
          throwsStateError,
        );
        messenger.setMockMethodCallHandler(
          WindowsDocumentExecution.channel,
          (_) async => null,
        );
        await expectLater(
          WindowsDocumentExecution.run('version', job),
          throwsStateError,
        );
        expect(await job.list().toList(), isEmpty);
      } finally {
        await job.delete(recursive: true);
      }
    },
  );

  test(
    'a refused PDF is an executed validation, never a conversion success',
    () {
      final refused = response('pdfa', pdf)..['exitCode'] = 1;
      expect(
        WindowsDocumentExecution.validate(
          refused,
          operation: 'pdfa',
          input: pdf,
        )['exitCode'],
        1,
      );
      final conversion = response('docx', source)..['exitCode'] = 1;
      expect(
        () => WindowsDocumentExecution.validate(
          conversion,
          operation: 'docx',
          input: source,
        ),
        throwsStateError,
      );
    },
  );
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:abak_desktop_companion/features/patients/services/document_windows_execution.dart';
import 'package:abak_desktop_companion/features/patients/services/windows_cda_reports.dart';

Uint8List packet(Iterable<MapEntry<String, String>> files) {
  final entries = files.toList();
  final bytes = BytesBuilder()..add(ascii.encode('ABAKCDR1'));
  void put(int value) {
    final word = ByteData(4)..setUint32(0, value, Endian.little);
    bytes.add(word.buffer.asUint8List());
  }

  put(entries.length);
  for (final entry in entries) {
    final name = utf8.encode(entry.key), data = utf8.encode(entry.value);
    put(name.length);
    put(data.length);
    bytes.add(name);
    bytes.add(data);
  }
  return bytes.takeBytes();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final xml = Uint8List.fromList(utf8.encode('<ClinicalDocument/>'));
  final configuration = <String, Object?>{
    'references': {
      'manifest.json': 'a' * 64,
      'infrastructure/cda/CDA_extended.xsd': 'b' * 64,
      'schematrons/moteur/saxon9he.jar': 'c' * 64,
    },
    'helper': 'd' * 64,
  };
  final identity = WindowsCdaReports.identity(configuration);
  Map<String, String> reports() => {
    'completed.txt': 'ABAK-CDA-1',
    'xsd.xml': '<xsd completed="true" valid="true"/>',
    for (var index = 0; index < 5; index++)
      'profile-$index.xml':
          '<schematron-output xmlns="http://purl.oclc.org/dsdl/svrl"><active-pattern/></schematron-output>',
  };
  Map<String, dynamic> response({Uint8List? data, int exit = 0}) {
    final bytes = data ?? packet(reports().entries);
    return {
      'protocol': 1,
      'operation': 'cda',
      'requestId': 'a' * 32,
      'pid': 47,
      'exitCode': exit,
      'stdout': '',
      'stderr': '',
      'inputHash': WindowsDocumentExecution.digest(xml),
      'isolation': {
        'platform': 'windows',
        'serviceIdentifier': 'ABAKDocumentControls',
        'networkDenied': true,
        'writeRestricted': true,
        'jobObject': true,
        'restrictingSids': 'service+World',
      },
      ...identity,
      'cdaReports': bytes,
      'cdaReportsHash': WindowsDocumentExecution.digest(bytes),
    };
  }

  late Directory job;
  var calls = 0;
  setUp(() async {
    job = await Directory.systemTemp.createTemp('abak-cda-test-');
    await File(p.join(job.path, 'document.xml')).writeAsBytes(xml);
    calls = 0;
    messenger.setMockMethodCallHandler(WindowsDocumentExecution.channel, (
      _,
    ) async {
      calls++;
      return response();
    });
  });
  tearDown(() async {
    messenger.setMockMethodCallHandler(WindowsDocumentExecution.channel, null);
    await job.delete(recursive: true);
  });
  Future<void> unchanged() async {
    expect(await job.list().map((f) => p.basename(f.path)).toList(), [
      'document.xml',
    ]);
    expect(await File(p.join(job.path, 'document.xml')).readAsBytes(), xml);
  }

  void validate(Map<String, dynamic> value) =>
      WindowsDocumentExecution.validate(
        value,
        operation: 'cda',
        input: xml,
        cdaIdentity: identity,
      );

  test(
    'CDA sends bytes only and retains seven reports with bound evidence',
    () async {
      messenger.setMockMethodCallHandler(WindowsDocumentExecution.channel, (
        call,
      ) async {
        calls++;
        expect(call.method, 'runWindows');
        final args = call.arguments as Map;
        expect(args.keys.toSet(), {
          'protocol',
          'operation',
          'input',
          'inputHash',
        });
        expect(args['operation'], 'cda');
        expect(args['input'], xml);
        return response();
      });
      final result = await WindowsDocumentExecution.runCda(job, configuration);
      expect(result.exitCode, 0);
      expect(calls, 1);
      for (final entry in reports().entries) {
        expect(
          await File(p.join(job.path, entry.key)).readAsString(),
          entry.value,
        );
      }
      final proof =
          jsonDecode(
                await File(
                  p.join(job.path, 'native-launch-cda.json'),
                ).readAsString(),
              )
              as Map;
      expect(proof['inputHash'], WindowsDocumentExecution.digest(xml));
      for (final key in identity.keys) {
        expect(proof[key], identity[key]);
      }
      expect(await File(p.join(job.path, 'document.xml')).readAsBytes(), xml);
    },
  );
  test(
    'optional XSD errors and failed assertions are retained without alteration',
    () {
      final refused = reports()
        ..['xsd.xml'] = '<xsd completed="true" valid="false"/>'
        ..['xsd-error.txt'] = 'synthetic XSD error'
        ..['profile-0.xml'] =
            '<schematron-output><failed-assert>synthetic refusal</failed-assert></schematron-output>';
      final data = packet(refused.entries);
      validate(response(data: data));
      final decoded = WindowsCdaReports.decode(data);
      expect(utf8.decode(decoded['xsd-error.txt']!), 'synthetic XSD error');
      expect(
        utf8.decode(decoded['profile-0.xml']!),
        contains('synthetic refusal'),
      );
    },
  );
  test(
    'every required report and the exact completion marker are checked',
    () async {
      for (final key in reports().keys) {
        final incomplete = reports()..remove(key);
        final data = response(data: packet(incomplete.entries));
        messenger.setMockMethodCallHandler(
          WindowsDocumentExecution.channel,
          (_) async => data,
        );
        await expectLater(
          WindowsDocumentExecution.runCda(job, configuration),
          throwsStateError,
        );
        await unchanged();
      }
      final wrong = reports()..['completed.txt'] = 'unfinished';
      expect(
        () => validate(response(data: packet(wrong.entries))),
        throwsStateError,
      );
    },
  );
  test(
    'a reply for different references or helper creates no evidence',
    () async {
      for (final key in identity.keys) {
        messenger.setMockMethodCallHandler(
          WindowsDocumentExecution.channel,
          (_) async => response()..[key] = 'f' * 64,
        );
        await expectLater(
          WindowsDocumentExecution.runCda(job, configuration),
          throwsStateError,
        );
        await unchanged();
      }
    },
  );
  test(
    'changed input, report bytes or absent report metadata are rejected',
    () {
      for (final key in [
        'inputHash',
        'cdaReports',
        'cdaReportsHash',
        ...identity.keys,
      ]) {
        expect(() => validate(response()..remove(key)), throwsStateError);
      }
      final changed = response();
      (changed['cdaReports'] as Uint8List)[20] ^= 1;
      expect(() => validate(changed), throwsStateError);
      expect(
        () => validate(response()..['operation'] = 'pdfa'),
        throwsStateError,
      );
    },
  );
  test('missing Windows process protections reject the CDA result', () {
    for (final key in [
      'platform',
      'serviceIdentifier',
      'networkDenied',
      'writeRestricted',
      'jobObject',
      'restrictingSids',
    ]) {
      final value = response();
      (value['isolation'] as Map).remove(key);
      expect(() => validate(value), throwsStateError);
    }
  });
  test('duplicate, unknown and traversal report names are rejected', () {
    final entries = reports().entries.toList();
    for (final name in [
      '../xsd.xml',
      r'C:\outside.xml',
      'unexpected.xml',
      'profile-1.xml',
    ]) {
      final changed = List<MapEntry<String, String>>.from(entries);
      changed[2] = MapEntry(name, '<synthetic/>');
      expect(() => WindowsCdaReports.decode(packet(changed)), throwsStateError);
    }
  });
  test(
    'all truncated packets, wrong versions and trailing bytes are rejected',
    () {
      final bytes = packet(reports().entries);
      for (var size = 0; size < bytes.length; size++) {
        expect(
          () => WindowsCdaReports.decode(
            Uint8List.fromList(bytes.sublist(0, size)),
          ),
          throwsStateError,
        );
      }
      final magic = Uint8List.fromList(bytes)..[7] = 50;
      expect(() => WindowsCdaReports.decode(magic), throwsStateError);
      expect(
        () => WindowsCdaReports.decode(Uint8List.fromList([...bytes, 0])),
        throwsStateError,
      );
      expect(
        () => WindowsCdaReports.decode(Uint8List(WindowsCdaReports.limit + 1)),
        throwsStateError,
      );
    },
  );
  test('invalid UTF-8 reports are rejected before writing files', () async {
    final data = packet(reports().entries);
    data[data.length - 1] = 255;
    messenger.setMockMethodCallHandler(
      WindowsDocumentExecution.channel,
      (_) async => response(data: data),
    );
    await expectLater(
      WindowsDocumentExecution.runCda(job, configuration),
      throwsFormatException,
    );
    await unchanged();
  });
  test('an occupied evidence path stops before any service call', () async {
    final existing = File(p.join(job.path, 'profile-0.xml'));
    await existing.writeAsString('existing evidence');
    await expectLater(
      WindowsDocumentExecution.runCda(job, configuration),
      throwsStateError,
    );
    expect(calls, 0);
    expect(await existing.readAsString(), 'existing evidence');
  });
  test('a null service reply creates no reports', () async {
    messenger.setMockMethodCallHandler(
      WindowsDocumentExecution.channel,
      (_) async => null,
    );
    await expectLater(
      WindowsDocumentExecution.runCda(job, configuration),
      throwsStateError,
    );
    await unchanged();
  });
  test(
    'an interrupted Java run retains diagnostic proof but no completion',
    () async {
      final failed = response(data: Uint8List(0), exit: 1)
        ..['stderr'] = 'synthetic exception';
      messenger.setMockMethodCallHandler(
        WindowsDocumentExecution.channel,
        (_) async => failed,
      );
      final result = await WindowsDocumentExecution.runCda(job, configuration);
      expect(result.exitCode, 1);
      expect(result.stderr, 'synthetic exception');
      expect(
        await File(p.join(job.path, 'native-launch-cda.json')).exists(),
        isTrue,
      );
      expect(await File(p.join(job.path, 'completed.txt')).exists(), isFalse);
      expect(() => validate(response(exit: 1)), throwsStateError);
    },
  );
  test('CDA reference identity is deterministic and rejects unsafe paths', () {
    final a = 'a' * 64, b = 'b' * 64;
    final expected = WindowsDocumentExecution.digest(
      utf8.encode('a/file\u0000$a\nb/file\u0000$b\n'),
    );
    expect(
      WindowsCdaReports.referenceFingerprint({'b/file': b, 'a/file': a}),
      expected,
    );
    expect(
      WindowsCdaReports.referenceFingerprint({
        'b/file': b,
        'a/file': a,
        'a/abak-0-0.xsl': a,
        '.bench-test/file': b,
        'unified-configuration.json': a,
      }),
      expected,
    );
    for (final key in [
      '../a',
      r'a\b',
      'C:/a',
      'a//b',
      '/a',
      'a\nb',
      'a.',
      'a /b',
    ]) {
      expect(
        () => WindowsCdaReports.referenceFingerprint({key: a}),
        throwsStateError,
      );
    }
    expect(
      () => WindowsCdaReports.identity({
        'references': {'a': a},
        'helper': a,
      }),
      throwsStateError,
    );
  });
  test('CDA requires an input document and a configuration identity', () async {
    await expectLater(
      WindowsDocumentExecution.execute(operation: 'cda', input: xml),
      throwsStateError,
    );
    await expectLater(
      WindowsDocumentExecution.execute(
        operation: 'cda',
        input: Uint8List(0),
        cdaIdentity: identity,
      ),
      throwsStateError,
    );
    await expectLater(
      WindowsDocumentExecution.execute(
        operation: 'cda',
        input: Uint8List(WindowsCdaReports.inputLimit + 1),
        cdaIdentity: identity,
      ),
      throwsStateError,
    );
    await expectLater(
      WindowsDocumentExecution.execute(
        operation: 'docx',
        input: Uint8List(WindowsDocumentExecution.limit + 1),
      ),
      throwsStateError,
    );
    expect(calls, 0);
  });
}

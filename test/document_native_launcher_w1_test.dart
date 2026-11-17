import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:abak_desktop_companion/features/patients/services/document_native_launcher.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  late Directory job;
  var calls = 0;

  setUp(() async {
    job = await Directory.systemTemp.createTemp('abak-w1-test-');
    calls = 0;
  });
  tearDown(() async {
    messenger.setMockMethodCallHandler(NativeDocumentLauncher.channel, null);
    await job.delete(recursive: true);
  });
  List<String> arguments() => [
    '-cp',
    'synthetic.jar',
    'org.verapdf.apps.GreenfieldCliWrapper',
    '--format',
    'xml',
    '--flavour',
    '1b',
    p.join(job.path, 'document.pdf'),
  ];
  Map<String, Object?> macResponse() => {
    'protocol': 1,
    'pid': 7,
    'exitCode': 0,
    'stdout': '',
    'stderr': '',
    'files': <String, String>{},
    'isolation': {
      'networkDenied': true,
      'callerJobWriteDenied': true,
      'privateWriteSucceeded': true,
      'serviceIdentifier': 'fr.abakphysio.documentcontrols',
    },
  };

  test(
    'Windows CDA requires the dedicated service rather than a generic launch',
    () async {
      messenger.setMockMethodCallHandler(NativeDocumentLauncher.channel, (
        _,
      ) async {
        calls++;
        return macResponse();
      });
      await expectLater(
        NativeDocumentLauncher.run(
          'unused-java',
          [
            '--class-path',
            p.join(job.path, 'references/schematrons/moteur/saxon9he.jar'),
            p.join(job.path, 'CdaCheck.java'),
            p.join(job.path, 'references'),
            job.path,
          ],
          job,
          const Duration(seconds: 1),
        ),
        throwsStateError,
      );
      expect(calls, 0);
      expect(await job.list().toList(), isEmpty);
    },
    skip: !Platform.isWindows,
  );

  test(
    'existing macOS response and evidence format are preserved',
    () async {
      messenger.setMockMethodCallHandler(NativeDocumentLauncher.channel, (
        call,
      ) async {
        calls++;
        expect(call.method, 'run');
        expect((call.arguments as Map)['protocol'], 1);
        return macResponse();
      });
      final result = await NativeDocumentLauncher.run(
        'unused-java',
        arguments(),
        job,
        const Duration(seconds: 1),
      );
      expect(result.exitCode, 0);
      expect(calls, 1);
      final evidence =
          jsonDecode(
                await File(
                  p.join(job.path, 'native-launch-pdfa.json'),
                ).readAsString(),
              )
              as Map;
      expect(
        (evidence['isolation'] as Map)['serviceIdentifier'],
        'fr.abakphysio.documentcontrols',
      );
    },
    skip: Platform.isWindows,
  );

  test(
    'macOS checks still reject missing, false or Windows isolation',
    () async {
      for (final isolation in [
        null,
        {...(macResponse()['isolation'] as Map), 'networkDenied': false},
        {...(macResponse()['isolation'] as Map), 'callerJobWriteDenied': false},
        {
          ...(macResponse()['isolation'] as Map),
          'privateWriteSucceeded': false,
        },
        {...(macResponse()['isolation'] as Map), 'serviceIdentifier': 'other'},
        {'platform': 'windows', 'qualified': true},
      ]) {
        messenger.setMockMethodCallHandler(
          NativeDocumentLauncher.channel,
          (_) async => macResponse()..['isolation'] = isolation,
        );
        await expectLater(
          NativeDocumentLauncher.run(
            'unused-java',
            arguments(),
            job,
            const Duration(seconds: 1),
          ),
          throwsStateError,
        );
      }
      expect(await job.list().toList(), isEmpty);
    },
    skip: Platform.isWindows,
  );

  test('the existing command allow-list rejects arbitrary commands', () async {
    await expectLater(
      NativeDocumentLauncher.run(
        'unused-java',
        ['-version'],
        job,
        const Duration(seconds: 1),
      ),
      throwsStateError,
    );
    expect(calls, 0);
    expect(await job.list().toList(), isEmpty);
  });
}

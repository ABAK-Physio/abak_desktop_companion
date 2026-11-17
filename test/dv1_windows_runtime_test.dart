import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import '../lib/features/patients/services/dmp_chain/native/bridge.dart';
import '../lib/features/patients/services/dmp_chain/native/dmp_runtime_paths.dart';

String testDart() {
  final exe = Platform.resolvedExecutable;
  if (p.basenameWithoutExtension(exe) == 'dart') return exe;
  final cache = p.dirname(p.dirname(p.dirname(p.dirname(exe))));
  final dart = p.join(
    cache,
    'dart-sdk',
    'bin',
    Platform.isWindows ? 'dart.exe' : 'dart',
  );
  if (!File(dart).existsSync())
    throw StateError('SDK Dart de test introuvable.');
  return dart;
}

void main() {
  test('Windows CPS uses bundled java.exe, Mac retains java-cps', () {
    expect(
      DmpRuntimePaths.cpsJava(
        r'C:\Program Files\ABAK\data\DmpTools\x64',
        windows: true,
      ),
      r'C:\Program Files\ABAK\data\DmpTools\x64\java\bin\java.exe',
    );
    expect(
      DmpRuntimePaths.cpsJava(
        '/Applications/ABAK/DmpTools/arm64',
        windows: false,
      ),
      '/Applications/ABAK/DmpTools/arm64/java/bin/java-cps',
    );
  });
  for (final path in [
    r'C:\Windows\System32\cps3_pkcs11_w64.dll',
    r'D:\Program Files\ABAK\preuve de contrôle\trust.pem',
    'C:/ABAK/trust.pem',
  ]) {
    test('accepts local absolute Windows path $path', () {
      expect(DmpRuntimePaths.absoluteLocal(path, windows: true), isTrue);
    });
  }
  for (final path in [
    '',
    r'C:relative.dll',
    r'\Windows\cps.dll',
    r'\\server\share\cps.dll',
    r'\\?\C:\cps.dll',
    '/usr/local/lib/cps.dylib',
    r'C:\..\cps.dll',
    r'C:\.\cps.dll',
    'C:\\bad\n.dll',
    'C:\\bad\r.dll',
    'C:\\bad\u0000.dll',
    'C:\\bad".dll',
    'C:\\bad{.dll',
  ]) {
    test('rejects unsafe Windows path ${path.codeUnits}', () {
      expect(DmpRuntimePaths.absoluteLocal(path, windows: true), isFalse);
    });
  }
  test('POSIX absolute paths remain accepted on Mac', () {
    expect(
      DmpRuntimePaths.absoluteLocal(
        '/usr/local/lib/libcps3_pkcs11_osx.dylib',
        windows: false,
      ),
      isTrue,
    );
    expect(
      DmpRuntimePaths.absoluteLocal('relative/lib.dylib', windows: false),
      isFalse,
    );
  });
  for (final mode in ['lf', 'crlf']) {
    test(
      'isolated framed exchange handles $mode and a private working directory',
      () async {
        final directory = Directory.systemTemp.createTempSync('ABAK DV1 é ');
        final original = Directory.current.path;
        final bridge = DmpProcessBridge(
          executable: testDart(),
          arguments: [
            p.absolute('test/support/dv1_protocol_worker.dart'),
            mode,
          ],
          workingDirectory: directory.path,
        );
        try {
          final result = await bridge.call('probe', {
            'text': 'exact\n<test>é</test>',
          });
          expect(result['echo'], 'exact\n<test>é</test>');
          expect(result['cwd'], directory.path);
          expect(Directory.current.path, original);
        } finally {
          await bridge.close();
          directory.deleteSync(recursive: true);
        }
      },
    );
  }
  test('embedded CR remains a protocol error, without retry', () async {
    final bridge = DmpProcessBridge(
      executable: testDart(),
      arguments: [
        p.absolute('test/support/dv1_protocol_worker.dart'),
        'bad-cr',
      ],
    );
    try {
      await expectLater(
        bridge.call('probe', {'text': 'synthetic'}),
        throwsA(
          isA<DmpNativeFailure>().having(
            (e) => e.code,
            'code',
            'NATIVE_PROTOCOL',
          ),
        ),
      );
    } finally {
      await bridge.close();
    }
  });
}

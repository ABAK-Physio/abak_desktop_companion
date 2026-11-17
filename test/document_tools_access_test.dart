import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:abak_desktop_companion/features/patients/services/document_tools_access.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  String root(String key, String value, {bool windows = true}) =>
      DocumentToolsAccess.rootForPlatform(key, value, windows: windows);

  test('Windows java.exe resolves to its JDK home', () {
    expect(root('java', r'C:\Tools\jdk\bin\java.exe'), r'C:\Tools\jdk');
    expect(root('java', r'C:\Tools\jdk\BIN\JAVA.EXE'), r'C:\Tools\jdk');
    expect(() => root('java', r'C:\Tools\jdk\bin\java'), throwsStateError);
    expect(() => root('java', r'C:\Tools\java.exe'), throwsStateError);
  });

  test(
    'Windows LibreOffice uses the program directory, not a macOS bundle',
    () {
      expect(
        root('office', r'C:\Program Files\LibreOffice\program\soffice.exe'),
        r'C:\Program Files\LibreOffice\program',
      );
      expect(() => root('office', r'C:\Tools\other.exe'), throwsStateError);
      expect(() => root('office', r'C:\Tools\soffice.exe'), throwsStateError);
      expect(root('vera', r'C:\Tools\vera\cli.jar'), r'C:\Tools\vera');
    },
  );

  test(
    'Windows tools require absolute local paths outside the volume root',
    () {
      for (final value in [
        r'\\server\share',
        r'C:\',
        r'C:tools',
        r'tools',
        r'C:\Tools\..\Other',
        '/Applications/LibreOffice.app',
      ]) {
        expect(
          () => root('references', value),
          throwsStateError,
          reason: value,
        );
      }
      expect(
        root('references', r'C:\Tools\references'),
        r'C:\Tools\references',
      );
    },
  );

  test('macOS java and app paths keep their existing rules', () {
    expect(
      root('java', '/Library/Java/Example/bin/java', windows: false),
      '/Library/Java/Example',
    );
    expect(
      root('office', '/Applications/LibreOffice.app', windows: false),
      '/Applications/LibreOffice.app',
    );
    expect(
      () => root('java', '/Library/Java/Example/bin/java.exe', windows: false),
      throwsStateError,
    );
    expect(() => root('java', '/bin/java', windows: false), throwsStateError);
  });

  test(
    'Windows configuration and access never call macOS directory methods',
    () async {
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      const macChannel = MethodChannel('abak/directory_access');
      var macCalls = 0;
      messenger.setMockMethodCallHandler(macChannel, (_) async {
        macCalls++;
        throw StateError('macOS directory access called on Windows');
      });
      final directory = await Directory.systemTemp.createTemp(
        'abak-tools-windows-',
      );
      try {
        final paths = <String, String>{
          'java': p.join(directory.path, 'jdk', 'bin', 'java.exe'),
          'vera': p.join(directory.path, 'vera', 'cli.jar'),
          'office': p.join(
            directory.path,
            'LibreOffice',
            'program',
            'soffice.exe',
          ),
          'references': p.join(directory.path, 'references'),
          'label': 'Synthetic local references',
        };
        for (final key in ['java', 'vera', 'office']) {
          final file = File(paths[key]!);
          await file.parent.create(recursive: true);
          await file.writeAsString('synthetic fixture, never executed');
        }
        await Directory(paths['references']!).create();
        expect(
          await DocumentToolsAccess.authorize(paths, onStep: (_) {}),
          isTrue,
        );
        final access = await DocumentToolsAccess.acquire(
          paths,
          includeOffice: true,
        );
        await access.release();
        expect(macCalls, 0);
        await File(paths['java']!).delete();
        await expectLater(DocumentToolsAccess.acquire(paths), throwsStateError);
        expect(macCalls, 0);
      } finally {
        messenger.setMockMethodCallHandler(macChannel, null);
        await directory.delete(recursive: true);
      }
    },
    skip: !Platform.isWindows,
  );
}

import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:abak_desktop_companion/features/dmp_setup/bundled_pdf_tools.dart';
import 'package:abak_desktop_companion/features/patients/services/document_tools_access.dart';

void main() {
  test('verified bundled tools pass configuration path validation', () async {
    final temporary = await Directory.systemTemp.createTemp(
      'abak-bundle-paths-',
    );
    final directory = Directory(await temporary.resolveSymbolicLinks());
    addTearDown(() => directory.delete(recursive: true));
    final javaRelative = Platform.isWindows
        ? 'java/bin/java.exe'
        : 'java/bin/java';
    final hashes = <String, String>{};
    for (final relative in [javaRelative, 'vera/cli.jar', 'NOTICE.txt']) {
      final file = File(p.joinAll([directory.path, ...relative.split('/')]));
      await file.parent.create(recursive: true);
      final bytes = utf8.encode('synthetic fixture, never executed');
      await file.writeAsBytes(bytes);
      hashes[relative] = sha256.convert(bytes).toString();
    }
    await File(p.join(directory.path, 'manifest.json')).writeAsString(
      jsonEncode({'protocol': 1, 'profile': 'PDF/A-1b', 'files': hashes}),
    );

    final tools = await BundledPdfTools.verify(directory);
    expect(tools.java, p.joinAll([directory.path, ...javaRelative.split('/')]));
    expect(tools.vera, p.join(directory.path, 'vera', 'cli.jar'));
    for (final entry in {'java': tools.java, 'vera': tools.vera}.entries) {
      expect(entry.value, p.normalize(entry.value));
      expect(await File(entry.value).exists(), isTrue);
      expect(
        DocumentToolsAccess.rootForPlatform(
          entry.key,
          entry.value,
          windows: Platform.isWindows,
        ),
        p.join(directory.path, entry.key),
      );
    }
  });
}

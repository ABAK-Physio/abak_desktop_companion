
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_setup/bundled_pdf_tools.dart';

void main() {
  test(
    'Windows bundled PDF tools match the real preparation manifest',
        () async {
          if (!Platform.isWindows) return;

          const bundlePath = String.fromEnvironment('ABAK_DMP_TOOLS_TEST_ROOT');

          if (bundlePath.isEmpty) return;

          final root = Directory(bundlePath);
      expect(await root.exists(), isTrue);

      final tools = await BundledPdfTools.verify(root);

      expect(await File(tools.java).exists(), isTrue);
      expect(await File(tools.vera).exists(), isTrue);
      expect(tools.fingerprint, isNotEmpty);
    },
  );
}

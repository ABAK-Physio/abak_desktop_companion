import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import '../lib/features/patients/services/dmp_chain/native/dmp_runtime_paths.dart';

void main() {
  const configuration =
      '82bf25a3917b44fe44157b2603656d0eba5c835260cc3fd6493642d70a33f7de';
  const worker =
      '0f19a0793472c4ff2f2982040f014ebb41357ac94cd9036be5c98e685c472b3f';
  const controls =
      r'C:\Users\Utilisateur\AppData\Roaming\com.example\abak_desktop_companion\episode_document_versions\controls';

  test('reported Windows source path stays below the legacy path limit', () {
    final old = p.windows.join(
      controls,
      'dv1-runtime',
      configuration,
      worker,
      'DmpNativeBridge.java',
    );
    final directory = DmpRuntimePaths.workerDirectory(
      controls,
      configuration,
      worker,
      windows: true,
    );
    final source = p.windows.join(directory, 'DmpNativeBridge.java');
    expect(old.length, 269);
    expect(source.length, 204);
    expect(source.length, lessThan(260));
    expect(
      p.windows.dirname(directory),
      p.windows.join(controls, 'dv1-runtime'),
    );
    expect(p.windows.basename(directory), matches(RegExp(r'^[0-9a-f]{64}$')));
  });

  test('changing either pinned input changes the Windows directory', () {
    final original = DmpRuntimePaths.workerDirectory(
      controls,
      configuration,
      worker,
      windows: true,
    );
    expect(
      DmpRuntimePaths.workerDirectory(controls, worker, worker, windows: true),
      isNot(original),
    );
    expect(
      DmpRuntimePaths.workerDirectory(
        controls,
        configuration,
        configuration,
        windows: true,
      ),
      isNot(original),
    );
    expect(
      DmpRuntimePaths.workerDirectory(
        controls,
        configuration,
        worker,
        windows: true,
      ),
      original,
    );
  });

  test('Mac runtime directory remains identical', () {
    const root = '/Users/test/Library/Application Support/ABAK/controls';
    expect(
      DmpRuntimePaths.workerDirectory(
        root,
        configuration,
        worker,
        windows: false,
      ),
      p.posix.join(root, 'dv1-runtime', configuration, worker),
    );
  });

  for (final invalid in ['', '../outside', 'a' * 63, 'A' * 64]) {
    test('invalid directory key is rejected: $invalid', () {
      expect(
        () => DmpRuntimePaths.workerDirectory(
          controls,
          invalid,
          worker,
          windows: true,
        ),
        throwsArgumentError,
      );
      expect(
        () => DmpRuntimePaths.workerDirectory(
          controls,
          configuration,
          invalid,
          windows: true,
        ),
        throwsArgumentError,
      );
    });
  }
}

import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/core/maintenance/startup_maintenance.dart';

void main() {
  test('optional maintenance failure permits next startup stage', () async {
    final stages = <String>[];
    await runOptionalMaintenance('Purge', () async {
      stages.add('purge');
      throw StateError('Database unavailable');
    });
    stages.add('ready');
    expect(stages, ['purge', 'ready']);
  });
  test(
    'fatal shutdown attempts every service despite an individual error',
    () async {
      final stopped = <String>[];
      await stopStartupServices([
        () async {
          stopped.add('watcher');
          throw StateError('Stop failed');
        },
        () async {
          stopped.add('server');
        },
      ]);
      expect(stopped, ['watcher', 'server']);
    },
  );
}

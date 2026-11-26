// Invoked only by document_root_migration_test.dart on a marked synthetic tree.
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/core/documents/document_root_migration.dart';
import '../document_root_migration_test.dart' show Access;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('synthetic migration crash worker', () async {
    final root = Platform.environment['ABAK_M2_SYNTHETIC_ROOT']!;
    if (!p.basename(root).startsWith('abak_m2_synthetic_') ||
        await File(p.join(root, 'migration-test-scope')).readAsString() !=
            'ABAK-M2-SYNTHETIC') {
      throw StateError('invalid synthetic scope');
    }
    sqfliteFfiInit();
    final db = await databaseFactoryFfi.openDatabase(
      p.join(root, 'synthetic.sqlite'),
      options: OpenDatabaseOptions(singleInstance: false),
    );
    final service = DocumentRootMigration(
      database: db,
      support: Directory(p.join(root, 'support')),
      access: Access(),
      checkpoint: (phase) async {
        if (phase == Platform.environment['ABAK_M2_CRASH_PHASE']) exit(73);
      },
    );
    final plan = await service.plan(p.join(root, 'target'));
    await service.execute(
      plan,
      MigrationConsent(
        planHash: plan.hash,
        invalidations: true,
        unknownSpace: true,
      ),
    );
    throw StateError('expected process exit was not reached');
  });
}

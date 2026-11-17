import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/maintenance/services/backup_cleanup_health.dart';
import 'package:abak_desktop_companion/features/maintenance/models/backup_cleanup_result.dart';
import 'package:abak_desktop_companion/features/maintenance/models/database_backup.dart';
import 'package:abak_desktop_companion/features/import_export/models/import_session.dart';
import 'package:abak_desktop_companion/features/home/widgets/system_status_card.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';

BackupCleanupResult result({bool failed = false}) => BackupCleanupResult(
  scannedCount: 7,
  deletedCount: 0,
  keptCount: 7,
  deletedPaths: const [],
  failedPaths: failed ? ['synthetic.zip'] : [],
);

void main() {
  test(
    'partial failure and global exception stay unhealthy until successful cleanup',
    () async {
      final monitor = BackupCleanupMonitor();
      await monitor.run(() async => result(failed: true));
      expect(monitor.value, BackupCleanupHealth.incomplete);
      await expectLater(
        monitor.run(() async => throw StateError('catalog unavailable')),
        throwsStateError,
      );
      expect(monitor.value, BackupCleanupHealth.unavailable);
      await monitor.run(() async => result());
      expect(monitor.value, BackupCleanupHealth.healthy);
      monitor.dispose();
    },
  );
  testWidgets(
    'recent backup never hides suspended cleanup; successful retry clears warning',
    (tester) async {
      final monitor = BackupCleanupMonitor();
      await monitor.run(() async => result(failed: true));
      final backup = DatabaseBackup(
        backupId: 'test',
        fileName: 'test.zip',
        filePath: '/synthetic/test.zip',
        createdAt: DateTime.now().millisecondsSinceEpoch,
        fileSize: 1,
        status: 'completed',
        notes: null,
      );
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('fr', 'FR'),
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: S.delegate.supportedLocales,
          home: Scaffold(
            body: SystemStatusCard(
              cleanupMonitor: monitor,
              loadStatus: () async => [<ImportSession>[], backup],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Tout fonctionne normalement'), findsNothing);
      expect(
        find.byKey(const ValueKey('backup-cleanup-warning')),
        findsOneWidget,
      );
      expect(find.text('Une intervention est nécessaire'), findsOneWidget);
      await monitor.run(() async => result());
      await tester.pumpAndSettle();
      expect(find.text('Tout fonctionne normalement'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('backup-cleanup-warning')),
        findsNothing,
      );
      await expectLater(
        monitor.run(() async => throw StateError('catalog')),
        throwsStateError,
      );
      await tester.pumpAndSettle();
      expect(find.text('Tout fonctionne normalement'), findsNothing);
      expect(
        find.byKey(const ValueKey('backup-cleanup-warning')),
        findsOneWidget,
      );
      await tester.pumpWidget(const SizedBox());
      monitor.dispose();
    },
  );
}

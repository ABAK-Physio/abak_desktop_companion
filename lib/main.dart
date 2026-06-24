import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/database/database_service.dart';
import 'features/import_export/data/import_session_repository.dart';
import 'features/local_exchange/services/airdrop_import_watcher.dart';
import 'features/local_exchange/services/local_exchange_server.dart';
import 'features/maintenance/data/database_backup_repository.dart';
import 'features/maintenance/services/local_backup_cleanup_service.dart';
import 'features/patients/services/default_contact_form_template_service.dart';
import 'features/patients/services/patient_purge_service.dart';
import 'core/ui/app_messenger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1400, 900),
    minimumSize: Size(1200, 800),
    center: true,
    title: 'ABAK Desktop Companion',
  );

  await DatabaseService.database;

  await DefaultContactFormTemplateService()
      .ensureDefaultTemplateExists();

  await LocalExchangeServer.instance.start();

  AirDropImportWatcher.instance.onImportMessage =
      (message) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 5),
      ),
    );
  };

  await AirDropImportWatcher.instance.start();

  debugPrint(
    '📡 serveur local ABAK actif sur le port '
        '${LocalExchangeServer.instance.port}',
  );

  await ImportSessionRepository().recoverInterruptedSessions();

  final purgeResult =
  await PatientPurgeService().purgeArchivedPatients();

  debugPrint(
    '🧹 purge patients : '
        '${purgeResult.deletedPatients} supprimé(s)',
  );

  final backupCleanupResult = await LocalBackupCleanupService(
    repository: DatabaseBackupRepository(),
  ).cleanupOldBackups();

  debugPrint(
    '🧹 purge sauvegardes SQLite : '
        '${backupCleanupResult.deletedCount} supprimée(s), '
        '${backupCleanupResult.keptCount} conservée(s)',
  );

  windowManager.waitUntilReadyToShow(
    windowOptions,
        () async {
      await windowManager.show();
      await windowManager.focus();
    },
  );

  runApp(const AbakDesktopApp());
}
/*
 * ABAK Desktop Companion
 * Copyright (C) 2026 ABAK Metrics
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Affero General Public License as
 * published by the Free Software Foundation, either version 3 of the
 * License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 * See the GNU Affero General Public License for more details.
 *
 * You should have received a copy of the GNU Affero General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'core/database/database_service.dart';
import 'features/import_export/data/import_session_repository.dart';
import 'features/local_exchange/services/airdrop_import_watcher.dart';
import 'features/local_exchange/services/local_exchange_server.dart';
import 'features/maintenance/data/database_backup_repository.dart';
import 'features/maintenance/services/local_backup_cleanup_service.dart';
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

  await LocalExchangeServer.instance.start();

  AirDropImportWatcher.instance.onImportMessage = (message) {
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 5)),
    );
  };

  await AirDropImportWatcher.instance.start();

  debugPrint(
    '📡 serveur local ABAK actif sur le port '
    '${LocalExchangeServer.instance.port}',
  );

  await ImportSessionRepository().recoverInterruptedSessions();

  final purgeResult = await PatientPurgeService().purgeArchivedPatients();

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

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const AbakDesktopApp());
}

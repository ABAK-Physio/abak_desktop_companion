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
import 'features/patients/services/patient_fr_insi_pkcs11_diagnostic_service.dart';

import 'core/speech/abak_whisper_speech_provider.dart';
import 'core/speech/speech_to_text_provider_registry.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final diagnostic =
    await const PatientFrInsiPkcs11DiagnosticService().diagnose();

    debugPrint(
      '🔐 Diagnostic PKCS#11 : $diagnostic',
    );
  } catch (e) {
    debugPrint(
      '❌ Diagnostic PKCS#11 : $e',
    );
  }

  await windowManager.ensureInitialized();

  const windowOptions = WindowOptions(
    size: Size(1400, 900),
    minimumSize: Size(1200, 800),
    center: true,
    title: 'ABAK Desktop Companion',
  );

  await DatabaseService.database;

  SpeechToTextProviderRegistry.register(
    AbakWhisperSpeechProvider(),
  );

  try {
    await LocalExchangeServer.instance.start();
  } on LocalExchangeServerAlreadyRunningException {
    runApp(const _AlreadyRunningApp());

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });

    return;
  }

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

class _AlreadyRunningApp extends StatelessWidget {
  const _AlreadyRunningApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ABAK Desktop Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        useMaterial3: true,
      ),
      home: const _AlreadyRunningScreen(),
    );
  }
}

class _AlreadyRunningScreen extends StatelessWidget {
  const _AlreadyRunningScreen();

  Future<void> _closeApplication() async {
    await windowManager.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Card(
            margin: const EdgeInsets.all(32),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'ABAK Desktop Companion est déjà ouvert',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Une seule instance peut être ouverte à la fois.\n\n'
                        'Utilisez la fenêtre Companion déjà ouverte.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _closeApplication,
                    child: const Text('Fermer'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
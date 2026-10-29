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
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:window_manager/window_manager.dart';

import 'generated/l10n.dart';
import 'app.dart';
import 'core/database/database_service.dart';
import 'core/settings/macos_launch_history_service.dart';
import 'features/import_export/data/import_session_repository.dart';
import 'features/local_exchange/services/airdrop_import_watcher.dart';
import 'features/local_exchange/services/local_exchange_server.dart';
import 'features/maintenance/data/database_backup_repository.dart';
import 'features/maintenance/services/local_backup_cleanup_service.dart';
import 'features/patients/services/patient_purge_service.dart';
import 'core/ui/app_messenger.dart';
import 'core/speech/abak_whisper_speech_provider.dart';
import 'core/speech/speech_to_text_provider_registry.dart';
import 'core/ui/macos_installation_guard.dart';
import 'core/maintenance/maintenance_session.dart';
import 'core/maintenance/maintenance_screen.dart';
import 'package:path_provider/path_provider.dart';

CompanionInstanceLock? _instanceLock;

Future<void> main(List<String> arguments) async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await _startApplication(StartupRequest.parse(arguments));
  } catch (error, stackTrace) {
    // Keep any normal-startup lock until exit: a partially started background
    // service must not coexist with a second owner of this database.
    debugPrint('Échec du démarrage : $error');
    debugPrintStack(stackTrace: stackTrace);
    runApp(const _StartupFailureApp());

    try {
      await windowManager.ensureInitialized();
      await windowManager.show();
      await windowManager.focus();
    } catch (windowError) {
      debugPrint('Impossible d’afficher la fenêtre : $windowError');
    }
  }
}

Future<void> _startApplication(StartupRequest request) async {
  // Separate read-only surface: no business routes, history writes, network,
  // imports, recovery, purges, speech, CPS or INSi startup is reachable here.
  if (request.maintenance) {
    final session = await MaintenanceSession.open(request);
    try {
      await windowManager.ensureInitialized();
      runApp(
        CompanionMaintenanceApp(
          session: session,
          coordinatedRequest: request.coordinatedPhase == null ? null : request,
          bundleRecipeRoot: request.bundleResourcesRecipe
              ? request.syntheticRoot
              : null,
        ),
      );
      await windowManager.waitUntilReadyToShow(
        const WindowOptions(
          size: Size(820, 620),
          center: true,
          title: 'ABAK Companion — Maintenance',
        ),
        () async {
          await windowManager.show();
          await windowManager.focus();
        },
      );
    } catch (_) {
      await session.close();
      rethrow;
    }
    return;
  }

  MacosLaunchSnapshot? launchSnapshot;
  // Ne pas polluer l’historique de la Release depuis une session de développement.
  if (Platform.isMacOS && kReleaseMode) {
    final location = await const MacosInstallationGuard().inspect();

    if (!location.isInstalled &&
        !MacosInstallationGuard.allowsOutsideApplications) {
      await windowManager.ensureInitialized();
      runApp(MacosInstallationRequiredApp(location: location));

      await windowManager.waitUntilReadyToShow(
        const WindowOptions(
          size: Size(800, 620),
          minimumSize: Size(640, 480),
          center: true,
          title: 'Installer ABAK Companion',
        ),
        () async {
          await windowManager.show();
          await windowManager.focus();
        },
      );

      return;
    }

    launchSnapshot = await const MacosLaunchHistoryService()
        .inspectBeforeStartup();
    if (launchSnapshot.kind == MacosLaunchKind.olderVersion) {
      await windowManager.ensureInitialized();
      runApp(_OlderVersionApp(snapshot: launchSnapshot));
      await windowManager.waitUntilReadyToShow(
        const WindowOptions(
          size: Size(720, 460),
          minimumSize: Size(600, 400),
          center: true,
          title: 'ABAK Companion — Version ancienne',
        ),
        () async {
          await windowManager.show();
          await windowManager.focus();
        },
      );
      return;
    }
  }

  await windowManager.ensureInitialized();

  final windowOptions = WindowOptions(
    size: const Size(1400, 900),
    minimumSize: const Size(1200, 800),
    center: true,
    title: launchSnapshot == null
        ? 'ABAK Desktop Companion'
        : 'ABAK Companion — ${launchSnapshot.current.label}',
  );

  // Kernel-backed lock before SQLite opens or migrates, independent of network.
  final support = await getApplicationSupportDirectory();
  await support.create(recursive: true);
  try {
    _instanceLock = await CompanionInstanceLock.acquire(
      File('${support.path}/.companion-instance.lock'),
    );
  } on CompanionAlreadyRunning {
    runApp(const _AlreadyRunningApp());
    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
    return;
  }
  await DatabaseService.database;

  SpeechToTextProviderRegistry.register(AbakWhisperSpeechProvider());

  try {
    await LocalExchangeServer.instance.start();
  } on LocalExchangeServerAlreadyRunningException {
    await DatabaseService.closeDatabase();
    await _instanceLock?.close();
    _instanceLock = null;
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

  // Backup retention is optional maintenance and must never block startup.
  try {
    final backupCleanupResult = await LocalBackupCleanupService(
      repository: DatabaseBackupRepository(),
    ).cleanupOldBackups();

    debugPrint(
      '🧹 purge sauvegardes SQLite : '
      '${backupCleanupResult.deletedCount} supprimée(s), '
      '${backupCleanupResult.keptCount} conservée(s), '
      '${backupCleanupResult.failedPaths.length} échec(s) de nettoyage',
    );
  } catch (error, stackTrace) {
    debugPrint(
      'Nettoyage des sauvegardes indisponible, démarrage poursuivi : $error',
    );
    debugPrintStack(stackTrace: stackTrace);
  }

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(AbakDesktopApp(launchSnapshot: launchSnapshot));
}

class _AlreadyRunningApp extends StatelessWidget {
  const _AlreadyRunningApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      title: 'ABAK Desktop Companion',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
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
    final s = S.of(context);
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
                    s.main_alreadyRunningTitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s.main_alreadyRunningMessage,
                    textAlign: TextAlign.center,
                  ),
                  FilledButton(
                    onPressed: _closeApplication,
                    child: Text(s.main_close),
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

class _StartupFailureApp extends StatelessWidget {
  const _StartupFailureApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 24),
                  const Text(
                    'Impossible de démarrer ABAK Companion',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Une erreur est survenue pendant le démarrage. '
                    'Fermez l’application et contactez l’assistance si le problème persiste.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => windowManager.close(),
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

/// Cet écran est affiché avant toute ouverture de la base par ce lancement.
class _OlderVersionApp extends StatelessWidget {
  const _OlderVersionApp({required this.snapshot});

  final MacosLaunchSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.update_disabled, size: 48),
                  const SizedBox(height: 20),
                  Text(
                    snapshot.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(snapshot.message, textAlign: TextAlign.center),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () => windowManager.close(),
                    child: const Text('Fermer cette copie'),
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

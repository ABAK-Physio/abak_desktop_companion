import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:window_manager/window_manager.dart';
import '../../generated/l10n.dart';
import '../settings/language_preference_service.dart';
import 'document_migration_gateway.dart';
import 'document_migration_dialog.dart';

/// Before background producers start; retains the existing instance lock.
/// An unfinished journal is presented before recover() can abandon or finalize it.
Future<bool> recoverDocumentsBeforeStartup(WindowOptions options) async {
  final gateway = LocalDocumentMigrationGateway();
  try {
    if ((await gateway.details()).isEmpty) {
      await gateway.recover();
      return true;
    }
  } catch (_) {
    // The dialog repeats the read-only diagnosis and presents recovery failures.
  }
  final decision = Completer<bool>();
  final language = await const LanguagePreferenceService().getLanguageCode();
  final locale = S.delegate.supportedLocales.firstWhere(
    (l) => l.languageCode == language.split('_').first,
    orElse: () => const Locale('fr', 'FR'),
  );
  runApp(
    MaterialApp(
      locale: locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: Scaffold(
        body: Center(
          child: DocumentMigrationDialog(
            gateway: gateway,
            recoveryOnly: true,
            onReady: () {
              if (!decision.isCompleted) decision.complete(true);
            },
            onQuit: () {
              if (!decision.isCompleted) decision.complete(false);
            },
          ),
        ),
      ),
    ),
  );
  await windowManager.waitUntilReadyToShow(options, () async {
    await windowManager.show();
    await windowManager.focus();
  });
  return decision.future;
}

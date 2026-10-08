import 'dart:io';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:window_manager/window_manager.dart';

import 'features/planning/prototype/planning_prototype_screen.dart';
import 'core/database/database_service.dart';
import 'features/planning/data/planning_repository.dart';

/// Dedicated planning entry point, using the shared Companion SQLite database.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('fr_FR');
  PackageStrings.setLocale('fr');
  if (Platform.isMacOS || Platform.isWindows || Platform.isLinux) {
    await windowManager.ensureInitialized();
    await windowManager.waitUntilReadyToShow(
      const WindowOptions(
        size: Size(1400, 900),
        minimumSize: Size(900, 650),
        center: true,
        title: 'ABAK — Prototype planning',
      ),
      () async {
        await windowManager.show();
        await windowManager.focus();
      },
    );
  }
  runApp(
    PlanningPrototypeApp(
      repository: PlanningRepository(database: () => DatabaseService.database),
    ),
  );
}

class PlanningPrototypeApp extends StatelessWidget {
  const PlanningPrototypeApp({super.key, this.repository});

  /// Null keeps the in-memory demo available to isolated widget tests.
  final PlanningRepository? repository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ABAK — Prototype planning',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: PlanningPrototypeScreen(repository: repository),
    );
  }
}

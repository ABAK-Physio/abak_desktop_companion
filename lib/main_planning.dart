import 'dart:io';

import 'package:calendar_view/calendar_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:window_manager/window_manager.dart';

import 'features/planning/prototype/planning_prototype_screen.dart';

/// Independent entry point: no Companion startup, repositories or persistence.
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
  runApp(const PlanningPrototypeApp());
}

class PlanningPrototypeApp extends StatelessWidget {
  const PlanningPrototypeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ABAK — Prototype planning',
      debugShowCheckedModeBanner: false,
      locale: const Locale('fr', 'FR'),
      supportedLocales: const [Locale('fr', 'FR')],
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const PlanningPrototypeScreen(),
    );
  }
}

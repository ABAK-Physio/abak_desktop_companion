import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/settings/language_preference_service.dart';
import 'core/ui/app_messenger.dart';
import 'features/dashboard/home_dashboard_screen.dart';
import 'generated/l10n.dart';

class AbakDesktopApp extends StatefulWidget {
  const AbakDesktopApp({super.key});

  @override
  State<AbakDesktopApp> createState() => _AbakDesktopAppState();
}

class _AbakDesktopAppState extends State<AbakDesktopApp> {
  final LanguagePreferenceService _languageService =
  const LanguagePreferenceService();

  Locale? _locale;

  @override
  void initState() {
    super.initState();
    _loadLocale();
  }

  Future<void> _loadLocale() async {
    final languageCode = await _languageService.getLanguageCode();

    if (!mounted) return;

    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: rootScaffoldMessengerKey,
      title: 'ABAK Desktop Companion',
      debugShowCheckedModeBanner: false,

      locale: _locale,

      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      supportedLocales: S.delegate.supportedLocales,

      theme: ThemeData(
        colorSchemeSeed: Colors.teal,
        useMaterial3: true,
      ),

      home: HomeDashboardScreen(
        onLocaleChanged: _loadLocale,
      ),
    );
  }
}
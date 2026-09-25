import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/settings/language_preference_service.dart';
import 'core/settings/macos_launch_history_service.dart';
import 'core/ui/app_messenger.dart';
import 'features/dashboard/home_dashboard_screen.dart';
import 'features/local_exchange/services/airdrop_import_watcher.dart';
import 'features/settings/settings_screen.dart';
import 'generated/l10n.dart';

class AbakDesktopApp extends StatefulWidget {
  const AbakDesktopApp({super.key, this.launchSnapshot});

  final MacosLaunchSnapshot? launchSnapshot;

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

      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),

      home: _LaunchNoticeHost(
        snapshot: widget.launchSnapshot,
        child: _HomeWithDirectoryStatus(
          onLocaleChanged: _loadLocale,
          versionLabel: widget.launchSnapshot?.current.label,
        ),
      ),
    );
  }
}

/// Affiche aussi les problèmes apparus avant runApp, sans bloquer les données.
class _HomeWithDirectoryStatus extends StatelessWidget {
  const _HomeWithDirectoryStatus({
    required this.onLocaleChanged,
    this.versionLabel,
  });

  final String? versionLabel;

  final VoidCallback onLocaleChanged;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: AirDropImportWatcher.instance.accessProblem,
      child: HomeDashboardScreen(onLocaleChanged: onLocaleChanged),
      builder: (context, problem, child) {
        return Column(
          children: [
            if (versionLabel != null)
              Material(
                color: Theme.of(context).colorScheme.surfaceContainerLow,
                child: SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    child: Text('ABAK Companion — $versionLabel'),
                  ),
                ),
              ),
            if (problem != null)
              Material(
                color: Theme.of(context).colorScheme.errorContainer,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.folder_off_outlined),
                        const SizedBox(width: 12),
                        Expanded(child: Text(problem)),
                        const SizedBox(width: 12),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push<void>(
                              MaterialPageRoute<void>(
                                builder: (context) => Scaffold(
                                  appBar: AppBar(title: Text(S.of(context).settings_title)),
                                  body: const SingleChildScrollView(
                                    padding: EdgeInsets.all(16),
                                    child: SettingsScreen(),
                                  ),
                                ),
                              ),
                            );
                          },
                          child: const Text('Rétablir l’accès'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            Expanded(child: child!),
          ],
        );
      },
    );
  }
}
/// Mémorise le démarrage réussi après l’affichage de l’accueil, sans dialogue.
class _LaunchNoticeHost extends StatefulWidget {
  const _LaunchNoticeHost({required this.snapshot, required this.child});

  final MacosLaunchSnapshot? snapshot;
  final Widget child;

  @override
  State<_LaunchNoticeHost> createState() => _LaunchNoticeHostState();
}

class _LaunchNoticeHostState extends State<_LaunchNoticeHost> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _finishSuccessfulLaunch();
    });
  }

  Future<void> _finishSuccessfulLaunch() async {
    final snapshot = widget.snapshot;
    if (snapshot == null || snapshot.kind == MacosLaunchKind.olderVersion) return;
    if (snapshot.kind == MacosLaunchKind.unchanged) return;

    try {
      await const MacosLaunchHistoryService().markSuccessful(snapshot);
    } catch (_) {
      if (!mounted) return;
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text(
            'La version démarrée n’a pas pu être mémorisée. '
                'Réessayez en redémarrant l’application.',
          ),
          duration: Duration(seconds: 8),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

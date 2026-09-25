import 'package:flutter/foundation.dart' show kReleaseMode;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:window_manager/window_manager.dart';

class MacosInstallationLocation {
  const MacosInstallationLocation({
    required this.actualPath,
    required this.expectedPath,
    required this.isInstalled,
  });

  final String actualPath;
  final String expectedPath;
  final bool isInstalled;
}

class MacosInstallationGuard {
  const MacosInstallationGuard();

  // Exception explicite réservée aux compilations Release locales.
  static const bool allowsOutsideApplications =
      kReleaseMode && String.fromEnvironment('ENV') == 'local_release';

  static const _channel = MethodChannel('abak/directory_access');

  Future<MacosInstallationLocation> inspect() async {
    final value = await _channel.invokeMapMethod<String, dynamic>(
      'getInstallationLocation',
    );
    final actual = value?['actualPath'];
    final expected = value?['expectedPath'];
    final installed = value?['isInstalled'];
    if (actual is! String || actual.isEmpty ||
        expected is! String || expected.isEmpty || installed is! bool) {
      throw StateError('Impossible de vérifier l’emplacement de Companion.');
    }
    return MacosInstallationLocation(
      actualPath: actual,
      expectedPath: expected,
      isInstalled: installed,
    );
  }

  Future<bool> openApplicationsFolder() async {
    return await _channel.invokeMethod<bool>('openApplicationsFolder') ?? false;
  }
}

/// Affiché avant l’ouverture des données si la Release est hors Applications.
class MacosInstallationRequiredApp extends StatelessWidget {
  const MacosInstallationRequiredApp({super.key, required this.location});

  final MacosInstallationLocation location;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Installer ABAK Companion',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: _InstallationRequiredScreen(location: location),
    );
  }
}

class _InstallationRequiredScreen extends StatefulWidget {
  const _InstallationRequiredScreen({required this.location});

  final MacosInstallationLocation location;

  @override
  State<_InstallationRequiredScreen> createState() =>
      _InstallationRequiredScreenState();
}

class _InstallationRequiredScreenState extends State<_InstallationRequiredScreen> {
  bool _opening = false;
  String? _error;

  Future<void> _openApplications() async {
    if (_opening) return;
    setState(() {
      _opening = true;
      _error = null;
    });
    try {
      final opened = await const MacosInstallationGuard().openApplicationsFolder();
      if (!opened && mounted) {
        setState(() => _error = 'Ouvrez le dossier Applications depuis le Finder.');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Ouvrez le dossier Applications depuis le Finder.');
      }
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.install_desktop, size: 48),
                const SizedBox(height: 20),
                const Text(
                  'Ouvrez ABAK Companion depuis Applications',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Cette copie est située hors de l’emplacement prévu. '
                      'Fermez-la, utilisez l’installateur PKG, puis ouvrez '
                      'Companion depuis le dossier Applications. '
                      'Si l’application y est déjà installée, ouvrez cette copie.',
                ),
                const SizedBox(height: 12),
                const Text(
                  'Un ancien alias du Bureau peut encore pointer vers '
                      'Téléchargements. Recréez-le depuis Applications.',
                ),
                const SizedBox(height: 12),
                const Text('Copie actuellement ouverte :'),
                SelectableText(widget.location.actualPath),
                const SizedBox(height: 8),
                const Text('Emplacement attendu :'),
                SelectableText(widget.location.expectedPath),
                const SizedBox(height: 16),
                const Text('La base de données n’a pas été ouverte par ce lancement.'),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ],
                const SizedBox(height: 24),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: _opening ? null : _openApplications,
                      child: const Text('Ouvrir Applications'),
                    ),
                    FilledButton(
                      onPressed: () => windowManager.close(),
                      child: const Text('Fermer cette copie'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

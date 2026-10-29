import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/settings/application_settings_service.dart';

/// Preference only: discovery never starts a browser or accesses a card.
class WebPsBrowserSettings extends StatefulWidget {
  const WebPsBrowserSettings({super.key});

  @override
  State<WebPsBrowserSettings> createState() => _WebPsBrowserSettingsState();
}

class _WebPsBrowserSettingsState extends State<WebPsBrowserSettings> {
  static const preferenceKey = 'dmp_webps_browser_macos';
  static const names = {
    'com.apple.Safari': 'Safari',
    'com.google.Chrome': 'Google Chrome',
    'org.mozilla.firefox': 'Firefox',
  };
  static const bundles = {
    'com.apple.Safari': 'Safari.app',
    'com.google.Chrome': 'Google Chrome.app',
    'org.mozilla.firefox': 'Firefox.app',
  };
  final settings = const ApplicationSettingsService();
  List<String> installed = [];
  String? selected, message;
  bool busy = true;

  @override
  void initState() {
    super.initState();
    refresh();
  }

  Future<void> refresh() async {
    setState(() => busy = true);
    try {
      final saved = await settings.getString(preferenceKey);
      final found = <String>[];
      if (Platform.isMacOS) {
        // Standard locations plus indexed bundles; no browser is launched.
        for (final id in names.keys) {
          final result = await Process.run('/usr/bin/mdfind', [
            'kMDItemCFBundleIdentifier == "$id"',
          ]).timeout(const Duration(seconds: 5));
          final home = Platform.environment['HOME'];
          final paths = <String>{
            '/Applications/${bundles[id]}',
            '/System/Applications/${bundles[id]}',
            if (home != null) '$home/Applications/${bundles[id]}',
            if (result.exitCode == 0)
              ...result.stdout
                  .toString()
                  .split('\n')
                  .where((p) => p.isNotEmpty),
          };
          for (final path in paths) {
            if (await Directory(path).exists()) {
              found.add(id);
              break;
            }
          }
        }
      }
      if (!mounted) return;
      setState(() {
        installed = found;
        selected = saved;
        message = saved != null && !found.contains(saved)
            ? 'Le navigateur enregistré est indisponible. Choisissez un navigateur installé.'
            : null;
      });
    } catch (_) {
      if (mounted) {
        setState(
          () => message = 'Impossible de vérifier les navigateurs. Réessayez.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> choose(String? id) async {
    if (id == null || !installed.contains(id)) return;
    setState(() => busy = true);
    try {
      await settings.setString(preferenceKey, id);
      if (mounted) {
        setState(() {
          selected = id;
          message =
              'Choix enregistré. Le fonctionnement avec la CPS reste à vérifier.';
        });
      }
    } catch (_) {
      if (mounted) setState(() => message = 'Choix non enregistré. Réessayez.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!Platform.isMacOS) return const SizedBox.shrink();
    final ids = {...installed, ?selected};
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<String>(
            key: ValueKey('$selected:${ids.join(",")}'),
            initialValue: selected,
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Navigateur pour le DMP',
            ),
            hint: const Text('Choisir un navigateur'),
            items: [
              for (final id in ids)
                DropdownMenuItem(
                  value: id,
                  enabled: installed.contains(id),
                  child: Text(
                    '${names[id] ?? "Navigateur enregistré"}${installed.contains(id) ? "" : " — indisponible"}',
                  ),
                ),
            ],
            onChanged: busy ? null : choose,
          ),
          const SizedBox(height: 8),
          const Text(
            'Firefox utilise la Cryptolib CPS. Safari et Chrome nécessitent CPS-Gestion. La présence du navigateur ne garantit pas son fonctionnement avec la CPS.',
          ),
          if (busy) const LinearProgressIndicator(),
          if (message != null) Text(message!),
          if (!busy && installed.isEmpty)
            const Text(
              'Aucun navigateur détecté. Installez un navigateur pris en charge, puis actualisez.',
            ),
          TextButton(
            onPressed: busy ? null : refresh,
            child: const Text('Actualiser les navigateurs'),
          ),
        ],
      ),
    );
  }
}

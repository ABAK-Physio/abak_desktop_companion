import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/settings/exchange_directory_service.dart';
import '../smart_card/screens/smart_card_diagnostic_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final ExchangeDirectoryService _exchangeDirectoryService =
  ExchangeDirectoryService();

  String? _exchangeDirectoryPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExchangeDirectory();
  }

  Future<void> _loadExchangeDirectory() async {
    final path =
    await _exchangeDirectoryService.getExchangeDirectoryPathLabel();

    if (!mounted) return;

    setState(() {
      _exchangeDirectoryPath = path;
      _isLoading = false;
    });
  }

  Future<void> _chooseExchangeDirectory() async {
    final selectedPath =
    await _exchangeDirectoryService.chooseDirectory();

    if (!mounted) return;

    if (selectedPath != null) {
      setState(() {
        _exchangeDirectoryPath = selectedPath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dossier d’échange ABAK mis à jour'),
        ),
      );
    }
  }

  Future<void> _resetExchangeDirectory() async {
    await _exchangeDirectoryService.resetDirectory();
    await _loadExchangeDirectory();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Dossier d’échange réinitialisé'),
      ),
    );
  }

  Future<void> _openExchangeDirectory() async {
    final path =
    await _exchangeDirectoryService.getExchangeDirectoryPathLabel();

    final directory = Directory(path);

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }

    if (Platform.isWindows) {
      await Process.run('explorer', [directory.path]);
    } else if (Platform.isMacOS) {
      await Process.run('open', [directory.path]);
    } else if (Platform.isLinux) {
      await Process.run('xdg-open', [directory.path]);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ouverture du dossier d’échange'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: 650,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Réglages de l’application',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 24),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.folder_open),
                    title: const Text('Dossier d’échange ABAK'),
                    subtitle: Text(
                      _isLoading
                          ? 'Chargement...'
                          : (_exchangeDirectoryPath ??
                          'Aucun dossier défini'),
                    ),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _openExchangeDirectory,
                          icon: const Icon(Icons.open_in_new),
                          label: const Text('Ouvrir'),
                        ),
                        OutlinedButton(
                          onPressed: _chooseExchangeDirectory,
                          child: const Text('Modifier'),
                        ),
                        IconButton(
                          tooltip: 'Réinitialiser',
                          onPressed: _resetExchangeDirectory,
                          icon: const Icon(Icons.restart_alt),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  icon: const Icon(Icons.credit_card),
                  label: const Text('Diagnostic Carte Vitale'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                        const SmartCardDiagnosticScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
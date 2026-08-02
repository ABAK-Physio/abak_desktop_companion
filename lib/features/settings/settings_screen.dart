import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/settings/exchange_directory_service.dart';
import 'package:abak_vitale/abak_vitale.dart';
import '../import_export/abak_import_launcher.dart';
import '../maintenance/backup_history_screen.dart';
import '../maintenance/services/local_database_reset_service.dart';

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
    final path = await _exchangeDirectoryService
        .getExchangeDirectoryPathLabel();

    if (!mounted) return;

    setState(() {
      _exchangeDirectoryPath = path;
      _isLoading = false;
    });
  }

  Future<void> _chooseExchangeDirectory() async {
    final selectedPath = await _exchangeDirectoryService.chooseDirectory();

    if (!mounted) return;

    if (selectedPath != null) {
      setState(() {
        _exchangeDirectoryPath = selectedPath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dossier d’échange ABAK mis à jour')),
      );
    }
  }

  Future<void> _resetExchangeDirectory() async {
    await _exchangeDirectoryService.resetDirectory();
    await _loadExchangeDirectory();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dossier d’échange réinitialisé')),
    );
  }

  Future<void> _openExchangeDirectory() async {
    final path = await _exchangeDirectoryService
        .getExchangeDirectoryPathLabel();

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
      const SnackBar(content: Text('Ouverture du dossier d’échange')),
    );
  }

  Future<void> _importAbakFile() async {
    await AbakImportLauncher.importArchiveFromPicker(context);
  }

  void _openBackupHistory() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const BackupHistoryScreen(),
      ),
    );
  }

  Future<void> _resetLocalDatabase() async {
    final messenger = ScaffoldMessenger.of(context);

    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Réinitialiser la base locale ?'),
          content: const Text(
            'Cette opération supprimera toutes les données locales '
                '(patients, résultats, imports et historiques).\n\n'
                'Une sauvegarde automatique sera créée avant la réinitialisation.\n\n'
                'Utilisez cette fonction uniquement lors d’une opération '
                'd’assistance technique.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Continuer'),
            ),
          ],
        );
      },
    );

    if (firstConfirm != true || !mounted) return;

    final controller = TextEditingController();

    final secondConfirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirmation obligatoire'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tapez RESET pour confirmer définitivement.',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'RESET',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                final valid =
                    controller.text.trim().toUpperCase() == 'RESET';

                Navigator.of(dialogContext).pop(valid);
              },
              child: const Text('Réinitialiser'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (secondConfirm != true) {
      if (!mounted) return;

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Confirmation invalide.'),
        ),
      );
      return;
    }

    final result = await LocalDatabaseResetService().resetDatabase();

    if (!mounted) return;

    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? 'Base réinitialisée. Sauvegarde automatique créée.'
              : 'Erreur lors de la réinitialisation : ${result.error}',
        ),
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
                  'Assistance',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 16),

                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Ces fonctions sont destinées à l’installation, au diagnostic '
                          'et aux opérations d’assistance technique.\n\n'
                          'Utilisez-les uniquement lorsqu’un technicien ou la '
                          'documentation ABAK vous le demande.',
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Configuration',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.folder_open),
                    title: const Text('Dossier d’échange ABAK'),
                    subtitle: Text(
                      _isLoading
                          ? 'Chargement...'
                          : (_exchangeDirectoryPath ?? 'Aucun dossier défini'),
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

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Diagnostic',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.credit_card),
                    label: const Text('Diagnostic Carte Vitale'),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const VitaleDiagnosticScreen(),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Maintenance',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _importAbakFile,
                      icon: const Icon(Icons.file_upload_outlined),
                      label: const Text('Importer manuellement un fichier .abak'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _openBackupHistory,
                      icon: const Icon(Icons.folder_copy_outlined),
                      label: const Text('Gérer les sauvegardes'),
                    ),
                    OutlinedButton.icon(
                      onPressed: _resetLocalDatabase,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      icon: const Icon(Icons.restart_alt_outlined),
                      label: const Text('Réinitialiser la base'),
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

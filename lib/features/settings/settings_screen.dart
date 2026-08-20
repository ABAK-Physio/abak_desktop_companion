import 'dart:io';
import '../../generated/l10n.dart';
import 'package:flutter/material.dart';

import '../../core/settings/exchange_directory_service.dart';
import 'package:abak_vitale/abak_vitale.dart';
import '../import_export/abak_import_launcher.dart';
import '../maintenance/backup_history_screen.dart';
import '../maintenance/services/local_database_reset_service.dart';
import '../import_export/import_resolution_assistant_screen.dart';

import '../../core/expert/expert_context_info.dart';
import '../../core/expert/expert_info_button.dart';
import '../../core/settings/application_settings_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ExpertContextInfo _expertInfo(S s) {
    return ExpertContextInfo(
      contextName: s.settings_contextName,
      sourceFile: 'lib/features/settings/settings_screen.dart',
      arbPrefix: 'settings',
      comment: s.settings_contextComment,
    );
  }

  final ApplicationSettingsService _applicationSettingsService =
  const ApplicationSettingsService();

  bool _expertModeEnabled = false;

  final ExchangeDirectoryService _exchangeDirectoryService =
      ExchangeDirectoryService();

  String? _exchangeDirectoryPath;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadExpertMode();
    _loadExchangeDirectory();
  }

  Future<void> _loadExpertMode() async {
    final expertModeEnabled =
    await _applicationSettingsService.isExpertModeEnabled();

    if (!mounted) return;

    setState(() {
      _expertModeEnabled = expertModeEnabled;
    });
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
    final s = S.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final firstConfirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(s.settings_resetDatabaseTitle),
          content: Text(
            s.settings_resetDatabaseWarning,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(s.settings_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(s.settings_continue),
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
          title: Text(s.settings_confirmationRequired),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                s.settings_typeResetConfirmation,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: s.settings_resetKeyword,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(s.settings_cancel),
            ),
            FilledButton(
              onPressed: () {
                final valid =
                    controller.text.trim().toUpperCase() == 'RESET';

                Navigator.of(dialogContext).pop(valid);
              },
              child: Text(s.settings_reset),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (secondConfirm != true) {
      if (!mounted) return;

      messenger.showSnackBar(
        SnackBar(
          content: Text(s.settings_invalidConfirmation),
        ),
      );
      return;
    }

    final result = await LocalDatabaseResetService().resetDatabase(
      databaseNotFoundMessage:
      s.localDatabaseBackup_databaseNotFound,
      chooseBackupFolderTitle:
      s.localDatabaseBackup_chooseBackupFolder,
      backupCancelledMessage:
      s.localDatabaseBackup_cancelled,
      backupFailedMessage:
          (error) => '${s.localDatabaseReset_backupFailed} : $error',
    );

    if (!mounted) return;
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? s.settings_databaseResetSuccess
              : s.settings_databaseResetError(result.error ?? ''),
        ),
      ),
    );
  }

  void _openImportResolutionAssistant() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ImportResolutionAssistantScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s=S.of(context);
    return Center(
      child: SizedBox(
        width: 650,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                   Expanded(
                      child: Text(
                        s.settings_title,
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                    if (_expertModeEnabled)
                    ExpertInfoButton(
                    info: _expertInfo(s),
                  ),
                  ],
                ),
                const SizedBox(height: 16),

                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      s.settings_assistanceWarning,
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    s.settings_configuration,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),

                Card(
                  child: ListTile(
                    leading: const Icon(Icons.folder_open),
                    title: Text(s.settings_exchangeDirectory),
                    subtitle: Text(
                      _isLoading
                          ? s.settings_loading
                          : (_exchangeDirectoryPath ?? s.settings_noDirectoryDefined),
                    ),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: _openExchangeDirectory,
                          icon: const Icon(Icons.open_in_new),
                          label: Text(s.settings_open),
                        ),
                        OutlinedButton(
                          onPressed: _chooseExchangeDirectory,
                          child: Text(s.settings_edit),
                        ),
                        IconButton(
                          tooltip: s.settings_resetTooltip,
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
                    s.settings_diagnostic,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),

                Align(
                  alignment: Alignment.centerLeft,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.credit_card),
                    label: Text(s.settings_vitaleDiagnostic),
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
                    s.settings_maintenance,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 8),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _openImportResolutionAssistant,
                      icon: const Icon(Icons.assistant_outlined),
                      label: Text(s.settings_resolveImportProblem),
                    ),
                    OutlinedButton.icon(
                      onPressed: _importAbakFile,
                      icon: const Icon(Icons.file_upload_outlined),
                      label: Text(s.settings_importAbakFile),
                    ),
                    OutlinedButton.icon(
                      onPressed: _openBackupHistory,
                      icon: const Icon(Icons.folder_copy_outlined),
                      label: Text(s.settings_manageBackups),
                    ),
                    OutlinedButton.icon(
                      onPressed: _resetLocalDatabase,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.error,
                      ),
                      icon: const Icon(Icons.restart_alt_outlined),
                      label: Text(s.settings_resetDatabase),
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

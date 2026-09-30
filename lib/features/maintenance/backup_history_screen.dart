import 'package:file_picker/file_picker.dart';
import 'widgets/maintenance_progress.dart';
import 'package:flutter/material.dart';
import 'package:abak_shared/abak_shared.dart';

import '../../core/expert/expert_context_info.dart';
import '../../core/expert/expert_info_button.dart';

import '../../core/utils/date_format_utils.dart';
import '../../generated/l10n.dart';
import 'data/database_backup_repository.dart';
import 'models/database_backup.dart';
import 'package:abak_desktop_companion/features/desktop_backup/services/local_database_restore_service.dart';

class BackupHistoryScreen extends StatefulWidget {
  const BackupHistoryScreen({super.key});

  @override
  State<BackupHistoryScreen> createState() => _BackupHistoryScreenState();
}

class _BackupHistoryScreenState extends State<BackupHistoryScreen> {
  final DatabaseBackupRepository _repository = DatabaseBackupRepository();
  final LocalDatabaseRestoreService _restoreService =
      const LocalDatabaseRestoreService();

  late Future<List<DatabaseBackup>> _futureBackups;

  @override
  void initState() {
    super.initState();
    _futureBackups = _repository.getBackups();
  }

  Future<void> _restoreBackup(String backupPath) async {
    final s = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(s.backupHistory_restoreTitle),
          content: Text(s.backupHistory_restoreWarning),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(s.backupHistory_cancel),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(context).pop(true),
              icon: const Icon(Icons.restore),
              label: Text(s.backupHistory_restore),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) return;

    final result = await withMaintenanceProgress(
      context,
      () => _restoreService.restoreDatabase(backupPath: backupPath),
    );

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(s.backupArchive_resultTitle),
        content: SingleChildScrollView(child: SelectableText(result.message)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (!mounted) return;

    setState(() {
      _futureBackups = _repository.getBackups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.folder_open),
            label: Text(s.backupArchive_chooseFile),
            onPressed: () async {
              final picked = await FilePicker.platform.pickFiles(
                dialogTitle: s.backupArchive_chooseFile,
                type: FileType.custom,
                allowedExtensions: ['zip', 'db'],
              );
              final path = picked?.files.single.path;
              if (path != null && mounted) await _restoreBackup(path);
            },
          ),
          ContextHelpButton(
            technicalInformationLabel: S.of(context).g_helpTooltip,
            title: s.backupHistory_title,
            content: s.backupHistory_help,
          ),
          ExpertModeInfoButton(
            info: ExpertContextInfo(
              contextName: s.backupHistory_title,
              sourceFile: 'lib/features/maintenance/backup_history_screen.dart',
              arbPrefix: 'backupHistory',
            ),
          ),
        ],
        title: Text(s.backupHistory_title),
      ),
      body: FutureBuilder<List<DatabaseBackup>>(
        future: _futureBackups,
        builder: (context, snapshot) {
          final backups = snapshot.data ?? [];

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (backups.isEmpty) {
            return Center(child: Text(s.backupHistory_empty));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: backups.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return _BackupTile(
                backup: backups[index],
                onRestore: () => _restoreBackup(backups[index].filePath),
              );
            },
          );
        },
      ),
    );
  }
}

class _BackupTile extends StatelessWidget {
  final DatabaseBackup backup;
  final VoidCallback onRestore;

  const _BackupTile({required this.backup, required this.onRestore});

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes o';

    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} Ko';

    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} Mo';
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);

    final formattedDate = DateFormatUtils.formatTimestamp(
      context,
      backup.createdAt,
    );

    return ListTile(
      leading: const Icon(Icons.save_outlined),
      title: Text(backup.fileName),
      subtitle: Text(
        '$formattedDate · ${_formatFileSize(backup.fileSize)}\n'
        '${backup.filePath}',
      ),
      isThreeLine: true,
      trailing: OutlinedButton.icon(
        onPressed: onRestore,
        icon: const Icon(Icons.restore),
        label: Text(s.backupHistory_restore),
      ),
    );
  }
}

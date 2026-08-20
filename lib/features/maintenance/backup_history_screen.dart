import 'package:flutter/material.dart';

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

  Future<void> _restoreBackup(DatabaseBackup backup) async {
    final s=S.of(context);
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

    final result = await _restoreService.restoreDatabase(
      backupPath: backup.filePath,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(result.message),
        backgroundColor: result.success ? Colors.green : Colors.red,
      ),
    );

    setState(() {
      _futureBackups = _repository.getBackups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s=S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.backupHistory_title)),
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
                onRestore: () => _restoreBackup(backups[index]),
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

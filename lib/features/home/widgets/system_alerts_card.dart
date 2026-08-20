import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
import '../../maintenance/models/system_health_snapshot.dart';
import '../../maintenance/services/system_health_service.dart';
import '../../../core/utils/date_format_utils.dart';

class SystemAlertsCard extends StatelessWidget {
  const SystemAlertsCard({super.key});

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes o';

    final kb = bytes / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} Ko';
    }

    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} Mo';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: FutureBuilder<SystemHealthSnapshot>(
        future: const SystemHealthService().loadSnapshot(),
        builder: (context, snapshot) {
          final health = snapshot.data;

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (health == null) {
            return const SizedBox.shrink();
          }

          final hasLargeDatabase = health.databaseSizeBytes > 500 * 1024 * 1024;

          final hasLargeBackupStorage =
              health.backupsTotalSizeBytes > 1024 * 1024 * 1024;

          final hasManyArchivedPatients = health.archivedPatientsCount >= 100;

          final recentRestore =
              health.lastRestoreAt != null &&
              DateTime.now()
                      .difference(
                        DateTime.fromMillisecondsSinceEpoch(
                          health.lastRestoreAt!,
                        ),
                      )
                      .inDays <=
                  7;

          final hasAlerts =
              health.hasFailedImports ||
              health.hasRunningImports ||
              health.hasNoBackup ||
              health.hasOldBackup ||
              hasLargeDatabase ||
              hasLargeBackupStorage ||
              hasManyArchivedPatients ||
              recentRestore;

          return ExpansionTile(
            initiallyExpanded: hasAlerts,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            leading: Icon(
              hasAlerts
                  ? Icons.warning_amber_outlined
                  : Icons.verified_outlined,
              color: hasAlerts
                  ? Theme.of(context).colorScheme.error
                  : Colors.green,
            ),
            title: Text(
              S.of(context).home_system_alert,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            children: [
              if (!hasAlerts)
                Text (
                S.of(context).home_no_alert_detected)
              else ...[
                if (health.hasFailedImports)
                  _AlertLine(
                    icon: Icons.error_outline,
                    label: S.of(context).home_imports_with_errors,
                    value: '${health.failedImportsCount}',
                    color: Theme.of(context).colorScheme.error,
                  ),

                if (health.hasRunningImports)
                  _AlertLine(
                    icon: Icons.sync_outlined,
                    label: S.of(context).home_imports_interrupted_or_in_progress,
                    value: '${health.runningImportsCount}',
                    color: Colors.blueGrey,
                  ),

                if (health.hasNoBackup)
                  _AlertLine(
                    icon: Icons.save_outlined,
                    label: S.of(context).home_no_saved_backup,
                    value: S.of(context).home_to_do_list,
                    color: Theme.of(context).colorScheme.error,
                  ),

                if (health.hasOldBackup)
                  _AlertLine(
                    icon: Icons.schedule_outlined,
                    label: S.of(context).home_last_old_backup,
                    value: S.of(context).home_more_7_days,
                    color: Colors.orange,
                  ),

                if (hasLargeDatabase)
                  _AlertLine(
                    icon: Icons.storage_outlined,
                    label: S.of(context).home_large_sqlite_database,
                    value: _formatBytes(health.databaseSizeBytes),
                    color: Colors.orange,
                  ),

                if (hasLargeBackupStorage)
                  _AlertLine(
                    icon: Icons.folder_outlined,
                    label: S.of(context).home_very_large_backups,
                    value: _formatBytes(health.backupsTotalSizeBytes),
                    color: Colors.orange,
                  ),

                if (hasManyArchivedPatients)
                  _AlertLine(
                    icon: Icons.archive_outlined,
                    label: S.of(context).home_large_number_of_archived_patients,
                    value: '${health.archivedPatientsCount}',
                    color: Colors.orange,
                  ),

                if (recentRestore)
                  _AlertLine(
                    icon: Icons.restore_outlined,
                    label: S.of(context).home_recent_restoration_detected,
                    value: DateFormatUtils.formatTimestampForDisplay(
                      context,
                      health.lastRestoreAt,
                    ),
                    color: Colors.blue,
                  ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _AlertLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _AlertLine({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

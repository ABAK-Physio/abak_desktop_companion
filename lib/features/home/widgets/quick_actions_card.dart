import 'package:flutter/material.dart';

import '../../import_export/abak_import_launcher.dart';
import '../../import_export/import_history_screen.dart';
import '../../maintenance/services/local_database_backup_service.dart';


class QuickActionsCard extends StatelessWidget {
  final ValueChanged<AbakImportLauncherResult>? onImportCompleted;
  final VoidCallback? onMaintenanceCompleted;

  const QuickActionsCard({
    super.key,
    this.onImportCompleted,
    this.onMaintenanceCompleted,
  });

  Widget _actionButton({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
    bool primary = false,
    Color? foregroundColor,
  }) {
    if (primary) {
      return FilledButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      style: foregroundColor == null
          ? null
          : OutlinedButton.styleFrom(foregroundColor: foregroundColor),
      icon: Icon(icon),
      label: Text(label),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.flash_on_outlined),
                const SizedBox(width: 8),
                Text(
                  'Actions rapides',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const Divider(height: 28),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _actionButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ImportHistoryScreen(),
                      ),
                    );
                  },
                  icon: Icons.history_outlined,
                  label: 'Historique des imports',
                ),
                _actionButton(
                  onPressed: () async {
                    final result = await LocalDatabaseBackupService()
                        .createBackup();

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result.success
                              ? 'Sauvegarde créée avec succès.'
                              : 'Erreur lors de la sauvegarde : ${result.error}',
                        ),
                      ),
                    );

                    if (result.success) {
                      onMaintenanceCompleted?.call();
                    }
                  },
                  icon: Icons.save_outlined,
                  label: 'Créer une sauvegarde',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

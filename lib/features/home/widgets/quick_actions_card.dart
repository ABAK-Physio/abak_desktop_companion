import '../../maintenance/widgets/maintenance_progress.dart';
import 'package:flutter/material.dart';

import '../../../generated/l10n.dart';
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
                Expanded(
                  child: Text(
                    S.of(context).home_quick_actions,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
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
                  label: S.of(context).home_import_history,
                ),
                _actionButton(
                  onPressed: () async {
                    final s = S.of(context);
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: const Text('Créer une sauvegarde'),
                        content: const SingleChildScrollView(
                          child: Text(
                            'La sauvegarde contient des données de santé. '
                                'Conservez-la dans un endroit protégé, accessible '
                                'uniquement aux personnes autorisées.\n\n'
                                'Privilégiez un support externe, par exemple une clé USB '
                                'ou un disque externe, afin de préserver votre sauvegarde '
                                'en cas de panne de l’ordinateur.',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(dialogContext).pop(false),
                            child: const Text('Annuler'),
                          ),
                          FilledButton(
                            onPressed: () => Navigator.of(dialogContext).pop(true),
                            child: const Text('Choisir l’emplacement'),
                          ),
                        ],
                      ),
                    );

                    if (confirmed != true || !context.mounted) return;
                    final result = await withMaintenanceProgress(
                      context,
                      () => LocalDatabaseBackupService().createBackup(
                        databaseNotFoundMessage:
                            s.localDatabaseBackup_databaseNotFound,
                        chooseBackupFolderTitle:
                            s.localDatabaseBackup_chooseBackupFolder,
                        cancelledMessage: s.localDatabaseBackup_cancelled,
                      ),
                    );

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result.success
                              ? S.of(context).home_backup_successfully_created
                              : S
                                    .of(context)
                                    .home_error_while_saving(
                                      result.error ?? '',
                                    ),
                        ),
                      ),
                    );

                    if (result.success) {
                      onMaintenanceCompleted?.call();
                    }
                  },
                  icon: Icons.save_outlined,
                  label: S.of(context).home_create_a_backup,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

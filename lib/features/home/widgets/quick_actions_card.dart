import 'package:flutter/material.dart';

import '../../import_export/abak_import_launcher.dart';
import '../../import_export/import_history_screen.dart';
import '../../maintenance/backup_history_screen.dart';
import '../../maintenance/services/local_database_backup_service.dart';
import '../../maintenance/services/local_database_reset_service.dart';

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
          : OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
      ),
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
                  primary: true,
                  onPressed: () async {
                    final result =
                    await AbakImportLauncher.importArchiveFromPicker(
                      context,
                    );

                    if (result != null) {
                      onImportCompleted?.call(result);
                    }
                  },
                  icon: Icons.file_upload_outlined,
                  label: 'Importer',
                ),
                _actionButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ImportHistoryScreen(),
                      ),
                    );
                  },
                  icon: Icons.history_outlined,
                  label: 'Historique',
                ),
                _actionButton(
                  onPressed: () async {
                    final result =
                    await LocalDatabaseBackupService().createBackup();

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
                _actionButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BackupHistoryScreen(),
                      ),
                    );
                  },
                  icon: Icons.folder_copy_outlined,
                  label: 'Gérer les sauvegardes',
                ),
                _actionButton(
                  foregroundColor: Colors.red,
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);

                    final firstConfirm = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text('Réinitialiser la base locale ?'),
                          content: const Text(
                            'Cette action supprimera toutes les données locales '
                                '(patients, résultats, imports, historiques).\n\n'
                                'Une sauvegarde automatique sera créée avant la réinitialisation.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: const Text('Annuler'),
                            ),
                            FilledButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: const Text('Continuer'),
                            ),
                          ],
                        );
                      },
                    );

                    if (firstConfirm != true) return;

                    final controller = TextEditingController();

                    if (!context.mounted) return;

                    final secondConfirm = await showDialog<bool>(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text('Confirmation obligatoire'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
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
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: const Text('Annuler'),
                            ),
                            FilledButton(
                              onPressed: () {
                                final valid =
                                    controller.text.trim().toUpperCase() ==
                                        'RESET';
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
                      if (!context.mounted) return;

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Confirmation invalide.'),
                        ),
                      );

                      return;
                    }

                    final result =
                    await LocalDatabaseResetService().resetDatabase();

                    if (!context.mounted) return;

                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          result.success
                              ? 'Base réinitialisée. Sauvegarde automatique créée.'
                              : 'Erreur lors de la réinitialisation : ${result.error}',
                        ),
                      ),
                    );

                    if (result.success) {
                      onMaintenanceCompleted?.call();
                    }
                  },
                  icon: Icons.restart_alt_outlined,
                  label: 'Réinitialiser la base',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
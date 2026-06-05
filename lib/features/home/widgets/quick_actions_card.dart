import 'package:flutter/material.dart';

import '../../import_export/abak_import_launcher.dart';
import '../../import_export/import_history_screen.dart';
import '../../settings/settings_screen.dart';
import '../../patients/services/patient_purge_service.dart';
import '../../maintenance/services/local_database_backup_service.dart';
import '../../maintenance/backup_history_screen.dart';
import '../../maintenance/services/local_database_reset_service.dart';

class QuickActionsCard extends StatelessWidget {
  final ValueChanged<AbakImportLauncherResult>? onImportCompleted;
  final VoidCallback? onMaintenanceCompleted;

  const QuickActionsCard({
    super.key,
    this.onImportCompleted,
    this.onMaintenanceCompleted,
  });

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
                FilledButton.icon(
                  onPressed: () async {
                    final result =
                    await AbakImportLauncher.importArchiveFromPicker(
                      context,
                    );

                    if (result != null) {
                      onImportCompleted?.call(result);
                    }
                  },
                  icon: const Icon(Icons.file_upload_outlined),
                  label: const Text('Importer'),
                ),

                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                        const ImportHistoryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.history_outlined),
                  label: const Text('Historique'),
                ),

                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                        const SettingsScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.settings_outlined),
                  label: const Text('Réglages'),
                ),

                OutlinedButton.icon(
                  onPressed: () async {
                    final result = await PatientPurgeService()
                        .purgeArchivedPatients();

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Purge terminée : '
                              '${result.deletedPatients} patient(s) supprimé(s) '
                              'sur ${result.scannedPatients} patient(s) archivé(s).',
                        ),
                      ),
                    );

                    onMaintenanceCompleted?.call();
                  },
                  icon: const Icon(Icons.cleaning_services_outlined),
                  label: const Text('Maintenance'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    final result =
                    await LocalDatabaseBackupService()
                        .createBackup();

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          result.success
                              ? 'Sauvegarde créée : ${result.backupPath}'
                              : 'Erreur sauvegarde : ${result.error}',
                        ),
                      ),
                    );

                    if (result.success) {
                      onMaintenanceCompleted?.call();
                    }
                  },
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Sauvegarde SQLite'),
                ),


                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
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
                              const Text('Tapez RESET pour confirmer définitivement.'),
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
                      if (!context.mounted) return;

                      messenger.showSnackBar(
                        const SnackBar(
                          content: Text('Confirmation invalide.'),
                        ),
                      );

                      return;
                    }

                    final result = await LocalDatabaseResetService().resetDatabase();

                    if (!context.mounted) return;

                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          result.success
                              ? 'Base réinitialisée. Sauvegarde : ${result.backupPath}'
                              : 'Erreur reset : ${result.error}',
                        ),
                      ),
                    );

                    if (result.success) {
                      onMaintenanceCompleted?.call();
                    }
                  },
                  icon: const Icon(Icons.restart_alt_outlined),
                  label: const Text('Réinitialiser DB'),
                ),


                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const BackupHistoryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.folder_copy_outlined),
                  label: const Text('Sauvegardes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
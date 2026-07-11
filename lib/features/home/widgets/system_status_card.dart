import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../import_export/data/import_session_repository.dart';
import '../../import_export/models/import_session.dart';
import '../../patients/services/patient_purge_service.dart';
import '../../maintenance/data/database_backup_repository.dart';
import '../../maintenance/models/database_backup.dart';

class SystemStatusCard extends StatelessWidget {
  const SystemStatusCard({super.key});

  @override
  Widget build(BuildContext context) {
    final importRepository = ImportSessionRepository();
    final patientPurgeService = PatientPurgeService();
    final backupRepository = DatabaseBackupRepository();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<dynamic>>(
          future: Future.wait([
            importRepository.getSessions(),
            patientPurgeService.previewArchivedPatientsPurge(),
            backupRepository.getLastBackup(),
          ]),
          builder: (context, snapshot) {
            final data = snapshot.data;

            final sessions = data == null
                ? <ImportSession>[]
                : data[0] as List<ImportSession>;

            final purgePreview = data == null
                ? null
                : data[1] as PatientPurgePreview;

            final lastBackup = data == null ? null : data[2] as DatabaseBackup?;

            final failedImports = sessions
                .where(
                  (session) =>
                      session.status == 'failed' ||
                      session.failedFilesCount > 0,
                )
                .length;

            final conflictCount = sessions.fold<int>(
              0,
              (total, session) => total + session.conflictResultsCount,
            );

            final hasWarning =
                failedImports > 0 ||
                conflictCount > 0 ||
                (purgePreview?.hasPurgeablePatients ?? false) ||
                lastBackup == null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monitor_heart_outlined),
                    const SizedBox(width: 8),
                    Text(
                      'État système',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const Divider(height: 28),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else ...[
                  _GeneralStatusLine(hasWarning: hasWarning),
                  const Divider(height: 28),
                  _StatusLine(
                    label: 'Imports à vérifier',
                    value: failedImports.toString(),
                    icon: Icons.error_outline,
                    isWarning: failedImports > 0,
                  ),
                  _StatusLine(
                    label: 'Patients à associer',
                    value: conflictCount.toString(),
                    icon: Icons.person_search_outlined,
                    isWarning: conflictCount > 0,
                  ),
                  if (purgePreview != null) ...[
                    const Divider(height: 28),
                    _StatusLine(
                      label: 'Patients archivés',
                      value: purgePreview.archivedPatients.toString(),
                      icon: Icons.archive_outlined,
                    ),
                    _StatusLine(
                      label: 'Dossiers supprimables',
                      value: purgePreview.purgeablePatients.toString(),
                      icon: Icons.delete_sweep_outlined,
                      isWarning: purgePreview.hasPurgeablePatients,
                    ),
                  ],
                  const Divider(height: 28),
                  _StatusLine(
                    label: 'Dernière sauvegarde',
                    value: _formatLastBackup(lastBackup),
                    icon: Icons.save_outlined,
                    isWarning: lastBackup == null,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatLastBackup(DatabaseBackup? lastBackup) {
    if (lastBackup == null) {
      return 'Aucune';
    }

    return DateFormat(
      'dd/MM/yyyy HH:mm',
    ).format(DateTime.fromMillisecondsSinceEpoch(lastBackup.createdAt));
  }
}

class _GeneralStatusLine extends StatelessWidget {
  final bool hasWarning;

  const _GeneralStatusLine({required this.hasWarning});

  @override
  Widget build(BuildContext context) {
    final color = hasWarning
        ? Theme.of(context).colorScheme.error
        : Colors.green;

    return Row(
      children: [
        Icon(
          hasWarning
              ? Icons.warning_amber_outlined
              : Icons.check_circle_outline,
          size: 22,
          color: color,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            hasWarning
                ? 'Une intervention est nécessaire'
                : 'Tout fonctionne normalement',
            style: TextStyle(fontWeight: FontWeight.w600, color: color),
          ),
        ),
      ],
    );
  }
}

class _StatusLine extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isWarning;

  const _StatusLine({
    required this.label,
    required this.value,
    required this.icon,
    this.isWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isWarning
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;

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

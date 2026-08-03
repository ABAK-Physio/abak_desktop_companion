import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../import_export/data/import_session_repository.dart';
import '../../import_export/import_resolution_assistant_screen.dart';
import '../../import_export/models/import_session.dart';
import '../../maintenance/data/database_backup_repository.dart';
import '../../maintenance/models/database_backup.dart';
import '../../patients/services/patient_purge_service.dart';

class SystemStatusCard extends StatefulWidget {
  const SystemStatusCard({super.key});

  @override
  State<SystemStatusCard> createState() => _SystemStatusCardState();
}

class _SystemStatusCardState extends State<SystemStatusCard> {
  Timer? _timer;
  late Future<List<dynamic>> _statusFuture;

  @override
  void initState() {
    super.initState();

    _statusFuture = _loadStatus();

    _timer = Timer.periodic(
      const Duration(seconds: 3),
          (_) => _refreshStatus(),
    );
  }

  Future<List<dynamic>> _loadStatus() {
    final importRepository = ImportSessionRepository();
    final patientPurgeService = PatientPurgeService();
    final backupRepository = DatabaseBackupRepository();

    return Future.wait([
      importRepository.getSessions(),
      patientPurgeService.previewArchivedPatientsPurge(),
      backupRepository.getLastBackup(),
    ]);
  }

  void _refreshStatus() {
    if (!mounted) return;

    setState(() {
      _statusFuture = _loadStatus();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<dynamic>>(
          future: _statusFuture,
          builder: (context, snapshot) {
            final data = snapshot.data;

            final sessions = data == null
                ? <ImportSession>[]
                : data[0] as List<ImportSession>;

            final purgePreview = data == null
                ? null
                : data[1] as PatientPurgePreview;

            final lastBackup = data == null
                ? null
                : data[2] as DatabaseBackup?;

            final failedImports = sessions.where((session) {
              return session.status == 'failed' ||
                  session.failedFilesCount > 0;
            }).length;

            final importsWithWarnings = sessions.where((session) {
              return session.status == 'completed_with_errors' ||
                  session.conflictResultsCount > 0 ||
                  session.skippedResultsCount > 0;
            }).length;

            final hasImportProblem =
                failedImports > 0 || importsWithWarnings > 0;

            final hasWarning =
                hasImportProblem ||
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
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else ...[
                  _GeneralStatusLine(hasWarning: hasWarning),
                  if (hasImportProblem) ...[
                    const Divider(height: 28),
                    _ImportStatusSection(
                      failedImports: failedImports,
                      importsWithWarnings: importsWithWarnings,
                      onResolutionCompleted: _refreshStatus,
                    ),
                  ],
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

    return DateFormat('dd/MM/yyyy HH:mm').format(
      DateTime.fromMillisecondsSinceEpoch(lastBackup.createdAt),
    );
  }
}

class _GeneralStatusLine extends StatelessWidget {
  final bool hasWarning;

  const _GeneralStatusLine({
    required this.hasWarning,
  });

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
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _ImportStatusSection extends StatelessWidget {
  final int failedImports;
  final int importsWithWarnings;
  final VoidCallback onResolutionCompleted;

  const _ImportStatusSection({
    required this.failedImports,
    required this.importsWithWarnings,
    required this.onResolutionCompleted,
  });

  Future<void> _openAssistant(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ImportResolutionAssistantScreen(),
      ),
    );

    onResolutionCompleted();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (failedImports > 0)
          _ImportStatusLine(
            icon: Icons.error_outline,
            label:
            '$failedImports import'
                '${failedImports > 1 ? 's' : ''} en échec',
            color: Theme.of(context).colorScheme.error,
            buttonLabel: 'Résoudre',
            onPressed: () => _openAssistant(context),
          ),
        if (importsWithWarnings > 0)
          _ImportStatusLine(
            icon: Icons.warning_amber_outlined,
            label:
            '$importsWithWarnings import'
                '${importsWithWarnings > 1 ? 's' : ''} à vérifier',
            color: Colors.orange,
            buttonLabel: 'Vérifier',
            onPressed: () => _openAssistant(context),
          ),
      ],
    );
  }
}

class _ImportStatusLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _ImportStatusLine({
    required this.icon,
    required this.label,
    required this.color,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 22,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
          OutlinedButton(
            onPressed: onPressed,
            child: Text(buttonLabel),
          ),
        ],
      ),
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
          Icon(
            icon,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(label),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
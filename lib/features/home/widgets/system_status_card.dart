import 'dart:async';

import 'package:flutter/material.dart';
import '../../../core/utils/date_format_utils.dart';

import '../../../generated/l10n.dart';

import '../../import_export/data/import_session_repository.dart';
import '../../import_export/import_resolution_assistant_screen.dart';
import '../../import_export/models/import_session.dart';
import '../../maintenance/data/database_backup_repository.dart';
import '../../maintenance/models/database_backup.dart';

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
    final backupRepository = DatabaseBackupRepository();

    return Future.wait([
      importRepository.getSessions(),
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

            final lastBackup = data == null
                ? null
                : data[1] as DatabaseBackup?;

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
                    lastBackup == null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.monitor_heart_outlined),
                    const SizedBox(width: 8),
                    Text(S.of(context).home_system_status,
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
                  const Divider(height: 28),
                  _StatusLine(
                    label: S.of(context).home_last_backup,
                    value: _formatLastBackup(
                      context,
                      lastBackup,
                    ),
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

  String _formatLastBackup(
      BuildContext context,
      DatabaseBackup? lastBackup,
      ) {
    if (lastBackup == null) {
      return S.of(context).systemStatusCard_nome;
    }

    return DateFormatUtils.formatTimestamp(
      context,
      lastBackup.createdAt,
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
                ? S.of(context).home_an_intervention_is_necessary
                : S.of(context).home_everything_is_working_normally,
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
                '${failedImports > 1 ? 's' : ''} ${S.of(context).home_unsuccessful}',
            color: Theme.of(context).colorScheme.error,
            buttonLabel: S.of(context).home_solve,
            onPressed: () => _openAssistant(context),
          ),
        if (importsWithWarnings > 0)
          _ImportStatusLine(
            icon: Icons.warning_amber_outlined,
            label:
            '$importsWithWarnings import'
                '${importsWithWarnings > 1 ? 's' : ''} ${S.of(context).home_to_be_verified}',
            color: Colors.orange,
            buttonLabel: S.of(context).home_verify,
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
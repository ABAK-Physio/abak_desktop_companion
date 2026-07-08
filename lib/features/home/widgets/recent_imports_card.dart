import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../import_export/data/import_session_repository.dart';
import '../../import_export/import_history_screen.dart';
import '../../import_export/models/import_session.dart';
import '../../import_export/import_session_detail_screen.dart';

class RecentImportsCard extends StatefulWidget {
  const RecentImportsCard({super.key});

  @override
  State<RecentImportsCard> createState() => _RecentImportsCardState();
}

class _RecentImportsCardState extends State<RecentImportsCard> {
  final ImportSessionRepository repository = ImportSessionRepository();
  late Future<List<ImportSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _sessionsFuture = repository.getSessions();
  }

  void _refreshSessions() {
    setState(() {
      _sessionsFuture = repository.getSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: FutureBuilder<List<ImportSession>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          final sessions = snapshot.hasData
              ? snapshot.data!.take(5).toList()
              : <ImportSession>[];

          return ExpansionTile(
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            leading: const Icon(Icons.history_outlined),
            title: Text(
              'Imports récents',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ImportHistoryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.open_in_new_outlined, size: 18),
                  label: const Text('Historique'),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.expand_more),
              ],
            ),
            children: [
              if (snapshot.connectionState == ConnectionState.waiting)
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (snapshot.hasError)
                Text(
                  'Impossible de charger les imports récents.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else if (sessions.isEmpty)
                  Text(
                    'Aucun import enregistré.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  )
                else
                  ...sessions.map(
                        (session) => _RecentImportTile(
                      session: session,
                      onChanged: _refreshSessions,
                    ),
                  ),
            ],
          );
        },
      ),
    );
  }
}

class _RecentImportTile extends StatelessWidget {
  final ImportSession session;
  final VoidCallback onChanged;

  const _RecentImportTile({
    required this.session,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      session.completedAt ?? session.startedAt,
    );

    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);

    final needsResolution = session.status == 'needs_resolution';
    final hasErrors =
        session.failedFilesCount > 0 || session.status == 'failed';
    final hasConflicts = session.conflictResultsCount > 0;

    final icon = hasErrors
        ? Icons.error_outline
        : (needsResolution || hasConflicts)
        ? Icons.warning_amber_outlined
        : Icons.check_circle_outline;

    final color = hasErrors
        ? Theme.of(context).colorScheme.error
        : (needsResolution || hasConflicts)
        ? Colors.orange
        : Colors.green;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: color),
      title: Row(
        children: [
          Expanded(child: Text(formattedDate)),
          _StatusChip(status: session.status),
        ],
      ),
      subtitle: _ImportSummary(session: session),
      onTap: () async {
        final changed = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => ImportSessionDetailScreen(session: session),
          ),
        );

        if (changed == true) {
          onChanged();
        }
      },
    );
  }
}

class _ImportSummary extends StatelessWidget {
  final ImportSession session;

  const _ImportSummary({
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final lines = <Widget>[];

    if (session.summaryPatientLabel != null &&
        session.summaryPatientLabel!.isNotEmpty) {
      lines.add(
        Text(
          session.summaryPatientLabel!,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      );
    }

    if (session.summaryEpisodeLabel != null &&
        session.summaryEpisodeLabel!.isNotEmpty) {
      lines.add(Text(session.summaryEpisodeLabel!));
    }

    if (session.summaryExercisesLabel != null &&
        session.summaryExercisesLabel!.isNotEmpty) {
      lines.add(
        Text(
          session.summaryExercisesLabel!,
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      );
    }

    if (session.status == 'needs_resolution') {
      lines.add(
        Text(
          'Action requise : associer ce dossier à un patient',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    } else if (session.conflictResultsCount > 0) {
      lines.add(
        const Text(
          'Conflit détecté',
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    if (lines.isEmpty) {
      lines.add(
        Text(
          _legacySummary(session),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines,
    );
  }

  static String _legacySummary(ImportSession session) {
    final parts = <String>[];

    if (session.processedFilesCount > 0) {
      parts.add('${session.processedFilesCount} fichier');
    }

    if (session.importedResultsCount > 0) {
      parts.add('${session.importedResultsCount} résultat');
    }

    if (session.skippedResultsCount > 0) {
      parts.add('${session.skippedResultsCount} ignoré');
    }

    if (session.conflictResultsCount > 0) {
      parts.add('${session.conflictResultsCount} conflit');
    }

    if (session.failedFilesCount > 0) {
      parts.add('${session.failedFilesCount} erreur');
    }

    return parts.isEmpty
        ? 'Aucun résultat importé'
        : parts.join(' · ');
  }
}

class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    late final String label;
    late final Color color;
    late final IconData icon;

    switch (status) {
      case 'completed':
        label = 'Succès';
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;

      case 'completed_with_errors':
        label = 'Attention';
        color = Colors.orange;
        icon = Icons.warning_amber_outlined;
        break;

      case 'failed':
        label = 'Échec';
        color = Theme.of(context).colorScheme.error;
        icon = Icons.error_outline;
        break;

      case 'needs_resolution':
        label = 'Action requise';
        color = Colors.orange;
        icon = Icons.warning_amber_outlined;
        break;

      default:
        label = status;
        color = Colors.grey;
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../import_export/data/import_session_repository.dart';
import '../../import_export/import_history_screen.dart';
import '../../import_export/models/import_session.dart';
import '../../import_export/import_session_detail_screen.dart';

class RecentImportsCard extends StatelessWidget {
  const RecentImportsCard({super.key});

  @override
  @override
  Widget build(BuildContext context) {
    final repository = ImportSessionRepository();

    return Card(
      child: FutureBuilder<List<ImportSession>>(
        future: repository.getSessions(),
        builder: (context, snapshot) {
          final sessions = (snapshot.data ?? []).take(5).toList();

          return ExpansionTile(
            initiallyExpanded: true,
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            childrenPadding: const EdgeInsets.fromLTRB(
              20,
              0,
              20,
              20,
            ),
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
                  icon: const Icon(
                    Icons.open_in_new_outlined,
                    size: 18,
                  ),
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
                  child: Center(
                    child: CircularProgressIndicator(),
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
                      (session) => _RecentImportTile(session: session),
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

  const _RecentImportTile({
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      session.completedAt ?? session.startedAt,
    );

    final formattedDate = DateFormat('dd/MM/yyyy HH:mm').format(date);

    final hasErrors = session.failedFilesCount > 0;
    final hasConflicts = session.conflictResultsCount > 0;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        hasErrors
            ? Icons.error_outline
            : hasConflicts
            ? Icons.warning_amber_outlined
            : Icons.check_circle_outline,
        color: hasErrors
            ? Theme.of(context).colorScheme.error
            : hasConflicts
            ? Colors.orange
            : Colors.green,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(formattedDate),
          ),
          _StatusChip(
            status: session.status,
          ),
        ],
      ),
      subtitle: Text(
        [
          '${session.processedFilesCount} fichier(s)',
          '${session.importedResultsCount} résultat(s)',
          '${session.skippedResultsCount} ignoré(s)',
          '${session.conflictResultsCount} conflit(s)',
          if (session.failedFilesCount > 0)
            '${session.failedFilesCount} erreur(s)',
        ].join(' · '),
      ),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ImportSessionDetailScreen(
              session: session,
            ),
          ),
        );
      },
    );
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
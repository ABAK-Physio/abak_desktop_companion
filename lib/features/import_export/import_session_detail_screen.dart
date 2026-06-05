import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'data/import_session_repository.dart';
import 'models/import_session.dart';
import 'models/import_session_file.dart';

class ImportSessionDetailScreen extends StatelessWidget {
  final ImportSession session;

  const ImportSessionDetailScreen({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final repository = ImportSessionRepository();

    final startedDate =
    DateTime.fromMillisecondsSinceEpoch(session.startedAt);

    final completedDate = session.completedAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(session.completedAt!);

    final formatter = DateFormat.yMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_Hm();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail import'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Résumé de la session',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Divider(height: 28),
                  _InfoRow(
                    label: 'Début',
                    value: formatter.format(startedDate),
                  ),
                  _InfoRow(
                    label: 'Fin',
                    value: completedDate == null
                        ? 'Non terminée'
                        : formatter.format(completedDate),
                  ),
                  _InfoRow(
                    label: 'Fichiers traités',
                    value: session.processedFilesCount.toString(),
                  ),
                  _InfoRow(
                    label: 'Fichiers en erreur',
                    value: session.failedFilesCount.toString(),
                  ),
                  _InfoRow(
                    label: 'Résultats importés',
                    value: session.importedResultsCount.toString(),
                  ),
                  _InfoRow(
                    label: 'Résultats ignorés',
                    value: session.skippedResultsCount.toString(),
                  ),
                  _InfoRow(
                    label: 'Conflits détectés',
                    value: session.conflictResultsCount.toString(),
                  ),
                  _InfoRow(
                    label: 'Métriques importées',
                    value: session.importedMetricsCount.toString(),
                  ),
                  if (session.sourceLabel != null)
                    _InfoRow(
                      label: 'Source',
                      value: session.sourceLabel!,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<ImportSessionFile>>(
            future: repository.getFilesForSession(session.importSessionId),
            builder: (context, snapshot) {
              final files = snapshot.data ?? [];

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (files.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Aucun fichier associé.'),
                  ),
                );
              }

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fichiers traités',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const Divider(height: 28),
                      ...files.map(
                            (file) => _ImportFileTile(file: file),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ImportFileTile extends StatelessWidget {
  final ImportSessionFile file;

  const _ImportFileTile({
    required this.file,
  });

  String _formatFileSize(int? bytes) {
    if (bytes == null) return 'Taille inconnue';

    if (bytes < 1024) {
      return '$bytes o';
    }

    final kb = bytes / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} Ko';
    }

    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} Mo';
  }

  @override
  Widget build(BuildContext context) {
    final isError = file.status == 'error';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        isError ? Icons.error_outline : Icons.check_circle_outline,
        color: isError
            ? Theme.of(context).colorScheme.error
            : null,
      ),
      title: Text(file.fileName),
      subtitle: Text(
        isError
            ? '${_formatFileSize(file.fileSize)} · '
            '${file.errorMessage ?? 'Erreur inconnue'}'
            : '${_formatFileSize(file.fileSize)} · '
            '${file.importedResultsCount} importé(s), '
            '${file.skippedResultsCount} ignoré(s), '
            '${file.conflictResultsCount} conflit(s), '
            '${file.importedMetricsCount} métrique(s)',
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }
}
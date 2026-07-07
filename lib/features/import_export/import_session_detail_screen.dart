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
          _BusinessSummaryCard(
            session: session,
            dateLabel: completedDate == null
                ? formatter.format(startedDate)
                : formatter.format(completedDate),
          ),
          const SizedBox(height: 16),
          _ImportReportCard(
            session: session,
            startedLabel: formatter.format(startedDate),
            completedLabel: completedDate == null
                ? 'Non terminé'
                : formatter.format(completedDate),
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
                        'Fichiers',
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

class _BusinessSummaryCard extends StatelessWidget {
  final ImportSession session;
  final String dateLabel;

  const _BusinessSummaryCard({
    required this.session,
    required this.dateLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _statusTitle(session),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              dateLabel,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const Divider(height: 28),
            _InfoRow(
              label: 'Patient',
              value: _valueOrUnknown(session.summaryPatientLabel),
            ),
            _InfoRow(
              label: 'Suivi clinique',
              value: _valueOrUnknown(session.summaryEpisodeLabel),
            ),
            _InfoRow(
              label: 'Activité importée',
              value: _valueOrUnknown(session.summaryExercisesLabel),
            ),
          ],
        ),
      ),
    );
  }

  static String _statusTitle(ImportSession session) {
    if (session.status == 'needs_resolution') {
      return 'Import en attente de résolution';
    }

    if (session.failedFilesCount > 0 || session.status == 'failed') {
      return 'Import en échec';
    }

    if (session.conflictResultsCount > 0 ||
        session.skippedResultsCount > 0 ||
        session.status == 'completed_with_errors') {
      return 'Import terminé avec avertissement';
    }

    return 'Import réalisé avec succès';
  }

  static String _valueOrUnknown(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Non renseigné';
    }
    return value;
  }
}

class _ImportReportCard extends StatelessWidget {
  final ImportSession session;
  final String startedLabel;
  final String completedLabel;

  const _ImportReportCard({
    required this.session,
    required this.startedLabel,
    required this.completedLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Compte rendu d’import',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const Divider(height: 28),
            _ImportReportMessage(session: session),
            const SizedBox(height: 16),
            _InfoRow(label: 'Début', value: startedLabel),
            _InfoRow(label: 'Fin', value: completedLabel),
            _InfoRow(
              label: 'Fichiers traités',
              value: session.processedFilesCount.toString(),
            ),
            _InfoRow(
              label: 'Résultats importés',
              value: session.importedResultsCount.toString(),
            ),
            if (session.skippedResultsCount > 0)
              _InfoRow(
                label: 'Résultats ignorés',
                value: session.skippedResultsCount.toString(),
              ),
            if (session.conflictResultsCount > 0)
              _InfoRow(
                label: 'Conflits détectés',
                value: session.conflictResultsCount.toString(),
              ),
            if (session.failedFilesCount > 0)
              _InfoRow(
                label: 'Fichiers en erreur',
                value: session.failedFilesCount.toString(),
              ),
            if (session.sourceLabel != null)
              _InfoRow(
                label: 'Source',
                value: session.sourceLabel!,
              ),
          ],
        ),
      ),
    );
  }
}

class _ImportReportMessage extends StatelessWidget {
  final ImportSession session;

  const _ImportReportMessage({
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    final style = _messageStyle(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: style.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: style.color.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            style.icon,
            color: style.color,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _reportText(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: style.color,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  _ImportReportMessageStyle _messageStyle(BuildContext context) {
    if (session.failedFilesCount > 0 || session.status == 'failed') {
      return _ImportReportMessageStyle(
        icon: Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
      );
    }

    if (session.status == 'needs_resolution' ||
        session.conflictResultsCount > 0 ||
        session.skippedResultsCount > 0 ||
        session.status == 'completed_with_errors') {
      return const _ImportReportMessageStyle(
        icon: Icons.warning_amber_outlined,
        color: Colors.orange,
      );
    }

    return const _ImportReportMessageStyle(
      icon: Icons.check_circle_outline,
      color: Colors.green,
    );
  }

  String _reportText() {
    if (session.status == 'needs_resolution') {
      return 'Le fichier a été reçu, mais l’import n’a pas encore été finalisé.';
    }

    if (session.failedFilesCount > 0 || session.status == 'failed') {
      return 'L’import n’a pas pu être terminé correctement. Consulter le détail des fichiers pour identifier la cause.';
    }

    if (session.conflictResultsCount > 0) {
      return 'Un conflit a été détecté entre les données importées et les données déjà présentes. Une vérification est recommandée.';
    }

    if (session.skippedResultsCount > 0 && session.importedResultsCount == 0) {
      return 'Aucun nouveau résultat n’a été importé. Les résultats étaient probablement déjà présents dans Companion.';
    }

    if (session.skippedResultsCount > 0) {
      return 'L’import est terminé. Certains résultats ont été ignorés car ils étaient déjà présents.';
    }

    return 'L’import est terminé sans anomalie détectée.';
  }
}

class _ImportReportMessageStyle {
  final IconData icon;
  final Color color;

  const _ImportReportMessageStyle({
    required this.icon,
    required this.color,
  });
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
        color: isError ? Theme.of(context).colorScheme.error : null,
      ),
      title: Text(file.fileName),
      subtitle: Text(
        isError
            ? '${_formatFileSize(file.fileSize)} · '
            '${file.errorMessage ?? 'Erreur inconnue'}'
            : '${_formatFileSize(file.fileSize)} · '
            '${file.importedResultsCount} importé(s), '
            '${file.skippedResultsCount} ignoré(s), '
            '${file.conflictResultsCount} conflit(s)',
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
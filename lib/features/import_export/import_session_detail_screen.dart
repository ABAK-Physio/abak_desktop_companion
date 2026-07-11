import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'data/import_session_repository.dart';
import 'models/import_session.dart';
import 'models/import_session_file.dart';
import 'abak_import_launcher.dart';

enum ImportActionKind { associatePatient, deleteImport }

class ImportActionInfo {
  final String title;
  final String message;
  final IconData icon;
  final Color color;
  final List<ImportActionKind> actions;

  const ImportActionInfo({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.actions,
  });

  bool get canAssociatePatient =>
      actions.contains(ImportActionKind.associatePatient);

  bool get canDeleteImport => actions.contains(ImportActionKind.deleteImport);
}

class ImportActionInfoService {
  const ImportActionInfoService();

  ImportActionInfo describe(BuildContext context, ImportSession session) {
    if (session.status == 'needs_resolution') {
      return const ImportActionInfo(
        title: 'Association patient requise',
        message:
            'Le fichier a bien été reçu. Pour terminer l’import, associez ce dossier à un patient.',
        icon: Icons.person_search,
        color: Colors.orange,
        actions: [
          ImportActionKind.associatePatient,
          ImportActionKind.deleteImport,
        ],
      );
    }

    if (session.failedFilesCount > 0 || session.status == 'failed') {
      return ImportActionInfo(
        title: 'Import impossible',
        message:
            'L’import n’a pas pu être terminé. Consultez le détail des fichiers, puis supprimez cet import s’il ne peut pas être corrigé.',
        icon: Icons.error_outline,
        color: Theme.of(context).colorScheme.error,
        actions: const [ImportActionKind.deleteImport],
      );
    }

    if (session.conflictResultsCount > 0 ||
        session.skippedResultsCount > 0 ||
        session.status == 'completed_with_errors') {
      return const ImportActionInfo(
        title: 'Import terminé avec avertissement',
        message:
        'L’import est terminé, mais certains résultats n’ont pas pu être '
            'importés ou nécessitent une vérification.',
        icon: Icons.warning_amber_outlined,
        color: Colors.orange,
        actions: [],
      );
    }

    if (session.duplicateResultsCount > 0) {
      return const ImportActionInfo(
        title: 'Import réalisé avec succès',
        message:
        'L’import est terminé. Les résultats déjà présents ont été '
            'reconnus et n’ont pas été importés une seconde fois.',
        icon: Icons.check_circle_outline,
        color: Colors.green,
        actions: [],
      );
    }

    return const ImportActionInfo(
      title: 'Import réalisé avec succès',
      message: 'L’import est terminé sans anomalie détectée.',
      icon: Icons.check_circle_outline,
      color: Colors.green,
      actions: [],
    );
  }
}

class ImportSessionDetailScreen extends StatelessWidget {
  final ImportSession session;

  const ImportSessionDetailScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final repository = ImportSessionRepository();

    final startedDate = DateTime.fromMillisecondsSinceEpoch(session.startedAt);

    final completedDate = session.completedAt == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(session.completedAt!);

    final formatter = DateFormat.yMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_Hm();

    final actionInfo = const ImportActionInfoService().describe(
      context,
      session,
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Suivi de l'import")),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _BusinessSummaryCard(
            session: session,
            actionInfo: actionInfo,
            dateLabel: completedDate == null
                ? formatter.format(startedDate)
                : formatter.format(completedDate),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<ImportSessionFile>>(
            future: repository.getFilesForSession(session.importSessionId),
            builder: (context, snapshot) {
              final files = snapshot.data ?? [];

              ImportSessionFile? fileToResolve;

              for (final file in files) {
                if (file.status == 'needs_resolution') {
                  fileToResolve = file;
                  break;
                }
              }

              if (actionInfo.actions.isEmpty) {
                return const SizedBox.shrink();
              }

              return _ImportActionsBar(
                session: session,
                repository: repository,
                actionInfo: actionInfo,
                fileToResolve: fileToResolve,
              );
            },
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
                      ...files.map((file) => _ImportFileTile(file: file)),
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
  final ImportActionInfo actionInfo;
  final String dateLabel;

  const _BusinessSummaryCard({
    required this.session,
    required this.actionInfo,
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
              actionInfo.title,
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

  static String _valueOrUnknown(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'En attente';
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
              "État de l'import",
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
            if (session.duplicateResultsCount > 0)
              _InfoRow(
                label: 'Résultats déjà présents',
                value: session.duplicateResultsCount.toString(),
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
              _InfoRow(label: 'Source', value: session.sourceLabel!),
          ],
        ),
      ),
    );
  }
}

class _ImportReportMessage extends StatelessWidget {
  final ImportSession session;

  const _ImportReportMessage({required this.session});

  @override
  Widget build(BuildContext context) {
    final actionInfo = const ImportActionInfoService().describe(
      context,
      session,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: actionInfo.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: actionInfo.color.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(actionInfo.icon, color: actionInfo.color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              actionInfo.message,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: actionInfo.color,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImportFileTile extends StatelessWidget {
  final ImportSessionFile file;

  const _ImportFileTile({required this.file});

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
            '${file.duplicateResultsCount} déjà présent(s), '
            '${file.skippedResultsCount} ignoré(s), '
            '${file.conflictResultsCount} conflit(s)',
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

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
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}

class _ImportActionsBar extends StatelessWidget {
  final ImportSession session;
  final ImportSessionRepository repository;
  final ImportActionInfo actionInfo;
  final ImportSessionFile? fileToResolve;

  const _ImportActionsBar({
    required this.session,
    required this.repository,
    required this.actionInfo,
    required this.fileToResolve,
  });

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer cet import ?'),
          content: const Text(
            'Cette action supprimera l’historique de cet import. '
            'Elle ne supprimera pas les données patient déjà importées.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton.icon(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              icon: const Icon(Icons.delete_outline),
              label: const Text('Supprimer'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await repository.deleteSession(session.importSessionId);

    if (!context.mounted) return;

    Navigator.of(context).pop(true);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Import supprimé.')));
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        if (actionInfo.canAssociatePatient)
          FilledButton.icon(
            onPressed: fileToResolve?.filePath == null
                ? null
                : () async {
                    final result =
                        await AbakImportLauncher.importArchiveFromPathWithResolution(
                          context,
                          fileToResolve!.filePath!,
                        );

                    if (!context.mounted) return;

                    if (result != null) {
                      Navigator.of(context).pop(true);
                    }
                  },
            icon: const Icon(Icons.person_search_outlined),
            label: const Text('Associer à un patient'),
          ),
        if (actionInfo.canDeleteImport)
          OutlinedButton.icon(
            onPressed: () => _confirmDelete(context),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Supprimer cet import'),
          ),
      ],
    );
  }
}

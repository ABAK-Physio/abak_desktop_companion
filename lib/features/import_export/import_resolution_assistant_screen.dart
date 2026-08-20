import 'package:flutter/material.dart';

import '../../core/utils/date_format_utils.dart';
import '../../generated/l10n.dart';
import 'data/import_session_repository.dart';
import 'import_session_detail_screen.dart';
import 'models/import_session.dart';

class ImportResolutionAssistantScreen extends StatefulWidget {
  const ImportResolutionAssistantScreen({super.key});

  @override
  State<ImportResolutionAssistantScreen> createState() =>
      _ImportResolutionAssistantScreenState();
}

class _ImportResolutionAssistantScreenState
    extends State<ImportResolutionAssistantScreen> {
  final ImportSessionRepository _repository = ImportSessionRepository();

  late Future<List<ImportSession>> _sessionsFuture;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  void _loadSessions() {
    _sessionsFuture = _repository.getSessions();
  }

  bool _requiresIntervention(ImportSession session) {
    return session.status == 'needs_resolution' ||
        session.status == 'failed' ||
        session.status == 'completed_with_errors' ||
        session.failedFilesCount > 0 ||
        session.conflictResultsCount > 0 ||
        session.skippedResultsCount > 0;
  }

  Future<void> _openSession(ImportSession session) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => ImportSessionDetailScreen(session: session),
      ),
    );

    if (!mounted) return;

    setState(_loadSessions);
  }

  String _sessionTitle(BuildContext context, ImportSession session) {
    final s = S.of(context);
    if (session.status == 'needs_resolution') {
      return s.importResolutionAssistant_importToComplete;
    }

    if (session.status == 'failed' || session.failedFilesCount > 0) {
      return s.importResolutionAssistant_importFailed;
    }

    if (session.conflictResultsCount > 0 ||
        session.skippedResultsCount > 0 ||
        session.status == 'completed_with_errors') {
      return s.importResolutionAssistant_importToReview;
    }

    return s.importResolutionAssistant_import;
  }

  String _sessionDescription(ImportSession session, S s) {
    final elements = <String>[];

    final patient = session.summaryPatientLabel?.trim();
    if (patient != null && patient.isNotEmpty) {
      elements.add(patient);
    }

    final episode = session.summaryEpisodeLabel?.trim();
    if (episode != null && episode.isNotEmpty) {
      elements.add(episode);
    }

    if (session.failedFilesCount > 0) {
      elements.add(
        '${session.failedFilesCount} '
            '${session.failedFilesCount > 1
            ? s.importResolutionAssistant_files
            : s.importResolutionAssistant_file} '
            '${s.importResolutionAssistant_inError}',
      );
    }

    if (session.conflictResultsCount > 0) {
      elements.add(
        '${session.conflictResultsCount} '
            '${session.conflictResultsCount > 1
            ? s.importResolutionAssistant_results
            : s.importResolutionAssistant_result} '
            '${s.importResolutionAssistant_toReview}',
      );
    }

    if (elements.isEmpty) {
      return s.importResolutionAssistant_interventionRequired;
    }

    return elements.join(' · ');
  }

  IconData _sessionIcon(ImportSession session) {
    if (session.status == 'needs_resolution') {
      return Icons.person_search_outlined;
    }

    if (session.status == 'failed' || session.failedFilesCount > 0) {
      return Icons.error_outline;
    }

    return Icons.warning_amber_outlined;
  }

  Color _sessionColor(BuildContext context, ImportSession session) {
    if (session.status == 'failed' || session.failedFilesCount > 0) {
      return Theme.of(context).colorScheme.error;
    }

    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.importResolutionAssistant_title),
      ),
      body: FutureBuilder<List<ImportSession>>(
        future: _sessionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${s.importResolutionAssistant_loadingError} : ${snapshot.error}',
                ),
              ),
            );
          }

          final sessions = (snapshot.data ?? const <ImportSession>[])
              .where(_requiresIntervention)
              .toList();

          if (sessions.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: Colors.green,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      s.importResolutionAssistant_noProblem,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Card(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    s.importResolutionAssistant_selectImportInstruction,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ...sessions.map((session) {
                final color = _sessionColor(context, session);

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    leading: Icon(
                      _sessionIcon(session),
                      color: color,
                    ),
                    title: Text(
                      _sessionTitle(context, session),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      '${DateFormatUtils.formatTimestamp(
                        context,
                        session.startedAt,
                      )}\n'
                          '${_sessionDescription(session, s)}',
                    ),
                    isThreeLine: true,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openSession(session),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
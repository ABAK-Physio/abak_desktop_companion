import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    if (session.status == 'needs_resolution') {
      return 'Import à terminer';
    }

    if (session.status == 'failed' || session.failedFilesCount > 0) {
      return 'Import en échec';
    }

    if (session.conflictResultsCount > 0 ||
        session.skippedResultsCount > 0 ||
        session.status == 'completed_with_errors') {
      return 'Import à vérifier';
    }

    return 'Import';
  }

  String _sessionDescription(ImportSession session) {
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
        '${session.failedFilesCount} fichier'
            '${session.failedFilesCount > 1 ? 's' : ''} en erreur',
      );
    }

    if (session.conflictResultsCount > 0) {
      elements.add(
        '${session.conflictResultsCount} résultat'
            '${session.conflictResultsCount > 1 ? 's' : ''} à vérifier',
      );
    }

    if (elements.isEmpty) {
      return 'Une intervention est nécessaire pour terminer cet import.';
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
    final formatter = DateFormat.yMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_Hm();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résolution des problèmes d’import'),
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
                  'Impossible de charger les imports : ${snapshot.error}',
                ),
              ),
            );
          }

          final sessions = (snapshot.data ?? const <ImportSession>[])
              .where(_requiresIntervention)
              .toList();

          if (sessions.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      size: 48,
                      color: Colors.green,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Aucun problème d’import détecté.',
                      style: TextStyle(
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
                child: const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Sélectionnez un import pour afficher son détail '
                        'et suivre les étapes proposées.',
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
                      '${formatter.format(
                        DateTime.fromMillisecondsSinceEpoch(
                          session.startedAt,
                        ),
                      )}\n'
                          '${_sessionDescription(session)}',
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
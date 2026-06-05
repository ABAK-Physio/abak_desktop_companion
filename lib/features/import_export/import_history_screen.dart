import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'data/import_session_repository.dart';
import 'models/import_session.dart';
import 'import_session_detail_screen.dart';

class ImportHistoryScreen extends StatelessWidget {
  const ImportHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repository = ImportSessionRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique des imports'),
      ),
      body: FutureBuilder<List<ImportSession>>(
        future: repository.getSessions(),
        builder: (context, snapshot) {
          final sessions = snapshot.data ?? [];

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (sessions.isEmpty) {
            return const Center(
              child: Text('Aucun import enregistré.'),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: sessions.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _ImportSessionTile(
                session: sessions[index],
                repository: repository,
              );
            },
          );
        },
      ),
    );
  }
}

class _ImportSessionTile extends StatelessWidget {
  final ImportSession session;
  final ImportSessionRepository repository;

  const _ImportSessionTile({
    required this.session,
    required this.repository,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(session.startedAt);
    final formatter = DateFormat.yMd(
      Localizations.localeOf(context).toLanguageTag(),
    ).add_Hm();

    return Card(
      child: ListTile(
        leading: Icon(
          session.conflictResultsCount > 0
              ? Icons.report_problem_outlined
              : switch (session.status) {
            'running' => Icons.sync_outlined,
            'completed_with_errors' => Icons.warning_amber_outlined,
            'failed' => Icons.error_outline,
            _ => Icons.check_circle_outline,
          },
        ),
        title: Text(formatter.format(date)),
        subtitle: Text(
          '${session.status} · '
              '${session.processedFilesCount} fichier(s) · '
              '${session.importedResultsCount} importé(s) · '
              '${session.skippedResultsCount} ignoré(s) · '
              '${session.conflictResultsCount} conflit(s)',
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ImportSessionDetailScreen(
                session: session,
              ),
            ),
          );
        },
      ),
    );
  }
}
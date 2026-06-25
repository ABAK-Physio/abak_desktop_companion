import 'package:flutter/material.dart';

import 'episode_forms_screen.dart';
import 'episode_documents_screen.dart';
import 'episode_notes_screen.dart';
import 'episode_report_screen.dart';

class EpisodeDashboardScreen extends StatelessWidget {
  final String caseId;
  final String caseLabel;
  final String patientId;
  final String patientDisplayName;

  const EpisodeDashboardScreen({
    super.key,
    required this.caseId,
    required this.caseLabel,
    required this.patientId,
    required this.patientDisplayName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(caseLabel),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _DashboardCard(
            icon: Icons.assignment_outlined,
            title: 'Formulaires',
            subtitle: 'Questionnaires spécifiques à cet épisode',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EpisodeFormsScreen(
                    caseId: caseId,
                    caseLabel: caseLabel,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          _DashboardCard(
            icon: Icons.attach_file_outlined,
            title: 'Documents',
            subtitle: 'Documents associés à cet épisode',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EpisodeDocumentsScreen(
                    caseId: caseId,
                    caseLabel: caseLabel,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          _DashboardCard(
            icon: Icons.notes_outlined,
            title: 'Notes',
            subtitle: 'Observations et commentaires du kiné',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EpisodeNotesScreen(
                    caseId: caseId,
                    caseLabel: caseLabel,
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: 16),

          _DashboardCard(
            icon: Icons.description_outlined,
            title: 'Rapport',
            subtitle: 'Synthèse de l’épisode',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => EpisodeReportScreen(
                    caseId: caseId,
                    caseLabel: caseLabel,
                    patientId: patientId,
                    patientDisplayName: patientDisplayName,
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

class _DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _DashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

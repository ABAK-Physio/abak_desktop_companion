import 'package:flutter/material.dart';

import '../../../models/care_episode.dart';
import '../../../../practitioners/models/practitioner.dart';

class EpisodeHeader extends StatelessWidget {
  final CareEpisode episode;
  final Future<Practitioner?> practitionerFuture;
  final VoidCallback onEditPractitioner;
  final VoidCallback onShowHistory;
  final VoidCallback onOpenDocuments;

  const EpisodeHeader({
    super.key,
    required this.episode,
    required this.practitionerFuture,
    required this.onEditPractitioner,
    required this.onShowHistory,
    required this.onOpenDocuments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.medical_information_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _EpisodeHeaderInformation(
                    label: 'Pathologie',
                    value: episode.pathologyLabel,
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: FutureBuilder<Practitioner?>(
                    future: practitionerFuture,
                    builder: (context, snapshot) {
                      final practitioner = snapshot.data;

                      final value =
                      snapshot.connectionState == ConnectionState.waiting
                          ? 'Chargement…'
                          : practitioner == null
                          ? 'Non renseigné'
                          : practitioner.isArchived
                          ? '${practitioner.displayName} — archivé'
                          : practitioner.displayName;

                      return _EpisodeHeaderInformation(
                        label: 'Kiné référent',
                        value: value,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onOpenDocuments,
            tooltip: 'Documents de la prise en charge',
            icon: const Icon(Icons.attach_file),
          ),
          IconButton(
            onPressed: onEditPractitioner,
            tooltip: 'Modifier le kiné référent',
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: onShowHistory,
            tooltip: 'Historique des kinés référents',
            icon: const Icon(Icons.history),
          ),
        ],
      ),
    );
  }
}

class _EpisodeHeaderInformation extends StatelessWidget {
  final String label;
  final String value;

  const _EpisodeHeaderInformation({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}
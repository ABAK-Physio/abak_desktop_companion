import 'package:flutter/material.dart';

import '../../../../../generated/l10n.dart';
import '../../../models/care_episode.dart';
import '../../../../practitioners/models/practitioner.dart';
import '../../../../external_correspondents/models/external_correspondent.dart';

class EpisodeHeader extends StatelessWidget {
  final CareEpisode episode;
  final Future<Practitioner?> practitionerFuture;
  final Future<ExternalCorrespondent?> prescribingCorrespondentFuture;
  final VoidCallback onEditPractitioner;
  final VoidCallback onShowHistory;
  final VoidCallback onOpenDocuments;
  final VoidCallback onOpenDmpDocuments;
  final VoidCallback? onOpenBodymap;

  const EpisodeHeader({
    super.key,
    required this.episode,
    required this.practitionerFuture,
    required this.prescribingCorrespondentFuture,
    required this.onEditPractitioner,
    required this.onShowHistory,
    required this.onOpenDocuments,
    required this.onOpenDmpDocuments,
    this.onOpenBodymap,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth < 700
              ? constraints.maxWidth
              : (constraints.maxWidth - 32) / 3;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  SizedBox(
                    width: width,
                    child: _EpisodeHeaderInformation(
                      label: s.careEpisodeReportsWorkspace_pathology,
                      value: episode.pathologyLabel,
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: FutureBuilder<Practitioner?>(
                      future: practitionerFuture,
                      builder: (context, snapshot) {
                        final practitioner = snapshot.data;

                        final value =
                            snapshot.connectionState == ConnectionState.waiting
                            ? s.careEpisodeReportsWorkspace_loading
                            : practitioner == null
                            ? s.careEpisodeReportsWorkspace_notProvided
                            : practitioner.isArchived
                            ? '${practitioner.displayName} — '
                                  '${s.careEpisodeReportsWorkspace_archived}'
                            : practitioner.displayName;

                        return _EpisodeHeaderInformation(
                          label: s
                              .careEpisodeReportsWorkspace_referringPractitioner,
                          value: value,
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: width,
                    child: FutureBuilder<ExternalCorrespondent?>(
                      future: prescribingCorrespondentFuture,
                      builder: (context, snapshot) {
                        final correspondent = snapshot.data;

                        final value =
                            snapshot.connectionState == ConnectionState.waiting
                            ? s.careEpisodeReportsWorkspace_loading
                            : correspondent == null
                            ? s.careEpisodeReportsWorkspace_notProvided
                            : correspondent.displayName;

                        return _EpisodeHeaderInformation(
                          label: 'Médecin prescripteur',
                          value: value,
                        );
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                children: [
                  if (onOpenBodymap != null)
                    IconButton(
                      key: const ValueKey('open-pain-bodymap'),
                      onPressed: onOpenBodymap,
                      tooltip: 'Carte des douleurs',
                      icon: const Icon(Icons.accessibility_new),
                    ),
                  IconButton(
                    onPressed: onOpenDocuments,
                    tooltip: s.episodeAttachments_title,
                    icon: const Icon(Icons.attach_file),
                  ),
                  IconButton(
                    onPressed: onOpenDmpDocuments,
                    tooltip: s.episodeDmpDocuments_title,
                    icon: const Icon(Icons.file_present_outlined),
                  ),
                  IconButton(
                    onPressed: onEditPractitioner,
                    tooltip:
                        s.careEpisodeReportsWorkspace_editReferringPractitioner,
                    icon: const Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    onPressed: onShowHistory,
                    tooltip: s
                        .careEpisodeReportsWorkspace_referringPractitionerHistory,
                    icon: const Icon(Icons.history),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _EpisodeHeaderInformation extends StatelessWidget {
  final String label;
  final String value;

  const _EpisodeHeaderInformation({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelMedium),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

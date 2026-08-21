import 'package:flutter/material.dart';

import 'package:abak_desktop_companion/core/utils/date_format_utils.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/care_episode_assessment.dart';

import 'table_header.dart';

class AssessmentHistoryCard extends StatelessWidget {
  final Future<List<CareEpisodeAssessment>> assessmentsFuture;
  final bool isEditing;
  final bool showOpenAssessmentAction;
  final VoidCallback onOpenAssessmentPressed;
  final VoidCallback? onSaveOrUpdatePressed;
  final VoidCallback? onCancelChangesPressed;
  final VoidCallback? onReturnToDraftPressed;
  final ValueChanged<CareEpisodeAssessment> onEditAssessment;
  final ValueChanged<CareEpisodeAssessment> onArchiveAssessment;
  final VoidCallback? onExpand;
  final ValueChanged<CareEpisodeAssessment> onDuplicateAssessment;

  const AssessmentHistoryCard({
    super.key,
    required this.assessmentsFuture,
    required this.isEditing,
    required this.showOpenAssessmentAction,
    required this.onOpenAssessmentPressed,
    required this.onSaveOrUpdatePressed,
    required this.onCancelChangesPressed,
    required this.onReturnToDraftPressed,
    required this.onEditAssessment,
    required this.onArchiveAssessment,
    required this.onExpand,
    required this.onDuplicateAssessment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Historique des bilans',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (onExpand != null)
                  IconButton(
                    onPressed: onExpand,
                    tooltip: 'Agrandir',
                    icon: const Icon(Icons.zoom_out_map),
                  ),
                if (showOpenAssessmentAction)
                  IconButton(
                    onPressed: onOpenAssessmentPressed,
                    tooltip: 'Créer ou reprendre un bilan',
                    icon: const Icon(Icons.note_add_outlined),
                  ),
                if (isEditing) ...[
                  IconButton(
                    onPressed: onReturnToDraftPressed,
                    tooltip: 'Retour au brouillon',
                    icon: const Icon(Icons.note_add_outlined),
                  ),
                  IconButton(
                    onPressed: onCancelChangesPressed,
                    tooltip: 'Annuler les modifications',
                    icon: const Icon(Icons.undo),
                  ),
                ],
                IconButton(
                  onPressed: onSaveOrUpdatePressed,
                  tooltip: isEditing
                      ? 'Mettre à jour le bilan'
                      : 'Enregistrer le bilan',
                  icon: const Icon(Icons.save_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<CareEpisodeAssessment>>(
                future: assessmentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Impossible de charger les bilans.'),
                    );
                  }

                  final assessments = snapshot.data ?? [];

                  if (assessments.isEmpty) {
                    return const Center(
                      child: Text('Aucun bilan enregistré.'),
                    );
                  }

                  return Column(
                    children: [
                      const TableHeader(
                        columns: [
                          Expanded(
                            flex: 5,
                            child: Text('Nom'),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text('Date'),
                          ),
                          SizedBox(width: 42),
                          SizedBox(width: 42),
                          SizedBox(width: 42),
                        ],
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.separated(
                          itemCount: assessments.length,
                          separatorBuilder: (_, _) =>
                          const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final assessment = assessments[index];

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      assessment.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(
                                      DateFormatUtils
                                          .formatTimestampForDisplay(
                                        context,
                                        assessment.assessmentDate,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 42,
                                    child: IconButton(
                                      onPressed: () =>
                                          onEditAssessment(assessment),
                                      tooltip: 'Modifier',
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 42,
                                    child: IconButton(
                                      onPressed: () =>
                                          onDuplicateAssessment(assessment),
                                      tooltip: 'Dupliquer',
                                      icon: const Icon(
                                        Icons.copy_outlined,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 42,
                                    child: IconButton(
                                      onPressed: () =>
                                          onArchiveAssessment(assessment),
                                      tooltip: 'Mettre à la corbeille',
                                      icon: const Icon(
                                        Icons.delete_outline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
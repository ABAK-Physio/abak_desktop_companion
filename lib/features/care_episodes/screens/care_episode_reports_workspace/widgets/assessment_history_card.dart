import 'package:flutter/material.dart';
import '../../../../../generated/l10n.dart';
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
    final s = S.of(context);

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
                    s.careEpisodeReportsWorkspace_assessmentHistory,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (onExpand != null)
                  IconButton(
                    onPressed: onExpand,
                    tooltip: s.careEpisodeReportsWorkspace_expand,
                    icon: const Icon(Icons.zoom_out_map),
                  ),
                if (showOpenAssessmentAction)
                  IconButton(
                    onPressed: onOpenAssessmentPressed,
                    tooltip: s.careEpisodeReportsWorkspace_createOrResumeAssessment,
                    icon: const Icon(Icons.note_add_outlined),
                  ),
                if (isEditing) ...[
                  IconButton(
                    onPressed: onReturnToDraftPressed,
                    tooltip: s.careEpisodeReportsWorkspace_returnToDraft,
                    icon: const Icon(Icons.note_add_outlined),
                  ),
                  IconButton(
                    onPressed: onCancelChangesPressed,
                    tooltip: s.careEpisodeReportsWorkspace_cancelChanges,
                    icon: const Icon(Icons.undo),
                  ),
                ],
                IconButton(
                  onPressed: onSaveOrUpdatePressed,
                  tooltip: isEditing
                      ? s.careEpisodeReportsWorkspace_updateAssessment
                      : s.careEpisodeReportsWorkspace_saveAssessment,
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
                    return Center(
                      child: Text(
                        s.careEpisodeReportsWorkspace_assessmentsLoadError,
                      ),
                    );
                  }

                  final assessments = snapshot.data ?? [];

                  if (assessments.isEmpty) {
                    return Center(
                      child: Text(
                        s.careEpisodeReportsWorkspace_noAssessments,
                      ),
                    );
                  }

                  return Column(
                    children: [
                      TableHeader(
                        columns: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              s.careEpisodeReportsWorkspace_name,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              s.careEpisodeReportsWorkspace_date,
                            ),
                          ),
                          const SizedBox(width: 42),
                          const SizedBox(width: 42),
                          const SizedBox(width: 42),
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
                                      tooltip: s.careEpisodeReportsWorkspace_edit,
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
                                      tooltip: s.careEpisodeReportsWorkspace_duplicate,
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
                                      tooltip: s.careEpisodeReportsWorkspace_moveToTrash,
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
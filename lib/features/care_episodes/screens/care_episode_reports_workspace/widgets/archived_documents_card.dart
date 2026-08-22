import 'package:flutter/material.dart';
import '../../../../../generated/l10n.dart';
import 'package:abak_desktop_companion/core/utils/date_format_utils.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/care_episode_assessment.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/care_episode_report.dart';

import 'scrollable_workspace_card.dart';

class ArchivedDocumentsCard extends StatelessWidget {
  final Future<List<CareEpisodeAssessment>> archivedAssessmentsFuture;
  final Future<List<CareEpisodeReport>> archivedReportsFuture;
  final ValueChanged<CareEpisodeAssessment> onRestoreAssessment;
  final ValueChanged<CareEpisodeReport> onRestoreReport;
  final ValueChanged<CareEpisodeAssessment> onDeleteAssessment;
  final ValueChanged<CareEpisodeReport> onDeleteReport;
  final VoidCallback? onExpand;

  const ArchivedDocumentsCard({
    super.key,
    required this.archivedAssessmentsFuture,
    required this.archivedReportsFuture,
    required this.onRestoreAssessment,
    required this.onRestoreReport,
    required this.onDeleteAssessment,
    required this.onDeleteReport,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ScrollableWorkspaceCard(
      title: s.careEpisodeReportsWorkspace_archivedDocuments,
      trailing: onExpand == null
          ? null
          : IconButton(
        onPressed: onExpand,
        tooltip: s.careEpisodeReportsWorkspace_expand,
        icon: const Icon(Icons.zoom_out_map),
      ),
      child: FutureBuilder<List<CareEpisodeAssessment>>(
        future: archivedAssessmentsFuture,
        builder: (context, assessmentsSnapshot) {
          return FutureBuilder<List<CareEpisodeReport>>(
            future: archivedReportsFuture,
            builder: (context, reportsSnapshot) {
              if (assessmentsSnapshot.connectionState ==
                  ConnectionState.waiting ||
                  reportsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (assessmentsSnapshot.hasError ||
                  reportsSnapshot.hasError) {
                return Center(
                  child: Text(
                    s.careEpisodeReportsWorkspace_trashLoadError,
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final items = <_ArchivedDocumentItem>[
                ...((assessmentsSnapshot.data ?? []).map(
                      (assessment) => _ArchivedDocumentItem(
                    typeLabel: s.careEpisodeReportsWorkspace_assessment,
                    title: assessment.title,
                    archivedAt: assessment.archivedAt ?? 0,
                    icon: Icons.assignment_outlined,
                    assessment: assessment,
                  ),
                )),
                ...((reportsSnapshot.data ?? []).map(
                      (report) => _ArchivedDocumentItem(
                    typeLabel: s.careEpisodeReportsWorkspace_report,
                    title: report.title,
                    archivedAt: report.archivedAt ?? 0,
                    icon: Icons.description_outlined,
                    report: report,
                  ),
                )),
              ]..sort(
                    (a, b) => b.archivedAt.compareTo(a.archivedAt),
              );

              if (items.isEmpty) {
                return Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text(
                          s.careEpisodeReportsWorkspace_noDocument,
                        ),
                      ),
                    ),
                    const Divider(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${s.careEpisodeReportsWorkspace_archivedDocumentsCount} : 0',
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) =>
                      const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                    Text(
                                      '${item.typeLabel} — '
                                          '${DateFormatUtils.formatTimestampForDisplay(
                                        context,
                                        item.archivedAt,
                                      )}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  final assessment = item.assessment;
                                  final report = item.report;

                                  if (assessment != null) {
                                    onRestoreAssessment(assessment);
                                    return;
                                  }

                                  if (report != null) {
                                    onRestoreReport(report);
                                  }
                                },
                                tooltip: s.careEpisodeReportsWorkspace_restore,
                                icon: const Icon(
                                  Icons.restore_from_trash_outlined,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  final assessment = item.assessment;
                                  final report = item.report;

                                  if (assessment != null) {
                                    onDeleteAssessment(assessment);
                                    return;
                                  }

                                  if (report != null) {
                                    onDeleteReport(report);
                                  }
                                },
                                tooltip: s.careEpisodeReportsWorkspace_deletePermanently,
                                icon: const Icon(
                                  Icons.delete_forever_outlined,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '${s.careEpisodeReportsWorkspace_archivedDocumentsCount} : ${items.length}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ArchivedDocumentItem {
  final String typeLabel;
  final String title;
  final int archivedAt;
  final IconData icon;
  final CareEpisodeAssessment? assessment;
  final CareEpisodeReport? report;

  const _ArchivedDocumentItem({
    required this.typeLabel,
    required this.title,
    required this.archivedAt,
    required this.icon,
    this.assessment,
    this.report,
  });
}
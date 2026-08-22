import 'package:flutter/material.dart';
import '../../../../../generated/l10n.dart';
import 'package:abak_desktop_companion/core/utils/date_format_utils.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/care_episode_report.dart';

import 'scrollable_workspace_card.dart';
import 'table_header.dart';

class ReportHistoryCard extends StatelessWidget {
  final Future<List<CareEpisodeReport>> reportsFuture;
  final bool isEditingReport;
  final VoidCallback onCreateReportPressed;
  final VoidCallback? onSaveReportPressed;
  final VoidCallback? onCancelReportChangesPressed;
  final ValueChanged<CareEpisodeReport> onEditReport;
  final ValueChanged<CareEpisodeReport> onArchiveReport;
  final VoidCallback? onExpand;
  final ValueChanged<CareEpisodeReport> onDuplicateReport;

  const ReportHistoryCard({
    super.key,
    required this.reportsFuture,
    required this.isEditingReport,
    required this.onCreateReportPressed,
    required this.onSaveReportPressed,
    required this.onCancelReportChangesPressed,
    required this.onEditReport,
    required this.onArchiveReport,
    required this.onExpand,
    required this.onDuplicateReport,
  });

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ScrollableWorkspaceCard(
      title: s.careEpisodeReportsWorkspace_reportHistory,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onExpand != null)
            IconButton(
              onPressed: onExpand,
              tooltip: s.careEpisodeReportsWorkspace_expand,
              icon: const Icon(Icons.zoom_out_map),
            ),
          IconButton(
            onPressed: onCreateReportPressed,
            tooltip: isEditingReport
                ? s.careEpisodeReportsWorkspace_returnToReportDraft
                : s.careEpisodeReportsWorkspace_createOrResumeReport,
            icon: const Icon(Icons.description_outlined),
          ),
          if (isEditingReport)
            IconButton(
              onPressed: onCancelReportChangesPressed,
              tooltip: s.careEpisodeReportsWorkspace_cancelChanges,
              icon: const Icon(Icons.undo),
            ),
          if (isEditingReport || onSaveReportPressed != null)
            IconButton(
              onPressed: onSaveReportPressed,
              tooltip: isEditingReport
                  ? s.careEpisodeReportsWorkspace_updateReport
                  : s.careEpisodeReportsWorkspace_saveReport,
              icon: const Icon(Icons.save_outlined),
            ),
        ],
      ),
      child: FutureBuilder<List<CareEpisodeReport>>(
        future: reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                s.careEpisodeReportsWorkspace_reportsLoadError,
              ),
            );
          }

          final reports = snapshot.data ?? [];

          if (reports.isEmpty) {
            return Center(
              child: Text(
                s.careEpisodeReportsWorkspace_noReports,
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
                  itemCount: reports.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final report = reports[index];

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
                              report.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              DateFormatUtils.formatTimestampForDisplay(
                                context,
                                report.reportDate,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 42,
                            child: IconButton(
                              onPressed: () => onEditReport(report),
                              tooltip: s.careEpisodeReportsWorkspace_edit,
                              icon: const Icon(Icons.edit_outlined),
                            ),
                          ),
                          SizedBox(
                            width: 42,
                            child: IconButton(
                              onPressed: () => onDuplicateReport(report),
                              tooltip: s.careEpisodeReportsWorkspace_duplicate,
                              icon: const Icon(Icons.copy_outlined),
                            ),
                          ),
                          SizedBox(
                            width: 42,
                            child: IconButton(
                              onPressed: () => onArchiveReport(report),
                              tooltip: s.careEpisodeReportsWorkspace_moveToTrash,
                              icon: const Icon(Icons.delete_outline),
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
    );
  }
}
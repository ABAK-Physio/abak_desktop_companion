import '../../../../../generated/l10n.dart';
import 'package:abak_desktop_companion/core/utils/date_format_utils.dart';
import 'package:abak_desktop_companion/features/results/models/desktop_result.dart';
import 'package:abak_desktop_companion/features/results/result_detail_screen.dart';
import 'package:abak_shared/abak_shared.dart';
import 'package:flutter/material.dart';

import 'scrollable_workspace_card.dart';
import 'table_header.dart';

typedef TestIncludedChanged = void Function({
required String exoId,
required bool included,
});

class LatestTestsCard extends StatelessWidget {
  final Future<List<DesktopResult>> resultsFuture;
  final Set<String> selectedTestExoIds;
  final bool selectionEnabled;
  final TestIncludedChanged onTestIncludedChanged;
  final VoidCallback? onExpand;

  const LatestTestsCard({
    super.key,
    required this.resultsFuture,
    required this.selectedTestExoIds,
    required this.selectionEnabled,
    required this.onTestIncludedChanged,
    required this.onExpand,
  });

  List<DesktopResult> _latestResultsByTest(
      List<DesktopResult> results,
      ) {
    final sortedResults = [...results]
      ..sort(
            (a, b) => b.createdAt.compareTo(a.createdAt),
      );

    final latestByTest = <String, DesktopResult>{};

    for (final result in sortedResults) {
      latestByTest.putIfAbsent(
        result.exoId,
            () => result,
      );
    }

    final latestResults = latestByTest.values.toList()
      ..sort(
            (a, b) => ClinicalActivityCatalog.displayLabel(
          a.exoId,
        ).compareTo(
          ClinicalActivityCatalog.displayLabel(
            b.exoId,
          ),
        ),
      );

    return latestResults;
  }

  String _resultLabel(DesktopResult result) {
    if (result.scoreTotal == null) {
      return '—';
    }

    final score = result.scoreTotal!.toStringAsFixed(2);
    final unit = result.measureUnit?.trim();

    if (unit == null || unit.isEmpty) {
      return score;
    }

    return '$score $unit';
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ScrollableWorkspaceCard(
      title: s.careEpisodeReportsWorkspace_latestTests,
      trailing: onExpand == null
          ? null
          : IconButton(
        onPressed: onExpand,
        tooltip: s.careEpisodeReportsWorkspace_expand,
        icon: const Icon(Icons.zoom_out_map),
      ),
      child: FutureBuilder<List<DesktopResult>>(
        future: resultsFuture,
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
                s.careEpisodeReportsWorkspace_testsLoadError,
              ),
            );
          }

          final latestResults = _latestResultsByTest(
            snapshot.data ?? [],
          );

          if (latestResults.isEmpty) {
            return Center(
              child: Text(
                s.careEpisodeReportsWorkspace_noTests,
              ),
            );
          }

          return Column(
            children: [
              TableHeader(
                columns: [
                  Expanded(
                    flex: 4,
                    child: Text(
                      s.careEpisodeReportsWorkspace_test,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      s.careEpisodeReportsWorkspace_date,
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      s.careEpisodeReportsWorkspace_result,
                    ),
                  ),
                  SizedBox(
                    width: 72,
                    child: Text(
                      s.careEpisodeReportsWorkspace_include,
                    ),
                  ),
                ],
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: latestResults.length,
                  separatorBuilder: (_, _) =>
                  const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final result = latestResults[index];

                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ResultDetailScreen(
                                  result: result,
                                ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                ClinicalActivityCatalog
                                    .displayLabel(
                                  result.exoId,
                                ),
                                maxLines: 2,
                                overflow:
                                TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                DateFormatUtils
                                    .formatTimestampForDisplay(
                                  context,
                                  result.createdAt,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                _resultLabel(result),
                                maxLines: 2,
                                overflow:
                                TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: 72,
                              child: Center(
                                child: Checkbox(
                                  value:
                                  selectedTestExoIds.contains(
                                    result.exoId,
                                  ),
                                  onChanged: selectionEnabled
                                      ? (value) {
                                    onTestIncludedChanged(
                                      exoId:
                                      result.exoId,
                                      included:
                                      value ?? false,
                                    );
                                  }
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
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
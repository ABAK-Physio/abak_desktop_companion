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

  Future<void> _showAllResults(BuildContext context) async {
    final results = await resultsFuture;

    if (!context.mounted) return;

    final sortedResults = [...results]
      ..sort((a, b) {
        final labelComparison =
        ClinicalActivityCatalog.displayLabel(a.exoId).compareTo(
          ClinicalActivityCatalog.displayLabel(b.exoId),
        );

        if (labelComparison != 0) {
          return labelComparison;
        }

        return b.createdAt.compareTo(a.createdAt);
      });

    final groupedResults = <String, List<DesktopResult>>{};

    for (final result in sortedResults) {
      groupedResults
          .putIfAbsent(
        result.exoId,
            () => <DesktopResult>[],
      )
          .add(result);
    }

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(32),
          child: SizedBox(
            width: MediaQuery.of(dialogContext).size.width * 0.80,
            height: MediaQuery.of(dialogContext).size.height * 0.80,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Tous les résultats des tests',
                          style: Theme.of(
                            dialogContext,
                          ).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () =>
                            Navigator.of(dialogContext).pop(),
                        tooltip: 'Fermer',
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: groupedResults.isEmpty
                        ? const Center(
                      child: Text(
                        'Aucun résultat disponible.',
                      ),
                    )
                        : ListView(
                      children: [
                        for (final entry
                        in groupedResults.entries) ...[
                          Text(
                            ClinicalActivityCatalog.displayLabel(
                              entry.key,
                            ),
                            style: Theme.of(dialogContext)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          for (final result in entry.value)
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                DateFormatUtils
                                    .formatTimestampForDisplay(
                                  dialogContext,
                                  result.createdAt,
                                ),
                              ),
                              subtitle: Text(
                                _resultLabel(result),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right,
                              ),
                              onTap: () {
                                Navigator.of(dialogContext).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        ResultDetailScreen(
                                          result: result,
                                        ),
                                  ),
                                );
                              },
                            ),
                          const Divider(height: 24),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return ScrollableWorkspaceCard(
      title: s.careEpisodeReportsWorkspace_latestTests,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => _showAllResults(context),
            tooltip: 'Voir tous les résultats',
            icon: const Icon(Icons.view_list_outlined),
          ),
          if (onExpand != null)
            IconButton(
              onPressed: onExpand,
              tooltip: s.careEpisodeReportsWorkspace_expand,
              icon: const Icon(Icons.zoom_out_map),
            ),
        ],
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
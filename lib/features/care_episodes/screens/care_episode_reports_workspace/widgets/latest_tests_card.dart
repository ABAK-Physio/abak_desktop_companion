import '../../../../../generated/l10n.dart';
import 'package:abak_desktop_companion/core/utils/date_format_utils.dart';
import 'package:abak_desktop_companion/features/results/models/desktop_result.dart';
import 'package:abak_desktop_companion/features/results/result_detail_screen.dart';
import 'package:abak_shared/abak_shared.dart';
import 'package:flutter/material.dart';

import 'scrollable_workspace_card.dart';
import 'table_header.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:abak_desktop_companion/features/results/desktop_result_grouping.dart';

typedef TestIncludedChanged =
    void Function({required String exoId, required bool included});

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

  List<DesktopResult> _latestResultsByTest(List<DesktopResult> results) {
    final sortedResults = [...results]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final latestByTest = <String, DesktopResult>{};

    for (final result in sortedResults) {
      final definition = ClinicalActivityCatalog.infoFor(
        result.exoId,
      );

      final followUpGroupPath = definition.followUpGroupPath;

      String groupKey = result.exoId;

      if (followUpGroupPath != null) {
        final groupCode = _readStructuredString(
          result,
          followUpGroupPath,
        );

        if (groupCode != null) {
          groupKey = '${result.exoId}::$groupCode';
        }
      }

      latestByTest.putIfAbsent(
        groupKey,
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

  String _testDisplayLabel(DesktopResult result) {
    return desktopResultDisplayLabel(result);
  }

  String _testSelectionKey(DesktopResult result) {
    return desktopResultSelectionKey(result);
  }

  double? _readMetricValueWithFallbacks(
      DesktopResult result,
      ExerciseMetricDefinition metric,
      ) {
    return readDesktopResultMetricValueWithFallbacks(
      result,
      metric,
    );
  }

  String? _readStructuredString(
      DesktopResult result,
      String path,
      ) {
    return readDesktopResultStructuredString(
      result,
      path,
    );
  }

  Widget _buildEvolutionChart(
      BuildContext context,
      List<DesktopResult> results,
      ) {
    if (results.isEmpty) {
      return const Center(
        child: Text(
          'Aucun résultat disponible.',
          textAlign: TextAlign.center,
        ),
      );
    }

    final definition = ClinicalActivityCatalog.infoFor(
      results.first.exoId,
    );

    final chartMetrics = definition.metrics
        .where((metric) => metric.showOnEvolutionChart)
        .toList();

    if (chartMetrics.isEmpty) {
      return const Center(
        child: Text(
          'Aucune donnée d’évolution disponible pour ce test.',
          textAlign: TextAlign.center,
        ),
      );
    }

    final chronologicalResults = [...results]
      ..sort(
            (a, b) => a.createdAt.compareTo(b.createdAt),
      );

    final colorScheme = Theme.of(context).colorScheme;

    final chartColors = [
      colorScheme.primary,
      colorScheme.secondary,
      colorScheme.tertiary,
      colorScheme.error,
      colorScheme.primaryContainer,
      colorScheme.secondaryContainer,
    ];

    final lineBars = <LineChartBarData>[];
    final legendItems = <Widget>[];

    for (var metricIndex = 0;
    metricIndex < chartMetrics.length;
    metricIndex++) {
      final metric = chartMetrics[metricIndex];

      final spots = <FlSpot>[];

      for (var resultIndex = 0;
      resultIndex < chronologicalResults.length;
      resultIndex++) {
        final value = _readMetricValueWithFallbacks(
          chronologicalResults[resultIndex],
          metric,
        );

        if (value != null) {
          spots.add(
            FlSpot(
              resultIndex.toDouble(),
              value,
            ),
          );
        }
      }

      if (spots.length < 2) {
        continue;
      }

      final color =
      chartColors[metricIndex % chartColors.length];

      lineBars.add(
        LineChartBarData(
          spots: spots,
          isCurved: false,
          color: color,
          dotData: const FlDotData(
            show: true,
          ),
        ),
      );

      legendItems.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 16,
              height: 3,
              color: color,
            ),
            const SizedBox(width: 6),
            Text(
              metric.fallbackLabel,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      );
    }

    if (lineBars.isEmpty) {
      return const Center(
        child: Text(
          'Au moins deux résultats sont nécessaires pour afficher l’évolution.',
          textAlign: TextAlign.center,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (legendItems.length > 1) ...[
            Wrap(
              spacing: 20,
              runSpacing: 8,
              children: legendItems,
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: LineChart(
              LineChartData(
                lineBarsData: lineBars,
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: false,
                    ),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 48,
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.round();

                        if (index < 0 ||
                            index >=
                                chronologicalResults.length) {
                          return const SizedBox.shrink();
                        }

                        return SideTitleWidget(
                          meta: meta,
                          child: Text(
                            DateFormatUtils
                                .formatTimestampForDisplay(
                              context,
                              chronologicalResults[index]
                                  .createdAt,
                            ),
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAllResults(BuildContext context) async {
    final results = await resultsFuture;

    if (!context.mounted) return;

    final sortedResults = [...results]
      ..sort((a, b) {
        final labelComparison = ClinicalActivityCatalog.displayLabel(
          a.exoId,
        ).compareTo(
          ClinicalActivityCatalog.displayLabel(
            b.exoId,
          ),
        );

        if (labelComparison != 0) {
          return labelComparison;
        }

        return b.createdAt.compareTo(a.createdAt);
      });

    final groupedResults = <String, List<DesktopResult>>{};
    final groupLabels = <String, String>{};

    for (final result in sortedResults) {
      final definition = ClinicalActivityCatalog.infoFor(
        result.exoId,
      );

      final followUpGroupPath = definition.followUpGroupPath;

      String groupKey = result.exoId;
      String groupLabel = ClinicalActivityCatalog.displayLabel(
        result.exoId,
      );

      if (followUpGroupPath != null) {
        final groupCode = _readStructuredString(
          result,
          followUpGroupPath,
        );

        if (groupCode != null) {
          groupKey = '${result.exoId}::$groupCode';

          final followUpGroupLabelPath =
              definition.followUpGroupLabelPath;

          final groupValueLabel = followUpGroupLabelPath == null
              ? null
              : _readStructuredString(
            result,
            followUpGroupLabelPath,
          );

          groupLabel =
          '${ClinicalActivityCatalog.displayLabel(result.exoId)} — '
              '${groupValueLabel ?? groupCode}';
        }
      }

      groupedResults
          .putIfAbsent(
        groupKey,
            () => <DesktopResult>[],
      )
          .add(result);

      groupLabels[groupKey] = groupLabel;
    }

    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        String? selectedExoId;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.all(32),
              child: SizedBox(
                width:
                MediaQuery.of(dialogContext).size.width * 0.80,
                height:
                MediaQuery.of(dialogContext).size.height * 0.80,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.stretch,
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
                                Navigator.of(
                                  dialogContext,
                                ).pop(),
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
                            : Row(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 1,
                              child: ListView(
                                children: [
                                  for (final entry
                                  in groupedResults
                                      .entries) ...[
                                    InkWell(
                                      onTap: () {
                                        setDialogState(() {
                                          selectedExoId =
                                              entry.key;
                                        });
                                      },
                                      child: Padding(
                                        padding:
                                        const EdgeInsets
                                            .symmetric(
                                          vertical: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            if (selectedExoId ==
                                                entry.key)
                                              const Padding(
                                                padding:
                                                EdgeInsets
                                                    .only(
                                                  right: 6,
                                                ),
                                                child: Icon(
                                                  Icons
                                                      .chevron_right,
                                                  size: 18,
                                                ),
                                              ),
                                            Expanded(
                                              child: Text(
                                                groupLabels[entry.key] ?? entry.key,
                                                style: Theme.of(
                                                  dialogContext,
                                                )
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                  fontWeight:
                                                  selectedExoId ==
                                                      entry.key
                                                      ? FontWeight
                                                      .bold
                                                      : FontWeight
                                                      .w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    for (final result
                                    in entry.value)
                                      ListTile(
                                        contentPadding:
                                        EdgeInsets.zero,
                                        title: Text(
                                          DateFormatUtils
                                              .formatTimestampForDisplay(
                                            dialogContext,
                                            result.createdAt,
                                          ),
                                        ),
                                        subtitle: Text(
                                          _resultLabel(
                                            result,
                                          ),
                                        ),
                                        trailing:
                                        const Icon(
                                          Icons
                                              .chevron_right,
                                        ),
                                        onTap: () {
                                          Navigator.of(
                                            dialogContext,
                                          ).push(
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  ResultDetailScreen(
                                                    result:
                                                    result,
                                                  ),
                                            ),
                                          );
                                        },
                                      ),
                                    const Divider(
                                      height: 24,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const VerticalDivider(
                              width: 32,
                            ),
                            Expanded(
                              flex: 2,
                              child: selectedExoId == null
                                  ? const Center(
                                child: Text(
                                  'Sélectionnez un test pour afficher son évolution.',
                                  textAlign: TextAlign.center,
                                ),
                              )
                                  : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    groupLabels[selectedExoId!] ?? selectedExoId!,
                                    style: Theme.of(dialogContext)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Expanded(
                                    child: _buildEvolutionChart(
                                      dialogContext,
                                      groupedResults[selectedExoId!] ?? [],
                                    ),
                                  ),
                                ],
                              ),
                            ),
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
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(s.careEpisodeReportsWorkspace_testsLoadError),
            );
          }

          final latestResults = _latestResultsByTest(snapshot.data ?? []);

          if (latestResults.isEmpty) {
            return Center(child: Text(s.careEpisodeReportsWorkspace_noTests));
          }

          return Column(
            children: [
              TableHeader(
                columns: [
                  Expanded(
                    flex: 4,
                    child: Text(s.careEpisodeReportsWorkspace_test),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(s.careEpisodeReportsWorkspace_date),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(s.careEpisodeReportsWorkspace_result),
                  ),
                  SizedBox(
                    width: 72,
                    child: Text(s.careEpisodeReportsWorkspace_include),
                  ),
                ],
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: latestResults.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final result = latestResults[index];

                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ResultDetailScreen(result: result),
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
                                _testDisplayLabel(result),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                DateFormatUtils.formatTimestampForDisplay(
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
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: 72,
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: selectionEnabled
                                    ? null
                                    : () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Sélectionnez d’abord « Bilan » pour pouvoir inclure des tests.',
                                      ),
                                    ),
                                  );
                                },
                                child: Center(
                                  child: Checkbox(
                                    value: selectedTestExoIds.contains(
                                      _testSelectionKey(result),
                                    ),
                                    onChanged: selectionEnabled
                                        ? (value) {
                                      onTestIncludedChanged(
                                        exoId: _testSelectionKey(result),
                                        included: value ?? false,
                                      );
                                    }
                                        : null,
                                  ),
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

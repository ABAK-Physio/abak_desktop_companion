import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:abak_desktop_companion/features/results/models/desktop_result.dart';
import 'package:abak_shared/abak_shared.dart';
import '../services/structured_metric_reader.dart';

class ExerciseEvolutionDetailScreen extends StatelessWidget {
  final String exoId;
  final List<DesktopResult> measures;
  final String patientName;

  const ExerciseEvolutionDetailScreen({
    super.key,
    required this.exoId,
    required this.patientName,
    required this.measures,
  });

  @override
  Widget build(BuildContext context) {
    final sortedMeasures = [...measures]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    final exerciseDefinition =
    ClinicalActivityCatalog.infoFor(exoId);

    final measureGroups = _buildMeasureGroups(
      measures: sortedMeasures,
      definition: exerciseDefinition,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Évolution du ${ClinicalActivityCatalog.displayLabel(exoId)}',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            ClinicalActivityCatalog.displayLabel(exoId),
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                patientName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          const SizedBox(height: 16),
          for (final group in measureGroups)
            _EvolutionGroupSection(
              label: group.label,
              measures: group.measures,
              definition: exerciseDefinition,
            ),
        ],
      ),
    );
  }
}

class _EvolutionMeasureGroup {
  final String key;
  final String label;
  final List<DesktopResult> measures;

  const _EvolutionMeasureGroup({
    required this.key,
    required this.label,
    required this.measures,
  });
}

class _MeasureMetricDisplay {
  final String label;
  final String value;

  const _MeasureMetricDisplay({
    required this.label,
    required this.value,
  });
}

class _EvolutionGroupSection extends StatelessWidget {
  final String label;
  final List<DesktopResult> measures;
  final ExerciseDefinition definition;

  const _EvolutionGroupSection({
    required this.label,
    required this.measures,
    required this.definition,
  });

  @override
  Widget build(BuildContext context) {
    final followUpMetric = _findFollowUpMetric(definition);

    final followUpUnit =
        followUpMetric?.defaultUnit ?? definition.defaultUnit;

    final scoreDecimals =
        followUpMetric?.scoreDecimals ?? definition.scoreDecimals;

    final scoreDirection =
        followUpMetric?.scoreDirection ?? definition.scoreDirection;

    final threshold =
        followUpMetric?.meaningfulChangeThreshold ??
            definition.meaningfulChangeThreshold;

    final evolutionSeries = _buildEvolutionSeries(
      measures: measures,
      definition: definition,
    );

    final followUpValues = measures
        .map(
          (measure) => _readFollowUpValue(
        measure: measure,
        definition: definition,
      ),
    )
        .whereType<double>()
        .toList();

    final canShowChart = evolutionSeries.any(
          (series) => series.spots.length >= 2,
    );

    final evolutionAnalysis = _analyzeEvolution(
      followUpValues,
      scoreDirection,
      threshold,
    );

    final hasDeclaredChartMetrics = definition.metrics.any(
          (metric) => metric.showOnEvolutionChart,
    );

    final shouldExplainMissingChart =
        definition.followUpPolicy ==
            FollowUpPolicy.declaredMetricsOnly &&
            !hasDeclaredChartMetrics;

    final formatter = DateFormat.yMd(
      Localizations.localeOf(context).toLanguageTag(),
    );

    final normalizedUnit = followUpUnit?.trim();

    final unit = normalizedUnit == null || normalizedUnit.isEmpty
        ? ''
        : ' $normalizedUnit';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),

        if (canShowChart) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                height: 300,
                child: Column(
                  children: [
                    _EvolutionChartLegend(
                      series: evolutionSeries,
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: _EvolutionLineChart(
                        series: evolutionSeries,
                        measures: measures,
                        unit: normalizedUnit,
                        scoreDecimals: scoreDecimals,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (shouldExplainMissingChart) ...[
          const _NoEvolutionChartCard(),
          const SizedBox(height: 16),
        ],

        if (evolutionAnalysis != null) ...[
          _EvolutionSummaryCard(
            analysis: evolutionAnalysis,
            unit: normalizedUnit,
            scoreDecimals: scoreDecimals,
          ),
          const SizedBox(height: 16),
        ],

        ...measures.map((result) {
          final date = formatter.format(
            DateTime.fromMillisecondsSinceEpoch(result.createdAt),
          );

          final followUpValue = _readFollowUpValue(
            measure: result,
            definition: definition,
          );

          final chartMetricDisplays = _readChartMetricDisplays(
            measure: result,
            definition: definition,
          );

          Widget title;

          if (followUpValue != null) {
            title = Text(
              '${followUpValue.toStringAsFixed(scoreDecimals)}$unit',
            );
          } else if (chartMetricDisplays.isNotEmpty) {
            title = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final display in chartMetricDisplays)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Text(
                      '${display.label} : ${display.value}',
                    ),
                  ),
              ],
            );
          } else {
            title = const Text('-');
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.timeline),
              title: title,
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(date),
              ),
            ),
          );
        }),

        const SizedBox(height: 24),
      ],
    );
  }
}

class _NoEvolutionChartCard extends StatelessWidget {
  const _NoEvolutionChartCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.info_outline, color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Aucune courbe d’évolution définie',
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Les résultats de cet exercice ne sont pas représentés '
                    'par une courbe synthétique. Ils restent disponibles '
                    'individuellement afin d’éviter une présentation '
                    'simplifiée ou trompeuse.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _EvolutionDirection { increase, decrease, unchanged }

enum _EvolutionInterpretation {
  expectedDirection,
  oppositeDirection,
  unchanged,
  notInterpretable,
}

enum _MeaningfulChangeStatus { reached, notReached, unavailable }

enum _EvolutionConclusion {
  expectedAndMeaningful,
  oppositeAndMeaningful,
  belowThreshold,
  unchanged,
  directionUnavailable,
  thresholdUnavailable,
}

enum _EvolutionConfidence {
  supported,
  cautious,
  insufficientChange,
  observationOnly,
}

class _EvolutionAnalysis {
  final double firstValue;
  final double lastValue;
  final double delta;
  final _EvolutionDirection direction;
  final _EvolutionInterpretation interpretation;
  final double? meaningfulChangeThreshold;
  final _MeaningfulChangeStatus meaningfulChangeStatus;
  final _EvolutionConclusion conclusion;
  final _EvolutionConfidence confidence;

  const _EvolutionAnalysis({
    required this.firstValue,
    required this.lastValue,
    required this.delta,
    required this.direction,
    required this.interpretation,
    required this.meaningfulChangeThreshold,
    required this.meaningfulChangeStatus,
    required this.conclusion,
    required this.confidence,
  });
}

_EvolutionAnalysis? _analyzeEvolution(
  List<double> values,
  ScoreDirection scoreDirection,
  double? meaningfulChangeThreshold,
) {
  if (values.length < 2) {
    return null;
  }

  final firstValue = values.first;
  final lastValue = values.last;

  final delta = lastValue - firstValue;

  final direction = delta > 0
      ? _EvolutionDirection.increase
      : delta < 0
      ? _EvolutionDirection.decrease
      : _EvolutionDirection.unchanged;

  final interpretation = _interpretDirection(
    direction: direction,
    scoreDirection: scoreDirection,
  );

  _MeaningfulChangeStatus evaluateMeaningfulChange({
    required double delta,
    required double? threshold,
  }) {
    if (threshold == null || threshold <= 0) {
      return _MeaningfulChangeStatus.unavailable;
    }

    return delta.abs() >= threshold
        ? _MeaningfulChangeStatus.reached
        : _MeaningfulChangeStatus.notReached;
  }

  _EvolutionConclusion buildEvolutionConclusion({
    required _EvolutionDirection direction,
    required _EvolutionInterpretation interpretation,
    required _MeaningfulChangeStatus meaningfulChangeStatus,
  }) {
    if (direction == _EvolutionDirection.unchanged) {
      return _EvolutionConclusion.unchanged;
    }

    if (interpretation == _EvolutionInterpretation.notInterpretable) {
      return _EvolutionConclusion.directionUnavailable;
    }

    if (meaningfulChangeStatus == _MeaningfulChangeStatus.unavailable) {
      return _EvolutionConclusion.thresholdUnavailable;
    }

    if (meaningfulChangeStatus == _MeaningfulChangeStatus.notReached) {
      return _EvolutionConclusion.belowThreshold;
    }

    if (interpretation == _EvolutionInterpretation.expectedDirection) {
      return _EvolutionConclusion.expectedAndMeaningful;
    }

    return _EvolutionConclusion.oppositeAndMeaningful;
  }

  _EvolutionConfidence buildEvolutionConfidence(
    _EvolutionConclusion conclusion,
  ) {
    switch (conclusion) {
      case _EvolutionConclusion.expectedAndMeaningful:
      case _EvolutionConclusion.oppositeAndMeaningful:
        return _EvolutionConfidence.supported;

      case _EvolutionConclusion.thresholdUnavailable:
        return _EvolutionConfidence.cautious;

      case _EvolutionConclusion.belowThreshold:
      case _EvolutionConclusion.unchanged:
        return _EvolutionConfidence.insufficientChange;

      case _EvolutionConclusion.directionUnavailable:
        return _EvolutionConfidence.observationOnly;
    }
  }

  final meaningfulChangeStatus = evaluateMeaningfulChange(
    delta: delta,
    threshold: meaningfulChangeThreshold,
  );

  final conclusion = buildEvolutionConclusion(
    direction: direction,
    interpretation: interpretation,
    meaningfulChangeStatus: meaningfulChangeStatus,
  );

  final confidence = buildEvolutionConfidence(conclusion);

  return _EvolutionAnalysis(
    firstValue: firstValue,
    lastValue: lastValue,
    delta: delta,
    direction: direction,
    interpretation: interpretation,
    meaningfulChangeThreshold: meaningfulChangeThreshold,
    meaningfulChangeStatus: meaningfulChangeStatus,
    conclusion: conclusion,
    confidence: confidence,
  );
}

_EvolutionInterpretation _interpretDirection({
  required _EvolutionDirection direction,
  required ScoreDirection scoreDirection,
}) {
  if (direction == _EvolutionDirection.unchanged) {
    return _EvolutionInterpretation.unchanged;
  }

  switch (scoreDirection) {
    case ScoreDirection.higherIsBetter:
      return direction == _EvolutionDirection.increase
          ? _EvolutionInterpretation.expectedDirection
          : _EvolutionInterpretation.oppositeDirection;

    case ScoreDirection.lowerIsBetter:
      return direction == _EvolutionDirection.decrease
          ? _EvolutionInterpretation.expectedDirection
          : _EvolutionInterpretation.oppositeDirection;

    case ScoreDirection.neutral:
    case ScoreDirection.unknown:
      return _EvolutionInterpretation.notInterpretable;
  }
}

class _EvolutionSummaryCard extends StatelessWidget {
  final _EvolutionAnalysis analysis;
  final String? unit;
  final int scoreDecimals;

  const _EvolutionSummaryCard({
    required this.analysis,
    required this.unit,
    required this.scoreDecimals,
  });

  String _formatValue(double value) {
    final normalizedUnit = unit?.trim();
    final formattedValue = value.toStringAsFixed(scoreDecimals);

    if (normalizedUnit == null || normalizedUnit.isEmpty) {
      return formattedValue;
    }

    return '$formattedValue $normalizedUnit';
  }

  String _formatDelta(double delta) {
    final normalizedUnit = unit?.trim();
    final sign = delta > 0 ? '+' : '';
    final formattedDelta = '$sign${delta.toStringAsFixed(scoreDecimals)}';

    if (normalizedUnit == null || normalizedUnit.isEmpty) {
      return formattedDelta;
    }

    return '$formattedDelta $normalizedUnit';
  }

  String _directionLabel(_EvolutionDirection direction) {
    switch (direction) {
      case _EvolutionDirection.increase:
        return 'Hausse';
      case _EvolutionDirection.decrease:
        return 'Baisse';
      case _EvolutionDirection.unchanged:
        return 'Valeur inchangée';
    }
  }

  String _interpretationLabel(_EvolutionInterpretation interpretation) {
    switch (interpretation) {
      case _EvolutionInterpretation.expectedDirection:
        return 'La variation va dans le sens attendu pour cette mesure.';

      case _EvolutionInterpretation.oppositeDirection:
        return 'La variation va dans le sens opposé au sens attendu.';

      case _EvolutionInterpretation.unchanged:
        return 'Aucune variation n’est observée entre les deux mesures.';

      case _EvolutionInterpretation.notInterpretable:
        return 'Le sens favorable ou défavorable de cette mesure '
            'n’est pas défini.';
    }
  }

  String _meaningfulChangeLabel(_EvolutionAnalysis analysis) {
    switch (analysis.meaningfulChangeStatus) {
      case _MeaningfulChangeStatus.reached:
        final threshold = analysis.meaningfulChangeThreshold;

        if (threshold == null) {
          return 'Le seuil de changement notable est atteint.';
        }

        return 'La variation atteint ou dépasse le seuil défini '
            '(${_formatValue(threshold)}).';

      case _MeaningfulChangeStatus.notReached:
        final threshold = analysis.meaningfulChangeThreshold;

        if (threshold == null) {
          return 'Le seuil de changement notable n’est pas atteint.';
        }

        return 'La variation reste inférieure au seuil défini '
            '(${_formatValue(threshold)}).';

      case _MeaningfulChangeStatus.unavailable:
        return 'Aucun seuil de changement notable n’est renseigné '
            'pour cette mesure.';
    }
  }

  String _conclusionMessage(_EvolutionConclusion conclusion) {
    switch (conclusion) {
      case _EvolutionConclusion.expectedAndMeaningful:
        return 'La variation dépasse le seuil défini pour cette mesure '
            'et évolue dans le sens attendu. Elle est compatible avec '
            'une évolution clinique favorable.';

      case _EvolutionConclusion.oppositeAndMeaningful:
        return 'La variation dépasse le seuil défini pour cette mesure, '
            'mais évolue dans le sens opposé au sens attendu.';

      case _EvolutionConclusion.belowThreshold:
        return 'La variation observée reste inférieure au seuil défini '
            'pour cette mesure. Elle peut correspondre à la variabilité '
            'de la mesure et ne permet pas, à elle seule, de conclure.';

      case _EvolutionConclusion.unchanged:
        return 'La première et la dernière mesure présentent '
            'la même valeur.';

      case _EvolutionConclusion.directionUnavailable:
        return 'Le sens favorable ou défavorable de cette mesure '
            'n’est pas défini. La variation est présentée sans '
            'interprétation clinique automatique.';

      case _EvolutionConclusion.thresholdUnavailable:
        return 'Aucun seuil de changement notable n’est renseigné '
            'pour cette mesure. Le sens de la variation peut être décrit, '
            'mais sa portée clinique ne peut pas être déterminée '
            'automatiquement.';
    }
  }

  String _confidenceLabel(_EvolutionConfidence confidence) {
    switch (confidence) {
      case _EvolutionConfidence.supported:
        return 'Conclusion étayée';

      case _EvolutionConfidence.cautious:
        return 'Conclusion prudente';

      case _EvolutionConfidence.insufficientChange:
        return 'Variation insuffisante';

      case _EvolutionConfidence.observationOnly:
        return 'Observation uniquement';
    }
  }

  IconData _confidenceIcon(_EvolutionConfidence confidence) {
    switch (confidence) {
      case _EvolutionConfidence.supported:
        return Icons.verified_outlined;

      case _EvolutionConfidence.cautious:
        return Icons.info_outline;

      case _EvolutionConfidence.insufficientChange:
        return Icons.horizontal_rule;

      case _EvolutionConfidence.observationOnly:
        return Icons.visibility_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Évolution entre la première et la dernière mesure',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 20),

            Text('Observation', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),

            Wrap(
              spacing: 32,
              runSpacing: 16,
              children: [
                SizedBox(
                  width: 180,
                  child: _EvolutionValueItem(
                    label: 'Première mesure',
                    value: _formatValue(analysis.firstValue),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: _EvolutionValueItem(
                    label: 'Dernière mesure',
                    value: _formatValue(analysis.lastValue),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: _EvolutionValueItem(
                    label: 'Variation observée',
                    value: _formatDelta(analysis.delta),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            Text('Analyse automatique', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),

            _EvolutionAnalysisLine(
              icon: analysis.direction == _EvolutionDirection.increase
                  ? Icons.arrow_upward
                  : analysis.direction == _EvolutionDirection.decrease
                  ? Icons.arrow_downward
                  : Icons.horizontal_rule,
              text:
                  'Sens observé : '
                  '${_directionLabel(analysis.direction)}',
            ),
            const SizedBox(height: 10),

            _EvolutionAnalysisLine(
              icon: Icons.swap_vert,
              text: _interpretationLabel(analysis.interpretation),
            ),
            const SizedBox(height: 10),

            _EvolutionAnalysisLine(
              icon: Icons.straighten,
              text: _meaningfulChangeLabel(analysis),
            ),

            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 16),

            Text('Conclusion', style: theme.textTheme.titleSmall),
            const SizedBox(height: 12),

            _EvolutionConfidenceIndicator(
              icon: _confidenceIcon(analysis.confidence),
              label: _confidenceLabel(analysis.confidence),
            ),
            const SizedBox(height: 12),

            Text(
              _conclusionMessage(analysis.conclusion),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _EvolutionConfidenceIndicator extends StatelessWidget {
  final IconData icon;
  final String label;

  const _EvolutionConfidenceIndicator({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.labelLarge),
        ],
      ),
    );
  }
}

class _EvolutionAnalysisLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _EvolutionAnalysisLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _EvolutionValueItem extends StatelessWidget {
  final String label;
  final String value;

  const _EvolutionValueItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleMedium),
      ],
    );
  }
}

class _EvolutionSeries {
  final String label;
  final List<FlSpot> spots;

  const _EvolutionSeries({required this.label, required this.spots});
}

List<_EvolutionMeasureGroup> _buildMeasureGroups({
  required List<DesktopResult> measures,
  required ExerciseDefinition definition,
}) {
  final groupPath = definition.followUpGroupPath?.trim();

  if (groupPath == null || groupPath.isEmpty) {
    return [
      _EvolutionMeasureGroup(
        key: 'default',
        label: definition.fallbackLabel,
        measures: measures,
      ),
    ];
  }

  final grouped = <String, List<DesktopResult>>{};
  final labels = <String, String>{};

  for (final measure in measures) {
    final groupKey = StructuredMetricReader.readString(
      structuredJson: measure.structuredJson,
      path: groupPath,
    ) ??
        'legacy';

    final labelPath = definition.followUpGroupLabelPath?.trim();

    final groupLabel = labelPath == null || labelPath.isEmpty
        ? groupKey
        : StructuredMetricReader.readString(
      structuredJson: measure.structuredJson,
      path: labelPath,
    ) ??
        groupKey;

    final resolvedGroupLabel =
    groupKey == 'legacy'
        ? 'Résultats antérieurs'
        : groupLabel;

    grouped.putIfAbsent(groupKey, () => []).add(measure);
    labels.putIfAbsent(
      groupKey,
          () => resolvedGroupLabel,
    );
  }

  return grouped.entries.map((entry) {
    final sorted = [...entry.value]
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return _EvolutionMeasureGroup(
      key: entry.key,
      label: labels[entry.key] ?? entry.key,
      measures: sorted,
    );
  }).toList();
}

List<_EvolutionSeries> _buildEvolutionSeries({
  required List<DesktopResult> measures,
  required ExerciseDefinition definition,
}) {
  final chartMetrics = definition.metrics
      .where((metric) => metric.showOnEvolutionChart)
      .toList();

  if (definition.followUpPolicy == FollowUpPolicy.disabled) {
    return const [];
  }

  if (chartMetrics.isNotEmpty) {
    final metricSeries = <_EvolutionSeries>[];

    for (final metric in chartMetrics) {
      final spots = <FlSpot>[];

      for (int i = 0; i < measures.length; i++) {
        final value = StructuredMetricReader.readDouble(
          structuredJson: measures[i].structuredJson,
          path: metric.path,
        );

        if (value == null) {
          continue;
        }

        spots.add(FlSpot(i.toDouble(), value));
      }

      if (spots.isNotEmpty) {
        metricSeries.add(
          _EvolutionSeries(label: metric.fallbackLabel, spots: spots),
        );
      }
    }

    if (metricSeries.isNotEmpty) {
      return metricSeries;
    }
  }

  if (definition.followUpPolicy == FollowUpPolicy.declaredMetricsOnly) {
    return const [];
  }

  final fallbackSpots = <FlSpot>[];

  for (int i = 0; i < measures.length; i++) {
    final value = measures[i].scoreTotal;

    if (value == null) {
      continue;
    }

    fallbackSpots.add(FlSpot(i.toDouble(), value));
  }

  if (fallbackSpots.isEmpty) {
    return const [];
  }

  return [_EvolutionSeries(label: 'Score', spots: fallbackSpots)];
}

ExerciseMetricDefinition? _findFollowUpMetric(ExerciseDefinition definition) {
  for (final metric in definition.metrics) {
    if (metric.useForFollowUp) {
      return metric;
    }
  }

  return null;
}

List<_MeasureMetricDisplay> _readChartMetricDisplays({
  required DesktopResult measure,
  required ExerciseDefinition definition,
}) {
  final displays = <_MeasureMetricDisplay>[];

  for (final metric in definition.metrics) {
    if (!metric.showOnEvolutionChart) {
      continue;
    }

    final value = StructuredMetricReader.readDouble(
      structuredJson: measure.structuredJson,
      path: metric.path,
    );

    if (value == null) {
      continue;
    }

    final unit = metric.defaultUnit ?? definition.defaultUnit;
    final decimals = metric.scoreDecimals ?? definition.scoreDecimals;

    final normalizedUnit = unit?.trim();

    final formattedValue =
    normalizedUnit == null || normalizedUnit.isEmpty
        ? value.toStringAsFixed(decimals)
        : '${value.toStringAsFixed(decimals)} $normalizedUnit';

    displays.add(
      _MeasureMetricDisplay(
        label: metric.fallbackLabel,
        value: formattedValue,
      ),
    );
  }

  return displays;
}

double? _readFollowUpValue({
  required DesktopResult measure,
  required ExerciseDefinition definition,
}) {
  final followUpMetric = _findFollowUpMetric(definition);

  if (followUpMetric != null) {
    final value = StructuredMetricReader.readDouble(
      structuredJson: measure.structuredJson,
      path: followUpMetric.path,
    );

    if (value != null) {
      return value;
    }
  }

  if (definition.followUpPolicy == FollowUpPolicy.legacyScoreFallback) {
    return measure.scoreTotal;
  }

  return null;
}

Color _evolutionSeriesColor(BuildContext context, int index) {
  final colorScheme = Theme.of(context).colorScheme;

  final colors = [
    colorScheme.primary,
    colorScheme.secondary,
    colorScheme.tertiary,
    colorScheme.error,
  ];

  return colors[index % colors.length];
}

class _EvolutionChartLegend extends StatelessWidget {
  final List<_EvolutionSeries> series;

  const _EvolutionChartLegend({required this.series});

  @override
  Widget build(BuildContext context) {
    if (series.length <= 1) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 20,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: [
        for (int i = 0; i < series.length; i++)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 4,
                decoration: BoxDecoration(
                  color: _evolutionSeriesColor(context, i),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                series[i].label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
      ],
    );
  }
}

class _EvolutionLineChart extends StatelessWidget {
  final List<_EvolutionSeries> series;
  final List<DesktopResult> measures;
  final String? unit;
  final int scoreDecimals;

  const _EvolutionLineChart({
    required this.series,
    required this.measures,
    required this.unit,
    required this.scoreDecimals,
  });

  @override
  Widget build(BuildContext context) {
    final allSpots = series
        .expand((evolutionSeries) => evolutionSeries.spots)
        .toList();

    if (allSpots.isEmpty) {
      return const SizedBox.shrink();
    }

    final values = allSpots.map((spot) => spot.y).toList();

    final minValue = values.reduce(math.min);
    final maxValue = values.reduce(math.max);
    final range = maxValue - minValue;

    final minY = range == 0 ? minValue - 1 : minValue - range * 0.15;

    final maxY = range == 0 ? maxValue + 1 : maxValue + range * 0.15;

    final maxX = allSpots.map((spot) => spot.x).reduce(math.max);

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: maxX,
        minY: minY,
        maxY: maxY,
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(),
          rightTitles: const AxisTitles(),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              interval: 1,
              getTitlesWidget: (value, meta) {
                if (value != value.roundToDouble()) {
                  return const SizedBox.shrink();
                }

                final index = value.toInt();

                if (index < 0 || index >= measures.length) {
                  return const SizedBox.shrink();
                }

                final formatter = DateFormat.Md(
                  Localizations.localeOf(context).toLanguageTag(),
                );

                final date = DateTime.fromMillisecondsSinceEpoch(
                  measures[index].createdAt,
                );

                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    formatter.format(date),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 64,
              getTitlesWidget: (value, meta) {
                final normalizedUnit = unit?.trim();

                final label = normalizedUnit == null || normalizedUnit.isEmpty
                    ? value.toStringAsFixed(scoreDecimals)
                    : '${value.toStringAsFixed(scoreDecimals)} '
                          '$normalizedUnit';

                return Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall,
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          for (int i = 0; i < series.length; i++)
            LineChartBarData(
              spots: series[i].spots,
              isCurved: true,
              barWidth: 4,
              color: _evolutionSeriesColor(context, i),
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(show: false),
            ),
        ],
      ),
    );
  }
}

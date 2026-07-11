import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:abak_desktop_companion/features/results/data/desktop_result_repository.dart';
import 'package:abak_desktop_companion/features/results/models/desktop_result.dart';
import 'package:abak_shared/abak_shared.dart';

import '../services/structured_metric_reader.dart';
import 'exercise_evolution_detail_screen.dart';

class EpisodeEvolutionScreen extends StatelessWidget {
  final String careEpisodeId;
  final String patientName;

  const EpisodeEvolutionScreen({
    super.key,
    required this.careEpisodeId,
    required this.patientName,
  });

  Map<String, List<DesktopResult>> _groupResultsByExercise(
    List<DesktopResult> results,
  ) {
    final grouped = <String, List<DesktopResult>>{};

    for (final result in results) {
      grouped.putIfAbsent(result.exoId, () => []);
      grouped[result.exoId]!.add(result);
    }

    for (final entry in grouped.entries) {
      entry.value.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    return grouped;
  }

  ExerciseMetricDefinition? _followUpMetric(ExerciseDefinition definition) {
    for (final metric in definition.metrics) {
      if (metric.useForFollowUp) {
        return metric;
      }
    }

    return null;
  }

  double? _readFollowUpValue({
    required DesktopResult measure,
    required ExerciseDefinition definition,
  }) {
    final metric = _followUpMetric(definition);

    if (metric != null) {
      final metricValue = StructuredMetricReader.readDouble(
        structuredJson: measure.structuredJson,
        path: metric.path,
      );

      if (metricValue != null) {
        return metricValue;
      }
    }

    return measure.scoreTotal;
  }

  String? _resolvedUnit(ExerciseDefinition definition) {
    final metric = _followUpMetric(definition);

    final unit = metric?.defaultUnit ?? definition.defaultUnit;
    final normalizedUnit = unit?.trim();

    if (normalizedUnit == null || normalizedUnit.isEmpty) {
      return null;
    }

    return normalizedUnit;
  }

  int _resolvedScoreDecimals(ExerciseDefinition definition) {
    final metric = _followUpMetric(definition);

    return metric?.scoreDecimals ?? definition.scoreDecimals;
  }

  bool _hasChartSeriesWithEvolution({
    required List<DesktopResult> measures,
    required ExerciseDefinition definition,
  }) {
    final chartMetrics = definition.metrics.where(
      (metric) => metric.showOnEvolutionChart,
    );

    for (final metric in chartMetrics) {
      final valueCount = measures.where((measure) {
        return StructuredMetricReader.readDouble(
              structuredJson: measure.structuredJson,
              path: metric.path,
            ) !=
            null;
      }).length;

      if (valueCount >= 2) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    final repository = DesktopResultRepository();

    return Scaffold(
      appBar: AppBar(title: const Text("Évolution de l'épisode")),
      body: FutureBuilder<List<DesktopResult>>(
        future: repository.getResultsForCareEpisode(careEpisodeId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final results = snapshot.data ?? [];

          if (results.isEmpty) {
            return const Center(
              child: Text("Aucun résultat disponible pour cet épisode."),
            );
          }

          final grouped = _groupResultsByExercise(results);

          final exercises = grouped.entries.toList()
            ..sort((a, b) {
              final labelA = ClinicalActivityCatalog.displayLabel(a.key);
              final labelB = ClinicalActivityCatalog.displayLabel(b.key);

              return labelA.compareTo(labelB);
            });

          final formatter = DateFormat.yMd(
            Localizations.localeOf(context).toLanguageTag(),
          );

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                "Exercices suivis",
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
              ...exercises.map((entry) {
                final exoId = entry.key;
                final measures = entry.value;

                final definition = ClinicalActivityCatalog.infoFor(exoId);

                final followUpMeasures = measures.where((measure) {
                  return _readFollowUpValue(
                        measure: measure,
                        definition: definition,
                      ) !=
                      null;
                }).toList();

                final unit = _resolvedUnit(definition);
                final scoreDecimals = _resolvedScoreDecimals(definition);

                String formatValue(double? value) {
                  if (value == null) {
                    return '-';
                  }

                  final formattedValue = value.toStringAsFixed(scoreDecimals);

                  if (unit == null) {
                    return formattedValue;
                  }

                  return '$formattedValue $unit';
                }

                final DesktopResult firstMeasure;
                final DesktopResult lastMeasure;

                if (followUpMeasures.isNotEmpty) {
                  firstMeasure = followUpMeasures.first;
                  lastMeasure = followUpMeasures.last;
                } else {
                  firstMeasure = measures.first;
                  lastMeasure = measures.last;
                }

                final firstValue = _readFollowUpValue(
                  measure: firstMeasure,
                  definition: definition,
                );

                final lastValue = _readFollowUpValue(
                  measure: lastMeasure,
                  definition: definition,
                );

                final firstDate = formatter.format(
                  DateTime.fromMillisecondsSinceEpoch(firstMeasure.createdAt),
                );

                final lastDate = formatter.format(
                  DateTime.fromMillisecondsSinceEpoch(lastMeasure.createdAt),
                );

                final canShowEvolution =
                    followUpMeasures.length >= 2 ||
                    _hasChartSeriesWithEvolution(
                      measures: measures,
                      definition: definition,
                    );

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ClinicalActivityCatalog.displayLabel(exoId),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "${measures.length} "
                          "évaluation${measures.length > 1 ? 's' : ''}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Première : "
                          "${formatValue(firstValue)} "
                          "($firstDate)",
                        ),
                        Text(
                          "Dernière : "
                          "${formatValue(lastValue)} "
                          "($lastDate)",
                        ),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: canShowEvolution
                              ? OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            ExerciseEvolutionDetailScreen(
                                              patientName: patientName,
                                              exoId: exoId,
                                              measures: measures,
                                            ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.show_chart),
                                  label: const Text("Voir l'évolution"),
                                )
                              : Text(
                                  'Une seule valeur chiffrée disponible',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}

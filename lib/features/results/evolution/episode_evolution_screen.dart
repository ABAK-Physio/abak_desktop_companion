import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:abak_desktop_companion/features/results/data/desktop_result_repository.dart';
import 'package:abak_desktop_companion/features/results/models/desktop_result.dart';
import 'exercise_evolution_detail_screen.dart';
import 'package:abak_shared/abak_shared.dart';

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

  @override
  Widget build(BuildContext context) {
    final repository = DesktopResultRepository();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Évolution de l'épisode"),
      ),
      body: FutureBuilder<List<DesktopResult>>(
        future: repository.getResultsForCareEpisode(careEpisodeId),
        builder: (context, snapshot) {
          final results = snapshot.data ?? [];
          final grouped = _groupResultsByExercise(results);
          final exercises = grouped.entries.toList()
            ..sort((a, b) {
              final labelA = ClinicalActivityCatalog.displayLabel(a.key);
              final labelB = ClinicalActivityCatalog.displayLabel(b.key);
              return labelA.compareTo(labelB);
            });

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (results.isEmpty) {
            return const Center(
              child: Text("Aucun résultat disponible pour cet épisode."),
            );
          }

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
                final String exoId = entry.key;
                final measures = entry.value;

                final first = measures.first;
                final last = measures.last;

                final unit = last.measureUnit?.trim().isNotEmpty == true
                    ? ' ${last.measureUnit!.trim()}'
                    : '';

                final firstValue = first.scoreTotal == null
                    ? '-'
                    : '${first.scoreTotal!.toStringAsFixed(2)}$unit';

                final lastValue = last.scoreTotal == null
                    ? '-'
                    : '${last.scoreTotal!.toStringAsFixed(2)}$unit';

                final formatter = DateFormat.yMd(
                  Localizations.localeOf(context).toLanguageTag(),
                );

                final firstDate = formatter.format(
                  DateTime.fromMillisecondsSinceEpoch(first.createdAt),
                );

                final lastDate = formatter.format(
                  DateTime.fromMillisecondsSinceEpoch(last.createdAt),
                );

                final numericCount =
                    measures.where((measure) => measure.scoreTotal != null).length;

                final canShowEvolution = numericCount >= 2;

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
                          "${measures.length} évaluation${measures.length > 1 ? 's' : ''}",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        Text("Première : $firstValue ($firstDate)"),
                        Text("Dernière : $lastValue ($lastDate)"),
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerRight,
                          child: canShowEvolution
                              ? OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ExerciseEvolutionDetailScreen(
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
import 'package:flutter/material.dart';

import '../../../models/care_episode_assessment.dart';
import '../../../models/care_episode_report.dart';
import '../../../../results/models/desktop_result.dart';

class EpisodeSummaryCard extends StatelessWidget {
  final Future<List<DesktopResult>> resultsFuture;
  final Future<List<CareEpisodeAssessment>> assessmentsFuture;
  final Future<List<CareEpisodeReport>> reportsFuture;

  const EpisodeSummaryCard({
    super.key,
    required this.resultsFuture,
    required this.assessmentsFuture,
    required this.reportsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<DesktopResult>>(
          future: resultsFuture,
          builder: (context, resultsSnapshot) {
            final distinctTestCount = (resultsSnapshot.data ?? [])
                .map((result) => result.exoId)
                .toSet()
                .length;

            return FutureBuilder<List<CareEpisodeAssessment>>(
              future: assessmentsFuture,
              builder: (context, assessmentsSnapshot) {
                final assessmentCount =
                    assessmentsSnapshot.data?.length ?? 0;

                return FutureBuilder<List<CareEpisodeReport>>(
                  future: reportsFuture,
                  builder: (context, reportsSnapshot) {
                    final reportCount = reportsSnapshot.data?.length ?? 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Résumé de l’épisode',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _SummaryLine(
                                  label: 'Nombre de tests',
                                  value:
                                  resultsSnapshot.connectionState ==
                                      ConnectionState.waiting
                                      ? '…'
                                      : '$distinctTestCount',
                                ),
                                const Divider(),
                                _SummaryLine(
                                  label: 'Nombre de bilans',
                                  value:
                                  assessmentsSnapshot.connectionState ==
                                      ConnectionState.waiting
                                      ? '…'
                                      : '$assessmentCount',
                                ),
                                const Divider(),
                                _SummaryLine(
                                  label: 'Nombre de rapports',
                                  value:
                                  reportsSnapshot.connectionState ==
                                      ConnectionState.waiting
                                      ? '…'
                                      : '$reportCount',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}
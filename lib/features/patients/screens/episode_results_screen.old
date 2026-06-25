import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../results/data/desktop_result_repository.dart';
import '../../results/models/desktop_result.dart';
import '../../results/result_detail_screen.dart';

class EpisodeResultsScreen extends StatelessWidget {
  final String caseId;
  final String caseLabel;

  EpisodeResultsScreen({
    super.key,
    required this.caseId,
    required this.caseLabel,
  });

  final DesktopResultRepository _repository =
  DesktopResultRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Résultats ABAK — $caseLabel'),
      ),
      body: FutureBuilder<List<DesktopResult>>(
        future: _repository.getResultsForMobileCase(caseId),
        builder: (context, snapshot) {
          final results = snapshot.data ?? [];

          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur : ${snapshot.error}'),
            );
          }

          if (results.isEmpty) {
            return const Center(
              child: Text(
                'Aucun résultat ABAK associé à cet épisode.',
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(24),
            itemCount: results.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              return _EpisodeResultTile(
                result: results[index],
              );
            },
          );
        },
      ),
    );
  }
}

class _EpisodeResultTile extends StatelessWidget {
  final DesktopResult result;

  const _EpisodeResultTile({
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(result.createdAt);
    final locale = Localizations.localeOf(context);
    final formatter = DateFormat.yMd(locale.toLanguageTag());

    return Card(
      child: ListTile(
        leading: const Icon(Icons.science_outlined),
        title: Text(result.exoId),
        subtitle: Text(
          [
            formatter.format(date),
            if (result.scoreTotal != null)
              'Score : ${result.scoreTotal}',
            if (result.measureUnit != null)
              result.measureUnit!,
            'Sync : ${result.syncState}',
          ].join(' · '),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ResultDetailScreen(
                result: result,
              ),
            ),
          );
        },
      ),
    );
  }
}
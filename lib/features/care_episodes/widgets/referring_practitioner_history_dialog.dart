import 'package:flutter/material.dart';
import '../../../core/utils/date_format_utils.dart';
import '../data/care_episode_referring_practitioner_repository.dart';
import '../models/care_episode_referring_practitioner_history_item.dart';

class ReferringPractitionerHistoryDialog extends StatelessWidget {
  final String careEpisodeId;

  ReferringPractitionerHistoryDialog({
    super.key,
    required this.careEpisodeId,
  });

  final CareEpisodeReferringPractitionerRepository _repository =
  CareEpisodeReferringPractitionerRepository();

  String _formatDate(BuildContext context, int timestamp) {
    return DateFormatUtils.formatTimestampForDisplay(
      context,
      timestamp,
    );
  }

  String _periodLabel(
      BuildContext context,
      CareEpisodeReferringPractitionerHistoryItem item,
      ) {
    final start = _formatDate(context, item.startedAt);

    if (item.endedAt == null) {
      return 'Depuis le $start';
    }

    final end = _formatDate(context, item.endedAt!);
    return 'Du $start au $end';
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Historique des kinés référents'),
      content: SizedBox(
        width: 520,
        child:
        FutureBuilder<List<CareEpisodeReferringPractitionerHistoryItem>>(
          future: _repository.getReferringPractitionerHistoryWithNames(
            careEpisodeId,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 120,
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            if (snapshot.hasError) {
              return Text(
                'Erreur lors du chargement de l’historique : '
                    '${snapshot.error}',
              );
            }

            final items = snapshot.data ??
                const <CareEpisodeReferringPractitionerHistoryItem>[];

            if (items.isEmpty) {
              return const Text(
                'Aucun kiné référent n’a encore été enregistré '
                    'pour cet épisode.',
              );
            }

            return ListView.separated(
              shrinkWrap: true,
              itemCount: items.length,
              separatorBuilder: (context, index) =>
              const Divider(height: 24),
              itemBuilder: (context, index) {
                final item = items[index];

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    item.isCurrent
                        ? Icons.person_pin_circle_outlined
                        : Icons.history,
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.isArchived
                              ? '${item.displayName} — archivé'
                              : item.displayName,
                        ),
                      ),
                      if (item.isCurrent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outlineVariant,
                            ),
                          ),
                          child: Text(
                            'Référent actuel',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      _periodLabel(context, item),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Fermer'),
        ),
      ],
    );
  }
}
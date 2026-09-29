import 'package:flutter/material.dart';
import '../../../core/utils/date_format_utils.dart';
import '../data/care_episode_referring_practitioner_repository.dart';
import '../models/care_episode_referring_practitioner_history_item.dart';
import 'package:abak_shared/abak_shared.dart';
import '../../../generated/l10n.dart';

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
    final s = S.of(context);
    final start = _formatDate(context, item.startedAt);

    if (item.endedAt == null) {
      return s.referringPractitionerHistoryDialog_since(start);
    }

    final end = _formatDate(context, item.endedAt!);
    return s.referringPractitionerHistoryDialog_fromTo(start, end);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(S.of(context).referringPractitionerHistory_title),
          ),
          ContextHelpButton(
            technicalInformationLabel: S.of(context).g_helpTooltip,
            title: S.of(context).referringPractitionerHistory_title,
            content: S.of(context).referringPractitionerHistory_help,
          ),
        ],
      ),
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
                s.referringPractitionerHistoryDialog_loadHistoryError(
                  snapshot.error.toString(),
                ),
              );
            }

            final items = snapshot.data ??
                const <CareEpisodeReferringPractitionerHistoryItem>[];

            if (items.isEmpty) {
              return Text(
                s.referringPractitionerHistoryDialog_noHistory,
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
                              ? s.referringPractitionerHistoryDialog_archivedPractitioner(item.displayName)
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
                            s.referringPractitionerHistoryDialog_currentPractitioner,
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
          child: Text(s.referringPractitionerHistoryDialog_close),
        ),
      ],
    );
  }
}
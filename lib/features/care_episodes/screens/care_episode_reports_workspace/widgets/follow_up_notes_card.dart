import 'package:flutter/material.dart';

import 'package:abak_desktop_companion/core/utils/date_format_utils.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/care_episode_note.dart';

import 'scrollable_workspace_card.dart';
import 'table_header.dart';

typedef NoteIncludedChanged = void Function({
required String noteId,
required bool included,
});

class FollowUpNotesCard extends StatelessWidget {
  final Future<List<CareEpisodeNote>> notesFuture;
  final Set<String> selectedNoteIds;
  final bool selectionEnabled;
  final VoidCallback onAddNote;
  final VoidCallback? onExpand;
  final NoteIncludedChanged onNoteIncludedChanged;

  const FollowUpNotesCard({
    super.key,
    required this.notesFuture,
    required this.selectedNoteIds,
    required this.selectionEnabled,
    required this.onAddNote,
    required this.onExpand,
    required this.onNoteIncludedChanged,
  });

  String _noteTitle(String content) {
    final normalized = content.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (normalized.isEmpty) {
      return 'Note de suivi';
    }

    if (normalized.length <= 40) {
      return normalized;
    }

    return '${normalized.substring(0, 40)}…';
  }

  String _notePreview(String content) {
    final normalized = content.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (normalized.isEmpty) {
      return '—';
    }

    if (normalized.length <= 100) {
      return normalized;
    }

    return '${normalized.substring(0, 100)}…';
  }

  @override
  Widget build(BuildContext context) {
    return ScrollableWorkspaceCard(
      title: 'Notes de suivi',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onExpand != null)
            IconButton(
              onPressed: onExpand,
              tooltip: 'Agrandir',
              icon: const Icon(Icons.zoom_out_map),
            ),
          IconButton(
            onPressed: onAddNote,
            tooltip: 'Ajouter une note de suivi',
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      child: FutureBuilder<List<CareEpisodeNote>>(
        future: notesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Impossible de charger les notes de suivi.',
              ),
            );
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return const Center(
              child: Text('Aucune note de suivi.'),
            );
          }

          return Column(
            children: [
              const TableHeader(
                columns: [
                  Expanded(
                    flex: 2,
                    child: Text('Date'),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text('Titre'),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text('Note'),
                  ),
                  SizedBox(
                    width: 72,
                    child: Text('Inclure'),
                  ),
                ],
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: notes.length,
                  separatorBuilder: (_, _) =>
                  const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final note = notes[index];

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 2,
                            child: Text(
                              DateFormatUtils.formatTimestampForDisplay(
                                context,
                                note.noteDate,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              _noteTitle(note.content),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              _notePreview(note.content),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ),
                          SizedBox(
                            width: 72,
                            child: Center(
                              child: Checkbox(
                                value: selectedNoteIds.contains(
                                  note.noteId,
                                ),
                                onChanged: selectionEnabled
                                    ? (value) {
                                  onNoteIncludedChanged(
                                    noteId: note.noteId,
                                    included: value ?? false,
                                  );
                                }
                                    : null,
                              ),
                            ),
                          ),
                        ],
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
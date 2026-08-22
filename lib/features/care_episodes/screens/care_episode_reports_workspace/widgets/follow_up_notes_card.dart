import 'package:flutter/material.dart';
import '../../../../../generated/l10n.dart';
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
  final ValueChanged<CareEpisodeNote> onEditNote;

  const FollowUpNotesCard({
    super.key,
    required this.notesFuture,
    required this.selectedNoteIds,
    required this.selectionEnabled,
    required this.onAddNote,
    required this.onExpand,
    required this.onNoteIncludedChanged,
    required this.onEditNote,
  });

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
    final s = S.of(context);
    return ScrollableWorkspaceCard(
      title: s.careEpisodeReportsWorkspace_followUpNotes,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onExpand != null)
            IconButton(
              onPressed: onExpand,
              tooltip: s.careEpisodeReportsWorkspace_expand,
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
            return Center(
              child: Text(
                s.careEpisodeReportsWorkspace_followUpNotesLoadError,
              ),
            );
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return Center(
              child: Text(
                s.careEpisodeReportsWorkspace_noFollowUpNotes,
              ),
            );
          }

          return Column(
            children: [
              TableHeader(
                columns: [
                  Expanded(
                    flex: 2,
                    child: Text(s.careEpisodeReportsWorkspace_date),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(s.careEpisodeReportsWorkspace_title),
                  ),
                  Expanded(
                    flex: 5,
                    child: Text(s.careEpisodeReportsWorkspace_note),
                  ),
                  SizedBox(
                    width: 72,
                    child: Text(s.careEpisodeReportsWorkspace_include),
                  ),
                  const SizedBox(width: 42),
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
                              note.title.isNotEmpty
                                  ? note.title
                                  : s.careEpisodeReportsWorkspace_followUpNoteDefaultTitle,
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
                          SizedBox(
                            width: 42,
                            child: IconButton(
                              onPressed: () => onEditNote(note),
                              tooltip: 'Modifier la note',
                              icon: const Icon(Icons.edit_outlined),
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
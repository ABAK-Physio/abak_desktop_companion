import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/care_episode_repository.dart';
import '../models/care_episode.dart';
import '../models/care_episode_note.dart';
import 'package:intl/intl.dart';

class CareEpisodeDetailScreen extends StatefulWidget {
  final CareEpisode episode;

  const CareEpisodeDetailScreen({
    super.key,
    required this.episode,
  });

  @override
  State<CareEpisodeDetailScreen> createState() =>
      _CareEpisodeDetailScreenState();
}

class _CareEpisodeDetailScreenState extends State<CareEpisodeDetailScreen> {
  final CareEpisodeRepository _repository = CareEpisodeRepository();

  int _refreshToken = 0;

  void _refresh() {
    setState(() {
      _refreshToken++;
    });
  }

  Future<void> _addFollowUpNote() async {
    final controller = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nouvelle note de suivi'),
          content: SizedBox(
            width: 520,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              minLines: 5,
              maxLines: 10,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );

    final content = controller.text.trim();
    controller.dispose();

    if (confirmed != true || content.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    final note = CareEpisodeNote(
      noteId: const Uuid().v4(),
      careEpisodeId: widget.episode.careEpisodeId,
      noteDate: now,
      content: content,
      createdAt: now,
    );

    await _repository.insertNote(note);

    if (!mounted) return;

    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.episode.displayTitle),
      ),
      body: ListView(
        key: ValueKey(_refreshToken),
        padding: const EdgeInsets.all(24),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pathologie',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.episode.pathologyLabel,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Compte rendu initial',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.episode.displayInitialReport,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Résultats ABAK',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Aucun résultat rattaché pour le moment.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: FutureBuilder<List<CareEpisodeNote>>(
                key: ValueKey('notes-$_refreshToken'),
                future: _repository.getNotesForEpisode(
                  widget.episode.careEpisodeId,
                ),
                builder: (context, snapshot) {
                  final notes = snapshot.data ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Notes de suivi',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: _addFollowUpNote,
                            icon: const Icon(Icons.add),
                            label: const Text('Ajouter'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (snapshot.connectionState == ConnectionState.waiting)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        )
                      else if (notes.isEmpty)
                        const Text('Aucune note de suivi.')
                      else
                        ...notes.map(
                              (note) {
                            final date = DateTime.fromMillisecondsSinceEpoch(
                              note.noteDate,
                            );

                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.note_alt_outlined),
                              title: Text(
                                DateFormat.yMd(
                                  Localizations.localeOf(context).toLanguageTag(),
                                ).format(date),
                              ),
                              subtitle: Text(note.content),
                            );
                          },
                        ),
                    ],
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Conclusion',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Aucune conclusion rédigée.',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rapport',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Aucun rapport généré.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
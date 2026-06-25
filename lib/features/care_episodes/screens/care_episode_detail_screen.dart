import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/care_episode_repository.dart';
import '../models/care_episode.dart';
import '../models/care_episode_note.dart';
import 'package:intl/intl.dart';
import '../../results/data/desktop_result_repository.dart';
import '../../results/models/desktop_result.dart';
import '../../results/result_detail_screen.dart';

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
  final DesktopResultRepository _resultRepository =
  DesktopResultRepository();

  int _refreshToken = 0;
  bool _hasChanged = false;
  late CareEpisode _episode;

  @override
  void initState() {
    super.initState();
    _episode = widget.episode;
  }

  void _refresh() {
    setState(() {
      _refreshToken++;
    });
  }

  Future<void> _editFinalConclusion() async {
    final controller = TextEditingController(
      text: _episode.finalConclusion ?? '',
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Conclusion'),
          content: SizedBox(
            width: 520,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Conclusion finale',
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
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    final conclusion = controller.text.trim();
    controller.dispose();

    if (confirmed != true) return;

    await _repository.updateFinalConclusion(
      careEpisodeId: widget.episode.careEpisodeId,
      finalConclusion: conclusion.isEmpty ? null : conclusion,
    );

    _hasChanged = true;

    setState(() {
      _episode = CareEpisode(
        careEpisodeId: _episode.careEpisodeId,
        patientId: _episode.patientId,
        title: _episode.title,
        pathologyLabel: _episode.pathologyLabel,
        initialReport: _episode.initialReport,
        finalConclusion: conclusion.isEmpty ? null : conclusion,
        createdAt: _episode.createdAt,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        archivedAt: _episode.archivedAt,
      );
    });

    if (!mounted) return;

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

    _hasChanged = true;
    if (!mounted) return;

    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        Navigator.of(context).pop(_hasChanged);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_episode.displayTitle),
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
                    Text(_episode.pathologyLabel),
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
                    Text(_episode.displayInitialReport),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _AbakResultsCard(
              repository: _resultRepository,
              careEpisodeId: _episode.careEpisodeId,
              refreshToken: _refreshToken,
              onChanged: () {
                _hasChanged = true;
                _refresh();
              },
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: FutureBuilder<List<CareEpisodeNote>>(
                  key: ValueKey('notes-$_refreshToken'),
                  future: _repository.getNotesForEpisode(
                    _episode.careEpisodeId,
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
                        if (snapshot.connectionState ==
                            ConnectionState.waiting)
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
                                    Localizations.localeOf(context)
                                        .toLanguageTag(),
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Conclusion',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _editFinalConclusion,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Modifier'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _episode.finalConclusion?.trim().isNotEmpty == true
                          ? _episode.finalConclusion!.trim()
                          : 'Aucune conclusion rédigée.',
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
      ),
    );
  }
}

class _AbakResultsCard extends StatelessWidget {
  final DesktopResultRepository repository;
  final String careEpisodeId;
  final int refreshToken;
  final VoidCallback onChanged;

  const _AbakResultsCard({
    required this.repository,
    required this.careEpisodeId,
    required this.refreshToken,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<DesktopResult>>(
          key: ValueKey('abak-results-$refreshToken'),
          future: repository.getResultsForCareEpisode(careEpisodeId),
          builder: (context, snapshot) {
            final results = snapshot.data ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Résultats ABAK',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )
                else if (results.isEmpty)
                  const Text('Aucun résultat rattaché pour le moment.')
                else
                  ...results.map(
                        (result) {
                      final date = DateTime.fromMillisecondsSinceEpoch(
                        result.createdAt,
                      );

                      final formatter = DateFormat.yMd(
                        Localizations.localeOf(context).toLanguageTag(),
                      );

                      final mobileOrigin =
                          result.mobilePathologyLabel ??
                              result.mobilePatientLabel;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.bar_chart_outlined),
                        title: Text(result.exoId),
                        subtitle: Text(
                          [
                            formatter.format(date),
                            if (result.scoreTotal != null)
                              'Score : ${result.scoreTotal}',
                            if (result.measureUnit != null)
                              result.measureUnit!,
                            if (mobileOrigin != null &&
                                mobileOrigin.trim().isNotEmpty)
                              'Origine ABAK : ${mobileOrigin.trim()}',
                          ].join(' · '),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final changed =
                          await Navigator.of(context).push<bool>(
                            MaterialPageRoute(
                              builder: (_) => ResultDetailScreen(
                                result: result,
                              ),
                            ),
                          );

                          if (changed == true) {
                            onChanged();
                          }
                        },
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
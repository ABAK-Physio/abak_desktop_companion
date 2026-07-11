import 'package:flutter/material.dart';

import '../data/episode_note_repository.dart';
import '../models/episode_note.dart';

class EpisodeNotesScreen extends StatefulWidget {
  final String caseId;
  final String caseLabel;

  const EpisodeNotesScreen({
    super.key,
    required this.caseId,
    required this.caseLabel,
  });

  @override
  State<EpisodeNotesScreen> createState() => _EpisodeNotesScreenState();
}

class _EpisodeNotesScreenState extends State<EpisodeNotesScreen> {
  final EpisodeNoteRepository _repository = EpisodeNoteRepository();

  late Future<List<EpisodeNote>> _futureNotes;

  @override
  void initState() {
    super.initState();
    _futureNotes = _loadNotes();
  }

  Future<List<EpisodeNote>> _loadNotes() {
    return _repository.getByCaseId(widget.caseId);
  }

  Future<void> _refresh() async {
    setState(() {
      _futureNotes = _loadNotes();
    });
  }

  Future<void> _openEditor({EpisodeNote? note}) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) =>
            _EpisodeNoteEditorScreen(caseId: widget.caseId, note: note),
      ),
    );

    if (changed == true) {
      await _refresh();
    }
  }

  Widget _buildNoteTile(EpisodeNote note) {
    final updatedAt = note.updatedAt ?? note.createdAt;
    final date = DateTime.fromMillisecondsSinceEpoch(updatedAt);

    return Card(
      child: ListTile(
        leading: const Icon(Icons.notes_outlined),
        title: Text(note.title),
        subtitle: Text(
          [
            'Modifiée le : ${date.toLocal()}',
            if (note.content.trim().isNotEmpty) note.content.trim(),
          ].join('\n'),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _openEditor(note: note),
      ),
    );
  }

  Future<void> _archiveNote(EpisodeNote note) async {
    await _repository.archive(note.noteId);
    await _refresh();
  }

  Future<void> _confirmArchive(EpisodeNote note) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Archiver la note ?'),
          content: Text('La note "${note.title}" ne sera plus affichée.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Archiver'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _archiveNote(note);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notes — ${widget.caseLabel}'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<EpisodeNote>>(
        future: _futureNotes,
        builder: (context, snapshot) {
          final notes = snapshot.data ?? [];

          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: () => _openEditor(),
                  icon: const Icon(Icons.add),
                  label: const Text('Nouvelle note'),
                ),
              ),
              const SizedBox(height: 16),
              if (notes.isEmpty)
                const Text('Aucune note associée à cet épisode.')
              else
                ...notes.map(
                  (note) => Dismissible(
                    key: ValueKey(note.noteId),
                    direction: DismissDirection.endToStart,
                    confirmDismiss: (_) async {
                      await _confirmArchive(note);
                      return false;
                    },
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 24),
                      color: Theme.of(context).colorScheme.error,
                      child: Icon(
                        Icons.archive_outlined,
                        color: Theme.of(context).colorScheme.onError,
                      ),
                    ),
                    child: _buildNoteTile(note),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _EpisodeNoteEditorScreen extends StatefulWidget {
  final String caseId;
  final EpisodeNote? note;

  const _EpisodeNoteEditorScreen({required this.caseId, this.note});

  @override
  State<_EpisodeNoteEditorScreen> createState() =>
      _EpisodeNoteEditorScreenState();
}

class _EpisodeNoteEditorScreenState extends State<_EpisodeNoteEditorScreen> {
  final EpisodeNoteRepository _repository = EpisodeNoteRepository();

  final _titleController = TextEditingController();
  final _contentController = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();

    _titleController.text = widget.note?.title ?? '';
    _contentController.text = widget.note?.content ?? '';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le titre est obligatoire.')),
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    if (widget.note == null) {
      await _repository.create(
        caseId: widget.caseId,
        title: title,
        content: content,
      );
    } else {
      await _repository.update(
        noteId: widget.note!.noteId,
        title: title,
        content: content,
      );
    }

    if (!mounted) return;

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Modifier la note' : 'Nouvelle note'),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Enregistrer'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Titre',
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _contentController,
            minLines: 10,
            maxLines: 20,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Contenu',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}

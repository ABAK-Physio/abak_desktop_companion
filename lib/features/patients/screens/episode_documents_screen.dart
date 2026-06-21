import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../data/episode_document_repository.dart';
import '../models/episode_document.dart';
import '../services/episode_document_storage_service.dart';

class EpisodeDocumentsScreen extends StatefulWidget {
  final String caseId;
  final String caseLabel;

  const EpisodeDocumentsScreen({
    super.key,
    required this.caseId,
    required this.caseLabel,
  });

  @override
  State<EpisodeDocumentsScreen> createState() =>
      _EpisodeDocumentsScreenState();
}

class _EpisodeDocumentsScreenState extends State<EpisodeDocumentsScreen> {
  final EpisodeDocumentRepository _repository =
  EpisodeDocumentRepository();

  final EpisodeDocumentStorageService _storageService =
  EpisodeDocumentStorageService();

  late Future<List<EpisodeDocument>> _futureDocuments;

  @override
  void initState() {
    super.initState();
    _futureDocuments = _loadDocuments();
  }

  Future<List<EpisodeDocument>> _loadDocuments() {
    return _repository.getByCaseId(widget.caseId);
  }

  Future<void> _refresh() async {
    setState(() {
      _futureDocuments = _loadDocuments();
    });
  }

  Future<void> _addDocument() async {
    final result = await FilePicker.platform.pickFiles();

    if (result == null || result.files.isEmpty) {
      return;
    }

    final file = result.files.single;
    final path = file.path;

    if (path == null) {
      return;
    }

    try {
      final copiedPath =
      await _storageService.copyDocumentToEpisodeFolder(
        caseId: widget.caseId,
        sourcePath: path,
      );

      await _repository.create(
        caseId: widget.caseId,
        title: file.name,
        filePath: copiedPath,
        mimeType: file.extension,
        source: 'local_copy',
      );

      await _refresh();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur ajout document : $e'),
        ),
      );
    }
  }

  Future<void> _openDocument(
      EpisodeDocument document,
      ) async {
    final file = File(document.filePath);

    if (!await file.exists()) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fichier introuvable.'),
        ),
      );

      return;
    }

    try {
      if (Platform.isMacOS) {
        await Process.run(
          'open',
          [document.filePath],
        );
      } else if (Platform.isWindows) {
        await Process.run(
          'cmd',
          ['/c', 'start', '', document.filePath],
          runInShell: true,
        );
      } else {
        throw Exception(
          'Ouverture non prise en charge sur cette plateforme.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d’ouvrir le fichier : $e'),
        ),
      );
    }
  }

  Widget _buildDocumentTile(
      EpisodeDocument document,
      ) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.insert_drive_file_outlined,
        ),
        title: Text(document.title),
        subtitle: Text(
          [
            document.mimeType ?? 'Type inconnu',
            document.source ?? 'Source non précisée',
            document.filePath,
          ].join('\n'),
        ),
        trailing: const Icon(
          Icons.open_in_new_outlined,
        ),
        onTap: () => _openDocument(document),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Documents — ${widget.caseLabel}',
        ),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<EpisodeDocument>>(
        future: _futureDocuments,
        builder: (context, snapshot) {
          final documents = snapshot.data ?? [];

          if (snapshot.connectionState !=
              ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur : ${snapshot.error}',
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: OutlinedButton.icon(
                  onPressed: _addDocument,
                  icon: const Icon(Icons.add),
                  label: const Text(
                    'Ajouter un document',
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (documents.isEmpty)
                const Text(
                  'Aucun document associé à cet épisode.',
                )
              else
                ...documents.map(
                  _buildDocumentTile,
                ),
            ],
          );
        },
      ),
    );
  }
}
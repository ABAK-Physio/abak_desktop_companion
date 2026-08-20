import 'dart:io';

import 'package:abak_shared/abak_shared.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../core/utils/date_format_utils.dart';

import '../../../generated/l10n.dart';
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
    final s = S.of(context);
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

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            s.episodeDocuments_documentAdded,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${s.episodeDocuments_addError} : $error',
          ),
        ),
      );
    }
  }

  Future<void> _openDocument(EpisodeDocument document) async {
    final s = S.of(context);

    final file = File(document.filePath);

    if (!await file.exists()) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(s.episodeDocuments_fileNotFound),
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
          [
            '/c',
            'start',
            '',
            document.filePath,
          ],
          runInShell: true,
        );
      } else {
        throw Exception(
          s.episodeDocuments_platformNotSupported,
        );
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Impossible d’ouvrir le fichier : $error',
          ),
        ),
      );
    }
  }

  IconData _documentIcon(EpisodeDocument document) {
    final extension = _documentExtension(document);

    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf_outlined;

      case 'doc':
      case 'docx':
      case 'odt':
      case 'pages':
      case 'rtf':
      case 'txt':
        return Icons.description_outlined;

      case 'xls':
      case 'xlsx':
      case 'ods':
      case 'numbers':
      case 'csv':
        return Icons.table_chart_outlined;

      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'heic':
        return Icons.image_outlined;

      default:
        return Icons.insert_drive_file_outlined;
    }
  }

  String _documentExtension(EpisodeDocument document) {
    final storedExtension = document.mimeType?.trim().toLowerCase();

    if (storedExtension != null && storedExtension.isNotEmpty) {
      return storedExtension.replaceFirst('.', '');
    }

    final fileName = document.title.trim();
    final separatorIndex = fileName.lastIndexOf('.');

    if (separatorIndex < 0 || separatorIndex == fileName.length - 1) {
      return '';
    }

    return fileName.substring(separatorIndex + 1).toLowerCase();
  }

  String _documentTypeLabel(
      EpisodeDocument document,
      S s,
      ) {
    final extension = _documentExtension(document);

    switch (extension) {
      case 'pdf':
        return s.episodeDocuments_pdfDocument;

      case 'doc':
      case 'docx':
      case 'odt':
      case 'pages':
      case 'rtf':
      case 'txt':
        return s.episodeDocuments_textDocument;

      case 'xls':
      case 'xlsx':
      case 'ods':
      case 'numbers':
      case 'csv':
        return s.episodeDocuments_spreadsheet;

      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
      case 'heic':
        return s.episodeDocuments_image;

      default:
        return extension.isEmpty
            ? s.episodeDocuments_document
            : '${s.episodeDocuments_document} ${extension.toUpperCase()}';
    }
  }

  String _createdAtLabel(
      BuildContext context,
      EpisodeDocument document,
      ) {
    return DateFormatUtils.formatTimestamp(
      context,
      document.createdAt,
    );
  }

  Widget _buildDocumentTile(
      EpisodeDocument document,
      S s,
      ) {
    return Card(
      child: ListTile(
        leading: Icon(
          _documentIcon(document),
          size: 32,
        ),
        title: Text(
          document.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${_documentTypeLabel(document, s)}'
              ' · ${s.episodeDocuments_addedOn} '
              '${_createdAtLabel(context, document)}',
        ),
        trailing: IconButton(
          tooltip: s.episodeDocuments_openDocument,
          onPressed: () => _openDocument(document),
          icon: const Icon(Icons.open_in_new_outlined),
        ),
        onTap: () => _openDocument(document),
      ),
    );
  }

  Widget _buildEmptyState(S s) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(
            Icons.folder_open_outlined,
            size: 48,
          ),
          SizedBox(height: 12),
          Text(
            s.episodeDocuments_noDocument,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            s.episodeDocuments_emptyDescription,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          s.episodeDocuments_title,
        ),
        actions: [
          ContextHelpButton(
            title: s.episodeDocuments_title,
            content:
            s.episodeDocuments_help,
          ),
          IconButton(
            tooltip: s.episodeDocuments_refresh,
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<EpisodeDocument>>(
        future: _futureDocuments,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                s.episodeDocuments_loadError,
              ),
            );
          }

          final documents = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                widget.caseLabel,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerLeft,
                child: FilledButton.icon(
                  onPressed: _addDocument,
                  icon: const Icon(Icons.add),
                  label: Text(s.episodeDocuments_addDocument),
                ),
              ),
              const SizedBox(height: 16),
              if (documents.isEmpty)
                _buildEmptyState(s)
              else
                ...documents.map(
                      (document) => _buildDocumentTile(document, s),
                ),
            ],
          );
        },
      ),
    );
  }
}
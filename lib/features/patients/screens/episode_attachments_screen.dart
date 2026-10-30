import '../../../core/settings/macos_directory_access_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';
import '../../../core/utils/date_format_utils.dart';
import '../data/episode_document_repository.dart';
import '../models/episode_document.dart';
import '../services/document_mime.dart';
import '../services/patient_attachment_service.dart';

class EpisodeAttachmentsScreen extends StatefulWidget {
  final String caseId;
  final String caseLabel;
  final EpisodeDocumentRepository? repository;
  final PatientAttachmentService? service;
  final Future<String?> Function()? pickFile;
  final Future<void> Function(String)? openFile;
  const EpisodeAttachmentsScreen({
    super.key,
    required this.caseId,
    required this.caseLabel,
    this.repository,
    this.service,
    this.pickFile,
    this.openFile,
  });
  @override
  State<EpisodeAttachmentsScreen> createState() =>
      _EpisodeAttachmentsScreenState();
}

class _EpisodeAttachmentsScreenState extends State<EpisodeAttachmentsScreen> {
  late final EpisodeDocumentRepository _repository;
  late final PatientAttachmentService _service;
  late Future<List<EpisodeDocument>> _documents;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? EpisodeDocumentRepository();
    _service =
        widget.service ?? PatientAttachmentService(repository: _repository);
    _documents = _load();
  }

  Future<List<EpisodeDocument>> _load() async => (await _repository.getByCaseId(
    widget.caseId,
  )).where((document) => document.source == 'local_copy').toList();
  Future<void> _refresh() async {
    setState(() => _documents = _load());
  }

  Future<String?> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    return result?.files.single.path;
  }

  Future<void> _addDocument() async {
    final s = S.of(context);
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final path = await (widget.pickFile?.call() ?? _pickFile());
      if (path == null || !mounted) return;
      await _service.add(caseId: widget.caseId, sourcePath: path);

      if (!mounted) return;
      await _refresh();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.episodeDocuments_documentAdded)));
    } on AttachmentDestinationRequired {
      _destinationMessage();
    } on DirectoryAuthorizationRequired catch (error) {
      _destinationMessage(root: error.path);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${s.episodeDocuments_addError} : $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
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
    return DocumentMime.extension(document.mimeType, document.filePath);
  }

  String _documentTypeLabel(EpisodeDocument document, S s) {
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

  String _createdAtLabel(BuildContext context, EpisodeDocument document) {
    return DateFormatUtils.formatTimestamp(context, document.createdAt);
  }

  Future<void> _configure({String? root}) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final ready = root == null
          ? await _service.access.configure()
          : await _service.access.authorize(root);
      if (ready && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(S.of(context).episodeAttachments_destinationReady),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(error.toString())));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _destinationMessage({String? root}) {
    if (!mounted) return;
    final s = S.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.episodeAttachments_destinationRequired),
        action: SnackBarAction(
          label: root == null
              ? s.episodeAttachments_configureFolder
              : s.episodeAttachments_authorizeFolder,
          onPressed: () => _configure(root: root),
        ),
      ),
    );
  }

  Future<void> _openDocument(EpisodeDocument document) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      await _service.open(document, openFile: widget.openFile);
    } on DirectoryAuthorizationRequired catch (error) {
      _destinationMessage(root: error.path);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${S.of(context).episodeDocuments_openError} : $error'),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.episodeAttachments_title),
        actions: [
          IconButton(
            key: const Key('attachment-destination'),
            tooltip: s.episodeAttachments_configureFolder,
            onPressed: _busy ? null : () => _configure(),
            icon: const Icon(Icons.folder_outlined),
          ),
          IconButton(
            tooltip: s.episodeDocuments_refresh,
            onPressed: _busy ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
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
              key: const Key('add-ordinary-document'),
              onPressed: _busy ? null : _addDocument,
              icon: const Icon(Icons.add),
              label: Text(s.episodeDocuments_addDocument),
            ),
          ),
          if (_busy) const LinearProgressIndicator(),
          const SizedBox(height: 16),
          FutureBuilder<List<EpisodeDocument>>(
            future: _documents,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Text(s.episodeDocuments_loadError);
              }
              final documents = snapshot.data ?? [];
              if (documents.isEmpty) {
                return Column(
                  children: [
                    Text(s.episodeDocuments_noDocument),
                    Text(s.episodeDocuments_emptyDescription),
                  ],
                );
              }
              return Column(
                children: documents
                    .map(
                      (document) => Card(
                        child: ListTile(
                          leading: Icon(_documentIcon(document)),
                          title: Text(
                            document.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            '${_documentTypeLabel(document, s)} · ${s.episodeDocuments_addedOn} ${_createdAtLabel(context, document)}',
                          ),
                          trailing: IconButton(
                            tooltip: s.episodeDocuments_openDocument,
                            icon: const Icon(Icons.open_in_new),
                            onPressed: () => _openDocument(document),
                          ),
                          onTap: () => _openDocument(document),
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

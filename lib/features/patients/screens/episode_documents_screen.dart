import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/settings/generated_documents_directory_service.dart';
import '../services/patient_documents_service.dart';
import '../services/document_journal_service.dart';
import '../services/document_controls_service.dart';
import 'dart:io';

import 'package:abak_shared/abak_shared.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../../core/expert/expert_context_info.dart';
import '../../../core/expert/expert_info_button.dart';

import '../../../core/utils/date_format_utils.dart';

import '../../../generated/l10n.dart';
import '../data/episode_document_repository.dart';
import '../models/episode_document.dart';
import '../models/episode_document_version.dart';
import '../services/final_pdf_document_service.dart';
import '../services/document_mime.dart';
import '../services/document_medical_service.dart';
import 'document_medical_screen.dart';
import 'document_controls_panel.dart';
import '../services/docx_pdf_service.dart';
import 'document_journal_panel.dart';
import '../services/document_reconciliation_service.dart';
import '../services/episode_document_storage_service.dart';

class EpisodeDocumentsScreen extends StatefulWidget {
  final String caseId;
  final String caseLabel;
  final EpisodeDocumentRepository? repository;
  final EpisodeDocumentStorageService? storage;
  final FinalPdfDocumentService? finalPdfService;
  final DocumentMedicalService? medicalService;
  final DocumentControlsService? controlsService;
  final DocumentReconciliationService? reconciliationService;
  final DocumentArchivePicker? pickArchive;
  final Future<String?> Function(bool pdfOnly)? pickFile;
  final Future<String?> Function()? pickDocx;
  final Future<void> Function(String path)? openFile;
  final bool showExpertInfo;

  const EpisodeDocumentsScreen({
    super.key,
    required this.caseId,
    required this.caseLabel,
    this.repository,
    this.storage,
    this.finalPdfService,
    this.medicalService,
    this.controlsService,
    this.reconciliationService,
    this.pickArchive,
    this.pickFile,
    this.pickDocx,
    this.openFile,
    this.showExpertInfo = true,
  });

  @override
  State<EpisodeDocumentsScreen> createState() => _EpisodeDocumentsScreenState();
}

class _EpisodeDocumentsScreenState extends State<EpisodeDocumentsScreen>
    with WidgetsBindingObserver {
  late final EpisodeDocumentRepository _repository;
  late final EpisodeDocumentStorageService _storageService;
  late final FinalPdfDocumentService _pdf;
  late final DocumentMedicalService _medical;
  final Map<String, MedicalStatus> _medicalStates = {};
  bool _busy = false;
  String? _notice;
  final Map<String, String> _journalStates = {};
  Map<String, List<EpisodeDocumentVersion>> _versions = {};

  late Future<List<EpisodeDocument>> _futureDocuments;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _repository = widget.repository ?? EpisodeDocumentRepository();
    _storageService = widget.storage ?? EpisodeDocumentStorageService();
    _pdf = widget.finalPdfService ?? FinalPdfDocumentService();
    _medical = widget.medicalService ?? DocumentMedicalService(pdf: _pdf);
    _futureDocuments = _loadDocuments();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && !_busy && mounted) _refresh();
  }

  Future<List<EpisodeDocument>> _loadDocuments() async {
    final docs = await _repository.getByCaseId(widget.caseId);
    final versions = <String, List<EpisodeDocumentVersion>>{};
    final journal = DocumentJournalService(
      controls:
          widget.controlsService ?? DocumentControlsService(medical: _medical),
    );
    for (final doc in docs) {
      versions[doc.documentId] = await _pdf.versions(doc.documentId);
      if (versions[doc.documentId]!.isNotEmpty) {
        if (versions[doc.documentId]!.first.sourceKind != 'report') {
          _medicalStates.remove(doc.documentId);
          _journalStates[doc.documentId] =
              'Hors préparation DMP — réservée aux rapports.';
          continue;
        }
        _journalStates[doc.documentId] = (await journal.status(
          versions[doc.documentId]!.first,
        )).message;
        _medicalStates[doc.documentId] = await _medical.status(
          versions[doc.documentId]!.first,
        );
      }
    }
    _versions = versions;
    return docs;
  }

  Future<void> _refresh() async {
    setState(() {
      _futureDocuments = _loadDocuments();
    });
  }

  Future<void> _addDocument() async {
    final s = S.of(context);
    if (_busy) return;
    final path = await _pick(false);
    if (path == null || !mounted) return;
    setState(() => _busy = true);
    try {
      final copiedPath = await _storageService.copyDocumentToEpisodeFolder(
        caseId: widget.caseId,
        sourcePath: path,
      );

      await _repository.create(
        caseId: widget.caseId,
        title: File(path).uri.pathSegments.last,
        filePath: copiedPath,
        mimeType: await DocumentMime.forFile(File(copiedPath)),
        source: 'local_copy',
      );

      await _refresh();

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.episodeDocuments_documentAdded)));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${s.episodeDocuments_addError} : $error')),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openDocument(EpisodeDocument document) async {
    final s = S.of(context);

    var path = document.filePath;
    try {
      final versions = await _pdf.versions(document.documentId);
      if (versions.isNotEmpty) {
        path = (await _pdf.previewFile(versions.first)).path;
      }
    } catch (e) {
      _message(e.toString());
      return;
    }
    final file = File(path);

    if (!await file.exists()) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(s.episodeDocuments_fileNotFound)));

      return;
    }

    try {
      if (widget.openFile != null) {
        await widget.openFile!(path);
        return;
      }
      if (Platform.isMacOS) {
        await Process.run('open', [path]);
      } else if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', path], runInShell: true);
      } else {
        throw Exception(s.episodeDocuments_platformNotSupported);
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Impossible d’ouvrir le fichier : $error')),
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

  Widget _buildDocumentTile(EpisodeDocument document, S s) {
    return Card(
      child: ListTile(
        leading: Icon(_documentIcon(document), size: 32),
        title: Text(
          document.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '${_documentTypeLabel(document, s)}'
          ' · ${s.episodeDocuments_addedOn} '
          '${_createdAtLabel(context, document)}'
          '${(_versions[document.documentId] ?? []).isEmpty ? '' : '\nPDF final · version ${_versions[document.documentId]!.first.number} · ${_versions[document.documentId]!.first.pages} page(s) · ${_medicalStates[document.documentId]?.valid == true ? 'validé médicalement' : 'non validé médicalement'}\n${_journalStates[document.documentId] ?? ''}'}',
        ),
        trailing: PopupMenuButton<String>(
          key: Key('document-actions-${document.documentId}'),
          enabled: !_busy,
          onSelected: (action) {
            if (action == 'open') _openDocument(document);
            if (action == 'new') _importFinal(document: document);
            if (action == 'new-docx') {
              _importFinal(document: document, fromDocx: true);
            }
            if (action == 'convert-docx') {
              _importFinal(document: document, existing: true, fromDocx: true);
            }
            if (action == 'freeze') {
              _importFinal(document: document, existing: true);
            }
            if (action == 'history') _history(document);
            if (action == 'medical') _medicalPreparation(document);
          },
          itemBuilder: (_) => [
            PopupMenuItem(
              value: 'open',
              child: Text(s.episodeDocuments_openDocument),
            ),
            if ((_versions[document.documentId] ?? []).isNotEmpty) ...[
              PopupMenuItem(
                value: 'medical',
                enabled:
                    _versions[document.documentId]!.first.sourceKind ==
                    'report',
                child: Text(
                  _versions[document.documentId]!.first.sourceKind == 'report'
                      ? 'Contexte et validation médicale'
                      : 'Préparation DMP réservée aux rapports',
                ),
              ),
              const PopupMenuItem(
                value: 'new',
                child: Text('Importer une nouvelle version PDF'),
              ),
              const PopupMenuItem(
                value: 'new-docx',
                child: Text('Créer une nouvelle version depuis un DOCX'),
              ),
              const PopupMenuItem(
                value: 'history',
                child: Text('Voir les versions figées'),
              ),
            ] else if (_documentExtension(document) == 'docx')
              const PopupMenuItem(
                value: 'convert-docx',
                child: Text('Créer le PDF/A depuis ce DOCX'),
              )
            else if (_documentExtension(document) == 'pdf')
              const PopupMenuItem(
                value: 'freeze',
                child: Text('Conserver ce PDF comme version finale'),
              ),
          ],
        ),
        onTap: () => _openDocument(document),
      ),
    );
  }

  Future<void> _medicalPreparation(EpisodeDocument document) async {
    final versions = await _pdf.versions(document.documentId);
    if (!mounted || versions.isEmpty) return;
    if (versions.first.sourceKind != 'report') {
      _message(DocumentMedicalService.reportOnlyMessage);
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DocumentMedicalScreen(
          version: versions.first,
          service: _medical,
          controls: widget.controlsService,
          reconciliation: widget.reconciliationService,
          pickArchive: widget.pickArchive,
        ),
      ),
    );
    if (mounted) await _refresh();
  }

  Widget _buildEmptyState(S s) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Icon(Icons.folder_open_outlined, size: 48),
          SizedBox(height: 12),
          Text(s.episodeDocuments_noDocument, textAlign: TextAlign.center),
          SizedBox(height: 8),
          Text(
            s.episodeDocuments_emptyDescription,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _message(String message) {
    if (mounted) setState(() => _notice = message);
  }

  Future<String?> _pick(bool pdfOnly) async {
    if (widget.pickFile != null) return widget.pickFile!(pdfOnly);
    return _pickInPatientFolder(pdfOnly ? 'pdf' : null);
  }

  Future<String?> _pickInPatientFolder(String? extension) async {
    GeneratedDocumentsDirectoryAccess? access;
    final key = 'episode_import_directory.${widget.caseId}';
    try {
      String? initialDirectory;
      SharedPreferences? preferences;
      // Keep the macOS authorization alive while the native panel is open.
      try {
        access = await const GeneratedDocumentsDirectoryService()
            .acquireConfigured();
      } catch (_) {
        // Folder suggestions must not prevent manual selection.
      }
      try {
        preferences = await SharedPreferences.getInstance();
        final last = preferences.getString(key);
        if (last != null && await Directory(last).exists()) {
          initialDirectory = last;
        }
      } catch (_) {}
      if (initialDirectory == null && access != null) {
        try {
          final folders = await const PatientDocumentsService().findForEpisode(
            episodeId: widget.caseId,
            rootPath: access.path,
            database: await _pdf.database(),
          );
          if (folders != null) {
            for (final folder in [folders.report, folders.path]) {
              if (await Directory(folder).exists()) {
                initialDirectory = folder;
                break;
              }
            }
          }
          initialDirectory ??= access.path;
        } catch (_) {}
      }
      if (initialDirectory == null) {
        try {
          final downloads = await getDownloadsDirectory();
          if (downloads != null && await downloads.exists()) {
            initialDirectory = downloads.path;
          }
        } catch (_) {}
      }
      if (!mounted) return null;
      final result = await FilePicker.platform.pickFiles(
        type: extension == null ? FileType.any : FileType.custom,
        allowedExtensions: extension == null ? null : [extension],
        initialDirectory: initialDirectory,
        dialogTitle: extension == 'pdf'
            ? 'Choisir le PDF modifié du patient'
            : extension == 'docx'
            ? 'Choisir le document Word du patient'
            : 'Choisir un document du patient',
      );
      final selected = result?.files.single.path;
      if (selected != null) {
        try {
          await preferences?.setString(key, p.dirname(selected));
        } catch (_) {}
      }
      return selected;
    } finally {
      await access?.release();
    }
  }

  Future<void> _importFinal({
    EpisodeDocument? document,
    bool existing = false,
    bool fromDocx = false,
  }) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _notice = null;
    });
    try {
      final path = existing
          ? document!.filePath
          : fromDocx
          ? (widget.pickDocx != null
                ? await widget.pickDocx!()
                : await _pickInPatientFolder('docx'))
          : await _pick(true);
      if (path == null || !mounted) return;
      final origins = await _pdf.origins(widget.caseId);
      var selected = origins.first;
      var chosenTitle = document?.title ?? File(path).uri.pathSegments.last;
      if (document == null && fromDocx) {
        chosenTitle = chosenTitle.replaceFirst(
          RegExp(r'\.docx$', caseSensitive: false),
          '.pdf',
        );
      }
      if (!mounted) return;
      final accepted = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => StatefulBuilder(
          builder: (context, update) => AlertDialog(
            title: Text(
              fromDocx
                  ? 'Créer le PDF/A depuis le DOCX'
                  : 'Conserver le PDF final',
            ),
            content: SizedBox(
              width: 480,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(widget.caseLabel),
                  TextFormField(
                    initialValue: chosenTitle,
                    onChanged: (value) => chosenTitle = value,
                    readOnly: document != null,
                    decoration: const InputDecoration(
                      labelText: 'Titre de la pièce',
                    ),
                  ),
                  if (!existing)
                    DropdownButton<PdfOrigin>(
                      isExpanded: true,
                      value: selected,
                      items: origins
                          .map(
                            (o) => DropdownMenuItem(
                              value: o,
                              child: Text(
                                fromDocx && o.kind == 'external'
                                    ? 'DOCX externe'
                                    : o.label ?? o.kind,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (o) {
                        if (o != null) update(() => selected = o);
                      },
                    ),
                  Text(
                    fromDocx
                        ? 'Le DOCX reste intact. LibreOffice crée une copie PDF/A hors réseau, vérifiée par veraPDF. Examinez ensuite toutes les pages et validez leur contenu médical. Chaque modification exige une nouvelle version. Cette conversion ne signe ni n’envoie le document.'
                        : 'Le PDF est conservé sans conversion. Cet import ne valide pas son contenu clinique et ne lance aucun envoi. L’ouverture utilisera une copie de consultation ; pour conserver des corrections, importez une nouvelle version.',
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Annuler'),
              ),
              FilledButton(
                key: const Key('confirm-final-import'),
                onPressed: () => Navigator.pop(dialogContext, true),
                child: Text(
                  fromDocx
                      ? 'Convertir et vérifier le PDF/A'
                      : 'Conserver cette version',
                ),
              ),
            ],
          ),
        ),
      );
      if (accepted != true || !mounted) return;
      final origin = existing
          ? PdfOrigin('legacy_piece', id: document!.documentId)
          : selected;
      final controls =
          widget.controlsService ?? DocumentControlsService(medical: _medical);
      if (fromDocx && await controls.configuration() == null) {
        if (!mounted || !await configureDocumentControls(context, controls)) {
          return;
        }
      }
      final version = fromDocx
          ? await DocxPdfService(controls: controls).convert(
              sourcePath: path,
              episodeId: widget.caseId,
              title: chosenTitle,
              documentId: document?.documentId,
              origin: origin,
            )
          : await _pdf.importPdf(
              episodeId: widget.caseId,
              sourcePath: path,
              title: chosenTitle,
              documentId: document?.documentId,
              origin: origin,
            );
      if (!mounted) return;
      await _refresh();
      _message(
        '${fromDocx ? 'PDF/A-1b conforme. ' : ''}Version ${version.number} conservée · ${version.pages} page(s). Examinez les pages dans « Contexte et validation médicale ». Validation médicale non effectuée.',
      );
    } catch (e) {
      _message('${fromDocx ? 'Conversion DOCX' : 'Import PDF'} refusé : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _history(EpisodeDocument document) async {
    try {
      final versions = await _pdf.versions(document.documentId);
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Versions — ${document.title}'),
          content: SizedBox(
            width: 520,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (final version in versions)
                  ListTile(
                    title: Text(
                      'Version ${version.number} · ${version.pages} page(s)',
                    ),
                    subtitle: Text(
                      'Origine : ${version.sourceKind == 'external'
                          ? 'PDF externe'
                          : version.sourceKind == 'report'
                          ? 'rapport'
                          : version.sourceKind == 'assessment'
                          ? 'bilan'
                          : 'pièce existante'} · ${version.size} octets',
                    ),
                    trailing: const Icon(Icons.open_in_new),
                    onTap: () async {
                      try {
                        final file = await _pdf.previewFile(version);
                        if (widget.openFile != null) {
                          await widget.openFile!(file.path);
                        } else if (Platform.isMacOS) {
                          await Process.run('open', [file.path]);
                        } else {
                          throw const FinalPdfException(
                            'Ouverture de version non prise en charge sur cette plateforme.',
                          );
                        }
                      } catch (e) {
                        if (ctx.mounted) Navigator.pop(ctx);
                        _message(e.toString());
                      }
                    },
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (e) {
      _message(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.episodeDocuments_title),
        actions: [
          if (widget.showExpertInfo)
            ExpertModeInfoButton(
              info: ExpertContextInfo(
                contextName: s.episodeDocuments_title,
                sourceFile:
                    'lib/features/patients/screens/episode_documents_screen.dart',
                arbPrefix: 'episodeDocuments',
              ),
            ),
          ContextHelpButton(
            technicalInformationLabel: S.of(context).g_helpTooltip,
            title: s.episodeDocuments_title,
            content: s.episodeDocuments_help,
          ),
          IconButton(
            tooltip: s.episodeDocuments_refresh,
            onPressed: _busy ? null : _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<List<EpisodeDocument>>(
        future: _futureDocuments,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(s.episodeDocuments_loadError));
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
                  key: const Key('add-ordinary-document'),
                  onPressed: _busy ? null : _addDocument,
                  icon: const Icon(Icons.add),
                  label: Text(s.episodeDocuments_addDocument),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const Key('convert-docx-pdfa'),
                onPressed: _busy ? null : () => _importFinal(fromDocx: true),
                icon: const Icon(Icons.description_outlined),
                label: const Text('Créer un PDF/A depuis un DOCX'),
              ),
              const SizedBox(height: 8),
              FilledButton.icon(
                key: const Key('import-final-pdf'),
                onPressed: _busy ? null : () => _importFinal(),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: const Text('Importer le PDF final'),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  'Copie figée pour cet épisode. La validation médicale et les contrôles DMP seront distincts de cet import.',
                ),
              ),
              if (_busy)
                const LinearProgressIndicator(key: Key('pdf-import-busy')),
              if (_notice != null)
                Text(_notice!, key: const Key('pdf-import-notice')),
              if (documents.isEmpty)
                _buildEmptyState(s)
              else
                ...documents.map((document) => _buildDocumentTile(document, s)),
            ],
          );
        },
      ),
    );
  }
}

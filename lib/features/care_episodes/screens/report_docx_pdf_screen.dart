import 'dart:async';

import 'report_pdf_export_guide.dart';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../../../core/settings/generated_documents_directory_service.dart';
import '../../../core/settings/macos_directory_access_service.dart';
import '../../documents/services/initial_report_document_service.dart';
import '../../patients/models/episode_document_version.dart';
import '../../patients/screens/document_controls_panel.dart';
import '../../patients/screens/document_medical_screen.dart';
import '../../patients/services/document_controls_service.dart';
import '../../patients/services/document_medical_service.dart';
import '../../patients/services/docx_pdf_service.dart';
import '../../patients/services/final_pdf_document_service.dart';
import '../../patients/services/patient_documents_service.dart';
import '../../patients/services/pdfa_preflight_service.dart';

/// Reads the existing Word file. No DOCX generator or export service is used.
class ReportDocxPdfScreen extends StatefulWidget {
  const ReportDocxPdfScreen({
    super.key,
    required this.episodeId,
    required this.patientId,
    required this.patientName,
    required this.reportId,
    required this.reportTitle,
    this.pdfService,
    this.controlsService,
    this.preflightService,
    this.pickPdf,
  });

  final FinalPdfDocumentService? pdfService;
  final DocumentControlsService? controlsService;
  final PdfaPreflightService? preflightService;
  final Future<String?> Function()? pickPdf;
  final String episodeId, patientId, patientName;
  final String reportId, reportTitle;
  PdfOrigin get origin => PdfOrigin('report', id: reportId, label: reportTitle);

  @override
  State<ReportDocxPdfScreen> createState() => _ReportDocxPdfScreenState();
}

class _ReportDocxPdfScreenState extends State<ReportDocxPdfScreen> {
  late final _pdf = widget.pdfService ?? FinalPdfDocumentService();
  late final _medical =
      widget.controlsService?.medical ?? DocumentMedicalService(pdf: _pdf);
  late final _controls =
      widget.controlsService ?? DocumentControlsService(medical: _medical);
  GeneratedDocumentsDirectoryAccess? _access;
  Map<String, Object?>? _source;
  String? _path;
  EpisodeDocumentVersion? _version;
  bool _busy = false, _needsDirectory = false;
  bool _configuring = false;
  String _message = '';
  int? _step = 2;
  bool _docxOpened = false;
  String? _pdfVerdict;

  String get _kind => 'Rapport';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    unawaited(_access?.release());
    super.dispose();
  }

  Future<Map<String, Object?>> _readSource() async {
    if (widget.reportId.isEmpty) {
      throw const FinalPdfException('Origine clinique absente.');
    }
    final db = await _pdf.database();
    final episodes = await db.query(
      'care_episodes',
      where: 'care_episode_id = ? AND patient_id = ? AND archived_at IS NULL',
      whereArgs: [widget.episodeId, widget.patientId],
    );
    if (episodes.length != 1) {
      throw const FinalPdfException('Prise en charge absente ou modifiée.');
    }
    final rows = await db.query(
      'care_episode_reports',
      where:
          'report_id = ? '
          'AND care_episode_id = ? AND status = ? AND archived_at IS NULL',
      whereArgs: [widget.origin.id, widget.episodeId, 'saved'],
    );
    if (rows.length != 1) {
      throw const FinalPdfException(
        'Rapport absent, archivé ou non enregistré.',
      );
    }
    return rows.single;
  }

  Future<void> _load({bool authorizeDirectory = false}) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _message = '';
      _source = null;
      _path = null;
      _version = null;
      _pdfVerdict = null;
      _needsDirectory = false;
    });
    GeneratedDocumentsDirectoryAccess? access;
    try {
      await _access?.release();
      _access = null;
      final source = await _readSource();
      final version = await _pdf.latestForOrigin(
        widget.episodeId,
        widget.origin,
      );
      if (!mounted) return;
      setState(() {
        _source = source;
        _version = version;
        _step = version == null ? 2 : 3;
      });
      final name = source['docx_file_name'] as String?;
      if (name == null || name.isEmpty) {
        throw const FinalPdfException(
          'Aucun DOCX associé. Vous pouvez choisir un PDF exporté depuis votre logiciel.',
        );
      }
      if (p.basename(name) != name ||
          name.contains('\\') ||
          p.extension(name).toLowerCase() != '.docx') {
        throw const FinalPdfException('Nom du DOCX associé invalide.');
      }
      const directory = GeneratedDocumentsDirectoryService();
      if (authorizeDirectory && await directory.chooseAndSave() == null) return;
      access = await directory.acquireConfigured();
      if (access == null) {
        _needsDirectory = true;
        throw const FinalPdfException(
          'Sélectionnez le dossier racine contenant les documents déjà générés pour les patients.',
        );
      }
      // Find only: never create a patient folder or regenerate a missing DOCX.
      final folders = await const PatientDocumentsService().findInRoot(
        patientId: widget.patientId,
        rootPath: access.path,
      );
      if (folders == null) {
        _needsDirectory = true;
        throw const FinalPdfException(
          'Le dossier de ce patient n’est pas associé à cette destination. Sélectionnez le dossier racine utilisé pour ses DOCX.',
        );
      }
      final path = p.join(folders.report, name);
      if (!await File(path).exists()) {
        throw FinalPdfException(
          'DOCX associé introuvable : $path. Aucun fichier n’a été régénéré.',
        );
      }
      if (!mounted) return;
      _access = access;
      access = null;
      setState(() => _path = path);
    } on DirectoryAuthorizationRequired catch (e) {
      if (mounted) {
        setState(() {
          _needsDirectory = true;
          _message = e.toString();
        });
      }
    } catch (e) {
      if (mounted) setState(() => _message = e.toString());
    } finally {
      await access?.release();
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<String?> _pickPatientPdf() async {
    GeneratedDocumentsDirectoryAccess? temporaryAccess;
    try {
      String? initialDirectory;
      try {
        final docx = _path;
        if (docx != null && await Directory(p.dirname(docx)).exists()) {
          initialDirectory = p.dirname(docx);
        } else {
          final access =
              _access ??
              (temporaryAccess =
                  await const GeneratedDocumentsDirectoryService()
                      .acquireConfigured());
          if (access != null) {
            final folders = await const PatientDocumentsService().findInRoot(
              patientId: widget.patientId,
              rootPath: access.path,
            );
            if (folders != null) {
              for (final candidate in [folders.report, folders.path]) {
                if (await Directory(candidate).exists()) {
                  initialDirectory = candidate;
                  break;
                }
              }
            }
          }
        }
      } catch (_) {
        // An unavailable suggested folder must not prevent manual selection.
      }
      if (!mounted) return null;
      return (await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        initialDirectory: initialDirectory,
      ))?.files.single.path;
    } finally {
      await temporaryAccess?.release();
    }
  }

  Future<void> _importPdf() async {
    final source = _source;
    if (_busy || source == null) return;
    setState(() {
      _busy = true;
      _message = '';
    });
    try {
      final path = widget.pickPdf != null
          ? await widget.pickPdf!()
          : await _pickPatientPdf();
      if (path == null || !mounted) return;
      if (jsonEncode(await _readSource()) != jsonEncode(source)) {
        throw const FinalPdfException(
          'Le rapport a changé. Cliquez sur Actualiser avant import.',
        );
      }
      final version = await _pdf.importPdf(
        episodeId: widget.episodeId,
        sourcePath: path,
        title: '$_kind — ${source['title']}',
        origin: widget.origin,
        reuseOriginDocument: true,
        expectedSourceRevision: FinalPdfDocumentService.hash(
          utf8.encode(jsonEncode(source)),
        ),
      );
      if (!mounted) return;
      setState(() {
        _version = version;
        _pdfVerdict = null;
        _step = 3;
        _message = 'PDF conservé. Vérification du format en cours…';
      });
      await _checkPdf(version);
    } catch (e) {
      if (mounted) {
        setState(() => _message = 'Import ou contrôle interrompu : $e');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _checkPdf(EpisodeDocumentVersion version) async {
    final verdict =
        await (widget.preflightService ?? PdfaPreflightService(_controls))
            .check(version);
    if (mounted) {
      setState(() {
        _pdfVerdict = verdict;
        _message = switch (verdict) {
          'conforme' => 'Format PDF/A conforme pour cette version.',
          'refuse' => 'Une conversion au format PDF/A est nécessaire.',
          _ => 'Le format n’a pas pu être vérifié. Consultez l’étape 4.',
        };
      });
    }
  }

  Future<void> _recheckPdf() async {
    final version = _version;
    if (_busy || version == null) return;
    setState(() {
      _busy = true;
      _message = 'Vérification PDF/A en cours…';
    });
    try {
      await _checkPdf(version);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openDocx() async {
    final path = _path;
    if (_busy || path == null) return;
    setState(() {
      _busy = true;
      _message = 'Ouverture du document dans votre traitement de texte…';
    });
    try {
      await const InitialReportDocumentService().open(path);
      if (mounted) {
        setState(() {
          _docxOpened = true;
          _message = 'Demande d’ouverture transmise à votre traitement de texte.';
          _step = 0;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _message = 'Ouverture impossible : $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _convert() async {
    final source = _source;
    final path = _path;
    if (_busy || source == null || path == null) return;
    setState(() {
      _busy = true;
      _message = 'Préparation de la conversion…';
    });
    try {
      if (await _controls.configuration() == null) {
        if (!mounted) return;
        setState(() {
          _configuring = true;
          _message =
              'Configurez les outils locaux. La conversion n’a pas commencé.';
        });
        if (!mounted || !await configureDocumentControls(context, _controls)) {
          if (mounted) setState(() => _message = 'Conversion non lancée.');
          return;
        }
        if (!mounted) return;
        setState(() => _configuring = false);
      }
      final current = await _readSource();
      if (jsonEncode(current) != jsonEncode(source)) {
        throw const FinalPdfException(
          'Le rapport a changé. Cliquez sur Actualiser avant conversion.',
        );
      }
      final version = await DocxPdfService(controls: _controls).convert(
        sourcePath: path,
        episodeId: widget.episodeId,
        title: '$_kind — ${source['title']}',
        origin: widget.origin,
        reuseOriginDocument: true,
        expectedSourceRevision: FinalPdfDocumentService.hash(
          utf8.encode(jsonEncode(source)),
        ),
        onProgress: (message) {
          if (mounted) setState(() => _message = message);
        },
      );
      if (!mounted) return;
      setState(() {
        _version = version;
        _pdfVerdict = 'conforme';
        _step = 3;
        _message =
            'PDF créé et format PDF/A conforme. Version ${version.number} conservée.';
      });
    } catch (e) {
      if (mounted) setState(() => _message = 'Conversion refusée : $e');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _configuring = false;
        });
      }
    }
  }

  Future<void> _configure() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _configuring = true;
      _message = 'Configuration des outils locaux…';
    });
    try {
      final saved = await configureDocumentControls(context, _controls);
      if (mounted) {
        setState(
          () => _message = saved
              ? 'Configuration enregistrée. Vous pouvez créer le PDF conforme.'
              : 'Configuration annulée. Aucune conversion lancée.',
        );
      }
    } catch (e) {
      if (mounted) setState(() => _message = e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _configuring = false;
        });
      }
    }
  }

  Future<void> _preview() async {
    final version = _version;
    if (_busy || version == null) return;
    setState(() => _busy = true);
    try {
      final file = await _pdf.previewFile(version);
      await const InitialReportDocumentService().open(file.path);
    } catch (e) {
      if (mounted) {
        setState(() => _message = 'Ouverture du PDF impossible : $e');
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(_message)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _exportHelp() => showDialog<void>(
    context: context,
    builder: (_) => const ReportPdfExportGuide(),
  );

  ExpansionPanel _panel(
    int index,
    String title,
    String status,
    List<Widget> children, {
    bool done = false,
  }) => ExpansionPanel(
    isExpanded: _step == index,
    canTapOnHeader: true,
    headerBuilder: (context, expanded) => ListTile(
      leading: CircleAvatar(
        child: done ? const Icon(Icons.check) : Text('${index + 1}'),
      ),
      title: Text(title),
      subtitle: Text(status),
    ),
    body: Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    ),
  );

  Widget _help(String text) => ExpansionTile(
    tilePadding: EdgeInsets.zero,
    title: const Text('En savoir plus'),
    leading: const Icon(Icons.info_outline),
    children: [
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Align(alignment: Alignment.centerLeft, child: Text(text)),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Préparer le PDF du rapport'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _busy ? null : _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 960),
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(
                widget.patientName,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '$_kind : ${_source?['title'] ?? widget.origin.label ?? ''}',
              ),
              const SizedBox(height: 16),
              const Text('Préparer le PDF → Vérifier et valider le rapport'),
              const SizedBox(height: 8),
              const Text('Vous avez déjà un PDF ? Commencez à l’étape 3.'),
              const SizedBox(height: 16),
              if (_busy && !_configuring) const LinearProgressIndicator(),
              if (_message.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Semantics(liveRegion: true, child: Text(_message)),
                ),
              ExpansionPanelList(
                expandedHeaderPadding: EdgeInsets.zero,
                expansionCallback: (index, expanded) =>
                    setState(() => _step = expanded ? index : null),
                children: [
                  _panel(
                    0,
                    'Relire ou modifier le rapport',
                    _docxOpened
                        ? 'Ouverture demandée · relecture à votre charge'
                        : 'Facultatif',
                    [
                      const Text(
                        'Ouvrez le document si vous souhaitez modifier son contenu.',
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton.icon(
                          onPressed: _busy || _path == null ? null : _openDocx,
                          icon: const Icon(Icons.edit_document),
                          label: const Text('Ouvrir le document'),
                        ),
                      ),
                      if (_path == null && !_busy)
                        const Text(
                          'Le document Word n’est pas accessible. Vous pouvez choisir un PDF à l’étape 3.',
                        ),
                      if (_needsDirectory)
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => _load(authorizeDirectory: true),
                          child: const Text(
                            'Retrouver le dossier des documents',
                          ),
                        ),
                      _help(
                        'Enregistrez vos modifications dans votre traitement de texte avant de préparer le PDF. '
                        'L’ouverture du document ne confirme pas sa relecture.',
                      ),
                    ],
                  ),
                  _panel(
                    1,
                    'Obtenir le PDF',
                    'À faire dans votre traitement de texte, si nécessaire',
                    [
                      const Text(
                        'Dans Word, Pages ou votre logiciel habituel, exportez le rapport au format PDF, puis revenez ici.',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          TextButton.icon(
                            key: const Key('report-pdf-export-guide'),
                            onPressed: _exportHelp,
                            icon: const Icon(Icons.help_outline),
                            label: const Text('Comment exporter mon rapport ?'),
                          ),
                          OutlinedButton(
                            onPressed: _busy
                                ? null
                                : () => setState(() => _step = 2),
                            child: const Text('Mon PDF est prêt'),
                          ),
                        ],
                      ),
                      _help(
                        'Choisissez le format PDF/A-1b si votre logiciel le propose. '
                        'Pages ne propose pas d’option PDF/A-1b documentée : son PDF peut nécessiter une conversion. '
                        'L’étape 4 vérifiera le format. Companion ne peut pas constater l’export dans votre logiciel.',
                      ),
                      ExpansionTile(
                        tilePadding: EdgeInsets.zero,
                        title: const Text(
                          'Autre possibilité : créer le PDF avec LibreOffice',
                        ),
                        children: [
                          const Text(
                            'Cette option utilise le DOCX enregistré. Les modifications faites uniquement dans un PDF ne seront pas reprises.',
                          ),
                          OutlinedButton.icon(
                            onPressed: _busy || _path == null ? null : _convert,
                            icon: const Icon(Icons.picture_as_pdf_outlined),
                            label: const Text('Créer le PDF avec LibreOffice'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  _panel(
                    2,
                    'Choisir le PDF à utiliser',
                    _version == null
                        ? 'À faire'
                        : 'PDF conservé · version ${_version!.number} · ${_version!.pages} page(s)',
                    [
                      const Text(
                        'Sélectionnez le PDF de ce rapport dans le dossier du patient.',
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          FilledButton.icon(
                            key: const Key('report-import-pdf'),
                            onPressed: _busy || _source == null
                                ? null
                                : _importPdf,
                            icon: const Icon(Icons.upload_file),
                            label: Text(
                              _version == null
                                  ? 'Choisir le PDF'
                                  : 'Choisir une nouvelle version',
                            ),
                          ),
                          if (_version != null)
                            OutlinedButton(
                              onPressed: _busy ? null : _preview,
                              child: const Text('Consulter le PDF'),
                            ),
                        ],
                      ),
                      _help(
                        'Une copie du PDF est conservée et son format est vérifié automatiquement. '
                        'La sélection ne convertit pas le fichier et ne valide pas son contenu. '
                        'Un nouveau PDF conserve les versions précédentes et demande une nouvelle validation médicale.',
                      ),
                    ],
                    done: _version != null,
                  ),
                  _panel(
                    3,
                    'Vérifier le format du PDF',
                    switch (_pdfVerdict) {
                      'conforme' => 'Format conforme',
                      'refuse' => 'Conversion nécessaire',
                      'non_verifie' => 'Vérification non aboutie',
                      _ =>
                        _version == null ? 'En attente du PDF' : 'À vérifier',
                    },
                    [
                      Text(switch (_pdfVerdict) {
                        'conforme' =>
                          'Le PDF respecte le format d’archivage PDF/A-1b. Vous pouvez poursuivre vers la validation du rapport.',
                        'refuse' =>
                          'Exportez une version PDF/A-1b ou convertissez le PDF avec un outil adapté, puis choisissez le résultat à l’étape 3.',
                        'non_verifie' =>
                          'Vérifiez la configuration des outils dans « Détails et assistance », puis relancez la vérification.',
                        _ =>
                          'Le format est contrôlé automatiquement lorsque vous choisissez un PDF. Vous pouvez aussi relancer cette vérification.',
                      }),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: OutlinedButton(
                          onPressed: _busy || _version == null
                              ? null
                              : _recheckPdf,
                          child: const Text('Vérifier le format du PDF'),
                        ),
                      ),
                      if (_pdfVerdict == 'refuse')
                        TextButton(
                          onPressed: _exportHelp,
                          child: const Text('Voir les solutions de conversion'),
                        ),
                      _help(
                        'Ce contrôle concerne le format du fichier, pas son contenu médical. '
                        'Les contrôles PDF/A et CDA requis pour le DMP restent distincts. '
                        'À la réouverture de cet écran, aucun contrôle n’est relancé automatiquement.',
                      ),
                    ],
                    done: _pdfVerdict == 'conforme',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _busy || _version == null
                    ? null
                    : () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DocumentMedicalScreen(
                            version: _version!,
                            service: _medical,
                            controls: _controls,
                          ),
                        ),
                      ),
                icon: const Icon(Icons.arrow_forward),
                label: const Text('Continuer vers la validation du rapport'),
              ),
              const SizedBox(height: 8),
              const Text(
                'La validation médicale se fait à l’écran suivant. Aucun envoi n’est déclenché ici.',
              ),
              if (_version != null && _pdfVerdict != 'conforme')
                const Text(
                  'Vous pouvez préparer le contexte du rapport ; la conformité du format reste à établir avant le DMP.',
                ),
              const SizedBox(height: 16),
              ExpansionTile(
                title: const Text('Détails et assistance'),
                leading: const Icon(Icons.settings_outlined),
                children: [
                  if (_path != null) SelectableText('Document Word : $_path'),
                  if (_version != null)
                    Text(
                      'PDF conservé — version ${_version!.number} · ${_version!.pages} page(s)',
                    ),
                  OutlinedButton(
                    onPressed: _busy ? null : _configure,
                    child: const Text(
                      'Configurer les outils de contrôle locaux',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

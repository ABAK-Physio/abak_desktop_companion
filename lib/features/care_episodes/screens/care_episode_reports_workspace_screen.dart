import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:abak_shared/abak_shared.dart';
import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../external_correspondents/widgets/external_correspondent_selector.dart';
import '../../results/data/desktop_result_repository.dart';
import '../../results/models/desktop_result.dart';
import '../data/care_episode_assessment_repository.dart';
import '../data/care_episode_repository.dart';
import '../data/care_episode_report_repository.dart';
import '../models/assessment_templates/assessment_template.dart';
import '../models/assessment_templates/default_assessment_templates.dart';
import '../models/care_episode.dart';
import '../models/care_episode_assessment.dart';
import '../models/care_episode_note.dart';
import '../models/care_episode_report.dart';
import '../models/clinical_document_type.dart';
import '../../practitioners/data/practitioner_repository.dart';
import '../../practitioners/models/practitioner.dart';
import '../../practitioners/widgets/practitioner_selector.dart';
import '../data/care_episode_referring_practitioner_repository.dart';
import '../widgets/referring_practitioner_history_dialog.dart';
import '../../patients/screens/episode_documents_screen.dart';

import '../data/care_episode_document_edit_draft_repository.dart';
import 'care_episode_reports_workspace/widgets/assessment_template_guide.dart';
import 'care_episode_reports_workspace/widgets/episode_header.dart';
import 'care_episode_reports_workspace/widgets/episode_summary_card.dart';
import 'care_episode_reports_workspace/widgets/archived_documents_card.dart';
import 'care_episode_reports_workspace/widgets/follow_up_notes_card.dart';
import 'care_episode_reports_workspace/widgets/latest_tests_card.dart';
import 'care_episode_reports_workspace/widgets/assessment_history_card.dart';
import 'care_episode_reports_workspace/widgets/report_history_card.dart';
import 'care_episode_reports_workspace/widgets/soap_draft_card.dart';
import 'care_episode_reports_workspace/widgets/document_title_dialog.dart';
import 'package:abak_desktop_companion/features/patients/data/patient_attribute_repository.dart';
import 'package:abak_desktop_companion/features/care_episodes/data/assessment_template_draft_repository.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/assessment_templates/assessment_template_answers.dart';
import 'care_episode_reports_workspace/widgets/assessment_template_selector.dart';
import '../data/assessment_document_data_builder.dart';
import '../data/report_document_data_builder.dart';
import '../services/report_docx_service.dart';
import '../services/assessment_docx_service.dart';
import '../../episodes/report/services/episode_report_docx_export_service.dart';
import '../services/assessment_chart_image_service.dart';
import '../../../core/settings/application_settings_service.dart';
import '../../external_correspondents/data/external_correspondent_repository.dart';
import '../../external_correspondents/models/external_correspondent.dart';

class CareEpisodeReportsWorkspaceScreen extends StatefulWidget {
  final CareEpisode episode;
  final String patientName;
  final DesktopResultRepository resultRepository;

  const CareEpisodeReportsWorkspaceScreen({
    super.key,
    required this.episode,
    required this.patientName,
    required this.resultRepository,
  });

  @override
  State<CareEpisodeReportsWorkspaceScreen> createState() =>
      _CareEpisodeReportsWorkspaceScreenState();
}

class _CareEpisodeReportsWorkspaceScreenState
    extends State<CareEpisodeReportsWorkspaceScreen> {
  final CareEpisodeRepository _careEpisodeRepository = CareEpisodeRepository();
  final CareEpisodeAssessmentRepository _assessmentRepository =
      CareEpisodeAssessmentRepository();
  final CareEpisodeReportRepository _reportRepository =
      CareEpisodeReportRepository();

  final CareEpisodeDocumentEditDraftRepository _documentEditDraftRepository =
      CareEpisodeDocumentEditDraftRepository();

  final TextEditingController _draftController = TextEditingController();
  final FocusNode _draftFocusNode = FocusNode();

  final CareEpisodeReferringPractitionerRepository
  _referringPractitionerRepository =
      CareEpisodeReferringPractitionerRepository();

  final PractitionerRepository _practitionerRepository =
      PractitionerRepository();

  final ExternalCorrespondentRepository _externalCorrespondentRepository =
  ExternalCorrespondentRepository();

  final PatientAttributeRepository _patientAttributeRepository =
      PatientAttributeRepository();

  final AssessmentTemplateDraftRepository _assessmentTemplateDraftRepository =
      AssessmentTemplateDraftRepository();

  late Future<Practitioner?> _currentReferringPractitionerFuture;

  late Future<ExternalCorrespondent?> _prescribingCorrespondentFuture;

  Timer? _draftSaveTimer;
  Timer? _assessmentTemplateSaveTimer;
  bool _updatingDraftController = false;

  late Future<List<DesktopResult>> _resultsFuture;
  late Future<List<CareEpisodeNote>> _notesFuture;
  late Future<List<CareEpisodeAssessment>> _assessmentsFuture;
  late Future<List<CareEpisodeReport>> _reportsFuture;
  late Future<List<CareEpisodeAssessment>> _archivedAssessmentsFuture;
  late Future<List<CareEpisodeReport>> _archivedReportsFuture;

  ClinicalDocumentType _documentType = ClinicalDocumentType.assessment;
  bool _documentTypeSelected = false;

  CareEpisodeAssessment? _draft;
  CareEpisodeReport? _reportDraft;
  Set<String> _selectedTestExoIds = <String>{};
  Set<String> _selectedNoteIds = <String>{};
  bool _draftLoading = true;
  bool _testSelectionLoading = true;
  bool _noteSelectionLoading = true;
  String? _draftLoadError;

  Future<void> _exportAssessmentDocx() async {
    final assessment = _draft;

    if (assessment == null) {
      return;
    }

    bool createNewDocx = false;

    if (assessment.docxFileName != null) {
      final choice = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Un DOCX existe déjà'),
            content: const Text(
              'Un DOCX est déjà associé à ce bilan. '
              'Voulez-vous remplacer le fichier existant '
              'ou créer un nouveau fichier ?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Annuler'),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop('new');
                },
                child: const Text('Créer un nouveau'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop('replace');
                },
                child: const Text('Remplacer'),
              ),
            ],
          );
        },
      );

      if (choice == null) {
        return;
      }

      createNewDocx = choice == 'new';
    }

    var selectedDirectory = await const ApplicationSettingsService().getString(
      ApplicationSettingsService.assessmentDocumentsDirectoryKey,
    );

    if (selectedDirectory == null || selectedDirectory.trim().isEmpty) {
      selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Choisir le dossier de destination',
      );

      if (selectedDirectory == null) {
        return;
      }
    }

    try {
      final data = await AssessmentDocumentDataBuilder().build(
        assessment: assessment,
        episode: widget.episode,
      );

      final chartPngBytes = <Uint8List>[];

      for (final test in data.tests) {
        for (final series in test.chartSeries) {
          final pngBytes = await const AssessmentChartImageService().buildPng(
            series: series,
          );

          chartPngBytes.add(pngBytes);

          debugPrint(
            '[DOCX] Graphique généré : '
            '${test.title} / ${series.label}',
          );
        }
      }

      final bytes = await AssessmentDocxService().buildDocx(
        data: data,
        chartPngBytes: chartPngBytes,
      );

      final exportService = const EpisodeReportDocxExportService();

      final file = assessment.docxFileName == null || createNewDocx
          ? await exportService.exportToDocxFile(
              bytes: bytes,
              directory: Directory(selectedDirectory),
              fileName: 'Bilan_${widget.patientName}_${assessment.title}',
            )
          : await exportService.overwriteDocxFile(
              bytes: bytes,
              directory: Directory(selectedDirectory),
              fileName: assessment.docxFileName!,
            );

      final updatedAssessment = CareEpisodeAssessment(
        assessmentId: assessment.assessmentId,
        careEpisodeId: assessment.careEpisodeId,
        title: assessment.title,
        contentJson: assessment.contentJson,
        status: assessment.status,
        authorPractitionerId: assessment.authorPractitionerId,
        recipientText: assessment.recipientText,
        docxFileName: file.uri.pathSegments.last,
        assessmentDate: assessment.assessmentDate,
        createdAt: assessment.createdAt,
        updatedAt: assessment.updatedAt,
        archivedAt: assessment.archivedAt,
      );

      await CareEpisodeAssessmentRepository().updateAssessment(
        updatedAssessment,
      );

      debugPrint('[DOCX] Fichier créé : ${file.path}');

      if (!mounted) return;

      setState(() {
        _draft = updatedAssessment;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Document Word créé : ${file.path}')),
      );
    } catch (e, stackTrace) {
      debugPrint('[DOCX] Erreur : $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de la création du document Word : $e'),
        ),
      );
    }
  }

  Future<void> _exportReportDocx() async {
    final report = _reportDraft;

    if (report == null || report.status != 'saved') {
      return;
    }

    bool createNewDocx = false;

    if (report.docxFileName != null) {
      final choice = await showDialog<String>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Un DOCX existe déjà'),
            content: const Text(
              'Un DOCX est déjà associé à ce rapport. '
                  'Voulez-vous remplacer le fichier existant '
                  'ou créer un nouveau fichier ?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Annuler'),
              ),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop('new');
                },
                child: const Text('Créer un nouveau'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop('replace');
                },
                child: const Text('Remplacer'),
              ),
            ],
          );
        },
      );

      if (choice == null) {
        return;
      }

      createNewDocx = choice == 'new';
    }

    var selectedDirectory = await const ApplicationSettingsService().getString(
      ApplicationSettingsService.assessmentDocumentsDirectoryKey,
    );

    if (selectedDirectory == null || selectedDirectory.trim().isEmpty) {
      selectedDirectory = await FilePicker.platform.getDirectoryPath(
        dialogTitle: 'Choisir le dossier de destination',
      );

      if (selectedDirectory == null) {
        return;
      }
    }

    try {
      final data = await ReportDocumentDataBuilder().build(
        report: report,
        episode: widget.episode,
      );

      Uint8List? establishmentLogoBytes;
      String? establishmentLogoExtension;

      final logoPath = data.establishmentLogoPath;

      if (logoPath != null && logoPath.trim().isNotEmpty) {
        final logoFile = File(logoPath);

        if (await logoFile.exists()) {
          final lowerPath = logoPath.toLowerCase();

          if (lowerPath.endsWith('.png')) {
            establishmentLogoExtension = 'png';
          } else if (lowerPath.endsWith('.jpg') ||
              lowerPath.endsWith('.jpeg')) {
            establishmentLogoExtension = 'jpg';
          }

          if (establishmentLogoExtension != null) {
            establishmentLogoBytes = await logoFile.readAsBytes();
          }
        }
      }

      final chartPngBytes = <Uint8List>[];

      for (final test in data.tests) {
        for (final series in test.chartSeries) {
          final pngBytes = await const AssessmentChartImageService().buildPng(
            series: series,
          );

          chartPngBytes.add(pngBytes);

          debugPrint(
            '[RAPPORT DOCX] Graphique généré : '
                '${test.title} / ${series.label}',
          );
        }
      }

      final bytes = await ReportDocxService().buildDocx(
        data: data,
        chartPngBytes: chartPngBytes,
        establishmentLogoBytes: establishmentLogoBytes,
        establishmentLogoExtension: establishmentLogoExtension,
      );

      final exportService = const EpisodeReportDocxExportService();

      final file = report.docxFileName == null || createNewDocx
          ? await exportService.exportToDocxFile(
        bytes: bytes,
        directory: Directory(selectedDirectory),
        fileName: 'Rapport_${widget.patientName}_${report.title}',
      )
          : await exportService.overwriteDocxFile(
        bytes: bytes,
        directory: Directory(selectedDirectory),
        fileName: report.docxFileName!,
      );

      final updatedReport = CareEpisodeReport(
        reportId: report.reportId,
        careEpisodeId: report.careEpisodeId,
        sourceAssessmentId: report.sourceAssessmentId,
        authorPractitionerId: report.authorPractitionerId,
        docxFileName: file.uri.pathSegments.last,
        title: report.title,
        contentJson: report.contentJson,
        status: report.status,
        reportDate: report.reportDate,
        createdAt: report.createdAt,
        updatedAt: report.updatedAt,
        archivedAt: report.archivedAt,
      );

      await _reportRepository.updateReport(updatedReport);

      debugPrint('[DOCX RAPPORT] Fichier créé : ${file.path}');

      if (!mounted) return;

      setState(() {
        _reportDraft = updatedReport;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Document Word créé : ${file.path}',
          ),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('[DOCX RAPPORT] Erreur : $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur lors de la création du document Word : $e',
          ),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();

    _currentReferringPractitionerFuture = _loadCurrentReferringPractitioner();
    _prescribingCorrespondentFuture = _loadPrescribingCorrespondent();
    _resultsFuture = widget.resultRepository.getResultsForCareEpisode(
      widget.episode.careEpisodeId,
    );

    _notesFuture = _careEpisodeRepository.getNotesForEpisode(
      widget.episode.careEpisodeId,
    );

    _assessmentsFuture = _assessmentRepository.getSavedForEpisode(
      widget.episode.careEpisodeId,
    );

    _reportsFuture = _reportRepository.getSavedForEpisode(
      widget.episode.careEpisodeId,
    );

    _archivedAssessmentsFuture = _assessmentRepository.getArchivedForEpisode(
      widget.episode.careEpisodeId,
    );

    _archivedReportsFuture = _reportRepository.getArchivedForEpisode(
      widget.episode.careEpisodeId,
    );

    _draftController.addListener(_scheduleDraftSave);

    _draftLoading = false;
    _testSelectionLoading = false;
    _noteSelectionLoading = false;
  }

  void _setDraftContent(String value) {
    _updatingDraftController = true;

    try {
      _draftController.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    } finally {
      _updatingDraftController = false;
    }
  }

  void _scheduleDraftSave() {
    if (_updatingDraftController || _draftLoading) {
      return;
    }

    switch (_documentType) {
      case ClinicalDocumentType.assessment:
        final assessment = _draft;

        if (assessment == null) {
          return;
        }

        _draftSaveTimer?.cancel();
        _draftSaveTimer = Timer(
          const Duration(seconds: 1),
          assessment.isDraft ? _saveDraft : _saveAssessmentEditDraft,
        );

      case ClinicalDocumentType.report:
        final report = _reportDraft;

        if (report == null) {
          return;
        }

        _draftSaveTimer?.cancel();
        _draftSaveTimer = Timer(
          const Duration(seconds: 1),
          report.isDraft ? _saveReportDraft : _saveReportEditDraft,
        );
    }
  }

  Future<void> _saveAssessmentEditDraft() async {
    final assessment = _draft;

    if (assessment == null || !assessment.isSaved) {
      return;
    }

    await _documentEditDraftRepository.saveContent(
      documentType: 'assessment',
      documentId: assessment.assessmentId,
      contentJson: _draftController.text,
    );
  }

  Future<void> _saveDraft() async {
    final draft = _draft;

    if (draft == null || !draft.isDraft) {
      return;
    }

    final updatedDraft = CareEpisodeAssessment(
      assessmentId: draft.assessmentId,
      careEpisodeId: draft.careEpisodeId,
      title: draft.title,
      contentJson: _draftController.text,
      status: draft.status,
      authorPractitionerId: draft.authorPractitionerId,
      recipientText: draft.recipientText,
      assessmentDate: draft.assessmentDate,
      createdAt: draft.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      archivedAt: draft.archivedAt,
    );

    await _assessmentRepository.updateAssessment(updatedDraft);

    if (!mounted) return;

    _draft = updatedDraft;
  }

  Future<void> _selectAssessmentAuthor() async {
    final draft = _draft;

    if (draft == null) {
      return;
    }

    final selectedPractitionerId = await showDialog<String?>(
      context: context,
      builder: (dialogContext) {
        String? practitionerId = draft.authorPractitionerId;

        return AlertDialog(
          title: const Text('Choisir le rédacteur'),
          content: SizedBox(
            width: 420,
            child: PractitionerSelector(
              label: 'Rédacteur',
              selectedPractitionerId: practitionerId,
              allowEmpty: false,
              onChanged: (value) {
                practitionerId = value;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(practitionerId);
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );

    if (selectedPractitionerId == null || !mounted) {
      return;
    }

    final updatedDraft = CareEpisodeAssessment(
      assessmentId: draft.assessmentId,
      careEpisodeId: draft.careEpisodeId,
      title: draft.title,
      contentJson: draft.contentJson,
      status: draft.status,
      authorPractitionerId: selectedPractitionerId,
      recipientText: draft.recipientText,
      assessmentDate: draft.assessmentDate,
      createdAt: draft.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      archivedAt: draft.archivedAt,
    );

    await _assessmentRepository.updateAssessment(updatedDraft);

    if (!mounted) return;

    setState(() {
      _draft = updatedDraft;
    });
  }

  Future<void> _selectReportAuthor() async {
    final report = _reportDraft;

    if (report == null) {
      return;
    }

    final selectedPractitionerId = await showDialog<String?>(
      context: context,
      builder: (dialogContext) {
        String? practitionerId = report.authorPractitionerId;

        return AlertDialog(
          title: const Text('Choisir le rédacteur'),
          content: SizedBox(
            width: 420,
            child: PractitionerSelector(
              label: 'Rédacteur',
              selectedPractitionerId: practitionerId,
              allowEmpty: false,
              onChanged: (value) {
                practitionerId = value;
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(practitionerId);
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );

    if (selectedPractitionerId == null || !mounted) {
      return;
    }

    final updatedReport = CareEpisodeReport(
      reportId: report.reportId,
      careEpisodeId: report.careEpisodeId,
      sourceAssessmentId: report.sourceAssessmentId,
      authorPractitionerId: selectedPractitionerId,
      docxFileName: report.docxFileName,
      title: report.title,
      contentJson: report.contentJson,
      status: report.status,
      reportDate: report.reportDate,
      createdAt: report.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      archivedAt: report.archivedAt,
    );

    await _reportRepository.updateReport(updatedReport);

    if (!mounted) return;

    setState(() {
      _reportDraft = updatedReport;
    });
  }

  Future<void> _editAssessmentRecipient() async {
    final draft = _draft;

    if (draft == null) {
      return;
    }

    final controller = TextEditingController(text: draft.recipientText ?? '');

    final recipientText = await showDialog<String?>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Destinataire(s)'),
          content: SizedBox(
            width: 420,
            child: TextField(
              controller: controller,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Destinataire(s)',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(controller.text.trim());
              },
              child: const Text('Valider'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (recipientText == null || !mounted) {
      return;
    }

    final updatedDraft = CareEpisodeAssessment(
      assessmentId: draft.assessmentId,
      careEpisodeId: draft.careEpisodeId,
      title: draft.title,
      contentJson: draft.contentJson,
      status: draft.status,
      authorPractitionerId: draft.authorPractitionerId,
      recipientText: recipientText.isEmpty ? null : recipientText,
      docxFileName: draft.docxFileName,
      assessmentDate: draft.assessmentDate,
      createdAt: draft.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      archivedAt: draft.archivedAt,
    );

    await _assessmentRepository.updateAssessment(updatedDraft);

    if (!mounted) return;

    setState(() {
      _draft = updatedDraft;
    });
  }

  Future<void> _saveReportDraft() async {
    final report = _reportDraft;

    if (report == null || !report.isDraft) {
      return;
    }

    final updatedReport = CareEpisodeReport(
      reportId: report.reportId,
      careEpisodeId: report.careEpisodeId,
      sourceAssessmentId: report.sourceAssessmentId,
      authorPractitionerId: report.authorPractitionerId,
      docxFileName: report.docxFileName,
      title: report.title,
      contentJson: _draftController.text,
      status: report.status,
      reportDate: report.reportDate,
      createdAt: report.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      archivedAt: report.archivedAt,
    );

    await _reportRepository.updateReport(updatedReport);

    if (!mounted) return;

    _reportDraft = updatedReport;
  }

  Future<void> _saveReportEditDraft() async {
    final report = _reportDraft;

    if (report == null || !report.isSaved) {
      return;
    }

    await _documentEditDraftRepository.saveContent(
      documentType: 'report',
      documentId: report.reportId,
      contentJson: _draftController.text,
    );
  }

  Future<CareEpisodeReport> _getOrCreateReportDraft() async {
    var report = await _reportRepository.getDraftForEpisode(
      widget.episode.careEpisodeId,
    );

    if (report != null) {
      return report;
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    report = CareEpisodeReport(
      reportId: const Uuid().v4(),
      careEpisodeId: widget.episode.careEpisodeId,
      docxFileName: null,
      sourceAssessmentId: null,
      title: '',
      contentJson: '',
      status: 'draft',
      reportDate: now,
      createdAt: now,
    );

    await _reportRepository.insertReport(report);
    return report;
  }

  Future<void> _createOrOpenReportDraft() async {
    _draftSaveTimer?.cancel();

    if (_documentTypeSelected) {
      if (_documentType == ClinicalDocumentType.assessment) {
        await _saveDraft();
      } else {
        await _saveReportDraft();
      }
    }

    if (!mounted) return;

    try {
      final report = await _getOrCreateReportDraft();

      if (!mounted) return;

      if (report.contentJson.trim().isNotEmpty) {
        final choice = await showDialog<String>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Un brouillon de rapport existe'),
              content: const Text(
                'Un travail en cours a déjà été sauvegardé automatiquement.\n\n'
                'Souhaitez-vous reprendre ce brouillon ou commencer un nouveau rapport ?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop('cancel'),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop('resume'),
                  child: const Text('Reprendre le brouillon'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop('new'),
                  child: const Text('Nouveau rapport'),
                ),
              ],
            );
          },
        );

        if (choice == null || choice == 'cancel') {
          return;
        }

        if (choice == 'resume') {
          await _showReport(report);
          return;
        }

        if (choice == 'new') {
          final now = DateTime.now().millisecondsSinceEpoch;

          final emptyReport = CareEpisodeReport(
            reportId: report.reportId,
            careEpisodeId: report.careEpisodeId,
            sourceAssessmentId: report.sourceAssessmentId,
            authorPractitionerId: report.authorPractitionerId,
            docxFileName: report.docxFileName,
            title: '',
            contentJson: '',
            status: 'draft',
            reportDate: now,
            createdAt: report.createdAt,
            updatedAt: now,
            archivedAt: report.archivedAt,
          );

          await _reportRepository.updateReport(emptyReport);

          if (!mounted) return;

          await _showReport(emptyReport);
          return;
        }
      }

      await _showReport(report);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’ouvrir le brouillon du rapport.'),
        ),
      );
    }
  }

  Future<void> _showReport(
      CareEpisodeReport report, {
        String? contentOverride,
      }) async {
    setState(() {
      _testSelectionLoading = true;
      _noteSelectionLoading = true;
    });

    final selectedTestExoIds = await _reportRepository
        .getSelectedTestExoIds(report.reportId);

    final selectedNoteIds = await _reportRepository.getSelectedNoteIds(
      report.reportId,
    );

    if (!mounted) return;

    setState(() {
      _documentType = ClinicalDocumentType.report;
      _documentTypeSelected = true;
      _reportDraft = report;
      _selectedTestExoIds = selectedTestExoIds;
      _selectedNoteIds = selectedNoteIds;
      _testSelectionLoading = false;
      _noteSelectionLoading = false;
      _draftLoadError = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _setDraftContent(contentOverride ?? report.contentJson);
      _draftFocusNode.requestFocus();
    });
  }

  Future<void> _editReport(CareEpisodeReport report) async {
    _draftSaveTimer?.cancel();

    if (_documentType == ClinicalDocumentType.assessment) {
      await _saveDraft();
    } else {
      await _saveReportDraft();
    }

    if (!mounted) return;

    try {
      final reloadedReport = await _reportRepository.getReportById(
        report.reportId,
      );

      if (reloadedReport == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le rapport est introuvable.')),
        );
        return;
      }

      final editDraftContent = await _documentEditDraftRepository.getContent(
        documentType: 'report',
        documentId: reloadedReport.reportId,
      );

      if (!mounted) return;

      await _showReport(reloadedReport, contentOverride: editDraftContent);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible d’ouvrir le rapport.')),
      );
    }
  }

  Future<void> _returnToReportDraft() async {
    _draftSaveTimer?.cancel();

    try {
      final report = await _getOrCreateReportDraft();
      await _showReport(report);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de revenir au brouillon du rapport.'),
        ),
      );
    }
  }

  Future<void> _cancelReportChanges() async {
    final report = _reportDraft;

    if (report == null || !report.isSaved) {
      return;
    }

    _draftSaveTimer?.cancel();

    await _documentEditDraftRepository.delete(
      documentType: 'report',
      documentId: report.reportId,
    );

    try {
      final reloadedReport = await _reportRepository.getReportById(
        report.reportId,
      );

      if (reloadedReport == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le rapport est introuvable.')),
        );
        return;
      }

      await _showReport(reloadedReport);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’annuler les modifications du rapport.'),
        ),
      );
    }
  }

  Future<void> _editAssessment(CareEpisodeAssessment assessment) async {
    _draftSaveTimer?.cancel();

    final currentAssessment = _draft;

    if (currentAssessment != null) {
      await _saveDraft();
    }

    if (!mounted) return;

    final reloadedAssessment = await _assessmentRepository.getAssessmentById(
      assessment.assessmentId,
    );

    if (!mounted) return;

    if (reloadedAssessment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Le bilan est introuvable.')),
      );
      return;
    }

    final selectedTestExoIds = await _assessmentRepository
        .getSelectedTestExoIds(reloadedAssessment.assessmentId);

    final selectedNoteIds = await _assessmentRepository.getSelectedNoteIds(
      reloadedAssessment.assessmentId,
    );

    final editDraftContent = await _documentEditDraftRepository.getContent(
      documentType: 'assessment',
      documentId: reloadedAssessment.assessmentId,
    );

    if (!mounted) return;

    setState(() {
      _documentType = ClinicalDocumentType.assessment;
      _draft = reloadedAssessment;
      _selectedTestExoIds = selectedTestExoIds;
      _selectedNoteIds = selectedNoteIds;
      _testSelectionLoading = false;
      _noteSelectionLoading = false;
      _draftLoadError = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _setDraftContent(editDraftContent ?? reloadedAssessment.contentJson);
      _draftFocusNode.requestFocus();
    });
  }

  Future<void> _duplicateAssessment(CareEpisodeAssessment assessment) async {
    final title = await _showDocumentTitleDialog(
      dialogTitle: 'Dupliquer le bilan',
      fieldLabel: 'Titre du nouveau bilan',
      actionLabel: 'Dupliquer',
      initialTitle: 'Copie de ${assessment.title}',
    );

    if (title == null) {
      return;
    }

    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      final duplicatedAssessment = CareEpisodeAssessment(
        assessmentId: const Uuid().v4(),
        careEpisodeId: assessment.careEpisodeId,
        title: title,
        contentJson: assessment.contentJson,
        status: 'saved',
        assessmentDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await _assessmentRepository.insertAssessment(duplicatedAssessment);

      if (!mounted) return;

      setState(() {
        _assessmentsFuture = _assessmentRepository.getSavedForEpisode(
          widget.episode.careEpisodeId,
        );
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de dupliquer le bilan.')),
      );
    }
  }

  Future<void> _duplicateReport(CareEpisodeReport report) async {
    final title = await _showDocumentTitleDialog(
      dialogTitle: 'Dupliquer le rapport',
      fieldLabel: 'Titre du nouveau rapport',
      actionLabel: 'Dupliquer',
      initialTitle: 'Copie de ${report.title}',
    );

    if (title == null) {
      return;
    }

    try {
      final now = DateTime.now().millisecondsSinceEpoch;

      final duplicatedReport = CareEpisodeReport(
        reportId: const Uuid().v4(),
        careEpisodeId: report.careEpisodeId,
        sourceAssessmentId: report.sourceAssessmentId,
        authorPractitionerId: report.authorPractitionerId,
        docxFileName: null,
        title: title,
        contentJson: report.contentJson,
        status: 'saved',
        reportDate: now,
        createdAt: now,
        updatedAt: now,
      );

      await _reportRepository.insertReport(duplicatedReport);

      if (!mounted) return;

      setState(() {
        _reportsFuture = _reportRepository.getSavedForEpisode(
          widget.episode.careEpisodeId,
        );
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de dupliquer le rapport.')),
      );
    }
  }

  Future<void> _setTestIncluded({
    required String exoId,
    required bool included,
  }) async {
    if (_testSelectionLoading) {
      return;
    }

    final previousSelection = Set<String>.from(_selectedTestExoIds);
    final nextSelection = Set<String>.from(_selectedTestExoIds);

    if (included) {
      nextSelection.add(exoId);
    } else {
      nextSelection.remove(exoId);
    }

    setState(() {
      _selectedTestExoIds = nextSelection;
    });

    try {
      switch (_documentType) {
        case ClinicalDocumentType.assessment:
          final assessment = _draft;

          if (assessment == null) {
            return;
          }

          if (assessment.isSaved) {
            return;
          }

          await _assessmentRepository.setTestIncluded(
            assessmentId: assessment.assessmentId,
            exoId: exoId,
            included: included,
          );

        case ClinicalDocumentType.report:
          final report = _reportDraft;

          if (report == null) {
            return;
          }

          if (report.isSaved) {
            return;
          }

          await _reportRepository.setTestIncluded(
            reportId: report.reportId,
            exoId: exoId,
            included: included,
          );
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _selectedTestExoIds = previousSelection;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’enregistrer la sélection du test.'),
        ),
      );
    }
  }

  Future<void> _setNoteIncluded({
    required String noteId,
    required bool included,
  }) async {
    if (_noteSelectionLoading) {
      return;
    }

    final previousSelection = Set<String>.from(_selectedNoteIds);
    final nextSelection = Set<String>.from(_selectedNoteIds);

    if (included) {
      nextSelection.add(noteId);
    } else {
      nextSelection.remove(noteId);
    }

    setState(() {
      _selectedNoteIds = nextSelection;
    });

    try {
      switch (_documentType) {
        case ClinicalDocumentType.assessment:
          final assessment = _draft;

          if (assessment == null) {
            return;
          }

          if (assessment.isSaved) {
            return;
          }

          await _assessmentRepository.setNoteIncluded(
            assessmentId: assessment.assessmentId,
            noteId: noteId,
            included: included,
          );

        case ClinicalDocumentType.report:
          final report = _reportDraft;

          if (report == null) {
            return;
          }

          if (report.isSaved) {
            return;
          }

          await _reportRepository.setNoteIncluded(
            reportId: report.reportId,
            noteId: noteId,
            included: included,
          );
      }
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _selectedNoteIds = previousSelection;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’enregistrer la sélection de la note.'),
        ),
      );
    }
  }

  Future<CareEpisodeAssessment> _getOrCreateDraft() async {
    var draft = await _assessmentRepository.getDraftForEpisode(
      widget.episode.careEpisodeId,
    );

    if (draft != null) {
      return draft;
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    draft = CareEpisodeAssessment(
      assessmentId: const Uuid().v4(),
      careEpisodeId: widget.episode.careEpisodeId,
      title: '',
      contentJson: '',
      status: 'draft',
      assessmentDate: now,
      createdAt: now,
    );

    await _assessmentRepository.insertAssessment(draft);
    return draft;
  }

  Future<void> _showAssessment(CareEpisodeAssessment assessment) async {
    final selectedTestExoIds = await _assessmentRepository
        .getSelectedTestExoIds(assessment.assessmentId);

    final selectedNoteIds = await _assessmentRepository.getSelectedNoteIds(
      assessment.assessmentId,
    );

    if (!mounted) return;

    setState(() {
      _documentTypeSelected = true;
      _documentType = ClinicalDocumentType.assessment;
      _draft = assessment;
      _selectedTestExoIds = selectedTestExoIds;
      _selectedNoteIds = selectedNoteIds;
      _testSelectionLoading = false;
      _noteSelectionLoading = false;
      _draftLoadError = null;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _setDraftContent(assessment.contentJson);
      _draftFocusNode.requestFocus();
    });
  }

  Future<void> _returnToDraft() async {
    _draftSaveTimer?.cancel();

    try {
      final draft = await _getOrCreateDraft();

      if (!mounted) return;

      if (draft.contentJson.trim().isNotEmpty) {
        final choice = await showDialog<String>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Un brouillon de bilan existe'),
              content: const Text(
                'Un travail en cours a déjà été sauvegardé automatiquement.\n\n'
                'Souhaitez-vous reprendre ce brouillon ou commencer un nouveau bilan ?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop('cancel'),
                  child: const Text('Annuler'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop('resume'),
                  child: const Text('Reprendre le brouillon'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(dialogContext).pop('new'),
                  child: const Text('Nouveau bilan'),
                ),
              ],
            );
          },
        );

        if (choice == null || choice == 'cancel') {
          return;
        }

        if (choice == 'resume') {
          await _showAssessment(draft);
          return;
        }

        if (choice == 'new') {
          final now = DateTime.now().millisecondsSinceEpoch;

          final emptyDraft = CareEpisodeAssessment(
            assessmentId: draft.assessmentId,
            careEpisodeId: draft.careEpisodeId,
            title: '',
            contentJson: '',
            status: 'draft',
            assessmentDate: now,
            createdAt: draft.createdAt,
            updatedAt: now,
            archivedAt: draft.archivedAt,
          );

          await _assessmentRepository.updateAssessment(emptyDraft);

          if (!mounted) return;

          await _showAssessment(emptyDraft);
          return;
        }
      }

      await _showAssessment(draft);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de revenir au brouillon.')),
      );
    }
  }

  Future<void> _cancelAssessmentChanges() async {
    final assessment = _draft;

    if (assessment == null || !assessment.isSaved) {
      return;
    }

    _draftSaveTimer?.cancel();

    await _documentEditDraftRepository.delete(
      documentType: 'assessment',
      documentId: assessment.assessmentId,
    );

    try {
      final reloadedAssessment = await _assessmentRepository.getAssessmentById(
        assessment.assessmentId,
      );

      if (reloadedAssessment == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Le bilan est introuvable.')),
        );
        return;
      }

      await _showAssessment(reloadedAssessment);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’annuler les modifications.'),
        ),
      );
    }
  }

  Future<void> _archiveAssessment(CareEpisodeAssessment assessment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Mettre le bilan à la corbeille ?'),
          content: Text(
            'Le bilan « ${assessment.title} » ne sera plus affiché '
            'dans l’historique.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Mettre à la corbeille'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    _draftSaveTimer?.cancel();

    try {
      await _assessmentRepository.archiveAssessment(assessment.assessmentId);

      CareEpisodeAssessment? activeDraft = _draft;

      if (_draft?.assessmentId == assessment.assessmentId) {
        activeDraft = await _assessmentRepository.getDraftForEpisode(
          widget.episode.careEpisodeId,
        );

        if (activeDraft == null) {
          final now = DateTime.now().millisecondsSinceEpoch;

          activeDraft = CareEpisodeAssessment(
            assessmentId: const Uuid().v4(),
            careEpisodeId: widget.episode.careEpisodeId,
            title: '',
            contentJson: '',
            status: 'draft',
            assessmentDate: now,
            createdAt: now,
          );

          await _assessmentRepository.insertAssessment(activeDraft);
        }
      }

      final selectedTestExoIds = activeDraft == null
          ? <String>{}
          : await _assessmentRepository.getSelectedTestExoIds(
              activeDraft.assessmentId,
            );

      final selectedNoteIds = activeDraft == null
          ? <String>{}
          : await _assessmentRepository.getSelectedNoteIds(
              activeDraft.assessmentId,
            );

      if (!mounted) return;

      setState(() {
        _draft = activeDraft;
        _selectedTestExoIds = selectedTestExoIds;
        _selectedNoteIds = selectedNoteIds;
        if (_draft?.assessmentId != assessment.assessmentId) {
          _setDraftContent(_draft?.contentJson ?? '');
        }
        _assessmentsFuture = _assessmentRepository.getSavedForEpisode(
          widget.episode.careEpisodeId,
        );
        _archivedAssessmentsFuture = _assessmentRepository
            .getArchivedForEpisode(widget.episode.careEpisodeId);
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de mettre le bilan à la corbeille.'),
        ),
      );
    }
  }

  Future<void> _archiveReport(CareEpisodeReport report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Mettre le rapport à la corbeille ?'),
          content: Text(
            'Le rapport « ${report.title} » sera placé dans la corbeille. '
            'Il pourra être restauré ultérieurement.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Mettre à la corbeille'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _reportRepository.archiveReport(report.reportId);

      if (!mounted) return;

      setState(() {
        _reportsFuture = _reportRepository.getSavedForEpisode(
          widget.episode.careEpisodeId,
        );
        _archivedReportsFuture = _reportRepository.getArchivedForEpisode(
          widget.episode.careEpisodeId,
        );
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de mettre le rapport à la corbeille.'),
        ),
      );
    }
  }

  Future<void> _restoreAssessment(CareEpisodeAssessment assessment) async {
    try {
      await _assessmentRepository.restoreAssessment(assessment.assessmentId);

      if (!mounted) return;

      setState(() {
        _assessmentsFuture = _assessmentRepository.getSavedForEpisode(
          widget.episode.careEpisodeId,
        );
        _archivedAssessmentsFuture = _assessmentRepository
            .getArchivedForEpisode(widget.episode.careEpisodeId);
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de restaurer le bilan.')),
      );
    }
  }

  Future<void> _restoreReport(CareEpisodeReport report) async {
    try {
      await _reportRepository.restoreReport(report.reportId);

      if (!mounted) return;

      setState(() {
        _reportsFuture = _reportRepository.getSavedForEpisode(
          widget.episode.careEpisodeId,
        );
        _archivedReportsFuture = _reportRepository.getArchivedForEpisode(
          widget.episode.careEpisodeId,
        );
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de restaurer le rapport.')),
      );
    }
  }

  Future<void> _deleteAssessmentPermanently(
    CareEpisodeAssessment assessment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer définitivement le bilan ?'),
          content: Text(
            'Le bilan « ${assessment.title} » sera définitivement supprimé. '
            'Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Supprimer définitivement'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _assessmentRepository.deleteAssessment(assessment.assessmentId);

      if (!mounted) return;

      setState(() {
        _archivedAssessmentsFuture = _assessmentRepository
            .getArchivedForEpisode(widget.episode.careEpisodeId);
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de supprimer définitivement le bilan.'),
        ),
      );
    }
  }

  Future<void> _deleteReportPermanently(CareEpisodeReport report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer définitivement le rapport ?'),
          content: Text(
            'Le rapport « ${report.title} » sera définitivement supprimé. '
            'Cette action est irréversible.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Supprimer définitivement'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    try {
      await _reportRepository.deleteReport(report.reportId);

      if (!mounted) return;

      setState(() {
        _archivedReportsFuture = _reportRepository.getArchivedForEpisode(
          widget.episode.careEpisodeId,
        );
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de supprimer définitivement le rapport.'),
        ),
      );
    }
  }

  Future<String?> _showDocumentTitleDialog({
    required String dialogTitle,
    required String fieldLabel,
    required String actionLabel,
    String initialTitle = '',
  }) {
    return showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return DocumentTitleDialog(
          dialogTitle: dialogTitle,
          fieldLabel: fieldLabel,
          actionLabel: actionLabel,
          initialTitle: initialTitle,
        );
      },
    );
  }

  Future<void> _saveOrUpdateAssessment() async {
    final assessment = _draft;

    if (assessment == null) {
      return;
    }

    final isEditing = assessment.isSaved;

    final title = await _showDocumentTitleDialog(
      dialogTitle: isEditing
          ? 'Mettre à jour le bilan'
          : 'Enregistrer le bilan',
      fieldLabel: 'Titre du bilan',
      actionLabel: isEditing ? 'Mettre à jour' : 'Enregistrer',
      initialTitle: isEditing ? assessment.title : '',
    );

    if (title == null) {
      return;
    }

    _draftSaveTimer?.cancel();

    final now = DateTime.now().millisecondsSinceEpoch;

    final savedAssessment = CareEpisodeAssessment(
      assessmentId: assessment.assessmentId,
      careEpisodeId: assessment.careEpisodeId,
      title: title,
      contentJson: _draftController.text,
      status: 'saved',
      authorPractitionerId: assessment.authorPractitionerId,
      recipientText: assessment.recipientText,
      docxFileName: assessment.docxFileName,
      assessmentDate: isEditing ? assessment.assessmentDate : now,
      createdAt: assessment.createdAt,
      updatedAt: now,
      archivedAt: assessment.archivedAt,
    );

    try {
      await _assessmentRepository.updateAssessment(savedAssessment);

      if (isEditing) {
        await _documentEditDraftRepository.delete(
          documentType: 'assessment',
          documentId: savedAssessment.assessmentId,
        );
      }

      if (isEditing) {
        await _assessmentRepository.replaceSelectedTests(
          assessmentId: savedAssessment.assessmentId,
          exoIds: _selectedTestExoIds,
        );

        await _assessmentRepository.replaceSelectedNotes(
          assessmentId: savedAssessment.assessmentId,
          noteIds: _selectedNoteIds,
        );

        if (!mounted) return;

        setState(() {
          _draft = savedAssessment;
          _assessmentsFuture = _assessmentRepository.getSavedForEpisode(
            widget.episode.careEpisodeId,
          );
        });

        return;
      }

      final newDraftCreatedAt = DateTime.now().millisecondsSinceEpoch;

      final newDraft = CareEpisodeAssessment(
        assessmentId: const Uuid().v4(),
        careEpisodeId: widget.episode.careEpisodeId,
        title: '',
        contentJson: '',
        status: 'draft',
        assessmentDate: newDraftCreatedAt,
        createdAt: newDraftCreatedAt,
      );

      await _assessmentRepository.insertAssessment(newDraft);

      if (!mounted) return;

      _setDraftContent('');

      setState(() {
        _draft = newDraft;
        _selectedTestExoIds = <String>{};
        _selectedNoteIds = <String>{};
        _assessmentsFuture = _assessmentRepository.getSavedForEpisode(
          widget.episode.careEpisodeId,
        );
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _draftFocusNode.requestFocus();
        }
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Impossible de mettre à jour le bilan.'
                : 'Impossible d’enregistrer le bilan.',
          ),
        ),
      );
    }
  }

  Future<void> _saveReport() async {
    final report = _reportDraft;

    if (report == null) {
      return;
    }

    final isEditing = report.isSaved;

    final title = await _showDocumentTitleDialog(
      dialogTitle: isEditing
          ? 'Mettre à jour le rapport'
          : 'Enregistrer le rapport',
      fieldLabel: 'Titre du rapport',
      actionLabel: isEditing ? 'Mettre à jour' : 'Enregistrer',
      initialTitle: isEditing ? report.title : '',
    );

    if (title == null) {
      return;
    }

    _draftSaveTimer?.cancel();

    final now = DateTime.now().millisecondsSinceEpoch;

    final currentReferringPractitioner =
    await _loadCurrentReferringPractitioner();

    final savedReport = CareEpisodeReport(
      reportId: report.reportId,
      careEpisodeId: report.careEpisodeId,
      sourceAssessmentId: report.sourceAssessmentId,
      authorPractitionerId:
      report.authorPractitionerId ??
          currentReferringPractitioner?.practitionerId,
      docxFileName: report.docxFileName,
      title: title,
      contentJson: _draftController.text,
      status: 'saved',
      reportDate: isEditing ? report.reportDate : now,
      createdAt: report.createdAt,
      updatedAt: now,
      archivedAt: report.archivedAt,
    );

    try {
      await _reportRepository.updateReport(savedReport);

      if (isEditing) {
        await _documentEditDraftRepository.delete(
          documentType: 'report',
          documentId: savedReport.reportId,
        );
      }

      await _reportRepository.replaceSelectedTests(
        reportId: savedReport.reportId,
        exoIds: _selectedTestExoIds,
      );

      await _reportRepository.replaceSelectedNotes(
        reportId: savedReport.reportId,
        noteIds: _selectedNoteIds,
      );

      if (isEditing) {
        if (!mounted) return;

        setState(() {
          _reportDraft = savedReport;
          _reportsFuture = _reportRepository.getSavedForEpisode(
            widget.episode.careEpisodeId,
          );
        });

        return;
      }

      final newDraft = CareEpisodeReport(
        reportId: const Uuid().v4(),
        careEpisodeId: widget.episode.careEpisodeId,
        sourceAssessmentId: null,
        title: '',
        contentJson: '',
        status: 'draft',
        reportDate: now,
        createdAt: now,
      );

      await _reportRepository.insertReport(newDraft);

      if (!mounted) return;

      _setDraftContent('');

      setState(() {
        _documentType = ClinicalDocumentType.report;
        _reportDraft = newDraft;
        _selectedTestExoIds = <String>{};
        _selectedNoteIds = <String>{};
        _reportsFuture = _reportRepository.getSavedForEpisode(
          widget.episode.careEpisodeId,
        );
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _draftFocusNode.requestFocus();
        }
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditing
                ? 'Impossible de mettre à jour le rapport.'
                : 'Impossible d’enregistrer le rapport.',
          ),
        ),
      );
    }
  }

  Future<void> _addFollowUpNote() async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Nouvelle note de suivi'),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  minLines: 5,
                  maxLines: 10,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );

    final title = titleController.text.trim();
    final content = contentController.text.trim();

    titleController.dispose();
    contentController.dispose();

    if (confirmed != true || title.isEmpty || content.isEmpty) {
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    final note = CareEpisodeNote(
      noteId: const Uuid().v4(),
      careEpisodeId: widget.episode.careEpisodeId,
      noteDate: now,
      title: title,
      content: content,
      createdAt: now,
    );

    await _careEpisodeRepository.insertNote(note);

    if (!mounted) return;

    setState(() {
      _notesFuture = _careEpisodeRepository.getNotesForEpisode(
        widget.episode.careEpisodeId,
      );
    });
  }

  Future<void> _editFollowUpNote(CareEpisodeNote note) async {
    final titleController = TextEditingController(text: note.title);

    final contentController = TextEditingController(text: note.content);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Modifier la note de suivi'),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Note',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  minLines: 5,
                  maxLines: 10,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    final title = titleController.text.trim();
    final content = contentController.text.trim();

    titleController.dispose();
    contentController.dispose();

    if (confirmed != true || title.isEmpty || content.isEmpty) {
      return;
    }

    final updatedNote = CareEpisodeNote(
      noteId: note.noteId,
      careEpisodeId: note.careEpisodeId,
      noteDate: note.noteDate,
      title: title,
      content: content,
      createdAt: note.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      archivedAt: note.archivedAt,
    );

    await _careEpisodeRepository.updateNote(updatedNote);

    if (!mounted) return;

    setState(() {
      _notesFuture = _careEpisodeRepository.getNotesForEpisode(
        widget.episode.careEpisodeId,
      );
    });
  }

  Future<void> _openExpandedSoapEditor() async {
    final expandedController = TextEditingController(
      text: _draftController.text,
    );

    void synchronizeContent() {
      if (_draftController.text == expandedController.text) {
        return;
      }

      _draftController.value = TextEditingValue(
        text: expandedController.text,
        selection: TextSelection.collapsed(
          offset: expandedController.text.length,
        ),
      );
    }

    expandedController.addListener(synchronizeContent);

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(32),
          child: SizedBox(
            width: MediaQuery.of(dialogContext).size.width * 0.90,
            height: MediaQuery.of(dialogContext).size.height * 0.85,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _documentType.editorTitle,
                          style: Theme.of(dialogContext).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        tooltip: 'Fermer',
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: expandedController,
                      autofocus: true,
                      enabled: _documentType == ClinicalDocumentType.assessment
                          ? _draft != null
                          : _reportDraft != null,
                      decoration: const InputDecoration(
                        hintText:
                            'Zone de rédaction du bilan SOAP.\n\n'
                            'S — Subjectif\n\n'
                            'O — Objectif\n\n'
                            'A — Analyse\n\n'
                            'P — Plan',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                      expands: true,
                      minLines: null,
                      maxLines: null,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    expandedController.removeListener(synchronizeContent);
    expandedController.dispose();
  }

  Future<bool> _insertAssessmentTemplateText(String generatedText) async {
    final text = generatedText.trim();

    if (text.isEmpty) {
      return false;
    }

    if (_documentType != ClinicalDocumentType.assessment || _draft == null) {
      return false;
    }

    final existingText = _draftController.text.trim();

    if (existingText.isEmpty) {
      _draftController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );

      _draftFocusNode.requestFocus();
      return true;
    }

    final choice = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Le bilan contient déjà du texte'),
          content: const Text(
            'Souhaitez-vous ajouter le contenu généré '
            'à la suite du bilan actuel ou remplacer '
            'le contenu existant ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop('cancel'),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop('append'),
              child: const Text('Ajouter à la suite'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop('replace'),
              child: const Text('Remplacer'),
            ),
          ],
        );
      },
    );

    if (choice == null || choice == 'cancel') {
      return false;
    }

    final newText = choice == 'replace'
        ? text
        : '${_draftController.text.trimRight()}\n\n$text';

    _draftController.value = TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );

    _draftFocusNode.requestFocus();

    return true;
  }

  void _scheduleAssessmentTemplateSave(AssessmentTemplateAnswers answers) {
    _assessmentTemplateSaveTimer?.cancel();

    _assessmentTemplateSaveTimer = Timer(const Duration(seconds: 1), () async {
      await _assessmentTemplateDraftRepository.saveDraft(
        careEpisodeId: widget.episode.careEpisodeId,
        answers: answers,
      );
    });
  }

  Future<void> _openAssessmentTemplateGuide() async {
    final template = await showDialog<AssessmentTemplate>(
      context: context,
      builder: (dialogContext) {
        return AssessmentTemplateSelector(
          templates: const [
            DefaultAssessmentTemplates.musculoskeletalGeneral,
            DefaultAssessmentTemplates.musculoskeletalUpperLimb,
          ],
        );
      },
    );

    if (template == null || !mounted) {
      return;
    }

    await _openAssessmentTemplateGuideFor(template);
  }

  Future<void> _openAssessmentTemplateGuideFor(
    AssessmentTemplate template,
  ) async {
    final profession = await _patientAttributeRepository.getOne(
      patientId: widget.episode.patientId,
      attributeKey: 'profession',
    );

    final sport = await _patientAttributeRepository.getOne(
      patientId: widget.episode.patientId,
      attributeKey: 'sport',
    );

    final savedAnswers = await _assessmentTemplateDraftRepository.getDraft(
      careEpisodeId: widget.episode.careEpisodeId,
      templateId: template.id,
    );

    if (!mounted) return;

    final initialValues = <String, String>{
      'profession': profession?.attributeValue?.trim() ?? '',
      'sports_activities': sport?.attributeValue?.trim() ?? '',
    };

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          child: SizedBox(
            width: 1100,
            height: 760,
            child: AssessmentTemplateGuide(
              template: template,
              initialValues: initialValues,
              initialAnswers: savedAnswers,
              onAnswersChanged: _scheduleAssessmentTemplateSave,
              onInsertGeneratedText: _insertAssessmentTemplateText,
            ),
          ),
        );
      },
    );
  }

  Future<void> _showExpandedWorkspaceContent({
    required String title,
    required Widget child,
  }) {
    return showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          insetPadding: const EdgeInsets.all(32),
          child: SizedBox(
            width: MediaQuery.of(dialogContext).size.width * 0.90,
            height: MediaQuery.of(dialogContext).size.height * 0.85,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          title,
                          style: Theme.of(dialogContext).textTheme.titleLarge,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        tooltip: 'Fermer',
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(child: child),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _draftSaveTimer?.cancel();
    _draftController.removeListener(_scheduleDraftSave);
    _draftController.dispose();
    _draftFocusNode.dispose();
    _assessmentTemplateSaveTimer?.cancel();
    super.dispose();
  }

  Future<Practitioner?> _loadCurrentReferringPractitioner() async {
    final assignment = await _referringPractitionerRepository
        .getCurrentReferringPractitioner(widget.episode.careEpisodeId);

    if (assignment == null) {
      return null;
    }

    return _practitionerRepository.getPractitionerById(
      assignment.practitionerId,
    );
  }

  Future<ExternalCorrespondent?> _loadPrescribingCorrespondent() async {
    final correspondentId = widget.episode.prescribingCorrespondentId;

    if (correspondentId == null) {
      return null;
    }

    return _externalCorrespondentRepository.getById(correspondentId);
  }

  Future<Practitioner?> _loadAssessmentAuthor(
    CareEpisodeAssessment assessment,
  ) async {
    final authorPractitionerId = assessment.authorPractitionerId;

    if (authorPractitionerId != null &&
        authorPractitionerId.trim().isNotEmpty) {
      return _practitionerRepository.getPractitionerById(authorPractitionerId);
    }

    return _loadCurrentReferringPractitioner();
  }

  Future<Practitioner?> _loadReportAuthor(
      CareEpisodeReport report,
      ) async {
    final authorPractitionerId = report.authorPractitionerId;

    if (authorPractitionerId != null &&
        authorPractitionerId.trim().isNotEmpty) {
      return _practitionerRepository.getPractitionerById(
        authorPractitionerId,
      );
    }

    return _loadCurrentReferringPractitioner();
  }

  Future<void> _editReferringPractitioner() async {
    final currentAssignment = await _referringPractitionerRepository
        .getCurrentReferringPractitioner(widget.episode.careEpisodeId);

    if (!mounted) return;

    final previousPractitionerId = currentAssignment?.practitionerId;
    String? selectedPractitionerId = previousPractitionerId;
    final previousCorrespondentId =
        widget.episode.prescribingCorrespondentId;

    String? selectedCorrespondentId = previousCorrespondentId;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Modifier les référents'),
          content: SizedBox(
            width: 480,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                PractitionerSelector(
                  label: 'Kiné référent',
                  selectedPractitionerId: selectedPractitionerId,
                  allowEmpty: true,
                  onChanged: (practitionerId) {
                    selectedPractitionerId = practitionerId;
                  },
                ),
                const SizedBox(height: 16),
                ExternalCorrespondentSelector(
                  label: 'Médecin prescripteur',
                  selectedCorrespondentId: selectedCorrespondentId,
                  allowEmpty: true,
                  onChanged: (correspondentId) {
                    selectedCorrespondentId = correspondentId;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Enregistrer'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

// Mise à jour du kiné référent.
    if (selectedPractitionerId == null) {
      if (previousPractitionerId != null) {
        await _referringPractitionerRepository
            .clearCurrentReferringPractitioner(widget.episode.careEpisodeId);
      }
    } else if (selectedPractitionerId != previousPractitionerId) {
      await _referringPractitionerRepository.changeReferringPractitioner(
        careEpisodeId: widget.episode.careEpisodeId,
        practitionerId: selectedPractitionerId!,
      );
    }

// Mise à jour du médecin prescripteur.
    if (selectedCorrespondentId != previousCorrespondentId) {
      await _careEpisodeRepository.updatePrescribingCorrespondent(
        careEpisodeId: widget.episode.careEpisodeId,
        correspondentId: selectedCorrespondentId,
      );
    }

    if (!mounted) return;

    setState(() {
      _currentReferringPractitionerFuture = _loadCurrentReferringPractitioner();

      _prescribingCorrespondentFuture =
      selectedCorrespondentId == null
          ? Future<ExternalCorrespondent?>.value(null)
          : _externalCorrespondentRepository.getById(
        selectedCorrespondentId!,
      );
    });
  }

  void _openEpisodeDocuments() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EpisodeDocumentsScreen(
          caseId: widget.episode.careEpisodeId,
          caseLabel: '${widget.patientName} — ${widget.episode.pathologyLabel}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('${widget.patientName} — Bilans et rapports'),
          actions: [
            ContextHelpButton(
              title: 'Bilans et rapports',
              content:
              'Cet écran permet de préparer et d’enregistrer les bilans et rapports liés à la prise en charge.\n\n'
                  'Pour un bilan, vous pouvez rédiger le texte principal, sélectionner les résultats de tests et les notes de suivi à inclure, puis générer un document DOCX une fois le bilan enregistré.\n\n'
                  'Les brouillons sont sauvegardés automatiquement tant qu’ils ne sont pas enregistrés comme bilan ou rapport.\n\n'
                  'L’historique permet de retrouver les bilans et rapports déjà enregistrés.',
              technicalInformationLabel: 'Comprendre l’écran',
              iconSize: 20,
            ),
            const SizedBox(width: 8),
          ],
        ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            EpisodeHeader(
              episode: widget.episode,
              practitionerFuture: _currentReferringPractitionerFuture,
              prescribingCorrespondentFuture: _prescribingCorrespondentFuture,
              onEditPractitioner: _editReferringPractitioner,
              onShowHistory: () {
                showDialog<void>(
                  context: context,
                  builder: (_) => ReferringPractitionerHistoryDialog(
                    careEpisodeId: widget.episode.careEpisodeId,
                  ),
                );
              },
              onOpenDocuments: _openEpisodeDocuments,
            ),

            const SizedBox(height: 12),

            Expanded(
              child: Column(
                children: [
                  Expanded(
                    flex: 7,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: [
                              Expanded(
                                child: SoapDraftCard(
                                  controller: _draftController,
                                  focusNode: _draftFocusNode,
                                  loading: _draftLoading,
                                  loadError: _draftLoadError,
                                  draftReady:
                                  _documentType ==
                                      ClinicalDocumentType.assessment
                                      ? _draft != null
                                      : _reportDraft != null,
                                  onExpand: _openExpandedSoapEditor,
                                  isEditing:
                                  _documentType ==
                                      ClinicalDocumentType.assessment
                                      ? _draft?.isSaved == true
                                      : _reportDraft?.isSaved == true,
                                  documentType: _documentType,
                                  documentTypeSelected: _documentTypeSelected,
                                  onOpenTemplateGuide:
                                  _openAssessmentTemplateGuide,
                                  documentTitle:
                                  _documentType ==
                                      ClinicalDocumentType.assessment
                                      ? _draft?.title
                                      : _reportDraft?.title,
                                  documentAuthorFuture:
                                  _documentType == ClinicalDocumentType.assessment
                                      ? (_draft != null
                                      ? _loadAssessmentAuthor(_draft!)
                                      : null)
                                      : (_reportDraft != null
                                      ? _loadReportAuthor(_reportDraft!)
                                      : null),
                                  onDocumentAuthorPressed:
                                  _documentType == ClinicalDocumentType.assessment
                                      ? _selectAssessmentAuthor
                                      : _selectReportAuthor,
                                  assessmentRecipientText:
                                  _documentType ==
                                      ClinicalDocumentType.assessment
                                      ? _draft?.recipientText
                                      : null,
                                  onAssessmentRecipientPressed:
                                  _editAssessmentRecipient,
                                  onDocumentTypeChanged: (documentType) async {
                                    switch (documentType) {
                                      case ClinicalDocumentType.assessment:
                                        await _returnToDraft();

                                      case ClinicalDocumentType.report:
                                        await _createOrOpenReportDraft();
                                    }
                                  },
                                ),
                              ),

                              const SizedBox(height: 8),

                              if (_documentType ==
                                  ClinicalDocumentType.assessment &&
                                  _draft?.isSaved == true)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Votre bilan est prêt. Le DOCX regroupera les informations '
                                              'saisies et les éléments sélectionnés.',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      FilledButton.icon(
                                        onPressed: _exportAssessmentDocx,
                                        icon: const Icon(
                                          Icons.description_outlined,
                                        ),
                                        label: const Text('Générer le DOCX'),
                                      ),
                                    ],
                                  ),
                                ),

                              if (_documentType ==
                                  ClinicalDocumentType.report &&
                                  _reportDraft?.isSaved == true)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          'Votre rapport est prêt. Le DOCX regroupera les informations '
                                              'du patient, du rédacteur et du correspondant.',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      FilledButton.icon(
                                        onPressed: _exportReportDocx,
                                        icon: const Icon(
                                          Icons.description_outlined,
                                        ),
                                        label: const Text('Générer le DOCX'),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: LatestTestsCard(
                                  resultsFuture: _resultsFuture,
                                  selectedTestExoIds: _selectedTestExoIds,
                                  selectionEnabled:
                                  ((_documentType == ClinicalDocumentType.assessment &&
                                      _draft != null) ||
                                      (_documentType == ClinicalDocumentType.report &&
                                          _reportDraft != null)) &&
                                      !_testSelectionLoading,
                                  onExpand: () {
                                    _showExpandedWorkspaceContent(
                                      title: 'Tests réalisés',
                                      child: StatefulBuilder(
                                        builder:
                                            (dialogContext, setDialogState) {
                                              return LatestTestsCard(
                                                resultsFuture: _resultsFuture,
                                                selectedTestExoIds:
                                                    _selectedTestExoIds,
                                                selectionEnabled:
                                                ((_documentType == ClinicalDocumentType.assessment &&
                                                    _draft != null) ||
                                                    (_documentType == ClinicalDocumentType.report &&
                                                        _reportDraft != null)) &&
                                                    !_testSelectionLoading,
                                                onExpand: null,
                                                onTestIncludedChanged:
                                                    ({
                                                      required exoId,
                                                      required included,
                                                    }) async {
                                                      await _setTestIncluded(
                                                        exoId: exoId,
                                                        included: included,
                                                      );

                                                      if (!dialogContext
                                                          .mounted) {
                                                        return;
                                                      }

                                                      setDialogState(() {});
                                                    },
                                              );
                                            },
                                      ),
                                    );
                                  },
                                  onTestIncludedChanged:
                                      ({required exoId, required included}) {
                                        _setTestIncluded(
                                          exoId: exoId,
                                          included: included,
                                        );
                                      },
                                ),
                              ),

                              const SizedBox(height: 12),

                              Expanded(
                                child: AssessmentHistoryCard(
                                  assessmentsFuture: _assessmentsFuture,
                                  isEditing:
                                      _documentType ==
                                          ClinicalDocumentType.assessment &&
                                      _draft?.isSaved == true,
                                  showOpenAssessmentAction:
                                      _documentType ==
                                      ClinicalDocumentType.report,
                                  onOpenAssessmentPressed: _returnToDraft,
                                  onSaveOrUpdatePressed:
                                      _documentType ==
                                              ClinicalDocumentType.assessment &&
                                          _draft != null
                                      ? _saveOrUpdateAssessment
                                      : null,
                                  onCancelChangesPressed:
                                      _documentType ==
                                              ClinicalDocumentType.assessment &&
                                          _draft?.isSaved == true
                                      ? _cancelAssessmentChanges
                                      : null,
                                  onReturnToDraftPressed:
                                      _documentType ==
                                              ClinicalDocumentType.assessment &&
                                          _draft?.isSaved == true
                                      ? _returnToDraft
                                      : null,
                                  onEditAssessment: _editAssessment,
                                  onDuplicateAssessment: _duplicateAssessment,
                                  onArchiveAssessment: _archiveAssessment,
                                  onExpand: () {
                                    _showExpandedWorkspaceContent(
                                      title: 'Historique des bilans',
                                      child: AssessmentHistoryCard(
                                        assessmentsFuture: _assessmentsFuture,
                                        isEditing:
                                            _documentType ==
                                                ClinicalDocumentType
                                                    .assessment &&
                                            _draft?.isSaved == true,
                                        showOpenAssessmentAction:
                                            _documentType ==
                                            ClinicalDocumentType.report,
                                        onOpenAssessmentPressed: _returnToDraft,
                                        onSaveOrUpdatePressed:
                                            _documentType ==
                                                    ClinicalDocumentType
                                                        .assessment &&
                                                _draft != null
                                            ? _saveOrUpdateAssessment
                                            : null,
                                        onCancelChangesPressed:
                                            _documentType ==
                                                    ClinicalDocumentType
                                                        .assessment &&
                                                _draft?.isSaved == true
                                            ? _cancelAssessmentChanges
                                            : null,
                                        onReturnToDraftPressed:
                                            _documentType ==
                                                    ClinicalDocumentType
                                                        .assessment &&
                                                _draft?.isSaved == true
                                            ? _returnToDraft
                                            : null,
                                        onEditAssessment: _editAssessment,
                                        onDuplicateAssessment:
                                            _duplicateAssessment,
                                        onArchiveAssessment: _archiveAssessment,
                                        onExpand: null,
                                      ),
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(height: 12),

                              Expanded(
                                child: ReportHistoryCard(
                                  reportsFuture: _reportsFuture,
                                  isEditingReport:
                                      _documentType ==
                                          ClinicalDocumentType.report &&
                                      _reportDraft?.isSaved == true,
                                  onCreateReportPressed:
                                      _documentType ==
                                              ClinicalDocumentType.report &&
                                          _reportDraft?.isSaved == true
                                      ? _returnToReportDraft
                                      : _createOrOpenReportDraft,
                                  onSaveReportPressed:
                                      _documentType ==
                                              ClinicalDocumentType.report &&
                                          _reportDraft != null
                                      ? _saveReport
                                      : null,
                                  onCancelReportChangesPressed:
                                      _documentType ==
                                              ClinicalDocumentType.report &&
                                          _reportDraft?.isSaved == true
                                      ? _cancelReportChanges
                                      : null,
                                  onEditReport: _editReport,
                                  onDuplicateReport: _duplicateReport,
                                  onArchiveReport: _archiveReport,
                                  onExpand: () {
                                    _showExpandedWorkspaceContent(
                                      title: 'Historique des rapports',
                                      child: ReportHistoryCard(
                                        reportsFuture: _reportsFuture,
                                        isEditingReport:
                                            _documentType ==
                                                ClinicalDocumentType.report &&
                                            _reportDraft?.isSaved == true,
                                        onCreateReportPressed:
                                            _documentType ==
                                                    ClinicalDocumentType
                                                        .report &&
                                                _reportDraft?.isSaved == true
                                            ? _returnToReportDraft
                                            : _createOrOpenReportDraft,
                                        onSaveReportPressed:
                                            _documentType ==
                                                    ClinicalDocumentType
                                                        .report &&
                                                _reportDraft != null
                                            ? _saveReport
                                            : null,
                                        onCancelReportChangesPressed:
                                            _documentType ==
                                                    ClinicalDocumentType
                                                        .report &&
                                                _reportDraft?.isSaved == true
                                            ? _cancelReportChanges
                                            : null,
                                        onEditReport: _editReport,
                                        onDuplicateReport: _duplicateReport,
                                        onArchiveReport: (report) async {
                                          final navigator = Navigator.of(
                                            context,
                                          );

                                          await _archiveReport(report);

                                          if (!mounted) return;

                                          navigator.pop();
                                        },
                                        onExpand: null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Expanded(
                    flex: 3,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          flex: 4,
                          child: FollowUpNotesCard(
                            notesFuture: _notesFuture,
                            selectedNoteIds: _selectedNoteIds,
                            selectionEnabled:
                            ((_documentType == ClinicalDocumentType.assessment &&
                                _draft != null) ||
                                (_documentType == ClinicalDocumentType.report &&
                                    _reportDraft != null)) &&
                                !_noteSelectionLoading,
                            onAddNote: _addFollowUpNote,
                            onEditNote: _editFollowUpNote,
                            onExpand: () {
                              _showExpandedWorkspaceContent(
                                title: 'Notes de suivi',
                                child: FollowUpNotesCard(
                                  notesFuture: _notesFuture,
                                  selectedNoteIds: _selectedNoteIds,
                                  selectionEnabled:
                                  ((_documentType == ClinicalDocumentType.assessment &&
                                      _draft != null) ||
                                      (_documentType == ClinicalDocumentType.report &&
                                          _reportDraft != null)) &&
                                      !_noteSelectionLoading,
                                  onAddNote: () async {
                                    final navigator = Navigator.of(context);

                                    await _addFollowUpNote();

                                    if (!mounted) return;

                                    navigator.pop();
                                  },
                                  onEditNote: _editFollowUpNote,
                                  onExpand: null,
                                  onNoteIncludedChanged:
                                      ({required noteId, required included}) {
                                        _setNoteIncluded(
                                          noteId: noteId,
                                          included: included,
                                        );
                                      },
                                ),
                              );
                            },
                            onNoteIncludedChanged:
                                ({required noteId, required included}) {
                                  _setNoteIncluded(
                                    noteId: noteId,
                                    included: included,
                                  );
                                },
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          flex: 2,
                          child: ArchivedDocumentsCard(
                            archivedAssessmentsFuture:
                                _archivedAssessmentsFuture,
                            archivedReportsFuture: _archivedReportsFuture,
                            onRestoreAssessment: _restoreAssessment,
                            onRestoreReport: _restoreReport,
                            onDeleteAssessment: _deleteAssessmentPermanently,
                            onDeleteReport: _deleteReportPermanently,
                            onExpand: () {
                              _showExpandedWorkspaceContent(
                                title: 'Documents archivés',
                                child: ArchivedDocumentsCard(
                                  archivedAssessmentsFuture:
                                      _archivedAssessmentsFuture,
                                  archivedReportsFuture: _archivedReportsFuture,
                                  onRestoreAssessment: (assessment) async {
                                    final navigator = Navigator.of(context);

                                    await _restoreAssessment(assessment);

                                    if (!mounted) return;

                                    navigator.pop();
                                  },
                                  onRestoreReport: (report) async {
                                    final navigator = Navigator.of(context);

                                    await _restoreReport(report);

                                    if (!mounted) return;

                                    navigator.pop();
                                  },
                                  onDeleteAssessment: (assessment) async {
                                    final navigator = Navigator.of(context);

                                    await _deleteAssessmentPermanently(
                                      assessment,
                                    );

                                    if (!mounted) return;

                                    navigator.pop();
                                  },
                                  onDeleteReport: (report) async {
                                    final navigator = Navigator.of(context);

                                    await _deleteReportPermanently(report);

                                    if (!mounted) return;

                                    navigator.pop();
                                  },
                                  onExpand: null,
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 16),

                        Expanded(
                          flex: 4,
                          child: EpisodeSummaryCard(
                            resultsFuture: _resultsFuture,
                            assessmentsFuture: _assessmentsFuture,
                            reportsFuture: _reportsFuture,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

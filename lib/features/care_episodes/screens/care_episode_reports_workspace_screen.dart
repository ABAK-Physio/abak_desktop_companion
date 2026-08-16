import 'dart:async';

import 'package:abak_shared/abak_shared.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../results/data/desktop_result_repository.dart';
import '../../results/models/desktop_result.dart';
import '../../results/result_detail_screen.dart';
import '../data/care_episode_assessment_repository.dart';
import '../data/care_episode_repository.dart';
import '../data/care_episode_report_repository.dart';
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

import '../../../core/speech/speech_dictation_button.dart';
import '../data/care_episode_document_edit_draft_repository.dart';

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
  final CareEpisodeRepository _careEpisodeRepository =
  CareEpisodeRepository();
  final CareEpisodeAssessmentRepository _assessmentRepository =
  CareEpisodeAssessmentRepository();
  final CareEpisodeReportRepository _reportRepository =
  CareEpisodeReportRepository();

  final CareEpisodeDocumentEditDraftRepository
  _documentEditDraftRepository =
  CareEpisodeDocumentEditDraftRepository();

  final TextEditingController _draftController = TextEditingController();
  final FocusNode _draftFocusNode = FocusNode();

  final CareEpisodeReferringPractitionerRepository
  _referringPractitionerRepository =
  CareEpisodeReferringPractitionerRepository();

  final PractitionerRepository _practitionerRepository =
  PractitionerRepository();

  late Future<Practitioner?> _currentReferringPractitionerFuture;

  Timer? _draftSaveTimer;
  bool _updatingDraftController = false;

  late Future<List<DesktopResult>> _resultsFuture;
  late Future<List<CareEpisodeNote>> _notesFuture;
  late Future<List<CareEpisodeAssessment>> _assessmentsFuture;
  late Future<List<CareEpisodeReport>> _reportsFuture;
  late Future<List<CareEpisodeAssessment>> _archivedAssessmentsFuture;
  late Future<List<CareEpisodeReport>> _archivedReportsFuture;

  ClinicalDocumentType _documentType =
      ClinicalDocumentType.assessment;

  CareEpisodeAssessment? _draft;
  CareEpisodeReport? _reportDraft;
  Set<String> _selectedTestExoIds = <String>{};
  Set<String> _selectedNoteIds = <String>{};
  bool _draftLoading = true;
  bool _testSelectionLoading = true;
  bool _noteSelectionLoading = true;
  String? _draftLoadError;

  @override
  void initState() {
    super.initState();

    _currentReferringPractitionerFuture =
        _loadCurrentReferringPractitioner();

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

    _archivedAssessmentsFuture =
        _assessmentRepository.getArchivedForEpisode(
          widget.episode.careEpisodeId,
        );

    _archivedReportsFuture = _reportRepository.getArchivedForEpisode(
      widget.episode.careEpisodeId,
    );

    _draftController.addListener(_scheduleDraftSave);
    _loadOrCreateDraft();
  }


  Future<void> _loadOrCreateDraft() async {
    try {
      var draft = await _assessmentRepository.getDraftForEpisode(
        widget.episode.careEpisodeId,
      );

      if (draft == null) {
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
      }

      final selectedTestExoIds =
      await _assessmentRepository.getSelectedTestExoIds(
        draft.assessmentId,
      );

      final selectedNoteIds =
      await _assessmentRepository.getSelectedNoteIds(
        draft.assessmentId,
      );

      if (!mounted) return;

      _setDraftContent(draft.contentJson);

      setState(() {
        _draft = draft;
        _selectedTestExoIds = selectedTestExoIds;
        _selectedNoteIds = selectedNoteIds;
        _draftLoading = false;
        _testSelectionLoading = false;
        _noteSelectionLoading = false;
        _draftLoadError = null;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _draftLoading = false;
        _testSelectionLoading = false;
        _noteSelectionLoading = false;
        _draftLoadError = 'Impossible de charger le brouillon.';
      });
    }
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
          assessment.isDraft
              ? _saveDraft
              : _saveAssessmentEditDraft,
        );

      case ClinicalDocumentType.report:
        final report = _reportDraft;

        if (report == null) {
          return;
        }

        _draftSaveTimer?.cancel();
        _draftSaveTimer = Timer(
          const Duration(seconds: 1),
          report.isDraft
              ? _saveReportDraft
              : _saveReportEditDraft,
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
      assessmentDate: draft.assessmentDate,
      createdAt: draft.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      archivedAt: draft.archivedAt,
    );

    await _assessmentRepository.updateAssessment(updatedDraft);

    if (!mounted) return;

    _draft = updatedDraft;
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

    if (_documentType == ClinicalDocumentType.assessment) {
      await _saveDraft();
    } else {
      await _saveReportDraft();
    }

    if (!mounted) return;

    try {
      final report = await _getOrCreateReportDraft();

      if (!mounted) return;

      setState(() {
        _documentType = ClinicalDocumentType.report;
        _reportDraft = report;
        _draftLoadError = null;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _setDraftContent(report.contentJson);
        _draftFocusNode.requestFocus();
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible d’ouvrir le brouillon du rapport.',
          ),
        ),
      );
    }
  }

  Future<void> _showReport(
      CareEpisodeReport report, {
        String? contentOverride,
      }) async {
    if (!mounted) return;

    setState(() {
      _documentType = ClinicalDocumentType.report;
      _reportDraft = report;
      _draftLoadError = null;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _setDraftContent(
        contentOverride ?? report.contentJson,
      );
      _draftFocusNode.requestFocus();
    });
  }

  Future<void> _editReport(
      CareEpisodeReport report,
      ) async {
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
          const SnackBar(
            content: Text('Le rapport est introuvable.'),
          ),
        );
        return;
      }

      final editDraftContent =
      await _documentEditDraftRepository.getContent(
        documentType: 'report',
        documentId: reloadedReport.reportId,
      );

      if (!mounted) return;

      await _showReport(
        reloadedReport,
        contentOverride: editDraftContent,
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’ouvrir le rapport.'),
        ),
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
          content: Text(
            'Impossible de revenir au brouillon du rapport.',
          ),
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
          const SnackBar(
            content: Text('Le rapport est introuvable.'),
          ),
        );
        return;
      }

      await _showReport(reloadedReport);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible d’annuler les modifications du rapport.',
          ),
        ),
      );
    }
  }

  Future<void> _editAssessment(
      CareEpisodeAssessment assessment,
      ) async {
    _draftSaveTimer?.cancel();

    final currentAssessment = _draft;

    if (currentAssessment != null) {
      await _saveDraft();
    }

    if (!mounted) return;

    final reloadedAssessment =
    await _assessmentRepository.getAssessmentById(
      assessment.assessmentId,
    );

    if (!mounted) return;

    if (reloadedAssessment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le bilan est introuvable.'),
        ),
      );
      return;
    }

    final selectedTestExoIds =
    await _assessmentRepository.getSelectedTestExoIds(
      reloadedAssessment.assessmentId,
    );

    final selectedNoteIds =
    await _assessmentRepository.getSelectedNoteIds(
      reloadedAssessment.assessmentId,
    );

    final editDraftContent =
    await _documentEditDraftRepository.getContent(
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

      _setDraftContent(
        editDraftContent ?? reloadedAssessment.contentJson,
      );
      _draftFocusNode.requestFocus();
    });
  }

  Future<void> _duplicateAssessment(
      CareEpisodeAssessment assessment,
      ) async {
    _draftSaveTimer?.cancel();

    try {
      final draft = await _getOrCreateDraft();

      if (!mounted) return;

      if (draft.contentJson.trim().isNotEmpty) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Remplacer le brouillon ?'),
              content: const Text(
                'Le brouillon actuel contient déjà du texte. '
                    'La duplication remplacera son contenu.',
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(false),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(true),
                  child: const Text('Dupliquer'),
                ),
              ],
            );
          },
        );

        if (confirmed != true) {
          return;
        }
      }

      final updatedDraft = CareEpisodeAssessment(
        assessmentId: draft.assessmentId,
        careEpisodeId: draft.careEpisodeId,
        title: '',
        contentJson: assessment.contentJson,
        status: 'draft',
        assessmentDate: draft.assessmentDate,
        createdAt: draft.createdAt,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        archivedAt: draft.archivedAt,
      );

      await _assessmentRepository.updateAssessment(updatedDraft);

      if (!mounted) return;

      await _showAssessment(updatedDraft);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de dupliquer le bilan.',
          ),
        ),
      );
    }
  }

  Future<void> _duplicateReport(
      CareEpisodeReport report,
      ) async {
    _draftSaveTimer?.cancel();

    try {
      final draft = await _getOrCreateReportDraft();

      if (!mounted) return;

      if (draft.contentJson.trim().isNotEmpty) {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Remplacer le brouillon ?'),
              content: const Text(
                'Le brouillon actuel contient déjà du texte. '
                    'La duplication remplacera son contenu.',
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(false),
                  child: const Text('Annuler'),
                ),
                FilledButton(
                  onPressed: () =>
                      Navigator.of(dialogContext).pop(true),
                  child: const Text('Dupliquer'),
                ),
              ],
            );
          },
        );

        if (confirmed != true) {
          return;
        }
      }

      final updatedDraft = CareEpisodeReport(
        reportId: draft.reportId,
        careEpisodeId: draft.careEpisodeId,
        sourceAssessmentId: report.sourceAssessmentId,
        title: '',
        contentJson: report.contentJson,
        status: 'draft',
        reportDate: draft.reportDate,
        createdAt: draft.createdAt,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        archivedAt: draft.archivedAt,
      );

      await _reportRepository.updateReport(updatedDraft);

      if (!mounted) return;

      await _showReport(updatedDraft);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de dupliquer le rapport.',
          ),
        ),
      );
    }
  }

  Future<void> _setTestIncluded({
    required String exoId,
    required bool included,
  }) async {
    final assessment = _draft;

    if (assessment == null || _testSelectionLoading) {
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

    if (assessment.isSaved) {
      return;
    }

    try {
      await _assessmentRepository.setTestIncluded(
        assessmentId: assessment.assessmentId,
        exoId: exoId,
        included: included,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _selectedTestExoIds = previousSelection;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible d’enregistrer la sélection du test.',
          ),
        ),
      );
    }
  }

  Future<void> _setNoteIncluded({
    required String noteId,
    required bool included,
  }) async {
    final assessment = _draft;

    if (assessment == null || _noteSelectionLoading) {
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

    if (assessment.isSaved) {
      return;
    }

    try {
      await _assessmentRepository.setNoteIncluded(
        assessmentId: assessment.assessmentId,
        noteId: noteId,
        included: included,
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _selectedNoteIds = previousSelection;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible d’enregistrer la sélection de la note.',
          ),
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

  Future<void> _showAssessment(
      CareEpisodeAssessment assessment,
      ) async {
    final selectedTestExoIds =
    await _assessmentRepository.getSelectedTestExoIds(
      assessment.assessmentId,
    );

    final selectedNoteIds =
    await _assessmentRepository.getSelectedNoteIds(
      assessment.assessmentId,
    );

    if (!mounted) return;

    setState(() {
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
      await _showAssessment(draft);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de revenir au brouillon.'),
        ),
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
      final reloadedAssessment =
      await _assessmentRepository.getAssessmentById(
        assessment.assessmentId,
      );

      if (reloadedAssessment == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Le bilan est introuvable.'),
          ),
        );
        return;
      }

      await _showAssessment(reloadedAssessment);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible d’annuler les modifications.',
          ),
        ),
      );
    }
  }

  Future<void> _archiveAssessment(
      CareEpisodeAssessment assessment,
      ) async {
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
      await _assessmentRepository.archiveAssessment(
        assessment.assessmentId,
      );

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
        _archivedAssessmentsFuture =
            _assessmentRepository.getArchivedForEpisode(
              widget.episode.careEpisodeId,
            );
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

  Future<void> _archiveReport(
      CareEpisodeReport report,
      ) async {
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
        _archivedReportsFuture =
            _reportRepository.getArchivedForEpisode(
              widget.episode.careEpisodeId,
            );
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de mettre le rapport à la corbeille.',
          ),
        ),
      );
    }
  }

  Future<void> _restoreAssessment(
      CareEpisodeAssessment assessment,
      ) async {
    try {
      await _assessmentRepository.restoreAssessment(
        assessment.assessmentId,
      );

      if (!mounted) return;

      setState(() {
        _assessmentsFuture = _assessmentRepository.getSavedForEpisode(
          widget.episode.careEpisodeId,
        );
        _archivedAssessmentsFuture =
            _assessmentRepository.getArchivedForEpisode(
              widget.episode.careEpisodeId,
            );
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de restaurer le bilan.'),
        ),
      );
    }
  }

  Future<void> _restoreReport(
      CareEpisodeReport report,
      ) async {
    try {
      await _reportRepository.restoreReport(
        report.reportId,
      );

      if (!mounted) return;

      setState(() {
        _reportsFuture = _reportRepository.getSavedForEpisode(
          widget.episode.careEpisodeId,
        );
        _archivedReportsFuture =
            _reportRepository.getArchivedForEpisode(
              widget.episode.careEpisodeId,
            );
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible de restaurer le rapport.'),
        ),
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
      await _assessmentRepository.deleteAssessment(
        assessment.assessmentId,
      );

      if (!mounted) return;

      setState(() {
        _archivedAssessmentsFuture =
            _assessmentRepository.getArchivedForEpisode(
              widget.episode.careEpisodeId,
            );
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de supprimer définitivement le bilan.',
          ),
        ),
      );
    }
  }

  Future<void> _deleteReportPermanently(
      CareEpisodeReport report,
      ) async {
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
      await _reportRepository.deleteReport(
        report.reportId,
      );

      if (!mounted) return;

      setState(() {
        _archivedReportsFuture =
            _reportRepository.getArchivedForEpisode(
              widget.episode.careEpisodeId,
            );
      });
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de supprimer définitivement le rapport.',
          ),
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
        return _DocumentTitleDialog(
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
      dialogTitle:
      isEditing ? 'Mettre à jour le bilan' : 'Enregistrer le bilan',
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
      assessmentDate:
      isEditing ? assessment.assessmentDate : now,
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
      dialogTitle:
      isEditing ? 'Mettre à jour le rapport' : 'Enregistrer le rapport',
      fieldLabel: 'Titre du rapport',
      actionLabel: isEditing ? 'Mettre à jour' : 'Enregistrer',
      initialTitle: isEditing ? report.title : '',
    );

    if (title == null) {
      return;
    }

    _draftSaveTimer?.cancel();

    final now = DateTime.now().millisecondsSinceEpoch;

    final savedReport = CareEpisodeReport(
      reportId: report.reportId,
      careEpisodeId: report.careEpisodeId,
      sourceAssessmentId: report.sourceAssessmentId,
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
    final controller = TextEditingController();

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
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

    final content = controller.text.trim();
    controller.dispose();

    if (confirmed != true || content.isEmpty) {
      return;
    }

    final now = DateTime.now().millisecondsSinceEpoch;

    final note = CareEpisodeNote(
      noteId: const Uuid().v4(),
      careEpisodeId: widget.episode.careEpisodeId,
      noteDate: now,
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
                          style: Theme.of(
                            dialogContext,
                          ).textTheme.titleLarge,
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
                      enabled:
                      _documentType == ClinicalDocumentType.assessment
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
                          style: Theme.of(
                            dialogContext,
                          ).textTheme.titleLarge,
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
    super.dispose();
  }

  Future<Practitioner?> _loadCurrentReferringPractitioner() async {
    final assignment = await _referringPractitionerRepository
        .getCurrentReferringPractitioner(
      widget.episode.careEpisodeId,
    );

    if (assignment == null) {
      return null;
    }

    return _practitionerRepository.getPractitionerById(
      assignment.practitionerId,
    );
  }

  Future<void> _editReferringPractitioner() async {
    final currentAssignment = await _referringPractitionerRepository
        .getCurrentReferringPractitioner(
      widget.episode.careEpisodeId,
    );

    if (!mounted) return;

    final previousPractitionerId = currentAssignment?.practitionerId;
    String? selectedPractitionerId = previousPractitionerId;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Modifier le kiné référent'),
          content: SizedBox(
            width: 480,
            child: PractitionerSelector(
              label: 'Kiné référent',
              selectedPractitionerId: selectedPractitionerId,
              allowEmpty: true,
              onChanged: (practitionerId) {
                selectedPractitionerId = practitionerId;
              },
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

    if (selectedPractitionerId == null) {
      if (previousPractitionerId != null) {
        await _referringPractitionerRepository
            .clearCurrentReferringPractitioner(
          widget.episode.careEpisodeId,
        );
      }
    } else if (selectedPractitionerId != previousPractitionerId) {
      await _referringPractitionerRepository
          .changeReferringPractitioner(
        careEpisodeId: widget.episode.careEpisodeId,
        practitionerId: selectedPractitionerId!,
      );
    }

    if (!mounted) return;

    setState(() {
      _currentReferringPractitionerFuture =
          _loadCurrentReferringPractitioner();
    });
  }

  void _openEpisodeDocuments() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EpisodeDocumentsScreen(
          caseId: widget.episode.careEpisodeId,
          caseLabel:
          '${widget.patientName} — ${widget.episode.pathologyLabel}',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.patientName} — Bilans et rapports'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _EpisodeHeader(
              episode: widget.episode,
              practitionerFuture: _currentReferringPractitionerFuture,
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
                          child: _SoapDraftCard(
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
                                : true,
                            documentType: _documentType,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            children: [
                              Expanded(
                                child: _LatestTestsCard(
                                  resultsFuture: _resultsFuture,
                                  selectedTestExoIds: _selectedTestExoIds,
                                  selectionEnabled:
                                  _documentType == ClinicalDocumentType.assessment &&
                                      _draft != null &&
                                      !_testSelectionLoading,
                                  onExpand: () {
                                    _showExpandedWorkspaceContent(
                                      title: 'Tests réalisés',
                                      child: _LatestTestsCard(
                                        resultsFuture: _resultsFuture,
                                        selectedTestExoIds: _selectedTestExoIds,
                                        selectionEnabled:
                                        _documentType == ClinicalDocumentType.assessment &&
                                            _draft != null &&
                                            !_testSelectionLoading,
                                        onExpand: null,
                                        onTestIncludedChanged: ({
                                          required exoId,
                                          required included,
                                        }) {
                                          _setTestIncluded(
                                            exoId: exoId,
                                            included: included,
                                          );
                                        },
                                      ),
                                    );
                                  },
                                  onTestIncludedChanged: ({
                                    required exoId,
                                    required included,
                                  }) {
                                    _setTestIncluded(
                                      exoId: exoId,
                                      included: included,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                child: _AssessmentHistoryCard(
                                  assessmentsFuture: _assessmentsFuture,
                                  isEditing:
                                  _documentType == ClinicalDocumentType.assessment &&
                                      _draft?.isSaved == true,
                                  showOpenAssessmentAction:
                                  _documentType == ClinicalDocumentType.report,
                                  onOpenAssessmentPressed: _returnToDraft,
                                  onSaveOrUpdatePressed:
                                  _documentType == ClinicalDocumentType.assessment &&
                                      _draft != null
                                      ? _saveOrUpdateAssessment
                                      : null,
                                  onCancelChangesPressed:
                                  _documentType == ClinicalDocumentType.assessment &&
                                      _draft?.isSaved == true
                                      ? _cancelAssessmentChanges
                                      : null,
                                  onReturnToDraftPressed:
                                  _documentType == ClinicalDocumentType.assessment &&
                                      _draft?.isSaved == true
                                      ? _returnToDraft
                                      : null,onEditAssessment: _editAssessment,
                                  onDuplicateAssessment: _duplicateAssessment,
                                  onArchiveAssessment: _archiveAssessment,
                                  onExpand: () {
                                    _showExpandedWorkspaceContent(
                                      title: 'Historique des bilans',
                                      child: _AssessmentHistoryCard(
                                        assessmentsFuture: _assessmentsFuture,
                                        isEditing:
                                        _documentType == ClinicalDocumentType.assessment &&
                                            _draft?.isSaved == true,
                                        showOpenAssessmentAction:
                                        _documentType == ClinicalDocumentType.report,
                                        onOpenAssessmentPressed: _returnToDraft,
                                        onSaveOrUpdatePressed:
                                        _documentType == ClinicalDocumentType.assessment &&
                                            _draft != null
                                            ? _saveOrUpdateAssessment
                                            : null,
                                        onCancelChangesPressed:
                                        _documentType == ClinicalDocumentType.assessment &&
                                            _draft?.isSaved == true
                                            ? _cancelAssessmentChanges
                                            : null,
                                        onReturnToDraftPressed:
                                        _documentType == ClinicalDocumentType.assessment &&
                                            _draft?.isSaved == true
                                            ? _returnToDraft
                                            : null,
                                          onEditAssessment: _editAssessment,
                                          onDuplicateAssessment: _duplicateAssessment,
                                          onArchiveAssessment: _archiveAssessment,
                                        onExpand: null,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: 12),
                              Expanded(
                                  child: _ReportHistoryCard(
                                    reportsFuture: _reportsFuture,
                                    isEditingReport:
                                    _documentType == ClinicalDocumentType.report &&
                                        _reportDraft?.isSaved == true,
                                    onCreateReportPressed:
                                    _documentType == ClinicalDocumentType.report &&
                                        _reportDraft?.isSaved == true
                                        ? _returnToReportDraft
                                        : _createOrOpenReportDraft,
                                    onSaveReportPressed:
                                    _documentType == ClinicalDocumentType.report &&
                                        _reportDraft != null
                                        ? _saveReport
                                        : null,
                                    onCancelReportChangesPressed:
                                    _documentType == ClinicalDocumentType.report &&
                                        _reportDraft?.isSaved == true
                                        ? _cancelReportChanges
                                        : null,
                                    onEditReport: _editReport,
                                    onDuplicateReport: _duplicateReport,
                                    onArchiveReport: _archiveReport,
                                    onExpand: () {
                                      _showExpandedWorkspaceContent(
                                        title: 'Historique des rapports',
                                        child: _ReportHistoryCard(
                                          reportsFuture: _reportsFuture,
                                          isEditingReport:
                                          _documentType == ClinicalDocumentType.report &&
                                              _reportDraft?.isSaved == true,
                                          onCreateReportPressed:
                                          _documentType == ClinicalDocumentType.report &&
                                              _reportDraft?.isSaved == true
                                              ? _returnToReportDraft
                                              : _createOrOpenReportDraft,
                                          onSaveReportPressed:
                                          _documentType == ClinicalDocumentType.report &&
                                              _reportDraft != null
                                              ? _saveReport
                                              : null,
                                          onCancelReportChangesPressed:
                                          _documentType == ClinicalDocumentType.report &&
                                              _reportDraft?.isSaved == true
                                              ? _cancelReportChanges
                                              : null,
                                          onEditReport: _editReport,
                                          onDuplicateReport: _duplicateReport,
                                          onArchiveReport: (report) async {
                                            final navigator = Navigator.of(context);

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
                          child: _FollowUpNotesCard(
                            notesFuture: _notesFuture,
                            selectedNoteIds: _selectedNoteIds,
                            selectionEnabled:
                            _documentType == ClinicalDocumentType.assessment &&
                                _draft != null &&
                                !_noteSelectionLoading,
                            onAddNote: _addFollowUpNote,
                            onExpand: () {
                              _showExpandedWorkspaceContent(
                                title: 'Notes de suivi',
                                child: _FollowUpNotesCard(
                                  notesFuture: _notesFuture,
                                  selectedNoteIds: _selectedNoteIds,
                                  selectionEnabled:
                                  _documentType == ClinicalDocumentType.assessment &&
                                      _draft != null &&
                                      !_noteSelectionLoading,
                                  onAddNote: () async {
                                    final navigator = Navigator.of(context);

                                    await _addFollowUpNote();

                                    if (!mounted) return;

                                    navigator.pop();
                                  },
                                  onExpand: null,
                                  onNoteIncludedChanged: ({
                                    required noteId,
                                    required included,
                                  }) {
                                    _setNoteIncluded(
                                      noteId: noteId,
                                      included: included,
                                    );
                                  },
                                ),
                              );
                            },
                            onNoteIncludedChanged: ({
                              required noteId,
                              required included,
                            }) {
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
                          child: _DocumentsCard(
                            archivedAssessmentsFuture: _archivedAssessmentsFuture,
                            archivedReportsFuture: _archivedReportsFuture,
                            onRestoreAssessment: _restoreAssessment,
                            onRestoreReport: _restoreReport,
                            onDeleteAssessment: _deleteAssessmentPermanently,
                            onDeleteReport: _deleteReportPermanently,
                            onExpand: () {
                              _showExpandedWorkspaceContent(
                                title: 'Documents archivés',
                                child: _DocumentsCard(
                                  archivedAssessmentsFuture: _archivedAssessmentsFuture,
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

                                    await _deleteAssessmentPermanently(assessment);

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
                          child: _EpisodeSummaryCard(
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

class _DocumentTitleDialog extends StatefulWidget {
  final String dialogTitle;
  final String fieldLabel;
  final String actionLabel;
  final String initialTitle;

  const _DocumentTitleDialog({
    required this.dialogTitle,
    required this.fieldLabel,
    required this.actionLabel,
    required this.initialTitle,
  });

  @override
  State<_DocumentTitleDialog> createState() =>
      _DocumentTitleDialogState();
}

class _DocumentTitleDialogState extends State<_DocumentTitleDialog> {
  late final TextEditingController _controller;

  bool get _canSave => _controller.text.trim().isNotEmpty;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.initialTitle,
    );
  }

  void _submit() {
    if (!_canSave) {
      return;
    }

    Navigator.of(context).pop(
      _controller.text.trim(),
    );
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.dialogTitle),
      content: SizedBox(
        width: 480,
        child: TextField(
          controller: _controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: widget.fieldLabel,
            border: const OutlineInputBorder(),
          ),
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            setState(() {});
          },
          onSubmitted: (_) => _submit(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _canSave ? _submit : null,
          child: Text(widget.actionLabel),
        ),
      ],
    );
  }
}

class _SoapDraftCard extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool loading;
  final String? loadError;
  final bool draftReady;
  final bool isEditing;
  final ClinicalDocumentType documentType;
  final VoidCallback onExpand;

  const _SoapDraftCard({
    required this.controller,
    required this.focusNode,
    required this.loading,
    required this.loadError,
    required this.draftReady,
    required this.isEditing,
    required this.documentType,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    isEditing
                        ? documentType.editorTitle
                        : documentType == ClinicalDocumentType.assessment
                        ? 'Bilan (nouveau)'
                        : documentType.editorTitle,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                SpeechDictationButton(
                  controller: controller,
                  focusNode: focusNode,
                ),

                IconButton(
                  onPressed: draftReady ? onExpand : null,
                  tooltip: 'Agrandir la zone de rédaction',
                  icon: const Icon(Icons.zoom_out_map),
                ),

                const SizedBox(width: 8),
                SizedBox(
                  width: 240,
                  child: DropdownButtonFormField<String>(
                    initialValue: null,
                    decoration: InputDecoration(
                      labelText: documentType.templateLabel,
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: const [],
                    onChanged: null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: loading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : loadError != null
                  ? Center(
                child: Text(loadError!),
              )
                  : TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: draftReady,
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
    );
  }
}

typedef _TestIncludedChanged = void Function({
required String exoId,
required bool included,
});

class _LatestTestsCard extends StatelessWidget {
  final Future<List<DesktopResult>> resultsFuture;
  final Set<String> selectedTestExoIds;
  final bool selectionEnabled;
  final _TestIncludedChanged onTestIncludedChanged;
  final VoidCallback? onExpand;

  const _LatestTestsCard({
    required this.resultsFuture,
    required this.selectedTestExoIds,
    required this.selectionEnabled,
    required this.onTestIncludedChanged,
    required this.onExpand,
  });

  List<DesktopResult> _latestResultsByTest(List<DesktopResult> results) {
    final sortedResults = [...results]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    final latestByTest = <String, DesktopResult>{};

    for (final result in sortedResults) {
      latestByTest.putIfAbsent(result.exoId, () => result);
    }

    final latestResults = latestByTest.values.toList()
      ..sort(
            (a, b) => ClinicalActivityCatalog.displayLabel(a.exoId).compareTo(
          ClinicalActivityCatalog.displayLabel(b.exoId),
        ),
      );

    return latestResults;
  }

  String _resultLabel(DesktopResult result) {
    if (result.scoreTotal == null) {
      return '—';
    }

    final score = result.scoreTotal!.toStringAsFixed(2);
    final unit = result.measureUnit?.trim();

    if (unit == null || unit.isEmpty) {
      return score;
    }

    return '$score $unit';
  }

  @override
  Widget build(BuildContext context) {
    return _ScrollableWorkspaceCard(
      title: 'Tests réalisés (dernier résultat)',
      trailing: onExpand == null
          ? null
          : IconButton(
        onPressed: onExpand,
        tooltip: 'Agrandir',
        icon: const Icon(Icons.zoom_out_map),
      ),
      child: FutureBuilder<List<DesktopResult>>(
        future: resultsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Impossible de charger les tests.'),
            );
          }

          final latestResults = _latestResultsByTest(snapshot.data ?? []);

          if (latestResults.isEmpty) {
            return const Center(
              child: Text('Aucun test réalisé pour cet épisode.'),
            );
          }

          final formatter = DateFormat.yMd(
            Localizations.localeOf(context).toLanguageTag(),
          );

          return Column(
            children: [
              const _TableHeader(
                columns: [
                  Expanded(flex: 4, child: Text('Test')),
                  Expanded(flex: 2, child: Text('Date')),
                  Expanded(flex: 3, child: Text('Résultat')),
                  SizedBox(width: 72, child: Text('Inclure')),
                ],
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: latestResults.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final result = latestResults[index];
                    final date = DateTime.fromMillisecondsSinceEpoch(
                      result.createdAt,
                    );

                    return InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                ResultDetailScreen(result: result),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 4,
                              child: Text(
                                ClinicalActivityCatalog.displayLabel(
                                  result.exoId,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(formatter.format(date)),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                _resultLabel(result),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(
                              width: 72,
                              child: Center(
                                child: Checkbox(
                                  value: selectedTestExoIds.contains(
                                    result.exoId,
                                  ),
                                  onChanged: selectionEnabled
                                      ? (value) {
                                    onTestIncludedChanged(
                                      exoId: result.exoId,
                                      included: value ?? false,
                                    );
                                  }
                                      : null,
                                ),
                              ),
                            ),
                          ],
                        ),
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

class _AssessmentHistoryCard extends StatelessWidget {
  final Future<List<CareEpisodeAssessment>> assessmentsFuture;
  final bool isEditing;
  final bool showOpenAssessmentAction;
  final VoidCallback onOpenAssessmentPressed;
  final VoidCallback? onSaveOrUpdatePressed;
  final VoidCallback? onCancelChangesPressed;
  final VoidCallback? onReturnToDraftPressed;
  final ValueChanged<CareEpisodeAssessment> onEditAssessment;
  final ValueChanged<CareEpisodeAssessment> onArchiveAssessment;
  final VoidCallback? onExpand;
  final ValueChanged<CareEpisodeAssessment> onDuplicateAssessment;

  const _AssessmentHistoryCard({
    required this.assessmentsFuture,
    required this.isEditing,
    required this.showOpenAssessmentAction,
    required this.onOpenAssessmentPressed,
    required this.onSaveOrUpdatePressed,
    required this.onCancelChangesPressed,
    required this.onReturnToDraftPressed,
    required this.onEditAssessment,
    required this.onArchiveAssessment,
    required this.onExpand,
    required this.onDuplicateAssessment,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Historique des bilans',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (onExpand != null)
                  IconButton(
                    onPressed: onExpand,
                    tooltip: 'Agrandir',
                    icon: const Icon(Icons.zoom_out_map),
                  ),
                if (showOpenAssessmentAction)
                  IconButton(
                    onPressed: onOpenAssessmentPressed,
                    tooltip: 'Créer ou reprendre un bilan',
                    icon: const Icon(Icons.note_add_outlined),
                  ),
                if (isEditing) ...[
                  IconButton(
                    onPressed: onReturnToDraftPressed,
                    tooltip: 'Retour au brouillon',
                    icon: const Icon(Icons.note_add_outlined),
                  ),
                  IconButton(
                    onPressed: onCancelChangesPressed,
                    tooltip: 'Annuler les modifications',
                    icon: const Icon(Icons.undo),
                  ),
                ],
                IconButton(
                  onPressed: onSaveOrUpdatePressed,
                  tooltip: isEditing
                      ? 'Mettre à jour le bilan'
                      : 'Enregistrer le bilan',
                  icon: const Icon(Icons.save_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: FutureBuilder<List<CareEpisodeAssessment>>(
                future: assessmentsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Impossible de charger les bilans.'),
                    );
                  }

                  final assessments = snapshot.data ?? [];

                  if (assessments.isEmpty) {
                    return const Center(
                      child: Text('Aucun bilan enregistré.'),
                    );
                  }

                  final formatter = DateFormat.yMd(
                    Localizations.localeOf(context).toLanguageTag(),
                  );

                  return Column(
                    children: [
                      const _TableHeader(
                        columns: [
                          Expanded(flex: 5, child: Text('Nom')),
                          Expanded(flex: 2, child: Text('Date')),
                          SizedBox(width: 42),
                          SizedBox(width: 42),
                          SizedBox(width: 42),
                        ],
                      ),
                      const Divider(height: 1),
                      Expanded(
                        child: ListView.separated(
                          itemCount: assessments.length,
                          separatorBuilder: (_, _) =>
                          const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final assessment = assessments[index];
                            final date =
                            DateTime.fromMillisecondsSinceEpoch(
                              assessment.assessmentDate,
                            );

                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 5,
                                    child: Text(
                                      assessment.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: Text(formatter.format(date)),
                                  ),
                                  SizedBox(
                                    width: 42,
                                    child: IconButton(
                                      onPressed: () =>
                                          onEditAssessment(assessment),
                                      tooltip: 'Modifier',
                                      icon: const Icon(
                                        Icons.edit_outlined,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 42,
                                    child: IconButton(
                                      onPressed: () => onDuplicateAssessment(assessment),
                                      tooltip: 'Dupliquer',
                                      icon: const Icon(
                                        Icons.copy_outlined,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 42,
                                    child: IconButton(
                                      onPressed: () =>
                                          onArchiveAssessment(assessment),
                                      tooltip: 'Mettre à la corbeille',
                                      icon: const Icon(
                                        Icons.delete_outline,
                                      ),
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
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportHistoryCard extends StatelessWidget {
  final Future<List<CareEpisodeReport>> reportsFuture;
  final bool isEditingReport;
  final VoidCallback onCreateReportPressed;
  final VoidCallback? onSaveReportPressed;
  final VoidCallback? onCancelReportChangesPressed;
  final ValueChanged<CareEpisodeReport> onEditReport;
  final ValueChanged<CareEpisodeReport> onArchiveReport;
  final VoidCallback? onExpand;
  final ValueChanged<CareEpisodeReport> onDuplicateReport;

  const _ReportHistoryCard({
    required this.reportsFuture,
    required this.isEditingReport,
    required this.onCreateReportPressed,
    required this.onSaveReportPressed,
    required this.onCancelReportChangesPressed,
    required this.onEditReport,
    required this.onArchiveReport,
    required this.onExpand,
    required this.onDuplicateReport,
  });

  @override
  Widget build(BuildContext context) {
    return _ScrollableWorkspaceCard(
      title: 'Historique des rapports',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onExpand != null)
            IconButton(
              onPressed: onExpand,
              tooltip: 'Agrandir',
              icon: const Icon(Icons.zoom_out_map),
            ),
          IconButton(
            onPressed: onCreateReportPressed,
            tooltip: isEditingReport
                ? 'Retour au brouillon du rapport'
                : 'Créer ou reprendre un rapport',
            icon: const Icon(Icons.description_outlined),
          ),
          if (isEditingReport)
            IconButton(
              onPressed: onCancelReportChangesPressed,
              tooltip: 'Annuler les modifications',
              icon: const Icon(Icons.undo),
            ),
          if (isEditingReport || onSaveReportPressed != null)
            IconButton(
              onPressed: onSaveReportPressed,
              tooltip: isEditingReport
                  ? 'Mettre à jour le rapport'
                  : 'Enregistrer le rapport',
              icon: const Icon(Icons.save_outlined),
            ),
        ],
      ),
      child: FutureBuilder<List<CareEpisodeReport>>(
        future: reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('Impossible de charger les rapports.'),
            );
          }

          final reports = snapshot.data ?? [];

          if (reports.isEmpty) {
            return const Center(
              child: Text('Aucun rapport enregistré.'),
            );
          }

          final formatter = DateFormat.yMd(
            Localizations.localeOf(context).toLanguageTag(),
          );

          return Column(
            children: [
              const _TableHeader(
                columns: [
                  Expanded(flex: 5, child: Text('Nom')),
                  Expanded(flex: 2, child: Text('Date')),
                  SizedBox(width: 42),
                  SizedBox(width: 42),
                  SizedBox(width: 42),
                ],
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: reports.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    final date = DateTime.fromMillisecondsSinceEpoch(
                      report.reportDate,
                    );

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Text(
                              report.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(formatter.format(date)),
                          ),
                          SizedBox(
                            width: 42,
                            child: IconButton(
                              onPressed: () => onEditReport(report),
                              tooltip: 'Modifier',
                              icon: const Icon(Icons.edit_outlined),
                            ),
                          ),
                          SizedBox(
                            width: 42,
                            child: IconButton(
                              onPressed: () => onDuplicateReport(report),
                              tooltip: 'Dupliquer',
                              icon: const Icon(
                                Icons.copy_outlined,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 42,
                            child: IconButton(
                              onPressed: () => onArchiveReport(report),
                              tooltip: 'Mettre à la corbeille',
                              icon: const Icon(Icons.delete_outline),
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

typedef _NoteIncludedChanged = void Function({
required String noteId,
required bool included,
});

class _FollowUpNotesCard extends StatelessWidget {
  final Future<List<CareEpisodeNote>> notesFuture;
  final Set<String> selectedNoteIds;
  final bool selectionEnabled;
  final VoidCallback onAddNote;
  final VoidCallback? onExpand;
  final _NoteIncludedChanged onNoteIncludedChanged;

  const _FollowUpNotesCard({
    required this.notesFuture,
    required this.selectedNoteIds,
    required this.selectionEnabled,
    required this.onAddNote,
    required this.onExpand,
    required this.onNoteIncludedChanged,
  });


  String _noteTitle(String content) {
    final normalized = content.replaceAll(RegExp(r'\s+'), ' ').trim();

    if (normalized.isEmpty) {
      return 'Note de suivi';
    }

    if (normalized.length <= 40) {
      return normalized;
    }

    return '${normalized.substring(0, 40)}…';
  }

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
    return _ScrollableWorkspaceCard(
      title: 'Notes de suivi',
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onExpand != null)
            IconButton(
              onPressed: onExpand,
              tooltip: 'Agrandir',
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
            return const Center(
              child: Text('Impossible de charger les notes de suivi.'),
            );
          }

          final notes = snapshot.data ?? [];

          if (notes.isEmpty) {
            return const Center(
              child: Text('Aucune note de suivi.'),
            );
          }

          final formatter = DateFormat.yMd(
            Localizations.localeOf(context).toLanguageTag(),
          );

          return Column(
            children: [
              const _TableHeader(
                columns: [
                  Expanded(flex: 2, child: Text('Date')),
                  Expanded(flex: 5, child: Text('Titre')),
                  Expanded(flex: 5, child: Text('Note')),
                  SizedBox(width: 72, child: Text('Inclure')),
                ],
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.separated(
                  itemCount: notes.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    final date = DateTime.fromMillisecondsSinceEpoch(
                      note.noteDate,
                    );

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
                            child: Text(formatter.format(date)),
                          ),
                          Expanded(
                            flex: 5,
                            child: Text(
                              _noteTitle(note.content),
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

class _DocumentsCard extends StatelessWidget {
  final Future<List<CareEpisodeAssessment>> archivedAssessmentsFuture;
  final Future<List<CareEpisodeReport>> archivedReportsFuture;
  final ValueChanged<CareEpisodeAssessment> onRestoreAssessment;
  final ValueChanged<CareEpisodeReport> onRestoreReport;
  final ValueChanged<CareEpisodeAssessment> onDeleteAssessment;
  final ValueChanged<CareEpisodeReport> onDeleteReport;
  final VoidCallback? onExpand;

  const _DocumentsCard({
    required this.archivedAssessmentsFuture,
    required this.archivedReportsFuture,
    required this.onRestoreAssessment,
    required this.onRestoreReport,
    required this.onDeleteAssessment,
    required this.onDeleteReport,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    return _ScrollableWorkspaceCard(
      title: 'Documents archivés',
      trailing: onExpand == null
          ? null
          : IconButton(
        onPressed: onExpand,
        tooltip: 'Agrandir',
        icon: const Icon(Icons.zoom_out_map),
      ),
      child: FutureBuilder<List<CareEpisodeAssessment>>(
        future: archivedAssessmentsFuture,
        builder: (context, assessmentsSnapshot) {
          return FutureBuilder<List<CareEpisodeReport>>(
            future: archivedReportsFuture,
            builder: (context, reportsSnapshot) {
              if (assessmentsSnapshot.connectionState ==
                  ConnectionState.waiting ||
                  reportsSnapshot.connectionState ==
                      ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (assessmentsSnapshot.hasError ||
                  reportsSnapshot.hasError) {
                return const Center(
                  child: Text(
                    'Impossible de charger la corbeille.',
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final items = <_ArchivedDocumentItem>[
                ...((assessmentsSnapshot.data ?? []).map(
                      (assessment) => _ArchivedDocumentItem(
                    typeLabel: 'Bilan',
                    title: assessment.title,
                    archivedAt: assessment.archivedAt ?? 0,
                    icon: Icons.assignment_outlined,
                    assessment: assessment,
                  ),
                )),
                ...((reportsSnapshot.data ?? []).map(
                      (report) => _ArchivedDocumentItem(
                    typeLabel: 'Rapport',
                    title: report.title,
                    archivedAt: report.archivedAt ?? 0,
                    icon: Icons.description_outlined,
                    report: report,
                  ),
                )),
              ]..sort(
                    (a, b) => b.archivedAt.compareTo(a.archivedAt),
              );

              if (items.isEmpty) {
                return const Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Text('Aucun document'),
                      ),
                    ),
                    Divider(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Documents archivés : 0'),
                    ),
                  ],
                );
              }

              final formatter = DateFormat.yMd(
                Localizations.localeOf(context).toLanguageTag(),
              );

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      itemCount: items.length,
                      separatorBuilder: (_, _) =>
                      const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final date = DateTime.fromMillisecondsSinceEpoch(
                          item.archivedAt,
                        );

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                item.icon,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                    ),
                                    Text(
                                      '${item.typeLabel} — '
                                          '${formatter.format(date)}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  final assessment = item.assessment;
                                  final report = item.report;

                                  if (assessment != null) {
                                    onRestoreAssessment(assessment);
                                    return;
                                  }

                                  if (report != null) {
                                    onRestoreReport(report);
                                  }
                                },
                                tooltip: 'Restaurer',
                                icon: const Icon(
                                  Icons.restore_from_trash_outlined,
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  final assessment = item.assessment;
                                  final report = item.report;

                                  if (assessment != null) {
                                    onDeleteAssessment(assessment);
                                    return;
                                  }

                                  if (report != null) {
                                    onDeleteReport(report);
                                  }
                                },
                                tooltip: 'Supprimer définitivement',
                                icon: const Icon(
                                  Icons.delete_forever_outlined,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Documents archivés : ${items.length}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _ArchivedDocumentItem {
  final String typeLabel;
  final String title;
  final int archivedAt;
  final IconData icon;
  final CareEpisodeAssessment? assessment;
  final CareEpisodeReport? report;

  const _ArchivedDocumentItem({
    required this.typeLabel,
    required this.title,
    required this.archivedAt,
    required this.icon,
    this.assessment,
    this.report,
  });
}

class _EpisodeSummaryCard extends StatelessWidget {
  final Future<List<DesktopResult>> resultsFuture;
  final Future<List<CareEpisodeAssessment>> assessmentsFuture;
  final Future<List<CareEpisodeReport>> reportsFuture;

  const _EpisodeSummaryCard({
    required this.resultsFuture,
    required this.assessmentsFuture,
    required this.reportsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<DesktopResult>>(
          future: resultsFuture,
          builder: (context, resultsSnapshot) {
            final distinctTestCount = (resultsSnapshot.data ?? [])
                .map((result) => result.exoId)
                .toSet()
                .length;

            return FutureBuilder<List<CareEpisodeAssessment>>(
              future: assessmentsFuture,
              builder: (context, assessmentsSnapshot) {
                final assessmentCount =
                    assessmentsSnapshot.data?.length ?? 0;

                return FutureBuilder<List<CareEpisodeReport>>(
                  future: reportsFuture,
                  builder: (context, reportsSnapshot) {
                    final reportCount = reportsSnapshot.data?.length ?? 0;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Résumé de l’épisode',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                _SummaryLine(
                                  label: 'Nombre de tests',
                                  value: resultsSnapshot.connectionState ==
                                      ConnectionState.waiting
                                      ? '…'
                                      : '$distinctTestCount',
                                ),
                                const Divider(),
                                _SummaryLine(
                                  label: 'Nombre de bilans',
                                  value:
                                  assessmentsSnapshot.connectionState ==
                                      ConnectionState.waiting
                                      ? '…'
                                      : '$assessmentCount',
                                ),
                                const Divider(),
                                _SummaryLine(
                                  label: 'Nombre de rapports',
                                  value: reportsSnapshot.connectionState ==
                                      ConnectionState.waiting
                                      ? '…'
                                      : '$reportCount',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  final String label;
  final String value;

  const _SummaryLine({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(child: Text(label)),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }
}

class _ScrollableWorkspaceCard extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? trailing;

  const _ScrollableWorkspaceCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ?trailing,
              ],
            ),
            const SizedBox(height: 12),
            Expanded(child: child),
          ],
        ),
      ),
    );
  }
}

class _EpisodeHeader extends StatelessWidget {
  final CareEpisode episode;
  final Future<Practitioner?> practitionerFuture;
  final VoidCallback onEditPractitioner;
  final VoidCallback onShowHistory;
  final VoidCallback onOpenDocuments;

  const _EpisodeHeader({
    required this.episode,
    required this.practitionerFuture,
    required this.onEditPractitioner,
    required this.onShowHistory,
    required this.onOpenDocuments,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.medical_information_outlined),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _EpisodeHeaderInformation(
                    label: 'Pathologie',
                    value: episode.pathologyLabel,
                  ),
                ),
                const SizedBox(width: 32),
                Expanded(
                  child: FutureBuilder<Practitioner?>(
                    future: practitionerFuture,
                    builder: (context, snapshot) {
                      final practitioner = snapshot.data;

                      final value = snapshot.connectionState ==
                          ConnectionState.waiting
                          ? 'Chargement…'
                          : practitioner == null
                          ? 'Non renseigné'
                          : practitioner.isArchived
                          ? '${practitioner.displayName} — archivé'
                          : practitioner.displayName;

                      return _EpisodeHeaderInformation(
                        label: 'Kiné référent',
                        value: value,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onOpenDocuments,
            tooltip: 'Documents de la prise en charge',
            icon: const Icon(Icons.attach_file),
          ),
          IconButton(
            onPressed: onEditPractitioner,
            tooltip: 'Modifier le kiné référent',
            icon: const Icon(Icons.edit_outlined),
          ),
          IconButton(
            onPressed: onShowHistory,
            tooltip: 'Historique des kinés référents',
            icon: const Icon(Icons.history),
          ),
        ],
      ),
    );
  }
}

class _EpisodeHeaderInformation extends StatelessWidget {
  final String label;
  final String value;

  const _EpisodeHeaderInformation({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _TableHeader extends StatelessWidget {
  final List<Widget> columns;

  const _TableHeader({
    required this.columns,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTextStyle(
      style: Theme.of(context).textTheme.labelMedium!.copyWith(
        fontWeight: FontWeight.w600,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 6,
        ),
        child: Row(children: columns),
      ),
    );
  }
}

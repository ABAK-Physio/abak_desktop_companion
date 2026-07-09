import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../data/care_episode_repository.dart';
import '../models/care_episode.dart';
import '../models/care_episode_note.dart';
import 'package:intl/intl.dart';
import '../../results/data/desktop_result_repository.dart';
import '../../results/models/desktop_result.dart';
import '../../results/result_detail_screen.dart';
import 'package:abak_shared/abak_shared.dart';
import '../../documents/services/initial_report_document_service.dart';
import '../../patients/data/patient_repository.dart';
import '../../patients/models/patient.dart';

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
  final InitialReportDocumentService _initialReportDocumentService =
  const InitialReportDocumentService();
  final PatientRepository _patientRepository = PatientRepository();

  Patient? _patient;

  @override
  void initState() {
    super.initState();
    _episode = widget.episode;
    _loadPatient();
  }

  Future<void> _loadPatient() async {
    final patient = await _patientRepository.getPatientById(_episode.patientId);

    if (!mounted) return;

    setState(() {
      _patient = patient;
    });
  }

  void _refresh() {
    setState(() {
      _refreshToken++;
    });
  }

  String _objectiveDataTemplate() {
    return '''
  Signes vitaux :

  Résultats de l'examen physique :

  Évaluation fonctionnelle :
  '''.trim();
  }

  String _assessmentDataTemplate() {
    return '''
  Synthèse clinique :

  Hypothèses / impression clinique :

  Évolution / points de vigilance :
  '''.trim();
  }

  String _treatmentPlanTemplate() {
    return '''
  Interventions prévues :

  Éducation / conseils au patient :

  Planification du suivi :
  - Fréquence :
  - Durée estimée :
  - Points à réévaluer :
  '''.trim();
  }

  Future<void> _editObjectiveData() async {
    final controller = TextEditingController(
      text: _episode.objectiveData?.trim().isNotEmpty == true
          ? _episode.objectiveData!.trim()
          : _objectiveDataTemplate(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Évaluation clinique'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.55,
            height: MediaQuery.of(context).size.height * 0.60,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Évaluation clinique',
                helperText: 'Structure inspirée du modèle SOAP • Objectif',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              expands: true,
              minLines: null,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
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

    final objectiveData = controller.text.trim();
    controller.dispose();

    if (confirmed != true) return;

    final updatedEpisode = CareEpisode(
      careEpisodeId: _episode.careEpisodeId,
      patientId: _episode.patientId,
      title: _episode.title,
      pathologyLabel: _episode.pathologyLabel,
      initialReport: _episode.initialReport,
      initialReportDocxPath: _episode.initialReportDocxPath,
      objectiveData: objectiveData.isEmpty ? null : objectiveData,
      finalConclusion: _episode.finalConclusion,
      createdAt: _episode.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      archivedAt: _episode.archivedAt,
    );

    await _repository.updateCareEpisode(updatedEpisode);

    _hasChanged = true;

    if (!mounted) return;

    setState(() {
      _episode = updatedEpisode;
    });
  }


  Future<void> _editAssessmentData() async {
    final controller = TextEditingController(
      text: _episode.assessmentData?.trim().isNotEmpty == true
          ? _episode.assessmentData!.trim()
          : _assessmentDataTemplate(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Analyse clinique'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.55,
            height: MediaQuery.of(context).size.height * 0.60,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Analyse clinique',
                helperText: 'Structure inspirée du modèle SOAP • Analyse',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              expands: true,
              minLines: null,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
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

    final assessmentData = controller.text.trim();
    controller.dispose();

    if (confirmed != true) return;

    final updatedEpisode = CareEpisode(
      careEpisodeId: _episode.careEpisodeId,
      patientId: _episode.patientId,
      title: _episode.title,
      pathologyLabel: _episode.pathologyLabel,
      initialReport: _episode.initialReport,
      initialReportDocxPath: _episode.initialReportDocxPath,
      objectiveData: _episode.objectiveData,
      assessmentData: assessmentData.isEmpty ? null : assessmentData,
      finalConclusion: _episode.finalConclusion,
      createdAt: _episode.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      archivedAt: _episode.archivedAt,
    );

    await _repository.updateCareEpisode(updatedEpisode);

    _hasChanged = true;

    if (!mounted) return;

    setState(() {
      _episode = updatedEpisode;
    });
  }

  Future<void> _editTreatmentPlan() async {
    final controller = TextEditingController(
      text: _episode.treatmentPlan?.trim().isNotEmpty == true
          ? _episode.treatmentPlan!.trim()
          : _treatmentPlanTemplate(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Plan de traitement'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.55,
            height: MediaQuery.of(context).size.height * 0.60,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Plan de traitement',
                helperText: 'Structure inspirée du modèle SOAP • Plan',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              expands: true,
              minLines: null,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
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

    final treatmentPlan = controller.text.trim();
    controller.dispose();

    if (confirmed != true) return;

    final updatedEpisode = CareEpisode(
      careEpisodeId: _episode.careEpisodeId,
      patientId: _episode.patientId,
      title: _episode.title,
      pathologyLabel: _episode.pathologyLabel,
      initialReport: _episode.initialReport,
      initialReportDocxPath: _episode.initialReportDocxPath,
      objectiveData: _episode.objectiveData,
      assessmentData: _episode.assessmentData,
      treatmentPlan: treatmentPlan.isEmpty ? null : treatmentPlan,
      finalConclusion: _episode.finalConclusion,
      createdAt: _episode.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      archivedAt: _episode.archivedAt,
    );

    await _repository.updateCareEpisode(updatedEpisode);

    _hasChanged = true;

    if (!mounted) return;

    setState(() {
      _episode = updatedEpisode;
    });
  }

  Future<void> _editInitialReport() async {
    final controller = TextEditingController(
      text: _episode.initialReport?.trim().isNotEmpty == true
          ? _episode.initialReport!.trim()
          : _initialReportTemplate(),
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Entretien initial'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.55,
            height: MediaQuery.of(context).size.height * 0.60,
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'Entretien initial',
                helperText: 'Structure inspirée du modèle SOAP • Subjectif',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              expands: true,
              minLines: null,
              maxLines: null,
              textAlignVertical: TextAlignVertical.top,
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

    final initialReport = controller.text.trim();
    controller.dispose();

    if (confirmed != true) return;

    final updatedEpisode = CareEpisode(
      careEpisodeId: _episode.careEpisodeId,
      patientId: _episode.patientId,
      title: _episode.title,
      pathologyLabel: _episode.pathologyLabel,
      initialReport: initialReport.isEmpty ? null : initialReport,
      finalConclusion: _episode.finalConclusion,
      createdAt: _episode.createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      archivedAt: _episode.archivedAt,
    );

    await _repository.updateCareEpisode(updatedEpisode);

    _hasChanged = true;

    if (!mounted) return;

    setState(() {
      _episode = updatedEpisode;
    });
  }

  Future<void> _associateInitialReportDocx() async {
    final path = await _initialReportDocumentService.pickExistingDocx();

    if (path == null) return;

    await _repository.updateInitialReportDocxPath(
      careEpisodeId: _episode.careEpisodeId,
      initialReportDocxPath: path,
    );

    if (!mounted) return;

    setState(() {
      _episode = CareEpisode(
        careEpisodeId: _episode.careEpisodeId,
        patientId: _episode.patientId,
        title: _episode.title,
        pathologyLabel: _episode.pathologyLabel,
        initialReport: _episode.initialReport,
        initialReportDocxPath: path,
        finalConclusion: _episode.finalConclusion,
        createdAt: _episode.createdAt,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        archivedAt: _episode.archivedAt,
      );
      _hasChanged = true;
    });
  }

  Future<void> _openInitialReportDocx() async {
    final path = _episode.initialReportDocxPath;

    if (path == null || path.trim().isEmpty) return;

    final exists = await _initialReportDocumentService.exists(path);

    if (!mounted) return;

    if (!exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Le fichier associé est introuvable.'),
        ),
      );
      return;
    }

    await _initialReportDocumentService.open(path);
  }

  Future<void> _unlinkInitialReportDocx() async {
    await _repository.updateInitialReportDocxPath(
      careEpisodeId: _episode.careEpisodeId,
      initialReportDocxPath: null,
    );

    if (!mounted) return;

    setState(() {
      _episode = CareEpisode(
        careEpisodeId: _episode.careEpisodeId,
        patientId: _episode.patientId,
        title: _episode.title,
        pathologyLabel: _episode.pathologyLabel,
        initialReport: _episode.initialReport,
        initialReportDocxPath: null,
        finalConclusion: _episode.finalConclusion,
        createdAt: _episode.createdAt,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        archivedAt: _episode.archivedAt,
      );
      _hasChanged = true;
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

  String _initialReportTemplate() {
    return '''
Motif de consultation :

Histoire de la maladie actuelle :

Douleur :

Limitations fonctionnelles :

Objectifs du patient :

Antécédents médicaux :

Observations complémentaires :
'''.trim();
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
          title: Text(
            _patient == null
                ? _episode.displayTitle
                : '${_patient!.lastName.toUpperCase()} ${_patient!.firstName}',
          ),
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
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Entretien initial',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Text(
                                  'SOAP • Subjectif',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _editInitialReport,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Modifier'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_episode.displayInitialReport),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    Text(
                      'Bilan initial',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    if (_episode.initialReportDocxPath == null ||
                        _episode.initialReportDocxPath!.trim().isEmpty) ...[
                      const Text('Aucun document de bilan associé.'),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _associateInitialReportDocx,
                        icon: const Icon(Icons.attach_file_outlined),
                        label: const Text('Associer un bilan existant…'),
                      ),
                    ] else ...[
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.description_outlined),
                        title: Text(
                          _initialReportDocumentService.fileName(
                            _episode.initialReportDocxPath!,
                          ),
                        ),
                        subtitle: const Text('Document de bilan associé'),
                      ),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _openInitialReportDocx,
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Ouvrir'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _associateInitialReportDocx,
                            icon: const Icon(Icons.swap_horiz),
                            label: const Text('Changer…'),
                          ),
                          OutlinedButton.icon(
                            onPressed: _unlinkInitialReportDocx,
                            icon: const Icon(Icons.link_off),
                            label: const Text('Dissocier'),
                          ),
                        ],
                      ),
                    ],
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
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Évaluation clinique',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Text(
                                  'SOAP • Objectif',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _editObjectiveData,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Modifier'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_episode.displayObjectiveData),
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
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Analyse clinique',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Text(
                                  'SOAP • Analyse',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _editAssessmentData,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Modifier'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_episode.displayAssessmentData),
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
                    Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Text(
                                'Plan de traitement',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.outlineVariant,
                                  ),
                                ),
                                child: Text(
                                  'SOAP • Plan',
                                  style: Theme.of(context).textTheme.labelMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: _editTreatmentPlan,
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text('Modifier'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(_episode.displayTreatmentPlan),
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

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.bar_chart_outlined),
                          title: Text(
                            ClinicalActivityCatalog.displayLabel(result.exoId),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                [
                                  formatter.format(date),
                                  if (result.scoreTotal != null)
                                    'Score : ${result.scoreTotal?.toStringAsFixed(2) ?? '-'}',
                                  if (result.measureUnit != null) result.measureUnit!,
                                ].join(' · '),
                              ),
                              if (mobileOrigin != null && mobileOrigin.trim().isNotEmpty)
                                Text(
                                  'Origine ABAK : ${mobileOrigin.trim()}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                            ],
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () async {
                            final changed = await Navigator.of(context).push<bool>(
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
                        ),
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
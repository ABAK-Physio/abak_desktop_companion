import 'package:flutter/material.dart';

import '../../results/data/desktop_result_repository.dart';
import '../data/episode_document_repository.dart';
import '../data/episode_form_repository.dart';
import '../data/episode_note_repository.dart';
import '../data/patient_attribute_repository.dart';
import '../data/patient_identity_repository.dart';
import '../models/patient_attribute.dart';
import '../models/patient_identity.dart';
import '../models/contact_form_field.dart';
import '../models/episode_form_answer.dart';
import '../../results/models/desktop_result.dart';
import '../models/episode_document.dart';
import '../models/episode_note.dart';
import '../data/episode_conclusion_repository.dart';
import '../models/episode_conclusion.dart';
import '../../episodes/report/services/episode_report_service.dart';
import '../../episodes/report/services/episode_report_text_builder.dart';
import '../../episodes/report/widgets/episode_report_preview_card.dart';

class EpisodeReportScreen extends StatefulWidget {
  final String caseId;
  final String caseLabel;
  final String patientId;
  final String patientDisplayName;

  const EpisodeReportScreen({
    super.key,
    required this.caseId,
    required this.caseLabel,
    required this.patientId,
    required this.patientDisplayName,
  });

  @override
  State<EpisodeReportScreen> createState() =>
      _EpisodeReportScreenState();
}

class _EpisodeReportScreenState extends State<EpisodeReportScreen> {
  final EpisodeFormRepository _formRepository =
  EpisodeFormRepository();

  final DesktopResultRepository _resultRepository =
  DesktopResultRepository();

  final EpisodeDocumentRepository _documentRepository =
  EpisodeDocumentRepository();

  final EpisodeNoteRepository _noteRepository =
  EpisodeNoteRepository();

  late Future<_EpisodeReportData> _futureData;

  final PatientIdentityRepository _identityRepository =
  PatientIdentityRepository();

  final PatientAttributeRepository _attributeRepository =
  PatientAttributeRepository();

  final EpisodeConclusionRepository _conclusionRepository =
  EpisodeConclusionRepository();

  @override
  void initState() {
    super.initState();
    _futureData = _loadData();
  }

  Future<_EpisodeReportData> _loadData() async {
    final forms = await _formRepository.getFormsByCaseId(widget.caseId);
    final formAnswers = <Map<ContactFormField, EpisodeFormAnswer?>>[];

    for (final form in forms) {
      final answers = await _formRepository.getFormWithAnswers(
        formId: form.formId,
      );

      formAnswers.add(answers);
    }
    final results =
    await _resultRepository.getResultsForMobileCase(widget.caseId);
    final documents =
    await _documentRepository.getByCaseId(widget.caseId);
    final notes =
    await _noteRepository.getByCaseId(widget.caseId);
    final identity =
    await _identityRepository.getByPatientId(widget.patientId);

    final attributes =
    await _attributeRepository.getByPatientId(widget.patientId);

    final conclusion =
    await _conclusionRepository.getActiveByCaseId(widget.caseId);

    return _EpisodeReportData(
      formsCount: forms.length,
      resultsCount: results.length,
      documentsCount: documents.length,
      notesCount: notes.length,
      identity: identity,
      attributes: attributes,
      formAnswers: formAnswers,
      results: results,
      documents: documents,
      notes: notes,
      conclusion: conclusion,
    );
  }

  Future<void> _refresh() async {
    setState(() {
      _futureData = _loadData();
    });
  }

  Widget _buildGeneratedTextPreview() {
    final reportService = EpisodeReportService();
    final textBuilder = const EpisodeReportTextBuilder();

    return FutureBuilder(
      future: reportService.buildReport(
        patientId: widget.patientId,
        episodeId: widget.caseId,
        patientDisplayName: widget.patientDisplayName,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Card(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Text('Génération de l’aperçu texte...'),
            ),
          );
        }

        final report = snapshot.data!;
        final document = textBuilder.build(report);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aperçu du rapport généré',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            EpisodeReportPreviewCard(
              document: document,
              report: report,
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent(_EpisodeReportData data) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        _ReportPatientCard(
          patientDisplayName: widget.patientDisplayName,
          identity: data.identity,
          attributes: data.attributes,
        ),
        const SizedBox(height: 16),
        _ReportFormsCard(
          formAnswers: data.formAnswers,
        ),
        const SizedBox(height: 16),
        _ReportResultsCard(
          results: data.results,
        ),
        const SizedBox(height: 16),
        _ReportDocumentsCard(
          documents: data.documents,
        ),
        const SizedBox(height: 16),
        _ReportNotesCard(
          notes: data.notes,
        ),
        const SizedBox(height: 16),
        _ReportConclusionCard(
          caseId: widget.caseId,
          conclusion: data.conclusion,
          onSaved: _refresh,
        ),

        const SizedBox(height: 16),

        _buildGeneratedTextPreview(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rapport — ${widget.caseLabel}'),
        actions: [
          IconButton(
            tooltip: 'Actualiser',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<_EpisodeReportData>(
        future: _futureData,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Erreur : ${snapshot.error}'),
            );
          }

          final data = snapshot.data;

          if (data == null) {
            return const Center(
              child: Text('Aucune donnée à afficher.'),
            );
          }

          return _buildContent(data);
        },
      ),
    );
  }
}

class _EpisodeReportData {
  final int formsCount;
  final int resultsCount;
  final int documentsCount;
  final int notesCount;
  final PatientIdentity? identity;
  final List<PatientAttribute> attributes;
  final List<Map<ContactFormField, EpisodeFormAnswer?>> formAnswers;
  final List<DesktopResult> results;
  final List<EpisodeDocument> documents;
  final List<EpisodeNote> notes;
  final EpisodeConclusion? conclusion;


  const _EpisodeReportData({
    required this.formsCount,
    required this.resultsCount,
    required this.documentsCount,
    required this.notesCount,
    required this.identity,
    required this.attributes,
    required this.formAnswers,
    required this.results,
    required this.documents,
    required this.notes,
    required this.conclusion,

  });
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,

  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}

class _ReportPatientCard extends StatelessWidget {
  final String patientDisplayName;
  final PatientIdentity? identity;
  final List<PatientAttribute> attributes;

  const _ReportPatientCard({
    required this.patientDisplayName,
    required this.identity,
    required this.attributes,
  });

  String _attributeValue(String key) {
    final matching = attributes.where((a) => a.attributeKey == key);

    if (matching.isEmpty) {
      return 'Non renseigné';
    }

    final value = matching.first.attributeValue?.trim();

    return value == null || value.isEmpty ? 'Non renseigné' : value;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person_outline),
                const SizedBox(width: 8),
                Text(
                  'Patient',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(height: 28),
            _ReportRow(
              label: 'Nom',
              value: patientDisplayName,
            ),
            _ReportRow(
              label: 'Téléphone',
              value: identity?.phone ?? 'Non renseigné',
            ),
            _ReportRow(
              label: 'Email',
              value: identity?.email ?? 'Non renseigné',
            ),
            _ReportRow(
              label: 'Côté dominant',
              value: _attributeValue('dominant_side'),
            ),
            _ReportRow(
              label: 'Profession',
              value: _attributeValue('profession'),
            ),
            _ReportRow(
              label: 'Activité sportive',
              value: _attributeValue('sport'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  final String label;
  final String value;

  const _ReportRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }
}

class _ReportFormsCard extends StatelessWidget {
  final List<Map<ContactFormField, EpisodeFormAnswer?>> formAnswers;

  const _ReportFormsCard({
    required this.formAnswers,
  });

  @override
  Widget build(BuildContext context) {
    if (formAnswers.isEmpty) {
      return const _SectionCard(
        title: 'Formulaires',
        subtitle: 'Aucun formulaire associé',
        icon: Icons.assignment_outlined,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.assignment_outlined),
                const SizedBox(width: 8),
                Text(
                  'Formulaires',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(height: 28),
            for (final form in formAnswers) ...[
              for (final entry in form.entries)
                _ReportRow(
                  label: entry.key.label,
                  value: entry.value?.value?.trim().isNotEmpty == true
                      ? entry.value!.value!
                      : 'Non renseigné',
                ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReportResultsCard extends StatelessWidget {
  final List<DesktopResult> results;

  const _ReportResultsCard({
    required this.results,
  });

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const _SectionCard(
        title: 'Résultats ABAK',
        subtitle: 'Aucun résultat associé',
        icon: Icons.bar_chart_outlined,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart_outlined),
                const SizedBox(width: 8),
                Text(
                  'Résultats ABAK',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(height: 28),
            for (final result in results)
              _ReportRow(
                label: result.exoId,
                value: [
                  if (result.scoreTotal != null)
                    'Score : ${result.scoreTotal}',
                  if (result.measureUnit != null)
                    result.measureUnit!,
                  if (result.mobileCaseLabel != null)
                    result.mobileCaseLabel!,
                ].join(' · '),
              ),
          ],
        ),
      ),
    );
  }
}

class _ReportDocumentsCard extends StatelessWidget {
  final List<EpisodeDocument> documents;

  const _ReportDocumentsCard({
    required this.documents,
  });

  @override
  Widget build(BuildContext context) {
    if (documents.isEmpty) {
      return const _SectionCard(
        title: 'Documents',
        subtitle: 'Aucun document associé',
        icon: Icons.attach_file_outlined,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.attach_file_outlined),
                const SizedBox(width: 8),
                Text(
                  'Documents',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(height: 28),
            for (final document in documents)
              _ReportRow(
                label: document.title,
                value: document.mimeType ?? 'Type inconnu',
              ),
          ],
        ),
      ),
    );
  }
}

class _ReportNotesCard extends StatelessWidget {
  final List<EpisodeNote> notes;

  const _ReportNotesCard({
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return const _SectionCard(
        title: 'Notes',
        subtitle: 'Aucune note associée',
        icon: Icons.notes_outlined,
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.notes_outlined),
                const SizedBox(width: 8),
                Text(
                  'Notes',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(height: 28),
            for (final note in notes) ...[
              Text(
                note.title,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 6),
              SelectableText(
                note.content.trim().isEmpty
                    ? 'Non renseigné'
                    : note.content.trim(),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
class _ReportConclusionCard extends StatelessWidget {
  final String caseId;
  final EpisodeConclusion? conclusion;
  final VoidCallback onSaved;

  const _ReportConclusionCard({
    required this.caseId,
    required this.conclusion,
    required this.onSaved,
  });

  Future<void> _openEditor(BuildContext context) async {
    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _EpisodeConclusionEditorScreen(
          caseId: caseId,
          conclusion: conclusion,
        ),
      ),
    );

    if (changed == true) {
      onSaved();
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = conclusion?.content.trim();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.description_outlined),
                const SizedBox(width: 8),
                Text(
                  'Conclusion clinique',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const Divider(height: 28),
            if (content == null || content.isEmpty)
              const Text('Aucune conclusion renseignée.')
            else
              SelectableText(content),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () => _openEditor(context),
                icon: const Icon(Icons.edit_outlined),
                label: Text(
                  content == null || content.isEmpty
                      ? 'Ajouter une conclusion'
                      : 'Modifier la conclusion',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EpisodeConclusionEditorScreen extends StatefulWidget {
  final String caseId;
  final EpisodeConclusion? conclusion;

  const _EpisodeConclusionEditorScreen({
    required this.caseId,
    this.conclusion,
  });

  @override
  State<_EpisodeConclusionEditorScreen> createState() =>
      _EpisodeConclusionEditorScreenState();
}

class _EpisodeConclusionEditorScreenState
    extends State<_EpisodeConclusionEditorScreen> {
  final EpisodeConclusionRepository _repository =
  EpisodeConclusionRepository();

  final _controller = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _controller.text = widget.conclusion?.content ?? '';
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final content = _controller.text.trim();

    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La conclusion ne peut pas être vide.'),
        ),
      );

      return;
    }

    setState(() {
      _saving = true;
    });

    await _repository.upsertForCase(
      caseId: widget.caseId,
      content: content,
    );

    if (!mounted) return;

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.conclusion != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditing
              ? 'Modifier la conclusion'
              : 'Ajouter une conclusion',
        ),
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
            controller: _controller,
            minLines: 10,
            maxLines: 20,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Conclusion clinique',
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }
}
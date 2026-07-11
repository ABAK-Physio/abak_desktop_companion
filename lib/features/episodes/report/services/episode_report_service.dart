import '../../../patients/data/episode_conclusion_repository.dart';
import '../../../patients/data/episode_form_repository.dart';
import '../../../patients/data/patient_attribute_repository.dart';
import '../../../patients/data/patient_identity_repository.dart';
import '../../../patients/data/patient_repository.dart';
import '../models/episode_report_view_model.dart';
import '../../../results/data/desktop_result_repository.dart';
import '../../../patients/data/episode_document_repository.dart';
import '../../../patients/data/episode_note_repository.dart';
import '../../../import_export/data/mobile_case_repository.dart';
import '../models/report_field.dart';
import '../models/report_form_section.dart';
import '../models/report_result_section.dart';
import '../models/report_document_item.dart';
import '../models/report_note_item.dart';
import 'package:abak_shared/abak_shared.dart';

class EpisodeReportService {
  final PatientRepository patientRepository;
  final PatientIdentityRepository identityRepository;
  final PatientAttributeRepository attributeRepository;
  final EpisodeConclusionRepository conclusionRepository;
  final EpisodeFormRepository formRepository;
  final DesktopResultRepository resultRepository;
  final EpisodeDocumentRepository documentRepository;
  final EpisodeNoteRepository noteRepository;
  final MobileCaseRepository mobileCaseRepository;

  EpisodeReportService({
    PatientRepository? patientRepository,
    PatientIdentityRepository? identityRepository,
    PatientAttributeRepository? attributeRepository,
    EpisodeConclusionRepository? conclusionRepository,
    EpisodeFormRepository? formRepository,
    DesktopResultRepository? resultRepository,
    EpisodeDocumentRepository? documentRepository,
    EpisodeNoteRepository? noteRepository,
    MobileCaseRepository? mobileCaseRepository,
  }) : patientRepository = patientRepository ?? PatientRepository(),
       identityRepository = identityRepository ?? PatientIdentityRepository(),
       attributeRepository =
           attributeRepository ?? PatientAttributeRepository(),
       conclusionRepository =
           conclusionRepository ?? EpisodeConclusionRepository(),
       formRepository = formRepository ?? EpisodeFormRepository(),
       resultRepository = resultRepository ?? DesktopResultRepository(),
       documentRepository = documentRepository ?? EpisodeDocumentRepository(),
       noteRepository = noteRepository ?? EpisodeNoteRepository(),
       mobileCaseRepository = mobileCaseRepository ?? MobileCaseRepository();

  Future<EpisodeReportViewModel> buildReport({
    required String patientId,
    required String episodeId,
    required String patientDisplayName,
  }) async {
    final patient = await patientRepository.getPatientById(patientId);
    final identity = await identityRepository.getByPatientId(patientId);
    final attributes = await attributeRepository.getByPatientId(patientId);
    final conclusion = await conclusionRepository.getActiveByCaseId(episodeId);
    final mobileCase = await mobileCaseRepository.getCaseById(episodeId);
    String formTitle(String templateId) {
      switch (templateId) {
        case 'default_initial_contact':
          return 'Formulaire de contact initial';
        default:
          return 'Formulaire';
      }
    }

    final forms = await formRepository.getFormsByCaseId(episodeId);
    final formSections = <ReportFormSection>[];

    for (final form in forms) {
      final answers = await formRepository.getFormWithAnswers(
        formId: form.formId,
      );

      final fields = <ReportField>[];

      for (final entry in answers.entries) {
        final field = entry.key;
        final answer = entry.value;
        final value = answer?.value?.trim();

        fields.add(
          ReportField(
            label: field.label,
            value: value == null || value.isEmpty ? 'Non renseigné' : value,
          ),
        );
      }

      formSections.add(
        ReportFormSection(title: formTitle(form.templateId), fields: fields),
      );
    }

    final results = [];

    final resultSections = <ReportResultSection>[];

    for (final result in results) {
      final title = ClinicalActivityCatalog.displayLabel(result.exoId);

      final score = result.scoreTotal?.toString();

      final unit = result.measureUnit?.trim();

      final summary = [
        if (score != null) 'Moyenne : $score',
        if (unit != null && unit.isNotEmpty) unit,
      ].join(' · ');

      final details = <String>[];

      final comment = result.comment?.trim();

      if (comment != null && comment.isNotEmpty) {
        details.add('Commentaire : $comment');
      }

      final exportText = result.exportSimpleText.trim();

      if (exportText.isNotEmpty) {
        details.add(exportText);
      }

      resultSections.add(
        ReportResultSection(
          title: title,
          summary: summary.isEmpty ? null : summary,
          details: details,
        ),
      );
    }

    final episodeDocuments = await documentRepository.getByCaseId(episodeId);

    final documents = episodeDocuments
        .map(
          (document) => ReportDocumentItem(
            title: document.title,
            mimeType: document.mimeType,
          ),
        )
        .toList();

    final episodeNotes = await noteRepository.getByCaseId(episodeId);

    final notes = episodeNotes
        .map(
          (note) => ReportNoteItem(
            title: note.title,
            content: note.content.trim().isEmpty
                ? 'Non renseigné'
                : note.content.trim(),
          ),
        )
        .toList();

    String attributeValue(String key) {
      final matching = attributes.where((a) => a.attributeKey == key);

      if (matching.isEmpty) {
        return 'Non renseigné';
      }

      final value = matching.first.attributeValue?.trim();

      return value == null || value.isEmpty ? 'Non renseigné' : value;
    }

    String sexLabel(String code) {
      switch (code) {
        case 'M':
          return 'Masculin';
        case 'F':
          return 'Féminin';
        case 'U':
        default:
          return 'Non renseigné';
      }
    }

    return EpisodeReportViewModel(
      patientDisplayName: patient?.displayName ?? patientDisplayName,
      birthDate: patient?.birthDate,
      sex: patient == null ? null : sexLabel(patient.sexCode),
      episodeTitle: mobileCase?.caseLabel ?? episodeId,
      patientProfileFields: [
        ReportField(
          label: 'Téléphone',
          value: identity?.phone ?? 'Non renseigné',
        ),
        ReportField(label: 'Email', value: identity?.email ?? 'Non renseigné'),
        ReportField(
          label: 'Côté dominant',
          value: attributeValue('dominant_side'),
        ),
        ReportField(label: 'Profession', value: attributeValue('profession')),
        ReportField(label: 'Activité sportive', value: attributeValue('sport')),
      ],
      formSections: formSections,
      resultSections: resultSections,
      documents: documents,
      notes: notes,
      clinicalConclusion: conclusion?.content,
    );
  }
}

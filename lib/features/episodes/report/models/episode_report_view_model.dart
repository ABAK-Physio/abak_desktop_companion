import 'report_field.dart';
import 'report_form_section.dart';
import 'report_result_section.dart';
import 'report_document_item.dart';
import 'report_note_item.dart';

class EpisodeReportViewModel {
  final String patientDisplayName;
  final String? birthDate;
  final String? sex;
  final String? episodeTitle;

  final List<ReportField> patientProfileFields;
  final List<ReportFormSection> formSections;

  final List<ReportResultSection> resultSections;
  final List<ReportDocumentItem> documents;
  final List<ReportNoteItem> notes;

  final String? clinicalConclusion;

  const EpisodeReportViewModel({
    required this.patientDisplayName,
    this.birthDate,
    this.sex,
    this.episodeTitle,
    required this.patientProfileFields,
    required this.formSections,
    required this.resultSections,
    required this.documents,
    required this.notes,
    this.clinicalConclusion,
  });
}

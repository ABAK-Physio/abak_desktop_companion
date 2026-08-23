import 'assessment_template_field.dart';

class AssessmentTemplateSection {
  final String id;
  final String title;
  final List<AssessmentTemplateField> fields;

  const AssessmentTemplateSection({
    required this.id,
    required this.title,
    required this.fields,
  });
}
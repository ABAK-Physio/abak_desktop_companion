import 'assessment_template_section.dart';

class AssessmentTemplate {
  final String id;
  final String name;
  final String? description;
  final List<AssessmentTemplateSection> sections;

  const AssessmentTemplate({
    required this.id,
    required this.name,
    this.description,
    required this.sections,
  });
}
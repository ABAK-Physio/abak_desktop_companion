import 'assessment_template_field_type.dart';

class AssessmentTemplateField {
  final String id;
  final String label;
  final AssessmentTemplateFieldType type;
  final List<String> options;
  final String? abakSource;
  final String tableRowHeader;
  final List<String> tableColumns;
  final List<String> tableRows;

  const AssessmentTemplateField({
    required this.id,
    required this.label,
    required this.type,
    this.options = const [],
    this.abakSource,
    this.tableRowHeader = 'Mouvement',
    this.tableColumns = const [],
    this.tableRows = const [],
  });
}
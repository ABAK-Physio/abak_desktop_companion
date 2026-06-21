import 'report_field.dart';

class ReportFormSection {
  final String title;
  final List<ReportField> fields;

  const ReportFormSection({
    required this.title,
    required this.fields,
  });

  bool get isEmpty {
    return title.trim().isEmpty && fields.every((field) => field.isEmpty);
  }
}

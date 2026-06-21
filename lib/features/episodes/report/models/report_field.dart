class ReportField {
  final String label;
  final String value;

  const ReportField({
    required this.label,
    required this.value,
  });

  bool get isEmpty {
    return label.trim().isEmpty && value.trim().isEmpty;
  }
}
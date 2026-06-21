class ReportResultSection {
  final String title;
  final String? summary;
  final List<String> details;

  const ReportResultSection({
    required this.title,
    this.summary,
    required this.details,
  });

  bool get isEmpty {
    return title.trim().isEmpty &&
        (summary == null || summary!.trim().isEmpty) &&
        details.every((line) => line.trim().isEmpty);
  }
}
class ReportDocumentItem {
  final String title;
  final String? mimeType;

  const ReportDocumentItem({
    required this.title,
    this.mimeType,
  });

  bool get isEmpty {
    return title.trim().isEmpty &&
        (mimeType == null || mimeType!.trim().isEmpty);
  }
}
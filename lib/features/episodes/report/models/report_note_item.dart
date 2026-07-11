class ReportNoteItem {
  final String title;
  final String content;

  const ReportNoteItem({required this.title, required this.content});

  bool get isEmpty {
    return title.trim().isEmpty && content.trim().isEmpty;
  }
}

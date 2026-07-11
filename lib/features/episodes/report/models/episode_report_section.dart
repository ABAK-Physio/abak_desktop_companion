class EpisodeReportSection {
  final String title;
  final List<String> lines;

  const EpisodeReportSection({required this.title, required this.lines});

  bool get isEmpty {
    return lines.every((line) => line.trim().isEmpty);
  }
}

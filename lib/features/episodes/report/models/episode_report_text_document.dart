import 'episode_report_section.dart';

class EpisodeReportTextDocument {
  final String title;
  final List<EpisodeReportSection> sections;

  const EpisodeReportTextDocument({
    required this.title,
    required this.sections,
  });

  String toPlainText() {
    final buffer = StringBuffer();

    buffer.writeln(title);
    buffer.writeln('=' * title.length);
    buffer.writeln();

    for (final section in sections) {
      if (section.isEmpty) continue;

      buffer.writeln(section.title);
      buffer.writeln('-' * section.title.length);

      for (final line in section.lines) {
        buffer.writeln(line);
      }

      buffer.writeln();
    }

    return buffer.toString().trimRight();
  }
}
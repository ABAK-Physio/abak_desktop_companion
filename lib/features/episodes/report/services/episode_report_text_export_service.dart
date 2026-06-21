import 'dart:io';

import 'package:path/path.dart' as p;

import '../models/episode_report_text_document.dart';

class EpisodeReportTextExportService {
  const EpisodeReportTextExportService();

  Future<File> exportToTextFile({
    required EpisodeReportTextDocument document,
    required Directory directory,
    required String fileName,
  }) async {
    final safeFileName = _sanitizeFileName(fileName);
    final path = p.join(directory.path, '$safeFileName.txt');

    final file = File(path);

    return file.writeAsString(
      document.toPlainText(),
      flush: true,
    );
  }

  String _sanitizeFileName(String value) {
    return value
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .replaceAll(RegExp(r'\s+'), '_');
  }
}
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

class EpisodeReportDocxExportService {
  const EpisodeReportDocxExportService();

  Future<File> exportToDocxFile({
    required Uint8List bytes,
    required Directory directory,
    required String fileName,
  }) async {
    final safeFileName = _sanitizeFileName(fileName);
    final path = p.join(directory.path, '$safeFileName.docx');

    final file = File(path);

    return file.writeAsBytes(
      bytes,
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
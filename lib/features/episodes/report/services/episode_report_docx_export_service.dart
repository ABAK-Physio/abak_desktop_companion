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

    final basePath = p.join(
      directory.path,
      '$safeFileName.docx',
    );

    final baseFile = File(basePath);

    if (!await baseFile.exists()) {
      return baseFile.writeAsBytes(
        bytes,
        flush: true,
      );
    }

    var maxIndex = 1;

    await for (final entity in directory.list()) {
      if (entity is! File) continue;

      final name = p.basename(entity.path);

      final match = RegExp(
        '^${RegExp.escape(safeFileName)}_(\\d+)\\.docx\$',
      ).firstMatch(name);

      if (match == null) continue;

      final index = int.tryParse(match.group(1)!);
      if (index != null && index > maxIndex) {
        maxIndex = index;
      }
    }

    final nextIndex = maxIndex + 1;

    final path = p.join(
      directory.path,
      '${safeFileName}_$nextIndex.docx',
    );

    return File(path).writeAsBytes(
      bytes,
      flush: true,
    );
  }

  Future<File> overwriteDocxFile({
    required Uint8List bytes,
    required Directory directory,
    required String fileName,
  }) async {
    final path = p.join(
      directory.path,
      fileName,
    );

    return File(path).writeAsBytes(
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

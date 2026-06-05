import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

class AbakFileExportService {
  const AbakFileExportService();

  Future<String?> savePackageJson({
    required String json,
    required String suggestedFileName,
  }) async {
    final outputPath = await FilePicker.platform.saveFile(
      dialogTitle: 'Exporter le package ABAK',
      fileName: _sanitizeFileName(suggestedFileName),
      type: FileType.custom,
      allowedExtensions: ['abak'],
    );

    debugPrint('🧪 saveFile outputPath = $outputPath');

    if (outputPath == null) {
      return null;
    }

    final path = outputPath.toLowerCase().endsWith('.abak')
        ? outputPath
        : '$outputPath.abak';

    debugPrint('🧪 final export path = $path');

    final file = File(path);

    await file.writeAsString(
      json,
      flush: true,
    );

    final exists = await file.exists();
    final length = exists ? await file.length() : 0;

    debugPrint('🧪 file exists after write = $exists');
    debugPrint('🧪 file length after write = $length');

    return path;
  }

  String _sanitizeFileName(String input) {
    final sanitized = input
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .trim();

    if (sanitized.isEmpty) {
      return 'abak_export.abak';
    }

    if (sanitized.toLowerCase().endsWith('.abak')) {
      return sanitized;
    }

    return '$sanitized.abak';
  }
}
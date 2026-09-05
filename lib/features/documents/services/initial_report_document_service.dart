import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as p;

import '../../../generated/l10n.dart';

class InitialReportDocumentService {
  const InitialReportDocumentService();

  Future<String?> pickExistingDocx() async {
    final result = await FilePicker.platform.pickFiles(
      dialogTitle: S.current.initialReportDocumentService_associate,
      type: FileType.custom,
      allowedExtensions: ['docx'],
      allowMultiple: false,
    );

    final path = result?.files.single.path;
    if (path == null || path.trim().isEmpty) {
      return null;
    }

    return path;
  }

  Future<bool> exists(String path) async {
    return File(path).exists();
  }

  String fileName(String path) {
    return p.basename(path);
  }

  Future<void> open(String path) async {
    if (Platform.isWindows) {
      await Process.run('cmd', ['/c', 'start', '', path]);
      return;
    }

    if (Platform.isMacOS) {
      await Process.run('open', [path]);
      return;
    }

    if (Platform.isLinux) {
      await Process.run('xdg-open', [path]);
      return;
    }

    throw UnsupportedError(S.current.initialReportDocumentService_unsupported);
  }
}

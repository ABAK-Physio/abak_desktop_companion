import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';

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
      final file = File(path);
      if (!await file.exists()) {
        throw FileSystemException('Fichier introuvable.', path);
      }
      final opened = await launchUrl(
        Uri.file(file.absolute.path, windows: true),
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        throw StateError(
          'Windows n’a pas pu ouvrir le document. Vérifiez l’application associée à ce type de fichier.',
        );
      }
      return;
    }

    if (Platform.isMacOS) {
      await const MethodChannel('abak/directory_access').invokeMethod<void>(
        p.extension(path).toLowerCase() == '.pdf' ? 'openPdf' : 'openDocx',
        {'path': path},
      );
      return;
    }

    if (Platform.isLinux) {
      await Process.run('xdg-open', [path]);
      return;
    }

    throw UnsupportedError(S.current.initialReportDocumentService_unsupported);
  }
}

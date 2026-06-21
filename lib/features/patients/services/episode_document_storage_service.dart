import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class EpisodeDocumentStorageService {
  Future<String> copyDocumentToEpisodeFolder({
    required String caseId,
    required String sourcePath,
  }) async {
    final sourceFile = File(sourcePath);

    if (!await sourceFile.exists()) {
      throw Exception('Fichier source introuvable : $sourcePath');
    }

    final appSupportDir = await getApplicationSupportDirectory();

    final documentsDir = Directory(
      p.join(
        appSupportDir.path,
        'episode_documents',
        caseId,
      ),
    );

    if (!await documentsDir.exists()) {
      await documentsDir.create(recursive: true);
    }

    final originalFileName = p.basename(sourcePath);
    final safeFileName = _safeFileName(originalFileName);
    final destinationPath = await _uniqueDestinationPath(
      directoryPath: documentsDir.path,
      fileName: safeFileName,
    );

    final copiedFile = await sourceFile.copy(destinationPath);

    return copiedFile.path;
  }

  Future<String> _uniqueDestinationPath({
    required String directoryPath,
    required String fileName,
  }) async {
    final extension = p.extension(fileName);
    final baseName = p.basenameWithoutExtension(fileName);

    var candidate = p.join(directoryPath, fileName);
    var counter = 1;

    while (await File(candidate).exists()) {
      candidate = p.join(
        directoryPath,
        '${baseName}_$counter$extension',
      );
      counter++;
    }

    return candidate;
  }

  String _safeFileName(String fileName) {
    return fileName
        .replaceAll(RegExp(r'[\\/:*?"<>|]'), '_')
        .trim();
  }
}
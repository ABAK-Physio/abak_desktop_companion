import 'dart:io';

class SmartCardConfigurationService {
  const SmartCardConfigurationService();

  File get configurationFile {
    if (Platform.isMacOS) {
      return File(
        '/Library/Application Support/santesocial/apilec/api_lec.ini',
      );
    }

    if (Platform.isWindows) {
      const candidates = <String>[
        r'C:\ProgramData\santesocial\api_lec64\api_lec.ini',
        r'C:\ProgramData\SESAM-Vitale\APILEC\api_lec.ini',
      ];

      for (final path in candidates) {
        final file = File(path);

        if (file.existsSync()) {
          return file;
        }
      }

      // Aucun fichier trouvé : on retourne le chemin le plus récent,
      // qui sera affiché dans les messages d'erreur.
      return File(candidates.first);
    }

    throw UnsupportedError(
      'Plateforme non prise en charge.',
    );
  }

  String updateReaderConfiguration(
      String iniContent,
      String readerName,
      ) {
    final lines = iniContent.split(RegExp(r'\r?\n'));

    final updatedLines = lines.map((line) {
      final trimmed = line.trimLeft();

      if (trimmed.startsWith('Ressource_Vitale=')) {
        return 'Ressource_Vitale=$readerName';
      }

      if (trimmed.startsWith('Ressource_CPS=')) {
        return 'Ressource_CPS=$readerName';
      }

      return line;
    }).toList();

    return updatedLines.join('\n');
  }

  Future<void> writeConfiguration(String content) async {
    final file = configurationFile;

    if (!await file.exists()) {
      throw FileSystemException(
        'Le fichier api_lec.ini est introuvable.',
        file.path,
      );
    }

    await file.writeAsString(
      content,
      flush: true,
    );
  }

  Future<void> configureReader(String readerName) async {
    final file = configurationFile;

    if (!await file.exists()) {
      throw FileSystemException(
        'Le fichier api_lec.ini est introuvable.',
        file.path,
      );
    }

    final currentContent = await file.readAsString();

    await backupFile.writeAsString(
      currentContent,
      flush: true,
    );

    final updatedContent = updateReaderConfiguration(
      currentContent,
      readerName,
    );

    await writeConfiguration(updatedContent);
  }

  File get backupFile {
    return File('${configurationFile.path}.bak');
  }

  Future<bool> backupFileExists() async {
    return backupFile.exists();
  }

  Future<bool> configurationFileExists() async {
    return configurationFile.exists();
  }

  Future<String?> readConfiguration() async {
    final file = configurationFile;

    if (!await file.exists()) {
      return null;
    }

    return file.readAsString();
  }
}
import 'dart:io';

import 'package:path/path.dart' as p;

import '../../../core/database/database_service.dart';
import '../../../core/settings/generated_documents_directory_service.dart';
import '../models/patient.dart';

class PatientDocumentFolders {
  const PatientDocumentFolders(this.path);

  final String path;
  String get assessment => p.join(path, 'Bilan');
  String get report => p.join(path, 'Rapport');
  String get other => p.join(path, 'Autre');
}

/// The caller must keep the root directory authorization alive while using it.
class PatientDocumentsService {
  const PatientDocumentsService();

  Future<PatientDocumentFolders?> ensureConfigured(String patientId) async {
    final access = await const GeneratedDocumentsDirectoryService()
        .acquireConfigured();
    if (access == null) return null;
    try {
      return await ensureInRoot(patientId: patientId, rootPath: access.path);
    } finally {
      await access.release();
    }
  }

  Future<PatientDocumentFolders> ensureInRoot({
    required String patientId,
    required String rootPath,
  }) async {
    final root = Directory(p.normalize(p.absolute(rootPath)));
    // Never silently recreate an unavailable volume or the configured root.
    if (!await root.exists()) {
      throw FileSystemException(
        'Dossier des documents indisponible',
        root.path,
      );
    }
    final db = await DatabaseService.database;
    // Serialize allocations, including two patients with identical identities.
    return db
        .transaction((txn) async {
          final patients = await txn.query(
            'patients',
            where: 'patient_id = ?',
            whereArgs: [patientId],
            limit: 1,
          );
          if (patients.isEmpty) throw StateError('Patient introuvable');
          final patient = Patient.fromMap(patients.single);
          final saved = await txn.query(
            'patient_document_folders',
            where: 'patient_id = ? AND root_path = ?',
            whereArgs: [patientId, root.path],
          );
          String folderName;
          if (saved.isNotEmpty) {
            folderName = saved.single['folder_name'] as String;
            if (p.basename(folderName) != folderName ||
                folderName == '.' ||
                folderName == '..' ||
                folderName.contains('\\')) {
              throw StateError('Nom du dossier patient invalide');
            }
          } else {
            final base = folderNameFor(patient);
            folderName = base;
            var suffix = 2;
            while (true) {
              final reserved = await txn.query(
                'patient_document_folders',
                where: 'root_path = ? AND folder_name = ? COLLATE NOCASE',
                whereArgs: [root.path, folderName],
                limit: 1,
              );
              final type = await FileSystemEntity.type(
                p.join(root.path, folderName),
                followLinks: false,
              );
              if (reserved.isEmpty && type == FileSystemEntityType.notFound) {
                break;
              }
              folderName = '${base}_$suffix';
              suffix++;
            }
            // Persist before creating files: a failed creation can be retried with
            // the same association, including after an application restart.
            await txn.insert('patient_document_folders', {
              'patient_id': patientId,
              'root_path': root.path,
              'folder_name': folderName,
            });
          }
          return PatientDocumentFolders(p.join(root.path, folderName));
        })
        .then((folders) async {
          await _ensureDirectory(folders.path);
          for (final path in [
            folders.assessment,
            folders.report,
            folders.other,
          ]) {
            await _ensureDirectory(path);
          }
          return folders;
        });
  }

  static String folderNameFor(Patient patient) {
    final date = patient.birthDate?.trim();
    final birth = date == null || date.isEmpty
        ? 'Sans date de naissance'
        : date;
    return '${_safeComponent(patient.lastName, 65)}_'
        '${_safeComponent(patient.firstName, 65)}_'
        '${_safeComponent(birth, 40)}';
  }

  static String _safeComponent(String value, int maxLength) {
    var name = value.replaceAll('ß', 'SS').toUpperCase();
    // Latin accents used by supported locales, plus common extended Latin names.
    const equivalents = {
      'A': 'ÀÁÂÃÄÅĀĂĄǍ',
      'C': 'ÇĆĈĊČ',
      'D': 'ÐĎĐ',
      'E': 'ÈÉÊËĒĔĖĘĚ',
      'G': 'ĜĞĠĢ',
      'H': 'ĤĦ',
      'I': 'ÌÍÎÏĨĪĬĮİǏ',
      'J': 'Ĵ',
      'K': 'Ķ',
      'L': 'ĹĻĽĿŁ',
      'N': 'ÑŃŅŇŊ',
      'O': 'ÒÓÔÕÖØŌŎŐǑ',
      'R': 'ŔŖŘ',
      'S': 'ŚŜŞŠȘ',
      'T': 'ŢŤŦȚ',
      'U': 'ÙÚÛÜŨŪŬŮŰŲǓ',
      'W': 'ŴẀẂẄ',
      'Y': 'ÝŸŶỲ',
      'Z': 'ŹŻŽ',
      'AE': 'Æ',
      'OE': 'Œ',
      'SS': 'ẞ',
      'TH': 'Þ',
    };
    for (final entry in equivalents.entries) {
      name = name.replaceAll(RegExp('[${entry.value}]'), entry.key);
    }
    name = name
        // Also handle accents stored separately from their base letter.
        .replaceAll(RegExp(r'[\u0300-\u036f]'), '')
        .replaceAll(RegExp(r'[^A-Z0-9_-]+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^[_-]+|[_-]+$'), '');
    if (name.length > maxLength) name = name.substring(0, maxLength);
    return name.isEmpty ? 'INCONNU' : name;
  }

  Future<void> _ensureDirectory(String path) async {
    final type = await FileSystemEntity.type(path, followLinks: false);
    if (type == FileSystemEntityType.directory) return;
    if (type != FileSystemEntityType.notFound) {
      throw FileSystemException(
        'Un fichier ou un lien occupe ce dossier',
        path,
      );
    }
    await Directory(path).create();
  }
}

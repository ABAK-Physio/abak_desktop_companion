import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;

import '../../../core/settings/generated_documents_directory_service.dart';
import '../../patients/data/patient_repository.dart';
import '../../patients/models/patient.dart';
import '../../patients/services/patient_documents_service.dart';
import 'backup_directory_access.dart';

class UserDataExportResult {
  const UserDataExportResult({
    required this.success,
    this.exportPath,
    this.patientCount = 0,
    this.fileCount = 0,
    this.errorCount = 0,
    this.error,
  });

  final bool success;
  final String? exportPath;
  final int patientCount;
  final int fileCount;
  final int errorCount;
  final String? error;
}

class UserDataExportService {
  UserDataExportService({
    PatientRepository? patientRepository,
    PatientDocumentsService? patientDocumentsService,
    BackupDirectoryAccess? destinationAccess,
  }) : patientRepository = patientRepository ?? PatientRepository(),
       patientDocumentsService =
           patientDocumentsService ?? const PatientDocumentsService(),
       destinationAccess = destinationAccess ?? const BackupDirectoryAccess();

  final PatientRepository patientRepository;
  final PatientDocumentsService patientDocumentsService;
  final BackupDirectoryAccess destinationAccess;

  Future<UserDataExportResult> export({
    required bool includeArchivedPatients,
    required String chooseDestinationTitle,
    required String cancelledMessage,
    required String patientLastNameLabel,
    required String patientFirstNameLabel,
    required String patientBirthDateLabel,
    required String patientSexLabel,
    required String patientMaleLabel,
    required String patientFemaleLabel,
    required String patientUnknownLabel,
    required String patientUnknownFemaleLabel,
  }) async {
    GeneratedDocumentsDirectoryAccess? documentsAccess;
    BackupDirectoryLease? destination;
    String? partialPath;

    try {
      final patients = await patientRepository.getAllPatients();

      if (includeArchivedPatients) {
        patients.addAll(await patientRepository.getArchivedPatients());
      }

      documentsAccess = await const GeneratedDocumentsDirectoryService()
          .acquireConfigured();

      destination = await destinationAccess.choose(chooseDestinationTitle);
      if (destination == null) {
        return UserDataExportResult(success: false, error: cancelledMessage);
      }

      final date = DateTime.now().toIso8601String().substring(0, 10);
      final outputPath = await _availableExportPath(
        destination.path,
        'ABAK_Export_$date',
      );
      partialPath = '$outputPath.partial';

      final encoder = ZipFileEncoder();
      encoder.create(partialPath);

      var patientCount = 0;
      var fileCount = 0;
      final errors = <String>[];

      try {
        final usedPatientFolderNames = <String>{};
        for (final patient in patients) {
          final basePatientFolderName = PatientDocumentsService.folderNameFor(
            patient,
          );

          var patientFolderName = basePatientFolderName;
          var suffix = 2;

          while (usedPatientFolderNames.contains(
            patientFolderName.toLowerCase(),
          )) {
            patientFolderName = '${basePatientFolderName}_$suffix';
            suffix++;
          }

          usedPatientFolderNames.add(patientFolderName.toLowerCase());

          final patientArchivePath = patientFolderName;

          final patientText = _patientText(
            patient,
            lastNameLabel: patientLastNameLabel,
            firstNameLabel: patientFirstNameLabel,
            birthDateLabel: patientBirthDateLabel,
            sexLabel: patientSexLabel,
            maleLabel: patientMaleLabel,
            femaleLabel: patientFemaleLabel,
            unknownLabel: patientUnknownLabel,
            unknownFemaleLabel: patientUnknownFemaleLabel,
          );
          final patientTextBytes = utf8.encode(patientText);

          encoder.addArchiveFile(
            ArchiveFile(
              p.posix.join(patientArchivePath, 'Patient.txt'),
              patientTextBytes.length,
              patientTextBytes,
            ),
          );

          patientCount++;

          if (documentsAccess == null) {
            continue;
          }

          try {
            final folders = await patientDocumentsService.findInRoot(
              patientId: patient.patientId,
              rootPath: documentsAccess.path,
            );

            if (folders == null) continue;

            fileCount += await _addDirectoryContents(
              encoder: encoder,
              sourcePath: folders.assessment,
              archivePath: p.posix.join(patientArchivePath, 'Bilan'),
              errors: errors,
            );

            fileCount += await _addDirectoryContents(
              encoder: encoder,
              sourcePath: folders.report,
              archivePath: p.posix.join(patientArchivePath, 'Rapport'),
              errors: errors,
            );
          } catch (error) {
            errors.add('$patientFolderName : $error');
          }
        }

        if (errors.isNotEmpty) {
          final content = utf8.encode('${errors.join('\n')}\n');
          encoder.addArchiveFile(
            ArchiveFile('Erreurs_export.txt', content.length, content),
          );
        }
      } finally {
        encoder.close();
      }

      await File(partialPath).rename(outputPath);
      partialPath = null;

      return UserDataExportResult(
        success: true,
        exportPath: outputPath,
        patientCount: patientCount,
        fileCount: fileCount,
        errorCount: errors.length,
      );
    } catch (error) {
      return UserDataExportResult(success: false, error: error.toString());
    } finally {
      if (partialPath != null) {
        final partial = File(partialPath);
        if (await partial.exists()) {
          await partial.delete();
        }
      }

      await documentsAccess?.release();
      await destination?.release();
    }
  }

  Future<int> _addDirectoryContents({
    required ZipFileEncoder encoder,
    required String sourcePath,
    required String archivePath,
    required List<String> errors,
  }) async {
    final directory = Directory(sourcePath);

    if (!await directory.exists()) return 0;

    var count = 0;

    await for (final entity in directory.list(
      recursive: true,
      followLinks: false,
    )) {
      if (entity is! File) continue;

      final relativePath = p.relative(entity.path, from: sourcePath);
      final zipPath = p.posix.join(
        archivePath,
        relativePath.replaceAll('\\', '/'),
      );

      try {
        await encoder.addFile(entity, zipPath);
        count++;
      } catch (error) {
        errors.add('${entity.path} : $error');
      }
    }

    return count;
  }

  Future<String> _availableExportPath(
    String destinationPath,
    String baseName,
  ) async {
    var candidate = p.join(destinationPath, '$baseName.zip');
    var suffix = 2;

    while (await File(candidate).exists() ||
        await File('$candidate.partial').exists()) {
      candidate = p.join(destinationPath, '${baseName}_$suffix.zip');
      suffix++;
    }

    return candidate;
  }

  String _patientText(
    Patient patient, {
    required String lastNameLabel,
    required String firstNameLabel,
    required String birthDateLabel,
    required String sexLabel,
    required String maleLabel,
    required String femaleLabel,
    required String unknownLabel,
    required String unknownFemaleLabel,
  }) {
    return '$lastNameLabel : ${patient.lastName}\n'
        '$firstNameLabel : ${patient.firstName}\n'
        '$birthDateLabel : ${_displayBirthDate(patient.birthDate, unknownFemaleLabel)}\n'
        '$sexLabel : ${_displaySex(patient.sexCode, maleLabel, femaleLabel, unknownLabel)}\n';
  }

  String _displayBirthDate(String? value, String unknownValue) {
    if (value == null || value.trim().isEmpty) {
      return unknownValue;
    }

    final date = DateTime.tryParse(value);
    if (date == null) return value;

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _displaySex(
    String value,
    String maleLabel,
    String femaleLabel,
    String unknownLabel,
  ) {
    switch (value.trim().toUpperCase()) {
      case 'M':
        return maleLabel;
      case 'F':
        return femaleLabel;
      default:
        return unknownLabel;
    }
  }
}

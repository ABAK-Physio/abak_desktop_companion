import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../patients/models/patient.dart';
import 'abak_import_service.dart';
import 'abak_package.dart';
import 'data/import_session_repository.dart';
import 'import_resolution_screen.dart';
import 'services/abak_import_resolution_service.dart';

class AbakImportLauncher {
  static Future<AbakImportLauncherResult?> importArchiveFromPicker(
      BuildContext context, {
        VoidCallback? onImportCompleted,
      }) async {
    final importSessionRepository = ImportSessionRepository();
    final importService = AbakImportService();
    final resolutionService = AbakImportResolutionService();

    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.custom,
        allowedExtensions: ['abak', 'json'],
      );

      if (result == null) return null;

      final importSessionId =
      await importSessionRepository.startSession(
        sourceLabel: 'manual_file_picker',
      );

      int processedFiles = 0;
      int failedFiles = 0;
      int totalImportedResults = 0;
      int totalSkippedResults = 0;
      int totalImportedMetrics = 0;
      int totalConflictResults = 0;

      final resolutionMessages = <String>[];
      final failedFileNames = <String>[];
      final importedPatientIds = <String>{};
      final importedPatientLabels = <String>{};

      for (final pickedFile in result.files) {
        try {
          final path = pickedFile.path;

          if (path == null) {
            failedFiles++;
            failedFileNames.add(pickedFile.name);
            continue;
          }

          final file = File(path);
          final jsonString = await file.readAsString();

          final decoded = jsonDecode(jsonString)
          as Map<String, dynamic>;

          debugPrint('🧪 PACKAGE KEYS = ${decoded.keys.toList()}');
          debugPrint('🧪 mobileCase = ${decoded['mobileCase']}');
          debugPrint('🧪 clinicalEpisode = ${decoded['clinicalEpisode']}');

          final package = AbakPackage.fromJson(decoded);



          final resolution =
          await resolutionService.resolve(package);

          resolutionMessages.add(
            '${pickedFile.name} : ${resolution.displayLabel}',
          );

          Patient? targetPatient = resolution.patient;

          if (!resolution.canImportAutomatically) {
            if (!context.mounted) {
              failedFiles++;
              failedFileNames.add(pickedFile.name);
              continue;
            }

            targetPatient =
            await Navigator.of(context).push<Patient>(
              MaterialPageRoute(
                builder: (_) => ImportResolutionScreen(
                  package: package,
                ),
              ),
            );
          }

          debugPrint(
            '🔗 LINK CASE -> PATIENT '
                'case=${resolution.mobileCase?.caseId} '
                'patient=${targetPatient?.patientId}',
          );

          if (!resolution.canImportAutomatically &&
              targetPatient != null) {
            resolutionMessages.add(
              '${pickedFile.name} : '
                  'rattaché à ${targetPatient.displayName}',
            );
          }

          if (targetPatient == null) {
            failedFiles++;
            failedFileNames.add(pickedFile.name);
            continue;
          }

          if (!resolution.canImportAutomatically &&
              // ignore: unnecessary_null_comparison
              targetPatient != null) {
            await resolutionService.linkMobileCaseToPatient(
              mobileCase: resolution.mobileCase,
              patientId: targetPatient.patientId,
            );
          }

          importedPatientIds.add(targetPatient.patientId);
          importedPatientLabels.add(targetPatient.displayName);

          final summary =
          await importService.importPackageJson(
            jsonString: jsonString,
            patient: targetPatient,
          );

          await importSessionRepository.addFileLog(
            importSessionId: importSessionId,
            fileName: pickedFile.name,
            fileSize: pickedFile.size,
            status: 'success',
            importedResultsCount:
            summary.importedResults,
            skippedResultsCount:
            summary.skippedResults,
            importedMetricsCount:
            summary.importedMetrics,
            conflictResultsCount:
            summary.conflictResults,
          );

          processedFiles++;
          totalImportedResults +=
              summary.importedResults;

          totalSkippedResults +=
              summary.skippedResults;

          totalImportedMetrics +=
              summary.importedMetrics;

          totalConflictResults +=
              summary.conflictResults;
        } catch (e, stack) {
          failedFiles++;
          failedFileNames.add(pickedFile.name);

          await importSessionRepository.addFileLog(
            importSessionId: importSessionId,
            fileName: pickedFile.name,
            fileSize: pickedFile.size,
            status: 'error',
            importedResultsCount: 0,
            skippedResultsCount: 0,
            conflictResultsCount: 0,
            importedMetricsCount: 0,
            errorMessage: e.toString(),
          );

          debugPrint(
            '❌ Erreur import fichier '
                '${pickedFile.name} : $e',
          );

          debugPrint('$stack');
        }
      }

      await importSessionRepository.completeSession(
        importSessionId: importSessionId,
        processedFilesCount: processedFiles,
        failedFilesCount: failedFiles,
        importedResultsCount:
        totalImportedResults,
        skippedResultsCount:
        totalSkippedResults,
        conflictResultsCount:
        totalConflictResults,
        importedMetricsCount:
        totalImportedMetrics,
      );


      final launcherResult = AbakImportLauncherResult(
        processedFiles: processedFiles,
        failedFiles: failedFiles,
        importedResults: totalImportedResults,
        skippedResults: totalSkippedResults,
        conflictResults: totalConflictResults,
        importedMetrics: totalImportedMetrics,
        patientIds: importedPatientIds.toList(),
        patientLabels: importedPatientLabels.toList(),
        completedAt: DateTime.now(),
      );

      if (!context.mounted) {
        return launcherResult;
      }

      onImportCompleted?.call();

      final errorSuffix = failedFiles == 0
          ? ''
          : ' $failedFiles fichier(s) en erreur.';

      final resolutionText =
      resolutionMessages.isEmpty
          ? ''
          : '\n\nRésolution :\n'
          '${resolutionMessages.join('\n')}';

      if (failedFileNames.isNotEmpty) {
        debugPrint(
          '❌ Fichiers non importés : '
              '${failedFileNames.join(', ')}',
        );
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 5),
          behavior:
          SnackBarBehavior.floating,
          content: Text(
            'Import terminé\n\n'
                'Fichiers traités : '
                '${launcherResult.processedFiles}\n'
                'Résultats importés : '
                '${launcherResult.importedResults}\n'
                'Résultats ignorés : '
                '${launcherResult.skippedResults}\n'
                'Conflits : '
                '${launcherResult.conflictResults}\n'
                'Métriques importées : '
                '${launcherResult.importedMetrics}'
                '$errorSuffix'
                '$resolutionText',
            style: const TextStyle(
              height: 1.4,
            ),
          ),
        ),
      );

      return launcherResult;
    } catch (e, stack) {
      debugPrint('❌ Erreur import package : $e');
      debugPrint('$stack');

      if (!context.mounted) {
        return null;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur import : $e',
          ),
        ),
      );

      return null;
    }
  }
  static Future<Map<String, dynamic>> importArchiveFromPath(
      String filePath, {
        String sourceLabel = 'local_network_upload',
      }) async {
    final importSessionRepository = ImportSessionRepository();
    final importService = AbakImportService();
    final resolutionService = AbakImportResolutionService();

    final file = File(filePath);
    final fileName = file.uri.pathSegments.last;

    if (!await file.exists()) {
      return {
        'status': 'error',
        'message': 'Fichier introuvable.',
        'fileName': fileName,
        'filePath': filePath,
      };
    }

    final importSessionId = await importSessionRepository.startSession(
      sourceLabel: sourceLabel,
    );

    try {
      final jsonString = await file.readAsString();
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final package = AbakPackage.fromJson(decoded);

      final resolution = await resolutionService.resolve(package);

      debugPrint(
        '🧭 RESOLUTION '
            'type=${resolution.type} '
            'case=${resolution.mobileCase?.caseId} '
            'patient=${resolution.patient?.patientId}',
      );

      if (!resolution.canImportAutomatically ||
          resolution.patient == null) {
        await importSessionRepository.addFileLog(
          importSessionId: importSessionId,
          fileName: fileName,
          filePath: filePath,
          fileSize: await file.length(),
          status: 'needs_resolution',
          importedResultsCount: 0,
          skippedResultsCount: 0,
          conflictResultsCount: 0,
          importedMetricsCount: 0,
        );

        await importSessionRepository.completeSession(
          importSessionId: importSessionId,
          processedFilesCount: 0,
          failedFilesCount: 0,
          importedResultsCount: 0,
          skippedResultsCount: 0,
          conflictResultsCount: 0,
          importedMetricsCount: 0,
          status: 'needs_resolution',
        );

        return {
          'status': 'needs_resolution',
          'message': 'Rattachement patient requis.',
          'fileName': fileName,
          'filePath': filePath,
          'resolution': resolution.displayLabel,
        };
      }

      final targetPatient = resolution.patient!;

      final summary = await importService.importPackageJson(
        jsonString: jsonString,
        patient: targetPatient,
      );

      await importSessionRepository.addFileLog(
        importSessionId: importSessionId,
        fileName: fileName,
        filePath: filePath,
        fileSize: await file.length(),
        status: 'success',
        importedResultsCount: summary.importedResults,
        skippedResultsCount: summary.skippedResults,
        conflictResultsCount: summary.conflictResults,
        importedMetricsCount: summary.importedMetrics,
      );

      await importSessionRepository.completeSession(
        importSessionId: importSessionId,
        processedFilesCount: 1,
        failedFilesCount: 0,
        importedResultsCount: summary.importedResults,
        skippedResultsCount: summary.skippedResults,
        conflictResultsCount: summary.conflictResults,
        importedMetricsCount: summary.importedMetrics,
      );

      return {
        'status': 'ok',
        'message': 'Import automatique effectué.',
        'fileName': fileName,
        'filePath': filePath,
        'patientId': targetPatient.patientId,
        'patientLabel': targetPatient.displayName,
        'importedResults': summary.importedResults,
        'skippedResults': summary.skippedResults,
        'conflictResults': summary.conflictResults,
        'importedMetrics': summary.importedMetrics,
      };
    } catch (e, stack) {
      debugPrint('❌ Erreur import réseau $fileName : $e');
      debugPrint('$stack');

      await importSessionRepository.addFileLog(
        importSessionId: importSessionId,
        fileName: fileName,
        filePath: filePath,
        fileSize: await file.length(),
        status: 'error',
        importedResultsCount: 0,
        skippedResultsCount: 0,
        conflictResultsCount: 0,
        importedMetricsCount: 0,
        errorMessage: e.toString(),
      );

      await importSessionRepository.completeSession(
        importSessionId: importSessionId,
        processedFilesCount: 0,
        failedFilesCount: 1,
        importedResultsCount: 0,
        skippedResultsCount: 0,
        conflictResultsCount: 0,
        importedMetricsCount: 0,
      );

      return {
        'status': 'error',
        'message': 'Erreur import : $e',
        'fileName': fileName,
        'filePath': filePath,
      };
    }
  }

  static Future<AbakImportLauncherResult?> importArchiveFromPathWithResolution(
      BuildContext context,
      String filePath, {
        VoidCallback? onImportCompleted,
      }) async {
    final importSessionRepository = ImportSessionRepository();
    final importService = AbakImportService();
    final resolutionService = AbakImportResolutionService();

    final file = File(filePath);
    final fileName = file.uri.pathSegments.last;

    if (!await file.exists()) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Fichier introuvable : $fileName')),
        );
      }
      return null;
    }

    final importSessionId = await importSessionRepository.startSession(
      sourceLabel: 'manual_resolution_from_incoming',
    );

    try {
      final jsonString = await file.readAsString();
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final package = AbakPackage.fromJson(decoded);

      final resolution = await resolutionService.resolve(package);
      Patient? targetPatient = resolution.patient;

      debugPrint(
        '🔗 LINK CASE -> PATIENT '
            'case=${resolution.mobileCase?.caseId} '
            'patient=${targetPatient?.patientId}',
      );

      if (!resolution.canImportAutomatically) {
        if (!context.mounted) return null;

        targetPatient = await Navigator.of(context).push<Patient>(
          MaterialPageRoute(
            builder: (_) => ImportResolutionScreen(
              package: package,
            ),
          ),
        );
      }

      //
      debugPrint(
        '🔗 LINK CASE -> PATIENT '
            'case=${resolution.mobileCase?.caseId} '
            'patient=${targetPatient?.patientId}',
      );


      if (!resolution.canImportAutomatically &&
          targetPatient != null) {
        await resolutionService.linkMobileCaseToPatient(
          mobileCase: resolution.mobileCase,
          patientId: targetPatient.patientId,
        );
      }

      if (targetPatient == null) {
        await importSessionRepository.completeSession(
          importSessionId: importSessionId,
          processedFilesCount: 0,
          failedFilesCount: 1,
          importedResultsCount: 0,
          skippedResultsCount: 0,
          conflictResultsCount: 0,
          importedMetricsCount: 0,
        );

        return null;
      }

      final summary = await importService.importPackageJson(
        jsonString: jsonString,
        patient: targetPatient,
      );

      await importSessionRepository.addFileLog(
        importSessionId: importSessionId,
        fileName: fileName,
        fileSize: await file.length(),
        status: 'success',
        importedResultsCount: summary.importedResults,
        skippedResultsCount: summary.skippedResults,
        conflictResultsCount: summary.conflictResults,
        importedMetricsCount: summary.importedMetrics,
      );

      await importSessionRepository.completeSession(
        importSessionId: importSessionId,
        processedFilesCount: 1,
        failedFilesCount: 0,
        importedResultsCount: summary.importedResults,
        skippedResultsCount: summary.skippedResults,
        conflictResultsCount: summary.conflictResults,
        importedMetricsCount: summary.importedMetrics,
      );
      await importSessionRepository.markFilesResolvedByPath(filePath);

      final launcherResult = AbakImportLauncherResult(
        processedFiles: 1,
        failedFiles: 0,
        importedResults: summary.importedResults,
        skippedResults: summary.skippedResults,
        conflictResults: summary.conflictResults,
        importedMetrics: summary.importedMetrics,
        patientIds: [targetPatient.patientId],
        patientLabels: [targetPatient.displayName],
        completedAt: DateTime.now(),
      );

      onImportCompleted?.call();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Import terminé : ${summary.importedResults} résultat(s) importé(s).',
            ),
          ),
        );
      }

      return launcherResult;
    } catch (e, stack) {
      debugPrint('❌ Erreur rattachement manuel $fileName : $e');
      debugPrint('$stack');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur import : $e')),
        );
      }

      return null;
    }
  }
}
class AbakImportLauncherResult {
  final int processedFiles;
  final int failedFiles;
  final int importedResults;
  final int skippedResults;
  final int conflictResults;
  final int importedMetrics;
  final DateTime completedAt;

  final List<String> patientIds;
  final List<String> patientLabels;

  const AbakImportLauncherResult({
    required this.processedFiles,
    required this.failedFiles,
    required this.importedResults,
    required this.skippedResults,
    required this.conflictResults,
    required this.importedMetrics,
    required this.patientIds,
    required this.patientLabels,
    required this.completedAt,
  });

  bool get hasFailures => failedFiles > 0;

  bool get hasImportedSomething =>
      importedResults > 0 || importedMetrics > 0;

  bool get hasPatients => patientLabels.isNotEmpty;

  @override
  String toString() {
    return 'AbakImportLauncherResult('
        'processedFiles: $processedFiles, '
        'failedFiles: $failedFiles, '
        'importedResults: $importedResults, '
        'skippedResults: $skippedResults, '
        'conflictResults: $conflictResults, '
        'importedMetrics: $importedMetrics, '
        'patientIds: $patientIds, '
        'patientLabels: $patientLabels'
        'completedAt: $completedAt, '
        ')';
  }
}
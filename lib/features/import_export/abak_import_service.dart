import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:abak_shared/abak_shared.dart';
import '../patients/models/patient.dart';
import '../results/data/desktop_result_repository.dart';
import '../results/models/desktop_result.dart';
import '../results/models/desktop_result_metric.dart';
import '../results/utils/result_hash_utils.dart';
import 'abak_package.dart';

class AbakImportService {
  final DesktopResultRepository _repository = DesktopResultRepository();

  Future<AbakImportSummary> importPackageJson({
    required String jsonString,
    required Patient patient,
    required String careEpisodeId,
  }) async {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    final package = AbakPackage.fromJson(decoded);

    int importedResults = 0;
    int skippedResults = 0;
    int conflictResults = 0;
    int importedMetrics = 0;

    final exerciseLabels = <String>{};

    final summaryPatientLabel = patient.displayName;
    final summaryEpisodeLabel =
        package.clinicalEpisode?.pathologyLabel ??
            package.clinicalEpisode?.episodeId;

    for (final rawResult in package.results) {
      final resultMap = rawResult.raw;

      final exoId = resultMap['exoId']?.toString();

      if (exoId != null && exoId.isNotEmpty) {
        exerciseLabels.add(
          ClinicalActivityCatalog.displayLabel(exoId),
        );
      }

      final resultId = resultMap['result_id']?.toString();

      if (resultId == null || resultId.isEmpty) {
        debugPrint(
          '⏭️ Résultat ignoré : result_id absent ou vide. '
              'exoId=${resultMap['exoId']}, '
              'createdAt=${resultMap['createdAt']}',
        );

        skippedResults++;
        continue;
      }

      final incomingHash =
          resultMap['content_hash']?.toString() ??
              ResultHashUtils.computeHash(
                resultId: resultId,
                exoId: resultMap['exoId']?.toString() ?? '',
                createdAt: (resultMap['createdAt'] as num?)?.toInt() ?? 0,
                scoreTotal: (resultMap['scoreTotal'] as num?)?.toDouble(),
                exportSimpleText: resultMap['exportSimpleText']?.toString() ?? '',
              );

      final alreadyExists = await _repository.resultExists(resultId);

      debugPrint('📥 Import result_id=$resultId');
      debugPrint('📥 alreadyExists=$alreadyExists');
      debugPrint('📥 incomingHash=$incomingHash');

      if (alreadyExists) {
        final existingHash = await _repository.getContentHashForResult(
          resultId,
        );

        debugPrint('🧪 HASH CHECK result_id=$resultId');
        debugPrint('🧪 existingHash=$existingHash');
        debugPrint('🧪 incomingHash=$incomingHash');
        debugPrint('🧪 exportSimpleText=${resultMap['exportSimpleText']}');
        debugPrint('🧪 scoreTotal=${resultMap['scoreTotal']}');
        debugPrint('🧪 createdAt=${resultMap['createdAt']}');
        debugPrint('🧪 exoId=${resultMap['exoId']}');

        if (existingHash == incomingHash) {
          debugPrint(
            '⏭️ Résultat ignoré comme doublon : '
                'resultId=$resultId, '
                'exoId=${resultMap['exoId']}, '
                'createdAt=${resultMap['createdAt']}',
          );

          skippedResults++;
          continue;
        }

        final existingRawResult = await _repository.getRawResultById(resultId);

        await _repository.saveResultConflict(
          resultId: resultId,
          existingHash: existingHash,
          incomingHash: incomingHash,
          existingJson: existingRawResult == null
              ? null
              : jsonEncode(existingRawResult),
          incomingJson: jsonEncode(resultMap),
        );

        await _repository.markResultAsConflict(resultId);

        conflictResults++;

        debugPrint('⚠️ Conflit détecté et sauvegardé pour result_id=$resultId');

        continue;
      }

      final clinicalEpisode = package.clinicalEpisode;

      final result = DesktopResult(
        resultId: resultId,
        careEpisodeId: careEpisodeId,
        patientId: patient.patientId,
        practitionerId: package.practitioner?.practitionerId,
        sourceDeviceId: package.sourceDevice?.deviceId,
        practitionerLabelSnapshot: package.practitioner?.displayName,
        mobileEpisodeId:
        resultMap['episode_id']?.toString() ?? clinicalEpisode?.episodeId,
        mobilePathologyCode: clinicalEpisode?.pathologyCode,
        mobilePathologyLabel: clinicalEpisode?.pathologyLabel,
        mobilePatientRef: clinicalEpisode?.patientRef,
        mobilePatientLabel: clinicalEpisode?.patientLabel,
        createdAt:
        (resultMap['createdAt'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
        importedAt: DateTime.now().millisecondsSinceEpoch,
        exoId: resultMap['exoId']?.toString() ?? 'UNKNOWN',
        scoreTotal: (resultMap['scoreTotal'] as num?)?.toDouble(),
        comment: resultMap['comment']?.toString(),
        exportSimpleText: resultMap['exportSimpleText']?.toString() ?? '',
        simpleExportSnapshotJson: resultMap['simpleExportSnapshotJson']
            ?.toString(),
        profileJson: resultMap['profileJson']?.toString(),
        structuredJson: resultMap['structuredJson']?.toString(),
        ageYears: (resultMap['ageYears'] as num?)?.toInt(),
        sexCode: resultMap['sexCode']?.toString(),
        testedSideCode: resultMap['testedSideCode']?.toString(),
        measureUnit: resultMap['measureUnit']?.toString(),
        heightCm: (resultMap['heightCm'] as num?)?.toInt(),
        weightKg: (resultMap['weightKg'] as num?)?.toDouble(),
        bmi: (resultMap['bmi'] as num?)?.toDouble(),
        sportLevelCode: resultMap['sportLevelCode']?.toString(),
        contextCode: resultMap['contextCode']?.toString(),
        testCode: resultMap['testCode']?.toString(),
        testVersion: (resultMap['testVersion'] as num?)?.toInt(),
        testFamily: resultMap['testFamily']?.toString(),
        performerCountryCode: resultMap['performerCountryCode']?.toString(),
        performerRegionCode: resultMap['performerRegionCode']?.toString(),
        performerMainActivityCode:
        resultMap['performerMainActivityCode']?.toString(),
        performerMainSpecialtyCode:
        resultMap['performerMainSpecialtyCode']?.toString(),
        performerYearsExperienceCode:
        resultMap['performerYearsExperienceCode']?.toString(),
        performerProfileUpdatedAt:
        (resultMap['performerProfileUpdatedAt'] as num?)?.toInt(),
        syncState: 'imported',
        lastModifiedAt:
        (resultMap['last_modified_at'] as num?)?.toInt() ??
            DateTime.now().millisecondsSinceEpoch,
        contentHash: incomingHash,
        localSchemaVersion: (resultMap['localSchemaVersion'] as num?)?.toInt(),
      );

      final rawMetrics = (resultMap['metrics'] as List?) ?? const [];

      final metrics = rawMetrics
          .whereType<Map<String, dynamic>>()
          .map(
            (metricMap) => DesktopResultMetric(
          metricId: metricMap['metric_id']?.toString() ?? '',
          resultId: resultId,
          metricKey: metricMap['metric_key']?.toString() ?? '',
          value: (metricMap['value'] as num?)?.toDouble() ?? 0,
          unit: metricMap['unit']?.toString(),
          label: metricMap['label']?.toString(),
        ),
      )
          .toList();

      await _repository.insertResultWithMetrics(
        result: result,
        metrics: metrics,
      );

      importedResults++;
      importedMetrics += metrics.length;
    }

    return AbakImportSummary(
      importedResults: importedResults,
      skippedResults: skippedResults,
      conflictResults: conflictResults,
      importedMetrics: importedMetrics,
      summaryPatientLabel: summaryPatientLabel,
      summaryEpisodeLabel: summaryEpisodeLabel,
      summaryExercisesLabel:
      exerciseLabels.isEmpty ? null : exerciseLabels.join(', '),
    );
  }
}

class AbakImportSummary {
  final int importedResults;
  final int skippedResults;
  final int conflictResults;
  final int importedMetrics;

  final String? summaryPatientLabel;
  final String? summaryEpisodeLabel;
  final String? summaryExercisesLabel;

  const AbakImportSummary({
    required this.importedResults,
    required this.skippedResults,
    required this.conflictResults,
    required this.importedMetrics,
    required this.summaryPatientLabel,
    required this.summaryEpisodeLabel,
    required this.summaryExercisesLabel,
  });
}
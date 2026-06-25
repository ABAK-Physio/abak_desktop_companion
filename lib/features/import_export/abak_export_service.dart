import 'dart:convert';

import '../patients/models/patient.dart';
import '../results/data/desktop_result_repository.dart';
import '../results/models/desktop_result.dart';
import 'abak_package.dart';

class AbakExportService {
  AbakExportService({
    DesktopResultRepository? repository,
  }) : _repository = repository ?? DesktopResultRepository();

  final DesktopResultRepository _repository;

  Future<String> exportPatientPackageJson({
    required Patient patient,
    List<String>? resultIds,
    List<String>? syncStates,
  }) async {
    final results = await _loadResults(
      patientId: patient.patientId,
      resultIds: resultIds,
      syncStates: syncStates,
    );

    final metrics = await _repository.getMetricsForResultIds(
      results.map((r) => r.resultId).toList(),
    );

    final package = AbakPackage(
      schemaVersion: 2,
      exportedAt: DateTime.now().millisecondsSinceEpoch,
      sourceDevice: const AbakSourceDevice(
        deviceId: 'desktop-macos',
        deviceLabel: 'ABAK Desktop Companion',
        platform: 'macos',
      ),
      practitioner: _buildPractitionerSnapshot(results),
      patient: AbakPatientSnapshot(
        localPatientId: patient.patientId,
        lastName: patient.lastName,
        firstName: patient.firstName,
        birthDate: patient.birthDate,
        sexCode: patient.sexCode,
      ),
      results: results
          .map((result) => AbakResultPayload(
        raw: _buildResultPayload(result),
      ))
          .toList(),
      metrics: metrics
          .map((metric) => AbakMetricPayload(raw: metric.toMap()))
          .toList(),
    );

    return const JsonEncoder.withIndent('  ').convert(package.toJson());
  }

  Future<List<DesktopResult>> _loadResults({
    required String patientId,
    List<String>? resultIds,
    List<String>? syncStates,
  }) {
    if (resultIds != null && resultIds.isNotEmpty) {
      return _repository.getResultsByIds(resultIds);
    }

    return _repository.getResultsForPatient(
      patientId,
      syncStates: syncStates,
    );
  }

  AbakPractitionerSnapshot? _buildPractitionerSnapshot(
      List<DesktopResult> results,
      ) {
    if (results.isEmpty) {
      return null;
    }

    final first = results.first;

    if (first.practitionerId == null &&
        first.practitionerLabelSnapshot == null) {
      return null;
    }

    return AbakPractitionerSnapshot(
      practitionerId: first.practitionerId,
      displayName: first.practitionerLabelSnapshot ?? 'Praticien ABAK',
    );
  }

  Map<String, dynamic> _buildResultPayload(DesktopResult result) {
    return {
      'result_id': result.resultId,
      'episode_id': result.mobileEpisodeId,
      'createdAt': result.createdAt,
      'exoId': result.exoId,
      'scoreTotal': result.scoreTotal,
      'comment': result.comment,
      'exportSimpleText': result.exportSimpleText,
      'simpleExportSnapshotJson': result.simpleExportSnapshotJson,
      'profileJson': result.profileJson,
      'structuredJson': result.structuredJson,
      'ageYears': result.ageYears,
      'sexCode': result.sexCode,
      'testedSideCode': result.testedSideCode,
      'measureUnit': result.measureUnit,
      'heightCm': result.heightCm,
      'weightKg': result.weightKg,
      'bmi': result.bmi,
      'sportLevelCode': result.sportLevelCode,
      'contextCode': result.contextCode,
      'testCode': result.testCode,
      'testVersion': result.testVersion,
      'testFamily': result.testFamily,
      'performerCountryCode': result.performerCountryCode,
      'performerRegionCode': result.performerRegionCode,
      'performerMainActivityCode': result.performerMainActivityCode,
      'performerMainSpecialtyCode': result.performerMainSpecialtyCode,
      'performerYearsExperienceCode': result.performerYearsExperienceCode,
      'performerProfileUpdatedAt': result.performerProfileUpdatedAt,
      'localSchemaVersion': result.localSchemaVersion,
      'content_hash': result.contentHash,
    };
  }
}
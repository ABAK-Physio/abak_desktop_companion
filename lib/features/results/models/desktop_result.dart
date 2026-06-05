class DesktopResult {
  final String resultId;
  final String patientId;
  final String? practitionerId;
  final String? sourceDeviceId;
  final String? practitionerLabelSnapshot;
  final String? episodeId;
  final int createdAt;
  final int importedAt;
  final String exoId;
  final double? scoreTotal;
  final String? comment;
  final String exportSimpleText;
  final String? simpleExportSnapshotJson;
  final String? profileJson;
  final String? structuredJson;
  final int? ageYears;
  final String? sexCode;
  final String? testedSideCode;
  final String? measureUnit;
  final int? heightCm;
  final double? weightKg;
  final double? bmi;
  final String? sportLevelCode;
  final String? contextCode;
  final String? testCode;
  final int? testVersion;
  final String? testFamily;
  final String? performerCountryCode;
  final String? performerRegionCode;
  final String? performerMainActivityCode;
  final String? performerMainSpecialtyCode;
  final String? performerYearsExperienceCode;
  final int? performerProfileUpdatedAt;
  final int? localSchemaVersion;

  final String syncState;
  final int? lastModifiedAt;
  final String? contentHash;

  final int? archivedAt;
  final String? mobileCaseId;
  final String? mobileCaseLabel;

  const DesktopResult({
    required this.resultId,
    required this.patientId,
    this.practitionerId,
    this.sourceDeviceId,
    this.practitionerLabelSnapshot,
    this.episodeId,
    required this.createdAt,
    required this.importedAt,
    required this.exoId,
    this.scoreTotal,
    this.comment,
    required this.exportSimpleText,
    this.simpleExportSnapshotJson,
    this.profileJson,
    this.structuredJson,
    this.ageYears,
    this.sexCode,
    this.testedSideCode,
    this.measureUnit,
    this.heightCm,
    this.weightKg,
    this.bmi,
    this.sportLevelCode,
    this.contextCode,
    this.testCode,
    this.testVersion,
    this.testFamily,
    this.performerCountryCode,
    this.performerRegionCode,
    this.performerMainActivityCode,
    this.performerMainSpecialtyCode,
    this.performerYearsExperienceCode,
    this.performerProfileUpdatedAt,
    this.localSchemaVersion,
    this.syncState = 'imported',
    this.lastModifiedAt,
    this.contentHash,
    this.archivedAt,
    this.mobileCaseId,
    this.mobileCaseLabel,
  });

  factory DesktopResult.fromMap(Map<String, dynamic> map) {
    return DesktopResult(
      resultId: map['result_id'] as String,
      patientId: map['patient_id'] as String,
      practitionerId: map['practitioner_id'] as String?,
      sourceDeviceId: map['source_device_id'] as String?,
      practitionerLabelSnapshot:
      map['practitioner_label_snapshot'] as String?,
      episodeId: map['episode_id'] as String?,
      createdAt: map['createdAt'] as int,
      importedAt: map['imported_at'] as int,
      exoId: map['exoId'] as String,
      scoreTotal: (map['scoreTotal'] as num?)?.toDouble(),
      comment: map['comment'] as String?,
      exportSimpleText: map['exportSimpleText'] as String,
      simpleExportSnapshotJson:
      map['simpleExportSnapshotJson'] as String?,
      profileJson: map['profileJson'] as String?,
      structuredJson: map['structuredJson'] as String?,
      ageYears: map['ageYears'] as int?,
      sexCode: map['sexCode'] as String?,
      testedSideCode: map['testedSideCode'] as String?,
      measureUnit: map['measureUnit'] as String?,
      heightCm: map['heightCm'] as int?,
      weightKg: (map['weightKg'] as num?)?.toDouble(),
      bmi: (map['bmi'] as num?)?.toDouble(),
      sportLevelCode: map['sportLevelCode'] as String?,
      contextCode: map['contextCode'] as String?,
      testCode: map['testCode'] as String?,
      testVersion: map['testVersion'] as int?,
      testFamily: map['testFamily'] as String?,
      performerCountryCode: map['performerCountryCode'] as String?,
      performerRegionCode: map['performerRegionCode'] as String?,
      performerMainActivityCode:
      map['performerMainActivityCode'] as String?,
      performerMainSpecialtyCode:
      map['performerMainSpecialtyCode'] as String?,
      performerYearsExperienceCode:
      map['performerYearsExperienceCode'] as String?,
      performerProfileUpdatedAt:
      map['performerProfileUpdatedAt'] as int?,
      localSchemaVersion: map['localSchemaVersion'] as int?,
      syncState: map['sync_state'] as String? ?? 'imported',
      lastModifiedAt: map['last_modified_at'] as int?,
      contentHash: map['content_hash'] as String?,
      archivedAt: map['archived_at'] as int?,
      mobileCaseId: map['mobile_case_id'] as String?,
      mobileCaseLabel: map['mobile_case_label'] as String?,
    );
  }

  DesktopResult copyWith({
    String? resultId,
    String? patientId,
    String? practitionerId,
    String? sourceDeviceId,
    String? practitionerLabelSnapshot,
    String? episodeId,
    int? createdAt,
    int? importedAt,
    String? exoId,
    double? scoreTotal,
    String? comment,
    String? exportSimpleText,
    String? simpleExportSnapshotJson,
    String? profileJson,
    String? structuredJson,
    int? ageYears,
    String? sexCode,
    String? testedSideCode,
    String? measureUnit,
    int? heightCm,
    double? weightKg,
    double? bmi,
    String? sportLevelCode,
    String? contextCode,
    String? testCode,
    int? testVersion,
    String? testFamily,
    String? performerCountryCode,
    String? performerRegionCode,
    String? performerMainActivityCode,
    String? performerMainSpecialtyCode,
    String? performerYearsExperienceCode,
    int? performerProfileUpdatedAt,
    int? localSchemaVersion,
    String? syncState,
    int? lastModifiedAt,
    String? contentHash,
    int? archivedAt,
    String? mobileCaseId,
    String? mobileCaseLabel,
  }) {
    return DesktopResult(
      resultId: resultId ?? this.resultId,
      patientId: patientId ?? this.patientId,
      practitionerId: practitionerId ?? this.practitionerId,
      sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
      practitionerLabelSnapshot:
      practitionerLabelSnapshot ?? this.practitionerLabelSnapshot,
      episodeId: episodeId ?? this.episodeId,
      createdAt: createdAt ?? this.createdAt,
      importedAt: importedAt ?? this.importedAt,
      exoId: exoId ?? this.exoId,
      scoreTotal: scoreTotal ?? this.scoreTotal,
      comment: comment ?? this.comment,
      exportSimpleText: exportSimpleText ?? this.exportSimpleText,
      simpleExportSnapshotJson:
      simpleExportSnapshotJson ?? this.simpleExportSnapshotJson,
      profileJson: profileJson ?? this.profileJson,
      structuredJson: structuredJson ?? this.structuredJson,
      ageYears: ageYears ?? this.ageYears,
      sexCode: sexCode ?? this.sexCode,
      testedSideCode: testedSideCode ?? this.testedSideCode,
      measureUnit: measureUnit ?? this.measureUnit,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      bmi: bmi ?? this.bmi,
      sportLevelCode: sportLevelCode ?? this.sportLevelCode,
      contextCode: contextCode ?? this.contextCode,
      testCode: testCode ?? this.testCode,
      testVersion: testVersion ?? this.testVersion,
      testFamily: testFamily ?? this.testFamily,
      performerCountryCode:
      performerCountryCode ?? this.performerCountryCode,
      performerRegionCode:
      performerRegionCode ?? this.performerRegionCode,
      performerMainActivityCode:
      performerMainActivityCode ?? this.performerMainActivityCode,
      performerMainSpecialtyCode:
      performerMainSpecialtyCode ?? this.performerMainSpecialtyCode,
      performerYearsExperienceCode:
      performerYearsExperienceCode ?? this.performerYearsExperienceCode,
      performerProfileUpdatedAt:
      performerProfileUpdatedAt ?? this.performerProfileUpdatedAt,
      localSchemaVersion:
      localSchemaVersion ?? this.localSchemaVersion,
      syncState: syncState ?? this.syncState,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      contentHash: contentHash ?? this.contentHash,
      archivedAt: archivedAt ?? this.archivedAt,
      mobileCaseId: mobileCaseId ?? this.mobileCaseId,
      mobileCaseLabel: mobileCaseLabel ?? this.mobileCaseLabel,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'result_id': resultId,
      'patient_id': patientId,
      'practitioner_id': practitionerId,
      'source_device_id': sourceDeviceId,
      'practitioner_label_snapshot': practitionerLabelSnapshot,
      'episode_id': episodeId,
      'createdAt': createdAt,
      'imported_at': importedAt,
      'exoId': exoId,
      'scoreTotal': scoreTotal,
      'comment': comment,
      'exportSimpleText': exportSimpleText,
      'simpleExportSnapshotJson': simpleExportSnapshotJson,
      'profileJson': profileJson,
      'structuredJson': structuredJson,
      'ageYears': ageYears,
      'sexCode': sexCode,
      'testedSideCode': testedSideCode,
      'measureUnit': measureUnit,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'bmi': bmi,
      'sportLevelCode': sportLevelCode,
      'contextCode': contextCode,
      'testCode': testCode,
      'testVersion': testVersion,
      'testFamily': testFamily,
      'performerCountryCode': performerCountryCode,
      'performerRegionCode': performerRegionCode,
      'performerMainActivityCode': performerMainActivityCode,
      'performerMainSpecialtyCode': performerMainSpecialtyCode,
      'performerYearsExperienceCode': performerYearsExperienceCode,
      'performerProfileUpdatedAt': performerProfileUpdatedAt,
      'localSchemaVersion': localSchemaVersion,
      'sync_state': syncState,
      'last_modified_at': lastModifiedAt ?? importedAt,
      'content_hash': contentHash,
      'archived_at': archivedAt,
      'mobile_case_id': mobileCaseId,
      'mobile_case_label': mobileCaseLabel,
    };
  }
}
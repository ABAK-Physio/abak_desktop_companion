class DesktopResult {
  final String resultId;
  final String careEpisodeId;

  final String? patientId;
  final String? practitionerId;
  final String? sourceDeviceId;
  final String? practitionerLabelSnapshot;
  final String? practitionerVerificationStatus;

  final String? mobileEpisodeId;
  final String? mobilePathologyCode;
  final String? mobilePathologyLabel;
  final String? mobilePatientRef;
  final String? mobilePatientLabel;

  final int createdAt;
  final int importedAt;
  final String exoId;
  final double? scoreTotal;
  final String? comment;
  final String exportSimpleText;
  final String? simpleExportSnapshotJson;

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
  final int? localSchemaVersion;

  final String syncState;
  final int? lastModifiedAt;
  final String? contentHash;
  final int? archivedAt;

  final String? patientLastName;
  final String? patientFirstName;
  final String? patientBirthDate;

  const DesktopResult({
    required this.resultId,
    required this.careEpisodeId,
    this.patientId,
    this.practitionerId,
    this.sourceDeviceId,
    this.practitionerLabelSnapshot,
    this.practitionerVerificationStatus,
    this.mobileEpisodeId,
    this.mobilePathologyCode,
    this.mobilePathologyLabel,
    this.mobilePatientRef,
    this.mobilePatientLabel,
    required this.createdAt,
    required this.importedAt,
    required this.exoId,
    this.scoreTotal,
    this.comment,
    required this.exportSimpleText,
    this.simpleExportSnapshotJson,
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
    this.localSchemaVersion,
    this.syncState = 'imported',
    this.lastModifiedAt,
    this.contentHash,
    this.archivedAt,
    this.patientLastName,
    this.patientFirstName,
    this.patientBirthDate,
  });

  factory DesktopResult.fromMap(Map<String, dynamic> map) {
    return DesktopResult(
      resultId: map['result_id'] as String,
      careEpisodeId: map['care_episode_id'] as String,
      patientId: map['patient_id'] as String?,
      patientLastName: map['last_name'] as String?,
      patientFirstName: map['first_name'] as String?,
      patientBirthDate: map['birth_date'] as String?,
      practitionerId: map['practitioner_id'] as String?,
      sourceDeviceId: map['source_device_id'] as String?,
      practitionerLabelSnapshot: map['practitioner_label_snapshot'] as String?,
      practitionerVerificationStatus:
          map['practitioner_verification_status'] as String?,
      mobileEpisodeId: map['mobile_episode_id'] as String?,
      mobilePathologyCode: map['mobile_pathology_code'] as String?,
      mobilePathologyLabel: map['mobile_pathology_label'] as String?,
      mobilePatientRef: map['mobile_patient_ref'] as String?,
      mobilePatientLabel: map['mobile_patient_label'] as String?,
      createdAt: map['createdAt'] as int,
      importedAt: map['imported_at'] as int,
      exoId: map['exoId'] as String,
      scoreTotal: (map['scoreTotal'] as num?)?.toDouble(),
      comment: map['comment'] as String?,
      exportSimpleText: map['exportSimpleText'] as String,
      simpleExportSnapshotJson: map['simpleExportSnapshotJson'] as String?,
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
      localSchemaVersion: map['localSchemaVersion'] as int?,
      syncState: map['sync_state'] as String? ?? 'imported',
      lastModifiedAt: map['last_modified_at'] as int?,
      contentHash: map['content_hash'] as String?,
      archivedAt: map['archived_at'] as int?,
    );
  }

  DesktopResult copyWith({
    String? resultId,
    String? careEpisodeId,
    String? patientId,
    String? practitionerId,
    String? sourceDeviceId,
    String? practitionerLabelSnapshot,
    String? practitionerVerificationStatus,
    String? mobileEpisodeId,
    String? mobilePathologyCode,
    String? mobilePathologyLabel,
    String? mobilePatientRef,
    String? mobilePatientLabel,
    int? createdAt,
    int? importedAt,
    String? exoId,
    double? scoreTotal,
    String? comment,
    String? exportSimpleText,
    String? simpleExportSnapshotJson,
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
    int? localSchemaVersion,
    String? syncState,
    int? lastModifiedAt,
    String? contentHash,
    int? archivedAt,
    String? patientLastName,
    String? patientFirstName,
    String? patientBirthDate,
  }) {
    return DesktopResult(
      resultId: resultId ?? this.resultId,
      careEpisodeId: careEpisodeId ?? this.careEpisodeId,
      patientId: patientId ?? this.patientId,
      practitionerId: practitionerId ?? this.practitionerId,
      sourceDeviceId: sourceDeviceId ?? this.sourceDeviceId,
      practitionerLabelSnapshot:
          practitionerLabelSnapshot ?? this.practitionerLabelSnapshot,
      practitionerVerificationStatus:
      practitionerVerificationStatus ??
          this.practitionerVerificationStatus,
      mobileEpisodeId: mobileEpisodeId ?? this.mobileEpisodeId,
      mobilePathologyCode: mobilePathologyCode ?? this.mobilePathologyCode,
      mobilePathologyLabel: mobilePathologyLabel ?? this.mobilePathologyLabel,
      mobilePatientRef: mobilePatientRef ?? this.mobilePatientRef,
      mobilePatientLabel: mobilePatientLabel ?? this.mobilePatientLabel,
      createdAt: createdAt ?? this.createdAt,
      importedAt: importedAt ?? this.importedAt,
      exoId: exoId ?? this.exoId,
      scoreTotal: scoreTotal ?? this.scoreTotal,
      comment: comment ?? this.comment,
      exportSimpleText: exportSimpleText ?? this.exportSimpleText,
      simpleExportSnapshotJson:
          simpleExportSnapshotJson ?? this.simpleExportSnapshotJson,
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
      localSchemaVersion: localSchemaVersion ?? this.localSchemaVersion,
      syncState: syncState ?? this.syncState,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      contentHash: contentHash ?? this.contentHash,
      archivedAt: archivedAt ?? this.archivedAt,
      patientLastName: patientLastName ?? this.patientLastName,
      patientFirstName: patientFirstName ?? this.patientFirstName,
      patientBirthDate: patientBirthDate ?? this.patientBirthDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'result_id': resultId,
      'care_episode_id': careEpisodeId,
      'patient_id': patientId,
      'practitioner_id': practitionerId,
      'source_device_id': sourceDeviceId,
      'practitioner_label_snapshot': practitionerLabelSnapshot,
      'practitioner_verification_status':
          practitionerVerificationStatus,
      'mobile_episode_id': mobileEpisodeId,
      'mobile_pathology_code': mobilePathologyCode,
      'mobile_pathology_label': mobilePathologyLabel,
      'mobile_patient_ref': mobilePatientRef,
      'mobile_patient_label': mobilePatientLabel,
      'createdAt': createdAt,
      'imported_at': importedAt,
      'exoId': exoId,
      'scoreTotal': scoreTotal,
      'comment': comment,
      'exportSimpleText': exportSimpleText,
      'simpleExportSnapshotJson': simpleExportSnapshotJson,
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
      'localSchemaVersion': localSchemaVersion,
      'sync_state': syncState,
      'last_modified_at': lastModifiedAt ?? importedAt,
      'content_hash': contentHash,
      'archived_at': archivedAt,
    };
  }
}

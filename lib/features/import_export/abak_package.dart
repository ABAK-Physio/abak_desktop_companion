class AbakPackage {
  final int schemaVersion;
  final int exportedAt;
  final AbakSourceDevice? sourceDevice;
  final AbakPractitionerSnapshot? practitioner;
  final AbakPatientSnapshot? patient;
  final List<AbakResultPayload> results;
  final List<AbakMetricPayload> metrics;
  final AbakMobileCaseSnapshot? mobileCase;
  final AbakClinicalEpisodeSnapshot? clinicalEpisode;

  const AbakPackage({
    required this.schemaVersion,
    required this.exportedAt,
    this.sourceDevice,
    this.practitioner,
    this.patient,
    this.mobileCase,
    this.clinicalEpisode,
    required this.results,
    required this.metrics,
  });

  factory AbakPackage.fromJson(Map<String, dynamic> json) {
    return AbakPackage(
      schemaVersion: json['schemaVersion'] as int? ?? 1,
      exportedAt: json['exportedAt'] as int,
      sourceDevice: json['sourceDevice'] == null
          ? null
          : AbakSourceDevice.fromJson(
              json['sourceDevice'] as Map<String, dynamic>,
            ),
      practitioner: json['practitioner'] == null
          ? null
          : AbakPractitionerSnapshot.fromJson(
              json['practitioner'] as Map<String, dynamic>,
            ),
      patient: json['patient'] == null
          ? null
          : AbakPatientSnapshot.fromJson(
              json['patient'] as Map<String, dynamic>,
            ),

      mobileCase: json['mobileCase'] == null
          ? null
          : AbakMobileCaseSnapshot.fromJson(
              json['mobileCase'] as Map<String, dynamic>,
            ),

      clinicalEpisode: json['clinicalEpisode'] == null
          ? null
          : AbakClinicalEpisodeSnapshot.fromJson(
              json['clinicalEpisode'] as Map<String, dynamic>,
            ),

      results: (json['results'] as List<dynamic>? ?? [])
          .map(
            (item) => AbakResultPayload.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      metrics: (json['metrics'] as List<dynamic>? ?? [])
          .map(
            (item) => AbakMetricPayload.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'exportedAt': exportedAt,
      'sourceDevice': sourceDevice?.toJson(),
      'practitioner': practitioner?.toJson(),
      'patient': patient?.toJson(),
      'results': results.map((e) => e.toJson()).toList(),
      'metrics': metrics.map((e) => e.toJson()).toList(),
      'mobileCase': mobileCase?.toJson(),
      'clinicalEpisode': clinicalEpisode?.toJson(),
    };
  }
}

class AbakSourceDevice {
  final String deviceId;
  final String deviceLabel;
  final String? platform;

  const AbakSourceDevice({
    required this.deviceId,
    required this.deviceLabel,
    this.platform,
  });

  factory AbakSourceDevice.fromJson(Map<String, dynamic> json) {
    return AbakSourceDevice(
      deviceId: json['deviceId'] as String,
      deviceLabel: json['deviceLabel'] as String,
      platform: json['platform'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceLabel': deviceLabel,
      'platform': platform,
    };
  }
}

class AbakPractitionerSnapshot {
  final String? practitionerId;
  final String displayName;

  const AbakPractitionerSnapshot({
    this.practitionerId,
    required this.displayName,
  });

  factory AbakPractitionerSnapshot.fromJson(Map<String, dynamic> json) {
    return AbakPractitionerSnapshot(
      practitionerId: json['practitionerId'] as String?,
      displayName: json['displayName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'practitionerId': practitionerId, 'displayName': displayName};
  }
}

class AbakPatientSnapshot {
  final String? localPatientId;
  final String lastName;
  final String firstName;
  final String? birthDate;
  final String? sexCode;

  const AbakPatientSnapshot({
    this.localPatientId,
    required this.lastName,
    required this.firstName,
    this.birthDate,
    this.sexCode,
  });

  factory AbakPatientSnapshot.fromJson(Map<String, dynamic> json) {
    return AbakPatientSnapshot(
      localPatientId: json['localPatientId'] as String?,
      lastName: json['lastName'] as String,
      firstName: json['firstName'] as String,
      birthDate: json['birthDate'] as String?,
      sexCode: json['sexCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'localPatientId': localPatientId,
      'lastName': lastName,
      'firstName': firstName,
      'birthDate': birthDate,
      'sexCode': sexCode,
    };
  }
}

class AbakMobileCaseSnapshot {
  final String caseId;
  final String caseLabel;
  final String? pathologyCode;

  const AbakMobileCaseSnapshot({
    required this.caseId,
    required this.caseLabel,
    this.pathologyCode,
  });

  factory AbakMobileCaseSnapshot.fromJson(Map<String, dynamic> json) {
    return AbakMobileCaseSnapshot(
      caseId: json['caseId'] as String,
      caseLabel: json['caseLabel'] as String,
      pathologyCode: json['pathologyCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'caseId': caseId,
      'caseLabel': caseLabel,
      'pathologyCode': pathologyCode,
    };
  }
}

class AbakClinicalEpisodeSnapshot {
  final String episodeId;
  final String? patientRef;
  final String? patientLabel;
  final String? label;

  final String? pathologyCode;
  final String? pathologyLabel;
  final String? pathologyCodingSystem;
  final String? pathologyCodingSystemUri;
  final String? pathologyExternalCode;
  final String? pathologyFreeText;

  final String? createdAt;
  final String? lastUsedAt;
  final String? closedAt;
  final String status;

  const AbakClinicalEpisodeSnapshot({
    required this.episodeId,
    this.patientRef,
    this.patientLabel,
    this.label,
    this.pathologyCode,
    this.pathologyLabel,
    this.pathologyCodingSystem,
    this.pathologyCodingSystemUri,
    this.pathologyExternalCode,
    this.pathologyFreeText,
    this.createdAt,
    this.lastUsedAt,
    this.closedAt,
    this.status = 'active',
  });

  factory AbakClinicalEpisodeSnapshot.fromJson(Map<String, dynamic> json) {
    return AbakClinicalEpisodeSnapshot(
      episodeId: json['episode_id']?.toString() ?? '',
      patientRef: json['patient_ref']?.toString(),
      patientLabel: json['patient_label']?.toString(),
      label: json['label']?.toString(),
      pathologyCode: json['pathology_code']?.toString(),
      pathologyLabel: json['pathology_label']?.toString(),
      pathologyCodingSystem: json['pathology_coding_system']?.toString(),
      pathologyCodingSystemUri: json['pathology_coding_system_uri']?.toString(),
      pathologyExternalCode: json['pathology_external_code']?.toString(),
      pathologyFreeText: json['pathology_free_text']?.toString(),
      createdAt: json['created_at']?.toString(),
      lastUsedAt: json['last_used_at']?.toString(),
      closedAt: json['closed_at']?.toString(),
      status: json['status']?.toString() ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'episode_id': episodeId,
      'patient_ref': patientRef,
      'patient_label': patientLabel,
      'label': label,
      'pathology_code': pathologyCode,
      'pathology_label': pathologyLabel,
      'pathology_coding_system': pathologyCodingSystem,
      'pathology_coding_system_uri': pathologyCodingSystemUri,
      'pathology_external_code': pathologyExternalCode,
      'pathology_free_text': pathologyFreeText,
      'created_at': createdAt,
      'last_used_at': lastUsedAt,
      'closed_at': closedAt,
      'status': status,
    };
  }
}

class AbakResultPayload {
  final Map<String, dynamic> raw;

  const AbakResultPayload({required this.raw});

  factory AbakResultPayload.fromJson(Map<String, dynamic> json) {
    return AbakResultPayload(raw: json);
  }

  Map<String, dynamic> toJson() => raw;
}

class AbakMetricPayload {
  final Map<String, dynamic> raw;

  const AbakMetricPayload({required this.raw});

  factory AbakMetricPayload.fromJson(Map<String, dynamic> json) {
    return AbakMetricPayload(raw: json);
  }

  Map<String, dynamic> toJson() => raw;
}

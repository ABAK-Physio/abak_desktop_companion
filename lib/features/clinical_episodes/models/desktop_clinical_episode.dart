class DesktopClinicalEpisode {
  final String episodeId;
  final String mobileCaseId;
  final String? patientId;

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

  final int importedAt;
  final int updatedAt;

  const DesktopClinicalEpisode({
    required this.episodeId,
    required this.mobileCaseId,
    this.patientId,
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
    required this.status,
    required this.importedAt,
    required this.updatedAt,
  });

  factory DesktopClinicalEpisode.fromMap(Map<String, dynamic> map) {
    return DesktopClinicalEpisode(
      episodeId: map['episode_id']?.toString() ?? '',
      mobileCaseId: map['mobile_case_id']?.toString() ?? '',
      patientId: map['patient_id']?.toString(),
      patientRef: map['patient_ref']?.toString(),
      patientLabel: map['patient_label']?.toString(),
      label: map['label']?.toString(),
      pathologyCode: map['pathology_code']?.toString(),
      pathologyLabel: map['pathology_label']?.toString(),
      pathologyCodingSystem: map['pathology_coding_system']?.toString(),
      pathologyCodingSystemUri: map['pathology_coding_system_uri']?.toString(),
      pathologyExternalCode: map['pathology_external_code']?.toString(),
      pathologyFreeText: map['pathology_free_text']?.toString(),
      createdAt: map['created_at']?.toString(),
      lastUsedAt: map['last_used_at']?.toString(),
      closedAt: map['closed_at']?.toString(),
      status: map['status']?.toString() ?? 'active',
      importedAt: (map['imported_at'] as num?)?.toInt() ?? 0,
      updatedAt: (map['updated_at'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'episode_id': episodeId,
      'mobile_case_id': mobileCaseId,
      'patient_id': patientId,
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
      'imported_at': importedAt,
      'updated_at': updatedAt,
    };
  }

  bool get isActive => status == 'active';

  bool get isClosed => status == 'closed';

  String get displayTitle {
    final cleanedLabel = label?.trim();
    if (cleanedLabel != null && cleanedLabel.isNotEmpty) {
      return cleanedLabel;
    }

    final cleanedPathology = pathologyLabel?.trim();
    if (cleanedPathology != null && cleanedPathology.isNotEmpty) {
      return cleanedPathology;
    }

    return 'Épisode clinique';
  }
}

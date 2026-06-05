class MobileCase {
  final String caseId;
  final String caseLabel;
  final String? pathologyCode;
  final String? sourceDeviceId;
  final int createdAt;
  final int? importedAt;
  final int? updatedAt;
  final int? archivedAt;

  const MobileCase({
    required this.caseId,
    required this.caseLabel,
    this.pathologyCode,
    this.sourceDeviceId,
    required this.createdAt,
    this.importedAt,
    this.updatedAt,
    this.archivedAt,
  });

  factory MobileCase.fromMap(Map<String, dynamic> map) {
    return MobileCase(
      caseId: map['case_id'] as String,
      caseLabel: map['case_label'] as String,
      pathologyCode: map['pathology_code'] as String?,
      sourceDeviceId: map['source_device_id'] as String?,
      createdAt: map['created_at'] as int,
      importedAt: map['imported_at'] as int?,
      updatedAt: map['updated_at'] as int?,
      archivedAt: map['archived_at'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'case_id': caseId,
      'case_label': caseLabel,
      'pathology_code': pathologyCode,
      'source_device_id': sourceDeviceId,
      'created_at': createdAt,
      'imported_at': importedAt,
      'updated_at': updatedAt,
      'archived_at': archivedAt,
    };
  }
}
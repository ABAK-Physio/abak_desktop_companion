enum PatientFrHealthIdentityStatus {
  provisional,
  retrieved,
  validated,
  qualified,
}

PatientFrHealthIdentityStatus resolvePatientFrHealthIdentityStatus({
  required bool identityValidated,
  required bool insRetrieved,
}) {
  if (identityValidated && insRetrieved) {
    return PatientFrHealthIdentityStatus.qualified;
  }

  if (identityValidated) {
    return PatientFrHealthIdentityStatus.validated;
  }

  if (insRetrieved) {
    return PatientFrHealthIdentityStatus.retrieved;
  }

  return PatientFrHealthIdentityStatus.provisional;
}

class PatientFrHealthIdentity {
  final String patientId;

  final String? insNumber;
  final String? insKey;
  final String? insOid;

  final String? birthLastName;
  final String? birthFirstNames;
  final String? birthDate;
  final String? sexCode;
  final String? birthPlaceCode;

  final String identityStatus;
  final bool identityDoubtful;

  final String? identityValidationMethod;
  final int? identityValidatedAt;
  final String? identityValidatedBy;

  final int? insRetrievedAt;
  final int? insLastCheckedAt;

  final int? updatedAt;

  const PatientFrHealthIdentity({
    required this.patientId,
    this.insNumber,
    this.insKey,
    this.insOid,
    this.birthLastName,
    this.birthFirstNames,
    this.birthDate,
    this.sexCode,
    this.birthPlaceCode,
    this.identityStatus = 'provisional',
    this.identityDoubtful = false,
    this.identityValidationMethod,
    this.identityValidatedAt,
    this.identityValidatedBy,
    this.insRetrievedAt,
    this.insLastCheckedAt,
    this.updatedAt,
  });

  bool get isProvisional =>
      status == PatientFrHealthIdentityStatus.provisional;

  bool get isRetrieved =>
      status == PatientFrHealthIdentityStatus.retrieved;

  bool get isValidated =>
      status == PatientFrHealthIdentityStatus.validated;

  bool get isQualified =>
      status == PatientFrHealthIdentityStatus.qualified;

  factory PatientFrHealthIdentity.fromMap(Map<String, Object?> map) {
    return PatientFrHealthIdentity(
      patientId: map['patient_id'] as String,
      insNumber: map['ins_number'] as String?,
      insKey: map['ins_key'] as String?,
      insOid: map['ins_oid'] as String?,
      birthLastName: map['birth_last_name'] as String?,
      birthFirstNames: map['birth_first_names'] as String?,
      birthDate: map['birth_date'] as String?,
      sexCode: map['sex_code'] as String?,
      birthPlaceCode: map['birth_place_code'] as String?,
      identityStatus:
      map['identity_status'] as String? ?? 'provisional',
      identityDoubtful:
      (map['identity_doubtful'] as int? ?? 0) == 1,
      identityValidationMethod:
      map['identity_validation_method'] as String?,
      identityValidatedAt:
      map['identity_validated_at'] as int?,
      identityValidatedBy:
      map['identity_validated_by'] as String?,
      insRetrievedAt:
      map['ins_retrieved_at'] as int?,
      insLastCheckedAt:
      map['ins_last_checked_at'] as int?,
      updatedAt: map['updated_at'] as int?,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'patient_id': patientId,
      'ins_number': insNumber,
      'ins_key': insKey,
      'ins_oid': insOid,
      'birth_last_name': birthLastName,
      'birth_first_names': birthFirstNames,
      'birth_date': birthDate,
      'sex_code': sexCode,
      'birth_place_code': birthPlaceCode,
      'identity_status': identityStatus,
      'identity_doubtful': identityDoubtful ? 1 : 0,
      'identity_validation_method': identityValidationMethod,
      'identity_validated_at': identityValidatedAt,
      'identity_validated_by': identityValidatedBy,
      'ins_retrieved_at': insRetrievedAt,
      'ins_last_checked_at': insLastCheckedAt,
      'updated_at': updatedAt,
    };
  }

  PatientFrHealthIdentityStatus get status {
    switch (identityStatus) {
      case 'retrieved':
        return PatientFrHealthIdentityStatus.retrieved;
      case 'validated':
        return PatientFrHealthIdentityStatus.validated;
      case 'qualified':
        return PatientFrHealthIdentityStatus.qualified;
      case 'provisional':
      default:
        return PatientFrHealthIdentityStatus.provisional;
    }
  }
}
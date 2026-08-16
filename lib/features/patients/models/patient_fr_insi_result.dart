enum PatientFrInsiResultStatus {
  success,
  notFound,
  ambiguous,
}

PatientFrInsiResultStatus patientFrInsiStatusFromCodeCr(
    String codeCr,
    ) {
  switch (codeCr) {
    case '00':
      return PatientFrInsiResultStatus.success;
    case '01':
      return PatientFrInsiResultStatus.notFound;
    case '02':
      return PatientFrInsiResultStatus.ambiguous;
    default:
      throw ArgumentError.value(
        codeCr,
        'codeCr',
        'CodeCR INSi non pris en charge',
      );
  }
}

class PatientFrInsiResult {
  final PatientFrInsiResultStatus status;

  final String? insNumber;
  final String? insKey;
  final String? insOid;

  final String? birthLastName;
  final String? birthFirstNames;
  final String? birthDate;
  final String? sexCode;
  final String? birthPlaceCode;

  const PatientFrInsiResult({
    required this.status,
    this.insNumber,
    this.insKey,
    this.insOid,
    this.birthLastName,
    this.birthFirstNames,
    this.birthDate,
    this.sexCode,
    this.birthPlaceCode,
  });

  bool get isSuccess => status == PatientFrInsiResultStatus.success;

  bool get isNotFound => status == PatientFrInsiResultStatus.notFound;

  bool get isAmbiguous => status == PatientFrInsiResultStatus.ambiguous;

}
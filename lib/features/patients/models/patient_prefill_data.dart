class PatientPrefillData {
  const PatientPrefillData({
    this.lastName,
    this.firstName,
    this.birthDate,
    this.sexCode,
  });

  final String? lastName;
  final String? firstName;
  final DateTime? birthDate;
  final String? sexCode;
}
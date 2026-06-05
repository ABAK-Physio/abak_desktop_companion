class Patient {
  final String patientId;
  final String lastName;
  final String firstName;
  final String? birthDate;
  final String sexCode;
  final int createdAt;
  final int? updatedAt;
  final int? archivedAt;

  const Patient({
    required this.patientId,
    required this.lastName,
    required this.firstName,
    this.birthDate,
    required this.sexCode,
    required this.createdAt,
    this.updatedAt,
    this.archivedAt,
  });

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      patientId: map['patient_id'] as String,
      lastName: map['last_name'] as String,
      firstName: map['first_name'] as String,
      birthDate: map['birth_date'] as String?,
      sexCode: map['sex_code'] as String? ?? 'U',
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int?,
      archivedAt: map['archived_at'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patient_id': patientId,
      'last_name': lastName,
      'first_name': firstName,
      'birth_date': birthDate,
      'sex_code': sexCode,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'archived_at': archivedAt,
    };
  }

  String get displayName => '$lastName $firstName';

  bool get isArchived => archivedAt != null;
}
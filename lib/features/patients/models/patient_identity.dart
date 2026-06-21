class PatientIdentity {
  final String patientId;
  final String? nationalHealthId;
  final String? healthSystemCountry;
  final String? identitySource;
  final String? phone;
  final String? email;
  final String? address;
  final int? lastVerifiedAt;
  final int updatedAt;

  const PatientIdentity({
    required this.patientId,
    this.nationalHealthId,
    this.healthSystemCountry,
    this.identitySource,
    this.phone,
    this.email,
    this.address,
    this.lastVerifiedAt,
    required this.updatedAt,
  });

  factory PatientIdentity.fromMap(Map<String, dynamic> map) {
    return PatientIdentity(
      patientId: map['patient_id'] as String,
      nationalHealthId: map['national_health_id'] as String?,
      healthSystemCountry: map['health_system_country'] as String?,
      identitySource: map['identity_source'] as String?,
      phone: map['phone'] as String?,
      email: map['email'] as String?,
      address: map['address'] as String?,
      lastVerifiedAt: map['last_verified_at'] as int?,
      updatedAt: map['updated_at'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'patient_id': patientId,
      'national_health_id': nationalHealthId,
      'health_system_country': healthSystemCountry,
      'identity_source': identitySource,
      'phone': phone,
      'email': email,
      'address': address,
      'last_verified_at': lastVerifiedAt,
      'updated_at': updatedAt,
    };
  }
}
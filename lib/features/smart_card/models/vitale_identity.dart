import '../../patients/models/patient_prefill_data.dart';

class VitaleIdentity {
  const VitaleIdentity({
    this.lastName,
    this.firstName,
    this.birthDate,
    this.sexCode,
    this.source = 'carte_vitale',
  });

  final String? lastName;
  final String? firstName;
  final DateTime? birthDate;
  final String? sexCode; // M / F / U
  final String source;

  bool get hasUsableIdentity {
    return (lastName?.trim().isNotEmpty ?? false) ||
        (firstName?.trim().isNotEmpty ?? false) ||
        birthDate != null ||
        (sexCode?.trim().isNotEmpty ?? false);
  }

  factory VitaleIdentity.fromMap(Map<dynamic, dynamic> map) {
    final birthDateRaw = map['birthDate']?.toString();

    return VitaleIdentity(
      lastName: map['lastName']?.toString(),
      firstName: map['firstName']?.toString(),
      birthDate: birthDateRaw == null || birthDateRaw.isEmpty
          ? null
          : DateTime.tryParse(birthDateRaw),
      sexCode: map['sexCode']?.toString(),
      source: map['source']?.toString() ?? 'carte_vitale',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'lastName': lastName,
      'firstName': firstName,
      'birthDate': birthDate?.toIso8601String(),
      'sexCode': sexCode,
      'source': source,
    };
  }

  PatientPrefillData toPatientPrefillData() {
    return PatientPrefillData(
      lastName: lastName,
      firstName: firstName,
      birthDate: birthDate,
      sexCode: sexCode,
    );
  }
}

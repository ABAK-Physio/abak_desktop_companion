class CasePatientLink {
  final String caseId;
  final String patientId;
  final int linkedAt;
  final String? linkedByPractitionerId;
  final String status;

  const CasePatientLink({
    required this.caseId,
    required this.patientId,
    required this.linkedAt,
    this.linkedByPractitionerId,
    this.status = 'linked',
  });

  factory CasePatientLink.fromMap(Map<String, dynamic> map) {
    return CasePatientLink(
      caseId: map['case_id'] as String,
      patientId: map['patient_id'] as String,
      linkedAt: map['linked_at'] as int,
      linkedByPractitionerId: map['linked_by_practitioner_id'] as String?,
      status: map['status'] as String? ?? 'linked',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'case_id': caseId,
      'patient_id': patientId,
      'linked_at': linkedAt,
      'linked_by_practitioner_id': linkedByPractitionerId,
      'status': status,
    };
  }
}
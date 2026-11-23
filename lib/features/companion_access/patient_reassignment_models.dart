class ReassignmentSource {
  const ReassignmentSource(this.id, this.name, this.patientCount);
  final String? id;
  final String name;
  final int patientCount;
}

class ReassignmentPatient {
  const ReassignmentPatient({
    required this.id,
    required this.name,
    required this.archived,
    this.birthDate,
    this.formerReferrer,
    this.departureDate,
  });
  final String id, name;
  final bool archived;
  final String? birthDate, formerReferrer;
  final int? departureDate;
}

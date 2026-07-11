class PatientAttribute {
  final String attributeId;
  final String patientId;
  final String attributeKey;
  final String? attributeValue;
  final int updatedAt;

  const PatientAttribute({
    required this.attributeId,
    required this.patientId,
    required this.attributeKey,
    this.attributeValue,
    required this.updatedAt,
  });

  factory PatientAttribute.fromMap(Map<String, dynamic> map) {
    return PatientAttribute(
      attributeId: map['attribute_id'] as String,
      patientId: map['patient_id'] as String,
      attributeKey: map['attribute_key'] as String,
      attributeValue: map['attribute_value'] as String?,
      updatedAt: map['updated_at'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'attribute_id': attributeId,
      'patient_id': patientId,
      'attribute_key': attributeKey,
      'attribute_value': attributeValue,
      'updated_at': updatedAt,
    };
  }
}

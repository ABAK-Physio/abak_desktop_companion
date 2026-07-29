import 'dart:convert';

class PractitionerQrData {
  final int schema;
  final String organizationId;
  final String organizationName;
  final String practitionerId;
  final String displayName;

  const PractitionerQrData({
    this.schema = 1,
    required this.organizationId,
    required this.organizationName,
    required this.practitionerId,
    required this.displayName,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': 'abak_practitioner_profile',
      'schema': schema,
      'organizationId': organizationId,
      'organizationName': organizationName,
      'practitionerId': practitionerId,
      'displayName': displayName,
    };
  }

  String toQrValue() {
    return jsonEncode(toJson());
  }
}
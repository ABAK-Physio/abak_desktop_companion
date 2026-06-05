class Practitioner {
  final String practitionerId;
  final String displayName;
  final String? firstName;
  final String? lastName;
  final String? professionalId;
  final String? email;
  final String? phone;
  final bool isActive;
  final int createdAt;
  final int? updatedAt;
  final int? archivedAt;

  const Practitioner({
    required this.practitionerId,
    required this.displayName,
    this.firstName,
    this.lastName,
    this.professionalId,
    this.email,
    this.phone,
    required this.isActive,
    required this.createdAt,
    this.updatedAt,
    this.archivedAt,
  });

  factory Practitioner.fromMap(Map<String, dynamic> map) {
    return Practitioner(
      practitionerId: map['practitioner_id'] as String,
      displayName: map['display_name'] as String,
      firstName: map['first_name'] as String?,
      lastName: map['last_name'] as String?,
      professionalId: map['professional_id'] as String?,
      email: map['email'] as String?,
      phone: map['phone'] as String?,
      isActive: (map['is_active'] as int? ?? 1) == 1,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int?,
      archivedAt: map['archived_at'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'practitioner_id': practitionerId,
      'display_name': displayName,
      'first_name': firstName,
      'last_name': lastName,
      'professional_id': professionalId,
      'email': email,
      'phone': phone,
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'archived_at': archivedAt,
    };
  }

  bool get isArchived => archivedAt != null;
}
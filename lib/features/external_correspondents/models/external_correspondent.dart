class ExternalCorrespondent {
  final String correspondentId;
  final String lastName;
  final String? firstName;
  final String? profession;
  final String? specialty;
  final String? addressLine1;
  final String? addressLine2;
  final String? postalCode;
  final String? city;
  final String? email;
  final String? phone;
  final int createdAt;
  final int? updatedAt;
  final int? archivedAt;

  const ExternalCorrespondent({
    required this.correspondentId,
    required this.lastName,
    this.firstName,
    this.profession,
    this.specialty,
    this.addressLine1,
    this.addressLine2,
    this.postalCode,
    this.city,
    this.email,
    this.phone,
    required this.createdAt,
    this.updatedAt,
    this.archivedAt,
  });

  String get displayName {
    final parts = [
      firstName?.trim(),
      lastName.trim(),
    ].whereType<String>().where((value) => value.isNotEmpty).toList();

    return parts.join(' ');
  }

  factory ExternalCorrespondent.fromMap(Map<String, Object?> map) {
    return ExternalCorrespondent(
      correspondentId: map['correspondent_id']?.toString() ?? '',
      lastName: map['last_name']?.toString() ?? '',
      firstName: map['first_name']?.toString(),
      profession: map['profession']?.toString(),
      specialty: map['specialty']?.toString(),
      addressLine1: map['address_line1']?.toString(),
      addressLine2: map['address_line2']?.toString(),
      postalCode: map['postal_code']?.toString(),
      city: map['city']?.toString(),
      email: map['email']?.toString(),
      phone: map['phone']?.toString(),
      createdAt: (map['created_at'] as num?)?.toInt() ?? 0,
      updatedAt: (map['updated_at'] as num?)?.toInt(),
      archivedAt: (map['archived_at'] as num?)?.toInt(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'correspondent_id': correspondentId,
      'last_name': lastName,
      'first_name': firstName,
      'profession': profession,
      'specialty': specialty,
      'address_line1': addressLine1,
      'address_line2': addressLine2,
      'postal_code': postalCode,
      'city': city,
      'email': email,
      'phone': phone,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'archived_at': archivedAt,
    };
  }
}
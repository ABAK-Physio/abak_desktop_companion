class ContactFormTemplate {
  final String templateId;
  final String? practitionerId;
  final String name;
  final String? description;
  final String? category;
  final bool isDefault;
  final int createdAt;
  final int? updatedAt;
  final int? archivedAt;

  const ContactFormTemplate({
    required this.templateId,
    this.practitionerId,
    required this.name,
    this.description,
    this.category,
    this.isDefault = false,
    required this.createdAt,
    this.updatedAt,
    this.archivedAt,
  });

  factory ContactFormTemplate.fromMap(Map<String, dynamic> map) {
    return ContactFormTemplate(
      templateId: map['template_id'] as String,
      practitionerId: map['practitioner_id'] as String?,
      name: map['name'] as String,
      description: map['description'] as String?,
      category: map['category'] as String?,
      isDefault: (map['is_default'] as int? ?? 0) == 1,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int?,
      archivedAt: map['archived_at'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'template_id': templateId,
      'practitioner_id': practitionerId,
      'name': name,
      'description': description,
      'category': category,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'archived_at': archivedAt,
    };
  }
}
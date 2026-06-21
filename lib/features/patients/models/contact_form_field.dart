class ContactFormField {
  final String fieldId;
  final String templateId;
  final String label;
  final String fieldType;
  final String targetScope;
  final int sortOrder;
  final bool required;
  final String? optionsJson;
  final int createdAt;
  final int? updatedAt;
  final int? archivedAt;

  const ContactFormField({
    required this.fieldId,
    required this.templateId,
    required this.label,
    required this.fieldType,
    required this.targetScope,
    required this.sortOrder,
    required this.required,
    this.optionsJson,
    required this.createdAt,
    this.updatedAt,
    this.archivedAt,
  });

  factory ContactFormField.fromMap(Map<String, dynamic> map) {
    return ContactFormField(
      fieldId: map['field_id'] as String,
      templateId: map['template_id'] as String,
      label: map['label'] as String,
      fieldType: map['field_type'] as String,
      targetScope: map['target_scope'] as String,
      sortOrder: map['sort_order'] as int,
      required: (map['required'] as int) == 1,
      optionsJson: map['options_json'] as String?,
      createdAt: map['created_at'] as int,
      updatedAt: map['updated_at'] as int?,
      archivedAt: map['archived_at'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'field_id': fieldId,
      'template_id': templateId,
      'label': label,
      'field_type': fieldType,
      'target_scope': targetScope,
      'sort_order': sortOrder,
      'required': required ? 1 : 0,
      'options_json': optionsJson,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'archived_at': archivedAt,
    };
  }
}
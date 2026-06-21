class EpisodeFormAnswer {
  final String answerId;
  final String formId;
  final String fieldId;
  final String? value;
  final int updatedAt;

  const EpisodeFormAnswer({
    required this.answerId,
    required this.formId,
    required this.fieldId,
    this.value,
    required this.updatedAt,
  });

  factory EpisodeFormAnswer.fromMap(Map<String, dynamic> map) {
    return EpisodeFormAnswer(
      answerId: map['answer_id'] as String,
      formId: map['form_id'] as String,
      fieldId: map['field_id'] as String,
      value: map['value'] as String?,
      updatedAt: map['updated_at'] as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'answer_id': answerId,
      'form_id': formId,
      'field_id': fieldId,
      'value': value,
      'updated_at': updatedAt,
    };
  }
}
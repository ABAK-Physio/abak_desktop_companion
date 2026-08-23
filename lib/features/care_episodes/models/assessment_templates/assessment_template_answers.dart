class AssessmentTemplateAnswers {
  final String templateId;
  final Map<String, dynamic> values;

  const AssessmentTemplateAnswers({
    required this.templateId,
    required this.values,
  });

  dynamic valueFor(String fieldId) {
    return values[fieldId];
  }

  bool hasValue(String fieldId) {
    final value = values[fieldId];

    if (value == null) {
      return false;
    }

    if (value is String) {
      return value.trim().isNotEmpty;
    }

    if (value is Iterable) {
      return value.isNotEmpty;
    }

    return true;
  }
}
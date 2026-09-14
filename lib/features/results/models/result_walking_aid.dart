import 'dart:convert';

/// Accessory metadata carried by Mobile in structuredJson.context.
class ResultWalkingAid {
  final String? code;
  final String? label;
  final String? description;

  const ResultWalkingAid({this.code, this.label, this.description});

  bool get isUsed {
    if (code != null) return code != 'none';
    final text = label?.trim().toLowerCase();
    if (text == null) return description?.trim().isNotEmpty == true;
    return !const {'aucun', 'none', 'keine', 'ninguna', 'nessuno',
      'nenhum', 'geen', '-'}.contains(text);
  }

  static ResultWalkingAid? fromStructuredJson(Object? value) {
    try {
      final decoded = value is String ? jsonDecode(value) : value;
      if (decoded is! Map || decoded['context'] is! Map) return null;
      final context = decoded['context'] as Map;
      String? text(String key) {
        final value = context[key];
        if (value is! String || value.trim().isEmpty) return null;
        return value.trim();
      }

      final aid = ResultWalkingAid(
        code: text('walkingAidCode'),
        label: text('walkingAidLabel'),
        description: text('walkingAidDescription'),
      );
      return aid.code == null && aid.label == null && aid.description == null
          ? null
          : aid;
    } on FormatException {
      return null;
    }
  }

  Map<String, String?> toJson() => {
    'code': code,
    'label': label,
    'description': code == 'other' ? description : null,
  };
}

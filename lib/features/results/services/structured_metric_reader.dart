import 'dart:convert';

class StructuredMetricReader {
  const StructuredMetricReader._();

  static double? readDouble({
    required String? structuredJson,
    required String path,
  }) {
    final value = _readValue(structuredJson: structuredJson, path: path);

    if (value == null) {
      return null;
    }

    if (value is num) {
      return value.toDouble();
    }

    if (value is String) {
      return double.tryParse(value.trim().replaceAll(',', '.'));
    }

    return null;
  }

  static String? readString({
    required String? structuredJson,
    required String path,
  }) {
    final value = _readValue(structuredJson: structuredJson, path: path);

    if (value == null) {
      return null;
    }

    if (value is String) {
      final text = value.trim();
      return text.isEmpty ? null : text;
    }

    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  static dynamic _readValue({
    required String? structuredJson,
    required String path,
  }) {
    if (structuredJson == null || structuredJson.trim().isEmpty) {
      return null;
    }

    final normalizedPath = path.trim();

    if (normalizedPath.isEmpty) {
      return null;
    }

    dynamic decoded;

    try {
      decoded = jsonDecode(structuredJson);
    } on FormatException {
      return null;
    }

    dynamic current = decoded;

    for (final segment in normalizedPath.split('.')) {
      if (current is! Map<String, dynamic>) {
        return null;
      }

      if (!current.containsKey(segment)) {
        return null;
      }

      current = current[segment];
    }

    return current;
  }
}

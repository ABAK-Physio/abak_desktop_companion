import 'dart:convert';

class StructuredMetricReader {
  const StructuredMetricReader._();

  static double? readDouble({
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

    try {
      final decoded = jsonDecode(structuredJson);

      if (decoded is! Map<String, dynamic>) {
        return null;
      }

      dynamic currentValue = decoded;

      for (final segment in normalizedPath.split('.')) {
        if (currentValue is! Map<String, dynamic>) {
          return null;
        }

        if (!currentValue.containsKey(segment)) {
          return null;
        }

        currentValue = currentValue[segment];
      }

      if (currentValue is num) {
        return currentValue.toDouble();
      }

      if (currentValue is String) {
        final normalizedValue = currentValue
            .trim()
            .replaceAll(',', '.');

        return double.tryParse(normalizedValue);
      }

      return null;
    } on FormatException {
      return null;
    } catch (_) {
      return null;
    }
  }
}
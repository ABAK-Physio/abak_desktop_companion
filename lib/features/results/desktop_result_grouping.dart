import 'dart:convert';

import 'package:abak_shared/abak_shared.dart';

import 'models/desktop_result.dart';

String desktopResultSelectionKey(DesktopResult result) {
  final definition = ClinicalActivityCatalog.infoFor(
    result.exoId,
  );

  final followUpGroupPath = definition.followUpGroupPath;

  if (followUpGroupPath == null) {
    return result.exoId;
  }

  final groupCode = readDesktopResultStructuredString(
    result,
    followUpGroupPath,
  );

  if (groupCode == null) {
    return result.exoId;
  }

  return '${result.exoId}::$groupCode';
}

String desktopResultDisplayLabel(DesktopResult result) {
  final baseLabel = ClinicalActivityCatalog.displayLabel(
    result.exoId,
  );

  final definition = ClinicalActivityCatalog.infoFor(
    result.exoId,
  );

  final followUpGroupPath = definition.followUpGroupPath;

  if (followUpGroupPath == null) {
    return baseLabel;
  }

  final groupCode = readDesktopResultStructuredString(
    result,
    followUpGroupPath,
  );

  if (groupCode == null) {
    return baseLabel;
  }

  final followUpGroupLabelPath =
      definition.followUpGroupLabelPath;

  final groupLabel = followUpGroupLabelPath == null
      ? null
      : readDesktopResultStructuredString(
    result,
    followUpGroupLabelPath,
  );

  return '$baseLabel — ${groupLabel ?? groupCode}';
}

double? readDesktopResultMetricValue(
    DesktopResult result,
    String path,
    ) {
  final jsonText = result.structuredJson;

  if (jsonText == null || jsonText.isEmpty) {
    return null;
  }

  try {
    dynamic current = jsonDecode(jsonText);

    for (final part in path.split('.')) {
      if (current is! Map<String, dynamic>) {
        return null;
      }

      current = current[part];

      if (current == null) {
        return null;
      }
    }

    if (current is num) {
      return current.toDouble();
    }

    return null;
  } catch (_) {
    return null;
  }
}

double? readDesktopResultMetricValueWithFallbacks(
    DesktopResult result,
    ExerciseMetricDefinition metric,
    ) {
  final primaryValue = readDesktopResultMetricValue(
    result,
    metric.path,
  );

  if (primaryValue != null) {
    return primaryValue;
  }

  for (final fallbackPath in metric.fallbackPaths) {
    final fallbackValue = readDesktopResultMetricValue(
      result,
      fallbackPath,
    );

    if (fallbackValue != null) {
      return fallbackValue;
    }
  }

  return null;
}

String? readDesktopResultStructuredString(
    DesktopResult result,
    String path,
    ) {
  final jsonText = result.structuredJson;

  if (jsonText == null || jsonText.isEmpty) {
    return null;
  }

  try {
    dynamic current = jsonDecode(jsonText);

    for (final part in path.split('.')) {
      if (current is! Map<String, dynamic>) {
        return null;
      }

      current = current[part];

      if (current == null) {
        return null;
      }
    }

    if (current is String && current.trim().isNotEmpty) {
      return current.trim();
    }

    return null;
  } catch (_) {
    return null;
  }
}
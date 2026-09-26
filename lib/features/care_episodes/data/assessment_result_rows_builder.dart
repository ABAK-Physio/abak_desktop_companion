import 'package:abak_shared/abak_shared.dart';
import '../../../generated/l10n.dart';
import '../../results/desktop_result_grouping.dart';
import '../../results/models/desktop_result.dart';
import '../models/assessment_document_data.dart';

class AssessmentResultRowsBuilder {
  static List<AssessmentDocumentResultRow> build({
    required String selectionKey,
    required List<DesktopResult> results,
  }) {
    final matching = results
        .where((result) => desktopResultSelectionKey(result) == selectionKey)
        .toList()
      ..sort((a, b) {
        final order = a.createdAt.compareTo(b.createdAt);
        return order != 0 ? order : a.resultId.compareTo(b.resultId);
      });
    return matching.map((result) => AssessmentDocumentResultRow(
      date: DateTime.fromMillisecondsSinceEpoch(result.createdAt),
      result: _resultText(result),
      walkingAid: _walkingAid(result),
    )).toList();
  }

  static String _number(num value) => value.toStringAsFixed(2)
      .replaceFirst(RegExp(r'\.?0+$'), '');

  static String _resultText(DesktopResult result) {
    final definition = ClinicalActivityCatalog.infoFor(result.exoId);
    final values = <String>[];
    for (final metric in definition.metrics.where((m) => m.showOnEvolutionChart)) {
      final value = readDesktopResultMetricValueWithFallbacks(result, metric);
      if (value == null) continue;
      final unit = metric.defaultUnit?.trim() ?? '';
      values.add('${metric.fallbackLabel} : ${_number(value)}'
          '${unit.isEmpty ? '' : ' $unit'}');
    }
    if (values.isNotEmpty) return values.join(' ; ');
    if (result.scoreTotal != null) {
      final unit = result.measureUnit?.trim() ?? '';
      return '${_number(result.scoreTotal!)}${unit.isEmpty ? '' : ' $unit'}';
    }
    return '-';
  }

  static String? _walkingAid(DesktopResult result) {
    final aid = result.walkingAid;
    if (aid == null) return null;
    final s = S.current;
    switch (aid.code) {
      case 'none': return s.walkingAid_none;
      case 'cane': return s.walkingAid_cane;
      case 'walkerTwoWheels': return s.walkingAid_walkerTwoWheels;
      case 'rollatorFourWheels': return s.walkingAid_rollatorFourWheels;
      case 'other': return aid.description ?? aid.label ?? s.walkingAid_other;
      default: return aid.label ?? aid.description ?? aid.code ?? '-';
    }
  }
}

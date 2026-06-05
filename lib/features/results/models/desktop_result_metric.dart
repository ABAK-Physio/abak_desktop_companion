class DesktopResultMetric {
  final String metricId;
  final String resultId;
  final String metricKey;
  final double value;
  final String? unit;
  final String? label;

  const DesktopResultMetric({
    required this.metricId,
    required this.resultId,
    required this.metricKey,
    required this.value,
    this.unit,
    this.label,
  });

  factory DesktopResultMetric.fromMap(Map<String, dynamic> map) {
    return DesktopResultMetric(
      metricId: map['metric_id'] as String,
      resultId: map['result_id'] as String,
      metricKey: map['metric_key'] as String,
      value: (map['value'] as num).toDouble(),
      unit: map['unit'] as String?,
      label: map['label'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'metric_id': metricId,
      'result_id': resultId,
      'metric_key': metricKey,
      'value': value,
      'unit': unit,
      'label': label,
    };
  }
}
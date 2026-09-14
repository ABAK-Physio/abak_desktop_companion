import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/results/models/result_walking_aid.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/assessment_document_data.dart';
import 'package:abak_desktop_companion/features/care_episodes/services/assessment_chart_image_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test('Only used accessories trigger the marker', () {
    expect(const ResultWalkingAid(code: 'none', label: 'Aucun').isUsed, isFalse);
    expect(const ResultWalkingAid().isUsed, isFalse);
    expect(const ResultWalkingAid(label: 'Aucun').isUsed, isFalse);
    for (final code in ['cane', 'walkerTwoWheels', 'rollatorFourWheels', 'other']) {
      expect(ResultWalkingAid(code: code).isUsed, isTrue);
    }
  });
  test('Chart with accessory markers exports to PNG', () async {
    final series = AssessmentDocumentChartSeries(label: 'Timed Up and Go', unit: 's', points: [
      AssessmentDocumentChartPoint(date: DateTime(2026, 9, 1), value: 18),
      AssessmentDocumentChartPoint(date: DateTime(2026, 9, 5), value: 15, usesWalkingAid: true),
      AssessmentDocumentChartPoint(date: DateTime(2026, 9, 10), value: 12, usesWalkingAid: true),
    ]);
    final bytes = await const AssessmentChartImageService().buildPng(series: series);
    expect(bytes.take(8), [137, 80, 78, 71, 13, 10, 26, 10]);
    await File('/tmp/companion-accessory-chart.png').writeAsBytes(bytes);
  });
}

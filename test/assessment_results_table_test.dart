import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import 'package:abak_desktop_companion/features/results/models/desktop_result.dart';
import 'package:abak_desktop_companion/features/results/desktop_result_grouping.dart';
import 'package:abak_desktop_companion/features/care_episodes/data/assessment_result_rows_builder.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/assessment_document_data.dart';
import 'package:abak_desktop_companion/features/care_episodes/services/assessment_docx_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => S.load(const Locale('fr', 'FR')));

  test('All measurements are ordered with their own accessory', () {
    DesktopResult result(String id, int date, {String? code, String? label}) => DesktopResult(
      resultId: id, careEpisodeId: 'episode', createdAt: date, importedAt: 1,
      exoId: 'E76', exportSimpleText: '', scoreTotal: 12,
      structuredJson: jsonEncode({'context': {
        if (code != null) 'walkingAidCode': code,
        if (label != null) 'walkingAidLabel': label,
        if (code == 'other') 'walkingAidDescription': label,
      }, 'scores': {'time_seconds': 12.0}}),
    );
    final old = result('old', 1);
    final rows = AssessmentResultRowsBuilder.build(
      selectionKey: desktopResultSelectionKey(old),
      results: [result('new', 3, code: 'other', label: 'Deux cannes'),
        old, result('middle', 2, code: 'none', label: 'Aucun')],
    );
    expect(rows.length, 3);
    expect(rows.map((r) => r.walkingAid), ['-', 'Aucun', 'Deux cannes']);
    expect(rows.map((r) => r.date.millisecondsSinceEpoch), [1, 2, 3]);
    expect(rows.every((r) => r.result.contains('12')), isTrue);
  });

  test('DOCX contains a repeating three-column table and every result', () async {
    final date = DateTime(2026, 9, 14, 10, 30);
    final data = AssessmentDocumentData(
      establishmentName: null, assessmentDate: date, printedAt: date,
      authorName: null, recipientText: null, patientLastName: 'Test',
      patientFirstName: 'Patient', patientSex: null, patientAgeYears: null,
      pathologyLabel: null, careEpisodeOpenedAt: null, referringPractitionerName: null,
      dominantSide: null, profession: null, sport: null, heightCm: null, weightKg: null,
      assessmentText: 'Bilan', notes: const [],
      tests: [AssessmentDocumentTest(selectionKey: 'E76', title: 'E76',
        testDate: date, resultText: 'Détail', declaredAgeYears: null,
        pathologyLabel: null, chartSeries: const [], resultRows: [
          AssessmentDocumentResultRow(date: date, result: '12 s', walkingAid: 'Aucun'),
          AssessmentDocumentResultRow(date: date, result: '10 s', walkingAid: 'Canne & appui <léger>'),
        ])],
    );
    final bytes = await AssessmentDocxService().buildDocx(data: data, chartPngBytes: []);
    final archive = ZipDecoder().decodeBytes(bytes);
    final file = archive.findFile('word/document.xml')!;
    final xml = XmlDocument.parse(utf8.decode(file.content as List<int>));
    final table = xml.findAllElements('w:tbl').single;
    expect(table.findAllElements('w:tr').length, 3);
    expect(table.findAllElements('w:tblHeader').length, 1);
    expect(table.innerText, contains('Accessoire utilisé'));
    expect(table.innerText, contains('12 s'));
    expect(table.innerText, contains('10 s'));
    expect(table.innerText, contains('Canne & appui <léger>'));
  });
}

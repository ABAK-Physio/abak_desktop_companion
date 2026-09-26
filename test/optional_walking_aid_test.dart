import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import 'package:abak_desktop_companion/features/results/models/desktop_result.dart';
import 'package:abak_desktop_companion/features/care_episodes/data/assessment_result_rows_builder.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/assessment_document_data.dart';
import 'package:abak_desktop_companion/features/care_episodes/services/clinical_document_attachments_docx.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => S.load(const Locale('fr', 'FR')));
  final cases = <String, List<Map<String, dynamic>>>{
    'absent': [{}, {}],
    'null': [
      {'walkingAidCode': null},
      {},
    ],
    'empty': [
      {
        'walkingAidCode': '',
        'walkingAidLabel': '  ',
        'walkingAidDescription': null,
      },
      {},
    ],
    'none': [
      {'walkingAidCode': 'none'},
      {},
    ],
    'historical': [
      {'walkingAidCode': 'cane'},
      {},
    ],
    'description': [
      {'walkingAidDescription': 'Deux cannes'},
      {},
    ],
  };
  for (final entry in cases.entries) {
    test('Imported ${entry.key} controls the whole table', () {
      final results = [
        for (var i = 0; i < entry.value.length; i++)
          DesktopResult.fromMap(
            DesktopResult(
              resultId: '$i',
              careEpisodeId: 'episode',
              exoId: 'E76',
              createdAt: i + 1,
              importedAt: 1,
              exportSimpleText: '',
              scoreTotal: 12,
              structuredJson: jsonEncode({'context': entry.value[i]}),
            ).toMap(),
          ),
      ];
      final rows = AssessmentResultRowsBuilder.build(
        selectionKey: 'E76',
        results: results.reversed.toList(),
      );
      final visible = ['none', 'historical', 'description'].contains(entry.key);
      expect(rows.last.walkingAid, isNull);
      expect(rows.first.walkingAid != null, visible);
      final xml = ClinicalDocumentAttachmentsDocx().build(
        tests: [
          AssessmentDocumentTest(
            selectionKey: 'E76',
            title: 'Test',
            testDate: null,
            resultText: '',
            declaredAgeYears: null,
            pathologyLabel: null,
            chartSeries: [],
            resultRows: rows,
          ),
        ],
        notes: [],
        patientAgeYears: null,
        pathologyLabel: null,
      );
      final doc = XmlDocument.parse('<root xmlns:w="w">$xml</root>');
      final table = doc.findAllElements('w:tbl').single;
      final columns = visible ? 3 : 2;
      expect(table.findAllElements('w:gridCol').length, columns);
      for (final row in table.findAllElements('w:tr')) {
        expect(row.findAllElements('w:tc').length, columns);
      }
      expect(table.innerText.contains(S.current.walkingAid_label), visible);
      if (visible)
        expect(
          table
              .findAllElements('w:tr')
              .last
              .findAllElements('w:tc')
              .last
              .innerText
              .trim(),
          '-',
        );
      expect(
        table
            .findAllElements('w:gridCol')
            .map((c) => int.parse(c.getAttribute('w:w')!))
            .reduce((a, b) => a + b),
        9600,
      );
    });
  }
}

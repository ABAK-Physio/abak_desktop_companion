import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/assessment_document_data.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/report_document_data.dart';
import 'package:abak_desktop_companion/features/care_episodes/services/assessment_docx_service.dart';
import 'package:abak_desktop_companion/features/care_episodes/services/report_docx_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() => S.load(const Locale('fr', 'FR')));
  final date = DateTime(2026, 9, 26, 10, 30);
  final chart = AssessmentDocumentChartSeries(
    label: 'Temps',
    unit: 's',
    points: [
      AssessmentDocumentChartPoint(date: date, value: 12),
      AssessmentDocumentChartPoint(date: date, value: 10, usesWalkingAid: true),
    ],
  );
  final png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII=',
  );

  for (final empty in [false, true]) {
    for (final logoExtension in <String?>[null, 'png', 'jpg']) {
      test(
        'Clinical content parity: empty=$empty, logo=$logoExtension',
        () async {
          final tests = empty
              ? <AssessmentDocumentTest>[]
              : [
                  AssessmentDocumentTest(
                    selectionKey: 'E76',
                    title: 'Test & mobilité',
                    testDate: date,
                    resultText: 'Résultat <détaillé>',
                    declaredAgeYears: 43,
                    pathologyLabel: 'Test diagnostic',
                    chartSeries: [chart, chart],
                    resultRows: [
                      AssessmentDocumentResultRow(
                        date: date,
                        result: '12 s',
                        walkingAid: 'Aucune',
                      ),
                      AssessmentDocumentResultRow(
                        date: date,
                        result: '10 s',
                        walkingAid: 'Canne & appui',
                      ),
                    ],
                  ),
                  AssessmentDocumentTest(
                    selectionKey: 'E77',
                    title: 'Deuxième test',
                    testDate: date,
                    resultText: 'Autre résultat',
                    declaredAgeYears: null,
                    pathologyLabel: null,
                    chartSeries: [chart],
                  ),
                ];
          final notes = empty
              ? <AssessmentDocumentNote>[]
              : [
                  AssessmentDocumentNote(
                    noteDate: date,
                    title: 'Suivi & évolution',
                    content: 'Note <sélectionnée>',
                  ),
                ];
          final report = ReportDocumentData(
            establishmentName: null,
            establishmentAddressLine1: null,
            establishmentAddressLine2: null,
            establishmentPostalCode: null,
            establishmentCity: null,
            establishmentPhone: null,
            establishmentEmail: null,
            establishmentLogoPath: null,
            reportDate: date,
            printedAt: date,
            authorName: null,
            recipientText: null,
            patientLastName: 'Patient',
            patientFirstName: 'Test',
            patientSex: null,
            patientAgeYears: 42,
            pathologyLabel: 'Dossier',
            careEpisodeOpenedAt: null,
            referringPractitionerName: null,
            dominantSide: null,
            profession: null,
            sport: null,
            heightCm: null,
            weightKg: null,
            prescribingCorrespondentName: null,
            prescribingCorrespondentProfession: null,
            prescribingCorrespondentSpecialty: null,
            prescribingCorrespondentAddressLine1: null,
            prescribingCorrespondentAddressLine2: null,
            prescribingCorrespondentPostalCode: null,
            prescribingCorrespondentCity: null,
            prescribingCorrespondentEmail: null,
            prescribingCorrespondentPhone: null,
            reportTitle: 'Rapport',
            reportText: 'Texte du rapport',
            tests: tests,
            notes: notes,
          );
          final assessment = AssessmentDocumentData(
            establishmentName: null,
            assessmentDate: date,
            printedAt: date,
            authorName: null,
            recipientText: null,
            patientLastName: 'Patient',
            patientFirstName: 'Test',
            patientSex: null,
            patientAgeYears: 42,
            pathologyLabel: 'Dossier',
            careEpisodeOpenedAt: null,
            referringPractitionerName: null,
            dominantSide: null,
            profession: null,
            sport: null,
            heightCm: null,
            weightKg: null,
            assessmentText: 'Texte du bilan',
            tests: tests,
            notes: notes,
          );
          final images = empty ? <Uint8List>[] : [png, png, png];
          final reportBytes = await ReportDocxService().buildDocx(
            data: report,
            chartPngBytes: images,
            establishmentLogoBytes: logoExtension == null ? null : png,
            establishmentLogoExtension: logoExtension,
          );
          final assessmentBytes = await AssessmentDocxService().buildDocx(
            data: assessment,
            chartPngBytes: images,
          );
          final archive = ZipDecoder().decodeBytes(reportBytes);
          XmlDocument document(Archive a, String path) => XmlDocument.parse(
            utf8.decode(a.findFile(path)!.content as List<int>),
          );
          final doc = document(archive, 'word/document.xml');
          final bilan = document(
            ZipDecoder().decodeBytes(assessmentBytes),
            'word/document.xml',
          );
          final text = doc.innerText;
          if (empty) {
            expect(
              text,
              isNot(contains(S.current.assessmentDocxService_results)),
            );
            expect(
              text,
              isNot(contains(S.current.assessmentDocxService_notes)),
            );
          } else {
            for (final value in [
              'Test & mobilité',
              'Résultat <détaillé>',
              '12 s',
              '10 s',
              'Canne & appui',
              'Suivi & évolution',
              'Note <sélectionnée>',
              'Test diagnostic',
              'Deuxième test',
            ]) {
              expect(text, contains(value));
              expect(bilan.innerText, contains(value));
            }
            final table = doc
                .findAllElements('w:tbl')
                .where((e) => e.innerText.contains('12 s'))
                .single;
            final original = bilan.findAllElements('w:tbl').single;
            expect(table.toXmlString(), original.toXmlString());
            expect(table.findAllElements('w:tblHeader').length, 1);
            expect(table.findAllElements('w:tr').length, 3);
            expect(
              text.indexOf('Note <sélectionnée>'),
              lessThan(text.indexOf('Très cordialement')),
            );
          }
          final relations = document(archive, 'word/_rels/document.xml.rels');
          final imageRelations = relations
              .findAllElements('Relationship')
              .where((e) => e.getAttribute('Type')!.endsWith('/image'))
              .toList();
          final expectedImages =
              images.length + (logoExtension == null ? 0 : 1);
          expect(imageRelations.length, expectedImages);
          final embedded = doc
              .findAllElements('a:blip')
              .map((e) => e.getAttribute('r:embed'))
              .toList();
          expect(embedded.length, expectedImages);
          expect(embedded.toSet().length, expectedImages);
          final drawingIds = doc
              .findAllElements('wp:docPr')
              .map((e) => e.getAttribute('id'))
              .toList();
          expect(drawingIds.toSet().length, expectedImages);
          for (final relation in imageRelations) {
            expect(embedded, contains(relation.getAttribute('Id')));
            expect(
              archive.findFile('word/${relation.getAttribute('Target')}'),
              isNotNull,
            );
          }
        },
      );
    }
  }
}

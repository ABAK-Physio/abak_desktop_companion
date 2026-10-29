import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'package:xml/xml.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/assessment_document_data.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/report_document_data.dart';
import 'package:abak_desktop_companion/features/care_episodes/services/assessment_docx_service.dart';
import 'package:abak_desktop_companion/features/care_episodes/services/report_docx_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await S.load(const Locale('fr', 'FR'));
  final date = DateTime(2026, 9, 26, 10, 30);
  final chart = AssessmentDocumentChartSeries(
    label: 'Temps',
    unit: 's',
    points: [
      AssessmentDocumentChartPoint(date: date, value: 12),
      AssessmentDocumentChartPoint(date: date, value: 10, usesWalkingAid: true),
    ],
  );
  final png = File(
    '${Platform.environment['PDF_BENCH_OUTPUT']!}/courbe.png',
  ).readAsBytesSync();
  final tests = [
    AssessmentDocumentTest(
      selectionKey: 'E76',
      title: 'Test & mobilité',
      testDate: date,
      resultText: 'Score total : 12\nRésultat <détaillé>',
      declaredAgeYears: 43,
      pathologyLabel: 'Test diagnostic',
      chartSeries: [chart, chart],
      resultRows: [
        AssessmentDocumentResultRow(
          date: date,
          result: 'Score total : 12 s',
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
      resultText: 'Score total : 99\nAutre résultat',
      declaredAgeYears: null,
      pathologyLabel: null,
      chartSeries: [chart],
    ),
  ];
  final notes = [
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
    establishmentReportHeaderPath: null,
    reportDate: date,
    printedAt: date,
    authorName: 'SIM-KINE',
    recipientText: null,
    patientLastName: 'SIM-A',
    patientFirstName: 'SYNTHETIQUE',
    patientSex: null,
    patientAgeYears: 42,
    pathologyLabel: 'Dossier',
    careEpisodeOpenedAt: null,
    referringPractitionerName: 'REFERENT-SYNTHETIQUE',
    dominantSide: null,
    profession: null,
    sport: null,
    heightCm: null,
    weightKg: null,
    prescribingCorrespondentName: 'PRESCRIPTEUR-SYNTHETIQUE',
    prescribingCorrespondentProfession: null,
    prescribingCorrespondentSpecialty: null,
    prescribingCorrespondentAddressLine1: null,
    prescribingCorrespondentAddressLine2: null,
    prescribingCorrespondentPostalCode: null,
    prescribingCorrespondentCity: null,
    prescribingCorrespondentEmail: null,
    prescribingCorrespondentPhone: null,
    reportTitle: 'SIMULATION - NE PAS ENVOYER',
    reportText: 'Texte du rapport',
    tests: tests,
    notes: notes,
    reportIntroduction: null,
  );
  final assessment = AssessmentDocumentData(
    establishmentName: null,
    assessmentDate: date,
    printedAt: date,
    authorName: 'SIM-KINE',
    recipientText: null,
    patientLastName: 'SIM-A',
    patientFirstName: 'SYNTHETIQUE',
    patientSex: null,
    patientAgeYears: 42,
    pathologyLabel: 'Dossier',
    careEpisodeOpenedAt: null,
    referringPractitionerName: 'REFERENT-SYNTHETIQUE',
    dominantSide: null,
    profession: null,
    sport: null,
    heightCm: null,
    weightKg: null,
    assessmentText: 'SIMULATION - NE PAS ENVOYER. Texte du bilan',
    tests: tests,
    notes: notes,
  );
  final images = [png, png, png];
  final reportBytes = await ReportDocxService().buildDocx(
    data: report,
    chartPngBytes: images,
  );
  final assessmentBytes = await AssessmentDocxService().buildDocx(
    data: assessment,
    chartPngBytes: images,
  );

  final out = Directory(Platform.environment['PDF_BENCH_OUTPUT']!);
  out.createSync(recursive: true);
  File('${out.path}/abak_rapport.docx').writeAsBytesSync(reportBytes);
  File('${out.path}/abak_bilan.docx').writeAsBytesSync(assessmentBytes);
  final without = await ReportDocxService().buildDocx(
    data: report,
    chartPngBytes: images,
    showPrescriber: false,
    showReferringPractitioner: false,
  );
  final xml = utf8.decode(
    ZipDecoder().decodeBytes(without).findFile('word/document.xml')!.content
        as List<int>,
  );
  if (xml.contains('PRESCRIPTEUR-SYNTHETIQUE') ||
      xml.contains('REFERENT-SYNTHETIQUE')) {
    throw StateError('Correspondants masqués non respectés');
  }
  for (final bytes in [reportBytes, assessmentBytes]) {
    final a = ZipDecoder().decodeBytes(bytes);
    final text = XmlDocument.parse(
      utf8.decode(a.findFile('word/document.xml')!.content as List<int>),
    ).innerText;
    for (final value in [
      'SIM-A',
      'SIM-KINE',
      'Note <sélectionnée>',
      '12 s',
      'Canne & appui',
    ]) {
      if (!text.contains(value)) throw StateError('Absent : $value');
    }
    if (text.contains('NOTE_EXCLUE')) throw StateError('Note exclue présente');
    if (a.files.where((f) => f.name.startsWith('word/media/')).length != 3) {
      throw StateError('Graphiques manquants');
    }
  }
  File('${out.path}/generateurs_ok.json').writeAsStringSync(
    jsonEncode({
      'bilan': true,
      'rapport': true,
      'correspondantsMasques': true,
      'medias': 3,
      'scope':
          'rendu de données sélectionnées injectées ; sélection dépôt métier non exécutée',
    }),
  );
  exit(0);
}

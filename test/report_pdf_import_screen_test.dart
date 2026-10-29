import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/features/care_episodes/screens/report_docx_pdf_screen.dart';
import 'package:abak_desktop_companion/features/patients/models/episode_document_version.dart';
import 'package:abak_desktop_companion/features/patients/services/document_controls_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/patients/services/final_pdf_document_service.dart';
import 'package:abak_desktop_companion/features/patients/services/pdf_conversion_evidence.dart';
import 'package:abak_desktop_companion/features/patients/services/pdfa_preflight_service.dart';

class SourceDatabase implements Database {
  String title = 'Rapport test';
  @override
  Future<List<Map<String, Object?>>> query(
    String table, {
    bool? distinct,
    List<String>? columns,
    String? where,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    String? orderBy,
    int? limit,
    int? offset,
  }) async => switch (table) {
    'care_episodes' => [
      {'care_episode_id': 'episode', 'patient_id': 'patient'},
    ],
    'care_episode_reports' => [
      {'report_id': 'report', 'title': title, 'docx_file_name': null},
    ],
    _ => throw StateError('Unexpected database call: $table'),
  };
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Unexpected database access');
}

class ImportPdf extends FinalPdfDocumentService {
  ImportPdf(SourceDatabase db) : super(database: () async => db);
  int imports = 0;
  final imported = const EpisodeDocumentVersion({
    'version_id': 'v1',
    'sequence_number': 1,
    'page_count': 2,
  });
  @override
  Future<EpisodeDocumentVersion?> latestForOrigin(
    String episode,
    PdfOrigin origin,
  ) async => null;
  @override
  Future<EpisodeDocumentVersion> importPdf({
    required String episodeId,
    required String sourcePath,
    required String title,
    String? documentId,
    PdfOrigin origin = const PdfOrigin('external'),
    PdfConversionEvidence? conversion,
    bool reuseOriginDocument = false,
    String? expectedSourceRevision,
  }) async {
    imports++;
    expect(episodeId, 'episode');
    expect(origin.kind, 'report');
    expect(origin.id, 'report');
    expect(reuseOriginDocument, true);
    expect(expectedSourceRevision, isNotEmpty);
    expect(conversion, isNull);
    return imported;
  }
}

class Preflight extends PdfaPreflightService {
  Preflight(super.controls);
  int calls = 0;
  String verdict = 'conforme';
  @override
  Future<String> check(EpisodeDocumentVersion version) async {
    calls++;
    return verdict;
  }
}

void main() {
  testWidgets(
    'export guide separates evidence and does not import or validate',
    (tester) async {
      tester.view.physicalSize = const Size(600, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final db = SourceDatabase();
      final pdf = ImportPdf(db);
      final controls = DocumentControlsService(
        medical: DocumentMedicalService(pdf: pdf),
      );
      final preflight = Preflight(controls);
      await tester.pumpWidget(
        MaterialApp(
          home: ReportDocxPdfScreen(
            episodeId: 'episode',
            patientId: 'patient',
            patientName: 'Patient test',
            reportId: 'report',
            reportTitle: 'Rapport test',
            pdfService: pdf,
            controlsService: controls,
            preflightService: preflight,
            pickPdf: () async => throw StateError('Guide must not open picker'),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('report-pdf-export-guide')),
      );
      await tester.tap(find.byKey(const Key('report-pdf-export-guide')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Aucun des parcours d’export'),
        findsOneWidget,
      );
      expect(find.text('Word — Windows'), findsOneWidget);
      expect(find.text('Word — macOS'), findsOneWidget);
      expect(find.text('PDF/A non confirmé — non testé'), findsOneWidget);
      expect(
        find.text('Export testé — non conforme à PDF/A-1b'),
        findsOneWidget,
      );
      await tester.ensureVisible(
        find.text('PDF existant → Adobe Acrobat Pro — macOS et Windows'),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Fermer'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(pdf.imports, 0);
      expect(preflight.calls, 0);
    },
  );

  for (final verdict in ['conforme', 'refuse', 'non_verifie']) {
    testWidgets('import without DOCX runs preflight automatically: $verdict', (
      tester,
    ) async {
      final db = SourceDatabase();
      final pdf = ImportPdf(db);
      final controls = DocumentControlsService(
        medical: DocumentMedicalService(pdf: pdf),
      );
      final preflight = Preflight(controls)..verdict = verdict;
      await tester.pumpWidget(
        MaterialApp(
          home: ReportDocxPdfScreen(
            episodeId: 'episode',
            patientId: 'patient',
            patientName: 'Patient test',
            reportId: 'report',
            reportTitle: 'Rapport test',
            pdfService: pdf,
            controlsService: controls,
            preflightService: preflight,
            pickPdf: () async => '/external.pdf',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('report-import-pdf')));
      await tester.tap(find.byKey(const Key('report-import-pdf')));
      await tester.pumpAndSettle();
      if (verdict == 'refuse') {
        expect(
          find.textContaining(
            'sinon, convertissez le PDF avec un outil adapté',
          ),
          findsOneWidget,
        );
      }
      if (verdict == 'non_verifie') {
        expect(
          find.textContaining(
            'avant de décider si une conversion est nécessaire',
          ),
          findsOneWidget,
        );
      }
      expect(pdf.imports, 1);
      expect(preflight.calls, 1);
      expect(
        find.textContaining(PdfaPreflightService.message(verdict)),
        findsOneWidget,
      );
      expect(find.text('Convertir avec LibreOffice (option)'), findsOneWidget);
      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();
      expect(find.text('Contexte et validation médicale'), findsOneWidget);
      expect(find.text('Convertir avec LibreOffice (option)'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
  for (final changed in [false, true]) {
    testWidgets(
      changed
          ? 'changed report blocks import'
          : 'cancelled picker leaves history intact',
      (tester) async {
        final db = SourceDatabase();
        final pdf = ImportPdf(db);
        final controls = DocumentControlsService(
          medical: DocumentMedicalService(pdf: pdf),
        );
        final preflight = Preflight(controls);
        await tester.pumpWidget(
          MaterialApp(
            home: ReportDocxPdfScreen(
              episodeId: 'episode',
              patientId: 'patient',
              patientName: 'Patient test',
              reportId: 'report',
              reportTitle: 'Rapport test',
              pdfService: pdf,
              controlsService: controls,
              preflightService: preflight,
              pickPdf: () async {
                if (changed) {
                  db.title = 'Changed';
                  return '/external.pdf';
                }
                return null;
              },
            ),
          ),
        );
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.byKey(const Key('report-import-pdf')));
        await tester.tap(find.byKey(const Key('report-import-pdf')));
        await tester.pumpAndSettle();
        expect(pdf.imports, 0);
        expect(preflight.calls, 0);
        if (changed) {
          expect(find.textContaining('Le rapport a changé'), findsOneWidget);
        }
      },
    );
  }
}

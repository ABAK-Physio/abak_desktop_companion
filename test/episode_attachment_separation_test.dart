import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import 'package:abak_desktop_companion/features/patients/data/episode_document_repository.dart';
import 'package:abak_desktop_companion/features/patients/models/episode_document.dart';
import 'package:abak_desktop_companion/features/patients/models/episode_document_version.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_attachment_service.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_documents_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/features/patients/services/final_pdf_document_service.dart';
import 'package:abak_desktop_companion/features/patients/screens/episode_attachments_screen.dart';
import 'package:abak_desktop_companion/features/patients/screens/episode_documents_screen.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/care_episode.dart';
import 'package:abak_desktop_companion/features/care_episodes/screens/care_episode_reports_workspace/widgets/episode_header.dart';

EpisodeDocument doc(String title, String? source, {String path = '/missing'}) =>
    EpisodeDocument(
      documentId: title,
      caseId: 'episode',
      title: title,
      filePath: path,
      source: source,
      createdAt: 1,
    );

class Repository extends EpisodeDocumentRepository {
  final documents = [
    doc('Attachment', 'local_copy'),
    doc('DMP', 'final_pdf'),
    doc('Unknown', null),
  ];
  @override
  Future<List<EpisodeDocument>> getByCaseId(String caseId) async {
    expect(caseId, 'episode');
    return documents;
  }

  @override
  Future<EpisodeDocument> create({
    required String caseId,
    required String title,
    required String filePath,
    String? mimeType,
    String? source,
  }) async {
    expect(caseId, 'episode');
    expect(source, 'local_copy');
    final document = doc(title, source, path: filePath);
    documents.add(document);
    return document;
  }
}

class AttachmentDb implements Database {
  AttachmentDb(this.root);
  final String root;
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
      {'patient_id': 'patient'},
    ],
    'patient_document_folders' => [
      {'root_path': root, 'folder_name': 'patient'},
    ],
    _ => throw StateError('Unexpected table $table'),
  };
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('Unexpected database access');
}

class AttachmentAccess extends AttachmentDirectoryAccess {
  const AttachmentAccess(this.root);
  final String root;
  @override
  Future<AttachmentDirectoryLease?> configured() async =>
      AttachmentDirectoryLease(root);
  @override
  Future<AttachmentDirectoryLease> acquire(String root) async =>
      AttachmentDirectoryLease(root);
}

class Pdf extends FinalPdfDocumentService {
  final requested = <String>[];
  @override
  Future<List<EpisodeDocumentVersion>> versions(String id) async {
    requested.add(id);
    return [];
  }
}

Widget app(Widget child) => MaterialApp(
  locale: const Locale('fr', 'FR'),
  supportedLocales: S.delegate.supportedLocales,
  localizationsDelegates: const [
    S.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  home: child,
);

class CancelledDestinationAccess extends AttachmentDirectoryAccess {
  int choices = 0;
  @override
  Future<bool> configure() async {
    choices++;
    return false;
  }
}

class MissingDestinationService extends PatientAttachmentService {
  MissingDestinationService(AttachmentDirectoryAccess access)
    : super(access: access);
  @override
  Future<EpisodeDocument> add({
    required String caseId,
    required String sourcePath,
  }) async => throw AttachmentDestinationRequired();
}

void main() {
  testWidgets('cancelled file picker leaves ordinary attachments unchanged', (
    tester,
  ) async {
    final repo = Repository();
    await tester.pumpWidget(
      app(
        EpisodeAttachmentsScreen(
          caseId: 'episode',
          caseLabel: 'Case',
          repository: repo,
          pickFile: () async => null,
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('add-ordinary-document')));
    await tester.pumpAndSettle();
    expect(repo.documents.length, 3);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'missing destination offers explicit configuration and respects cancellation',
    (tester) async {
      final repo = Repository();
      final access = CancelledDestinationAccess();
      await tester.pumpWidget(
        app(
          EpisodeAttachmentsScreen(
            caseId: 'episode',
            caseLabel: 'Case',
            repository: repo,
            service: MissingDestinationService(access),
            pickFile: () async => '/source.txt',
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const Key('add-ordinary-document')));
      await tester.pumpAndSettle();
      expect(access.choices, 0);
      expect(find.byType(SnackBarAction), findsOneWidget);
      await tester.tap(find.byType(SnackBarAction));
      await tester.pumpAndSettle();
      expect(access.choices, 1);
      expect(repo.documents.length, 3);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('ordinary attachments filter, add a stored copy and open it', (
    tester,
  ) async {
    final temp = Directory.systemTemp.createTempSync('attachments-test');
    addTearDown(() => temp.deleteSync(recursive: true));
    final source = File('${temp.path}/note.txt')
      ..writeAsStringSync('attachment');
    final repository = Repository();
    String? opened;
    await tester.pumpWidget(
      app(
        EpisodeAttachmentsScreen(
          caseId: 'episode',
          caseLabel: 'Case',
          repository: repository,
          service: PatientAttachmentService(
            database: () async => AttachmentDb(temp.path),
            repository: repository,
            access: AttachmentAccess(temp.path),
            supportDirectory: () async => temp,
            ensureFolders: (patient, root) async {
              final folders = PatientDocumentFolders('$root/patient');
              await Directory(folders.other).create(recursive: true);
              return folders;
            },
          ),
          pickFile: () async => source.path,
          openFile: (path) async => opened = path,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Attachment'), findsOneWidget);
    expect(find.text('DMP'), findsNothing);
    expect(find.text('Unknown'), findsNothing);
    expect(find.byKey(const Key('import-final-pdf')), findsNothing);
    await tester.runAsync(() async {
      final button = tester.widget<FilledButton>(
        find.byKey(const Key('add-ordinary-document')),
      );
      await (button.onPressed as dynamic)();
      await tester.pump();
      await Future<void>.delayed(Duration.zero);
    });
    await tester.pumpAndSettle();
    expect(find.text('note.txt'), findsOneWidget);
    final added = repository.documents.last;
    expect(added.filePath, contains('/patient/Autre/'));
    expect(File(added.filePath).readAsStringSync(), 'attachment');
    await tester.runAsync(() async {
      final tile = tester.widget<ListTile>(
        find.ancestor(
          of: find.text('note.txt'),
          matching: find.byType(ListTile),
        ),
      );
      await (tile.onTap as dynamic)();
    });
    expect(opened, added.filePath);
    expect(tester.takeException(), isNull);
  });
  testWidgets('DMP loads only final PDFs and retains import actions', (
    tester,
  ) async {
    final pdf = Pdf();
    await tester.pumpWidget(
      app(
        EpisodeDocumentsScreen(
          caseId: 'episode',
          caseLabel: 'Case',
          repository: Repository(),
          finalPdfService: pdf,
          showExpertInfo: false,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(pdf.requested, ['DMP']);
    expect(find.text('DMP'), findsOneWidget);
    expect(find.text('Attachment'), findsNothing);
    expect(find.byKey(const Key('add-ordinary-document')), findsNothing);
    expect(find.byKey(const Key('import-final-pdf')), findsOneWidget);
    expect(find.byKey(const Key('convert-docx-pdfa')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final width in [320.0, 700.0, 1400.0]) {
    testWidgets('header distinct actions without overflow at $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 1000);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var attachments = 0;
      var dmp = 0;
      await tester.pumpWidget(
        app(
          Scaffold(
            body: EpisodeHeader(
              episode: const CareEpisode(
                careEpisodeId: 'episode',
                patientId: 'patient',
                title: 'Test',
                pathologyLabel:
                    'Longue description de la pathologie de cet épisode',
                createdAt: 1,
              ),
              practitionerFuture: Future.value(null),
              prescribingCorrespondentFuture: Future.value(null),
              onEditPractitioner: () {},
              onShowHistory: () {},
              onOpenBodymap: () {},
              onOpenDocuments: () => attachments++,
              onOpenDmpDocuments: () => dmp++,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.attach_file));
      expect(attachments, 1);
      expect(dmp, 0);
      await tester.tap(find.byIcon(Icons.file_present_outlined));
      expect(attachments, 1);
      expect(dmp, 1);
      expect(find.byTooltip('Documents DMP'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}

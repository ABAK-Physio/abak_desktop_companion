// Opt-in incident regression: source database is read-only, all writes are
// confined to an in-memory copy. Tool inspection is stubbed; no validators,
// CPS or transport are invoked. No incident identifiers are stored here.
import 'package:abak_desktop_companion/core/database/document_dv1_schema.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/features/patients/models/episode_document_version.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/dv1_retry.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_controls_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_journal_service.dart';
import 'package:abak_desktop_companion/features/patients/services/document_native_controls.dart';
import 'package:abak_desktop_companion/features/patients/services/final_pdf_document_service.dart';

class ReadOnlyPdf extends FinalPdfDocumentService {
  ReadOnlyPdf({required super.database, required super.root});
  @override
  Future<File> verifyStoredBytes(EpisodeDocumentVersion version) async {
    if (!RegExp(
      r'^version-[a-f0-9-]{36}/document\.pdf$',
    ).hasMatch(version.relativePath)) {
      throw StateError('Invalid fixture path');
    }
    final file = File('${(await root()).path}/${version.relativePath}');
    final bytes = await file.readAsBytes();
    if (bytes.length != version.size ||
        FinalPdfDocumentService.hash(bytes) != version.digest) {
      throw StateError('PDF changed');
    }
    return file;
  }
}

class RecordedRunner implements DocumentControlRunner {
  RecordedRunner(this.config);
  final Map<String, Object?> config;
  @override
  Future<Map<String, Object?>> inspect(Map<String, String> paths) async =>
      config;
  @override
  Future<NativeControlOutput> execute(Map<String, Object?> c, Directory d) =>
      throw StateError('No control execution allowed');
}

class ReadOnlyControls extends DocumentControlsService {
  ReadOnlyControls({
    required super.medical,
    required super.runner,
    required this.directory,
  });
  final Directory directory;
  @override
  Future<Directory> get root async => directory;
}

void main() {
  test(
    'incident: prepare, preserve no-op, reserve atomically, reject changes',
    () async {
      sqfliteFfiInit();
      final source = await databaseFactoryFfi.openDatabase(
        Platform.environment['ABAK_RETRY_DB']!,
        options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
      );
      final db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
        options: OpenDatabaseOptions(singleInstance: false),
      );
      addTearDown(() async {
        await source.close();
        await db.close();
      });
      final schemas = await source.rawQuery(
        "SELECT name,sql FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%'",
      );
      for (final t in schemas) {
        await db.execute(t['sql'] as String);
        for (final row in await source.query(t['name'] as String)) {
          await db.insert(t['name'] as String, row);
        }
      }
      for (final t in await source.rawQuery(
        "SELECT sql FROM sqlite_master WHERE type='trigger'",
      )) {
        await db.execute(t['sql'] as String);
      }
      await createDocumentDv1Tables(db);
      final v = EpisodeDocumentVersion(
        (await db.query(
          'episode_document_versions',
          where: 'version_id=?',
          whereArgs: [Platform.environment['ABAK_RETRY_VERSION']!],
        )).single,
      );
      final controlsRoot = Directory(
        Platform.environment['ABAK_RETRY_CONTROLS']!,
      );
      final medical = DocumentMedicalService(
        pdf: ReadOnlyPdf(
          database: () async => db,
          root: () async => controlsRoot.parent,
        ),
      );
      final config =
          jsonDecode(
                (await db.query('document_control_config')).single['data_json']
                    as String,
              )
              as Map<String, dynamic>;
      final controls = ReadOnlyControls(
        medical: medical,
        runner: RecordedRunner(config),
        directory: controlsRoot,
      );
      final journal = DocumentJournalService(controls: controls);
      final review = await Dv1Retry.inspect(db, v, controlsRoot);
      final invalidBefore = await db.query('document_approval_invalidations');
      final controlInvalidBefore = await db.query(
        'document_control_invalidations',
      );
      await expectLater(
        db.transaction((tx) => medical.approvedCapture(tx, v)),
        throwsA(anything),
      );
      final prepared = await journal.prepare(v, retry: review);
      review.checkPreparation(
        prepared.receipt,
        prepared.run,
        prepared.payloadHash,
      );
      final prep = (await db.query(
        'document_preparations',
        where: 'version_id=?',
        whereArgs: [v.id],
      )).single;
      final changesBefore = await db.query('document_medical_changes');
      final draft = Map<String, String>.from(
        jsonDecode(prep['data_json'] as String),
      );
      final saved = await medical.savePreparation(
        v,
        draft,
        expectedRevision: prep['revision'] as int,
      );
      expect(saved, prep);
      expect(await db.query('document_medical_changes'), changesBefore);
      expect(await db.query('document_approval_invalidations'), invalidBefore);
      expect(
        await db.query('document_control_invalidations'),
        controlInvalidBefore,
      );
      await expectLater(
        medical.savePreparation(
          v,
          draft,
          expectedRevision: (prep['revision'] as int) - 1,
        ),
        throwsA(anything),
      );
      // A real content edit remains a strict rejection. Roll back this test edit.
      try {
        await db.transaction((tx) async {
          await tx.update(
            'document_preparations',
            {
              'data_json': medicalCanonical({
                ...draft,
                'title': 'Changed synthetic title',
              }),
            },
            where: 'version_id=?',
            whereArgs: [v.id],
          );
          await expectLater(review.capture(medical, tx, v), throwsA(anything));
          throw StateError('rollback');
        });
      } catch (e) {
        if (e is! StateError || e.message != 'rollback') rethrow;
      }
      // An unrelated intervening source change remains blocked, even with same snapshot values.
      try {
        await db.transaction((tx) async {
          await tx.insert('document_medical_changes', {
            'source_table': 'patients',
            'source_id': 'synthetic',
          });
          await expectLater(review.capture(medical, tx, v), throwsA(anything));
          throw StateError('rollback');
        });
      } catch (e) {
        if (e is! StateError || e.message != 'rollback') rethrow;
      }
      final original = (await db.query(
        'document_chain_steps',
        where: "chain_id=? AND phase='dv1_reservation'",
        whereArgs: [review.attemptId],
      )).single;
      await journal.reserveDv1(
        v,
        prepared,
        chainId: 'isolated-retry',
        retry: review,
        record: (tx, id) async {
          final data = {
            ...jsonDecode(original['data_json'] as String) as Map,
            'attemptId': id,
            'retry': review.evidence,
          };
          await tx.insert('document_chain_steps', {
            ...original,
            'step_id': 'isolated-retry',
            'chain_id': id,
            'data_json': medicalCanonical(data),
            'data_hash': medicalHash(data),
          });
        },
      );
      // This is the actual post-reservation check used just before transport.
      await db.transaction((tx) => review.capture(medical, tx, v));
      expect((await controls.status(v, retry: review)).pdfa, 'conforme');
      await expectLater(
        journal.reserveDv1(
          v,
          prepared,
          chainId: 'isolated-second',
          retry: review,
          record: (tx, id) async {},
        ),
        throwsA(anything),
      );
      expect(await db.query('document_approval_invalidations'), invalidBefore);
      expect(
        await db.query('document_control_invalidations'),
        controlInvalidBefore,
      );
      await medical.savePreparation(v, {
        ...draft,
        'title': 'Changed synthetic title',
      }, expectedRevision: prep['revision'] as int);
      await expectLater(
        db.transaction((tx) => review.capture(medical, tx, v)),
        throwsA(anything),
      );
      expect(
        (await db.query('document_medical_changes')).length,
        greaterThan(changesBefore.length),
      );
    },
    skip:
        [
          'ABAK_RETRY_DB',
          'ABAK_RETRY_CONTROLS',
          'ABAK_RETRY_VERSION',
        ].any((key) => (Platform.environment[key] ?? '').isEmpty)
        ? 'Requires explicit local incident paths; source opened read-only'
        : false,
  );
}

import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/features/practitioners/data/practitioner_repository.dart';
import 'package:abak_desktop_companion/features/practitioners/data/practitioner_departure_patient.dart';
import 'package:abak_desktop_companion/features/practitioners/services/practitioner_departure_export_service.dart';
import 'package:abak_desktop_companion/features/maintenance/services/backup_directory_access.dart';
import 'support/companion_access_test_support.dart';

class TestDirectoryAccess extends BackupDirectoryAccess {
  TestDirectoryAccess(this.path);
  final String? path;
  @override
  Future<BackupDirectoryLease?> choose(String title) async =>
      path == null ? null : BackupDirectoryLease(path!);
  @override
  Future<BackupDirectoryLease> read(String path) async =>
      BackupDirectoryLease(path);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory temp;
  late Database db;
  late PractitionerRepository repository;
  late PractitionerDepartureExportService exporter;
  final now = DateTime(2026, 11, 23);
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('departure_test_');
    temp = Directory(await temp.resolveSymbolicLinks());
    db = await openAccessTestDatabase('${temp.path}/db');
    repository = PractitionerRepository(database: () async => db);
    exporter = PractitionerDepartureExportService(
      database: () async => db,
      access: TestDirectoryAccess(temp.path),
      support: () async => temp,
    );
    for (final id in ['p', 'q', 'other']) {
      await db.insert('patients', {
        'patient_id': id,
        'last_name': 'Patient',
        'first_name': id,
        'created_at': 1,
        'updated_at': now.millisecondsSinceEpoch,
        if (id == 'q') 'archived_at': 2,
      });
      await db.insert('companion_patient_access', {
        'patient_id': id,
        'referring_practitioner_id': id == 'other' ? 'b' : 'a',
      });
      await db.insert('care_episodes', {
        'care_episode_id': 'e$id',
        'patient_id': id,
        'title': 'Episode',
        'pathology_label': 'Test',
        'created_at': 1,
      });
    }
  });
  tearDown(() async {
    await db.close();
    await temp.delete(recursive: true);
  });
  Future<void> report({int stamp = 1}) => db.insert('care_episode_reports', {
    'report_id': 'r',
    'care_episode_id': 'ep',
    'title': 'Rapport',
    'content_json': '{}',
    'created_at': stamp,
    'report_date': stamp,
    'author_practitioner_id': 'b',
  });
  test(
    'v54 migration preserves report rows and flags legacy dates as indicative',
    () async {
      await report(stamp: now.millisecondsSinceEpoch);
      final before = await db.query('care_episode_reports');
      for (final suffix in ['insert', 'update', 'delete']) {
        await db.execute('DROP TRIGGER companion_report_activity_$suffix');
      }
      await db.execute('DROP TABLE companion_report_activity');
      await db.execute('PRAGMA user_version=54');
      await db.close();
      db = await DatabaseService.openDatabaseFile(
        '${temp.path}/db',
        factory: databaseFactoryFfi,
      );
      expect(await db.query('care_episode_reports'), before);
      final patients = await repository.departurePatients('a', now: now);
      expect(patients.firstWhere((p) => p.id == 'p').inferred, isTrue);
      expect(patients.firstWhere((p) => p.id == 'p').active, isTrue);
    },
  );
  test(
    'symbolic links cannot include files outside the patient folder',
    () async {
      final directory = Directory('${temp.path}/Patient');
      await directory.create();
      await File('${temp.path}/secret').writeAsString('NEVER_EXPORT');
      await Link('${directory.path}/linked').create('${temp.path}/secret');
      await db.insert('patient_document_folders', {
        'patient_id': 'p',
        'root_path': temp.path,
        'folder_name': 'Patient',
      });
      await expectLater(
        exporter.export('a', {'p'}),
        throwsA(isA<FileSystemException>()),
      );
      expect(
        await temp
            .list()
            .where(
              (f) => f.path.endsWith('.zip') || f.path.endsWith('.partial'),
            )
            .length,
        0,
      );
    },
  );
  test(
    'failed journal write rolls back archive and patient unassignment',
    () async {
      await db.execute(
        "CREATE TRIGGER fail_departure BEFORE INSERT ON companion_access_events BEGIN SELECT RAISE(ABORT, 'test failure'); END",
      );
      await expectLater(
        repository.archivePractitioner('a'),
        throwsA(isA<DatabaseException>()),
      );
      expect(
        (await db.query(
          'companion_patient_access',
          where: 'patient_id=?',
          whereArgs: ['p'],
        )).single['referring_practitioner_id'],
        'a',
      );
      expect(
        (await db.query(
          'practitioners',
          where: 'practitioner_id=?',
          whereArgs: ['a'],
        )).single['archived_at'],
        isNull,
      );
    },
  );
  test(
    'managed attachment and frozen PDF are copied; an altered PDF prevents export',
    () async {
      final file = File('${temp.path}/episode_documents/ep/attachment.txt');
      await file.parent.create(recursive: true);
      await file.writeAsString('Attachment');
      await db.insert('episode_documents', {
        'document_id': 'doc',
        'case_id': 'ep',
        'title': 'Pièce',
        'file_path': file.path,
        'created_at': 1,
      });
      final pdf = File('${temp.path}/episode_document_versions/p/version.pdf');
      await pdf.parent.create(recursive: true);
      await pdf.writeAsString('%PDF-fixture');
      final bytes = await pdf.readAsBytes();
      await db.insert('episode_document_versions', {
        'version_id': 'version',
        'document_id': 'doc',
        'patient_id': 'p',
        'episode_id': 'ep',
        'sequence_number': 1,
        'relative_path': 'p/version.pdf',
        'sha256': sha256.convert(bytes).toString(),
        'byte_size': bytes.length,
        'mime_type': 'application/pdf',
        'page_count': 1,
        'source_kind': 'external',
        'captured_at': 1,
      });
      final receipt = (await exporter.export('a', {'p'}))!;
      final zip = ZipDecoder().decodeBytes(
        await File(receipt.path).readAsBytes(),
      );
      expect(
        zip.files.where((f) => f.name.endsWith('attachment.txt')).length,
        1,
      );
      expect(zip.files.where((f) => f.name.endsWith('version.pdf')).length, 1);
      await pdf.writeAsString('altered');
      await expectLater(exporter.export('a', {'p'}), throwsStateError);
      expect(await temp.list().where((f) => f.path.endsWith('.zip')).length, 1);
    },
  );
  test(
    'archive unassigns every patient, preserves author and departure, restore does not reassign',
    () async {
      await report();
      await repository.archivePractitioner(
        'a',
        departureDate: DateTime(2026, 1, 2),
        expectedPatientIds: {'p', 'q'},
      );
      final rows = await db.query(
        'companion_patient_access',
        where: 'patient_id IN (?,?)',
        whereArgs: ['p', 'q'],
      );
      expect(
        rows.every(
          (r) =>
              r['referring_practitioner_id'] == null &&
              r['former_practitioner_id'] == 'a' &&
              r['departure_date'] ==
                  DateTime(2026, 1, 2).millisecondsSinceEpoch,
        ),
        isTrue,
      );
      expect(
        (await db.query(
          'care_episode_reports',
        )).single['author_practitioner_id'],
        'b',
      );
      expect(
        (await db.query(
          'companion_patient_access',
          where: 'patient_id=?',
          whereArgs: ['other'],
        )).single['referring_practitioner_id'],
        'b',
      );
      await repository.restorePractitioner('a');
      expect(
        (await db.query(
          'companion_patient_access',
          where: 'patient_id=?',
          whereArgs: ['p'],
        )).single['referring_practitioner_id'],
        isNull,
      );
    },
  );
  test('administrator cannot prepare or archive departure', () async {
    await db.insert('companion_practitioner_access', {
      'practitioner_id': 'a',
      'is_administrator': 1,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    await expectLater(repository.departurePatients('a'), throwsStateError);
    await expectLater(repository.archivePractitioner('a'), throwsStateError);
    expect(
      (await db.query(
        'practitioners',
        where: 'practitioner_id=?',
        whereArgs: ['a'],
      )).single['archived_at'],
      isNull,
    );
  });
  test(
    'stale list and export validation failure leave everything unchanged',
    () async {
      await expectLater(
        repository.archivePractitioner('a', expectedPatientIds: {'p'}),
        throwsStateError,
      );
      await expectLater(
        repository.archivePractitioner(
          'a',
          verifyExport: (_) async => throw StateError('changed'),
        ),
        throwsStateError,
      );
      expect(
        (await db.query(
          'companion_patient_access',
          where: 'patient_id=?',
          whereArgs: ['p'],
        )).single['referring_practitioner_id'],
        'a',
      );
    },
  );
  test('calendar cutoff clamps end of month', () {
    expect(
      threeCalendarMonthsBefore(DateTime(2026, 5, 31)),
      DateTime(2026, 2, 28),
    );
  });
  test(
    'recent import and patient update do not make an old test active',
    () async {
      await db.insert('desktop_results', {
        'result_id': 'r',
        'care_episode_id': 'ep',
        'createdAt': 1,
        'imported_at': now.millisecondsSinceEpoch,
        'exoId': 'x',
        'exportSimpleText': 'Test',
      });
      expect(
        (await repository.departurePatients(
          'a',
          now: now,
        )).every((p) => !p.active),
        isTrue,
      );
      await db.update('desktop_results', {
        'createdAt': DateTime(2026, 8, 23).millisecondsSinceEpoch,
      });
      expect(
        (await repository.departurePatients(
          'a',
          now: now,
        )).firstWhere((p) => p.id == 'p').active,
        isTrue,
      );
    },
  );
  test(
    'report administrative updates do not count as content activity',
    () async {
      await report();
      await db.update('care_episode_reports', {
        'archived_at': now.millisecondsSinceEpoch,
        'updated_at': now.millisecondsSinceEpoch,
      });
      expect(
        (await repository.departurePatients(
          'a',
          now: now,
        )).firstWhere((p) => p.id == 'p').active,
        isFalse,
      );
      await db.update('care_episode_reports', {
        'content_json': '{"text":"edited"}',
      });
      expect(
        (await repository.departurePatients(
          'a',
          now: DateTime.now().add(const Duration(seconds: 1)),
        )).firstWhere((p) => p.id == 'p').active,
        isTrue,
      );
    },
  );
  test(
    'export includes selected database data and Autre, excludes other patients and secrets',
    () async {
      await report();
      final folder = Directory('${temp.path}/documents/Patient/Autre');
      await folder.create(recursive: true);
      await File('${folder.path}/note.txt').writeAsString('Pièce jointe');
      await db.insert('patient_document_folders', {
        'patient_id': 'p',
        'root_path': '${temp.path}/documents',
        'folder_name': 'Patient',
      });
      await db.insert('application_settings', {
        'setting_key': 'secret',
        'setting_value': 'NEVER_EXPORT',
        'updated_at': 1,
      });
      final receipt = (await exporter.export('a', {'p'}))!;
      final zip = ZipDecoder().decodeBytes(
        await File(receipt.path).readAsBytes(),
        verify: true,
      );
      expect(zip.findFile('Patient_1/Documents_1/Autre/note.txt'), isNotNull);
      final json = utf8.decode(
        zip.findFile('Patient_1/Dossier.json')!.content as List<int>,
      );
      expect(json, contains('Rapport'));
      expect(json, isNot(contains('NEVER_EXPORT')));
      expect(json, isNot(contains('other')));
      await repository.archivePractitioner(
        'a',
        expectedPatientIds: {'p', 'q'},
        verifyExport: receipt.verifyDatabase,
      );
    },
  );
  test('changed dossier refuses archive but keeps completed export', () async {
    final receipt = (await exporter.export('a', {'p'}))!;
    await db.update(
      'patients',
      {'first_name': 'Changed'},
      where: 'patient_id=?',
      whereArgs: ['p'],
    );
    await expectLater(
      repository.archivePractitioner('a', verifyExport: receipt.verifyDatabase),
      throwsStateError,
    );
    expect(await File(receipt.path).exists(), isTrue);
  });
  test('missing folder fails export and publishes no archive', () async {
    await db.insert('patient_document_folders', {
      'patient_id': 'p',
      'root_path': temp.path,
      'folder_name': 'missing',
    });
    await expectLater(exporter.export('a', {'p'}), throwsStateError);
    expect(
      await temp
          .list()
          .where((f) => f.path.endsWith('.zip') || f.path.endsWith('.partial'))
          .length,
      0,
    );
  });
  test('cancellation and foreign patient selection cannot export', () async {
    final cancelled = PractitionerDepartureExportService(
      database: () async => db,
      access: TestDirectoryAccess(null),
    );
    expect(await cancelled.export('a', {'p'}), isNull);
    await expectLater(exporter.export('a', {'other'}), throwsStateError);
  });
}

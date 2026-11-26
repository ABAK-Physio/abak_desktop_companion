import 'package:abak_desktop_companion/features/documents/services/initial_report_document_service.dart';
import 'package:abak_desktop_companion/core/documents/migration_dmp_analysis.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:abak_desktop_companion/features/episodes/report/services/episode_report_docx_export_service.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/core/documents/document_root_migration.dart';
import 'package:abak_desktop_companion/core/documents/document_activity_coordinator.dart';
import 'package:abak_desktop_companion/core/documents/migration_files.dart';
import 'package:abak_desktop_companion/core/database/document_medical_schema.dart';
import 'package:abak_desktop_companion/core/database/document_controls_schema.dart';
import 'package:abak_desktop_companion/core/database/document_versions_schema.dart';
import 'package:abak_desktop_companion/core/database/document_journal_schema.dart';
import 'package:abak_desktop_companion/core/database/document_reconciliation_schema.dart';
import 'package:abak_desktop_companion/features/maintenance/services/backup_directory_access.dart';
import 'package:abak_desktop_companion/features/maintenance/services/companion_backup_archive.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';
import 'package:abak_desktop_companion/features/cps/cps_operation_lease.dart';

class Access extends BackupDirectoryAccess {
  int active = 0;
  String? denied;
  bool releaseFailure = false;
  @override
  Future<BackupDirectoryLease> acquire(String path) async {
    if (path == denied) throw const FileSystemException('synthetic denied');
    active++;
    return BackupDirectoryLease(path, () async {
      active--;
      if (releaseFailure) throw StateError('synthetic release failure');
    });
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory temp, source, target, support;
  late Database db;
  late Access access;
  late DocumentActivityCoordinator gate;
  DocumentRootMigration service({
    Future<void> Function(String)? hook,
    int? space = 1000000,
    void Function(String, int, int)? progress,
  }) => DocumentRootMigration(
    database: db,
    support: support,
    access: access,
    coordinator: gate,
    availableBytes: (_) async => space,
    checkpoint: hook,
    progress: progress,
  );
  Future<String> root() async =>
      (await db.query(
            'application_settings',
            where: 'setting_key=?',
            whereArgs: [migrationRootKey],
          )).single['setting_value']
          as String;
  Future<void> file(String rel, [String content = 'synthetic']) async {
    final f = File(p.join(source.path, rel));
    await f.parent.create(recursive: true);
    await f.writeAsString(content);
  }

  Future<void> patient(String id, String folder) async {
    await db.insert('patients', {'patient_id': id});
    await db.insert('patient_document_folders', {
      'patient_id': id,
      'root_path': source.path,
      'folder_name': folder,
    });
    await Directory(p.join(source.path, folder)).create();
  }

  Future<void> approve({
    String id = '1',
    String episode = 'e',
    bool controls = true,
  }) async {
    final versionRoot = Directory(
      p.join(support.path, 'episode_document_versions', 'v$id'),
    );
    await versionRoot.create(recursive: true);
    final pdf = File(p.join(versionRoot.path, 'document.pdf'));
    await pdf.writeAsString('%PDF synthetic $id');
    await db.insert('episode_documents', {
      'document_id': 'd$id',
      'file_path': pdf.path,
    });
    await db.insert('episode_document_versions', {
      'version_id': 'v$id',
      'document_id': 'd$id',
      'patient_id': 'p',
      'episode_id': episode,
      'sequence_number': 1,
      'relative_path': 'v$id/document.pdf',
      'sha256': await CompanionBackupArchive.digest(pdf),
      'byte_size': await pdf.length(),
      'mime_type': 'application/pdf',
      'page_count': 1,
      'source_kind': 'report',
      'source_id': 'report',
      'source_revision': 'unchanged',
      'captured_at': 1,
    });
    final snapshot = {
      'episode': {
        'initial_report_docx_path': p.join(source.path, 'PAT/Bilan/a.docx'),
      },
      'document': {'file_path': pdf.path},
    };
    await db.insert('document_medical_approvals', {
      'approval_id': 'a$id',
      'version_id': 'v$id',
      'document_id': 'd$id',
      'patient_id': 'p',
      'episode_id': episode,
      'author_id': 'author',
      'validator_id': 'author',
      'context_id': 'context',
      'source_kind': 'report',
      'source_id': 'report',
      'snapshot_json': medicalCanonical(snapshot),
      'snapshot_hash': medicalHash(snapshot),
      'attestations_json': '{}',
      'approved_at': 1,
    });
    if (controls) {
      final dir = '00000000-0000-4000-8000-${id.padLeft(12, '0')}';
      final folder = await Directory(
        p.join(support.path, 'episode_document_versions', 'controls', dir),
      ).create(recursive: true);
      final hashes = <String, String>{};
      for (final name in [
        'document.pdf',
        'context.json',
        'configuration.json',
        'document.xml',
      ]) {
        final f = File(p.join(folder.path, name));
        await f.writeAsString('synthetic $name');
        hashes[name] = await CompanionBackupArchive.digest(f);
      }
      await db.insert('document_control_runs', {
        'run_id': 'r$id',
        'version_id': 'v$id',
        'approval_id': 'a$id',
        'snapshot_hash': medicalHash(snapshot),
        'configuration_hash': 'config',
        'configuration_revision': 1,
        'directory': dir,
        'started_at': 1,
      });
      await db.insert('document_control_results', {
        'run_id': 'r$id',
        'data_json': jsonEncode({'files': hashes}),
        'completed_at': 1,
      });
    }
  }

  Future<void> episode() async {
    await patient('p', 'PAT');
    await file('PAT/Bilan/a.docx');
    await db.insert('care_episodes', {
      'care_episode_id': 'e',
      'initial_report_docx_path': p.join(source.path, 'PAT/Bilan/a.docx'),
      'updated_at': 123,
    });
  }

  Future<void> execute(
    DocumentRootMigration s,
    DocumentMigrationPlan plan, {
    bool consent = true,
  }) => s.execute(
    plan,
    MigrationConsent(
      planHash: plan.hash,
      invalidations: consent,
      unknownSpace: true,
    ),
  );
  setUp(() async {
    final created = await Directory.systemTemp.createTemp('abak_m2_synthetic_');
    temp = Directory(await created.resolveSymbolicLinks());
    source = await Directory(p.join(temp.path, 'source')).create();
    target = await Directory(p.join(temp.path, 'target')).create();
    support = await Directory(p.join(temp.path, 'support')).create();
    access = Access();
    gate = DocumentActivityCoordinator();
    db = await databaseFactoryFfi.openDatabase(
      p.join(temp.path, 'synthetic.sqlite'),
      options: OpenDatabaseOptions(singleInstance: false),
    );
    for (final sql in [
      'CREATE TABLE application_settings(setting_key TEXT PRIMARY KEY,setting_value TEXT NOT NULL,updated_at INTEGER NOT NULL)',
      'CREATE TABLE patient_document_folders(patient_id TEXT,root_path TEXT,folder_name TEXT,PRIMARY KEY(patient_id,root_path),UNIQUE(root_path,folder_name COLLATE NOCASE))',
      'CREATE TABLE patients(patient_id TEXT PRIMARY KEY)',
      'CREATE TABLE care_episodes(care_episode_id TEXT PRIMARY KEY,initial_report_docx_path TEXT,updated_at INTEGER)',
      'CREATE TABLE episode_documents(document_id TEXT PRIMARY KEY,file_path TEXT)',
      'CREATE TABLE care_episode_reports(report_id TEXT PRIMARY KEY,docx_file_name TEXT)',
      'CREATE TABLE care_episode_assessments(assessment_id TEXT PRIMARY KEY,docx_file_name TEXT)',
      'CREATE TABLE patient_fr_health_identity(patient_id TEXT PRIMARY KEY)',
      'CREATE TABLE practitioners(practitioner_id TEXT PRIMARY KEY)',
    ]) {
      await db.execute(sql);
    }
    await createDocumentVersionsTable(db);
    await createDocumentMedicalTables(db);
    await createDocumentControlsTables(db);
    await createDocumentJournalTables(db);
    await createDocumentReconciliationTables(db);
    await db.insert('application_settings', {
      'setting_key': migrationRootKey,
      'setting_value': source.path,
      'updated_at': 1,
    });
  });
  tearDown(() async {
    expect(access.active, 0);
    await db.close();
    await temp.delete(recursive: true);
  });

  Future<void> attempt(String? outcome) async {
    final v = (await db.query('episode_document_versions')).single;
    final a = (await db.query('document_medical_approvals')).single;
    final run = (await db.query('document_control_runs')).single;
    final xml = File(
      p.join(
        support.path,
        'episode_document_versions',
        'controls',
        run['directory'] as String,
        'document.xml',
      ),
    );
    await db.insert('document_attempts', {
      'attempt_id': 'attempt',
      'document_id': v['document_id'],
      'version_id': v['version_id'],
      'patient_id': v['patient_id'],
      'pdf_hash': v['sha256'],
      'approval_id': a['approval_id'],
      'control_run_id': run['run_id'],
      'snapshot_hash': a['snapshot_hash'],
      'payload_hash': await CompanionBackupArchive.digest(xml),
      'mode': 'simulation',
      'started_at': 1,
    });
    if (outcome != null) {
      final evidence = {'outcome': outcome, 'scope': 'synthetic-offline'};
      await db.insert('document_attempt_results', {
        'attempt_id': 'attempt',
        'outcome': outcome,
        'detail': 'synthetic',
        'evidence_json': jsonEncode(evidence),
        'evidence_hash': medicalHash(evidence),
        'completed_at': 1,
      });
    }
  }

  for (final extra in <String?>[
    null,
    '.DS_Store',
    '.hidden',
    '._document.docx',
  ]) {
    test(
      'M2.3 count excludes directories and root outsiders, includes $extra once',
      () async {
        await patient('p', 'PAT');
        await file('PAT/Bilan/document.docx', 'a' * 6090);
        await file('PAT/Rapport/document.docx', 'b' * 6000);
        await Directory(p.join(source.path, 'PAT/Autre')).create();
        if (extra != null) await file('PAT/$extra', 'x' * 534);
        await file('.DS_Store', 'outside' * 1000);
        final s = service();
        final plan = await s.plan(target.path);
        final files = plan.manifest
            .where((e) => e['directory'] == false)
            .toList();
        expect(plan.associations, hasLength(1));
        expect(plan.data['files'], extra == null ? 2 : 3);
        expect(
          plan.data['directories'],
          4,
        ); // PAT plus three subfolders, including empty Autre.
        expect(plan.data['bytes'], extra == null ? 12090 : 12624);
        expect(plan.data['foreignEntries'], ['.DS_Store']);
        expect(files.length, plan.data['files']);
        expect(files.map((e) => e['path']).toSet().length, files.length);
        expect(
          files.fold<int>(0, (n, e) => n + (e['size'] as int)),
          plan.data['bytes'],
        );
        expect(
          plan.manifest.any(
            (e) => (e['path'] as String).contains('.abak-access-'),
          ),
          isFalse,
        );
        expect(
          await target.list().toList(),
          isEmpty,
        ); // Probe was removed before inventory/copy.
        await execute(s, plan);
        for (final entry in files) {
          final relative = (entry['path'] as String).split('/');
          expect(
            await CompanionBackupArchive.digest(
              File(p.joinAll([target.path, ...relative])),
            ),
            entry['sha256'],
          );
          expect(
            await File(p.joinAll([source.path, ...relative])).exists(),
            isFalse,
          );
        }
        expect(
          await Directory(p.join(target.path, 'PAT/Autre')).exists(),
          isTrue,
        );
        expect(await File(p.join(target.path, '.DS_Store')).exists(), isFalse);
      },
    );
  }
  test(
    'M2.3 foreign count counts immediate root entries, not their descendants',
    () async {
      await patient('p', 'PAT');
      await file('PAT/Bilan/document.docx');
      await file('outside/a.txt');
      await file('outside/deep/b.txt');
      await file('loose.txt');
      final plan = await service().plan(target.path);
      expect(plan.data['foreignEntries'], ['loose.txt', 'outside']);
      expect(plan.data['files'], 1);
      expect(plan.data['bytes'], 'synthetic'.length);
      expect(plan.manifest.where((e) => e['directory'] == false), hasLength(1));
    },
  );
  test(
    'M2.3 progress exposes real stages and completed only after receipt',
    () async {
      await patient('p', 'PAT');
      await file('PAT/one.txt');
      final events = <(String, int, int)>[];
      final s = service(
        progress: (phase, done, total) => events.add((phase, done, total)),
      );
      final plan = await s.plan(target.path);
      await execute(s, plan);
      expect(events.first.$1, 'preflight');
      expect(events.last.$1, 'completed');
      expect(events.where((e) => e.$1 == 'copy').last.$2, plan.manifest.length);
      expect(events.where((e) => e.$1 == 'copy').last.$3, plan.manifest.length);
      expect(
        events.indexWhere((e) => e.$1 == 'verifying'),
        lessThan(events.indexWhere((e) => e.$1 == 'activating')),
      );
      expect(await root(), target.path);
      expect(await s.recoveryDetails(), isEmpty);
    },
  );
  for (final phase in ['copied', 'afterCommit']) {
    test(
      'M2.3 readonly recovery details at $phase preserve journal, SQLite and files',
      () async {
        await patient('p', 'PAT');
        await file('PAT/one.txt');
        final s = service(
          hook: (p) async {
            if (p == phase) throw StateError('synthetic interruption');
          },
        );
        final plan = await s.plan(target.path);
        await expectLater(execute(s, plan), throwsStateError);
        final settings = await db.query('application_settings');
        final files = await s.journal
            .list(recursive: true)
            .where((e) => e is File)
            .cast<File>()
            .toList();
        final contents = {
          for (final f in files) f.path: await f.readAsString(),
        };
        final details = await s.recoveryDetails();
        expect(details, hasLength(1));
        expect(details.single.committed, phase == 'afterCommit');
        expect(
          details.single.requiredRoot,
          phase == 'afterCommit' ? target.path : source.path,
        );
        expect(await db.query('application_settings'), settings);
        for (final f in files) {
          expect(await f.readAsString(), contents[f.path]);
        }
        expect(
          await File(p.join(source.path, 'PAT/one.txt')).readAsString(),
          'synthetic',
        );
        await service().recover();
        expect(await s.recoveryDetails(), isEmpty);
      },
    );
  }
  test(
    'M2.3 diagnostic rejects contradictory receipt before displaying activation',
    () async {
      final s = service(
        hook: (p) async {
          if (p == 'afterCommit') throw StateError('synthetic interruption');
        },
      );
      final plan = await s.plan(target.path);
      await expectLater(execute(s, plan), throwsStateError);
      await db.update(
        'application_settings',
        {'setting_value': '{}'},
        where: 'setting_key=?',
        whereArgs: ['$migrationReceiptPrefix${plan.id}'],
      );
      await expectLater(
        s.recoveryDetails(),
        throwsA(
          isA<MigrationBlocked>().having(
            (e) => e.code,
            'code',
            'receipt_conflict',
          ),
        ),
      );
    },
  );
  test(
    'accepted historical simulation stays accepted after invalidation; no resend or new receipt',
    () async {
      await episode();
      await approve();
      await attempt('accepted');
      final attempts = await db.query('document_attempts'),
          results = await db.query('document_attempt_results');
      final s = service();
      final plan = await s.plan(target.path);
      expect(plan.dmp.data['acceptedDocuments'], isEmpty);
      expect(plan.dmp.data['acceptedSimulationDocuments'], ['d1']);
      expect(plan.dmp.data['remainingDocuments'], ['d1']);
      await execute(s, plan);
      expect(await db.query('document_attempts'), attempts);
      expect(await db.query('document_attempt_results'), results);
      expect(await db.query('document_medical_approvals'), hasLength(1));
    },
  );
  for (final outcome in <String?>[null, 'indeterminate']) {
    test(
      'unfinished/uncertain/retry-dependent attempt $outcome blocks even disabled',
      () async {
        await episode();
        await approve();
        await attempt(outcome);
        await expectLater(
          service().plan(target.path),
          throwsA(isA<MigrationBlocked>()),
        );
        expect(await db.query('document_approval_invalidations'), isEmpty);
        expect(await root(), source.path);
      },
    );
  }
  test(
    'verified DV1 classification preserves acceptance without reopening a send',
    () {
      final summary = MigrationTransmissionSummary();
      summary.recordDv1('document', 'version', 'indeterminate');
      summary.recordDv1('document', 'version', 'accepted');
      expect(summary.acceptedDocuments, {'document'});
      expect(summary.acceptedVersions, {'version'});
      expect(summary.uncertain, isEmpty);
      expect(summary.hasPendingRetry, false);
      summary.recordDv1('document', 'replacement', 'rejected');
      expect(summary.hasPendingRetry, true);
      expect(summary.acceptedDocuments, {'document'});
      summary.recordSimulation('simulated', 'accepted');
      expect(summary.acceptedDocuments, isNot(contains('simulated')));
      expect(summary.acceptedSimulations, {'simulated'});
    },
  );
  test(
    'opaque proof references into source cannot be consented away',
    () async {
      await episode();
      await approve();
      await db.insert('document_preparations', {
        'version_id': 'v1',
        'revision': 1,
        'updated_at': 1,
        'data_json': jsonEncode({
          'unknownProof': p.join(source.path, 'PAT/Bilan/a.docx'),
        }),
      });
      await expectLater(
        service().plan(target.path),
        throwsA(isA<MigrationBlocked>()),
      );
    },
  );
  test(
    'DMP enabled with no dependencies produces general-warning flag, not invalidations',
    () async {
      await db.insert('application_settings', {
        'setting_key': 'dmp_enabled',
        'setting_value': 'true',
        'updated_at': 1,
      });
      final plan = await service().plan(target.path);
      expect(plan.dmp.data['enabled'], true);
      expect(plan.dmp.requiresConsent, false);
    },
  );
  test(
    'stale zone cannot bypass an exclusive lease after its parent finishes',
    () async {
      final trigger = Completer<void>(), done = Completer<void>();
      await gate.activity(() async {
        unawaited(
          trigger.future.then((_) async {
            await expectLater(gate.activity(() async {}), throwsStateError);
            done.complete();
          }),
        );
      });
      await gate.exclusive(() async {
        trigger.complete();
        await done.future;
      });
    },
  );
  test(
    'new and regenerated DOCX files use the committed root after source cleanup',
    () async {
      await episode();
      final s = service();
      await execute(s, await s.plan(target.path));
      final directory = Directory(p.join(await root(), 'PAT/Bilan'));
      const exporter = EpisodeReportDocxExportService();
      final generated = await exporter.exportToDocxFile(
        bytes: Uint8List.fromList([1, 2]),
        directory: directory,
        fileName: 'new',
      );
      final regenerated = await exporter.overwriteDocxFile(
        bytes: Uint8List.fromList([3, 4]),
        directory: directory,
        fileName: 'a.docx',
      );
      expect(generated.path, p.join(target.path, 'PAT/Bilan/new.docx'));
      expect(await regenerated.readAsBytes(), [3, 4]);
      expect(
        await File(p.join(source.path, 'PAT/Bilan/a.docx')).exists(),
        false,
      );
    },
  );
  test(
    'actual exporter and backup entry points honor the shared migration barrier',
    () async {
      await DocumentActivityCoordinator.shared.exclusive(() async {
        await expectLater(
          const EpisodeReportDocxExportService().exportToDocxFile(
            bytes: Uint8List(0),
            directory: target,
            fileName: 'blocked',
          ),
          throwsStateError,
        );
        await expectLater(BackupOperation.run(() async {}), throwsStateError);
        await expectLater(
          const InitialReportDocumentService().open(
            p.join(target.path, 'blocked.docx'),
          ),
          throwsStateError,
        );
      });
      expect(await target.list().isEmpty, true);
    },
  );
  test(
    'exact attachment paths are rebased and report names preserved',
    () async {
      await episode();
      await file('PAT/Autre/manual.pdf');
      await db.insert('episode_documents', {
        'document_id': 'attachment',
        'file_path': p.join(source.path, 'PAT/Autre/manual.pdf'),
      });
      final s = service();
      await execute(s, await s.plan(target.path));
      expect(
        (await db.query('episode_documents')).single['file_path'],
        p.join(target.path, 'PAT/Autre/manual.pdf'),
      );
    },
  );
  test('historical empty roots stay associated and are reported', () async {
    final old = await Directory(p.join(temp.path, 'old')).create();
    await Directory(p.join(old.path, 'OLD')).create();
    await db.insert('patient_document_folders', {
      'patient_id': 'old',
      'root_path': old.path,
      'folder_name': 'OLD',
    });
    final s = service();
    final plan = await s.plan(target.path);
    expect(plan.data['historicalEmptyRoots'], [old.path]);
    await execute(s, plan);
    expect(
      (await db.query('patient_document_folders')).single['root_path'],
      old.path,
    );
  });
  test(
    'preflight is read-only for all DMP tables, even already invalidated records',
    () async {
      await episode();
      await approve();
      Future<String> capture() async {
        final data = <String, Object?>{};
        for (final row in await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
        )) {
          final name = row['name'] as String;
          data[name] = await db.query(name);
        }
        return medicalCanonical(data);
      }

      final before = await capture();
      await service().plan(target.path);
      expect(await capture(), before);
      expect(await target.list().isEmpty, true);
    },
  );
  test('Windows Unicode long and UNC names retain an extended prefix', () {
    expect(
      MigrationFiles.windowsExtendedPath(r'C:\é\documents'),
      r'\\?\C:\é\documents',
    );
    expect(
      MigrationFiles.windowsExtendedPath(r'\\server\share\é'),
      r'\\?\UNC\server\share\é',
    );
    expect(MigrationFiles.windowsExtendedPath(r'\\?\C:\long'), r'\\?\C:\long');
  });
  test(
    'macOS selection persists scopes without activating the destination',
    () async {
      if (!Platform.isMacOS) return;
      SharedPreferences.setMockInitialValues({});
      const channel = MethodChannel('abak/directory_access');
      final calls = <MethodCall>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            if (call.method == 'releaseDirectory') return null;
            final args = Map<String, dynamic>.from(call.arguments as Map);
            final path = args['expectedPath'] as String? ?? target.path;
            return {
              'path': path,
              'bookmark': 'synthetic-bookmark',
              'token': 'synthetic-token',
            };
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      final s = DocumentRootMigration(
        database: db,
        support: support,
        coordinator: gate,
      );
      await s.authorizeRoot(source.path, 'Localized title supplied by M2.3');
      final lease = await s.chooseDestination(
        'Localized title supplied by M2.3',
      );
      expect(lease!.path, target.path);
      await lease.release();
      expect(await root(), source.path);
      final args = Map<String, dynamic>.from(calls.first.arguments as Map);
      expect(args['expectedPath'], source.path);
      expect(args['readOnly'], false);
      expect(args['createDocumentsChild'], isNull);
      expect(calls.where((c) => c.method == 'releaseDirectory'), hasLength(2));
      final prefs = await SharedPreferences.getInstance();
      expect(
        prefs.getKeys().where((k) => k.startsWith('macos_directory_bookmark')),
        hasLength(2),
      );
    },
  );
  test(
    'release failures after commit do not hide success or leak remaining releases',
    () async {
      final s = service(
        hook: (at) async {
          if (at == 'afterCommit') access.releaseFailure = true;
        },
      );
      final plan = await s.plan(target.path);
      await execute(s, plan);
      expect(await root(), target.path);
      expect(access.active, 0);
      expect(s.diagnostics, contains('authorization_release_failed'));
    },
  );
  for (final phase in [
    'beforeCommit',
    'afterCommit',
    'deleted:PAT/Bilan/a.docx',
  ]) {
    test('new OS process exits at $phase and next instance recovers', () async {
      await episode();
      await approve();
      await File(
        p.join(temp.path, 'migration-test-scope'),
      ).writeAsString('ABAK-M2-SYNTHETIC');
      await db.close();
      final configFile = File('.dart_tool/package_config.json').absolute;
      final config = jsonDecode(await configFile.readAsString()) as Map;
      final flutter = (config['packages'] as List).cast<Map>().singleWhere(
        (e) => e['name'] == 'flutter',
      );
      final packageRoot = Directory.fromUri(
        configFile.uri.resolve(flutter['rootUri'] as String),
      );
      final sdk = packageRoot.parent.parent;
      final result = await Process.run(
        p.join(sdk.path, 'bin', Platform.isWindows ? 'flutter.bat' : 'flutter'),
        [
          'test',
          '--no-pub',
          'test/support/migration_crash_worker.dart',
          '--reporter',
          'expanded',
        ],
        environment: {
          'ABAK_M2_SYNTHETIC_ROOT': temp.path,
          'ABAK_M2_CRASH_PHASE': phase,
        },
      );
      // Reopen even if the assertion below fails, to keep teardown well-defined.
      db = await databaseFactoryFfi.openDatabase(
        p.join(temp.path, 'synthetic.sqlite'),
        options: OpenDatabaseOptions(singleInstance: false),
      );
      expect(result.exitCode, isNot(0));
      expect(
        await service().journal.exists(),
        true,
        reason: '${result.stdout}\n${result.stderr}',
      );
      gate = DocumentActivityCoordinator();
      final recovered = await service().recover();
      expect(
        recovered.single.state,
        phase != 'beforeCommit' ? 'committed' : 'sourceRetained',
      );
      expect(await root(), phase != 'beforeCommit' ? target.path : source.path);
      expect(
        await db.query('document_approval_invalidations'),
        hasLength(phase != 'beforeCommit' ? 1 : 0),
      );
    }, timeout: const Timeout(Duration(minutes: 2)));
  }
  test(
    'M2.4 recovery honours legacy consent that retained source files',
    () async {
      await episode();
      final s = service(
        hook: (at) async {
          if (at == 'afterCommit') {
            throw StateError('interrupted legacy migration');
          }
        },
      );
      final plan = await s.plan(target.path);
      await expectLater(execute(s, plan), throwsStateError);
      final legacyData = plan.data..remove('deleteTransferredSources');
      final legacy = DocumentMigrationPlan(legacyData);
      final records = await Directory(
        p.join(s.journal.path, plan.id),
      ).list().toList();
      for (final record in records) {
        final envelope =
            jsonDecode(await File(record.path).readAsString()) as Map;
        final payload = envelope['payload'] as Map;
        payload['plan'] = legacy.data;
        payload['planHash'] = legacy.hash;
        envelope['hash'] = medicalHash(payload);
        await File(
          record.path,
        ).writeAsString(jsonEncode(envelope), flush: true);
      }
      await db.update(
        'application_settings',
        {
          'setting_value': medicalCanonical({
            'id': legacy.id,
            'hash': legacy.hash,
            'destination': legacy.destination,
          }),
        },
        where: 'setting_key=?',
        whereArgs: ['$migrationReceiptPrefix${legacy.id}'],
      );
      final result = await service().recover();
      expect(result.single.sourcesRetained, true);
      expect(await root(), target.path);
      expect(
        await File(p.join(source.path, 'PAT/Bilan/a.docx')).readAsString(),
        'synthetic',
      );
    },
  );
  test(
    'M2.4 removes transferred technical files and empty source root',
    () async {
      await episode();
      await file('PAT/.DS_Store');
      final s = service();
      final plan = await s.plan(target.path);
      expect(
        await s.execute(plan, MigrationConsent(planHash: plan.hash)),
        false,
      );
      expect(await source.exists(), false);
      expect(await File(p.join(target.path, 'PAT/.DS_Store')).exists(), true);
      expect((await s.recover()).single.sourcesRetained, false);
    },
  );
  for (final scenario in [
    'sourceChanged',
    'copyChanged',
    'copyMissing',
    'deleteError',
    'historical',
    'liveReference',
    'sourceAlias',
  ]) {
    test('M2.4 retains unsafe source after commit: $scenario', () async {
      await episode();
      final s = service(
        hook: (at) async {
          if (at == 'afterCommit') {
            switch (scenario) {
              case 'sourceChanged':
                await file('PAT/Bilan/a.docx', 'modified');
              case 'copyChanged':
                await File(
                  p.join(target.path, 'PAT/Bilan/a.docx'),
                ).writeAsString('modified');
              case 'copyMissing':
                await File(p.join(target.path, 'PAT/Bilan/a.docx')).delete();
              case 'historical':
                await approve();
                final pdf = File(
                  p.join(
                    support.path,
                    'episode_document_versions/v1/document.pdf',
                  ),
                );
                await pdf.writeAsString('damaged evidence');
              case 'liveReference':
                await db.insert('episode_documents', {
                  'document_id': 'late',
                  'file_path': p.join(source.path, 'PAT/Bilan/a.docx'),
                });
              case 'sourceAlias':
                await Directory(
                  p.join(source.path, 'PAT'),
                ).rename(p.join(temp.path, 'kept'));
                await Link(
                  p.join(source.path, 'PAT'),
                ).create(p.join(temp.path, 'kept'));
            }
          }
          if (scenario == 'deleteError' && at == 'deleting:PAT/Bilan/a.docx') {
            throw const FileSystemException('synthetic deletion denied');
          }
        },
      );
      final plan = await s.plan(target.path);
      expect(
        await s.execute(plan, MigrationConsent(planHash: plan.hash)),
        true,
      );
      expect(await root(), target.path);
      expect(
        await File(p.join(source.path, 'PAT/Bilan/a.docx')).exists(),
        true,
      );
      expect(gate.recoveryRequired, false);
      expect((await service().recover()).single.sourcesRetained, true);
    });
  }
  test(
    'M2.4 resumes a partial cleanup and conserves newly modified files',
    () async {
      await episode();
      await file('PAT/Bilan/b.docx');
      final s = service(
        hook: (at) async {
          if (at == 'deleted:PAT/Bilan/a.docx') {
            throw StateError('synthetic interruption');
          }
        },
      );
      final plan = await s.plan(target.path);
      await expectLater(execute(s, plan), throwsStateError);
      expect(
        await File(p.join(source.path, 'PAT/Bilan/a.docx')).exists(),
        false,
      );
      expect(await root(), target.path);
      await file('PAT/Bilan/b.docx', 'new content');
      gate = DocumentActivityCoordinator();
      expect((await service().recover()).single.sourcesRetained, true);
      expect(
        await File(p.join(source.path, 'PAT/Bilan/b.docx')).readAsString(),
        'new content',
      );
    },
  );
  test('M2.4 resumes cleanup idempotently after a deleted subfolder', () async {
    await episode();
    final s = service(
      hook: (at) async {
        if (at == 'deleted:PAT/Bilan/a.docx') {
          throw StateError('synthetic interruption');
        }
      },
    );
    final plan = await s.plan(target.path);
    await expectLater(execute(s, plan), throwsStateError);
    await Directory(p.join(source.path, 'PAT/Bilan')).delete();
    gate = DocumentActivityCoordinator();
    expect((await service().recover()).single.sourcesRetained, false);
    expect(await source.exists(), false);
    expect((await service().recover()).single.sourcesRetained, false);
  });
  test('M2.4 keeps foreign root folders and files added after copy', () async {
    await episode();
    await file('foreign/keep.txt');
    final s = service(
      hook: (at) async {
        if (at == 'afterCommit') await file('PAT/Bilan/new.txt');
      },
    );
    final plan = await s.plan(target.path);
    await execute(s, plan);
    expect(await File(p.join(source.path, 'foreign/keep.txt')).exists(), true);
    expect(await File(p.join(source.path, 'PAT/Bilan/new.txt')).exists(), true);
    expect(await File(p.join(source.path, 'PAT/Bilan/a.docx')).exists(), false);
  });
  test('M2.4 never deletes sources after a rolled-back transaction', () async {
    await episode();
    final s = service(
      hook: (at) async {
        if (at == 'transaction') throw StateError('rollback');
      },
    );
    final plan = await s.plan(target.path);
    await expectLater(execute(s, plan), throwsStateError);
    await service().recover();
    expect(await root(), source.path);
    expect(
      await File(p.join(source.path, 'PAT/Bilan/a.docx')).readAsString(),
      'synthetic',
    );
  });
  test('empty root activates target and recovery is idempotent', () async {
    final s = service();
    final plan = await s.plan(target.path);
    await execute(s, plan);
    expect(await root(), target.path);
    expect(await source.exists(), false);
    expect((await s.recover()).single.state, 'completed');
    await s.recover();
  });
  test(
    'whole trees, homonyms, no birth, hidden manual and empty entries; foreign root stays',
    () async {
      for (final name in [
        'DUPONT_ELISE_1980',
        'DUPONT_ELISE_1980_2',
        'INCONNU_SANS_DATE',
      ]) {
        await patient(name, name);
        await file('$name/Bilan/a.docx');
        await file('$name/Rapport/é.docx');
        await file('$name/Autre/.manual.pdf');
        await file('$name/Autre/empty', '');
        await Directory(p.join(source.path, name, 'emptyDir')).create();
      }
      await file('foreign.txt');
      final s = service();
      final plan = await s.plan(target.path);
      expect(plan.data['files'], 12);
      expect(plan.data['foreignEntries'], ['foreign.txt']);
      await execute(s, plan);
      expect(await File(p.join(target.path, 'foreign.txt')).exists(), false);
      expect(
        await MigrationFiles.inventory(target.path, plan.folders),
        plan.manifest,
      );
      expect(
        await File(p.join(source.path, 'foreign.txt')).readAsString(),
        'synthetic',
      );
      for (final folder in plan.folders) {
        expect(await Directory(p.join(source.path, folder)).exists(), false);
      }
      expect(
        (await db.query(
          'patient_document_folders',
        )).map((r) => r['folder_name']).toSet(),
        plan.folders.toSet(),
      );
    },
  );
  test(
    'path changes invalidate all episode approvals with DMP disabled; proofs unchanged',
    () async {
      await episode();
      await approve();
      await approve(id: '2');
      final before = await db.query('document_medical_approvals');
      final versions = await db.query('episode_document_versions');
      final s = service();
      final plan = await s.plan(target.path);
      expect(plan.dmp.data['enabled'], false);
      expect(plan.dmp.approvalIds, ['a1', 'a2']);
      expect(plan.dmp.data['controls'], ['r1', 'r2']);
      expect(await db.query('document_approval_invalidations'), isEmpty);
      await expectLater(
        execute(s, plan, consent: false),
        throwsA(isA<MigrationBlocked>()),
      );
      await execute(s, plan);
      expect(await db.query('document_medical_approvals'), before);
      expect(await db.query('episode_document_versions'), versions);
      expect(await db.query('document_approval_invalidations'), hasLength(2));
      expect(await db.query('document_control_invalidations'), hasLength(2));
      expect((await db.query('care_episodes')).single['updated_at'], 123);
      expect(
        (await db.query('care_episodes')).single['initial_report_docx_path'],
        p.join(target.path, 'PAT/Bilan/a.docx'),
      );
    },
  );
  test('already invalidated approvals not counted again', () async {
    await episode();
    await approve();
    await db.insert('document_approval_invalidations', {
      'approval_id': 'a1',
      'reason': 'prior',
      'invalidated_at': 1,
    });
    final s = service();
    final plan = await s.plan(target.path);
    expect(plan.dmp.approvalIds, isEmpty);
    expect(plan.dmp.data['controls'], isEmpty);
    await execute(s, plan);
    expect(
      (await db.query('document_approval_invalidations')).single['reason'],
      'prior',
    );
  });
  test(
    'relative DOCX names unchanged and unrelated episodes receive no UPDATE',
    () async {
      await patient('p', 'PAT');
      await file('PAT/Rapport/a.docx');
      await db.insert('care_episode_reports', {
        'report_id': 'r',
        'docx_file_name': 'a.docx',
      });
      await db.insert('care_episodes', {
        'care_episode_id': 'unrelated',
        'updated_at': 123,
      });
      final before = await db.query('document_medical_changes');
      final s = service();
      await execute(s, await s.plan(target.path));
      expect(await db.query('document_medical_changes'), before);
      expect(
        (await db.query('care_episode_reports')).single['docx_file_name'],
        'a.docx',
      );
    },
  );
  for (final stage in [
    'prepared',
    'copy:1',
    'copied',
    'installed:PAT',
    'beforeCommit',
    'transaction',
    'afterCommit',
  ]) {
    test(
      'interruption $stage: durable recovery, preserved sources and atomic invalidations',
      () async {
        await episode();
        await approve();
        final s = service(
          hook: (at) async {
            if (at == stage) throw StateError('synthetic crash');
          },
        );
        final plan = await s.plan(target.path);
        await expectLater(execute(s, plan), throwsStateError);
        expect(gate.recoveryRequired, true);
        final committed = stage == 'afterCommit';
        expect(await root(), committed ? target.path : source.path);
        expect(
          await db.query('document_approval_invalidations'),
          hasLength(committed ? 1 : 0),
        );
        expect(
          await File(p.join(source.path, 'PAT/Bilan/a.docx')).readAsString(),
          'synthetic',
        );
        await db.close();
        db = await databaseFactoryFfi.openDatabase(
          p.join(temp.path, 'synthetic.sqlite'),
          options: OpenDatabaseOptions(singleInstance: false),
        );
        gate = DocumentActivityCoordinator();
        final recovered = await service().recover();
        expect(
          recovered.single.state,
          committed ? 'committed' : 'sourceRetained',
        );
        expect(gate.recoveryRequired, false);
        await service().recover();
      },
    );
  }
  test('cancel before copying has no root change', () async {
    final s = service();
    final plan = await s.plan(target.path);
    final token = MigrationCancellation()..cancelled = true;
    await expectLater(
      s.execute(
        plan,
        MigrationConsent(planHash: plan.hash),
        cancellation: token,
      ),
      throwsA(isA<MigrationBlocked>()),
    );
    expect(await root(), source.path);
  });
  test('mutation during copy is detected', () async {
    await episode();
    final s = service(
      hook: (at) async {
        if (at == 'copied') await file('PAT/Bilan/a.docx', 'changed');
      },
    );
    final plan = await s.plan(target.path);
    await expectLater(execute(s, plan), throwsA(isA<MigrationBlocked>()));
    expect(await root(), source.path);
  });
  test('corrupted destination copy is detected', () async {
    await episode();
    final s = service(
      hook: (at) async {
        if (at == 'copied') {
          final stage = (await target.list().toList()).single;
          await File(
            p.join(stage.path, 'PAT/Bilan/a.docx'),
          ).writeAsString('corrupt');
        }
      },
    );
    final plan = await s.plan(target.path);
    await expectLater(execute(s, plan), throwsA(isA<MigrationBlocked>()));
    expect(await root(), source.path);
  });
  test('source changed after consent requires a new plan', () async {
    await episode();
    final s = service();
    final plan = await s.plan(target.path);
    await file('PAT/new.txt');
    await expectLater(execute(s, plan), throwsA(isA<MigrationBlocked>()));
    expect(await root(), source.path);
  });
  test('DB changed after consent requires new plan', () async {
    final s = service();
    final plan = await s.plan(target.path);
    await db.insert('patients', {'patient_id': 'new'});
    await expectLater(execute(s, plan), throwsA(isA<MigrationBlocked>()));
  });
  test(
    'destination conflict appearing during copy is never overwritten',
    () async {
      await episode();
      final s = service(
        hook: (at) async {
          if (at == 'copied') {
            await Directory(p.join(target.path, 'PAT')).create();
            await File(
              p.join(target.path, 'PAT/foreign'),
            ).writeAsString('keep');
          }
        },
      );
      final plan = await s.plan(target.path);
      await expectLater(execute(s, plan), throwsA(anything));
      expect(
        await File(p.join(target.path, 'PAT/foreign')).readAsString(),
        'keep',
      );
      expect(await root(), source.path);
    },
  );
  test('same and nested roots rejected', () async {
    await expectLater(
      service().plan(source.path),
      throwsA(isA<MigrationBlocked>()),
    );
    final child = await Directory(p.join(source.path, 'child')).create();
    await expectLater(
      service().plan(child.path),
      throwsA(isA<MigrationBlocked>()),
    );
    await expectLater(
      service().plan(temp.path),
      throwsA(isA<MigrationBlocked>()),
    );
  });
  test('hidden destination file is not empty', () async {
    await File(p.join(target.path, '.hidden')).writeAsString('keep');
    await expectLater(
      service().plan(target.path),
      throwsA(isA<MigrationBlocked>()),
    );
  });
  test('insufficient and unknown space are distinct', () async {
    await episode();
    await expectLater(
      service(space: 0).plan(target.path),
      throwsA(isA<MigrationBlocked>()),
    );
    final s = service(space: null);
    final plan = await s.plan(target.path);
    await expectLater(
      s.execute(plan, MigrationConsent(planHash: plan.hash)),
      throwsA(isA<MigrationBlocked>()),
    );
    await execute(s, plan);
  });
  test('denied source and target release acquired leases', () async {
    access.denied = source.path;
    await expectLater(service().plan(target.path), throwsA(anything));
    access.denied = target.path;
    await expectLater(service().plan(target.path), throwsA(anything));
  });
  test('symlink in patient tree rejected', () async {
    await patient('p', 'PAT');
    await Link(p.join(source.path, 'PAT/link')).create(support.path);
    await expectLater(service().plan(target.path), throwsA(anything));
  });
  test('case collisions blocked before copy', () async {
    await patient('p', 'PAT');
    await db.insert('patient_document_folders', {
      'patient_id': 'p2',
      'root_path': source.path,
      'folder_name': 'other',
    });
    await Directory(p.join(source.path, 'other')).create();
    await file('PAT/A');
    await file('PAT/a');
    if ((await Directory(p.join(source.path, 'PAT')).list().toList()).length ==
        2) {
      await expectLater(service().plan(target.path), throwsA(anything));
    } else {
      expect(await File(p.join(source.path, 'PAT/A')).exists(), true);
    }
  });
  test('historical nonempty and inaccessible roots block', () async {
    final old = await Directory(p.join(temp.path, 'old')).create();
    await Directory(p.join(old.path, 'PAT')).create();
    await File(p.join(old.path, 'PAT/a')).writeAsString('old');
    await db.insert('patient_document_folders', {
      'patient_id': 'p',
      'root_path': old.path,
      'folder_name': 'PAT',
    });
    await expectLater(
      service().plan(target.path),
      throwsA(isA<MigrationBlocked>()),
    );
    access.denied = old.path;
    await expectLater(service().plan(target.path), throwsA(anything));
  });
  test('clinical absolute path is blocked without modifying its row', () async {
    await episode();
    await db.insert('care_episode_reports', {
      'report_id': 'r',
      'docx_file_name': p.join(source.path, 'PAT/Bilan/a.docx'),
    });
    await expectLater(
      service().plan(target.path),
      throwsA(isA<MigrationBlocked>()),
    );
  });
  test('unclassified dependency and protected storage overlap block', () async {
    await expectLater(
      service().plan(support.path),
      throwsA(isA<MigrationBlocked>()),
    );
    await db.insert('application_settings', {
      'setting_key': 'cabinet_logo_path',
      'setting_value': p.join(source.path, 'logo.png'),
      'updated_at': 1,
    });
    await expectLater(
      service().plan(target.path),
      throwsA(isA<MigrationBlocked>()),
    );
  });
  test(
    'missing or altered private evidence blocks even DMP disabled',
    () async {
      await episode();
      await approve();
      final f = File(
        p.join(support.path, 'episode_document_versions/v1/document.pdf'),
      );
      await f.writeAsString('bad');
      await expectLater(
        service().plan(target.path),
        throwsA(isA<MigrationBlocked>()),
      );
      await f.delete();
      await expectLater(
        service().plan(target.path),
        throwsA(isA<MigrationBlocked>()),
      );
    },
  );
  test('corrupt and missing journal fail closed after commit', () async {
    final s = service();
    final plan = await s.plan(target.path);
    await execute(s, plan);
    final dir = Directory(p.join(s.journal.path, plan.id));
    final f = (await dir.list().toList()).first;
    await File(f.path).writeAsString('broken');
    await expectLater(s.recover(), throwsA(anything));
    expect(gate.recoveryRequired, true);
    await dir.delete(recursive: true);
    await expectLater(s.recover(), throwsA(isA<MigrationBlocked>()));
  });
  test('lost destination after commit never activates source', () async {
    await episode();
    final s = service(
      hook: (at) async {
        if (at == 'afterCommit') throw StateError('crash');
      },
    );
    final plan = await s.plan(target.path);
    await expectLater(execute(s, plan), throwsStateError);
    await target.rename('${target.path}-offline');
    expect((await service().recover()).single.sourcesRetained, true);
    expect(await File(p.join(source.path, 'PAT/Bilan/a.docx')).exists(), true);
    expect(await root(), target.path);
  });
  test(
    'exclusive gate refuses active work, nested work succeeds and new work is blocked',
    () async {
      final entered = Completer<void>(), release = Completer<void>();
      final task = gate.activity(() async {
        await gate.activity(() async {});
        entered.complete();
        await release.future;
      });
      await entered.future;
      await expectLater(service().plan(target.path), throwsStateError);
      release.complete();
      await task;
      await gate.exclusive(() async {
        await expectLater(gate.activity(() async {}), throwsStateError);
        await expectLater(service().plan(target.path), throwsStateError);
      });
    },
  );
  test('active CPS operation blocks migration', () async {
    final lease = CpsOperationLease.acquire();
    try {
      await expectLater(
        service().plan(target.path),
        throwsA(isA<MigrationBlocked>()),
      );
    } finally {
      lease.release();
    }
  });
  test('native space inspection and no-replace installation', () async {
    expect(await MigrationFiles.availableBytes(temp.path), isPositive);
    final a = await Directory(p.join(temp.path, 'a')).create();
    final b = await Directory(p.join(temp.path, 'b')).create();
    await expectLater(
      MigrationFiles.install(a.path, b.path),
      throwsA(isA<FileSystemException>()),
    );
    expect(await a.exists(), true);
    expect(await b.exists(), true);
  });
}

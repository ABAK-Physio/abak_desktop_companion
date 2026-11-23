import 'dart:io';

import 'package:abak_desktop_companion/core/database/companion_access_schema.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/features/practitioners/data/practitioner_repository.dart';
import 'package:abak_desktop_companion/features/practitioners/models/practitioner.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory temporary;
  late String path;
  Database? connection;

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('companion_access_');
    path = '${temporary.path}/synthetic.db';
  });
  tearDown(() async {
    if (connection?.isOpen ?? false) await connection!.close();
    connection = null;
    await temporary.delete(recursive: true);
  });

  // Independent, minimal v50 fixture. The existing legacy migration tests
  // cover the full old schemas and preservation of clinical and DMP records.
  Future<void> legacy({bool practitioner = true, bool patient = true}) async {
    connection = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 50,
        onCreate: (db, _) async {
          await db.execute('''CREATE TABLE practitioners (
            practitioner_id TEXT PRIMARY KEY, display_name TEXT NOT NULL,
            created_at INTEGER NOT NULL, archived_at INTEGER)''');
          await db.execute('''CREATE TABLE patients (
            patient_id TEXT PRIMARY KEY, first_name TEXT NOT NULL,
            created_at INTEGER NOT NULL, archived_at INTEGER)''');
          // v55 additionally reads report dates and installs content triggers.
          await db.execute('''CREATE TABLE care_episode_reports (
            report_id TEXT PRIMARY KEY, title TEXT NOT NULL,
            content_json TEXT NOT NULL, created_at INTEGER NOT NULL,
            updated_at INTEGER, report_date INTEGER NOT NULL)''');
          if (practitioner) {
            // Deliberately insert the newer practitioner first.
            await db.insert('practitioners', {
              'practitioner_id': 'newer',
              'display_name': 'A',
              'created_at': 20,
            });
            await db.insert('practitioners', {
              'practitioner_id': 'first',
              'display_name': 'Z',
              'created_at': 10,
            });
          }
          if (patient) {
            for (final archived in [false, true]) {
              await db.insert('patients', {
                'patient_id': archived ? 'archived' : 'active',
                'first_name': 'Synthetique',
                'created_at': 30,
                'archived_at': archived ? 40 : null,
              });
            }
          }
        },
      ),
    );
  }

  Future<Database> upgrade() async {
    await connection?.close();
    final db = await DatabaseService.openDatabaseFile(
      path,
      factory: databaseFactoryFfi,
    );
    connection = db;
    return db;
  }

  test('first practitioner completes pending legacy assignments', () async {
    final db = await upgrade();
    await db.insert('patients', {
      'patient_id': 'pending',
      'last_name': 'Test',
      'first_name': 'Patient',
      'created_at': 1,
    });
    await db.insert('companion_patient_access', {'patient_id': 'pending'});
    await db.update('companion_access_initialization', {
      'assignments_pending': 1,
    });
    final repository = PractitionerRepository(database: () async => db);
    await repository.insertPractitioner(
      const Practitioner(
        practitionerId: 'first',
        displayName: 'Premier',
        isActive: true,
        createdAt: 2,
      ),
    );
    expect(
      (await db.query(
        'companion_patient_access',
      )).single['referring_practitioner_id'],
      'first',
    );
    expect(
      (await db.query(
        'companion_access_initialization',
      )).single['assignments_pending'],
      0,
    );
  });

  test('access metadata does not invalidate existing DMP approvals', () async {
    final db = await upgrade();
    await db.insert('practitioners', {
      'practitioner_id': 'kin',
      'display_name': 'Test',
      'created_at': 1,
    });
    await db.insert('patients', {
      'patient_id': 'patient',
      'last_name': 'Test',
      'first_name': 'Patient',
      'created_at': 1,
    });
    await db.insert('document_medical_approvals', {
      'approval_id': 'approval',
      'version_id': 'version',
      'document_id': 'document',
      'patient_id': 'patient',
      'episode_id': 'episode',
      'author_id': 'kin',
      'validator_id': 'kin',
      'context_id': 'context',
      'source_kind': 'external',
      'snapshot_json': '{}',
      'snapshot_hash': 'synthetic',
      'attestations_json': '{}',
      'approved_at': 2,
    });
    final changes = await db.query('document_medical_changes');
    final approvals = await db.query('document_medical_approvals');
    await db.insert('companion_practitioner_access', {
      'practitioner_id': 'kin',
      'is_administrator': 1,
    });
    await db.insert('companion_patient_access', {
      'patient_id': 'patient',
      'referring_practitioner_id': 'kin',
    });
    await db.update('companion_practitioner_access', {'is_administrator': 0});
    await db.update('companion_patient_access', {
      'referring_practitioner_id': null,
      'former_practitioner_id': 'kin',
      'departure_date': 3,
    });
    expect(await db.query('document_medical_changes'), changes);
    expect(await db.query('document_medical_approvals'), approvals);
    expect(await db.query('document_approval_invalidations'), isEmpty);
  });

  test(
    'fresh database has access storage but grants no administrator',
    () async {
      final db = await upgrade();
      expect(await db.getVersion(), DatabaseService.schemaVersion);
      expect(await db.query('companion_patient_access'), isEmpty);
      expect(await db.query('companion_practitioner_access'), isEmpty);
      expect(
        (await db.query(
          'companion_access_initialization',
        )).single['assignments_pending'],
        0,
      );
      expect(await db.rawQuery('PRAGMA integrity_check'), [
        {'integrity_check': 'ok'},
      ]);
    },
  );

  test(
    'upgrade assigns all existing patients chronologically without editing source rows',
    () async {
      await legacy();
      final beforePatients = await connection!.query('patients');
      final beforePractitioners = await connection!.query('practitioners');
      final db = await upgrade();
      expect(await db.query('patients'), beforePatients);
      expect(await db.query('practitioners'), beforePractitioners);
      final rows = await db.query('companion_patient_access');
      expect(rows, hasLength(2));
      for (final row in rows) {
        expect(row['referring_practitioner_id'], 'first');
        expect(row['former_practitioner_id'], isNull);
        expect(row['departure_date'], isNull);
      }
      expect(await db.query('companion_practitioner_access'), isEmpty);
      expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    },
  );

  test('same creation date uses a stable identifier tie-break', () async {
    await legacy();
    await connection!.update('practitioners', {'created_at': 10});
    final db = await upgrade();
    expect(
      (await db.query(
        'companion_patient_access',
      )).first['referring_practitioner_id'],
      'first',
    );
  });

  test(
    'legacy patients without a practitioner remain pending, then initialize once',
    () async {
      await legacy(practitioner: false);
      final db = await upgrade();
      expect(
        (await db.query(
          'companion_access_initialization',
        )).single['assignments_pending'],
        1,
      );
      expect(
        await db.transaction(completeInitialCompanionAssignments),
        isFalse,
      );
      await db.transaction((txn) async {
        await txn.insert('practitioners', {
          'practitioner_id': 'created',
          'display_name': 'Premier',
          'created_at': 50,
        });
        expect(await completeInitialCompanionAssignments(txn), isTrue);
      });
      expect(
        (await db.query(
          'companion_patient_access',
        )).first['referring_practitioner_id'],
        'created',
      );
      expect(
        (await db.query(
          'companion_access_initialization',
        )).single['assignments_pending'],
        0,
      );
    },
  );

  test(
    'reopening and retrying migration preserve deliberately unassigned patients',
    () async {
      await legacy();
      var db = await upgrade();
      await db.update(
        'companion_patient_access',
        {
          'referring_practitioner_id': null,
          'former_practitioner_id': 'first',
          'departure_date': 100,
        },
        where: 'patient_id = ?',
        whereArgs: ['active'],
      );
      await db.update(
        'companion_patient_access',
        {'referring_practitioner_id': 'newer'},
        where: 'patient_id = ?',
        whereArgs: ['archived'],
      );
      final before = await db.query('companion_patient_access');
      db = await upgrade();
      await db.transaction(migrateCompanionAccess);
      expect(await db.query('companion_patient_access'), before);
    },
  );

  test('empty legacy database has no deferred global assignment', () async {
    await legacy(practitioner: false, patient: false);
    final db = await upgrade();
    expect(
      (await db.query(
        'companion_access_initialization',
      )).single['assignments_pending'],
      0,
    );
  });

  test(
    'metadata enforces references, administrator boolean and departure pair',
    () async {
      await legacy();
      final db = await upgrade();
      await db.execute('PRAGMA foreign_keys = ON');
      await expectLater(
        db.insert('companion_practitioner_access', {
          'practitioner_id': 'missing',
        }),
        throwsA(isA<DatabaseException>()),
      );
      await expectLater(
        db.insert('companion_practitioner_access', {
          'practitioner_id': 'first',
          'is_administrator': 2,
        }),
        throwsA(isA<DatabaseException>()),
      );
      await expectLater(
        db.update('companion_patient_access', {
          'former_practitioner_id': 'first',
        }),
        throwsA(isA<DatabaseException>()),
      );
      await db.insert('companion_practitioner_access', {
        'practitioner_id': 'first',
      });
      expect(
        (await db.query(
          'companion_practitioner_access',
        )).single['is_administrator'],
        0,
      );
      await db.delete(
        'patients',
        where: 'patient_id = ?',
        whereArgs: ['active'],
      );
      expect(await db.query('companion_patient_access'), hasLength(1));
      expect(await db.rawQuery('PRAGMA foreign_key_check'), isEmpty);
    },
  );
}

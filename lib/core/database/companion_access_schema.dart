import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Local access metadata is separate from clinical/CPS source rows: changing
/// an assignment or an administrator flag must not invalidate DMP approvals.
/// No code, recovery key or live session is stored by this schema.
Future<void> createCompanionAccessTables(DatabaseExecutor db) async {
  await db.execute('''CREATE TABLE IF NOT EXISTS companion_practitioner_access (
    practitioner_id TEXT PRIMARY KEY NOT NULL
      REFERENCES practitioners(practitioner_id),
    is_administrator INTEGER NOT NULL DEFAULT 0
      CHECK(is_administrator IN (0, 1))
  )''');
  await db.execute('''CREATE TABLE IF NOT EXISTS companion_patient_access (
    patient_id TEXT PRIMARY KEY NOT NULL REFERENCES patients(patient_id)
      ON DELETE CASCADE,
    referring_practitioner_id TEXT REFERENCES practitioners(practitioner_id),
    former_practitioner_id TEXT REFERENCES practitioners(practitioner_id),
    departure_date INTEGER,
    CHECK ((former_practitioner_id IS NULL AND departure_date IS NULL)
      OR (former_practitioner_id IS NOT NULL AND departure_date IS NOT NULL))
  )''');
  await db.execute(
    '''CREATE INDEX IF NOT EXISTS companion_patient_access_referrer
    ON companion_patient_access(referring_practitioner_id)''',
  );
  await db.execute('''CREATE INDEX IF NOT EXISTS companion_patient_access_former
    ON companion_patient_access(former_practitioner_id)''');
  await db.execute(
    '''CREATE TABLE IF NOT EXISTS companion_access_initialization (
    singleton INTEGER PRIMARY KEY CHECK(singleton = 1),
    assignments_pending INTEGER NOT NULL CHECK(assignments_pending IN (0, 1))
  )''',
  );
}

/// Runs inside the database upgrade transaction. Only existing patients are
/// candidates for the one-off migration; subsequent creations use the UI's
/// explicit choice. Existing document authors are not changed in this stage.
Future<void> migrateCompanionAccess(DatabaseExecutor db) async {
  await createCompanionAccessTables(db);
  final state = await db.query('companion_access_initialization');
  if (state.isNotEmpty) return;
  await db.execute('''INSERT INTO companion_patient_access(patient_id)
    SELECT patient_id FROM patients''');
  await db.insert('companion_access_initialization', {
    'singleton': 1,
    'assignments_pending': 1,
  });
  await completeInitialCompanionAssignments(db);
}

/// Called in a transaction. If legacy patients exist without any practitioner,
/// keep their initialization pending until a practitioner has been created.
/// Once completed, this cannot reassign patients deliberately left unassigned.
Future<bool> completeInitialCompanionAssignments(DatabaseExecutor db) async {
  final state = await db.query('companion_access_initialization');
  if (state.isEmpty || state.single['assignments_pending'] == 0) return true;
  final patients = await db.query('companion_patient_access', limit: 1);
  if (patients.isNotEmpty) {
    final practitioners = await db.query(
      'practitioners',
      columns: ['practitioner_id'],
      orderBy: 'created_at ASC, practitioner_id ASC',
      limit: 1,
    );
    if (practitioners.isEmpty) return false;
    await db.update(
      'companion_patient_access',
      {'referring_practitioner_id': practitioners.single['practitioner_id']},
      where:
          'referring_practitioner_id IS NULL AND former_practitioner_id IS NULL',
    );
  }
  await db.update('companion_access_initialization', {
    'assignments_pending': 0,
  }, where: 'singleton = 1');
  return true;
}

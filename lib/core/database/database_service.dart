import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class DatabaseService {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null && _database!.isOpen) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  static Future<void> closeDatabase() async {
    final db = _database;

    if (db != null && db.isOpen) {
      await db.close();
    }

    _database = null;
  }

  static Future<Database> reopenDatabase() async {
    await closeDatabase();
    return database;
  }

  static Future<String> get databasePath async {
    final appSupportDir = await getApplicationSupportDirectory();

    final databaseDir = Directory(
      join(appSupportDir.path, 'database'),
    );

    if (!await databaseDir.exists()) {
      await databaseDir.create(recursive: true);
    }

    return join(
      databaseDir.path,
      'abak_desktop.db',
    );
  }

  static Future<Database> _initDatabase() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final path = await databasePath;

    return openDatabase(
      path,
      version: 12,
      onCreate: (db, version) async {
        await _createTables(db);
        await _createImportHistoryTables(db);
        await _createMobileCaseTables(db);
        await _createBackupTables(db);
        await _createRestoreHistoryTables(db);
        await _createResultConflictTables(db);
      },

      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await _createImportHistoryTables(db);
        }

        if (oldVersion < 3) {
          await db.execute('''
      ALTER TABLE desktop_import_sessions
      ADD COLUMN status TEXT NOT NULL DEFAULT 'completed'
    ''');
        }

        if (oldVersion < 4) {
          await db.execute('''
      ALTER TABLE desktop_results
      ADD COLUMN sync_state TEXT NOT NULL DEFAULT 'imported'
    ''');

          await db.execute('''
      ALTER TABLE desktop_results
      ADD COLUMN last_modified_at INTEGER
    ''');

          await db.execute('''
      ALTER TABLE desktop_results
      ADD COLUMN content_hash TEXT NULL
    ''');

          await db.execute('''
      UPDATE desktop_results
      SET last_modified_at = imported_at
      WHERE last_modified_at IS NULL
    ''');
        }
        if (oldVersion < 5) {
          await db.execute('''
    ALTER TABLE desktop_import_sessions
    ADD COLUMN conflict_results_count INTEGER NOT NULL DEFAULT 0
  ''');

          await db.execute('''
    ALTER TABLE desktop_import_session_files
    ADD COLUMN conflict_results_count INTEGER NOT NULL DEFAULT 0
  ''');
        }
        if (oldVersion < 6) {
          await _createMobileCaseTables(db);
        }
        if (oldVersion < 7) {
          await db.execute('''
    ALTER TABLE desktop_results
    ADD COLUMN mobile_case_id TEXT NULL
  ''');

          await db.execute('''
    ALTER TABLE desktop_results
    ADD COLUMN mobile_case_label TEXT NULL
  ''');
        }
        if (oldVersion < 8) {
          await _createBackupTables(db);
        }
        if (oldVersion < 9) {
          await _createRestoreHistoryTables(db);
        }
        if (oldVersion < 10) {
          await db.execute('''
    ALTER TABLE desktop_import_session_files
    ADD COLUMN file_path TEXT NULL
  ''');
        }
        if (oldVersion < 11) {
          await db.execute('''
    CREATE UNIQUE INDEX IF NOT EXISTS idx_desktop_result_metrics_result_key
    ON desktop_result_metrics(result_id, metric_key)
  ''');
        }
        if (oldVersion < 12) {
          await _createResultConflictTables(db);
        }
      },
    );
  }

  static Future<void> _createImportHistoryTables(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS desktop_import_sessions (
  import_session_id TEXT PRIMARY KEY,

  started_at INTEGER NOT NULL,
  completed_at INTEGER NULL,

  status TEXT NOT NULL DEFAULT 'running',

  processed_files_count INTEGER NOT NULL DEFAULT 0,
  failed_files_count INTEGER NOT NULL DEFAULT 0,

  imported_results_count INTEGER NOT NULL DEFAULT 0,
  skipped_results_count INTEGER NOT NULL DEFAULT 0,
  conflict_results_count INTEGER NOT NULL DEFAULT 0,
  imported_metrics_count INTEGER NOT NULL DEFAULT 0,

  source_label TEXT NULL,
  notes TEXT NULL
)
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS desktop_import_session_files (
      session_file_id TEXT PRIMARY KEY,

      import_session_id TEXT NOT NULL,

      file_name TEXT NOT NULL,
      file_path TEXT NULL,
      file_size INTEGER NULL,

      processed_at INTEGER NOT NULL,

      imported_results_count INTEGER NOT NULL DEFAULT 0,
      skipped_results_count INTEGER NOT NULL DEFAULT 0,
      conflict_results_count INTEGER NOT NULL DEFAULT 0,
      imported_metrics_count INTEGER NOT NULL DEFAULT 0,

      status TEXT NOT NULL,
      error_message TEXT NULL,

      FOREIGN KEY(import_session_id)
        REFERENCES desktop_import_sessions(import_session_id)
    )
  ''');
  }

  static Future<void> _createTables(Database db) async {
    await db.execute('''
  CREATE TABLE patients (
    patient_id TEXT PRIMARY KEY,
    last_name TEXT NOT NULL,
    first_name TEXT NOT NULL,
    birth_date TEXT,
    sex_code TEXT DEFAULT 'U',
    created_at INTEGER NOT NULL,
    updated_at INTEGER,
    archived_at INTEGER
  )
''');
    await db.execute('''
  CREATE TABLE practitioners (
    practitioner_id TEXT PRIMARY KEY,
    display_name TEXT NOT NULL,
    first_name TEXT,
    last_name TEXT,
    professional_id TEXT,
    email TEXT,
    phone TEXT,
    is_active INTEGER NOT NULL DEFAULT 1,
    created_at INTEGER NOT NULL,
    updated_at INTEGER,
    archived_at INTEGER
  )
''');
    await db.execute('''
  CREATE TABLE paired_devices (
    device_id TEXT PRIMARY KEY,
    practitioner_id TEXT NULL,

    device_label TEXT NOT NULL,
    platform TEXT NULL,

    public_key TEXT NULL,

    paired_at INTEGER NOT NULL,
    last_seen_at INTEGER NULL,

    archived_at INTEGER NULL,

    FOREIGN KEY(practitioner_id)
      REFERENCES practitioners(practitioner_id)
  )
''');
    await db.execute('''
  CREATE TABLE desktop_results (
    result_id TEXT PRIMARY KEY,

    patient_id TEXT NOT NULL,
    practitioner_id TEXT NULL,
    source_device_id TEXT NULL,

    practitioner_label_snapshot TEXT NULL,

    episode_id TEXT NULL,

    createdAt INTEGER NOT NULL,
    imported_at INTEGER NOT NULL,

    exoId TEXT NOT NULL,

    scoreTotal REAL,
    comment TEXT,

    exportSimpleText TEXT NOT NULL,
    simpleExportSnapshotJson TEXT NULL,

    profileJson TEXT NULL,
    structuredJson TEXT NULL,

    ageYears INTEGER NULL,
    sexCode TEXT NULL,
    testedSideCode TEXT NULL,
    measureUnit TEXT NULL,

    heightCm INTEGER NULL,
    weightKg REAL NULL,
    bmi REAL NULL,

    sportLevelCode TEXT NULL,
    contextCode TEXT NULL,

    testCode TEXT NULL,
    testVersion INTEGER NULL,
    testFamily TEXT NULL,

    performerCountryCode TEXT NULL,
    performerRegionCode TEXT NULL,
    performerMainActivityCode TEXT NULL,
    performerMainSpecialtyCode TEXT NULL,
    performerYearsExperienceCode TEXT NULL,
    performerProfileUpdatedAt INTEGER NULL,

    localSchemaVersion INTEGER NULL,

    archived_at INTEGER NULL,

    sync_state TEXT NOT NULL DEFAULT 'imported',
    last_modified_at INTEGER NULL,
    content_hash TEXT NULL,

    mobile_case_id TEXT NULL,
    mobile_case_label TEXT NULL,

    FOREIGN KEY(patient_id)
      REFERENCES patients(patient_id),

    FOREIGN KEY(practitioner_id)
      REFERENCES practitioners(practitioner_id),

    FOREIGN KEY(source_device_id)
      REFERENCES paired_devices(device_id)
  )
''');
    await db.execute('''
  CREATE TABLE desktop_result_metrics (
    metric_id TEXT PRIMARY KEY,

    result_id TEXT NOT NULL,

    metric_key TEXT NOT NULL,
    value REAL NOT NULL,

    unit TEXT NULL,
    label TEXT NULL,

FOREIGN KEY(result_id)
  REFERENCES desktop_results(result_id),

UNIQUE(result_id, metric_key)
  )
''');
  }
  static Future<void> _createMobileCaseTables(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS mobile_cases (
      case_id TEXT PRIMARY KEY,

      case_label TEXT NOT NULL,
      pathology_code TEXT NULL,

      source_device_id TEXT NULL,

      created_at INTEGER NOT NULL,
      imported_at INTEGER NULL,
      updated_at INTEGER NULL,
      archived_at INTEGER NULL,

      FOREIGN KEY(source_device_id)
        REFERENCES paired_devices(device_id)
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS case_patient_links (
      case_id TEXT PRIMARY KEY,

      patient_id TEXT NOT NULL,

      linked_at INTEGER NOT NULL,
      linked_by_practitioner_id TEXT NULL,

      status TEXT NOT NULL DEFAULT 'linked',

      FOREIGN KEY(case_id)
        REFERENCES mobile_cases(case_id),

      FOREIGN KEY(patient_id)
        REFERENCES patients(patient_id),

      FOREIGN KEY(linked_by_practitioner_id)
        REFERENCES practitioners(practitioner_id)
    )
  ''');
  }

  static Future<void> _createBackupTables(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS desktop_backups (
      backup_id TEXT PRIMARY KEY,

      file_name TEXT NOT NULL,
      file_path TEXT NOT NULL,

      created_at INTEGER NOT NULL,
      file_size INTEGER NOT NULL,

      status TEXT NOT NULL DEFAULT 'completed',
      notes TEXT NULL
    )
  ''');
  }
  static Future<void> _createRestoreHistoryTables(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS desktop_restore_history (
      restore_id TEXT PRIMARY KEY,

      restored_at INTEGER NOT NULL,

      source_backup_path TEXT NOT NULL,
      safety_backup_path TEXT NULL,

      success INTEGER NOT NULL DEFAULT 0,
      message TEXT NULL
    )
  ''');
  }

  static Future<void> _createResultConflictTables(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS desktop_result_conflicts (
      conflict_id TEXT PRIMARY KEY,

      result_id TEXT NOT NULL,

      existing_hash TEXT NULL,
      incoming_hash TEXT NOT NULL,

      existing_json TEXT NULL,
      incoming_json TEXT NOT NULL,

      detected_at INTEGER NOT NULL,

      resolution_status TEXT NOT NULL DEFAULT 'pending',
      resolved_at INTEGER NULL,
      resolution_note TEXT NULL,

      FOREIGN KEY(result_id)
        REFERENCES desktop_results(result_id)
    )
  ''');
  }
}
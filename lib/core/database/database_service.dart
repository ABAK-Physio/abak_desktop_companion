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

  static Future<void> resetUserDatabase() async {
    final db = await database;

    await _resetDatabase(db);
    await _createAllTables(db);
  }

  static Future<Database> _initDatabase() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final path = await databasePath;

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await _createAllTables(db);
      },
    );
  }

  static Future<void> _createAllTables(Database db) async {
    await _createCoreTables(db);
    await _createCareEpisodeTables(db);
    await _createCareEpisodeNoteTables(db);
    await _createResultTables(db);
    await _createImportHistoryTables(db);
    await _createBackupTables(db);
    await _createRestoreHistoryTables(db);
    await _createResultConflictTables(db);
  }

  static Future<void> _resetDatabase(Database db) async {
    await db.execute('DROP TABLE IF EXISTS desktop_result_conflicts');
    await db.execute('DROP TABLE IF EXISTS desktop_result_metrics');
    await db.execute('DROP TABLE IF EXISTS desktop_results');

    await db.execute('DROP TABLE IF EXISTS care_episode_notes');
    await db.execute('DROP TABLE IF EXISTS care_episodes');

    await db.execute('DROP TABLE IF EXISTS desktop_import_session_files');
    await db.execute('DROP TABLE IF EXISTS desktop_import_sessions');

    await db.execute('DROP TABLE IF EXISTS desktop_restore_history');
    await db.execute('DROP TABLE IF EXISTS desktop_backups');

    await db.execute('DROP TABLE IF EXISTS paired_devices');
    await db.execute('DROP TABLE IF EXISTS practitioners');
    await db.execute('DROP TABLE IF EXISTS patients');

    // Nettoyage des anciennes tables si une base de test les contient encore.
    await db.execute('DROP TABLE IF EXISTS mobile_cases');
    await db.execute('DROP TABLE IF EXISTS case_patient_links');
    await db.execute('DROP TABLE IF EXISTS desktop_clinical_episodes');
    await db.execute('DROP TABLE IF EXISTS episode_notes');
    await db.execute('DROP TABLE IF EXISTS episode_conclusions');
    await db.execute('DROP TABLE IF EXISTS episode_documents');
    await db.execute('DROP TABLE IF EXISTS episode_form_answers');
    await db.execute('DROP TABLE IF EXISTS episode_forms');
    await db.execute('DROP TABLE IF EXISTS contact_form_fields');
    await db.execute('DROP TABLE IF EXISTS contact_form_templates');
    await db.execute('DROP TABLE IF EXISTS patient_attributes');
    await db.execute('DROP TABLE IF EXISTS patient_identity');
  }

  static Future<void> _createCoreTables(Database db) async {
    await db.execute('''
      CREATE TABLE patients (
        patient_id TEXT PRIMARY KEY,
        last_name TEXT NOT NULL,
        first_name TEXT NOT NULL,
        birth_date TEXT NULL,
        sex_code TEXT NOT NULL DEFAULT 'U',
        created_at INTEGER NOT NULL,
        updated_at INTEGER NULL,
        archived_at INTEGER NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE practitioners (
        practitioner_id TEXT PRIMARY KEY,
        display_name TEXT NOT NULL,
        first_name TEXT NULL,
        last_name TEXT NULL,
        professional_id TEXT NULL,
        email TEXT NULL,
        phone TEXT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NULL,
        archived_at INTEGER NULL
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
  }

  static Future<void> _createCareEpisodeTables(Database db) async {
    await db.execute('''
      CREATE TABLE care_episodes (
        care_episode_id TEXT PRIMARY KEY,
        patient_id TEXT NOT NULL,
        title TEXT NOT NULL,
        pathology_label TEXT NOT NULL,
        initial_report TEXT NULL,
        final_conclusion TEXT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NULL,
        archived_at INTEGER NULL,

        FOREIGN KEY(patient_id)
          REFERENCES patients(patient_id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_care_episodes_patient_id
      ON care_episodes(patient_id)
    ''');
  }

  static Future<void> _createCareEpisodeNoteTables(Database db) async {
    await db.execute('''
      CREATE TABLE care_episode_notes (
        note_id TEXT PRIMARY KEY,
        care_episode_id TEXT NOT NULL,
        note_date INTEGER NOT NULL,
        content TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NULL,
        archived_at INTEGER NULL,

        FOREIGN KEY(care_episode_id)
          REFERENCES care_episodes(care_episode_id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_care_episode_notes_episode_id
      ON care_episode_notes(care_episode_id)
    ''');
  }

  static Future<void> _createResultTables(Database db) async {
    await db.execute('''
      CREATE TABLE desktop_results (
        result_id TEXT PRIMARY KEY,

        care_episode_id TEXT NOT NULL,

        patient_id TEXT NULL,
        practitioner_id TEXT NULL,
        source_device_id TEXT NULL,

        practitioner_label_snapshot TEXT NULL,

        mobile_episode_id TEXT NULL,
        mobile_pathology_code TEXT NULL,
        mobile_pathology_label TEXT NULL,
        mobile_patient_ref TEXT NULL,
        mobile_patient_label TEXT NULL,

        createdAt INTEGER NOT NULL,
        imported_at INTEGER NOT NULL,

        exoId TEXT NOT NULL,

        scoreTotal REAL NULL,
        comment TEXT NULL,

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

        FOREIGN KEY(care_episode_id)
          REFERENCES care_episodes(care_episode_id),

        FOREIGN KEY(patient_id)
          REFERENCES patients(patient_id),

        FOREIGN KEY(practitioner_id)
          REFERENCES practitioners(practitioner_id),

        FOREIGN KEY(source_device_id)
          REFERENCES paired_devices(device_id)
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_desktop_results_care_episode_id
      ON desktop_results(care_episode_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_desktop_results_patient_id
      ON desktop_results(patient_id)
    ''');

    await db.execute('''
      CREATE INDEX idx_desktop_results_exo_id
      ON desktop_results(exoId)
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

    await db.execute('''
      CREATE INDEX idx_desktop_result_metrics_result_id
      ON desktop_result_metrics(result_id)
    ''');
  }

  static Future<void> _createImportHistoryTables(Database db) async {
    await db.execute('''
      CREATE TABLE desktop_import_sessions (
        import_session_id TEXT PRIMARY KEY,

        started_at INTEGER NOT NULL,
        completed_at INTEGER NULL,

        status TEXT NOT NULL DEFAULT 'running',

        selected_patient_id TEXT NULL,
        selected_care_episode_id TEXT NULL,

        processed_files_count INTEGER NOT NULL DEFAULT 0,
        failed_files_count INTEGER NOT NULL DEFAULT 0,

        imported_results_count INTEGER NOT NULL DEFAULT 0,
        skipped_results_count INTEGER NOT NULL DEFAULT 0,
        conflict_results_count INTEGER NOT NULL DEFAULT 0,
        imported_metrics_count INTEGER NOT NULL DEFAULT 0,

        source_label TEXT NULL,
        notes TEXT NULL,

        FOREIGN KEY(selected_patient_id)
          REFERENCES patients(patient_id),

        FOREIGN KEY(selected_care_episode_id)
          REFERENCES care_episodes(care_episode_id)
      )
    ''');

    await db.execute('''
      CREATE TABLE desktop_import_session_files (
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

    await db.execute('''
      CREATE INDEX idx_desktop_import_session_files_session_id
      ON desktop_import_session_files(import_session_id)
    ''');
  }

  static Future<void> _createBackupTables(Database db) async {
    await db.execute('''
      CREATE TABLE desktop_backups (
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
      CREATE TABLE desktop_restore_history (
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
      CREATE TABLE desktop_result_conflicts (
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

    await db.execute('''
      CREATE INDEX idx_desktop_result_conflicts_result_id
      ON desktop_result_conflicts(result_id)
    ''');
  }
}
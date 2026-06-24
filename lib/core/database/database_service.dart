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

  static Future<void> _resetDatabase(Database db) async {
    await db.execute('DROP TABLE IF EXISTS episode_conclusions');
    await db.execute('DROP TABLE IF EXISTS episode_notes');
    await db.execute('DROP TABLE IF EXISTS episode_documents');
    await db.execute('DROP TABLE IF EXISTS episode_form_answers');
    await db.execute('DROP TABLE IF EXISTS episode_forms');
    await db.execute('DROP TABLE IF EXISTS contact_form_fields');
    await db.execute('DROP TABLE IF EXISTS contact_form_templates');
    await db.execute('DROP TABLE IF EXISTS patient_attributes');
    await db.execute('DROP TABLE IF EXISTS patient_identity');
    await db.execute('DROP TABLE IF EXISTS care_episodes');

    await db.execute('DROP TABLE IF EXISTS desktop_clinical_episodes');
    await db.execute('DROP TABLE IF EXISTS desktop_result_conflicts');
    await db.execute('DROP TABLE IF EXISTS desktop_result_metrics');
    await db.execute('DROP TABLE IF EXISTS desktop_results');

    await db.execute('DROP TABLE IF EXISTS case_patient_links');
    await db.execute('DROP TABLE IF EXISTS mobile_cases');

    await db.execute('DROP TABLE IF EXISTS desktop_import_session_files');
    await db.execute('DROP TABLE IF EXISTS desktop_import_sessions');

    await db.execute('DROP TABLE IF EXISTS desktop_restore_history');
    await db.execute('DROP TABLE IF EXISTS desktop_backups');

    await db.execute('DROP TABLE IF EXISTS paired_devices');
    await db.execute('DROP TABLE IF EXISTS practitioners');
    await db.execute('DROP TABLE IF EXISTS patients');
  }

  static Future<Database> _initDatabase() async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final path = await databasePath;

    return openDatabase(
      path,
      version: 21,
      onCreate: (db, version) async {
        await _createTables(db);
        await _createImportHistoryTables(db);
        await _createMobileCaseTables(db);
        await _createDesktopClinicalEpisodeTables(db);
        await _createBackupTables(db);
        await _createRestoreHistoryTables(db);
        await _createResultConflictTables(db);
        await _createPatientClinicalTables(db);
        await _createCareEpisodeTables(db);
        await _createEpisodeNoteTables(db);
        await _createEpisodeConclusionTables(db);

      },

      onUpgrade: (db, oldVersion, newVersion) async {
        await _resetDatabase(db);

        await _createTables(db);
        await _createImportHistoryTables(db);
        await _createMobileCaseTables(db);
        await _createDesktopClinicalEpisodeTables(db);
        await _createBackupTables(db);
        await _createRestoreHistoryTables(db);
        await _createResultConflictTables(db);
        await _createPatientClinicalTables(db);
        await _createCareEpisodeTables(db);
        await _createEpisodeNoteTables(db);
        await _createEpisodeConclusionTables(db);
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

  static Future<void> _createCareEpisodeTables(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS care_episodes (
      care_episode_id TEXT PRIMARY KEY,

      patient_id TEXT NOT NULL,

      title TEXT NOT NULL,
      pathology_label TEXT NOT NULL,

      initial_report TEXT NULL,

      created_at INTEGER NOT NULL,
      updated_at INTEGER NULL,
      archived_at INTEGER NULL,

      FOREIGN KEY(patient_id)
        REFERENCES patients(patient_id)
    )
  ''');

    await db.execute('''
    CREATE INDEX IF NOT EXISTS idx_care_episodes_patient_id
    ON care_episodes(patient_id)
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

  static Future<void> _createEpisodeConclusionTables(
      Database db,
      ) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS episode_conclusions (
      conclusion_id TEXT PRIMARY KEY,

      case_id TEXT NOT NULL,

      content TEXT NOT NULL,

      created_at INTEGER NOT NULL,
      updated_at INTEGER NULL,
      archived_at INTEGER NULL,

      FOREIGN KEY(case_id)
        REFERENCES mobile_cases(case_id)
    )
  ''');
  }

  static Future<void> _createPatientClinicalTables(Database db) async {
    await db.execute('''
  CREATE TABLE IF NOT EXISTS patient_identity (
    patient_id TEXT PRIMARY KEY,

    national_health_id TEXT NULL,
    health_system_country TEXT NULL,
    identity_source TEXT NULL,

    phone TEXT NULL,
    email TEXT NULL,
    address TEXT NULL,

    last_verified_at INTEGER NULL,
    updated_at INTEGER NOT NULL,

    FOREIGN KEY(patient_id)
      REFERENCES patients(patient_id)
  )
''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS patient_attributes (
      attribute_id TEXT PRIMARY KEY,

      patient_id TEXT NOT NULL,

      attribute_key TEXT NOT NULL,
      attribute_value TEXT NULL,

      updated_at INTEGER NOT NULL,

      FOREIGN KEY(patient_id)
        REFERENCES patients(patient_id),

      UNIQUE(patient_id, attribute_key)
    )
  ''');

    await db.execute('''
  CREATE TABLE IF NOT EXISTS contact_form_templates (
    template_id TEXT PRIMARY KEY,

    practitioner_id TEXT NULL,

    name TEXT NOT NULL,
    description TEXT NULL,
    category TEXT NULL,

    is_default INTEGER NOT NULL DEFAULT 0,

    created_at INTEGER NOT NULL,
    updated_at INTEGER NULL,
    archived_at INTEGER NULL,

    FOREIGN KEY(practitioner_id)
      REFERENCES practitioners(practitioner_id)
  )
''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS contact_form_fields (
      field_id TEXT PRIMARY KEY,

      template_id TEXT NOT NULL,

      label TEXT NOT NULL,
      field_type TEXT NOT NULL,

      target_scope TEXT NOT NULL,

      sort_order INTEGER NOT NULL DEFAULT 0,
      required INTEGER NOT NULL DEFAULT 0,

      options_json TEXT NULL,

      created_at INTEGER NOT NULL,
      updated_at INTEGER NULL,
      archived_at INTEGER NULL,

      FOREIGN KEY(template_id)
        REFERENCES contact_form_templates(template_id)
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS episode_forms (
      form_id TEXT PRIMARY KEY,

      case_id TEXT NOT NULL,
      template_id TEXT NOT NULL,

      created_at INTEGER NOT NULL,
      updated_at INTEGER NULL,
      archived_at INTEGER NULL,

      FOREIGN KEY(case_id)
        REFERENCES mobile_cases(case_id),

      FOREIGN KEY(template_id)
        REFERENCES contact_form_templates(template_id)
    )
  ''');

    await db.execute('''
  CREATE UNIQUE INDEX IF NOT EXISTS idx_episode_forms_case_template_active
  ON episode_forms(case_id, template_id)
  WHERE archived_at IS NULL
''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS episode_form_answers (
      answer_id TEXT PRIMARY KEY,

      form_id TEXT NOT NULL,
      field_id TEXT NOT NULL,

      value TEXT NULL,
      updated_at INTEGER NOT NULL,

      FOREIGN KEY(form_id)
        REFERENCES episode_forms(form_id),

      FOREIGN KEY(field_id)
        REFERENCES contact_form_fields(field_id),

      UNIQUE(form_id, field_id)
    )
  ''');

    await db.execute('''
    CREATE TABLE IF NOT EXISTS episode_documents (
      document_id TEXT PRIMARY KEY,

      case_id TEXT NOT NULL,

      title TEXT NOT NULL,
      file_path TEXT NOT NULL,
      mime_type TEXT NULL,

      source TEXT NULL,

      created_at INTEGER NOT NULL,
      updated_at INTEGER NULL,
      archived_at INTEGER NULL,

      FOREIGN KEY(case_id)
        REFERENCES mobile_cases(case_id)
    )
  ''');
  }

  static Future<void> _upgradeToV14(Database db) async {
    await db.execute('''
    ALTER TABLE contact_form_templates
    ADD COLUMN practitioner_id TEXT NULL
  ''');

    await db.execute('''
    ALTER TABLE contact_form_templates
    ADD COLUMN category TEXT NULL
  ''');

    await db.execute('''
    ALTER TABLE contact_form_templates
    ADD COLUMN is_default INTEGER NOT NULL DEFAULT 0
  ''');
  }

  static Future<void> _upgradeToV15(Database db) async {
    await db.execute('''
    ALTER TABLE patient_identity
    ADD COLUMN phone TEXT NULL
  ''');

    await db.execute('''
    ALTER TABLE patient_identity
    ADD COLUMN email TEXT NULL
  ''');

    await db.execute('''
    ALTER TABLE patient_identity
    ADD COLUMN address TEXT NULL
  ''');
  }

  static Future<void> _upgradeToV16(Database db) async {
    await db.execute('''
    UPDATE episode_forms
    SET archived_at = strftime('%s','now') * 1000,
        updated_at = strftime('%s','now') * 1000
    WHERE form_id NOT IN (
      SELECT MIN(form_id)
      FROM episode_forms
      WHERE archived_at IS NULL
      GROUP BY case_id, template_id
    )
    AND archived_at IS NULL
  ''');

    await db.execute('''
    CREATE UNIQUE INDEX IF NOT EXISTS idx_episode_forms_case_template_active
    ON episode_forms(case_id, template_id)
    WHERE archived_at IS NULL
  ''');
  }

  static Future<void> _createEpisodeNoteTables(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS episode_notes (
      note_id TEXT PRIMARY KEY,

      case_id TEXT NOT NULL,

      title TEXT NOT NULL,
      content TEXT NOT NULL,

      created_at INTEGER NOT NULL,
      updated_at INTEGER NULL,
      archived_at INTEGER NULL,

      FOREIGN KEY(case_id)
        REFERENCES mobile_cases(case_id)
    )
  ''');
  }
  static Future<void> _createDesktopClinicalEpisodeTables(Database db) async {
    await db.execute('''
    CREATE TABLE IF NOT EXISTS desktop_clinical_episodes (
      episode_id TEXT PRIMARY KEY,

      mobile_case_id TEXT NOT NULL,
      patient_id TEXT NULL,

      patient_ref TEXT NULL,
      patient_label TEXT NULL,
      label TEXT NULL,

      pathology_code TEXT NULL,
      pathology_label TEXT NULL,
      pathology_coding_system TEXT NULL,
      pathology_coding_system_uri TEXT NULL,
      pathology_external_code TEXT NULL,
      pathology_free_text TEXT NULL,

      created_at TEXT NULL,
      last_used_at TEXT NULL,
      closed_at TEXT NULL,
      status TEXT NOT NULL DEFAULT 'active',

      imported_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,

      FOREIGN KEY(mobile_case_id)
        REFERENCES mobile_cases(case_id),

      FOREIGN KEY(patient_id)
        REFERENCES patients(patient_id)
    )
  ''');

    await db.execute('''
    CREATE INDEX IF NOT EXISTS idx_desktop_clinical_episodes_mobile_case_id
    ON desktop_clinical_episodes(mobile_case_id)
  ''');

    await db.execute('''
    CREATE INDEX IF NOT EXISTS idx_desktop_clinical_episodes_patient_id
    ON desktop_clinical_episodes(patient_id)
  ''');

    await db.execute('''
    CREATE INDEX IF NOT EXISTS idx_desktop_results_episode_id
    ON desktop_results(episode_id)
  ''');
  }
}
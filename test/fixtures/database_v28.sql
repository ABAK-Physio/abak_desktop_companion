-- Frozen v28 schema from a48c882860a0576aa5fc38017c49a46e853eecc4
-- Source: lib/core/database/database_service.dart, _createAllTables and its callees.
-- Deliberately independent of current schema helpers. Do not regenerate from HEAD.
-- Statements contain no triggers or embedded semicolons. Split on semicolons.

CREATE TABLE patients (
  patient_id TEXT PRIMARY KEY,
  last_name TEXT NOT NULL,
  first_name TEXT NOT NULL,
  birth_date TEXT NULL,
  sex_code TEXT NOT NULL DEFAULT 'U',
  nir TEXT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NULL,
  archived_at INTEGER NULL
);

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
);

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
);

CREATE TABLE IF NOT EXISTS patient_fr_health_identity (
  patient_id TEXT PRIMARY KEY,

  ins_number TEXT NULL,
  ins_key TEXT NULL,
  ins_oid TEXT NULL,

  birth_last_name TEXT NULL,
  birth_first_names TEXT NULL,
  birth_date TEXT NULL,
  sex_code TEXT NULL,
  birth_place_code TEXT NULL,

  identity_status TEXT NOT NULL DEFAULT 'provisional',
  identity_doubtful INTEGER NOT NULL DEFAULT 0,

  identity_validation_method TEXT NULL,
  identity_validated_at INTEGER NULL,
  identity_validated_by TEXT NULL,

  ins_retrieved_at INTEGER NULL,
  ins_last_checked_at INTEGER NULL,

  updated_at INTEGER NULL,

  FOREIGN KEY(patient_id)
    REFERENCES patients(patient_id)
    ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS application_settings (
  setting_key TEXT PRIMARY KEY,
  setting_value TEXT NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE TABLE patient_identity (
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
);

CREATE TABLE patient_attributes (
  attribute_id TEXT PRIMARY KEY,

  patient_id TEXT NOT NULL,

  attribute_key TEXT NOT NULL,
  attribute_value TEXT NULL,

  updated_at INTEGER NOT NULL,

  FOREIGN KEY(patient_id)
    REFERENCES patients(patient_id),

  UNIQUE(patient_id, attribute_key)
);

CREATE TABLE care_episodes (
  care_episode_id TEXT PRIMARY KEY,
  patient_id TEXT NOT NULL,
  title TEXT NOT NULL,
  pathology_label TEXT NOT NULL,
  initial_report TEXT NULL,
  initial_report_docx_path TEXT NULL,
  objective_data TEXT NULL,
  assessment_data TEXT NULL,
  treatment_plan TEXT NULL,
  final_conclusion TEXT NULL,
  opened_at INTEGER NULL,
  prescribing_correspondent_id TEXT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NULL,
  archived_at INTEGER NULL,

  FOREIGN KEY(patient_id)
    REFERENCES patients(patient_id)
);

CREATE INDEX idx_care_episodes_patient_id
ON care_episodes(patient_id);

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
    REFERENCES care_episodes(care_episode_id)
    ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_episode_documents_case_id
ON episode_documents(case_id);

CREATE TABLE external_correspondents (
  correspondent_id TEXT PRIMARY KEY,
  last_name TEXT NOT NULL,
  first_name TEXT NULL,
  profession TEXT NULL,
  specialty TEXT NULL,
  address_line1 TEXT NULL,
  address_line2 TEXT NULL,
  postal_code TEXT NULL,
  city TEXT NULL,
  email TEXT NULL,
  phone TEXT NULL,
  archived_at INTEGER NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NULL
);

CREATE TABLE care_episode_referring_practitioners (
  assignment_id TEXT PRIMARY KEY,

  care_episode_id TEXT NOT NULL,
  practitioner_id TEXT NOT NULL,

  started_at INTEGER NOT NULL,
  ended_at INTEGER NULL,

  FOREIGN KEY(care_episode_id)
    REFERENCES care_episodes(care_episode_id),

  FOREIGN KEY(practitioner_id)
    REFERENCES practitioners(practitioner_id)
);

CREATE INDEX idx_care_episode_referring_practitioners_episode_id
ON care_episode_referring_practitioners(care_episode_id);

CREATE INDEX idx_care_episode_referring_practitioners_practitioner_id
ON care_episode_referring_practitioners(practitioner_id);

CREATE TABLE care_episode_notes (
  note_id TEXT PRIMARY KEY,
  care_episode_id TEXT NOT NULL,
  note_date INTEGER NOT NULL,
  title TEXT NOT NULL DEFAULT '',
  content TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NULL,
  archived_at INTEGER NULL,

  FOREIGN KEY(care_episode_id)
    REFERENCES care_episodes(care_episode_id)
);

CREATE INDEX idx_care_episode_notes_episode_id
ON care_episode_notes(care_episode_id);

CREATE TABLE care_episode_assessments (
  assessment_id TEXT PRIMARY KEY,
  care_episode_id TEXT NOT NULL,

  title TEXT NOT NULL,
  content_json TEXT NOT NULL,

  status TEXT NOT NULL DEFAULT 'draft',

  author_practitioner_id TEXT NULL,
  recipient_text TEXT NULL,
  docx_file_name TEXT NULL,

  assessment_date INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NULL,
  archived_at INTEGER NULL,

  FOREIGN KEY(care_episode_id)
    REFERENCES care_episodes(care_episode_id)
);

CREATE INDEX idx_care_episode_assessments_episode_id
ON care_episode_assessments(care_episode_id);

CREATE INDEX idx_care_episode_assessments_status
ON care_episode_assessments(care_episode_id, status);

CREATE TABLE care_episode_assessment_tests (
  assessment_id TEXT NOT NULL,
  exo_id TEXT NOT NULL,

  PRIMARY KEY(assessment_id, exo_id),

  FOREIGN KEY(assessment_id)
    REFERENCES care_episode_assessments(assessment_id)
);

CREATE TABLE care_episode_assessment_notes (
  assessment_id TEXT NOT NULL,
  note_id TEXT NOT NULL,

  PRIMARY KEY(assessment_id, note_id),

  FOREIGN KEY(assessment_id)
    REFERENCES care_episode_assessments(assessment_id),

  FOREIGN KEY(note_id)
    REFERENCES care_episode_notes(note_id)
);

CREATE TABLE care_episode_reports (
  report_id TEXT PRIMARY KEY,
  care_episode_id TEXT NOT NULL,
  source_assessment_id TEXT NULL,
  author_practitioner_id TEXT NULL,
  recipient_text TEXT NULL,
  docx_file_name TEXT NULL,

  title TEXT NOT NULL,
  content_json TEXT NOT NULL,

  status TEXT NOT NULL DEFAULT 'draft',

  report_date INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NULL,
  archived_at INTEGER NULL,

  FOREIGN KEY(care_episode_id)
    REFERENCES care_episodes(care_episode_id),

  FOREIGN KEY(source_assessment_id)
    REFERENCES care_episode_assessments(assessment_id)
);

CREATE INDEX idx_care_episode_reports_episode_id
ON care_episode_reports(care_episode_id);

CREATE TABLE IF NOT EXISTS care_episode_report_tests (
  report_id TEXT NOT NULL,
  exo_id TEXT NOT NULL,

  PRIMARY KEY(report_id, exo_id),

  FOREIGN KEY(report_id)
    REFERENCES care_episode_reports(report_id)
);

CREATE TABLE IF NOT EXISTS care_episode_report_notes (
  report_id TEXT NOT NULL,
  note_id TEXT NOT NULL,

  PRIMARY KEY(report_id, note_id),

  FOREIGN KEY(report_id)
    REFERENCES care_episode_reports(report_id),

  FOREIGN KEY(note_id)
    REFERENCES care_episode_notes(note_id)
);

CREATE TABLE IF NOT EXISTS care_episode_document_edit_drafts (
  document_type TEXT NOT NULL,
  document_id TEXT NOT NULL,
  content_json TEXT NOT NULL,
  updated_at INTEGER NOT NULL,

  PRIMARY KEY(document_type, document_id)
);

CREATE TABLE desktop_results (
  result_id TEXT PRIMARY KEY,

  care_episode_id TEXT NOT NULL,

  patient_id TEXT NULL,
  practitioner_id TEXT NULL,
  source_device_id TEXT NULL,

  practitioner_label_snapshot TEXT NULL,
  practitioner_verification_status TEXT NULL,

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
);

CREATE INDEX idx_desktop_results_care_episode_id
ON desktop_results(care_episode_id);

CREATE INDEX idx_desktop_results_patient_id
ON desktop_results(patient_id);

CREATE INDEX idx_desktop_results_exo_id
ON desktop_results(exoId);

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
);

CREATE INDEX idx_desktop_result_metrics_result_id
ON desktop_result_metrics(result_id);

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
  duplicate_results_count INTEGER NOT NULL DEFAULT 0,
  conflict_results_count INTEGER NOT NULL DEFAULT 0,
  imported_metrics_count INTEGER NOT NULL DEFAULT 0,

  source_label TEXT NULL,
  notes TEXT NULL,

  summary_patient_label TEXT NULL,
  summary_episode_label TEXT NULL,
  summary_exercises_label TEXT NULL,

  FOREIGN KEY(selected_patient_id)
    REFERENCES patients(patient_id),

  FOREIGN KEY(selected_care_episode_id)
    REFERENCES care_episodes(care_episode_id)
);

CREATE TABLE desktop_import_session_files (
  session_file_id TEXT PRIMARY KEY,

  import_session_id TEXT NOT NULL,

  file_name TEXT NOT NULL,
  file_path TEXT NULL,
  file_size INTEGER NULL,

  processed_at INTEGER NOT NULL,

  imported_results_count INTEGER NOT NULL DEFAULT 0,
  skipped_results_count INTEGER NOT NULL DEFAULT 0,
  duplicate_results_count INTEGER NOT NULL DEFAULT 0,
  conflict_results_count INTEGER NOT NULL DEFAULT 0,
  imported_metrics_count INTEGER NOT NULL DEFAULT 0,

  status TEXT NOT NULL,
  error_message TEXT NULL,

  FOREIGN KEY(import_session_id)
    REFERENCES desktop_import_sessions(import_session_id)
);

CREATE INDEX idx_desktop_import_session_files_session_id
ON desktop_import_session_files(import_session_id);

CREATE TABLE desktop_backups (
  backup_id TEXT PRIMARY KEY,
  file_name TEXT NOT NULL,
  file_path TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  file_size INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'completed',
  notes TEXT NULL
);

CREATE TABLE desktop_restore_history (
  restore_id TEXT PRIMARY KEY,
  restored_at INTEGER NOT NULL,
  source_backup_path TEXT NOT NULL,
  safety_backup_path TEXT NULL,
  success INTEGER NOT NULL DEFAULT 0,
  message TEXT NULL
);

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
);

CREATE INDEX idx_desktop_result_conflicts_result_id
ON desktop_result_conflicts(result_id);

CREATE TABLE IF NOT EXISTS assessment_template_drafts (
  draft_id TEXT PRIMARY KEY,
  care_episode_id TEXT NOT NULL,
  template_id TEXT NOT NULL,
  answers_json TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL,

  FOREIGN KEY(care_episode_id)
    REFERENCES care_episodes(care_episode_id)
);

CREATE UNIQUE INDEX IF NOT EXISTS
idx_assessment_template_drafts_episode_template
ON assessment_template_drafts(
  care_episode_id,
  template_id
);

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Legacy updated_at also covered administrative edits. Mark that backfill as
/// indicative; future activity tracks changes to report content only.
Future<void> createCompanionReportActivity(DatabaseExecutor db) async {
  await db.execute('''CREATE TABLE IF NOT EXISTS companion_report_activity (
    report_id TEXT PRIMARY KEY, last_content_at INTEGER NOT NULL,
    inferred INTEGER NOT NULL CHECK(inferred IN (0, 1)))''');
  await db.execute(
    '''INSERT OR IGNORE INTO companion_report_activity
    SELECT report_id, COALESCE(updated_at, created_at, report_date), 1 FROM care_episode_reports''',
  );
  await db.execute(
    '''CREATE TRIGGER IF NOT EXISTS companion_report_activity_insert
    AFTER INSERT ON care_episode_reports BEGIN
    INSERT OR REPLACE INTO companion_report_activity VALUES(NEW.report_id, NEW.created_at, 0); END''',
  );
  await db.execute(
    '''CREATE TRIGGER IF NOT EXISTS companion_report_activity_update
    AFTER UPDATE ON care_episode_reports
    WHEN NEW.content_json IS NOT OLD.content_json OR NEW.title IS NOT OLD.title
    BEGIN INSERT OR REPLACE INTO companion_report_activity VALUES(
      NEW.report_id, CAST(strftime('%s','now') AS INTEGER)*1000, 0); END''',
  );
  await db.execute(
    '''CREATE TRIGGER IF NOT EXISTS companion_report_activity_delete
    AFTER DELETE ON care_episode_reports BEGIN
    DELETE FROM companion_report_activity WHERE report_id = OLD.report_id; END''',
  );
}

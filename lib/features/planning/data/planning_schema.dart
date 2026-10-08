import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Used by fresh databases and the Companion v32 migration.
Future<void> createPlanningTables(DatabaseExecutor db) async {
  await db.execute('''
    CREATE TABLE IF NOT EXISTS planning_appointments (
      appointment_id TEXT PRIMARY KEY NOT NULL CHECK(length(trim(appointment_id)) > 0),
      title TEXT NOT NULL CHECK(length(trim(title)) > 0),
      appointment_date TEXT NOT NULL
        CHECK(appointment_date GLOB '[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'),
      start_minute INTEGER,
      end_minute INTEGER,
      notes TEXT NOT NULL DEFAULT '',
      color_argb INTEGER NOT NULL CHECK(color_argb BETWEEN 0 AND 4294967295),
      CHECK (
        (start_minute IS NULL AND end_minute IS NULL) OR
        (start_minute IS NOT NULL AND end_minute IS NOT NULL AND
         start_minute >= 0 AND end_minute <= 1440 AND end_minute > start_minute)
      )
    )
  ''');
  await db.execute('''
    CREATE INDEX IF NOT EXISTS idx_planning_appointments_date
    ON planning_appointments(appointment_date, start_minute)
  ''');
}

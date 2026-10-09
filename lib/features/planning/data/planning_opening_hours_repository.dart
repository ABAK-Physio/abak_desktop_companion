import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/planning_opening_hours.dart';

class PlanningOpeningHoursRepository {
  const PlanningOpeningHoursRepository({required this.database});
  final Future<Database> Function() database;
  static const settingKey = 'planning_opening_hours_v1';

  Future<PlanningOpeningHours?> load() async {
    final db = await database();
    final rows = await db.query(
      'application_settings',
      columns: ['setting_value'],
      where: 'setting_key = ?',
      whereArgs: [settingKey],
      limit: 1,
    );
    return rows.isEmpty
        ? null
        : PlanningOpeningHours.decode(rows.single['setting_value'] as String);
  }

  Future<void> save(PlanningOpeningHours hours) async {
    final db = await database();
    await db.insert('application_settings', {
      'setting_key': settingKey,
      'setting_value': hours.encode(),
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

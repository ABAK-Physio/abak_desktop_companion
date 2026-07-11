import '../database/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class CabinetIdentityService {
  const CabinetIdentityService();

  static const _cabinetNameKey = 'cabinet_name';
  static const _cabinetLogoPathKey = 'cabinet_logo_path';

  Future<String?> getCabinetName() async {
    return _getValue(_cabinetNameKey);
  }

  Future<void> setCabinetName(String value) async {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      await _deleteValue(_cabinetNameKey);
    } else {
      await _setValue(_cabinetNameKey, trimmed);
    }
  }

  Future<String?> getCabinetLogoPath() async {
    return _getValue(_cabinetLogoPathKey);
  }

  Future<void> setCabinetLogoPath(String path) async {
    await _setValue(_cabinetLogoPathKey, path);
  }

  Future<void> clearCabinetLogoPath() async {
    await _deleteValue(_cabinetLogoPathKey);
  }

  Future<String?> _getValue(String key) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'application_settings',
      columns: ['setting_value'],
      where: 'setting_key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return rows.first['setting_value'] as String?;
  }

  Future<void> _setValue(String key, String value) async {
    final db = await DatabaseService.database;

    await db.insert('application_settings', {
      'setting_key': key,
      'setting_value': value,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> _deleteValue(String key) async {
    final db = await DatabaseService.database;

    await db.delete(
      'application_settings',
      where: 'setting_key = ?',
      whereArgs: [key],
    );
  }
}

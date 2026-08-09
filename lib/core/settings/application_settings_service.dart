
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../database/database_service.dart';


class ApplicationSettingsService {
  const ApplicationSettingsService();

  static const String _tableName = 'application_settings';

  static const String expertModeEnabledKey = 'expert_mode_enabled';

  Future<String?> getString(String key) async {
    final db = await DatabaseService.database;

    final result = await db.query(
      _tableName,
      columns: ['setting_value'],
      where: 'setting_key = ?',
      whereArgs: [key],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first['setting_value'] as String;
  }

  Future<void> setString(
      String key,
      String value,
      ) async {
    final db = await DatabaseService.database;

    await db.insert(
      _tableName,
      {
        'setting_key': key,
        'setting_value': value,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> getBool(
      String key, {
        bool defaultValue = false,
      }) async {
    final value = await getString(key);

    if (value == null) {
      return defaultValue;
    }

    return value.toLowerCase() == 'true';
  }

  Future<void> setBool(
      String key,
      bool value,
      ) async {
    await setString(key, value.toString());
  }

  Future<int?> getInt(String key) async {
    final value = await getString(key);

    if (value == null) {
      return null;
    }

    return int.tryParse(value);
  }

  Future<int> getIntOrDefault(
      String key, {
        required int defaultValue,
      }) async {
    return await getInt(key) ?? defaultValue;
  }

  Future<void> setInt(
      String key,
      int value,
      ) async {
    await setString(key, value.toString());
  }

  Future<bool> isExpertModeEnabled() async {
    return getBool(
      expertModeEnabledKey,
      defaultValue: false,
    );
  }

  Future<void> setExpertModeEnabled(bool enabled) async {
    await setBool(
      expertModeEnabledKey,
      enabled,
    );
  }

  Future<void> remove(String key) async {
    final db = await DatabaseService.database;

    await db.delete(
      _tableName,
      where: 'setting_key = ?',
      whereArgs: [key],
    );
  }
}
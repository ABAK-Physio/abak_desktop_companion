import '../documents/document_activity_coordinator.dart';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../database/database_service.dart';


class ApplicationSettingsService {
  const ApplicationSettingsService();

  static const String _tableName = 'application_settings';

  static const String expertModeEnabledKey = 'expert_mode_enabled';

  static const String assessmentDocumentsDirectoryKey =
      'assessment_documents_directory';

  static const String openGeneratedDocumentKey =
      'open_generated_document';


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
      ) => DocumentActivityCoordinator.shared.activity(() async {
    final db = await DatabaseService.database;

    if (key == assessmentDocumentsDirectoryKey) {
      await db.transaction((tx) async {
        final rows = await tx.query(
          _tableName, where: 'setting_key=?', whereArgs: [key],
        );
        final old = rows.isEmpty ? null : rows.single['setting_value'] as String;
        if (old != null && old.trim().isNotEmpty) {
          if (old != value) throw StateError('document_root_migration_required');
          return;
        }
        await tx.insert(
          _tableName,
          {
            'setting_key': key,
            'setting_value': value,
            'updated_at': DateTime.now().millisecondsSinceEpoch,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      });
      return;
    }
    await db.insert(
      _tableName,
      {
        'setting_key': key,
        'setting_value': value,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  });

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

  Future<bool> isOpenGeneratedDocumentEnabled() async {
    return getBool(
      openGeneratedDocumentKey,
      defaultValue: true,
    );
  }

  Future<void> setOpenGeneratedDocumentEnabled(bool enabled) async {
    await setBool(
      openGeneratedDocumentKey,
      enabled,
    );
  }

  Future<void> remove(String key) async {
    if (key == assessmentDocumentsDirectoryKey) {
      throw StateError('document_root_migration_required');
    }
    final db = await DatabaseService.database;

    await db.delete(
      _tableName,
      where: 'setting_key = ?',
      whereArgs: [key],
    );
  }
}
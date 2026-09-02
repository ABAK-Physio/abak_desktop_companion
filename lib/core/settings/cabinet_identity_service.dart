import '../database/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

class CabinetIdentityService {
  const CabinetIdentityService();

  static const _cabinetNameKey = 'cabinet_name';
  static const _cabinetLogoPathKey = 'cabinet_logo_path';
  static const _cabinetAddressLine1Key = 'cabinet_address_line1';
  static const _cabinetAddressLine2Key = 'cabinet_address_line2';
  static const _cabinetPostalCodeKey = 'cabinet_postal_code';
  static const _cabinetCityKey = 'cabinet_city';
  static const _cabinetPhoneKey = 'cabinet_phone';
  static const _cabinetEmailKey = 'cabinet_email';
  static const _organizationIdKey = 'organization_id';

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

  Future<String?> getCabinetAddressLine1() async {
    return _getValue(_cabinetAddressLine1Key);
  }

  Future<void> setCabinetAddressLine1(String value) async {
    await _setOrDeleteTrimmed(
      key: _cabinetAddressLine1Key,
      value: value,
    );
  }

  Future<String?> getCabinetAddressLine2() async {
    return _getValue(_cabinetAddressLine2Key);
  }

  Future<void> setCabinetAddressLine2(String value) async {
    await _setOrDeleteTrimmed(
      key: _cabinetAddressLine2Key,
      value: value,
    );
  }

  Future<String?> getCabinetPostalCode() async {
    return _getValue(_cabinetPostalCodeKey);
  }

  Future<void> setCabinetPostalCode(String value) async {
    await _setOrDeleteTrimmed(
      key: _cabinetPostalCodeKey,
      value: value,
    );
  }

  Future<String?> getCabinetCity() async {
    return _getValue(_cabinetCityKey);
  }

  Future<void> setCabinetCity(String value) async {
    await _setOrDeleteTrimmed(
      key: _cabinetCityKey,
      value: value,
    );
  }

  Future<String?> getCabinetPhone() async {
    return _getValue(_cabinetPhoneKey);
  }

  Future<void> setCabinetPhone(String value) async {
    await _setOrDeleteTrimmed(
      key: _cabinetPhoneKey,
      value: value,
    );
  }

  Future<String?> getCabinetEmail() async {
    return _getValue(_cabinetEmailKey);
  }

  Future<void> setCabinetEmail(String value) async {
    await _setOrDeleteTrimmed(
      key: _cabinetEmailKey,
      value: value,
    );
  }

  Future<void> _setOrDeleteTrimmed({
    required String key,
    required String value,
  }) async {
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      await _deleteValue(key);
    } else {
      await _setValue(key, trimmed);
    }
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

  Future<String> getOrganizationId() async {
    final existing = await _getValue(_organizationIdKey);

    if (existing != null && existing.isNotEmpty) {
      return existing;
    }

    final organizationId = const Uuid().v4();

    await _setValue(_organizationIdKey, organizationId);

    return organizationId;
  }
}

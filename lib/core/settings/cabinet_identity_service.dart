import 'package:shared_preferences/shared_preferences.dart';

class CabinetIdentityService {
  const CabinetIdentityService();

  static const _cabinetNameKey = 'cabinet_name';
  static const _cabinetLogoPathKey = 'cabinet_logo_path';

  Future<String?> getCabinetName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cabinetNameKey);
  }

  Future<void> setCabinetName(String value) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = value.trim();

    if (trimmed.isEmpty) {
      await prefs.remove(_cabinetNameKey);
    } else {
      await prefs.setString(_cabinetNameKey, trimmed);
    }
  }

  Future<String?> getCabinetLogoPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_cabinetLogoPathKey);
  }

  Future<void> setCabinetLogoPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cabinetLogoPathKey, path);
  }

  Future<void> clearCabinetLogoPath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cabinetLogoPathKey);
  }
}
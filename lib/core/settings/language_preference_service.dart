import 'package:abak_shared/abak_shared.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguagePreferenceService {
  const LanguagePreferenceService();

  static const String _languageCodeKey = 'language_code';

  Future<String> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();

    final savedCode = prefs.getString(_languageCodeKey);

    if (savedCode != null && AbakSupportedLanguages.isSupported(savedCode)) {
      return savedCode;
    }

    return AbakSupportedLanguages.defaultCode;
  }

  Future<void> setLanguageCode(String languageCode) async {
    if (!AbakSupportedLanguages.isSupported(languageCode)) {
      throw ArgumentError.value(
        languageCode,
        'languageCode',
        'Unsupported language',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageCodeKey, languageCode);
  }

  Future<void> resetLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_languageCodeKey);
  }
}

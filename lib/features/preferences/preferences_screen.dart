import 'package:abak_shared/abak_shared.dart';
import 'package:flutter/material.dart';

import '../../core/settings/language_preference_service.dart';

class PreferencesScreen extends StatefulWidget {
  final VoidCallback onLanguageChanged;

  const PreferencesScreen({
    super.key,
    required this.onLanguageChanged,
  });

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final LanguagePreferenceService _languageService =
  const LanguagePreferenceService();

  String? _languageCode;
  bool _loading = true;

  static const Map<String, String> _languageLabels = {
    'fr': 'Français',
    'en': 'English',
    'de': 'Deutsch',
    'it': 'Italiano',
    'es': 'Español',
    'pt': 'Português',
    'nl': 'Nederlands',
  };

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final code = await _languageService.getLanguageCode();

    if (!mounted) return;

    setState(() {
      _languageCode = code;
      _loading = false;
    });
  }

  Future<void> _changeLanguage(String? code) async {
    if (code == null) return;

    await _languageService.setLanguageCode(code);

    if (!mounted) return;

    setState(() {
      _languageCode = code;
    });

    widget.onLanguageChanged();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Langue enregistrée. Le changement complet sera appliqué prochainement.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final languageCode =
        _languageCode ?? AbakSupportedLanguages.defaultCode;

    return Center(
      child: SizedBox(
        width: 650,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Paramètres utilisateur',
                  style: TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<String>(
                      initialValue: languageCode,
                      decoration: const InputDecoration(
                        labelText: 'Langue de l’application',
                        border: OutlineInputBorder(),
                      ),
                      items: AbakSupportedLanguages.codes.map((code) {
                        return DropdownMenuItem(
                          value: code,
                          child: Text(_languageLabels[code] ?? code),
                        );
                      }).toList(),
                      onChanged: _loading ? null : _changeLanguage,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
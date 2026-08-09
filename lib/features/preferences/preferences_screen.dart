import '../../generated/l10n.dart';

import 'package:abak_shared/abak_shared.dart';
import 'package:flutter/material.dart';
import '../../core/settings/language_preference_service.dart';
import '../../core/settings/application_settings_service.dart';
import '../patients/services/patient_archive_settings_service.dart';
import '../organization/organization_screen.dart';
import '../../core/expert/expert_context_info.dart';
import '../../core/expert/expert_info_button.dart';

class PreferencesScreen extends StatefulWidget {
  final VoidCallback onLanguageChanged;

  const PreferencesScreen({super.key, required this.onLanguageChanged});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final LanguagePreferenceService _languageService =
      const LanguagePreferenceService();
  final ApplicationSettingsService _applicationSettingsService =
      const ApplicationSettingsService();

  final PatientArchiveSettingsService _archiveSettingsService =
  PatientArchiveSettingsService();

  static const ExpertContextInfo _expertInfo = ExpertContextInfo(
    contextName: 'Paramètres utilisateur',
    sourceFile: 'lib/features/preferences/preferences_screen.dart',
    arbPrefix: 'preferences',
    comment:
    'Cet écran centralise les paramètres généraux de Companion.',
  );

  String? _languageCode;
  int _retentionDays =
      PatientArchiveSettingsService.defaultRetentionDays;

  bool _loading = true;
  bool _expertModeEnabled = false;

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
    _loadPreferences();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final languageCode =
        await _languageService.getLanguageCode();
    final retentionDays =
        await _archiveSettingsService.getRetentionDays();
    final expertModeEnabled =
        await _applicationSettingsService.isExpertModeEnabled();

    if (!mounted) return;

    setState(() {
      _languageCode = languageCode;
      _retentionDays = retentionDays;
      _expertModeEnabled = expertModeEnabled;
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

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Langue enregistrée.')));
  }

  Future<void> _changeRetentionDays(int? days) async {
    if (days == null) return;

    await _archiveSettingsService.setRetentionDays(days);

    if (!mounted) return;

    setState(() {
      _retentionDays = days;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Durée de conservation enregistrée.'),
      ),
    );
  }

  Future<void> _changeExpertMode(bool enabled) async {
    await _applicationSettingsService.setExpertModeEnabled(enabled);

    if (!mounted) return;

    setState(() {
      _expertModeEnabled = enabled;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paramètre du mode Expert enregistré.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final languageCode = _languageCode ?? AbakSupportedLanguages.defaultCode;

    return Center(
      child: SizedBox(
        width: 760,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              shrinkWrap: true,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        S.of(context).user_settings,
                        style: const TextStyle(fontSize: 24),
                      ),
                    ),
                    if (_expertModeEnabled)
                      const ExpertInfoButton(
                        info: _expertInfo,
                      ),
                    ContextHelpButton(
                      title: S.of(context).user_settings,
                      content: S.of(context).help_parametres_utilisateur,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: DropdownButtonFormField<String>(
                      initialValue: languageCode,
                      decoration: InputDecoration(
                        labelText: s.language_choice,
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

                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.archive_outlined),
                            const SizedBox(width: 8),
                            Text(
                              'Patients archivés',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          initialValue: _retentionDays,
                          decoration: const InputDecoration(
                            labelText: 'Durée de conservation',
                            border: OutlineInputBorder(),
                          ),
                          items: PatientArchiveSettingsService.retentionOptions.map((days) {
                            return DropdownMenuItem<int>(
                              value: days,
                              child: Text('$days jours'),
                            );
                          }).toList(),
                          onChanged: _loading ? null : _changeRetentionDays,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Les patients archivés peuvent être restaurés pendant cette durée '
                              'Ils seront ensuite supprimés automatiquement.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                Card(
                  child: SwitchListTile(
                    secondary: const Icon(Icons.developer_mode_outlined),
                    title: const Text('Mode Expert'),
                    subtitle: const Text(
                      'Affiche des informations techniques destinées '
                          'aux développeurs et aux contributeurs.',
                    ),
                    value: _expertModeEnabled,
                    onChanged: _loading ? null : _changeExpertMode,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.business_outlined),
                    title: const Text('Établissement'),
                    subtitle: const Text(
                      'Nom, logo et informations générales.',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const OrganizationScreen(),
                        ),
                      );
                    },
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

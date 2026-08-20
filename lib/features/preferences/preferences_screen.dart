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

  ExpertContextInfo _expertInfo(S s) {
    return ExpertContextInfo(
      contextName: s.preferences_contextName,
      sourceFile: 'lib/features/preferences/preferences_screen.dart',
      arbPrefix: 'preferences',
      comment: s.preferences_contextComment,
    );
  }

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
    final s = S.of(context);
    if (code == null) return;

    await _languageService.setLanguageCode(code);

    if (!mounted) return;

    setState(() {
      _languageCode = code;
    });

    widget.onLanguageChanged();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(s.preferences_languageSaved)));
  }

  Future<void> _changeRetentionDays(int? days) async {
    final s = S.of(context);
    if (days == null) return;

    await _archiveSettingsService.setRetentionDays(days);

    if (!mounted) return;

    setState(() {
      _retentionDays = days;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.preferences_retentionSaved),
      ),
    );
  }

  Future<void> _changeExpertMode(bool enabled) async {
    final s = S.of(context);

    await _applicationSettingsService.setExpertModeEnabled(enabled);

    if (!mounted) return;

    setState(() {
      _expertModeEnabled = enabled;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          s.preferences_expertModeSaved,
        ),
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
                      ExpertInfoButton(
                        info: _expertInfo(s),
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
                              s.preferences_archivedPatients,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<int>(
                          initialValue: _retentionDays,
                          decoration: InputDecoration(
                            labelText: s.preferences_retentionDuration,
                            border: const OutlineInputBorder(),
                          ),
                          items: PatientArchiveSettingsService.retentionOptions.map((days) {
                            return DropdownMenuItem<int>(
                              value: days,
                              child: Text(
                                '$days ${s.preferences_days}',
                              ),
                            );
                          }).toList(),
                          onChanged: _loading ? null : _changeRetentionDays,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          s.preferences_retentionExplanation,
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
                    title: Text(s.preferences_expertMode),
                    subtitle: Text(
                      s.preferences_expertModeDescription,
                    ),
                    value: _expertModeEnabled,
                    onChanged: _loading ? null : _changeExpertMode,
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.business_outlined),
                    title: Text(s.preferences_organization),
                    subtitle: Text(
                      s.preferences_organizationDescription,
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

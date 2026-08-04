import 'dart:io';
import '../../generated/l10n.dart';

import 'package:abak_shared/abak_shared.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/settings/cabinet_identity_service.dart';
import '../../core/settings/language_preference_service.dart';
import '../patients/services/patient_archive_settings_service.dart';

class PreferencesScreen extends StatefulWidget {
  final VoidCallback onLanguageChanged;

  const PreferencesScreen({super.key, required this.onLanguageChanged});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final LanguagePreferenceService _languageService =
      const LanguagePreferenceService();

  final CabinetIdentityService _cabinetIdentityService =
      const CabinetIdentityService();

  final PatientArchiveSettingsService _archiveSettingsService =
  PatientArchiveSettingsService();

  final TextEditingController _cabinetNameController = TextEditingController();

  String? _languageCode;
  String? _cabinetLogoPath;
  int _retentionDays =
      PatientArchiveSettingsService.defaultRetentionDays;

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
    _loadPreferences();
  }

  @override
  void dispose() {
    _cabinetNameController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final languageCode = await _languageService.getLanguageCode();
    final cabinetName = await _cabinetIdentityService.getCabinetName();
    final cabinetLogoPath = await _cabinetIdentityService.getCabinetLogoPath();
    final retentionDays =
        await _archiveSettingsService.getRetentionDays();

    if (!mounted) return;

    setState(() {
      _languageCode = languageCode;
      _cabinetNameController.text = cabinetName ?? '';
      _cabinetLogoPath = cabinetLogoPath;
      _retentionDays = retentionDays;
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

  Future<void> _saveCabinetName() async {
    await _cabinetIdentityService.setCabinetName(_cabinetNameController.text);

    if (!mounted) return;

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Nom du cabinet enregistré.')));
  }

  Future<void> _chooseLogo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    final path = result?.files.single.path;
    if (path == null) return;

    await _cabinetIdentityService.setCabinetLogoPath(path);

    if (!mounted) return;

    setState(() {
      _cabinetLogoPath = path;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logo du cabinet enregistré.')),
    );
  }

  Future<void> _removeLogo() async {
    await _cabinetIdentityService.clearCabinetLogoPath();

    if (!mounted) return;

    setState(() {
      _cabinetLogoPath = null;
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Logo du cabinet supprimé.')));
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
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Identité du cabinet',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _cabinetNameController,
                          decoration: const InputDecoration(
                            labelText: 'Nom du cabinet',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _saveCabinetName(),
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: FilledButton.icon(
                            onPressed: _saveCabinetName,
                            icon: const Icon(Icons.save_outlined),
                            label: const Text('Enregistrer le nom'),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            _LogoPreview(path: _cabinetLogoPath),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Wrap(
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: _chooseLogo,
                                    icon: const Icon(Icons.image_outlined),
                                    label: const Text('Choisir un logo'),
                                  ),
                                  if (_cabinetLogoPath != null)
                                    TextButton.icon(
                                      onPressed: _removeLogo,
                                      icon: const Icon(Icons.delete_outline),
                                      label: const Text('Supprimer le logo'),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
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

class _LogoPreview extends StatelessWidget {
  final String? path;

  const _LogoPreview({required this.path});

  @override
  Widget build(BuildContext context) {
    final logoFile = path == null ? null : File(path!);
    final hasLogo = logoFile != null && logoFile.existsSync();

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: hasLogo
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(logoFile, fit: BoxFit.contain),
            )
          : const Icon(Icons.image_outlined, size: 40),
    );
  }
}

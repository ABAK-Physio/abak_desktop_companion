import 'dart:io';

import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/settings/cabinet_identity_service.dart';
import '../../generated/l10n.dart';
import 'avertissement.dart';
import '../maintenance/models/system_health_snapshot.dart';
import '../maintenance/services/system_health_service.dart';
import '../../core/expert/expert_context_info.dart';
import '../../core/expert/expert_info_button.dart';
import '../../core/settings/application_settings_service.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  ExpertContextInfo _expertInfo(S s) {
    return ExpertContextInfo(
      contextName: s.information_contextName,
      sourceFile: 'lib/features/informations/about.dart',
      arbPrefix: 'information',
      comment: s.information_contextComment,
    );
  }

  final ApplicationSettingsService _applicationSettingsService =
  const ApplicationSettingsService();

  bool _expertModeEnabled = false;

  final CabinetIdentityService _cabinetIdentityService =
      const CabinetIdentityService();

  String _version = '';
  String _platform = '';
  String _language = '';
  String? _cabinetName;
  String? _cabinetLogoPath;
  SystemHealthSnapshot? _health;

  @override
  void initState() {
    super.initState();
    _loadExpertMode();
    _loadVersion();
    _loadCabinetIdentity();
    _loadSystemHealth();
  }

  Future<void> _loadExpertMode() async {
    final expertModeEnabled =
    await _applicationSettingsService.isExpertModeEnabled();

    if (!mounted) return;

    setState(() {
      _expertModeEnabled = expertModeEnabled;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadLanguage();
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes o';

    final kb = bytes / 1024;
    if (kb < 1024) return '${kb.toStringAsFixed(1)} Ko';

    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} Mo';
  }

  Future<void> _loadSystemHealth() async {
    final snapshot = await const SystemHealthService().loadSnapshot();

    if (!mounted) return;

    setState(() {
      _health = snapshot;
    });
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();

    String platform;
    if (Platform.isMacOS) {
      platform = 'macOS';
    } else if (Platform.isWindows) {
      platform = 'Windows';
    } else if (Platform.isLinux) {
      platform = 'Linux';
    } else {
      platform = Platform.operatingSystem;
    }

    if (!mounted) return;

    setState(() {
      _version = info.version;
      _platform = platform;
    });
  }

  Future<void> _loadCabinetIdentity() async {
    final cabinetName = await _cabinetIdentityService.getCabinetName();
    final cabinetLogoPath = await _cabinetIdentityService.getCabinetLogoPath();

    if (!mounted) return;

    setState(() {
      _cabinetName = cabinetName;
      _cabinetLogoPath = cabinetLogoPath;
    });
  }

  void _loadLanguage() {
    final localeCode = Localizations.localeOf(context).languageCode;

    const languageLabels = {
      'fr': 'Français',
      'en': 'English',
      'de': 'Deutsch',
      'it': 'Italiano',
      'es': 'Español',
      'pt': 'Português',
      'nl': 'Nederlands',
    };

    _language = languageLabels[localeCode] ?? localeCode;
  }

  Future<void> _openLicence() async {
    final uri = Uri.parse(
      'https://abak.care/gnu-general-public-license-version-3/',
    );

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {

    final logoFile = _cabinetLogoPath == null ? null : File(_cabinetLogoPath!);
    final hasLogo = logoFile != null && logoFile.existsSync();
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.information_contextName),
        actions: [
          if (_expertModeEnabled)
            ExpertInfoButton(
              info: _expertInfo(s),
            ),
        ],
      ),
      body: Center(
        child: SizedBox(
          width: 700,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _LogoPreview(hasLogo: hasLogo, logoFile: logoFile),
                  const SizedBox(height: 16),
                  const Text(
                    'ABAK Desktop Companion',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _version.isEmpty ? s.information_versionLoading : s.information_version(_version),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 32),

                  _InfoLine(
                    label: s.information_office,
                    value: _cabinetName?.trim().isNotEmpty == true
                        ? _cabinetName!.trim()
                        : s.information_notProvided,
                  ),
                  _InfoLine(
                    label: s.information_logo,
                    value: hasLogo ? s.information_configured : s.information_notConfigured,
                  ),
                  _InfoLine(
                    label: s.information_system,
                    value: _platform.isEmpty ? s.information_loading : _platform,
                  ),
                  _InfoLine(
                    label: s.information_language,
                    value: _language.isEmpty ? s.information_loading : _language,
                  ),

                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),

                  Text(
                    s.information_localStorage,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),

                  const SizedBox(height: 12),

                  if (_health != null) ...[
                    _InfoLine(
                      label: s.information_database,
                      value: s.information_size(_formatFileSize(_health!.databaseSizeBytes)),
                    ),
                    _InfoLine(
                      label: s.information_backups,
                      value:
                      '${s.information_backupCount(_health!.backupsCount)}\n'
                          '${s.information_totalSize(
                        _formatFileSize(_health!.backupsTotalSizeBytes),
                      )}',
                    ),
                  ],

                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 24),

                  OutlinedButton.icon(
                    onPressed: _openLicence,
                    icon: const Icon(Icons.open_in_browser),
                    label:Text(s.information_viewLicense),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const AvertissementScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.gavel_outlined),
                    label: Text(s.information_legalNotice),
                  ),

                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),

                  const Text(
                    '© ABAK Metrics',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoPreview extends StatelessWidget {
  final bool hasLogo;
  final File? logoFile;

  const _LogoPreview({required this.hasLogo, required this.logoFile});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: hasLogo
          ? ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(logoFile!, fit: BoxFit.contain),
            )
          : const Icon(Icons.info_outline, size: 48),
    );
  }
}

class _InfoLine extends StatelessWidget {
  final String label;
  final String value;

  const _InfoLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

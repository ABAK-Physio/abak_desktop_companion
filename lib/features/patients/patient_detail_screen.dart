import '../care_episodes/widgets/care_episodes_panel.dart';
import 'package:flutter/material.dart';
import '../../generated/l10n.dart';
import '../../core/expert/expert_context_info.dart';
import '../../core/expert/expert_info_button.dart';
import '../../core/settings/application_settings_service.dart';

import '../../core/utils/date_format_utils.dart';
import 'models/patient.dart';
import 'data/patient_attribute_repository.dart';
import 'data/patient_identity_repository.dart';
import 'models/patient_attribute.dart';
import 'models/patient_identity.dart';
import 'screens/patient_clinical_data_edit_screen.dart';

import 'package:abak_shared/abak_shared.dart';

import 'data/patient_fr_health_identity_repository.dart';
import 'models/patient_fr_health_identity.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  int _refreshToken = 0;
  bool _expertModeEnabled = false;

  final ApplicationSettingsService _applicationSettingsService =
      const ApplicationSettingsService();

  ExpertContextInfo _expertInfo(S s) {
    return ExpertContextInfo(
      contextName: s.patientDetail_patientInformation,
      sourceFile: 'lib/features/patients/patient_detail_screen.dart',
      arbPrefix: 'patientDetail',
    );
  }

  @override
  void initState() {
    super.initState();
    _loadExpertMode();
  }

  Future<void> _loadExpertMode() async {
    final expertModeEnabled =
        await _applicationSettingsService.isExpertModeEnabled();

    if (!mounted) return;

    setState(() {
      _expertModeEnabled = expertModeEnabled;
    });
  }

  final PatientIdentityRepository _patientIdentityRepository =
      PatientIdentityRepository();

  final PatientAttributeRepository _patientAttributeRepository =
      PatientAttributeRepository();

  final PatientFrHealthIdentityRepository _patientFrHealthIdentityRepository =
  PatientFrHealthIdentityRepository();

  String _formatBirthDate(BuildContext context) {
    final s = S.of(context);
    if (widget.patient.birthDate == null) {
      return s.patientDetail_noBirthdate;
    }

    final birthDate = DateTime.parse(widget.patient.birthDate!);
    final now = DateTime.now();

    var age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    final date = DateFormatUtils.formatIsoDateForDisplay(
      context,
      widget.patient.birthDate,
    );

    return '$date ($age ${s.patientDetail_years})';
  }

  String _formatPatientTitle() {
    return '${widget.patient.lastName.toUpperCase()} ${widget.patient.firstName}';
  }

  void _refresh() {
    setState(() => _refreshToken++);
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final birthDateText = _formatBirthDate(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_formatPatientTitle()),
        actions: [
          if (_expertModeEnabled) ExpertInfoButton(info: _expertInfo(s)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SectionCard(
            title:
                s.patientDetail_patientInformation,
            icon: Icons.person_outline,
            helpContent: S.of(context).help_information_patient,
            children: [
              Wrap(
                spacing: 24,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    '${widget.patient.lastName.toUpperCase()} '
                        '${widget.patient.firstName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${s.patientDetail_bornOn} $birthDateText',
                  ),
                  Text(
                    '${s.patientDetail_sex} : ${widget.patient.sexCode}',
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          _PatientFrHealthIdentitySection(
            repository: _patientFrHealthIdentityRepository,
            patientId: widget.patient.patientId,
            refreshToken: _refreshToken,
          ),
          const SizedBox(height: 16),

          CareEpisodesPanel(
            key: ValueKey(widget.patient.patientId),
            patientId: widget.patient.patientId,
            patientName: _formatPatientTitle(),
          ),

          const SizedBox(height: 16),
          _PatientClinicalDataSection(
            identityRepository: _patientIdentityRepository,
            attributeRepository: _patientAttributeRepository,
            patientId: widget.patient.patientId,
            refreshToken: _refreshToken,
            onRefresh: () {
              setState(() {
                _refreshToken++;
              });
            },
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? helpContent;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    this.helpContent,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (helpContent != null && helpContent!.trim().isNotEmpty) ...[
                    const SizedBox(width: 8),
                    ContextHelpButton(
                      title: title,
                      content: helpContent!,
                    ),
                  ],
                ],
              ),
              const Divider(height: 28),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: SelectableText(value)),
        ],
      ),
    );
  }
}

class _PatientFrHealthIdentitySection extends StatelessWidget {
  final PatientFrHealthIdentityRepository repository;
  final String patientId;
  final int refreshToken;

  const _PatientFrHealthIdentitySection({
    required this.repository,
    required this.patientId,
    required this.refreshToken,
  });

  String _statusLabel(
      PatientFrHealthIdentity? identity,
      S s,
      ) {
    switch (identity?.identityStatus) {
      case 'retrieved':
        return s.patientDetail_retrieved;
      case 'validated':
        return s.patientDetail_validated;
      case 'qualified':
        return s.patientDetail_qualified;
      case 'provisional':
      default:
        return s.patientDetail_provisional;
    }
  }

  String _statusDescription(PatientFrHealthIdentity? identity) {
    switch (identity?.identityStatus) {
      case 'retrieved':
        return 'INS obtenue, identité à contrôler';
      case 'validated':
        return 'Identité contrôlée, INS à rechercher';
      case 'qualified':
        return 'Identité conforme';
      case 'provisional':
      default:
        return 'Identité à compléter';
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return FutureBuilder<PatientFrHealthIdentity?>(
      key: ValueKey('patient-fr-health-identity-$refreshToken'),
      future: repository.getByPatientId(patientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _SectionCard(
            title: s.patientDetail_frHealthIdentity,
            icon: Icons.badge_outlined,
            children: [
              Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              ),
            ],
          );
        }

        if (snapshot.hasError) {
          return _SectionCard(
            title: s.patientDetail_frHealthIdentity,
            icon: Icons.badge_outlined,
            children: [
              Text('Erreur : ${snapshot.error}'),
            ],
          );
        }

        final identity = snapshot.data;

        return _SectionCard(
          title: s.patientDetail_frHealthIdentity,
          icon: Icons.badge_outlined,
          children: [
            _InfoRow(
              label: s.patientDetail_status,
              value: _statusLabel(identity, s),
            ),
            _InfoRow(
              label: s.patientDetail_state,
              value: _statusDescription(identity),
            ),
          ],
        );
      },
    );
  }
}

class _PatientClinicalDataSection extends StatelessWidget {
  final PatientIdentityRepository identityRepository;
  final PatientAttributeRepository attributeRepository;
  final String patientId;
  final int refreshToken;
  final VoidCallback onRefresh;

  const _PatientClinicalDataSection({
    required this.identityRepository,
    required this.attributeRepository,
    required this.patientId,
    required this.refreshToken,
    required this.onRefresh,
  });

  String _attributeValue(List<PatientAttribute> attributes,
      String key,
      S s,
      ) {
    final matching = attributes.where((a) => a.attributeKey == key);

    if (matching.isEmpty) {
      return s.patientDetail_notProvided;
    }

    return matching.first.attributeValue?.trim().isNotEmpty == true
        ? matching.first.attributeValue!
        : s.patientDetail_notProvided;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return FutureBuilder<_PatientClinicalData>(
      key: ValueKey('patient-clinical-$refreshToken'),
      future: _loadData(),
      builder: (context, snapshot) {
        final data = snapshot.data;

        return _SectionCard(
          title: s.patientDetail_patientInformation,
          icon: Icons.person_outline,
          helpContent: s.help_information_patient,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final changed = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) =>
                          PatientClinicalDataEditScreen(patientId: patientId),
                    ),
                  );

                  if (changed == true && context.mounted) {
                    final state = context
                        .findAncestorStateOfType<_PatientDetailScreenState>();

                    state?._refresh();
                  }
                },
                icon: const Icon(Icons.edit_outlined),
                label: Text(s.patientDetail_editClinicalData),
              ),
            ),
            const SizedBox(height: 16),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else if (snapshot.hasError)
              Text(
                '${s.patientDetail_error} : ${snapshot.error}',
              )
            else ...[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: _ClinicalDataColumn(
                      title: s.patientDetail_administrativeIdentity,
                      children: [
                        _InfoRow(
                          label: s.patientDetail_nationalIdentifier,
                          value:
                              data?.identity?.nationalHealthId ??
                              s.patientDetail_notProvided,
                        ),
                        _InfoRow(
                          label: s.patientDetail_healthSystemCountry,
                          value:
                              data?.identity?.healthSystemCountry ??
                              s.patientDetail_notProvided,
                        ),
                        _InfoRow(
                          label: s.patientDetail_identitySource,
                          value:
                              data?.identity?.identitySource ?? s.patientDetail_notProvided,
                        ),
                        _InfoRow(
                          label: 'Téléphone',
                          value: data?.identity?.phone ?? s.patientDetail_notProvided,
                        ),
                        _InfoRow(
                          label: 'Email',
                          value: data?.identity?.email ?? s.patientDetail_notProvided,
                        ),
                        _InfoRow(
                          label: 'Adresse',
                          value: data?.identity?.address ?? s.patientDetail_notProvided,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 32),
                  Expanded(
                    child: _ClinicalDataColumn(
                      title: s.patientDetail_patientProfile,
                      children: [
                        _InfoRow(
                          label: s.patientDetail_dominantSide,
                          value: _attributeValue(
                            data?.attributes ?? [],
                            'dominant_side',
                            s,
                          ),
                        ),
                        _InfoRow(
                          label: s.patientDetail_profession,
                          value: _attributeValue(
                            data?.attributes ?? [],
                            'profession',
                            s,
                          ),
                        ),
                        _InfoRow(
                          label: s.patientDetail_sportActivity,
                          value: _attributeValue(
                            data?.attributes ?? [],
                            'sport',
                            s,
                          ),
                        ),
                        _InfoRow(
                          label: s.patientDetail_height,
                          value: _attributeValue(
                            data?.attributes ?? [],
                            'height_cm',
                            s,
                          ),
                        ),
                        _InfoRow(
                          label: s.patientDetail_weight,
                          value: _attributeValue(
                            data?.attributes ?? [],
                            'weight_kg',
                            s,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ],
        );
      },
    );
  }

  Future<_PatientClinicalData> _loadData() async {
    final identity = await identityRepository.getByPatientId(patientId);
    final attributes = await attributeRepository.getByPatientId(patientId);

    return _PatientClinicalData(identity: identity, attributes: attributes);
  }
}

class _ClinicalDataColumn extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _ClinicalDataColumn({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}

class _PatientClinicalData {
  final PatientIdentity? identity;
  final List<PatientAttribute> attributes;

  const _PatientClinicalData({
    required this.identity,
    required this.attributes,
  });
}

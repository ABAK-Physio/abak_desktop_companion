import 'widgets/patient_documents_card.dart';
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
import 'data/patient_repository.dart';
import 'screens/patient_qualification_screen.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailScreen({super.key, required this.patient});

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  int _refreshToken = 0;
  Patient? _updatedPatient;
  Patient get _patient => _updatedPatient ?? widget.patient;
  final _identityOpening = ValueNotifier<bool>(false);
  final _identityOpenError = ValueNotifier<String?>(null);
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

  @override
  void dispose() {
    _identityOpening.dispose();
    _identityOpenError.dispose();
    super.dispose();
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
    if (_patient.birthDate == null) {
      return s.patientDetail_noBirthdate;
    }

    final birthDate = DateTime.parse(_patient.birthDate!);
    final now = DateTime.now();

    var age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    final date = DateFormatUtils.formatIsoDateForDisplay(
      context,
      _patient.birthDate,
    );

    return '$date ($age ${s.patientDetail_years})';
  }

  String _formatPatientTitle() {
    return '${_patient.lastName.toUpperCase()} ${_patient.firstName}';
  }

  void _refresh() {
    setState(() => _refreshToken++);
  }

  Future<void> _openIdentity() async {
    if (_identityOpening.value) return;
    _identityOpenError.value = null;
    _identityOpening.value = true;
    final patientId = _patient.patientId;
    try {
      await Navigator.of(context).push<bool>(MaterialPageRoute<bool>(
        settings: const RouteSettings(name: '/patient/identity'),
        builder: (_) => PatientQualificationScreen(patientId: patientId),
      ));
    } catch (error, stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stack,
        library: 'ABAK — ouverture de la fiche d’identité',
      ));
      if (mounted) {
        _identityOpenError.value =
            'Impossible d’ouvrir la fiche d’identité. Fermez puis rouvrez '
            'la fiche patient. Si le problème persiste, signalez ce message '
            'à l’assistance (IDENTITE-OUVERTURE).';
      }
      return;
    } finally {
      if (mounted) _identityOpening.value = false;
    }
    if (!mounted) return;
    try {
      final patient = await PatientRepository().getPatientById(patientId);
      if (mounted) setState(() { _updatedPatient = patient; _refreshToken++; });
    } catch (_) {
      if (mounted) {
        _identityOpenError.value =
            'La fiche patient n’a pas pu être actualisée. Fermez puis rouvrez cette fiche.';
      }
    }
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
                    '${_patient.lastName.toUpperCase()} '
                        '${_patient.firstName}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${s.patientDetail_bornOn} $birthDateText',
                  ),
                  Text(
                    '${s.patientDetail_sex} : ${_patient.sexCode}',
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          _PatientFrHealthIdentitySection(
            repository: _patientFrHealthIdentityRepository,
            onEdit: _openIdentity,
            opening: _identityOpening,
            openingError: _identityOpenError,
            patientId: _patient.patientId,
            refreshToken: _refreshToken,
          ),
          const SizedBox(height: 16),

          PatientDocumentsCard(patientId: _patient.patientId),
          const SizedBox(height: 16),

          CareEpisodesPanel(
            key: ValueKey(_patient.patientId),
            patientId: _patient.patientId,
            patientName: _formatPatientTitle(),
          ),

          const SizedBox(height: 16),
          _PatientClinicalDataSection(
            identityRepository: _patientIdentityRepository,
            attributeRepository: _patientAttributeRepository,
            patientId: _patient.patientId,
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
                      technicalInformationLabel: S.of(context).g_helpTooltip,
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

class _PatientFrHealthIdentitySection extends StatefulWidget {
  final PatientFrHealthIdentityRepository repository;
  final String patientId;
  final int refreshToken;
  final VoidCallback onEdit;
  final ValueNotifier<bool> opening;
  final ValueNotifier<String?> openingError;

  const _PatientFrHealthIdentitySection({
    required this.repository,
    required this.patientId,
    required this.refreshToken,
    required this.onEdit,
    required this.opening,
    required this.openingError,
  });

  @override
  State<_PatientFrHealthIdentitySection> createState() =>
      _PatientFrHealthIdentitySectionState();
}

class _PatientFrHealthIdentitySectionState
    extends State<_PatientFrHealthIdentitySection> {
  late Future<PatientFrHealthIdentity?> _identity;

  @override
  void initState() {
    super.initState();
    _loadIdentity();
  }

  @override
  void didUpdateWidget(covariant _PatientFrHealthIdentitySection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patientId != widget.patientId ||
        oldWidget.refreshToken != widget.refreshToken ||
        oldWidget.repository != widget.repository) {
      _loadIdentity();
    }
  }

  void _loadIdentity() {
    // Keep the button mounted during incidental parent/theme/focus rebuilds.
    // Refresh only when the patient changes or the identity form returns.
    _identity = widget.repository.getByPatientId(widget.patientId);
  }

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
        return 'Identité contrôlée et INS concordante';
      case 'provisional':
      default:
        return 'Identité à compléter';
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return FutureBuilder<PatientFrHealthIdentity?>(
      future: _identity,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _SectionCard(
            title: 'Identité et qualification',
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
            title: 'Identité et qualification',
            icon: Icons.badge_outlined,
            children: [
              Text('Erreur : ${snapshot.error}'),
            ],
          );
        }

        final identity = snapshot.data;

        return _SectionCard(
          title: 'Identité et qualification',
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
            const SizedBox(height: 12),
            ValueListenableBuilder<bool>(
              valueListenable: widget.opening,
              builder: (context, busy, _) => OutlinedButton.icon(
                onPressed: busy ? null : widget.onEdit,
                icon: const Icon(Icons.badge_outlined),
                label: Text(busy ? 'Ouverture…' : 'Compléter l’identité et ses justificatifs'),
              ),
            ),
            ValueListenableBuilder<String?>(
              valueListenable: widget.openingError,
              builder: (context, message, _) => message == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(message,
                        style: TextStyle(color: Theme.of(context).colorScheme.error)),
                    ),
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

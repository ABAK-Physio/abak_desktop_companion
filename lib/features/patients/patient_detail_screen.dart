import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../generated/l10n.dart';
import '../care_episodes/data/care_episode_referring_practitioner_repository.dart';
import '../practitioners/widgets/practitioner_selector.dart';

import '../../core/utils/date_format_utils.dart';
import 'models/patient.dart';
import 'data/patient_attribute_repository.dart';
import 'data/patient_identity_repository.dart';
import 'models/patient_attribute.dart';
import 'models/patient_identity.dart';
import 'screens/patient_clinical_data_edit_screen.dart';
import '../care_episodes/data/care_episode_repository.dart';
import '../care_episodes/models/care_episode.dart';

import '../care_episodes/models/care_episode_summary.dart';
import 'package:abak_shared/abak_shared.dart';
import '../care_episodes/screens/care_episode_reports_workspace_screen.dart';
import '../results/data/desktop_result_repository.dart';

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

  final PatientIdentityRepository _patientIdentityRepository =
      PatientIdentityRepository();

  final PatientAttributeRepository _patientAttributeRepository =
      PatientAttributeRepository();

  final PatientFrHealthIdentityRepository _patientFrHealthIdentityRepository =
  PatientFrHealthIdentityRepository();

  final CareEpisodeRepository _careEpisodeRepository = CareEpisodeRepository();

  final CareEpisodeReferringPractitionerRepository
  _referringPractitionerRepository =
  CareEpisodeReferringPractitionerRepository();

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

  Future<void> _editCareEpisode(CareEpisode episode) async {
    final s = S.of(context);
    final currentAssignment = await _referringPractitionerRepository
        .getCurrentReferringPractitioner(episode.careEpisodeId);

    if (!mounted) return;

    String? selectedPractitionerId = currentAssignment?.practitionerId;

    final pathologyController = TextEditingController(
      text: episode.pathologyLabel,
    );
    final initialReportController = TextEditingController(
      text: episode.initialReport ?? '',
    );

    final updated = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(s.patientDetail_editCareEpisode),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pathologyController,
                  decoration: InputDecoration(
                    labelText: s.patientDetail_pathology,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: initialReportController,
                  decoration: InputDecoration(
                    labelText: s.patientDetail_initialReport,
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  minLines: 5,
                  maxLines: 10,
                ),
                const SizedBox(height: 16),
                PractitionerSelector(
                  label: s.patientDetail_referringPractitioner,
                  selectedPractitionerId: selectedPractitionerId,
                  allowEmpty: true,
                  onChanged: (practitionerId) {
                    selectedPractitionerId = practitionerId;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(s.patientDetail_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(s.patientDetail_save),
            ),
          ],
        );
      },
    );

    final pathology = pathologyController.text.trim();
    final initialReport = initialReportController.text.trim();

    pathologyController.dispose();
    initialReportController.dispose();

    if (updated != true || pathology.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    final updatedEpisode = CareEpisode(
      careEpisodeId: episode.careEpisodeId,
      patientId: episode.patientId,
      title: episode.title,
      pathologyLabel: pathology,
      initialReport: initialReport.isEmpty ? null : initialReport,
      openedAt: episode.openedAt,
      createdAt: episode.createdAt,
      updatedAt: now,
      archivedAt: episode.archivedAt,
    );

    await _careEpisodeRepository.updateCareEpisode(updatedEpisode);

    final previousPractitionerId = currentAssignment?.practitionerId;

    if (selectedPractitionerId == null) {
      if (previousPractitionerId != null) {
        await _referringPractitionerRepository
            .clearCurrentReferringPractitioner(episode.careEpisodeId);
      }
    } else if (selectedPractitionerId != previousPractitionerId) {
      await _referringPractitionerRepository.changeReferringPractitioner(
        careEpisodeId: episode.careEpisodeId,
        practitionerId: selectedPractitionerId!,
      );
    }

    if (!mounted) return;

    setState(() {
      _refreshToken++;
    });
  }

  void _refresh() {
    setState(() {
      _refreshToken++;
    });
  }

  Future<void> _createCareEpisode() async {
    final s = S.of(context);
    final pathologyController = TextEditingController();
    final initialReportController = TextEditingController();

    String? selectedPractitionerId;

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(s.patientDetail_newCareEpisode),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pathologyController,
                  decoration: InputDecoration(
                    labelText: s.patientDetail_pathology,
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: initialReportController,
                  decoration: InputDecoration(
                    labelText: s.patientDetail_initialReport,
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  minLines: 5,
                  maxLines: 10,
                ),
                const SizedBox(height: 16),
                PractitionerSelector(
                  label: s.patientDetail_referringPractitioner,
                  selectedPractitionerId: selectedPractitionerId,
                  allowEmpty: true,
                  onChanged: (practitionerId) {
                    selectedPractitionerId = practitionerId;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(s.patientDetail_cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(s.patientDetail_create),
            ),
          ],
        );
      },
    );

    final pathology = pathologyController.text.trim();
    final initialReport = initialReportController.text.trim();

    pathologyController.dispose();
    initialReportController.dispose();

    if (created != true || pathology.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final date = DateTime.now();
    final monthYear = '${date.month.toString().padLeft(2, '0')}/${date.year}';

    final episode = CareEpisode(
      careEpisodeId: const Uuid().v4(),
      patientId: widget.patient.patientId,
      title: '${s.patientDetail_careEpisodeOpenedIn} $monthYear',
      pathologyLabel: pathology,
      initialReport: initialReport.isEmpty ? null : initialReport,
      openedAt: now,
      createdAt: now,
    );

    await _careEpisodeRepository.insertCareEpisode(episode);

    if (selectedPractitionerId != null) {
      await _referringPractitionerRepository.changeReferringPractitioner(
        careEpisodeId: episode.careEpisodeId,
        practitionerId: selectedPractitionerId!,
      );
    }

    if (!mounted) return;

    setState(() {
      _refreshToken++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final birthDateText = _formatBirthDate(context);

    return Scaffold(
      appBar: AppBar(title: Text(_formatPatientTitle())),
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

          _CareEpisodesSection(
            repository: _careEpisodeRepository,
            patientId: widget.patient.patientId,
            patientName: _formatPatientTitle(),
            refreshToken: _refreshToken,
            onCreateCareEpisode: _createCareEpisode,
            onEditCareEpisode: _editCareEpisode,
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

class _EmptySectionMessage extends StatelessWidget {
  final String text;

  const _EmptySectionMessage({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
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

class _CareEpisodesSection extends StatelessWidget {
  final CareEpisodeRepository repository;
  final String patientId;
  final int refreshToken;
  final VoidCallback onCreateCareEpisode;
  final ValueChanged<CareEpisode> onEditCareEpisode;
  final String patientName;

  const _CareEpisodesSection({
    required this.repository,
    required this.patientId,
    required this.refreshToken,
    required this.onCreateCareEpisode,
    required this.onEditCareEpisode,
    required this.patientName,
  });

  String _referringPractitionerLabel(
      CareEpisodeSummary summary,
      S s,
      ) {
    final name = summary.referringPractitionerDisplayName?.trim();

    if (name == null || name.isEmpty) {
      return s.patientDetail_notProvided;
    }

    if (summary.referringPractitionerArchived) {
      return '$name — ${s.patientDetail_archived}';
    }

    return name;
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return FutureBuilder<List<CareEpisodeSummary>>(
      key: ValueKey('care-episodes-$refreshToken'),
      future: repository.getEpisodeSummariesForPatient(patientId),
      builder: (context, snapshot) {
        final summaries = snapshot.data ?? [];

        return _SectionCard(
          title: 'Prises en charge',
          icon: Icons.folder_special_outlined,
          helpContent: S.of(context).help_prise_en_charge,
          children: [
            OutlinedButton.icon(
              onPressed: onCreateCareEpisode,
              icon: const Icon(Icons.add),
              label: const Text('Nouvelle prise en charge'),
            ),
            const SizedBox(height: 16),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else if (summaries.isEmpty)
              const _EmptySectionMessage(
                text: 'Aucune prise en charge créée pour ce patient.',
              )
            else
              ...summaries.map((summary) {
                final episode = summary.episode;

                final createdAt = DateTime.fromMillisecondsSinceEpoch(
                  episode.createdAt,
                );

                final monthYear = DateFormatUtils.formatMonthYear(
                  context,
                  createdAt,
                );

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.folder_open_outlined),
                  title: Text('Prise en charge ouverte en $monthYear'),
                  subtitle: Text(
                    [
                      '${s.patientDetail_pathology} : ${episode.pathologyLabel}',
                      '${s.patientDetail_referringPractitioner} : '
                          '${_referringPractitionerLabel(summary, s)}',
                    ].join('\n'),
                  ),
                  trailing: IconButton(
                    tooltip: 'Modifier',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => onEditCareEpisode(episode),
                  ),
                  onTap: () async {
                    await Navigator.of(context).push<void>(
                      MaterialPageRoute(
                        builder: (_) => CareEpisodeReportsWorkspaceScreen(
                          episode: episode,
                          patientName: patientName,
                          resultRepository: DesktopResultRepository(),
                        ),
                      ),
                    );

                    if (context.mounted) {
                      final state = context
                          .findAncestorStateOfType<_PatientDetailScreenState>();

                      state?._refresh();
                    }
                  },
                );
              }),
          ],
        );
      },
    );
  }
}

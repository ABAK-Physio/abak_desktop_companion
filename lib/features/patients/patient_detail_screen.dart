import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/date_format_utils.dart';
import 'models/patient.dart';
import 'data/patient_attribute_repository.dart';
import 'data/patient_identity_repository.dart';
import 'models/patient_attribute.dart';
import 'models/patient_identity.dart';
import 'screens/patient_clinical_data_edit_screen.dart';
import '../care_episodes/data/care_episode_repository.dart';
import '../care_episodes/models/care_episode.dart';
import '../care_episodes/screens/care_episode_detail_screen.dart';
import '../care_episodes/models/care_episode_summary.dart';

class PatientDetailScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailScreen({
    super.key,
    required this.patient,
  });

  @override
  State<PatientDetailScreen> createState() => _PatientDetailScreenState();
}

class _PatientDetailScreenState extends State<PatientDetailScreen> {
  int _refreshToken = 0;

  final PatientIdentityRepository _patientIdentityRepository =
  PatientIdentityRepository();

  final PatientAttributeRepository _patientAttributeRepository =
  PatientAttributeRepository();


  final CareEpisodeRepository _careEpisodeRepository =
  CareEpisodeRepository();

  Future<void> _editCareEpisode(CareEpisode episode) async {
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
          title: const Text('Modifier la prise en charge'),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pathologyController,
                  decoration: const InputDecoration(
                    labelText: 'Pathologie',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: initialReportController,
                  decoration: const InputDecoration(
                    labelText: 'Compte rendu initial',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  minLines: 5,
                  maxLines: 10,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Enregistrer'),
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
      createdAt: episode.createdAt,
      updatedAt: now,
      archivedAt: episode.archivedAt,
    );

    await _careEpisodeRepository.updateCareEpisode(updatedEpisode);

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
    final pathologyController = TextEditingController();
    final initialReportController = TextEditingController();

    final created = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Nouvelle prise en charge'),
          content: SizedBox(
            width: 520,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: pathologyController,
                  decoration: const InputDecoration(
                    labelText: 'Pathologie',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: initialReportController,
                  decoration: const InputDecoration(
                    labelText: 'Compte rendu initial',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  minLines: 5,
                  maxLines: 10,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Créer'),
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
    final monthYear =
        '${date.month.toString().padLeft(2, '0')}/${date.year}';

    final episode = CareEpisode(
      careEpisodeId: const Uuid().v4(),
      patientId: widget.patient.patientId,
      title: 'Prise en charge $monthYear - $pathology',
      pathologyLabel: pathology,
      initialReport: initialReport.isEmpty ? null : initialReport,
      createdAt: now,
    );

    await _careEpisodeRepository.insertCareEpisode(episode);

    if (!mounted) return;

    setState(() {
      _refreshToken++;
    });
  }


  @override
  Widget build(BuildContext context) {
    final birthDateText = widget.patient.birthDate == null
        ? 'Non renseignée'
        : DateFormatUtils.formatIsoDateForDisplay(context, widget.patient.birthDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patient.displayName),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SectionCard(
            title: 'Informations patient',
            icon: Icons.person_outline,
            children: [
              _InfoRow(label: 'Nom', value: widget.patient.lastName),
              _InfoRow(label: 'Prénom', value: widget.patient.firstName),
              _InfoRow(label: 'Date de naissance', value: birthDateText),
              _InfoRow(label: 'Sexe', value: widget.patient.sexCode),
              _InfoRow(label: 'Identifiant local', value: widget.patient.patientId),
              const SizedBox(height: 16),
            ],
          ),

          const SizedBox(height: 16),
          _CareEpisodesSection(
            repository: _careEpisodeRepository,
            patientId: widget.patient.patientId,
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
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
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
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
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

  const _InfoRow({
    required this.label,
    required this.value,
  });

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

  const _EmptySectionMessage({
    required this.text,
  });

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

  String _attributeValue(
      List<PatientAttribute> attributes,
      String key,
      ) {
    final matching = attributes.where((a) => a.attributeKey == key);

    if (matching.isEmpty) {
      return 'Non renseigné';
    }

    return matching.first.attributeValue?.trim().isNotEmpty == true
        ? matching.first.attributeValue!
        : 'Non renseigné';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_PatientClinicalData>(
      key: ValueKey('patient-clinical-$refreshToken'),
      future: _loadData(),
      builder: (context, snapshot) {
        final data = snapshot.data;

        return _SectionCard(
          title: 'Données cliniques patient',
          icon: Icons.assignment_ind_outlined,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final changed = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => PatientClinicalDataEditScreen(
                        patientId: patientId,
                      ),
                    ),
                  );

                  if (changed == true && context.mounted) {
                    final state = context.findAncestorStateOfType<_PatientDetailScreenState>();

                    state?._refresh();
                  }
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Modifier les données cliniques'),
              ),
            ),
            const SizedBox(height: 16),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else if (snapshot.hasError)
              Text('Erreur : ${snapshot.error}')
            else ...[
                Text(
                  'Identité administrative',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: 'Identifiant national',
                  value: data?.identity?.nationalHealthId ?? 'Non renseigné',
                ),
                _InfoRow(
                  label: 'Pays système santé',
                  value: data?.identity?.healthSystemCountry ?? 'Non renseigné',
                ),
                _InfoRow(
                  label: 'Source identité',
                  value: data?.identity?.identitySource ?? 'Non renseigné',
                ),
                _InfoRow(
                  label: 'Téléphone',
                  value: data?.identity?.phone ?? 'Non renseigné',
                ),
                _InfoRow(
                  label: 'Email',
                  value: data?.identity?.email ?? 'Non renseigné',
                ),
                _InfoRow(
                  label: 'Adresse',
                  value: data?.identity?.address ?? 'Non renseigné',
                ),
                const SizedBox(height: 16),
                Text(
                  'Profil patient',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: 'Côté dominant',
                  value: _attributeValue(
                    data?.attributes ?? [],
                    'dominant_side',
                  ),
                ),
                _InfoRow(
                  label: 'Profession',
                  value: _attributeValue(
                    data?.attributes ?? [],
                    'profession',
                  ),
                ),
                _InfoRow(
                  label: 'Activité sportive',
                  value: _attributeValue(
                    data?.attributes ?? [],
                    'sport',
                  ),
                ),
                _InfoRow(
                  label: 'Taille',
                  value: _attributeValue(
                    data?.attributes ?? [],
                    'height_cm',
                  ),
                ),
                _InfoRow(
                  label: 'Poids',
                  value: _attributeValue(
                    data?.attributes ?? [],
                    'weight_kg',
                  ),
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

    return _PatientClinicalData(
      identity: identity,
      attributes: attributes,
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

  const _CareEpisodesSection({
    required this.repository,
    required this.patientId,
    required this.refreshToken,
    required this.onCreateCareEpisode,
    required this.onEditCareEpisode,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<CareEpisodeSummary>>(
      key: ValueKey('care-episodes-$refreshToken'),
      future: repository.getEpisodeSummariesForPatient(patientId),
      builder: (context, snapshot) {
        final summaries = snapshot.data ?? [];

        return _SectionCard(
          title: 'Prises en charge',
          icon: Icons.folder_special_outlined,
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

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.folder_open_outlined),
                  title: Text(episode.displayTitle),
                  subtitle: Text(
                    [
                      'Pathologie : ${episode.pathologyLabel}',
                      '${summary.notesCount} note${summary.notesCount > 1 ? 's' : ''} de suivi',
                      summary.hasConclusion
                          ? 'Conclusion rédigée'
                          : 'Conclusion absente',
                    ].join('\n'),
                  ),
                  trailing: IconButton(
                    tooltip: 'Modifier',
                    icon: const Icon(Icons.edit_outlined),
                    onPressed: () => onEditCareEpisode(episode),
                  ),
                  onTap: () async {
                    final changed = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => CareEpisodeDetailScreen(
                          episode: episode,
                        ),
                      ),
                    );

                    if (changed == true && context.mounted) {
                      final state = context.findAncestorStateOfType<_PatientDetailScreenState>();

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

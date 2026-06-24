import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

import '../../core/utils/date_format_utils.dart';
import 'models/patient.dart';
import '../results/data/desktop_result_repository.dart';
import '../results/models/desktop_result.dart';
import '../results/models/desktop_result_metric.dart';
import '../results/result_detail_screen.dart';
import '../import_export/import_history_screen.dart';
import '../import_export/abak_export_service.dart';
import '../import_export/abak_file_export_service.dart';
import '../import_export/data/mobile_case_repository.dart';
import '../import_export/models/mobile_case.dart';
import '../import_export/abak_import_launcher.dart';
import 'data/patient_attribute_repository.dart';
import 'data/patient_identity_repository.dart';
import 'models/patient_attribute.dart';
import 'models/patient_identity.dart';
import 'screens/patient_clinical_data_edit_screen.dart';
import 'screens/episode_dashboard_screen.dart';
import '../clinical_episodes/data/desktop_clinical_episode_repository.dart';
import '../clinical_episodes/models/desktop_clinical_episode.dart';
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
  final DesktopResultRepository _resultRepository =
  DesktopResultRepository();

  int _refreshToken = 0;
  String _syncFilter = 'all';

  final MobileCaseRepository _mobileCaseRepository =
  MobileCaseRepository();

  final PatientIdentityRepository _patientIdentityRepository =
  PatientIdentityRepository();

  final PatientAttributeRepository _patientAttributeRepository =
  PatientAttributeRepository();

  final DesktopClinicalEpisodeRepository _clinicalEpisodeRepository =
  DesktopClinicalEpisodeRepository();

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

  Future<void> _exportPatientAbakPackage() async {
    try {
      final exportService = AbakExportService();
      final fileExportService = AbakFileExportService();

      final json = await exportService.exportPatientPackageJson(
        patient: widget.patient,
      );

      debugPrint('🧪 Export JSON length = ${json.length}');
      debugPrint('🧪 Export JSON preview = ${json.substring(0, json.length > 500 ? 500 : json.length)}');

      final path = await fileExportService.savePackageJson(
        json: json,
        suggestedFileName:
        'abak_${widget.patient.lastName}_${widget.patient.firstName}',
      );

      debugPrint('🧪 Export path = $path');

      if (path == null) {
        return;
      }

      final exists = await File(path).exists();

      if (!mounted) return;

      final messenger = ScaffoldMessenger.of(context);

      messenger.showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 10),
          content: Text(
            exists
                ? 'Package ABAK exporté : $path'
                : 'Export terminé mais fichier introuvable : $path',
          ),
        ),
      );

    } catch (e, stack) {
      debugPrint('❌ Erreur export ABAK : $e');
      debugPrint('$stack');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          duration: const Duration(seconds: 10),
          content: Text('Erreur export ABAK : $e'),
        ),
      );
    }
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

  Future<void> _addSimulatedResult() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final resultId = const Uuid().v4();

    final result = DesktopResult(
      resultId: resultId,
      patientId: widget.patient.patientId,
      createdAt: now,
      importedAt: now,
      exoId: 'E3',
      scoreTotal: 8.4,
      measureUnit: 's',
      exportSimpleText: 'Test simulé ABAK Desktop\nE3 : 8.4 s',
      practitionerLabelSnapshot: 'Kiné simulé',
      localSchemaVersion: 1,
    );

    final metrics = [
      DesktopResultMetric(
        metricId: const Uuid().v4(),
        resultId: resultId,
        metricKey: 'mean_time_s',
        value: 8.4,
        unit: 's',
        label: 'Temps moyen',
      ),
    ];

    await _resultRepository.insertResultWithMetrics(
      result: result,
      metrics: metrics,
    );

    setState(() {
      _refreshToken++;
    });
  }

  void refreshResults() {
    setState(() {
      _refreshToken++;
    });
  }

  Future<void> _importTestPackage() async {
    await AbakImportLauncher.importArchiveFromPicker(
      context,
      onImportCompleted: () {
        setState(() {
          _refreshToken++;
        });
      },
    );
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
              _MobileCasesSection(
                repository: _mobileCaseRepository,
                patientId: widget.patient.patientId,
                refreshToken: _refreshToken,
                patientDisplayName: widget.patient.displayName,
              ),
              const SizedBox(height: 16),
              _ClinicalEpisodesSection(
                repository: _clinicalEpisodeRepository,
                patientId: widget.patient.patientId,
                refreshToken: _refreshToken,
              ),
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
            onRefresh: refreshResults,
          ),

          const SizedBox(height: 16),
          const _SectionCard(
            title: 'Rapports ABAK archivés',
            icon: Icons.folder_outlined,
            children: [
              _EmptySectionMessage(
                text: 'Aucun rapport archivé pour ce patient.',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _FutureResultsSection(
            repository: _resultRepository,
            patientId: widget.patient.patientId,
            refreshToken: _refreshToken,
            onAddSimulatedResult: _addSimulatedResult,
            onImportTestPackage: _importTestPackage,
            syncFilter: _syncFilter,
            onSyncFilterChanged: (value) {
              setState(() {
                _syncFilter = value;
              });
            },
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Actions',
            icon: Icons.sync_alt_outlined,
            children: [
              OutlinedButton.icon(
                onPressed: _importTestPackage,
                icon: const Icon(Icons.file_upload_outlined),
                label: const Text('Importer une archive ABAK'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _exportPatientAbakPackage,
                icon: const Icon(Icons.download_outlined),
                label: const Text('Exporter une archive ABAK'),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ImportHistoryScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.history_outlined),
                label: const Text('Historique des imports'),
              ),
              const SizedBox(height: 8),
              const _ActionPlaceholder(
                icon: Icons.phone_android_outlined,
                label: 'Préparer un dossier pour téléphone',
              ),
            ],
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

class _ActionPlaceholder extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ActionPlaceholder({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: null,
      icon: Icon(icon),
      label: Text(label),
    );
  }
}

class _FutureResultsSection extends StatelessWidget {
  final DesktopResultRepository repository;
  final String patientId;
  final int refreshToken;
  final String syncFilter;
  final ValueChanged<String> onSyncFilterChanged;
  final VoidCallback onAddSimulatedResult;
  final VoidCallback onImportTestPackage;

  const _FutureResultsSection({
    required this.repository,
    required this.patientId,
    required this.refreshToken,
    required this.syncFilter,
    required this.onSyncFilterChanged,
    required this.onAddSimulatedResult,
    required this.onImportTestPackage,
  });

  List<DesktopResult> _applySyncFilter(
      List<DesktopResult> results,
      ) {
    if (syncFilter == 'all') {
      return results;
    }

    return results
        .where((result) => result.syncState == syncFilter)
        .toList();
  }

  Widget _buildSyncFilterChip({
    required String label,
    required String value,
  }) {
    return FilterChip(
      label: Text(label),
      selected: syncFilter == value,
      onSelected: (_) {
        onSyncFilterChanged(value);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DesktopResult>>(
      key: ValueKey(refreshToken),
      future: repository.getResultsForPatient(patientId),
      builder: (context, snapshot) {
        final allResults = snapshot.data ?? [];

        final importedCount = allResults
            .where((r) => r.syncState == 'imported')
            .length;

        final modifiedCount = allResults
            .where((r) => r.syncState == 'modified')
            .length;

        final syncedCount = allResults
            .where((r) => r.syncState == 'synced')
            .length;

        final conflictCount = allResults
            .where((r) => r.syncState == 'conflict')
            .length;

        final results = _applySyncFilter(allResults);

        return _SectionCard(
          title: 'Tests réalisés',
          icon: Icons.science_outlined,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    onPressed: onAddSimulatedResult,
                    icon: const Icon(Icons.add),
                    label: const Text('Ajouter un test simulé'),
                  ),
                  OutlinedButton.icon(
                    onPressed: onImportTestPackage,
                    icon: const Icon(Icons.download_outlined),
                    label: const Text('Importer package test'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSyncFilterChip(
                  label: 'Tous (${allResults.length})',
                  value: 'all',
                ),
                _buildSyncFilterChip(
                  label: 'Importés ($importedCount)',
                  value: 'imported',
                ),
                _buildSyncFilterChip(
                  label: 'Modifiés ($modifiedCount)',
                  value: 'modified',
                ),
                _buildSyncFilterChip(
                  label: 'Synchronisés ($syncedCount)',
                  value: 'synced',
                ),
                _buildSyncFilterChip(
                  label: 'Conflits ($conflictCount)',
                  value: 'conflict',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (snapshot.connectionState == ConnectionState.waiting)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (results.isEmpty)
              const _EmptySectionMessage(
                text: 'Aucun test enregistré pour ce patient.',
              )
            else
              ...results.map(
                    (result) => _ResultTile(
                  result: result,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ResultTile extends StatelessWidget {
  final DesktopResult result;

  const _ResultTile({
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final date = DateTime.fromMillisecondsSinceEpoch(
      result.createdAt,
    );

    final locale = Localizations.localeOf(context);

    final formatter = DateFormat.yMd(
      locale.toLanguageTag(),
    );

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        child: Icon(
          switch (result.syncState) {
            'modified' => Icons.edit_outlined,
            'synced' => Icons.cloud_done_outlined,
            'conflict' => Icons.report_problem_outlined,
            _ => Icons.assignment_outlined,
          },
        ),
      ),
      title: Text(result.exoId),
      subtitle: Text(
        [
          formatter.format(date),

          if (result.scoreTotal != null)
            'Score : ${result.scoreTotal}',

          if (result.measureUnit != null)
            result.measureUnit!,

          if (result.mobileCaseLabel != null &&
              result.mobileCaseLabel!.trim().isNotEmpty)
            'Pathologie : ${result.mobileCaseLabel!.trim()}',

          'Sync : ${result.syncState}',
        ].join(' · '),
      ),
      onTap: () async {
        final shouldRefresh = await Navigator.of(context).push<bool>(
          MaterialPageRoute(
            builder: (_) => ResultDetailScreen(
              result: result,
            ),
          ),
        );

        if (shouldRefresh == true && context.mounted) {
          final state =
          context.findAncestorStateOfType<_PatientDetailScreenState>();

          state?.refreshResults();
        }
      },
    );
  }
}
class _MobileCasesSection extends StatelessWidget {
  final MobileCaseRepository repository;
  final String patientId;
  final int refreshToken;
  final String patientDisplayName;

  const _MobileCasesSection({
    required this.repository,
    required this.patientId,
    required this.refreshToken,
    required this.patientDisplayName,

  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<MobileCase>>(
      key: ValueKey('mobile-cases-$refreshToken'),
      future: repository.getCasesForPatient(patientId),
      builder: (context, snapshot) {
        final cases = snapshot.data ?? [];

        return _SectionCard(
          title: 'Dossiers mobiles associés',
          icon: Icons.phone_android_outlined,
          children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else if (cases.isEmpty)
              const _EmptySectionMessage(
                text: 'Aucun dossier mobile associé à ce patient.',
              )
            else
              ...cases.map(
                    (mobileCase) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.folder_outlined),
                      title: Text(
                        mobileCase.pathologyCode ?? mobileCase.caseLabel,
                      ),
                      subtitle: Text(
                        [
                          'Libellé : ${mobileCase.caseLabel}',
                          'Case ID : ${mobileCase.caseId}',
                        ].join('\n'),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => EpisodeDashboardScreen(
                              caseId: mobileCase.caseId,
                              caseLabel: mobileCase.caseLabel,
                              patientId: patientId,
                              patientDisplayName: patientDisplayName,
                            ),
                          ),
                        );
                      },
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
                    final state =
                    context.findAncestorStateOfType<_PatientDetailScreenState>();

                    state?.refreshResults();
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

class _ClinicalEpisodesSection extends StatelessWidget {
  final DesktopClinicalEpisodeRepository repository;
  final String patientId;
  final int refreshToken;

  const _ClinicalEpisodesSection({
    required this.repository,
    required this.patientId,
    required this.refreshToken,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DesktopClinicalEpisode>>(
      key: ValueKey('clinical-episodes-$refreshToken'),
      future: repository.getEpisodesForPatient(patientId),
      builder: (context, snapshot) {
        final episodes = snapshot.data ?? [];

        return _SectionCard(
          title: 'Épisodes cliniques',
          icon: Icons.medical_information_outlined,
          children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else if (episodes.isEmpty)
              const _EmptySectionMessage(
                text: 'Aucun épisode clinique importé pour ce patient.',
              )
            else
              ...episodes.map(
                    (episode) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    episode.isClosed
                        ? Icons.lock_outline
                        : Icons.play_circle_outline,
                  ),
                  title: Text(episode.displayTitle),
                  subtitle: Text(
                    [
                      'Statut : ${episode.status}',
                      if (episode.createdAt != null)
                        'Créé : ${episode.createdAt}',
                      if (episode.closedAt != null)
                        'Clôturé : ${episode.closedAt}',
                      'Episode ID : ${episode.episodeId}',
                    ].join('\n'),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
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
                      final state = context
                          .findAncestorStateOfType<_PatientDetailScreenState>();

                      state?.refreshResults();
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

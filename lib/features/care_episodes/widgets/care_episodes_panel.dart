import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:abak_shared/abak_shared.dart';
import '../../../generated/l10n.dart';
import '../../../core/utils/date_format_utils.dart';
import '../data/care_episode_repository.dart';
import '../data/care_episode_referring_practitioner_repository.dart';
import '../models/care_episode.dart';
import '../models/care_episode_summary.dart';
import '../screens/care_episode_reports_workspace_screen.dart';
import '../../practitioners/widgets/practitioner_selector.dart';
import '../../external_correspondents/widgets/external_correspondent_selector.dart';
import '../../results/data/desktop_result_repository.dart';

/// Shared episode management for the patient record and import assignment.
class CareEpisodesPanel extends StatefulWidget {
  final String patientId;
  final String patientName;
  final String? initialPathology;
  final ValueChanged<CareEpisode>? onSelectEpisode;

  const CareEpisodesPanel({
    super.key,
    required this.patientId,
    required this.patientName,
    this.initialPathology,
    this.onSelectEpisode,
  });

  @override
  State<CareEpisodesPanel> createState() => _CareEpisodesPanelState();
}

class _CareEpisodesPanelState extends State<CareEpisodesPanel> {
  int _refreshToken = 0;
  bool _archivingCareEpisode = false;
  bool _restoringCareEpisode = false;
  final CareEpisodeRepository _careEpisodeRepository = CareEpisodeRepository();
  final CareEpisodeReferringPractitionerRepository
  _referringPractitionerRepository =
      CareEpisodeReferringPractitionerRepository();

  Future<void> _editCareEpisode(CareEpisode episode) async {
    final s = S.of(context);
    final currentAssignment = await _referringPractitionerRepository
        .getCurrentReferringPractitioner(episode.careEpisodeId);

    if (!mounted) return;

    String? selectedPractitionerId = currentAssignment?.practitionerId;

    String? selectedPrescribingCorrespondentId =
        episode.prescribingCorrespondentId;

    final pathologyController = TextEditingController(
      text: episode.pathologyLabel,
    );
    final initialReportController = TextEditingController(
      text: episode.initialReport ?? '',
    );

    final dialog = DialogRoute<bool>(
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
                const SizedBox(height: 16),
                ExternalCorrespondentSelector(
                  label: 'Médecin prescripteur',
                  selectedCorrespondentId: selectedPrescribingCorrespondentId,
                  allowEmpty: true,
                  onChanged: (correspondentId) {
                    selectedPrescribingCorrespondentId = correspondentId;
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

    final updated = await Navigator.of(context).push(dialog);
    // Controllers remain alive until the dialog's closing animation finishes.
    await dialog.completed;

    final pathology = pathologyController.text.trim();
    final initialReport = initialReportController.text.trim();

    pathologyController.dispose();
    initialReportController.dispose();

    if (!mounted || updated != true || pathology.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;

    final updatedEpisode = CareEpisode(
      careEpisodeId: episode.careEpisodeId,
      patientId: episode.patientId,
      title: episode.title,
      pathologyLabel: pathology,
      initialReport: initialReport.isEmpty ? null : initialReport,
      initialReportDocxPath: episode.initialReportDocxPath,
      objectiveData: episode.objectiveData,
      assessmentData: episode.assessmentData,
      treatmentPlan: episode.treatmentPlan,
      finalConclusion: episode.finalConclusion,
      openedAt: episode.openedAt,
      createdAt: episode.createdAt,
      updatedAt: now,
      archivedAt: episode.archivedAt,
      prescribingCorrespondentId: selectedPrescribingCorrespondentId,
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

  Future<void> _archiveCareEpisode(CareEpisode episode) async {
    if (_archivingCareEpisode) return;
    _archivingCareEpisode = true;

    try {
      final s = S.of(context);
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Archiver cette prise en charge ?'),
          content: Text(
            '${episode.title}\n'
            '${s.patientDetail_pathology} : ${episode.pathologyLabel}\n\n'
            'Cette prise en charge sera retirée de la liste. '
            'Ses données seront conservées par archivage.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(s.patientDetail_cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
                foregroundColor: Theme.of(dialogContext).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Archiver'),
            ),
          ],
        ),
      );

      if (confirmed != true || !mounted) return;

      await _careEpisodeRepository.archiveCareEpisode(episode.careEpisodeId);
      if (!mounted) return;

      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prise en charge archivée.')),
      );
    } catch (error, stackTrace) {
      debugPrint('Échec de l’archivage de la prise en charge : $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible d’archiver la prise en charge. Veuillez réessayer.',
          ),
        ),
      );
    } finally {
      _archivingCareEpisode = false;
    }
  }

  Future<void> _restoreCareEpisode(CareEpisode episode) async {
    if (_restoringCareEpisode) return;
    setState(() => _restoringCareEpisode = true);

    try {
      await _careEpisodeRepository.restoreCareEpisode(episode.careEpisodeId);
      if (!mounted) return;

      _refresh();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prise en charge restaurée.')),
      );
    } catch (error, stackTrace) {
      debugPrint('Échec de la restauration de la prise en charge : $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Impossible de restaurer la prise en charge. Veuillez réessayer.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _restoringCareEpisode = false);
      }
    }
  }

  void _refresh() {
    setState(() {
      _refreshToken++;
    });
  }

  Future<void> _createCareEpisode() async {
    final s = S.of(context);
    final pathologyController = TextEditingController(
      text: widget.initialPathology,
    );
    final initialReportController = TextEditingController();

    String? selectedPractitionerId;

    final dialog = DialogRoute<bool>(
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

    final created = await Navigator.of(context).push(dialog);
    // Controllers remain alive until the dialog's closing animation finishes.
    await dialog.completed;

    final pathology = pathologyController.text.trim();
    final initialReport = initialReportController.text.trim();

    pathologyController.dispose();
    initialReportController.dispose();

    if (!mounted || created != true || pathology.isEmpty) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final date = DateTime.now();
    final monthYear = '${date.month.toString().padLeft(2, '0')}/${date.year}';

    final episode = CareEpisode(
      careEpisodeId: const Uuid().v4(),
      patientId: widget.patientId,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CareEpisodesSection(
          repository: _careEpisodeRepository,
          patientId: widget.patientId,
          patientName: widget.patientName,
          refreshToken: _refreshToken,
          onCreateCareEpisode: _createCareEpisode,
          onEditCareEpisode: _editCareEpisode,
          onArchiveCareEpisode: _archiveCareEpisode,
          onRestoreCareEpisode: _restoreCareEpisode,
          onSelectEpisode: widget.onSelectEpisode,
        ),
        const SizedBox(height: 16),
        _CareEpisodesSection(
          repository: _careEpisodeRepository,
          patientId: widget.patientId,
          patientName: widget.patientName,
          refreshToken: _refreshToken,
          archived: true,
          restoring: _restoringCareEpisode,
          onCreateCareEpisode: _createCareEpisode,
          onEditCareEpisode: _editCareEpisode,
          onArchiveCareEpisode: _archiveCareEpisode,
          onRestoreCareEpisode: _restoreCareEpisode,
        ),
      ],
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
                  if (helpContent != null &&
                      helpContent!.trim().isNotEmpty) ...[
                    const SizedBox(width: 8),
                    ContextHelpButton(title: title, content: helpContent!),
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

class _CareEpisodesSection extends StatelessWidget {
  final CareEpisodeRepository repository;
  final String patientId;
  final int refreshToken;
  final VoidCallback onCreateCareEpisode;
  final ValueChanged<CareEpisode> onEditCareEpisode;
  final ValueChanged<CareEpisode> onArchiveCareEpisode;
  final ValueChanged<CareEpisode> onRestoreCareEpisode;
  final bool archived;
  final bool restoring;
  final String patientName;
  final ValueChanged<CareEpisode>? onSelectEpisode;

  const _CareEpisodesSection({
    required this.repository,
    required this.patientId,
    required this.refreshToken,
    required this.onCreateCareEpisode,
    required this.onEditCareEpisode,
    required this.onArchiveCareEpisode,
    required this.onRestoreCareEpisode,
    this.archived = false,
    this.restoring = false,
    required this.patientName,
    this.onSelectEpisode,
  });

  String _referringPractitionerLabel(CareEpisodeSummary summary, S s) {
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
      key: ValueKey('care-episodes-$archived-$refreshToken'),
      future: repository.getEpisodeSummariesForPatient(
        patientId,
        archived: archived,
      ),
      builder: (context, snapshot) {
        final summaries = snapshot.data ?? [];

        return _SectionCard(
          title: archived ? 'Prises en charge archivées' : 'Prises en charge',
          icon: archived
              ? Icons.archive_outlined
              : Icons.folder_special_outlined,
          helpContent: S.of(context).help_prise_en_charge,
          children: [
            if (!archived) ...[
              OutlinedButton.icon(
                onPressed: onCreateCareEpisode,
                icon: const Icon(Icons.add),
                label: const Text('Nouvelle prise en charge'),
              ),
              const SizedBox(height: 16),
            ],
            if (snapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else if (snapshot.hasError)
              const Text('Impossible de charger les prises en charge.')
            else if (summaries.isEmpty)
              _EmptySectionMessage(
                text: archived
                    ? 'Aucune prise en charge archivée pour ce patient.'
                    : 'Aucune prise en charge créée pour ce patient.',
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
                      'Médecin prescripteur : '
                          '${summary.prescribingCorrespondentDisplayName ?? s.patientDetail_notProvided}',
                      if (archived && episode.archivedAt != null)
                        'Archivée le ${DateFormatUtils.formatTimestampForDisplay(context, episode.archivedAt!)}',
                    ].join('\n'),
                  ),
                  trailing: archived
                      ? OutlinedButton.icon(
                          onPressed: restoring
                              ? null
                              : () => onRestoreCareEpisode(episode),
                          icon: const Icon(Icons.restore),
                          label: const Text('Restaurer'),
                        )
                      : Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (onSelectEpisode != null)
                              FilledButton(
                                onPressed: () => onSelectEpisode!(episode),
                                child: const Text('Choisir'),
                              ),
                            IconButton(
                              tooltip: 'Modifier',
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () => onEditCareEpisode(episode),
                            ),
                            IconButton(
                              tooltip: 'Archiver la prise en charge',
                              icon: const Icon(Icons.archive_outlined),
                              color: Theme.of(context).colorScheme.error,
                              onPressed: () => onArchiveCareEpisode(episode),
                            ),
                          ],
                        ),
                  onTap: () async {
                    if (!archived && onSelectEpisode != null) {
                      onSelectEpisode!(episode);
                      return;
                    }
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
                          .findAncestorStateOfType<_CareEpisodesPanelState>();

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

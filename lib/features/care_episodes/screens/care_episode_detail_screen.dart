import 'package:flutter/material.dart';

import '../models/care_episode.dart';
import 'package:intl/intl.dart';
import '../../results/data/desktop_result_repository.dart';
import '../../results/models/desktop_result.dart';
import '../../results/result_detail_screen.dart';
import 'package:abak_shared/abak_shared.dart';
import '../../patients/data/patient_repository.dart';
import '../../patients/models/patient.dart';
import '../../results/evolution/episode_evolution_screen.dart';
import 'care_episode_reports_workspace_screen.dart';


class CareEpisodeDetailScreen extends StatefulWidget {
  final CareEpisode episode;


  const CareEpisodeDetailScreen({super.key, required this.episode});

  @override
  State<CareEpisodeDetailScreen> createState() =>
      _CareEpisodeDetailScreenState();
}

class _CareEpisodeDetailScreenState extends State<CareEpisodeDetailScreen> {
  final DesktopResultRepository _resultRepository = DesktopResultRepository();


  int _refreshToken = 0;
  bool _hasChanged = false;
  late CareEpisode _episode;
  final PatientRepository _patientRepository = PatientRepository();

  Patient? _patient;

  @override
  void initState() {
    super.initState();
    _episode = widget.episode;
    _loadPatient();
  }

  Future<void> _loadPatient() async {
    final patient = await _patientRepository.getPatientById(_episode.patientId);

    if (!mounted) return;

    setState(() {
      _patient = patient;
    });
  }

  void _refresh() {
    setState(() {
      _refreshToken++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        Navigator.of(context).pop(_hasChanged);
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _patient == null
                ? _episode.displayTitle
                : '${_patient!.lastName.toUpperCase()} ${_patient!.firstName}',
          ),
          actions: [
            IconButton(
              tooltip: 'Nouvelle interface bilans et rapports',
              icon: const Icon(Icons.dashboard_customize_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CareEpisodeReportsWorkspaceScreen(
                      episode: _episode,
                      patientName: _patient == null
                          ? _episode.displayTitle
                          : '${_patient!.lastName.toUpperCase()} '
                          '${_patient!.firstName}',
                      resultRepository: _resultRepository,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        body: ListView(
          key: ValueKey(_refreshToken),
          padding: const EdgeInsets.all(24),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pathologie',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(_episode.pathologyLabel),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            _AbakResultsCard(
              repository: _resultRepository,
              careEpisodeId: _episode.careEpisodeId,
              refreshToken: _refreshToken,
              patientName: _patient == null
                  ? _episode.displayTitle
                  : '${_patient!.lastName.toUpperCase()} ${_patient!.firstName}',
              onChanged: () {
                _hasChanged = true;
                _refresh();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AbakResultsCard extends StatelessWidget {
  final DesktopResultRepository repository;
  final String careEpisodeId;
  final int refreshToken;
  final VoidCallback onChanged;
  final String patientName;

  const _AbakResultsCard({
    required this.repository,
    required this.careEpisodeId,
    required this.refreshToken,
    required this.onChanged,
    required this.patientName,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: FutureBuilder<List<DesktopResult>>(
          key: ValueKey('abak-results-$refreshToken'),
          future: repository.getResultsForCareEpisode(careEpisodeId),
          builder: (context, snapshot) {
            final results = snapshot.data ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Résultats ABAK',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: results.isEmpty
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EpisodeEvolutionScreen(
                                    careEpisodeId: careEpisodeId,
                                    patientName: patientName,
                                  ),
                                ),
                              );
                            },
                      icon: const Icon(Icons.show_chart),
                      label: const Text('Évolution'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const SizedBox(height: 12),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  )
                else if (results.isEmpty)
                  const Text('Aucun résultat rattaché pour le moment.')
                else
                  ...results.map((result) {
                    final date = DateTime.fromMillisecondsSinceEpoch(
                      result.createdAt,
                    );

                    final formatter = DateFormat.yMd(
                      Localizations.localeOf(context).toLanguageTag(),
                    );

                    final mobileOrigin =
                        result.mobilePathologyLabel ??
                        result.mobilePatientLabel;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const Icon(Icons.bar_chart_outlined),
                        title: Text(
                          ClinicalActivityCatalog.displayLabel(result.exoId),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              [
                                formatter.format(date),
                                if (result.scoreTotal != null)
                                  'Score : ${result.scoreTotal?.toStringAsFixed(2) ?? '-'}',
                                if (result.measureUnit != null)
                                  result.measureUnit!,
                              ].join(' · '),
                            ),
                            if (mobileOrigin != null &&
                                mobileOrigin.trim().isNotEmpty)
                              Text(
                                'Origine ABAK : ${mobileOrigin.trim()}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final changed = await Navigator.of(context)
                              .push<bool>(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ResultDetailScreen(result: result),
                                ),
                              );

                          if (changed == true) {
                            onChanged();
                          }
                        },
                      ),
                    );
                  }),
              ],
            );
          },
        ),
      ),
    );
  }
}

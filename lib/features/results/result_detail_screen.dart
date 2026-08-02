import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'data/desktop_result_repository.dart';
import 'models/desktop_result.dart';
import 'models/desktop_result_metric.dart';
import 'package:abak_shared/abak_shared.dart';
import 'models/result_traceability.dart';

class ResultDetailScreen extends StatefulWidget {
  final DesktopResult result;

  const ResultDetailScreen({super.key, required this.result});

  @override
  State<ResultDetailScreen> createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends State<ResultDetailScreen> {
  final DesktopResultRepository _repository = DesktopResultRepository();
  late DesktopResult _result;
  late final TextEditingController _commentController;
  ResultTraceability? _traceability;

  @override
  void initState() {
    super.initState();
    _result = widget.result;
    _commentController = TextEditingController(text: _result.comment ?? '');
    _loadTraceability();
  }

  Future<void> _loadTraceability() async {
    final traceability = await _repository.getTraceabilityForResult(
      _result.resultId,
    );

    if (!mounted) return;

    setState(() {
      _traceability = traceability;
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _formatVerificationStatus(String? status) {
    switch (status) {
      case 'verified':
        return 'Identité vérifiée';
      case 'unverified':
        return 'Identité non vérifiée';
      default:
        return '-';
    }
  }

  Future<void> _saveComment() async {
    final text = _commentController.text.trim();
    final now = DateTime.now().millisecondsSinceEpoch;

    await _repository.updateResultComment(
      resultId: _result.resultId,
      comment: text.isEmpty ? null : text,
    );

    if (!mounted) return;

    setState(() {
      _result = _result.copyWith(
        comment: text,
        syncState: 'modified',
        lastModifiedAt: now,
      );
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Commentaire enregistré')));
  }

  Future<void> _markAsSynced() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await _repository.markResultAsSynced(_result.resultId);

    if (!mounted) return;

    setState(() {
      _result = _result.copyWith(syncState: 'synced', lastModifiedAt: now);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Résultat marqué comme synchronisé')),
    );
  }

  Future<void> _markAsConflict() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await _repository.markResultAsConflict(_result.resultId);

    if (!mounted) return;

    setState(() {
      _result = _result.copyWith(syncState: 'conflict', lastModifiedAt: now);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Résultat marqué comme conflit')),
    );
  }

  Future<void> _archiveResult(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Archiver le résultat'),
          content: const Text('Voulez-vous vraiment archiver ce résultat ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Archiver'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _repository.archiveResult(_result.resultId);

    if (context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(_result.createdAt);
    final locale = Localizations.localeOf(context);
    final formatter = DateFormat.yMd(locale.toLanguageTag());

    final traceabilityInfo = [
      _traceability?.practitionerDisplayName,
      _formatVerificationStatus(
        _traceability?.practitionerVerificationStatus,
      ),
      if (_traceability?.deviceLabel?.trim().isNotEmpty == true)
        'Appareil : ${_traceability!.deviceLabel!.trim()}',
    ].whereType<String>().where((value) {
      final trimmed = value.trim();
      return trimmed.isNotEmpty && trimmed != '-';
    }).join(' · ');

    final generalInformationCard = _SectionCard(
      title: 'Informations générales',
      icon: Icons.info_outline,
      children: [
        _InfoRow(
          label: 'Patient',
          value: _result.mobilePatientLabel ?? '-',
        ),
        _InfoRow(
          label: 'Naissance',
          value: _result.patientBirthDate ?? '-',
        ),
        _InfoRow(
          label: "Date de l'exercice",
          value: formatter.format(createdAt),
        ),
        _InfoRow(
          label: 'Score',
          value: _result.scoreTotal == null
              ? '-'
              : '${_result.scoreTotal!.toStringAsFixed(2)}'
              '${_result.measureUnit == null ? '' : ' ${_result.measureUnit}'}',
        ),
        _InfoRow(
          label: 'Réalisé par',
          value: traceabilityInfo.isEmpty ? '-' : traceabilityInfo,
        ),
      ],
    );

    final commentCard = _SectionCard(
      title: 'Commentaire clinique',
      icon: Icons.edit_note_outlined,
      children: [
        TextField(
          controller: _commentController,
          minLines: 3,
          maxLines: 5,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: 'Ajouter un commentaire...',
            isDense: true,
            contentPadding: EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerRight,
          child: FilledButton.icon(
            onPressed: _saveComment,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Enregistrer'),
          ),
        ),
      ],
    );

    final detailedResultCard = _SectionCard(
      title: 'Résultat détaillé',
      icon: Icons.description_outlined,
      children: [
        SelectableText(_result.exportSimpleText),
      ],
    );

    final metricsCard = _MetricsSection(
      repository: _repository,
      resultId: _result.resultId,
    );

    final synchronizationCard = _SectionCard(
      title: 'Import',
      icon: Icons.sync_outlined,
      children: [
        _InfoRow(label: 'État sync', value: _result.syncState),
        _InfoRow(
          label: 'Dernière modification',
          value: _result.lastModifiedAt == null
              ? '-'
              : DateFormat(
            'dd/MM/yyyy HH:mm',
            locale.toLanguageTag(),
          ).format(
            DateTime.fromMillisecondsSinceEpoch(
              _result.lastModifiedAt!,
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(ClinicalActivityCatalog.displayLabel(_result.exoId)),
        actions: [
          IconButton(
            tooltip: 'Archiver',
            icon: const Icon(Icons.archive_outlined),
            onPressed: () => _archiveResult(context),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWideScreen = constraints.maxWidth >= 1100;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              if (isWideScreen)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 4,
                      child: generalInformationCard,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 6,
                      child: commentCard,
                    ),
                  ],
                )
              else ...[
                generalInformationCard,
                const SizedBox(height: 16),
                commentCard,
              ],

              const SizedBox(height: 16),

              if (isWideScreen)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: detailedResultCard,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: metricsCard,
                    ),
                  ],
                )
              else ...[
                detailedResultCard,
                const SizedBox(height: 16),
                metricsCard,
              ],

              const SizedBox(height: 16),
              synchronizationCard,
            ],
          );
        },
      ),
    );
  }
}

class _MetricsSection extends StatelessWidget {
  final DesktopResultRepository repository;
  final String resultId;

  const _MetricsSection({required this.repository, required this.resultId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<DesktopResultMetric>>(
      future: repository.getMetricsForResult(resultId),
      builder: (context, snapshot) {
        final metrics = snapshot.data ?? [];

        return _SectionCard(
          title: 'Métriques',
          icon: Icons.analytics_outlined,
          children: [
            if (snapshot.connectionState == ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.all(16),
                child: CircularProgressIndicator(),
              )
            else if (metrics.isEmpty)
              const Text('Aucune métrique enregistrée.')
            else
              ...metrics.map(
                (metric) => _InfoRow(
                  label: metric.label ?? metric.metricKey,
                  value:
                  '${metric.value.toStringAsFixed(2)}'
                      '${metric.unit == null ? '' : ' ${metric.unit}'}'
                ),
              ),
          ],
        );
      },
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
        padding: const EdgeInsets.all(16),
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
            const Divider(height: 22),
            ...children,
          ],
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
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(value),
          ),
        ],
      ),
    );
  }
}

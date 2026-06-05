import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'data/desktop_result_repository.dart';
import 'models/desktop_result.dart';
import 'models/desktop_result_metric.dart';

class ResultDetailScreen extends StatefulWidget {
  final DesktopResult result;

  const ResultDetailScreen({
    super.key,
    required this.result,
  });

  @override
  State<ResultDetailScreen> createState() =>
      _ResultDetailScreenState();
}

class _ResultDetailScreenState
    extends State<ResultDetailScreen> {
  final DesktopResultRepository _repository =
  DesktopResultRepository();
  late DesktopResult _result;

  late final TextEditingController
  _commentController;

  @override
  void initState() {
    super.initState();

    _result = widget.result;

    _commentController = TextEditingController(
      text: _result.comment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
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

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Commentaire enregistré'),
      ),
    );
  }

  Future<void> _markAsSynced() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await _repository.markResultAsSynced(_result.resultId);

    if (!mounted) return;

    setState(() {
      _result = _result.copyWith(
        syncState: 'synced',
        lastModifiedAt: now,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Résultat marqué comme synchronisé'),
      ),
    );
  }

  Future<void> _markAsConflict() async {
    final now = DateTime.now().millisecondsSinceEpoch;

    await _repository.markResultAsConflict(_result.resultId);

    if (!mounted) return;

    setState(() {
      _result = _result.copyWith(
        syncState: 'conflict',
        lastModifiedAt: now,
      );
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Résultat marqué comme conflit'),
      ),
    );
  }

  Future<void> _archiveResult(
      BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title:
          const Text('Archiver le résultat'),
          content: const Text(
            'Voulez-vous vraiment archiver ce résultat ?',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.of(context).pop(true),
              child: const Text('Archiver'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await _repository.archiveResult(
      _result.resultId,
    );

    if (context.mounted) {
      Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final createdAt =
    DateTime.fromMillisecondsSinceEpoch(
      _result.createdAt,
    );

    final locale =
    Localizations.localeOf(context);

    final formatter = DateFormat.yMd(
      locale.toLanguageTag(),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_result.exoId),
        actions: [
          IconButton(
            tooltip: 'Archiver',
            icon:
            const Icon(Icons.archive_outlined),
            onPressed: () =>
                _archiveResult(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _SectionCard(
            title: 'Informations générales',
            icon: Icons.info_outline,
            children: [
              _InfoRow(
                label: 'Exercice',
                value: _result.exoId,
              ),
              _InfoRow(
                label: 'Date',
                value:
                formatter.format(createdAt),
              ),
              _InfoRow(
                label: 'Score',
                value: _result.scoreTotal
                    ?.toString() ??
                    '-',
              ),
              _InfoRow(
                label: 'Unité',
                value:
                _result.measureUnit ??
                    '-',
              ),
              _InfoRow(
                label: 'Kiné',
                value: widget.result
                    .practitionerLabelSnapshot ??
                    '-',
              ),
              if (_result.mobileCaseLabel != null)
                _InfoRow(
                  label: 'Dossier mobile',
                  value: _result.mobileCaseLabel!,
                ),

              if (_result.mobileCaseId != null)
                _InfoRow(
                  label: 'Case ID',
                  value: _result.mobileCaseId!,
                ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Commentaire clinique',
            icon: Icons.edit_note_outlined,
            children: [
              TextField(
                controller: _commentController,
                minLines: 3,
                maxLines: 6,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Ajouter un commentaire...',
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.icon(
                  onPressed: _saveComment,
                  icon: const Icon(Icons.save_outlined),
                  label: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Export simple',
            icon:
            Icons.description_outlined,
            children: [
              SelectableText(
                _result.exportSimpleText,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SectionCard(
            title: 'Synchronisation',
            icon: Icons.sync_outlined,
            children: [
              _InfoRow(
                label: 'État sync',
                value:
                _result.syncState,
              ),
              _InfoRow(
                label:
                'Dernière modification',
                value: widget
                    .result
                    .lastModifiedAt ==
                    null
                    ? '-'
                    : formatter.format(
                  DateTime
                      .fromMillisecondsSinceEpoch(
                    widget.result
                        .lastModifiedAt!,
                  ),
                ),
              ),
              _InfoRow(
                label: 'Hash contenu',
                value: widget
                    .result.contentHash ??
                    '-',
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: _markAsConflict,
                  icon: const Icon(Icons.report_problem_outlined),
                  label: const Text('Marquer comme conflit'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: _markAsSynced,
              icon: const Icon(Icons.cloud_done_outlined),
              label: const Text('Marquer comme synchronisé'),
            ),
          ),
          const SizedBox(height: 16),
          _MetricsSection(
            repository: _repository,
            resultId:
            _result.resultId,
          ),
        ],
      ),
    );
  }
}

class _MetricsSection extends StatelessWidget {
  final DesktopResultRepository repository;
  final String resultId;

  const _MetricsSection({
    required this.repository,
    required this.resultId,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<
        DesktopResultMetric>>(
      future:
      repository.getMetricsForResult(
        resultId,
      ),
      builder: (context, snapshot) {
        final metrics = snapshot.data ?? [];

        return _SectionCard(
          title: 'Métriques',
          icon: Icons.analytics_outlined,
          children: [
            if (snapshot.connectionState ==
                ConnectionState.waiting)
              const Padding(
                padding: EdgeInsets.all(16),
                child:
                CircularProgressIndicator(),
              )
            else if (metrics.isEmpty)
              const Text(
                'Aucune métrique enregistrée.',
              )
            else
              ...metrics.map(
                    (metric) => _InfoRow(
                  label:
                  metric.label ??
                      metric.metricKey,
                  value:
                  '${metric.value}'
                      '${metric.unit == null ? '' : ' ${metric.unit}'}',
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
        padding:
        const EdgeInsets.all(20),
        child: ConstrainedBox(
          constraints:
          const BoxConstraints(
            maxWidth: 900,
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge,
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
      padding:
      const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight:
                FontWeight.bold,
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
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../import_export/abak_import_launcher.dart';
import '../../import_export/abak_package.dart';
import '../../import_export/data/import_session_repository.dart';
import '../../import_export/models/pending_import_view_model.dart';

class PendingResolutionCard extends StatefulWidget {
  final VoidCallback? onImportCompleted;

  const PendingResolutionCard({super.key, this.onImportCompleted});

  @override
  State<PendingResolutionCard> createState() => _PendingResolutionCardState();
}

class _PendingResolutionCardState extends State<PendingResolutionCard> {
  final repository = ImportSessionRepository();

  List<Map<String, dynamic>> _files = [];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _refresh();

    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _refresh());
  }

  Future<void> _refresh() async {
    if (!mounted) return;

    final newFiles = await repository.getFilesNeedingResolution();

    if (_filesSignature(_files) == _filesSignature(newFiles)) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _files = newFiles;
    });
  }

  String _filesSignature(List<Map<String, dynamic>> files) {
    final paths =
        files
            .map((file) => file['file_path']?.toString() ?? '')
            .where((path) => path.isNotEmpty)
            .toList()
          ..sort();

    return paths.join('|');
  }

  Future<PendingImportViewModel> _buildViewModel(
    Map<String, dynamic> fileRow,
  ) async {
    final fileName = fileRow['file_name']?.toString() ?? 'Fichier ABAK';
    final filePath = fileRow['file_path']?.toString() ?? '';

    final file = File(filePath);
    final fileSize = await file.exists() ? await file.length() : null;

    try {
      final jsonString = await file.readAsString();
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      final package = AbakPackage.fromJson(decoded);

      final results = package.results;
      final firstResult = results.isEmpty ? null : results.first.raw;

      final createdAt = (firstResult?['createdAt'] as num?)?.toInt();

      final exerciseLabels = results
          .map((result) {
            final raw = result.raw;
            return raw['title']?.toString() ??
                raw['testName']?.toString() ??
                raw['exoTitle']?.toString() ??
                raw['exoId']?.toString() ??
                'Exercice ABAK';
          })
          .where((label) => label.trim().isNotEmpty)
          .toList();

      return PendingImportViewModel(
        fileName: fileName,
        filePath: filePath,
        fileSize: fileSize,
        pathologyLabel:
            package.clinicalEpisode?.pathologyLabel ??
            package.mobileCase?.pathologyCode ??
            '',
        patientLabel:
            package.clinicalEpisode?.patientLabel ??
            package.clinicalEpisode?.patientRef ??
            '',
        examinationDate: createdAt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(createdAt),
        exerciseLabels: exerciseLabels,
        resultsCount: results.length,
      );
    } catch (_) {
      return PendingImportViewModel(
        fileName: fileName,
        filePath: filePath,
        fileSize: fileSize,
        pathologyLabel: '',
        patientLabel: '',
        examinationDate: null,
        exerciseLabels: const [],
        resultsCount: 0,
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _openImportResolution(
    BuildContext context,
    String filePath,
  ) async {
    if (filePath.isEmpty || !filePath.toLowerCase().endsWith('.abak')) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chemin du fichier invalide : $filePath')),
      );
      return;
    }

    final result = await AbakImportLauncher.importArchiveFromPathWithResolution(
      context,
      filePath,
    );

    await _refresh();

    if (result != null) {
      widget.onImportCompleted?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final files = _files;
    final accentColor = files.isNotEmpty ? Colors.orange : Colors.green;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: accentColor, width: 2),
      ),
      child: ExpansionTile(
        key: const PageStorageKey<String>('pending_resolution_card'),
        maintainState: true,
        initiallyExpanded: files.isNotEmpty,
        leading: Icon(
          files.isNotEmpty
              ? Icons.medical_information_outlined
              : Icons.check_circle_outline,
          color: accentColor,
        ),
        title: Text(
          'Nouveaux résultats ABAK à associer à un patient',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          files.isEmpty
              ? 'Aucun import en attente'
              : '${files.length} import${files.length > 1 ? 's' : ''} en attente d’association',
          style: TextStyle(fontWeight: FontWeight.w600, color: accentColor),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          if (files.isEmpty)
            const Text('Aucun résultat ABAK à associer.')
          else
            ...files.map((fileRow) {
              final filePath = fileRow['file_path']?.toString() ?? '';

              return FutureBuilder<PendingImportViewModel>(
                key: ValueKey('pending-import-$filePath'),
                future: _buildViewModel(fileRow),
                builder: (context, snapshot) {
                  final vm = snapshot.data;

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: LinearProgressIndicator(),
                    );
                  }

                  if (vm == null) {
                    return const Text('Import ABAK illisible.');
                  }

                  return _PendingImportTile(
                    viewModel: vm,
                    onAssociate: () =>
                        _openImportResolution(context, vm.filePath),
                  );
                },
              );
            }),
        ],
      ),
    );
  }
}

class _PendingImportTile extends StatelessWidget {
  final PendingImportViewModel viewModel;
  final VoidCallback onAssociate;

  const _PendingImportTile({
    required this.viewModel,
    required this.onAssociate,
  });

  @override
  Widget build(BuildContext context) {
    final dateText = viewModel.examinationDate == null
        ? 'Date non renseignée'
        : DateFormat.yMMMMd(
            Localizations.localeOf(context).toLanguageTag(),
          ).format(viewModel.examinationDate!);

    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              viewModel.displayPathology,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _ImportInfoRow(
              icon: Icons.person_outline,
              label: 'Patient ABAK',
              value: viewModel.displayPatient,
            ),
            _ImportInfoRow(
              icon: Icons.event_outlined,
              label: 'Date du bilan',
              value: dateText,
            ),
            _ImportInfoRow(
              icon: Icons.bar_chart_outlined,
              label: 'Résultats',
              value: viewModel.resultsSummary,
            ),
            if (viewModel.visibleExerciseLabels.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...viewModel.visibleExerciseLabels.map(
                (label) => Padding(
                  padding: const EdgeInsets.only(left: 32, bottom: 4),
                  child: Text('• $label'),
                ),
              ),
              if (viewModel.hiddenExerciseCount > 0)
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Text(
                    '+ ${viewModel.hiddenExerciseCount} autre(s) exercice(s)',
                  ),
                ),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onAssociate,
                icon: const Icon(Icons.link_outlined),
                label: const Text('Associer à une prise en charge'),
              ),
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              key: PageStorageKey<String>(
                'technical-info-${viewModel.filePath}',
              ),
              tilePadding: EdgeInsets.zero,
              title: const Text('Informations techniques'),
              children: [
                _TechnicalInfoRow(label: 'Fichier', value: viewModel.fileName),
                _TechnicalInfoRow(label: 'Chemin', value: viewModel.filePath),
                _TechnicalInfoRow(
                  label: 'Taille',
                  value: viewModel.fileSize == null
                      ? 'Non renseignée'
                      : '${viewModel.fileSize} octets',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ImportInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ImportInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 12),
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _TechnicalInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _TechnicalInfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      subtitle: Text(value, overflow: TextOverflow.ellipsis, maxLines: 3),
    );
  }
}

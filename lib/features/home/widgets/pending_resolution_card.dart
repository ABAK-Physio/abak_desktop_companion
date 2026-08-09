import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../generated/l10n.dart';
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
    final s = S.of(context);

    final fileName =
        fileRow['file_name']?.toString() ?? s.home_abak_file;
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
            s.home_abak_exercice;
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
        SnackBar(content: Text('${S.of(context).home_invalid_file_path} $filePath')),
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
          S.of(context).home_new_abak_results_to_be_linked,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(
          files.isEmpty
              ? S.of(context).home_no_pending_imports
              : S.of(context).home_pending_association(files.length),
          style: TextStyle(fontWeight: FontWeight.w600, color: accentColor),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          if (files.isEmpty)
            Text(S.of(context).home_no_abak_result_to_associate)
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
                    return Text(S.of(context).home_unreadable_abak_import);
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
        ? S.of(context).home_date_not_specified
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
              label: S.of(context).home_patient_abak,
              value: viewModel.displayPatient,
            ),
            _ImportInfoRow(
              icon: Icons.event_outlined,
              label: S.of(context).home_balance_sheet_date,
              value: dateText,
            ),
            _ImportInfoRow(
              icon: Icons.bar_chart_outlined,
              label: S.of(context).home_results,
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
                    S.of(context).home_other_exercises(viewModel.hiddenExerciseCount),
                  ),
                ),
            ],
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: onAssociate,
                icon: const Icon(Icons.link_outlined),
                label: Text(S.of(context).home_link_to_a_care_plan),
              ),
            ),
            const SizedBox(height: 8),
            ExpansionTile(
              key: PageStorageKey<String>(
                'technical-info-${viewModel.filePath}',
              ),
              tilePadding: EdgeInsets.zero,
              title: Text(S.of(context).home_technical_information),
              children: [
                _TechnicalInfoRow(label: S.of(context).home_file, value: viewModel.fileName),
                _TechnicalInfoRow(label: S.of(context).home_pathway, value: viewModel.filePath),
                _TechnicalInfoRow(
                  label: S.of(context).home_size,
                  value: viewModel.fileSize == null
                      ? S.of(context).home_not_specified
                      : '${viewModel.fileSize} ${S.of(context).home_octets}',
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

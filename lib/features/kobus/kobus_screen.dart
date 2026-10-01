import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../generated/l10n.dart';
import 'kobus_models.dart';
import 'kobus_preparation.dart';
import 'kobus_import_service.dart';
import 'kobus_report.dart';

class KobusScreen extends StatefulWidget {
  const KobusScreen({super.key});
  @override
  State<KobusScreen> createState() => _KobusScreenState();
}

class _KobusScreenState extends State<KobusScreen> {
  final _service = KobusImportService();
  KobusPreparation? _preparation;
  bool _shared = false, _busy = false, _importing = false;
  bool _reading = false;
  String? _error;
  double _progress = 0;
  List<Map<String, Object?>> _history = [];
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    final preparation = _preparation;
    if (preparation != null && !_importing) disposeKobus(preparation);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      await _service.recover();
      final history = await _service.history();
      if (mounted) setState(() => _history = history);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    }
  }

  Future<void> _select() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['zip'],
      );
      if (result == null || !mounted) return;
      setState(() => _reading = true);
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      final path = result.files.single.path;
      if (path == null || !await File(path).exists()) {
        throw StateError(S.current.kobus_unavailable);
      }
      final preparation = await prepareKobus(path);
      if (!mounted) {
        await disposeKobus(preparation);
        return;
      }
      try {
        await findKobusCandidates(preparation, false);
      } catch (_) {
        await disposeKobus(preparation);
        rethrow;
      }
      if (!mounted) {
        await disposeKobus(preparation);
        return;
      }
      if (_preparation != null) await disposeKobus(_preparation!);
      setState(() {
        _preparation = preparation;
        _shared = false;
      });
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _reading = false;
        });
      }
    }
  }

  Future<void> _toggle(bool value) async {
    setState(() => _busy = true);
    try {
      await findKobusCandidates(_preparation!, value);
      if (mounted) setState(() => _shared = value);
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _start() async {
    final s = S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.kobus_confirm),
        content: Text(s.kobus_confirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(s.kobus_cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.kobus_start),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() {
      _busy = true;
      _importing = true;
      _progress = 0;
      _error = null;
    });
    final preparation = _preparation!;
    try {
      final run = await _service.import(
        preparation,
        includeShared: _shared,
        progress: (done, total) {
          if (mounted) setState(() => _progress = done / total);
        },
      );
      await _load();
      if (mounted) {
        final record = _history.singleWhere((r) => r['run_id'] == run);
        await _showReport(record);
      }
    } catch (e) {
      if (mounted) setState(() => _error = '$e');
    } finally {
      try {
        await disposeKobus(preparation);
      } catch (e) {
        if (mounted) setState(() => _error = '${_error ?? ''}\n$e');
      }
      if (mounted) {
        setState(() {
          _preparation = null;
          _busy = false;
          _importing = false;
        });
      }
    }
  }

  Future<void> _showReport(Map<String, Object?> run) async {
    final rows = await _service.items(run['run_id'] as String);
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KobusReportScreen(run: run, rows: rows),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context), preparation = _preparation;
    final selected =
        preparation?.folders.where((f) => !f.shared || _shared).toList() ??
        <KobusFolder>[];
    final creates = selected
        .where((f) => f.rejection == null && f.decision == KobusDecision.create)
        .length;
    final matches = selected
        .where((f) => f.rejection == null && f.candidates.isNotEmpty)
        .length;
    final rejects = selected.where((f) => f.rejection != null).length;
    return PopScope(
      canPop: !_busy,
      child: Scaffold(
        appBar: AppBar(title: Text(s.kobus_title)),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.kobus_intro),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _select,
                    icon: const Icon(Icons.file_upload_outlined),
                    label: Text(s.kobus_select),
                  ),
                  if (_error != null)
                    SelectableText(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  if (_reading)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Semantics(
                        liveRegion: true,
                        child: const Text(
                          'Lecture du fichier en cours... patientez',
                        ),
                      ),
                    ),
                  if (_busy)
                    LinearProgressIndicator(
                      value: _importing ? _progress : null,
                    ),
                  if (_importing)
                    TextButton(
                      onPressed: () =>
                          setState(() => _service.stopRequested = true),
                      child: Text(
                        _service.stopRequested
                            ? s.kobus_stopping
                            : s.kobus_stop,
                      ),
                    ),
                  if (preparation != null) ...[
                    Text(preparation.zipName),
                    CheckboxListTile(
                      value: _shared,
                      onChanged: _busy || !preparation.hasShared
                          ? null
                          : (v) => _toggle(v!),
                      title: Text(s.kobus_shared),
                      subtitle: Text(
                        preparation.hasShared
                            ? s.kobus_scopeReset
                            : s.kobus_noShared,
                      ),
                    ),
                    Text(
                      '${s.kobus_creations}: $creates • ${s.kobus_matches}: $matches • ${s.kobus_rejected}: $rejects',
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: _busy ? null : _start,
                      child: Text(s.kobus_confirm),
                    ),
                  ],
                ],
              ),
            ),
            Expanded(
              child: preparation == null
                  ? ListView.builder(
                      itemCount: _history.length,
                      itemBuilder: (context, i) {
                        final run = _history[i];
                        return ListTile(
                          leading: const Icon(Icons.history),
                          title: Text(
                            '${run['zip_name']} — ${DateFormat.yMd().add_Hm().format(DateTime.fromMillisecondsSinceEpoch(run['started_at'] as int))}',
                          ),
                          subtitle: Text(s.kobus_history),
                          onTap: _busy ? null : () => _showReport(run),
                        );
                      },
                    )
                  : ListView.builder(
                      itemCount: selected.length,
                      itemBuilder: (context, i) => _folder(selected[i], s),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _folder(KobusFolder folder, S s) => Card(
    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SelectableText(
            folder.sourcePath,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Text(folder.label),
          if (folder.rejection != null)
            Text('${s.kobus_rejected}: ${folder.rejection}')
          else ...[
            for (final warning in folder.identity!.warnings) Text(warning),
            Wrap(
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DropdownButton<KobusDecision>(
                  value: folder.decision,
                  onChanged: _busy
                      ? null
                      : (v) => setState(() {
                          folder.decision = v!;
                          if (v != KobusDecision.attach) folder.target = null;
                        }),
                  items: [
                    if (folder.candidates.isEmpty)
                      DropdownMenuItem(
                        value: KobusDecision.create,
                        child: Text(s.kobus_create),
                      ),
                    if (folder.candidates.isNotEmpty)
                      DropdownMenuItem(
                        value: KobusDecision.attach,
                        child: Text(s.kobus_attach),
                      ),
                    DropdownMenuItem(
                      value: KobusDecision.skip,
                      child: Text(s.kobus_skip),
                    ),
                    if (folder.candidates.isNotEmpty)
                      DropdownMenuItem(
                        value: KobusDecision.unresolved,
                        child: Text(s.kobus_unresolved),
                      ),
                  ],
                ),
                if (folder.decision == KobusDecision.attach &&
                    folder.target == null)
                  Text(s.kobus_chooseCandidate),
              ],
            ),
            if (folder.candidates.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text(s.kobus_source)),
                    DataColumn(label: Text(s.kobus_candidate)),
                    DataColumn(label: Text(s.kobus_provenance)),
                    DataColumn(label: Text(s.kobus_reason)),
                  ],
                  rows: folder.candidates
                      .map(
                        (candidate) => DataRow(
                          selected: folder.target == candidate,
                          onSelectChanged: _busy
                              ? null
                              : (_) => setState(() {
                                  folder.target = candidate;
                                  folder.decision = KobusDecision.attach;
                                }),
                          cells: [
                            DataCell(
                              Text(
                                '${folder.label}\n${folder.identity!.sex} • NIR : ${folder.identity!.nir ?? "—"}',
                              ),
                            ),
                            DataCell(
                              Text(
                                '${candidate.patient.displayName}\n${candidate.patient.birthDate ?? "—"} • ${candidate.patient.sexCode}\n${candidate.patient.nir ?? ""}',
                              ),
                            ),
                            DataCell(
                              Text(
                                candidate.sourcePath ??
                                    (candidate.patient.isArchived
                                        ? s.kobus_archived
                                        : s.kobus_existing),
                              ),
                            ),
                            DataCell(Text(candidate.reason)),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ],
      ),
    ),
  );
}

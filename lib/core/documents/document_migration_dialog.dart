import '../utils/file_size_format.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../../generated/l10n.dart';
import '../settings/documents_setup_dialog.dart';
import '../settings/macos_directory_access_service.dart';
import 'document_migration_gateway.dart';
import 'document_root_migration.dart';
import 'migration_dmp_analysis.dart';

Future<void> showDocumentStorageFlow(
  BuildContext context, {
  DocumentMigrationGateway? gateway,
}) async {
  final api = gateway ?? LocalDocumentMigrationGateway();
  final root = await api.root();
  if (!context.mounted) return;
  if (root == null || root.trim().isEmpty) {
    await showInitialDocumentsSetup(context);
  } else {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DocumentMigrationDialog(
        gateway: api,
        onQuit: () => windowManager.close(),
      ),
    );
  }
}

String migrationErrorText(S s, Object error) {
  final code = error is MigrationBlocked ? error.code : error.toString();
  if (code == 'cancelled') return s.migration_cancelled;
  if (error is DirectoryAuthorizationRequired) {
    return s.migration_authorizationMissing;
  }
  if (error is FileSystemException) return s.migration_access;
  if (code.contains('journal') ||
      code.contains('receipt') ||
      code.contains('recovery_') ||
      code.contains('root_conflict')) {
    return s.migration_corrupt;
  }
  if (code.contains('activity') || code.contains('busy')) {
    return s.migration_busy;
  }
  if (code.contains('transmission_uncertain')) {
    return s.migration_blockedTransmission;
  }
  if (code.contains('dv1_retry_continuity')) return s.migration_blockedRetry;
  if (code.contains('historical_evidence') ||
      code.contains('historical_document_dependency') ||
      code.contains('historical_dependency')) {
    return s.migration_blockedEvidence;
  }
  if (code.contains('transmission') ||
      code.contains('dv1') ||
      code.contains('clinical_source') ||
      code.contains('restore_barrier')) {
    return s.migration_blockedDmp;
  }
  return s.migration_blockedStorage;
}

class DocumentMigrationDialog extends StatefulWidget {
  const DocumentMigrationDialog({
    super.key,
    required this.gateway,
    this.recoveryOnly = false,
    this.onReady,
    this.onQuit,
  });
  final DocumentMigrationGateway gateway;
  final bool recoveryOnly;
  final VoidCallback? onReady, onQuit;
  @override
  State<DocumentMigrationDialog> createState() =>
      _DocumentMigrationDialogState();
}

class _DocumentMigrationDialogState extends State<DocumentMigrationDialog> {
  String phase = 'loading';
  String? source, destination, authorizationPath, returnFromOpen;
  bool enabled = false,
      invalidations = false,
      unknownSpace = false,
      changed = false;
  int done = 0, total = 0;
  bool showFiles = false;
  bool sourcesRetained = false;
  Object? error;
  DocumentMigrationPlan? plan;
  List<MigrationRecoveryDetails> details = [];
  MigrationCancellation? cancellation;
  bool get busy => [
    'loading',
    'planning',
    'preflight',
    'copy',
    'verifying',
    'activating',
    'cleaning',
    'recovering',
  ].contains(phase);
  bool get cancellable =>
      ['preflight', 'copy', 'verifying'].contains(phase) &&
      cancellation != null;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void update(VoidCallback body) {
    if (mounted) setState(body);
  }

  Future<void> _load() async {
    try {
      source = await widget.gateway.root();
      enabled = await widget.gateway.dmpEnabled();
      if (widget.recoveryOnly || widget.gateway.pending) {
        details = await widget.gateway.details();
        // recover() still verifies receipts and completed journals, even if there
        // are no unfinished entries. Never infer safety from an empty list.
        if (details.isEmpty) {
          await _recover();
          return;
        }
        authorizationPath = details.first.requiredRoot;
        update(() => phase = 'recovery');
      } else {
        update(() => phase = 'intro');
      }
    } catch (e) {
      _failed(e);
    }
  }

  void _failed(Object e) {
    update(() {
      error = e;
      phase = 'error';
      if (e is DirectoryAuthorizationRequired) {
        authorizationPath = e.path;
      } else if (e is FileSystemException && e.path?.isNotEmpty == true) {
        // Never authorize an arbitrary proof file or ancestor: exact known roots.
        final candidates = [
          source,
          destination,
          ...details.map((d) => d.requiredRoot),
        ];
        authorizationPath = candidates.contains(e.path) ? e.path : null;
      }
    });
  }

  Future<void> _choose() async {
    update(() {
      phase = 'planning';
      error = null;
    });
    try {
      final selected = await widget.gateway.choose(
        S.of(context).migration_choose,
      );
      if (selected == null) {
        update(() => phase = 'intro');
        return;
      }
      destination = selected;
      await _analyse();
    } catch (e) {
      _failed(e);
    }
  }

  Future<void> _analyse() async {
    update(() {
      phase = 'planning';
      invalidations = false;
      unknownSpace = false;
      error = null;
    });
    try {
      final next = await widget.gateway.plan(destination!);
      update(() {
        plan = next;
        phase = 'review';
      });
    } catch (e) {
      _failed(e);
    }
  }

  Future<void> _execute() async {
    final selected = plan!;
    cancellation = MigrationCancellation();
    update(() => phase = 'preflight');
    try {
      sourcesRetained = await widget.gateway.execute(
        selected,
        MigrationConsent(
          planHash: selected.hash,
          invalidations: invalidations,
          unknownSpace: unknownSpace,
        ),
        cancellation!,
        (next, n, max) {
          update(() {
            phase = next == 'completed' ? 'activating' : next;
            done = n;
            total = max;
          });
        },
      );
      // Only the returned, committed service result permits the success screen.
      documentRootRevision.value++;
      update(() => phase = 'success');
    } catch (e) {
      if (e is MigrationBlocked &&
          e.code == 'plan_changed' &&
          !widget.gateway.pending) {
        changed = true;
        await _analyse();
      } else {
        _failed(e);
        if (widget.gateway.pending) {
          try {
            details = await widget.gateway.details();
            authorizationPath ??= details.isEmpty
                ? null
                : details.first.requiredRoot;
            update(() {});
          } catch (_) {
            /* Keep original diagnostic. */
          }
        }
      }
    }
  }

  Future<void> _recover() async {
    update(() {
      phase = 'recovering';
      error = null;
    });
    try {
      final result = await widget.gateway.recover();
      source = await widget.gateway.root();
      if (plan == null) {
        for (final detail in details) {
          if (detail.committed &&
              result.any(
                (r) =>
                    r.id == detail.plan.id &&
                    ['committed', 'completed'].contains(r.state),
              )) {
            plan = detail.plan;
            break;
          }
        }
      }
      final committed =
          plan != null &&
          result.any(
            (r) =>
                r.id == plan!.id &&
                ['committed', 'completed'].contains(r.state),
          );
      sourcesRetained = result.any(
        (r) => r.id == plan?.id && r.sourcesRetained,
      );
      documentRootRevision.value++;
      update(() {
        phase = committed ? 'success' : 'recovered';
      });
    } catch (e) {
      _failed(e);
    }
  }

  Future<void> _authorize() async {
    final previous = phase;
    update(() => phase = 'planning');
    try {
      await widget.gateway.authorize(
        authorizationPath!,
        S.of(context).migration_authorize,
      );
      if (returnFromOpen != null) {
        await _open(plan!.destination);
      } else if (widget.recoveryOnly || widget.gateway.pending) {
        await _recover();
      } else if (destination != null) {
        await _analyse();
      } else {
        await _load();
      }
    } catch (e) {
      if (e is MigrationBlocked && e.code == 'cancelled') {
        update(() => phase = previous);
      } else {
        _failed(e);
      }
    }
  }

  Future<void> _open(String path) async {
    final previous = returnFromOpen ?? phase;
    update(() => phase = 'planning');
    try {
      await widget.gateway.open(path);
      update(() {
        phase = previous;
        returnFromOpen = null;
      });
    } catch (e) {
      returnFromOpen = previous;
      _failed(e);
    }
  }

  void _close() {
    if (widget.recoveryOnly) {
      widget.onReady?.call();
    } else {
      Navigator.of(context).pop();
    }
  }

  String _size(int bytes) {
    final s = S.of(context);
    return formatBinaryFileSize(
      bytes,
      locale: Localizations.localeOf(context).toString(),
      units: [
        s.migration_unit_bytes,
        s.migration_unit_kib,
        s.migration_unit_mib,
        s.migration_unit_gib,
        s.migration_unit_tib,
      ],
    );
  }

  Widget _fileDetails(DocumentMigrationPlan selected) {
    final files = showFiles
        ? selected.manifest.where((e) => e['directory'] == false).toList()
        : <Map<String, Object?>>[];
    return ExpansionTile(
      key: const ValueKey('migration-file-details'),
      title: Text(S.of(context).migration_fileDetails),
      onExpansionChanged: (value) => setState(() => showFiles = value),
      children: [
        if (showFiles)
          SizedBox(
            height: 220,
            child: ListView.builder(
              itemCount: files.length,
              itemBuilder: (_, index) => ListTile(
                title: SelectableText(files[index]['path'] as String),
                subtitle: Text(_size(files[index]['size'] as int)),
              ),
            ),
          ),
      ],
    );
  }

  Widget _impact(MigrationDmpImpact impact, {bool completed = false}) {
    final s = S.of(context), d = impact.data;
    int count(String k) => (d[k] as List?)?.length ?? 0;
    final has =
        count('documents') +
            count('preparingDocuments') +
            count('approvals') +
            count('controls') +
            count('acceptedDocuments') >
        0;
    if (!has) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        if (!enabled) Text(s.migration_historical),
        Text(
          completed
              ? s.migration_impactCompleted(
                  count('documents'),
                  count('approvals'),
                  count('controls'),
                )
              : s.migration_impact(
                  count('documents'),
                  count('approvals'),
                  count('controls'),
                ),
        ),
        if (count('preparingDocuments') > 0)
          Text(s.migration_preparing(count('preparingDocuments'))),
        if (count('remainingDocuments') > 0)
          Text(s.migration_remaining(count('remainingDocuments'))),
        if (count('acceptedDocuments') > 0)
          Text(s.migration_accepted(count('acceptedDocuments'))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final title = switch (phase) {
      'success' => s.migration_success,
      'review' => s.migration_review,
      'dmp' => s.migration_dmpTitle,
      'recovery' || 'recovering' || 'recovered' => s.migration_recovery,
      'error' => s.migration_error,
      _ => s.migration_title,
    };
    final children = <Widget>[];
    final actions = <Widget>[];
    Widget button(
      String key,
      String text,
      VoidCallback? action, {
      bool primary = false,
    }) => primary
        ? FilledButton(key: ValueKey(key), onPressed: action, child: Text(text))
        : TextButton(key: ValueKey(key), onPressed: action, child: Text(text));
    if (busy) {
      final label = switch (phase) {
        'copy' => s.migration_copy,
        'verifying' => s.migration_verifying,
        'activating' => s.migration_activating,
        'cleaning' => s.migration_cleaning,
        _ => s.migration_preflight,
      };
      children.addAll([
        Text(label),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: ['copy', 'cleaning'].contains(phase) && total > 0
              ? done / total
              : null,
        ),
        if (['copy', 'cleaning'].contains(phase) && total > 0)
          Text(s.migration_counter(done, total)),
        const SizedBox(height: 12),
        Text(s.migration_intro),
      ]);
      if (cancellable) {
        actions.add(
          button(
            'migration-cancel-copy',
            s.migration_cancel,
            () => update(() => cancellation!.cancelled = true),
          ),
        );
      }
    } else if (phase == 'intro' || phase == 'dmp') {
      children.add(
        Text(phase == 'dmp' ? s.migration_dmpMessage : s.migration_intro),
      );
      actions.add(button('migration-cancel', s.migration_cancel, _close));
      actions.add(
        button(
          'migration-continue',
          phase == 'dmp' ? s.migration_continue : s.migration_choose,
          () {
            if (phase == 'intro' && enabled) {
              setState(() => phase = 'dmp');
            } else {
              _choose();
            }
          },
          primary: true,
        ),
      );
    } else if (phase == 'review') {
      final p = plan!, d = p.data;
      if (changed) {
        children.add(
          Text(s.migration_changed, key: const ValueKey('migration-changed')),
        );
      }
      children.addAll([
        Text(s.migration_intro),
        SelectableText(s.migration_roots(p.source, p.destination)),
        const SizedBox(height: 12),
        Text(
          s.migration_counts(
            p.associations.length,
            d['files'],
            _size(d['bytes'] as int),
          ),
        ),
        Text(s.migration_fileCountExplanation),
        _fileDetails(p),
        if ((d['historicalEmptyRoots'] as List?)?.isNotEmpty == true)
          Text(
            s.migration_historicalRoots(
              (d['historicalEmptyRoots'] as List).length,
            ),
          ),
        if ((d['foreignEntries'] as List).isNotEmpty)
          Text(s.migration_foreign((d['foreignEntries'] as List).length)),
        _impact(p.dmp),
        if (p.dmp.requiresConsent)
          CheckboxListTile(
            key: const ValueKey('migration-invalidations'),
            value: invalidations,
            onChanged: (v) => setState(() => invalidations = v!),
            title: Text(s.migration_consent),
          ),
        if (d['spaceUnknown'] == true)
          CheckboxListTile(
            key: const ValueKey('migration-space'),
            value: unknownSpace,
            onChanged: (v) => setState(() => unknownSpace = v!),
            title: Text(s.migration_spaceConsent),
          ),
      ]);
      actions.add(button('migration-cancel', s.migration_cancel, _close));
      actions.add(
        button(
          'migration-confirm',
          s.migration_confirm,
          (!p.dmp.requiresConsent || invalidations) &&
                  (d['spaceUnknown'] != true || unknownSpace)
              ? _execute
              : null,
          primary: true,
        ),
      );
    } else if (phase == 'success') {
      final p = plan!;
      children.addAll([
        SelectableText(p.destination),
        Text(
          s.migration_counts(
            p.associations.length,
            p.data['files'],
            _size(p.data['bytes'] as int),
          ),
        ),
        Text(s.migration_fileCountExplanation),
        _fileDetails(p),
        Text(sourcesRetained ? s.migration_cleanupWarning : s.migration_moved),
        if (p.dmp.requiresConsent) Text(s.migration_renew),
        _impact(p.dmp, completed: true),
      ]);
      actions.add(
        button('migration-open', s.migration_open, () => _open(p.destination)),
      );
      actions.add(
        button('migration-close', s.migration_close, _close, primary: true),
      );
    } else if (phase == 'recovery') {
      for (final d in details) {
        children.addAll([
          Text(
            d.committed ? s.migration_afterCommit : s.migration_beforeCommit,
          ),
          SelectableText(s.migration_roots(d.plan.source, d.plan.destination)),
        ]);
      }
      actions.add(
        button(
          'migration-recover',
          details.every((d) => !d.committed)
              ? s.migration_abandon
              : s.migration_recoverAction,
          _recover,
          primary: true,
        ),
      );
    } else if (phase == 'recovered') {
      children.addAll([
        Text(s.migration_recovered),
        if (source != null) SelectableText(source!),
      ]);
      actions.add(
        button('migration-ready', s.migration_continue, _close, primary: true),
      );
    } else if (phase == 'error') {
      children.add(Text(migrationErrorText(s, error!)));
      if (widget.gateway.pending) {
        children.add(
          Text(
            details.any((d) => d.committed)
                ? s.migration_afterCommit
                : s.migration_recovery,
          ),
        );
      }
      if (error is MigrationBlocked &&
          (error as MigrationBlocked).dmp != null) {
        children.add(_impact((error as MigrationBlocked).dmp!));
      }
      children.add(
        ExpansionTile(
          title: Text(s.migration_technical),
          children: [SelectableText(error.toString())],
        ),
      );
      if (authorizationPath != null) {
        children.add(SelectableText(authorizationPath!));
      }
      if (widget.gateway.canAuthorize && authorizationPath != null) {
        actions.add(
          button('migration-authorize', s.migration_authorize, _authorize),
        );
      }
      actions.add(
        button(
          'migration-retry',
          widget.gateway.pending &&
                  details.isNotEmpty &&
                  details.every((d) => !d.committed)
              ? s.migration_abandon
              : s.migration_retry,
          () => returnFromOpen != null
              ? _open(plan!.destination)
              : widget.recoveryOnly || widget.gateway.pending
              ? _recover()
              : _choose(),
        ),
      );
      if (!widget.recoveryOnly && !widget.gateway.pending) {
        actions.add(button('migration-close', s.migration_close, _close));
      }
    }
    if ((widget.recoveryOnly || widget.gateway.pending) && !busy) {
      actions.add(button('migration-quit', s.migration_quit, widget.onQuit));
    }
    return PopScope(
      canPop: !busy && !widget.gateway.pending && !widget.recoveryOnly,
      child: AlertDialog(
        title: Text(title),
        content: SizedBox(
          width: 620,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: children,
            ),
          ),
        ),
        actions: actions,
      ),
    );
  }
}

class DocumentStorageTile extends StatefulWidget {
  const DocumentStorageTile({super.key, this.gateway});
  final DocumentMigrationGateway? gateway;
  @override
  State<DocumentStorageTile> createState() => _DocumentStorageTileState();
}

class _DocumentStorageTileState extends State<DocumentStorageTile> {
  late final api = widget.gateway ?? LocalDocumentMigrationGateway();
  String? root;
  bool busy = true;
  Object? error;
  @override
  void initState() {
    super.initState();
    documentRootRevision.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    documentRootRevision.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final value = await api.root();
      if (mounted) {
        setState(() {
          root = value;
          busy = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = e;
          busy = false;
        });
      }
    }
  }

  Future<void> _action(bool open) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      if (open) {
        await api.open(root!);
      } else {
        if (!mounted) return;
        await showDocumentStorageFlow(context, gateway: api);
      }
      await _load();
    } catch (e) {
      if (mounted) setState(() => error = e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final configured = root != null && root!.trim().isNotEmpty;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: const Icon(Icons.folder_outlined),
          title: Text(s.migration_folder),
          subtitle: SelectableText(
            configured ? root! : s.migration_unconfigured,
          ),
        ),
        if (error != null) Text(migrationErrorText(s, error!)),
        Wrap(
          spacing: 8,
          children: [
            OutlinedButton(
              key: const ValueKey('storage-move'),
              onPressed: busy ? null : () => _action(false),
              child: Text(
                configured ? s.migration_move : s.migration_configure,
              ),
            ),
            if (configured)
              OutlinedButton(
                key: const ValueKey('storage-open'),
                onPressed: busy ? null : () => _action(true),
                child: Text(s.migration_open),
              ),
            if (configured &&
                error is DirectoryAuthorizationRequired &&
                api.canAuthorize)
              OutlinedButton(
                key: const ValueKey('storage-authorize'),
                onPressed: busy
                    ? null
                    : () async {
                        try {
                          await api.authorize(root!, s.migration_authorize);
                          if (mounted) setState(() => error = null);
                        } catch (e) {
                          if (mounted) setState(() => error = e);
                        }
                      },
                child: Text(s.migration_authorize),
              ),
          ],
        ),
      ],
    );
  }
}

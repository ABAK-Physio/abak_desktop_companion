import 'administrative_access_service.dart';
import 'administrative_access_prompt.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'companion_access_service.dart';
import 'patient_access_service.dart';

class _PatientRoute {
  _PatientRoute(this.patientId, this.cancel);
  _PatientRoute.administrative(this.section, this.cancel) : patientId = null;
  final String? patientId;
  String? section;
  AdministrativeAccessDecision? administrativeState;
  bool get allowed => patientId == null
      ? administrativeState?.allowed == true
      : state?.allowed == true;
  final VoidCallback cancel;
  PatientAccessState? state;
  String? error;
  int revision = 0;
  bool opened = false;
}

/// One boundary above the root Navigator also masks dialogs and document routes
/// pushed above the patient. The identity banner remains outside this boundary.
class PatientAccessBoundary extends StatefulWidget {
  const PatientAccessBoundary({
    super.key,
    required this.child,
    this.service,
    this.administrativeService,
  });
  final Widget child;
  final PatientAccessService? service;
  final AdministrativeAccessService? administrativeService;
  static PatientAccessService serviceOf(BuildContext context) =>
      _PatientAccessHost.of(context).service;
  static AdministrativeAccessService administrativeServiceOf(
    BuildContext context,
  ) => _PatientAccessHost.of(context).administrativeService;
  @override
  State<PatientAccessBoundary> createState() => _PatientAccessBoundaryState();
}

class _PatientAccessBoundaryState extends State<PatientAccessBoundary> {
  late final PatientAccessService service =
      widget.service ?? PatientAccessService();
  late final AdministrativeAccessService administrativeService =
      widget.administrativeService ??
      AdministrativeAccessService(session: service.session);
  final routes = <_PatientRoute>[];
  late final surface = OverlayEntry(builder: content);

  @override
  void initState() {
    super.initState();
    service.addListener(_refreshAll);
    administrativeService.addListener(_refreshAll);
  }

  void _refreshAll() {
    for (final route in routes) {
      route.state = null;
      route.administrativeState = null;
      route.error = null;
      _refresh(route);
    }
    if (mounted) setState(() {});
  }

  Future<void> _refresh(_PatientRoute route) async {
    final revision = ++route.revision;
    try {
      final state = route.patientId == null
          ? null
          : await service.inspect(route.patientId!);
      final adminState = route.patientId == null
          ? await administrativeService.inspect()
          : null;
      if (!mounted || !routes.contains(route) || revision != route.revision) {
        return;
      }
      setState(() {
        route.state = state;
        route.administrativeState = adminState;
        route.opened |= route.allowed;
      });
    } catch (error) {
      if (!mounted || !routes.contains(route) || revision != route.revision) {
        return;
      }
      setState(
        () => route.error = error is CompanionAccessException
            ? error.message
            : 'Impossible de vérifier les droits d’accès. Réessayez.',
      );
    }
  }

  void add(_PatientRoute route) {
    setState(() => routes.add(route));
    _refresh(route);
  }

  void remove(_PatientRoute route) {
    routes.remove(route);
    // Route disposal can happen while Navigator is building.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    service.removeListener(_refreshAll);
    administrativeService.removeListener(_refreshAll);
    if (widget.administrativeService == null) administrativeService.dispose();
    if (widget.service == null) service.dispose();
    surface.remove();
    surface.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    surface.markNeedsBuild();
    return Overlay(initialEntries: [surface]);
  }

  Widget content(BuildContext context) {
    // Every retained scope must remain authorized: an underlying settings
    // page can be exposed by a dialog or route's closing animation.
    final top = routes.where((route) => !route.allowed).lastOrNull;
    final blocked = top != null && !top.allowed;
    return _PatientAccessHost(
      boundary: this,
      // Rebuild scopes on authorization without constructing their clinical
      // content before the first successful check.
      revision: Object(),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExcludeFocus(
            excluding: blocked,
            child: Offstage(offstage: blocked, child: widget.child),
          ),
          if (blocked)
            Material(
              color: Theme.of(context).colorScheme.surface,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: 480,
                    child: top.patientId == null
                        ? AdministrativeAccessPrompt(
                            key: ValueKey((top, service.session.sessionId)),
                            state: top.administrativeState,
                            error: top.error,
                            section: top.section!,
                            service: administrativeService,
                            cancel: top.cancel,
                            retry: () {
                              setState(() => top.error = null);
                              _refresh(top);
                            },
                          )
                        : _PatientAccessPrompt(
                            key: ValueKey((top, service.session.sessionId)),
                            route: top,
                            service: service,
                            retry: () {
                              setState(() => top.error = null);
                              _refresh(top);
                            },
                          ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PatientAccessHost extends InheritedWidget {
  const _PatientAccessHost({
    required this.boundary,
    required this.revision,
    required super.child,
  });
  final _PatientAccessBoundaryState boundary;
  final Object revision;
  static _PatientAccessBoundaryState of(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_PatientAccessHost>()!
      .boundary;
  @override
  bool updateShouldNotify(_PatientAccessHost oldWidget) =>
      revision != oldWidget.revision;
}

class PatientAccessScope extends StatefulWidget {
  const PatientAccessScope({
    super.key,
    required this.patientId,
    required this.builder,
  }) : section = null,
       onCancel = null;
  const PatientAccessScope.administrative({
    super.key,
    required this.section,
    required this.builder,
    this.onCancel,
  }) : patientId = null;
  final String? patientId;
  final String? section;
  final VoidCallback? onCancel;
  final WidgetBuilder builder;
  @override
  State<PatientAccessScope> createState() => _PatientAccessScopeState();
}

class _PatientAccessScopeState extends State<PatientAccessScope> {
  _PatientAccessBoundaryState? boundary;
  _PatientRoute? entry;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final host = _PatientAccessHost.of(context);
    if (boundary == host) return;
    if (entry != null) boundary?.remove(entry!);
    boundary = host;
    final route = ModalRoute.of(context)!;
    final navigator = Navigator.of(context);
    void cancel() {
      navigator.popUntil((candidate) => candidate == route);
      if (widget.onCancel != null) {
        widget.onCancel!();
      } else if (navigator.canPop()) {
        navigator.pop();
      }
    }

    final created = widget.patientId == null
        ? _PatientRoute.administrative(widget.section!, cancel)
        : _PatientRoute(widget.patientId!, cancel);
    entry = created;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && entry == created) host.add(created);
    });
  }

  @override
  void dispose() {
    if (entry != null) boundary?.remove(entry!);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      entry?.opened == true ? widget.builder(context) : const SizedBox.shrink();
}

class _PatientAccessPrompt extends StatefulWidget {
  const _PatientAccessPrompt({
    super.key,
    required this.route,
    required this.service,
    required this.retry,
  });
  final _PatientRoute route;
  final PatientAccessService service;
  final VoidCallback retry;
  @override
  State<_PatientAccessPrompt> createState() => _PatientAccessPromptState();
}

class _PatientAccessPromptState extends State<_PatientAccessPrompt> {
  final code = TextEditingController();
  PatientAccessReason? reason;
  bool emergency = false, busy = false;
  String? error;
  @override
  void dispose() {
    code.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (busy || reason == null) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await widget.service.grantException(
        patientId: widget.route.patientId!,
        code: code.text,
        reason: reason!,
      );
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is CompanionAccessException
              ? e.message
              : 'L’accès n’a pas pu être enregistré. Réessayez.',
        );
      }
    } finally {
      if (mounted) {
        code.clear();
        setState(() => busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.route.state;
    final failure = widget.route.error;
    final identify = state?.decision == PatientAccessDecision.identification;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.lock_outline, size: 36),
        const SizedBox(height: 16),
        if (failure != null) ...[
          Text(failure),
          TextButton(onPressed: widget.retry, child: const Text('Réessayer')),
        ] else if (state == null) ...[
          const Center(child: CircularProgressIndicator()),
          const SizedBox(height: 12),
          const Text('Vérification de l’accès…', textAlign: TextAlign.center),
        ] else if (identify) ...[
          const Text(
            'Identifiez-vous dans le bandeau pour ouvrir ce dossier.',
            textAlign: TextAlign.center,
          ),
        ] else ...[
          Text(
            state.referrerId == null
                ? 'Ce dossier est non affecté.'
                : 'Vous n’êtes pas le kiné référent.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (emergency) ...[
            const SizedBox(height: 16),
            const Text(
              'Cet accès sera limité à la session en cours et son motif sera enregistré.',
            ),
            const SizedBox(height: 12),
            const Text('Motif obligatoire'),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in state.reasons)
                  ChoiceChip(
                    label: Text(item.label),
                    selected: reason == item,
                    onSelected: busy
                        ? null
                        : (_) => setState(() => reason = item),
                  ),
              ],
            ),
            TextField(
              controller: code,
              obscureText: true,
              enabled: !busy,
              keyboardType: TextInputType.number,
              maxLength: 4,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                labelText: 'Code Companion du kiné actif',
              ),
              onSubmitted: (_) => submit(),
            ),
            if (error != null)
              Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            FilledButton(
              onPressed: busy || reason == null ? null : submit,
              child: Text(busy ? 'Vérification…' : 'Autoriser l’accès'),
            ),
          ] else ...[
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => setState(() => emergency = true),
              child: const Text('Urgence'),
            ),
          ],
        ],
        TextButton(
          onPressed: busy ? null : widget.route.cancel,
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}

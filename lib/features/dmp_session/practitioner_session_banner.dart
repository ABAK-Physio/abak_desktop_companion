import '../companion_access/companion_access_service.dart';
import '../companion_access/recovery_key_screen.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../companion_access/companion_session.dart';
import '../cps/cps_operation_lease.dart';
import '../dmp_setup/dmp_setup_service.dart';
import '../practitioners/data/practitioner_repository.dart';
import '../practitioners/models/practitioner.dart';
import 'inactivity_lock.dart';

/// Local identification, never CPS authentication or a change of report author.
/// Above the Navigator: pushed routes cannot cover the lock or identity prompt.
class PractitionerSessionBanner extends StatefulWidget {
  const PractitionerSessionBanner({
    super.key,
    required this.child,
    this.loadEnabled,
    this.loadIdleMinutes,
    this.now,
    this.loadPractitioners,
    this.session,
    this.onIdentityChanged,
  });
  final Future<bool> Function()? loadEnabled;
  final Future<int> Function()? loadIdleMinutes;
  final DateTime Function()? now;
  final Future<List<Practitioner>> Function()? loadPractitioners;
  final CompanionSession? session;

  /// Close the former practitioner's routes only after successful identification
  /// as someone else, logout, or DMP deactivation. Same-person unlock keeps drafts.
  final VoidCallback? onIdentityChanged;
  final Widget child;
  @override
  State<PractitionerSessionBanner> createState() => _SessionState();
}

class _SessionState extends State<PractitionerSessionBanner>
    with WidgetsBindingObserver {
  late final session = widget.session ?? CompanionSession.current;
  late final inactivity = InactivityLock(onExpired: expire, now: widget.now);
  late final surface = OverlayEntry(builder: content);
  final pin = TextEditingController(), confirmation = TextEditingController();
  bool recovering = false;
  bool choosing = false, busy = false, creatingCode = false;
  bool wasEnabled = false, wasLocked = false;
  int configurationRevision = 0, operationRevision = 0, idleMinutes = 15;
  Timer? deferredLock;
  Practitioner? practitioner, candidate;
  List<Practitioner> choices = [];
  String? message;
  bool get enabled => session.enabled;
  bool get canAutoLock => session.authenticated;
  bool get gated => session.locked || choosing || candidate != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HardwareKeyboard.instance.addHandler(onKey);
    session.addListener(sessionChanged);
    DmpSetupService.changes.addListener(configurationChanged);
    CompanionAccessService.recoveryCompleted.addListener(recoveryFinished);
    CompanionAccessService.practitionerArchived.addListener(practitionerDeparted);
    load();
  }

  void practitionerDeparted() {
    final id = CompanionAccessService.practitionerArchived.value;
    if (!mounted || id == null) return;
    choices.removeWhere((p) => p.practitionerId == id);
    if (practitioner?.practitionerId != id && candidate?.practitionerId != id) return;
    operationRevision++;
    inactivity.stop();
    deferredLock?.cancel();
    clearCodes();
    setState(() {
      practitioner = candidate = null;
      choosing = creatingCode = busy = false;
      message = 'Ce kiné a été archivé. Sélectionnez un autre kiné.';
    });
    // The departure screen may still need to show its export receipt. The
    // access boundary already masks clinical routes after session invalidation.
  }

  void recoveryFinished() {
    if (!mounted || !enabled) return;
    operationRevision++;
    inactivity.stop();
    deferredLock?.cancel();
    clearCodes();
    setState(() {
      practitioner = candidate = null;
      choosing = creatingCode = false;
      message = 'Accès administrateur rétabli. Identifiez-vous avec le nouveau code Companion.';
    });
    widget.onIdentityChanged?.call();
  }

  void clearCodes() {
    pin.clear();
    confirmation.clear();
  }

  void sessionChanged() {
    if (!mounted) return;
    final deactivated = wasEnabled && !enabled;
    final justLocked = !wasLocked && session.locked;
    wasEnabled = enabled;
    wasLocked = session.locked;
    if (!enabled || justLocked) {
      operationRevision++;
      inactivity.stop();
      deferredLock?.cancel();
      clearCodes();
      choosing = busy = creatingCode = false;
      candidate = null;
      if (!enabled) { practitioner = null; recovering = false; }
    }
    setState(() {});
    if (deactivated) widget.onIdentityChanged?.call();
  }

  void configurationChanged() {
    operationRevision++;
    session.cancelAuthentication();
    if (mounted) setState(() => busy = false);
    load();
  }

  Future<void> load() async {
    final revision = ++configurationRevision;
    try {
      final value = await (widget.loadEnabled ?? DmpSetupService().enabled)();
      final minutes =
          await (widget.loadIdleMinutes ?? DmpSetupService().idleMinutes)();
      if (!mounted || revision != configurationRevision) return;
      final changed = enabled != value || idleMinutes != minutes;
      idleMinutes = minutes;
      session.setEnabled(value);
      setState(() {});
      if (changed) restartIdle();
    } catch (_) {
      // Keep an existing lock when configuration cannot be read.
      if (mounted && revision == configurationRevision) {
        setState(() => message = 'Configuration DMP indisponible.');
      }
    }
  }

  void restartIdle() {
    deferredLock?.cancel();
    if (canAutoLock) {
      inactivity.start(Duration(minutes: idleMinutes));
    } else {
      inactivity.stop();
    }
  }

  void expire() {
    if (!mounted || !canAutoLock) return;
    if (busy || CpsOperationLease.inUse) {
      // Finish an actual card/network operation before changing its context.
      deferredLock = Timer(const Duration(seconds: 1), expire);
      return;
    }
    lock();
  }

  void recordActivity() {
    if (deferredLock?.isActive == true && canAutoLock) restartIdle();
    inactivity.activity();
  }

  bool onKey(KeyEvent event) {
    if (event is KeyDownEvent || event is KeyRepeatEvent) recordActivity();
    return false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) inactivity.check();
  }

  bool current(int revision) =>
      mounted && enabled && revision == operationRevision;

  Future<void> choose() async {
    if (busy || !enabled) return;
    if (CpsOperationLease.inUse) {
      setState(
        () =>
            message = 'Terminez l’opération CPS avant de changer de praticien.',
      );
      return;
    }
    final revision = ++operationRevision;
    session.cancelAuthentication();
    FocusManager.instance.primaryFocus?.unfocus();
    clearCodes();
    setState(() {
      busy = true;
      message = null;
    });
    try {
      final result =
          await (widget.loadPractitioners ??
              PractitionerRepository().getActivePractitioners)();
      if (!current(revision)) return;
      setState(() {
        choices = result;
        choosing = true;
        candidate = null;
        creatingCode = false;
      });
    } catch (_) {
      if (current(revision)) {
        setState(() => message = 'Impossible de charger les praticiens.');
      }
    } finally {
      if (current(revision)) setState(() => busy = false);
    }
  }

  Future<void> select(Practitioner value) async {
    if (busy) return;
    final revision = ++operationRevision;
    clearCodes();
    setState(() {
      busy = true;
      message = null;
    });
    try {
      final hasCode = await session.access.hasPersonalCode(
        value.practitionerId,
      );
      if (!current(revision)) return;
      setState(() {
        candidate = value;
        choosing = false;
        creatingCode = !hasCode;
      });
    } catch (e) {
      if (current(revision)) {
        setState(
          () => message = e is CompanionAccessException
              ? e.message
              : 'Impossible de sélectionner ce praticien.',
        );
      }
    } finally {
      if (current(revision)) setState(() => busy = false);
    }
  }

  void cancel() {
    if (busy) return;
    operationRevision++;
    session.cancelAuthentication();
    clearCodes();
    setState(() {
      candidate = null;
      choosing = creatingCode = false;
      message = null;
    });
  }

  void lock() {
    if (!session.lock()) {
      setState(
        () => message = 'Terminez l’opération CPS avant de verrouiller.',
      );
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => message = null);
  }

  void signOut() {
    if (busy) return;
    if (!session.signOut()) {
      setState(
        () => message = 'Terminez l’opération CPS avant de vous déconnecter.',
      );
      return;
    }
    operationRevision++;
    inactivity.stop();
    deferredLock?.cancel();
    clearCodes();
    setState(() {
      practitioner = candidate = null;
      choosing = creatingCode = false;
      message = null;
    });
    widget.onIdentityChanged?.call();
  }

  Future<void> authenticate() async {
    final target = candidate ?? practitioner;
    if (busy || !enabled || target == null) return;
    var secret = pin.text;
    if (!CompanionAccessService.validCode(secret)) {
      setState(
        () => message = 'Saisissez votre code Companion à quatre chiffres.',
      );
      return;
    }
    if (creatingCode && secret != confirmation.text) {
      setState(() => message = 'Les deux nouveaux codes sont différents.');
      return;
    }
    final revision = ++operationRevision;
    final previousId = session.practitionerId;
    final needsCreation = creatingCode;
    clearCodes();
    setState(() {
      busy = true;
      message = null;
    });
    try {
      if (needsCreation) {
        await session.access.createCode(target.practitionerId, secret);
        if (!current(revision)) return;
        setState(() => creatingCode = false);
      }
      await session.signIn(target.practitionerId, secret);
      if (!current(revision)) return;
      // Clear the old practitioner's navigation before removing the overlay.
      if (previousId != target.practitionerId) widget.onIdentityChanged?.call();
      setState(() {
        practitioner = target;
        candidate = null;
        choosing = creatingCode = false;
      });
      restartIdle();
    } catch (e) {
      if (current(revision)) {
        setState(
          () => message = e is CompanionAccessException
              ? e.message
              : 'Identification impossible. Réessayez.',
        );
      }
    } finally {
      secret = '';
      if (current(revision)) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    session.removeListener(sessionChanged);
    session.setEnabled(false);
    session.cancelAuthentication();
    inactivity.stop();
    deferredLock?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    HardwareKeyboard.instance.removeHandler(onKey);
    DmpSetupService.changes.removeListener(configurationChanged);
    CompanionAccessService.recoveryCompleted.removeListener(recoveryFinished);
    CompanionAccessService.practitionerArchived.removeListener(practitionerDeparted);
    configurationRevision++;
    operationRevision++;
    clearCodes();
    pin.dispose();
    confirmation.dispose();
    surface.remove();
    surface.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    surface.markNeedsBuild();
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => recordActivity(),
      onPointerMove: (_) => recordActivity(),
      onPointerHover: (_) => recordActivity(),
      onPointerSignal: (_) => recordActivity(),
      child: Overlay(initialEntries: [surface]),
    );
  }

  Widget codeField(TextEditingController controller, String label) => TextField(
    controller: controller,
    obscureText: true,
    enableSuggestions: false,
    autocorrect: false,
    enabled: !busy,
    keyboardType: TextInputType.number,
    inputFormatters: [
      FilteringTextInputFormatter.digitsOnly,
      LengthLimitingTextInputFormatter(4),
    ],
    decoration: InputDecoration(labelText: label),
    onSubmitted: (_) => authenticate(),
  );

  Widget content(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      if (enabled)
        Material(
          color: Theme.of(context).colorScheme.primaryContainer,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                children: [
                  const Icon(Icons.person_outline, size: 20),
                  Text(
                    practitioner == null
                        ? 'Praticien non sélectionné'
                        : session.locked
                        ? 'Session verrouillée : ${practitioner!.displayName}'
                        : 'Kiné actif : ${practitioner!.displayName}',
                  ),
                  TextButton(
                    onPressed: busy ? null : choose,
                    child: Text(
                      practitioner == null
                          ? 'Choisir le praticien'
                          : 'Changer de praticien',
                    ),
                  ),
                  TextButton(
                    onPressed: busy || CpsOperationLease.inUse ? null : () => setState(() => recovering = true),
                    child: const Text('Clé de récupération'),
                  ),
                  if (session.authenticated)
                    TextButton.icon(
                      onPressed: busy ? null : lock,
                      icon: const Icon(Icons.lock_outline, size: 18),
                      label: const Text('Verrouiller'),
                    ),
                  if (practitioner != null)
                    TextButton(
                      onPressed: busy ? null : signOut,
                      child: const Text('Déconnecter'),
                    ),
                ],
              ),
            ),
          ),
        ),
      if (enabled && message != null)
        Material(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(message!),
          ),
        ),
      Expanded(
        key: const ValueKey('session-content'),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Offstage(
              offstage: gated || recovering,
              child: TickerMode(
                enabled: !gated && !recovering,
                child: ExcludeFocus(excluding: gated || recovering, child: widget.child),
              ),
            ),
            if (recovering)
              Material(child: RecoveryKeyPanel(service: session.access, onClose: () {
                setState(() => recovering = false);
              })),
            if (gated && !recovering)
              Material(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: choosing
                            ? [
                                const Text('Choisir le praticien'),
                                const Text(
                                  'La sélection nécessite le code personnel Companion, sans lecture de la CPS.',
                                ),
                                if (choices.isEmpty)
                                  const Text(
                                    'Aucun praticien actif. Ajoutez-le depuis la liste des kinés.',
                                  ),
                                for (final value in choices)
                                  ListTile(
                                    title: Text(value.displayName),
                                    onTap: busy ? null : () => select(value),
                                  ),
                                TextButton(
                                  onPressed: busy ? null : cancel,
                                  child: const Text('Annuler'),
                                ),
                              ]
                            : [
                                Icon(
                                  session.locked && candidate == null
                                      ? Icons.lock_outline
                                      : Icons.person_outline,
                                  size: 40,
                                ),
                                Text(
                                  session.locked && candidate == null
                                      ? 'Companion verrouillé'
                                      : 'Identification : ${candidate?.displayName ?? practitioner?.displayName ?? ''}',
                                ),
                                if (session.locked && candidate == null)
                                  Text(
                                    'Saisissez le code Companion de ${practitioner?.displayName ?? ''}. Les saisies restent conservées à l’écran.',
                                  ),
                                if (candidate != null &&
                                    candidate!.practitionerId !=
                                        session.practitionerId)
                                  const Text(
                                    'Enregistrez vos saisies avant de changer de kiné : les écrans ouverts seront fermés après identification. Annulez pour y revenir.',
                                  ),
                                if (creatingCode)
                                  const Text(
                                    'Créez votre code personnel Companion à quatre chiffres. Ce code est distinct de l’authentification CPS.',
                                  ),
                                codeField(
                                  pin,
                                  creatingCode
                                      ? 'Nouveau code Companion'
                                      : 'Code personnel Companion',
                                ),
                                if (creatingCode)
                                  codeField(
                                    confirmation,
                                    'Confirmer le nouveau code',
                                  ),
                                const SizedBox(height: 12),
                                FilledButton(
                                  onPressed: busy ? null : authenticate,
                                  child: Text(
                                    creatingCode
                                        ? 'Créer mon code et m’identifier'
                                        : session.locked && candidate == null
                                        ? 'Déverrouiller'
                                        : 'S’identifier',
                                  ),
                                ),
                                if (candidate != null)
                                  TextButton(
                                    onPressed: busy ? null : cancel,
                                    child: const Text('Annuler'),
                                  ),
                                if (busy)
                                  const Padding(
                                    padding: EdgeInsets.all(12),
                                    child: LinearProgressIndicator(),
                                  ),
                                const SizedBox(height: 8),
                                const Text(
                                  'La CPS reste nécessaire pour les opérations DMP qui l’exigent.',
                                ),
                              ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ],
  );
}

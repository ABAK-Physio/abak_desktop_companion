import 'dart:async';
import 'inactivity_lock.dart';
import 'dmp_work_context.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/database/database_service.dart';
import '../cps/cps_access_service.dart';
import '../cps/cps_profile.dart';
import '../cps/cps_operation_lease.dart';
import '../dmp_setup/dmp_setup_service.dart';
import '../practitioners/data/practitioner_repository.dart';
import '../practitioners/data/practitioner_cps_service.dart';
import '../practitioners/models/practitioner.dart';

/// Work context only: never grants DMP rights or changes report authorship.
/// Lives above the Navigator so pushed routes and dialogs cannot cover the lock.
class PractitionerSessionBanner extends StatefulWidget {
  const PractitionerSessionBanner({
    super.key,
    required this.child,
    this.loadEnabled,
    this.loadIdleMinutes,
    this.now,
    this.loadPractitioners,
    this.loadNationalId,
    this.readCard,
  });
  final Future<bool> Function()? loadEnabled;
  final Future<int> Function()? loadIdleMinutes;
  final DateTime Function()? now;
  final Future<List<Practitioner>> Function()? loadPractitioners;
  final Future<String?> Function(String)? loadNationalId;
  final Future<CpsProfile> Function(String)? readCard;
  final Widget child;
  @override
  State<PractitionerSessionBanner> createState() => _SessionState();
}

class _SessionState extends State<PractitionerSessionBanner>
    with WidgetsBindingObserver {
  bool enabled = false, choosing = false, locked = false, busy = false;
  int revision = 0, idleMinutes = 15;
  Timer? deferredLock;
  late final inactivity = InactivityLock(onExpired: expire, now: widget.now);

  bool get canAutoLock =>
      enabled &&
      !locked &&
      practitioner != null &&
      nationalId != null &&
      (Platform.isMacOS || widget.readCard != null);

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
      // Do not interrupt a card/network operation whose outcome may be unknown.
      deferredLock = Timer(const Duration(seconds: 1), expire);
      return;
    }
    choosing = false;
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

  Practitioner? practitioner;
  String? nationalId, message;
  List<Practitioner> choices = [];
  final pin = TextEditingController();
  late final surface = OverlayEntry(builder: content);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    HardwareKeyboard.instance.addHandler(onKey);
    DmpSetupService.changes.addListener(load);
    load();
  }

  Future<void> load() async {
    final current = ++revision;
    try {
      final value = await (widget.loadEnabled ?? DmpSetupService().enabled)();
      final minutes =
          await (widget.loadIdleMinutes ?? DmpSetupService().idleMinutes)();
      if (!mounted || current != revision) return;
      final changed = enabled != value || idleMinutes != minutes;
      DmpWorkContext.current.setEnabled(value);
      setState(() {
        enabled = value;
        idleMinutes = minutes;
        if (!value) {
          practitioner = null;
          nationalId = null;
          locked = choosing = false;
          pin.clear();
        }
      });
      if (changed) restartIdle();
    } catch (_) {
      // Do not remove an existing lock on a configuration read failure.
      if (mounted) setState(() => message = 'Configuration DMP indisponible.');
    }
  }

  Future<void> choose() async {
    if (CpsOperationLease.inUse) {
      setState(
        () =>
            message = 'Terminez l’opération CPS avant de changer de praticien.',
      );
      return;
    }
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      busy = true;
      message = null;
    });
    try {
      final result =
          await (widget.loadPractitioners ??
              PractitionerRepository().getActivePractitioners)();
      if (mounted && enabled) {
        setState(() {
          choices = result;
          choosing = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => message = 'Impossible de charger les praticiens.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<String?> storedId(String id) async {
    final row = await PractitionerCpsService.stored(
      await DatabaseService.database,
      id,
    );
    return row == null
        ? null
        : PractitionerCpsReading.fromStored(row).profile.nationalId;
  }

  Future<void> select(Practitioner value) async {
    setState(() => busy = true);
    try {
      final identifier = await (widget.loadNationalId ?? storedId)(
        value.practitionerId,
      );
      if (!mounted || !enabled) return;
      if (CpsOperationLease.inUse) throw StateError('Opération CPS en cours.');
      setState(() {
        practitioner = value;
        nationalId = identifier;
        DmpWorkContext.current.select(identifier);
        choosing = false;
        message = nationalId == null
            ? 'Verrouillage automatique indisponible : associez sa CPS dans la fiche du praticien.'
            : null;
      });
      restartIdle();
    } catch (_) {
      if (mounted) {
        setState(() => message = 'Impossible de sélectionner ce praticien.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void lock() {
    if (!Platform.isMacOS && widget.readCard == null) {
      setState(
        () => message =
            'Le déverrouillage CPS de ce parcours est disponible sur macOS. Verrouillez votre ordinateur pour vous absenter.',
      );
      return;
    }
    if (CpsOperationLease.inUse) {
      setState(
        () => message = 'Terminez l’opération CPS avant de verrouiller.',
      );
    } else if (nationalId == null) {
      setState(
        () => message =
            'Associez d’abord sa CPS dans la fiche du praticien. Pour vous absenter, verrouillez votre ordinateur.',
      );
    } else {
      inactivity.stop();
      deferredLock?.cancel();
      pin.clear();
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {
        locked = true;
        DmpWorkContext.current.lock();
        message = null;
      });
    }
  }

  Future<void> unlock() async {
    if (busy) return;
    final expected = nationalId;
    var secret = pin.text;
    pin.clear();
    setState(() {
      busy = true;
      message = null;
    });
    try {
      final profile = await (widget.readCard ?? const CpsAccessService().read)(
        secret,
      );
      secret = '';
      if (profile.nationalId != expected) {
        throw const FormatException('Présentez la CPS du praticien affiché.');
      }
      if (mounted) {
        DmpWorkContext.current.unlock(profile.nationalId);
        setState(() => locked = false);
        restartIdle();
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => message = e is PlatformException
              ? e.message
              : e is FormatException
              ? e.message
              : 'Déverrouillage impossible.',
        );
      }
    } finally {
      secret = '';
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  void dispose() {
    DmpWorkContext.current.setEnabled(false);
    inactivity.stop();
    deferredLock?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    HardwareKeyboard.instance.removeHandler(onKey);
    revision++;
    DmpSetupService.changes.removeListener(load);
    pin.clear();
    pin.dispose();
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

  Widget content(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (enabled)
          Material(
            color: Theme.of(context).colorScheme.primaryContainer,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  children: [
                    const Icon(Icons.person_outline, size: 20),
                    Text(
                      practitioner == null
                          ? 'Praticien non sélectionné'
                          : 'Praticien sélectionné : ${practitioner!.displayName}',
                    ),
                    if (!locked)
                      TextButton(
                        onPressed: busy ? null : choose,
                        child: Text(
                          practitioner == null
                              ? 'Choisir le praticien'
                              : 'Changer de praticien',
                        ),
                      ),
                    if (!locked && practitioner != null)
                      TextButton.icon(
                        onPressed: busy ? null : lock,
                        icon: const Icon(Icons.lock_outline, size: 18),
                        label: const Text('Verrouiller'),
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
                offstage: locked || choosing,
                child: TickerMode(
                  enabled: !locked && !choosing,
                  child: ExcludeFocus(
                    excluding: locked || choosing,
                    child: widget.child,
                  ),
                ),
              ),
              if (locked || choosing)
                Material(
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 520),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: locked
                              ? [
                                  const Icon(Icons.lock_outline, size: 40),
                                  const Text('Companion verrouillé'),
                                  Text(
                                    'Déverrouiller avec la CPS de ${practitioner!.displayName}. Les saisies restent conservées à l’écran.',
                                  ),
                                  TextField(
                                    controller: pin,
                                    obscureText: true,
                                    enableSuggestions: false,
                                    autocorrect: false,
                                    enabled: !busy,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                      LengthLimitingTextInputFormatter(16),
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'PIN CPS — non conservé',
                                    ),
                                    onSubmitted: (_) => unlock(),
                                  ),
                                  FilledButton(
                                    onPressed: busy ? null : unlock,
                                    child: const Text(
                                      'Déverrouiller avec ma CPS',
                                    ),
                                  ),
                                  const Text(
                                    'Cette lecture ne lance aucune connexion DMP.',
                                  ),
                                ]
                              : [
                                  const Text('Choisir le praticien'),
                                  const Text(
                                    'Cette sélection ne vaut pas authentification CPS et ne change ni le référent ni le rédacteur des rapports.',
                                  ),
                                  if (choices.isEmpty)
                                    const Text(
                                      'Aucun praticien actif. Ajoutez-le dans les paramètres.',
                                    ),
                                  for (final value in choices)
                                    ListTile(
                                      title: Text(value.displayName),
                                      onTap: busy ? null : () => select(value),
                                    ),
                                  TextButton(
                                    onPressed: busy
                                        ? null
                                        : () =>
                                              setState(() => choosing = false),
                                    child: const Text('Annuler'),
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
}

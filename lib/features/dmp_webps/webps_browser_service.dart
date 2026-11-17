import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../../core/settings/application_settings_service.dart';
import '../cps/cps_operation_lease.dart';
import '../dmp_session/dmp_work_context.dart';
import 'webps_local.dart';

/// Only launch/closure evidence; never claims a successful CPS authentication.
class WebPsBrowserService extends ChangeNotifier {
  WebPsBrowserService({
    MethodChannel? channel,
    DmpWorkContext? context,
    Future<String?> Function()? readBrowser,
    bool? isWindows,
  }) : isWindows = isWindows ?? Platform.isWindows,
       channel = channel ?? const MethodChannel('abak/webps_browser'),
       context = context ?? DmpWorkContext.current,
       readBrowser =
           readBrowser ??
           (() => const ApplicationSettingsService().getString(
             Platform.isWindows ? 'dmp_webps_browser_windows' : 'dmp_webps_browser_macos',
           ));
  static final shared = WebPsBrowserService();
  final bool isWindows;
  static bool supportsBrowser(String? browser, {required bool windows}) =>
      browser == 'org.mozilla.firefox' || (windows && browser == 'com.microsoft.edge');
  final MethodChannel channel;
  final DmpWorkContext context;
  final Future<String?> Function() readBrowser;
  CpsOperationLease? _lease;
  Timer? _timer;
  Future<void>? _closing;
  bool active = false, busy = false;
  String message = 'Aucun accès Web-PS lancé.';
  String? lastUrl, browserPath;
  String get professional => context.activeProfessional;

  Future<void> open(
    WebPsTarget target, {
    WebPsPatient? patient,
    required bool confirmed,
    required void Function() checkContext,
  }) async {
    if (!confirmed || busy || active) return;
    busy = true;
    notifyListeners();
    try {
      checkContext();
      final browser = await readBrowser();
      if (!supportsBrowser(browser, windows: isWindows)) {
        throw StateError(
          'Choisissez Firefox sur Mac, ou Microsoft Edge / Firefox sur Windows, dans les paramètres DMP.',
        );
      }
      final browserName = browser == 'com.microsoft.edge' ? 'Microsoft Edge' : 'Firefox';
      final url = WebPsUrl.build(WebPsUrl.dv1, target, patient: patient);
      checkContext();
      _lease = await CpsOperationLease.acquireAvailable();
      checkContext();
      active = true;
      lastUrl = url.toString();
      final launch = channel.invokeMapMethod<String, dynamic>('open', {
        'browser': browser,
        'url': url.toString(),
        'confirmed': true,
      });
      // Locks and other CPS operations close this browser before using the card.
      _lease!.park(close);
      _timer ??= Timer.periodic(const Duration(seconds: 2), (_) => refresh());
      final result = await launch.timeout(const Duration(seconds: 20));
      if (result?['active'] != true || result?['opening'] != false) {
        throw StateError('Ouverture du navigateur non confirmée.');
      }
      checkContext();
      browserPath = result?['browserPath'] as String?;
      message =
          '$browserName lancé. Vérifiez le praticien et le patient affichés dans Web-PS. L’authentification reste à confirmer dans le navigateur.';
      _timer ??= Timer.periodic(const Duration(seconds: 2), (_) => refresh());
    } catch (e) {
      final reason = e is PlatformException
          ? e.message ?? e.code
          : e.toString();
      if (active) {
        try {
          final status = await channel.invokeMapMethod<String, dynamic>(
            'status',
          );
          if (status?['active'] == false) {
            active = false;
            _lease?.release();
            _lease = null;
          } else {
            await close();
          }
        } catch (_) {
          /* Ownership retained on uncertainty. */
        }
      } else {
        _lease?.release();
        _lease = null;
      }
      message =
          '$reason${active ? ' Fermeture non confirmée : accès bloqués.' : ''}';
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    if (busy || _closing != null) return;
    busy = true;
    notifyListeners();
    try {
      final result = await channel.invokeMapMethod<String, dynamic>('status');
      if (result?['active'] == false) {
        if (active) message = 'Accès Web-PS fermé.';
        active = false;
        _lease?.release();
        _lease = null;
        _timer?.cancel();
        _timer = null;
      } else {
        active = true;
        message =
            'Un accès Web-PS est ouvert ou sa fermeture reste à confirmer.';
      }
    } catch (_) {
      active = true;
      message = 'État du navigateur indisponible. Aucun nouvel accès autorisé.';
    } finally {
      busy = false;
    }
    notifyListeners();
  }

  Future<void> close() {
    if (_closing != null) return _closing!;
    final future = _close();
    _closing = future;
    return future.whenComplete(() => _closing = null);
  }

  Future<void> _close() async {
    final result = await channel.invokeMapMethod<String, dynamic>('close');
    if (result?['active'] != false) {
      throw StateError('Fermeture du navigateur non confirmée.');
    }
    active = false;
    _lease?.release();
    _lease = null;
    _timer?.cancel();
    _timer = null;
    message = 'Accès Web-PS fermé. Un nouvel accès est possible.';
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

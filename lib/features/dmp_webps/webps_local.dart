import 'dart:async';
import 'package:flutter/foundation.dart';

enum WebPsTarget { dashboard, patient }

@immutable
class WebPsPatient {
  const WebPsPatient(this.name, this.ins, this.oid);
  final String name, ins, oid;
  String? get error {
    if (oid == '1.2.250.1.213.1.4.9') {
      return 'Accès patient indisponible : identifiant NIA.';
    }
    if (oid != '1.2.250.1.213.1.4.10') return 'Type d’INS non pris en charge.';
    if (!RegExp(r'^[12][0-9]{14}$').hasMatch(ins)) {
      return 'Un NIR de 15 chiffres est nécessaire.';
    }
    if (97 - int.parse(ins.substring(0, 13)) % 97 !=
        int.parse(ins.substring(13))) {
      return 'Clé du NIR invalide.';
    }
    if (name.trim().isEmpty) return 'Identité du patient absente.';
    return null;
  }
}

class WebPsUrl {
  static const dv1 = 'https://wps-cps.dev1.dmp.gouv.fr';
  static Uri build(String base, WebPsTarget target, {WebPsPatient? patient}) {
    final uri = Uri.tryParse(base.trim());
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host != 'wps-cps.dev1.dmp.gouv.fr' ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.path.isNotEmpty && uri.path != '/')) {
      throw const FormatException(
        'Base de test invalide : utilisez uniquement la racine HTTPS Web-PS DV1.',
      );
    }
    if (target == WebPsTarget.dashboard) {
      return uri.replace(path: '/AccesDirect/TableauDeBord');
    }
    if (patient == null) {
      throw const FormatException('Sélectionnez un patient.');
    }
    if (patient.error != null) throw FormatException(patient.error!);
    return uri.replace(
      pathSegments: ['AccesDirect', 'DossierPatient', patient.ins, patient.oid],
    );
  }
}

/// An in-memory window, never a native browser. Closing is explicit.
class SimulatedWebPsWindow {
  final Completer<void> _closed = Completer<void>();
  Future<void> get closed => _closed.future;
  void close() {
    if (!_closed.isCompleted) _closed.complete();
  }
}

abstract interface class WebPsBrowserSimulation {
  Future<SimulatedWebPsWindow> open(Uri uri, String windowName);
}

class MemoryWebPsBrowser implements WebPsBrowserSimulation {
  @override
  Future<SimulatedWebPsWindow> open(Uri uri, String windowName) async =>
      SimulatedWebPsWindow();
}

/// Shared by all instances of the screen, not released when navigating away.
/// This guard covers simulated windows only, never claims to control Safari/Chrome.
class WebPsCoordinator extends ChangeNotifier {
  WebPsCoordinator(this.browser);
  static final shared = WebPsCoordinator(MemoryWebPsBrowser());
  final WebPsBrowserSimulation browser;
  bool busy = false;
  Uri? activeUrl;
  WebPsPatient? activePatient;
  SimulatedWebPsWindow? window;
  String message = 'Aucune fenêtre simulée ouverte.';
  bool get canClose => window != null;
  Future<bool> open(
    String base,
    WebPsTarget target,
    WebPsPatient? patient,
  ) async {
    if (busy) return false;
    final url = WebPsUrl.build(base, target, patient: patient);
    // Reserve synchronously before invoking even an asynchronous opener.
    busy = true;
    activeUrl = url;
    activePatient = target == WebPsTarget.patient ? patient : null;
    message = 'Ouverture simulée en cours…';
    notifyListeners();
    try {
      final handle = await browser.open(url, 'ABAK_DMP_WEBPS');
      window = handle;
      message =
          'Fenêtre simulée ouverte. Fermez-la avant tout autre accès ou changement de patient.';
      notifyListeners();
      unawaited(
        handle.closed.then((_) {
          if (!identical(window, handle)) return;
          window = null;
          busy = false;
          activeUrl = null;
          activePatient = null;
          message = 'Fenêtre simulée fermée. Un nouvel accès est possible.';
          notifyListeners();
        }),
      );
      return true;
    } catch (_) {
      // Cannot infer that an uncertain opener created no window.
      message =
          'Ouverture non confirmée. Nouvel accès bloqué : fermeture de la fenêtre non confirmée.';
      notifyListeners();
      return false;
    }
  }

  void close() => window?.close();
}

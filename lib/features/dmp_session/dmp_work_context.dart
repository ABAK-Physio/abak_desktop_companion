import 'dart:async';
import '../cps/cps_operation_lease.dart';

/// Local work context, never proof of CPS authentication or patient consent.
/// Tickets bind an operation to a selection and cannot survive a lock or switch.
class DmpWorkContext {
  static final current = DmpWorkContext();
  bool _enabled = false, _locked = true;
  String? _professional;
  int _revision = 0;

  String get activeProfessional {
    final id = _professional ?? '';
    requireProfessional(id);
    return id;
  }

  void _invalidate() {
    _revision++;
    // Access remains blocked if closing fails; no unhandled asynchronous error.
    if (identical(this, current)) {
      unawaited(CpsOperationLease.closeIdle().catchError((Object _) {}));
    }
  }

  void setEnabled(bool value) {
    if (_enabled == value) return;
    _enabled = value;
    _professional = null;
    _locked = true;
    _invalidate();
  }

  void select(String? professional) {
    _professional = professional;
    _locked = false;
    _invalidate();
  }

  void lock() {
    _locked = true;
    _invalidate();
  }

  void unlock(String professional) {
    if (!_enabled || professional != _professional) {
      throw StateError('Présentez la CPS du praticien sélectionné.');
    }
    _locked = false;
    _invalidate();
  }

  void requireProfessional(String professional) {
    if (!_enabled) {
      throw StateError('Activez « Utiliser le DMP » dans les réglages.');
    }
    if (_professional == null) {
      throw StateError(
        'Sélectionnez un praticien avec une CPS associée dans le bandeau.',
      );
    }
    if (_locked) {
      throw StateError(
        'Déverrouillez Companion avec la CPS du praticien sélectionné.',
      );
    }
    if (professional != _professional) {
      throw StateError(
        'Le praticien du bandeau diffère de celui de la configuration DMP. Sélectionnez le même praticien avant de poursuivre.',
      );
    }
  }

  void Function() bind(String professional) {
    requireProfessional(professional);
    final revision = _revision;
    return () {
      requireProfessional(professional);
      if (_revision != revision) {
        throw StateError(
          'Le contexte du praticien a changé. Recommencez cette opération DMP.',
        );
      }
    };
  }
}

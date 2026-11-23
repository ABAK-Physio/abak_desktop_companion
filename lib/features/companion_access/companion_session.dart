import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../core/database/database_service.dart';
import '../cps/cps_operation_lease.dart';
import '../dmp_session/dmp_work_context.dart';
import '../practitioners/data/practitioner_cps_service.dart';
import 'companion_access_service.dart';

/// In-memory identity only. A lock ends the session; reauthentication always
/// creates a new identifier. No session or exceptional grant survives restart.
class CompanionSession extends ChangeNotifier {
  CompanionSession({
    CompanionAccessService? access,
    DmpWorkContext? dmpContext,
    Future<String?> Function(String)? loadNationalId,
    bool Function()? cpsBusy,
    String Function()? newSessionId,
  }) : access = access ?? CompanionAccessService(),
       dmpContext = dmpContext ?? DmpWorkContext.current,
       _loadNationalId = loadNationalId ?? _storedNationalId,
       _cpsBusy = cpsBusy ?? (() => CpsOperationLease.inUse),
       _newSessionId = newSessionId ?? (() => const Uuid().v4()) {
    CompanionAccessService.recoveryCompleted.addListener(_recovered);
    CompanionAccessService.practitionerArchived.addListener(_archived);
  }
  void _archived() {
    final id = CompanionAccessService.practitionerArchived.value;
    if (id == null) return;
    cancelAuthentication();
    if (id == _practitionerId) _recovered();
  }
  void _recovered() {
    cancelAuthentication();
    _sessionId = _practitionerId = null;
    _locked = false;
    dmpContext.select(null);
    notifyListeners();
  }

  static final current = CompanionSession();
  final CompanionAccessService access;
  final DmpWorkContext dmpContext;
  final Future<String?> Function(String) _loadNationalId;
  final bool Function() _cpsBusy;
  final String Function() _newSessionId;
  bool _enabled = false, _locked = false;
  String? _practitionerId, _sessionId;
  int _authenticationRevision = 0;
  bool get enabled => _enabled;
  bool get locked => _locked;
  String? get practitionerId => _practitionerId;
  String? get sessionId => _sessionId;
  bool get authenticated => _enabled && !_locked && _sessionId != null;

  static Future<String?> _storedNationalId(String id) async {
    final row = await PractitionerCpsService.stored(
      await DatabaseService.database,
      id,
    );
    return row == null
        ? null
        : PractitionerCpsReading.fromStored(row).profile.nationalId;
  }

  void setEnabled(bool value) {
    dmpContext.setEnabled(value);
    if (value == _enabled) return;
    _enabled = value;
    _locked = false;
    _practitionerId = _sessionId = null;
    cancelAuthentication();
    notifyListeners();
  }

  /// Cancels only an in-flight attempt, keeping the previous session and its
  /// DMP tickets intact when the user cancels a practitioner change.
  void cancelAuthentication() => _authenticationRevision++;

  Future<void> signIn(String practitionerId, String code) async {
    if (!_enabled) {
      throw const CompanionAccessException('Le mode DMP est désactivé.');
    }
    if (_cpsBusy()) {
      throw const CompanionAccessException(
        'Terminez l’opération CPS avant de changer de praticien.',
      );
    }
    final revision = ++_authenticationRevision;
    await access.verifyCode(practitionerId, code);
    final nationalId = await _loadNationalId(practitionerId);
    if (!_enabled || revision != _authenticationRevision) {
      throw const CompanionAccessException(
        'L’identification a été annulée. Recommencez.',
      );
    }
    if (_cpsBusy()) {
      throw const CompanionAccessException(
        'Terminez l’opération CPS avant de changer de praticien.',
      );
    }
    _practitionerId = practitionerId;
    _sessionId = _newSessionId();
    _locked = false;
    // A stored CPS identifier binds DMP operations to the local selection. It
    // is not a card read or proof of CPS authentication. Null is allowed locally.
    dmpContext.select(nationalId);
    notifyListeners();
  }

  bool lock() {
    if (!_enabled || _practitionerId == null || _cpsBusy()) return false;
    cancelAuthentication();
    _sessionId = null;
    _locked = true;
    dmpContext.lock();
    notifyListeners();
    return true;
  }

  bool signOut() {
    if (_cpsBusy()) return false;
    cancelAuthentication();
    _sessionId = _practitionerId = null;
    _locked = false;
    dmpContext.select(null);
    notifyListeners();
    return true;
  }

  /// Used by session-scoped operations: a new session, even for the same kiné,
  /// must never revive an old authorization.
  VoidCallback bind() {
    if (!authenticated) {
      throw const CompanionAccessException('Identifiez-vous dans le bandeau.');
    }
    final expected = _sessionId;
    return () {
      if (!authenticated || _sessionId != expected) {
        throw const CompanionAccessException(
          'La session a changé. Recommencez cette opération.',
        );
      }
    };
  }

  @override
  void dispose() {
    CompanionAccessService.recoveryCompleted.removeListener(_recovered);
    CompanionAccessService.practitionerArchived.removeListener(_archived);
    cancelAuthentication();
    _sessionId = _practitionerId = null;
    _enabled = false;
    dmpContext.setEnabled(false);
    super.dispose();
  }
}

import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/database/database_service.dart';
import 'companion_access_service.dart';
import 'companion_session.dart';

enum AdministrativeAccessReason {
  unexpectedAbsence('Absence non planifiée de l’administrateur'),
  withAgreement('Avec l’accord de l’administrateur');

  const AdministrativeAccessReason(this.label);
  final String label;
}

enum AdministrativeAccessDecision {
  unrestricted,
  administrator,
  exception,
  bootstrap,
  bootstrapRequired,
  identification,
  denied;

  bool get allowed =>
      this == unrestricted ||
      this == administrator ||
      this == exception ||
      this == bootstrap;
}

/// Only navigation authorization. Never confers an administrator flag or the
/// right to modify administrator credentials / recovery keys.
class AdministrativeAccessService extends ChangeNotifier {
  AdministrativeAccessService({
    Future<Database> Function()? database,
    CompanionSession? session,
    DateTime Function()? now,
  }) : _database = database ?? (() => DatabaseService.database),
       session = session ?? CompanionSession.current,
       _now = now ?? DateTime.now {
    this.session.addListener(_sessionChanged);
    CompanionAccessService.administratorChanges.addListener(_rightsChanged);
  }
  final Future<Database> Function() _database;
  final CompanionSession session;
  final DateTime Function() _now;
  bool _exception = false, _bootstrap = false, _disposed = false;
  int _revision = 0;

  void _sessionChanged() {
    _exception = _bootstrap = false;
    _rightsChanged();
  }

  void _rightsChanged() {
    _revision++;
    // Bootstrap authorization must not survive the creation/removal of admins.
    _bootstrap = false;
    notifyListeners();
  }

  void _check(int revision) {
    if (_disposed || _revision != revision) {
      throw const CompanionAccessException(
        'La session ou les droits ont changé. Recommencez.',
      );
    }
  }

  Future<AdministrativeAccessDecision> _inspect(DatabaseExecutor db) async {
    final settings = await db.query(
      'application_settings',
      columns: ['setting_value'],
      where: 'setting_key = ?',
      whereArgs: ['dmp_enabled'],
    );
    if (!session.enabled &&
        (settings.isEmpty || settings.single['setting_value'] != 'true')) {
      return AdministrativeAccessDecision.unrestricted;
    }
    if (!session.authenticated) {
      return AdministrativeAccessDecision.identification;
    }
    final person = await db.rawQuery(
      '''SELECT COALESCE(a.is_administrator, 0) AS administrator
      FROM practitioners p LEFT JOIN companion_practitioner_access a USING(practitioner_id)
      WHERE p.practitioner_id = ? AND p.archived_at IS NULL AND p.is_active = 1''',
      [session.practitionerId],
    );
    if (person.isEmpty) {
      throw const CompanionAccessException('Ce kiné n’est plus disponible.');
    }
    if (person.single['administrator'] == 1) {
      return AdministrativeAccessDecision.administrator;
    }
    final admins = await db.rawQuery(
      '''SELECT 1 FROM companion_practitioner_access a
      JOIN practitioners p USING(practitioner_id)
      WHERE a.is_administrator = 1 AND p.archived_at IS NULL LIMIT 1''',
    );
    if (admins.isEmpty) {
      return _bootstrap
          ? AdministrativeAccessDecision.bootstrap
          : AdministrativeAccessDecision.bootstrapRequired;
    }
    return _exception
        ? AdministrativeAccessDecision.exception
        : AdministrativeAccessDecision.denied;
  }

  Future<AdministrativeAccessDecision> inspect() async {
    final revision = _revision;
    final db = await _database();
    final result = await db.transaction(_inspect);
    _check(revision);
    return result;
  }

  Future<void> grantException({
    required String code,
    required AdministrativeAccessReason reason,
  }) async {
    final ticket = session.bind();
    final revision = _revision;
    final actor = session.practitionerId!;
    final sessionId = session.sessionId!;
    final before = await inspect();
    if (before.allowed) return;
    if (before != AdministrativeAccessDecision.denied) {
      throw const CompanionAccessException(
        'Identifiez-vous ou utilisez le mot de passe initial.',
      );
    }
    await session.access.verifyCode(actor, code);
    ticket();
    _check(revision);
    final db = await _database();
    await db.transaction((txn) async {
      if (await _inspect(txn) != AdministrativeAccessDecision.denied) {
        throw const CompanionAccessException(
          'Les droits ont changé. Recommencez.',
        );
      }
      ticket();
      _check(revision);
      await _log(
        txn,
        actor,
        sessionId,
        'administrative_exception_granted',
        reason.name,
      );
      ticket();
      _check(revision);
    });
    ticket();
    _check(revision);
    _exception = true;
    notifyListeners();
  }

  Future<void> unlockBootstrap(String password) async {
    final ticket = session.bind();
    final revision = _revision;
    final actor = session.practitionerId!;
    final sessionId = session.sessionId!;
    if (await inspect() != AdministrativeAccessDecision.bootstrapRequired) {
      throw const CompanionAccessException(
        'Le mot de passe initial n’est pas disponible.',
      );
    }
    await session.access.verifyInitialPassword(password);
    ticket();
    _check(revision);
    final db = await _database();
    await db.transaction((txn) async {
      if (await _inspect(txn) !=
          AdministrativeAccessDecision.bootstrapRequired) {
        throw const CompanionAccessException(
          'Un administrateur existe maintenant. Recommencez.',
        );
      }
      await _log(
        txn,
        actor,
        sessionId,
        'administrative_bootstrap_access',
        null,
      );
      ticket();
      _check(revision);
    });
    ticket();
    _check(revision);
    _bootstrap = true;
    notifyListeners();
  }

  /// A whole-database replacement would also replace administrator rights.
  /// The ordinary exception must not provide this indirect privilege.
  Future<void> requireDatabaseReplacementAccess() async {
    final state = await inspect();
    if (!state.allowed || state == AdministrativeAccessDecision.exception) {
      throw const CompanionAccessException(
        'La restauration ou la réinitialisation de la base n’est pas autorisée par un accès dérogatoire.',
      );
    }
  }

  Future<void> _log(
    DatabaseExecutor db,
    String actor,
    String sessionId,
    String action,
    String? reason,
  ) async {
    final now = _now().toUtc();
    final cutoff = DateTime.utc(
      now.year - 1,
      now.month,
      now.day,
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
    );
    await db.delete(
      'companion_access_events',
      where: 'occurred_at < ?',
      whereArgs: [cutoff.millisecondsSinceEpoch],
    );
    await db.insert('companion_access_events', {
      'occurred_at': now.millisecondsSinceEpoch,
      'action': action,
      'actor_practitioner_id': actor,
      'session_id': sessionId,
      'reason': reason,
    });
  }

  @override
  void dispose() {
    session.removeListener(_sessionChanged);
    CompanionAccessService.administratorChanges.removeListener(_rightsChanged);
    _disposed = true;
    _revision++;
    _exception = _bootstrap = false;
    super.dispose();
  }
}

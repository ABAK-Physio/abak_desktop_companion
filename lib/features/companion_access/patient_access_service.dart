import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../core/database/database_service.dart';
import 'companion_access_service.dart';
import 'companion_session.dart';

/// Fixed reasons only: neither a personal code nor clinical free text belongs
/// in the exceptions journal.
enum PatientAccessReason {
  unexpectedAbsence('Absence non planifiée du kiné référent'),
  withAgreement('Avec l’accord du kiné référent'),
  continuity('Continuité des soins — dossier sans référent');

  const PatientAccessReason(this.label);
  final String label;
}

enum PatientAccessDecision {
  unrestricted,
  referrer,
  exception,
  identification,
  denied,
}

class PatientAccessState {
  const PatientAccessState({
    required this.patientId,
    required this.referrerId,
    required this.referrerName,
    required this.decision,
  });
  final String patientId;
  final String? referrerId, referrerName;
  final PatientAccessDecision decision;
  bool get allowed => switch (decision) {
    PatientAccessDecision.unrestricted ||
    PatientAccessDecision.referrer ||
    PatientAccessDecision.exception => true,
    _ => false,
  };
  List<PatientAccessReason> get reasons => referrerId == null
      ? const [PatientAccessReason.continuity]
      : const [
          PatientAccessReason.unexpectedAbsence,
          PatientAccessReason.withAgreement,
        ];
}

/// Application-level access, not encryption or protection against direct file
/// access. Grants are deliberately memory-only and belong to a single session.
/// The UI must react to notifications and mask already-open descendant routes.
class PatientAccessService extends ChangeNotifier {
  PatientAccessService({
    Future<Database> Function()? database,
    CompanionSession? session,
    DateTime Function()? now,
  }) : _database = database ?? (() => DatabaseService.database),
       session = session ?? CompanionSession.current,
       _now = now ?? DateTime.now {
    this.session.addListener(_sessionChanged);
    CompanionAccessService.patientAssignmentsChanged.addListener(
      _assignmentsChanged,
    );
  }

  final Future<Database> Function() _database;
  final CompanionSession session;
  final DateTime Function() _now;
  // Value binds the grant to the assignment as well as to this live session.
  final Map<String, String?> _grants = {};
  int _revision = 0;
  bool _disposed = false;

  void _assignmentsChanged() {
    _revision++;
    for (final id in CompanionAccessService.patientAssignmentsChanged.value) {
      _grants.remove(id);
    }
    notifyListeners();
  }

  void _sessionChanged() {
    _revision++;
    _grants.clear();
    notifyListeners();
  }

  void _checkRevision(int expected) {
    if (_disposed || expected != _revision) {
      throw const CompanionAccessException(
        'La session a changé. Recommencez cette opération.',
      );
    }
  }

  Future<bool> _controlsEnabled(DatabaseExecutor db) async {
    final rows = await db.query(
      'application_settings',
      columns: ['setting_value'],
      where: 'setting_key = ?',
      whereArgs: ['dmp_enabled'],
    );
    // The banner loads asynchronously at startup. Its default false must not
    // bypass the durable setting. During toggles, either true keeps controls on.
    return session.enabled ||
        (rows.isNotEmpty && rows.single['setting_value'] == 'true');
  }

  Future<Map<String, Object?>> _patient(DatabaseExecutor db, String id) async {
    final rows = await db.rawQuery(
      '''SELECT p.patient_id,
      a.referring_practitioner_id, k.display_name AS referrer_name
      FROM patients p LEFT JOIN companion_patient_access a USING(patient_id)
      LEFT JOIN practitioners k ON k.practitioner_id = a.referring_practitioner_id
      WHERE p.patient_id = ?''',
      [id],
    );
    if (rows.isEmpty) {
      throw const CompanionAccessException(
        'Ce dossier patient n’est plus disponible.',
      );
    }
    return rows.single;
  }

  Future<void> _active(DatabaseExecutor db, String id) async {
    if ((await db.query(
      'practitioners',
      columns: ['practitioner_id'],
      where: 'practitioner_id = ? AND archived_at IS NULL AND is_active = 1',
      whereArgs: [id],
    )).isEmpty) {
      throw const CompanionAccessException('Ce kiné n’est plus disponible.');
    }
  }

  Future<PatientAccessState> inspect(String patientId) async {
    final revision = _revision;
    final db = await _database();
    final result = await db.transaction((txn) async {
      final row = await _patient(txn, patientId);
      final referrer = row['referring_practitioner_id'] as String?;
      var decision = PatientAccessDecision.unrestricted;
      if (await _controlsEnabled(txn)) {
        decision = PatientAccessDecision.identification;
        if (session.authenticated) {
          await _active(txn, session.practitionerId!);
          decision = referrer == session.practitionerId
              ? PatientAccessDecision.referrer
              : _grants.containsKey(patientId) && _grants[patientId] == referrer
              ? PatientAccessDecision.exception
              : PatientAccessDecision.denied;
        }
      }
      return PatientAccessState(
        patientId: patientId,
        referrerId: referrer,
        referrerName: row['referrer_name'] as String?,
        decision: decision,
      );
    });
    _checkRevision(revision);
    return result;
  }

  Future<void> grantException({
    required String patientId,
    required String code,
    required PatientAccessReason reason,
  }) async {
    final ticket = session.bind();
    final revision = _revision;
    final actor = session.practitionerId!;
    final sessionId = session.sessionId!;
    final before = await inspect(patientId);
    if (before.allowed) return;
    if (!before.reasons.contains(reason)) {
      throw const CompanionAccessException(
        'Choisissez un motif adapté à ce dossier.',
      );
    }
    // Separate committed authentication transaction: a wrong code must retain
    // its failure count even though the subsequent access operation is denied.
    await session.access.verifyCode(actor, code);
    ticket();
    _checkRevision(revision);
    final db = await _database();
    await db.transaction((txn) async {
      final row = await _patient(txn, patientId);
      await _active(txn, actor);
      if (!await _controlsEnabled(txn) ||
          row['referring_practitioner_id'] != before.referrerId) {
        throw const CompanionAccessException(
          'Le référent ou le mode DMP a changé. Recommencez.',
        );
      }
      ticket();
      _checkRevision(revision);
      await _log(
        txn,
        action: 'patient_exception_granted',
        patientId: patientId,
        actor: actor,
        sessionId: sessionId,
        reason: reason.name,
        previousReferrer: before.referrerId,
      );
      ticket();
      _checkRevision(revision);
    });
    // A lock while COMMIT completes may leave an honest audit record of a
    // just-ended authorization, but must never install a grant in the new session.
    ticket();
    _checkRevision(revision);
    _grants[patientId] = before.referrerId;
    notifyListeners();
  }

  /// Ordinary change only. A session exception (or administrator flag) never
  /// permits changing someone else's referrer. Unassigned patients require the
  /// separate recovery-key procedure, including when DMP is disabled.
  Future<void> changeReferrer({
    required String patientId,
    required String newReferrerId,
  }) async {
    final revision = _revision;
    final db = await _database();
    await db.transaction((txn) async {
      final row = await _patient(txn, patientId);
      final previous = row['referring_practitioner_id'] as String?;
      if (previous == null) {
        throw const CompanionAccessException(
          'La clé de récupération est nécessaire pour réaffecter ce dossier.',
        );
      }
      VoidCallback? ticket;
      if (await _controlsEnabled(txn)) {
        ticket = session.bind();
        if (session.practitionerId != previous) {
          throw const CompanionAccessException(
            'Seul le kiné référent peut changer cette affectation.',
          );
        }
        await _active(txn, session.practitionerId!);
      }
      await _active(txn, newReferrerId);
      ticket?.call();
      _checkRevision(revision);
      if (previous == newReferrerId) return;
      await txn.update(
        'companion_patient_access',
        {'referring_practitioner_id': newReferrerId},
        where: 'patient_id = ?',
        whereArgs: [patientId],
      );
      await _log(
        txn,
        action: 'patient_referrer_changed',
        patientId: patientId,
        actor: session.authenticated ? session.practitionerId : null,
        sessionId: session.sessionId,
        previousReferrer: previous,
        target: newReferrerId,
      );
      ticket?.call();
      _checkRevision(revision);
    });
    _grants.remove(patientId);
    if (!_disposed) notifyListeners();
  }

  /// Called inside the patient's creation transaction. No implicit assignment
  /// to the oldest practitioner after the initial migration.
  static Future<void> assignNewPatient(
    DatabaseExecutor db,
    String patientId,
    String referrerId,
  ) async {
    if ((await db.query(
      'practitioners',
      columns: ['practitioner_id'],
      where: 'practitioner_id = ? AND archived_at IS NULL AND is_active = 1',
      whereArgs: [referrerId],
    )).isEmpty) {
      throw const CompanionAccessException(
        'Sélectionnez un kiné référent disponible.',
      );
    }
    // Plain INSERT prevents using creation as a reassignment shortcut.
    await db.insert('companion_patient_access', {
      'patient_id': patientId,
      'referring_practitioner_id': referrerId,
    });
  }

  Future<void> _log(
    DatabaseExecutor db, {
    required String action,
    required String patientId,
    required String? actor,
    required String? sessionId,
    String? reason,
    String? previousReferrer,
    String? target,
  }) async {
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
      'patient_id': patientId,
      'actor_practitioner_id': actor,
      'target_practitioner_id': target,
      'session_id': sessionId,
      'reason': reason,
      'previous_practitioner_id': previousReferrer,
    });
  }

  @override
  void dispose() {
    session.removeListener(_sessionChanged);
    CompanionAccessService.patientAssignmentsChanged.removeListener(
      _assignmentsChanged,
    );
    _disposed = true;
    _revision++;
    _grants.clear();
    super.dispose();
  }
}

import 'patient_reassignment_models.dart';
import '../cps/cps_operation_lease.dart';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/companion_access_schema.dart';
import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../core/database/database_service.dart';
import 'personal_code_hasher.dart';

class CompanionAccessException implements Exception {
  const CompanionAccessException(this.message);
  final String message;
  @override
  String toString() => message;
}

class AccessPractitioner {
  const AccessPractitioner({
    required this.id,
    required this.name,
    required this.isAdministrator,
    required this.hasCode,
  });
  final String id, name;
  final bool isAdministrator, hasCode;
}

/// All authorization is checked here, independently of DMP and UI navigation.
/// Authentication failures are returned from the transaction before throwing:
/// rolling back a failed attempt would otherwise defeat the retry delay.
class CompanionAccessService {
  static final patientAssignmentsChanged = ValueNotifier<Set<String>>(const {});
  static final practitionerArchived = ValueNotifier<String?>(null);
  static final recoveryCompleted = ValueNotifier<int>(0);
  static final administratorChanges = ValueNotifier<int>(0);
  CompanionAccessService({
    Future<Database> Function()? database,
    PersonalCodeHasher? hasher,
    DateTime Function()? now,
  }) : _database = database ?? (() => DatabaseService.database),
       _hasher = hasher ?? Pbkdf2PersonalCodeHasher(),
       _now = now ?? DateTime.now;
  final Future<Database> Function() _database;
  final PersonalCodeHasher _hasher;
  final DateTime Function() _now;

  static bool validCode(String value) =>
      value.length == 4 && RegExp(r'^[0-9]{4}$').hasMatch(value);
  static void _requireCode(String code) {
    if (!validCode(code)) {
      throw const CompanionAccessException(
        'Le code Companion doit contenir exactement quatre chiffres.',
      );
    }
  }

  Future<List<AccessPractitioner>> practitioners() async {
    final db = await _database();
    await _purge(db);
    final rows = await db.rawQuery('''SELECT p.practitioner_id, p.display_name,
      COALESCE(a.is_administrator, 0) AS administrator,
      c.practitioner_id IS NOT NULL AS has_code
      FROM practitioners p
      LEFT JOIN companion_practitioner_access a USING(practitioner_id)
      LEFT JOIN companion_personal_codes c USING(practitioner_id)
      WHERE p.archived_at IS NULL AND p.is_active = 1
      ORDER BY p.display_name COLLATE NOCASE, p.practitioner_id''');
    return rows
        .map(
          (r) => AccessPractitioner(
            id: r['practitioner_id'] as String,
            name: r['display_name'] as String,
            isAdministrator: r['administrator'] == 1,
            hasCode: r['has_code'] == 1,
          ),
        )
        .toList();
  }

  Future<bool> hasAdministrators() async =>
      _hasAdministrators(await _database());

  Future<bool> _hasAdministrators(DatabaseExecutor db) async =>
      (await db.rawQuery(
        '''SELECT 1 FROM companion_practitioner_access a
      JOIN practitioners p USING(practitioner_id)
      WHERE a.is_administrator = 1 AND p.archived_at IS NULL LIMIT 1''',
      )).isNotEmpty;

  Future<void> _active(DatabaseExecutor db, String id) async {
    final rows = await db.query(
      'practitioners',
      columns: ['practitioner_id'],
      where: 'practitioner_id = ? AND archived_at IS NULL AND is_active = 1',
      whereArgs: [id],
    );
    if (rows.isEmpty) {
      throw const CompanionAccessException('Ce kiné n’est plus disponible.');
    }
  }

  Future<void> _administrator(DatabaseExecutor db, String id) async {
    await _active(db, id);
    final rows = await db.query(
      'companion_practitioner_access',
      where: 'practitioner_id = ? AND is_administrator = 1',
      whereArgs: [id],
    );
    if (rows.isEmpty) {
      throw const CompanionAccessException(
        'Le code d’un administrateur est nécessaire. Aucun accès dérogatoire n’est autorisé.',
      );
    }
  }

  Future<void> _run(
    Future<CompanionAccessException?> Function(Transaction) action,
  ) async {
    final db = await _database();
    final failure = await db.transaction(action);
    if (failure != null) throw failure;
  }

  Future<CompanionAccessException?> _blocked(
    DatabaseExecutor db,
    String scope,
  ) async {
    final rows = await db.query(
      'companion_auth_attempts',
      where: 'scope = ?',
      whereArgs: [scope],
    );
    if (rows.isEmpty) return null;
    final remaining =
        (rows.single['blocked_until'] as int) - _now().millisecondsSinceEpoch;
    if (remaining <= 0) return null;
    return CompanionAccessException(
      'Trop d’erreurs. Réessayez dans ${(remaining / 1000).ceil()} s.',
    );
  }

  Future<CompanionAccessException> _failed(
    DatabaseExecutor db,
    String scope,
  ) async {
    final rows = await db.query(
      'companion_auth_attempts',
      where: 'scope = ?',
      whereArgs: [scope],
    );
    final failures = (rows.isEmpty ? 0 : rows.single['failures'] as int) + 1;
    final blocked = failures >= 5;
    await db.insert('companion_auth_attempts', {
      'scope': scope,
      'failures': blocked ? 0 : failures,
      'blocked_until': blocked ? _now().millisecondsSinceEpoch + 30000 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    return CompanionAccessException(
      blocked
          ? 'Cinq erreurs consécutives. Réessayez dans 30 s.'
          : 'Code incorrect.',
    );
  }

  Future<void> _clearAttempts(DatabaseExecutor db, String scope) => db
      .delete('companion_auth_attempts', where: 'scope = ?', whereArgs: [scope])
      .then((_) {});

  Future<CompanionAccessException?> _check(
    DatabaseExecutor db,
    String id,
    String code,
  ) async {
    await _active(db, id);
    final scope = 'personal:$id';
    final blocked = await _blocked(db, scope);
    if (blocked != null) return blocked;
    final rows = await db.query(
      'companion_personal_codes',
      where: 'practitioner_id = ?',
      whereArgs: [id],
    );
    if (rows.isEmpty) {
      return const CompanionAccessException(
        'Ce kiné doit d’abord créer son code personnel.',
      );
    }
    bool verified;
    try {
      verified =
          validCode(code) &&
          await _hasher.verify(code, PersonalCodeVerifier.fromMap(rows.single));
    } on FormatException {
      return const CompanionAccessException(
        'Le code enregistré est illisible. Demandez sa réinitialisation à un administrateur.',
      );
    }
    if (!verified) return _failed(db, scope);
    await _clearAttempts(db, scope);
    return null;
  }

  Future<void> _store(DatabaseExecutor db, String id, String code) async {
    _requireCode(code);
    final value = await _hasher.create(code);
    await db.insert('companion_personal_codes', {
      'practitioner_id': id,
      ...value.toMap(),
      'updated_at': _now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    await _clearAttempts(db, 'personal:$id');
  }

  Future<void> _purge(DatabaseExecutor db) async {
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
  }

  Future<void> _log(
    DatabaseExecutor db,
    String action,
    String? actor,
    String target,
  ) async {
    await _purge(db);
    await db.insert('companion_access_events', {
      'occurred_at': _now().millisecondsSinceEpoch,
      'action': action,
      'actor_practitioner_id': actor,
      'target_practitioner_id': target,
    });
  }

  Future<void> createCode(String id, String code) async {
    _requireCode(code);
    await _run((db) async {
      await _active(db, id);
      if ((await db.query(
        'companion_personal_codes',
        where: 'practitioner_id = ?',
        whereArgs: [id],
      )).isNotEmpty) {
        throw const CompanionAccessException(
          'Un code existe déjà. Utilisez le changement ou la réinitialisation.',
        );
      }
      await _store(db, id, code);
      await _log(db, 'code_created', id, id);
      return null;
    });
  }

  Future<void> verifyCode(String id, String code) =>
      _run((db) => _check(db, id, code));

  /// Read-only journal consultation; navigation exceptions grant no access.
  Future<List<Map<String, Object?>>> readExceptionJournal({
    required String administratorId, required String code,
  }) async {
    var rows = <Map<String, Object?>>[];
    await _run((db) async {
      await _administrator(db, administratorId);
      final failure = await _check(db, administratorId, code);
      if (failure != null) return failure;
      final now = _now().toUtc();
      final cutoff = DateTime.utc(now.year - 1, now.month, now.day,
        now.hour, now.minute, now.second, now.millisecond).millisecondsSinceEpoch;
      rows = await db.rawQuery("""SELECT e.*,
        k.display_name AS actor_name, r.display_name AS referrer_name,
        p.last_name AS patient_last_name, p.first_name AS patient_first_name
        FROM companion_access_events e
        LEFT JOIN practitioners k ON k.practitioner_id=e.actor_practitioner_id
        LEFT JOIN practitioners r ON r.practitioner_id=e.previous_practitioner_id
        LEFT JOIN patients p ON p.patient_id=e.patient_id
        WHERE e.action IN ('patient_exception_granted', 'administrative_exception_granted')
          AND e.occurred_at >= ?
        ORDER BY e.occurred_at DESC, e.event_id DESC""", [cutoff]);
      return null;
    });
    return rows;
  }

  Future<bool> hasPersonalCode(String id) async {
    final db = await _database();
    await _active(db, id);
    return (await db.query(
      'companion_personal_codes',
      columns: ['practitioner_id'],
      where: 'practitioner_id = ?',
      whereArgs: [id],
    )).isNotEmpty;
  }

  Future<void> changeCode(String id, String currentCode, String newCode) async {
    _requireCode(newCode);
    await _run((db) async {
      final failure = await _check(db, id, currentCode);
      if (failure != null) return failure;
      await _store(db, id, newCode);
      await _log(db, 'code_changed', id, id);
      return null;
    });
  }

  Future<void> verifyInitialPassword(String password) => _run((db) async {
    if (await _hasAdministrators(db)) {
      throw const CompanionAccessException(
        'Un administrateur existe déjà : le mot de passe initial est désactivé.',
      );
    }
    final blocked = await _blocked(db, 'bootstrap');
    if (blocked != null) return blocked;
    if (password != 'admin') return _failed(db, 'bootstrap');
    await _clearAttempts(db, 'bootstrap');
    return null;
  });

  Future<void> initializeAdministrator(
    String id,
    String initialPassword,
    String code,
  ) async {
    _requireCode(code);
    await _run((db) async {
      if (await _hasAdministrators(db)) {
        throw const CompanionAccessException(
          'Un administrateur existe déjà : le mot de passe initial est désactivé.',
        );
      }
      await _active(db, id);
      final blocked = await _blocked(db, 'bootstrap');
      if (blocked != null) return blocked;
      if (initialPassword != 'admin') return _failed(db, 'bootstrap');
      final existing = await db.query(
        'companion_personal_codes',
        where: 'practitioner_id = ?',
        whereArgs: [id],
      );
      if (existing.isEmpty) {
        await _store(db, id, code);
      } else {
        final failure = await _check(db, id, code);
        if (failure != null) return failure;
      }
      await db.insert('companion_practitioner_access', {
        'practitioner_id': id,
        'is_administrator': 1,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await _clearAttempts(db, 'bootstrap');
      await _log(db, 'administrator_initialized', id, id);
      return null;
    });
    administratorChanges.value++;
  }

  Future<void> setAdministrator({
    required String actorId,
    required String actorCode,
    required String targetId,
    required bool enabled,
  }) async {
    await _run((db) async {
      await _administrator(db, actorId);
      await _active(db, targetId);
      final failure = await _check(db, actorId, actorCode);
      if (failure != null) return failure;
      if (enabled &&
          (await db.query(
            'companion_personal_codes',
            where: 'practitioner_id = ?',
            whereArgs: [targetId],
          )).isEmpty) {
        throw const CompanionAccessException(
          'Ce kiné doit créer son code personnel avant de devenir administrateur.',
        );
      }
      await db.insert('companion_practitioner_access', {
        'practitioner_id': targetId,
        'is_administrator': enabled ? 1 : 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await _log(
        db,
        enabled ? 'administrator_granted' : 'administrator_removed',
        actorId,
        targetId,
      );
      return null;
    });
    administratorChanges.value++;
  }

  Future<void> resetCode({
    required String actorId,
    required String actorCode,
    required String targetId,
  }) => _run((db) async {
    await _administrator(db, actorId);
    await _active(db, targetId);
    final failure = await _check(db, actorId, actorCode);
    if (failure != null) return failure;
    await db.delete(
      'companion_personal_codes',
      where: 'practitioner_id = ?',
      whereArgs: [targetId],
    );
    await _clearAttempts(db, 'personal:$targetId');
    await _log(db, 'code_reset', actorId, targetId);
    return null;
  });
  Future<bool> hasRecoveryKey() async => (await (await _database()).query(
    'companion_recovery_key',
    limit: 1,
  )).isNotEmpty;

  static String? _normalizeRecoveryKey(String input) {
    var value = input.toUpperCase().replaceAll(RegExp(r'[\s-]'), '');
    if (value.startsWith('ABAK')) value = value.substring(4);
    return RegExp(r'^[0-9A-F]{32}$').hasMatch(value) ? value : null;
  }

  static String _recoveryDigest(String normalized) => sha256
      .convert(utf8.encode('companion-recovery-v1:$normalized'))
      .toString();

  /// A random 128-bit key; SHA-256 is sufficient for this high-entropy secret.
  /// A cabinet name, personal PIN or machine identity never participates.
  Future<String> generateRecoveryKey({
    required String actorId,
    required String actorCode,
  }) async {
    String? generated;
    await _run((db) async {
      await _administrator(db, actorId);
      final failure = await _check(db, actorId, actorCode);
      if (failure != null) return failure;
      final random = Random.secure();
      final raw = List.generate(
        16,
        (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
      ).join().toUpperCase();
      await db.insert('companion_recovery_key', {
        'singleton': 1,
        'algorithm': 'random128-sha256-v1',
        'verifier': _recoveryDigest(raw),
        'created_at': _now().millisecondsSinceEpoch,
        'created_by': actorId,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await _clearAttempts(db, 'recovery');
      await _log(db, 'recovery_key_generated', actorId, actorId);
      generated =
          'ABAK-${List.generate(8, (i) => raw.substring(i * 4, i * 4 + 4)).join('-')}';
      return null;
    });
    return generated!;
  }

  Future<CompanionAccessException?> _checkRecoveryKey(
    DatabaseExecutor db,
    String key,
  ) async {
    final blocked = await _blocked(db, 'recovery');
    if (blocked != null) return blocked;
    final rows = await db.query('companion_recovery_key');
    if (rows.isEmpty) {
      return const CompanionAccessException(
        'Aucune clé de récupération n’a été générée pour cette base.',
      );
    }
    final row = rows.single;
    if (row['algorithm'] != 'random128-sha256-v1' ||
        row['verifier'] is! String ||
        !RegExp(r'^[a-f0-9]{64}$').hasMatch(row['verifier'] as String)) {
      throw const CompanionAccessException(
        'L’empreinte de récupération est illisible.',
      );
    }
    final normalized = _normalizeRecoveryKey(key);
    final actual = _recoveryDigest(normalized ?? 'invalid');
    final expected = row['verifier'] as String;
    var difference = normalized == null ? 1 : 0;
    for (var i = 0; i < expected.length; i++) {
      difference |= expected.codeUnitAt(i) ^ actual.codeUnitAt(i);
    }
    if (difference != 0) return _failed(db, 'recovery');
    await _clearAttempts(db, 'recovery');
    return null;
  }

  /// No logged-in identity is required. Possession of the recovery key is the
  /// explicit authority; the journal must not impersonate an existing kiné.
  Future<void> recoverAdministrator({
    required String key,
    required String newCode,
    String? practitionerId,
    String? newPractitionerName,
  }) async {
    _requireCode(newCode);
    void requireNoCardOperation() {
      if (CpsOperationLease.inUse) {
        throw const CompanionAccessException(
          'Terminez l’opération CPS avant de récupérer un accès.',
        );
      }
    }

    requireNoCardOperation();
    if ((practitionerId == null) == (newPractitionerName == null) ||
        (newPractitionerName != null && newPractitionerName.trim().isEmpty)) {
      throw const CompanionAccessException(
        'Choisissez un kiné existant ou indiquez le nom du nouveau kiné.',
      );
    }
    await _run((db) async {
      final failure = await _checkRecoveryKey(db, key);
      if (failure != null) return failure;
      final target = practitionerId ?? const Uuid().v4();
      if (practitionerId != null) {
        await _active(db, target);
      } else {
        await db.insert('practitioners', {
          'practitioner_id': target,
          'display_name': newPractitionerName!.trim(),
          'created_at': _now().millisecondsSinceEpoch,
        });
        await completeInitialCompanionAssignments(db);
      }
      await _store(db, target, newCode);
      requireNoCardOperation();
      await db.insert('companion_practitioner_access', {
        'practitioner_id': target,
        'is_administrator': 1,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await _log(db, 'administrator_recovered_with_key', null, target);
      return null;
    });
    administratorChanges.value++;
    recoveryCompleted.value++;
  }

  Future<List<ReassignmentSource>> reassignmentSources() async {
    final rows = await (await _database()).rawQuery(
      '''SELECT a.referring_practitioner_id AS id,
      k.display_name, k.archived_at, COUNT(*) AS total FROM patients p
      LEFT JOIN companion_patient_access a USING(patient_id)
      LEFT JOIN practitioners k ON k.practitioner_id = a.referring_practitioner_id
      GROUP BY a.referring_practitioner_id ORDER BY k.display_name COLLATE NOCASE''',
    );
    return rows
        .map(
          (r) => ReassignmentSource(
            r['id'] as String?,
            r['id'] == null
                ? 'Non affectés'
                : '${r['display_name'] ?? 'Kiné indisponible'}${r['archived_at'] == null ? '' : ' (archivé)'}',
            r['total'] as int,
          ),
        )
        .toList();
  }

  Future<List<ReassignmentPatient>> reassignmentPatients(
    String? sourceId,
  ) async {
    final rows = await (await _database()).rawQuery(
      '''SELECT p.patient_id, p.last_name, p.first_name,
      p.birth_date, p.archived_at, a.departure_date, k.display_name AS former_name
      FROM patients p LEFT JOIN companion_patient_access a USING(patient_id)
      LEFT JOIN practitioners k ON k.practitioner_id = a.former_practitioner_id
      WHERE a.referring_practitioner_id IS ? ORDER BY p.last_name COLLATE NOCASE, p.first_name COLLATE NOCASE, p.patient_id''',
      [sourceId],
    );
    return rows
        .map(
          (r) => ReassignmentPatient(
            id: r['patient_id'] as String,
            name: '${r['last_name']} ${r['first_name']}',
            archived: r['archived_at'] != null,
            birthDate: r['birth_date'] as String?,
            formerReferrer: r['former_name'] as String?,
            departureDate: r['departure_date'] as int?,
          ),
        )
        .toList();
  }

  /// Commit the reviewed set, never silently include newly added patients.
  Future<int> reassignPatientsWithKey({
    required String key,
    required String? sourceId,
    required Map<String, String> assignments,
    bool entireSource = false,
  }) async {
    final changes = Map<String, String>.unmodifiable(assignments);
    if (changes.isEmpty) {
      throw const CompanionAccessException(
        'Sélectionnez au moins un patient à réaffecter.',
      );
    }
    void requireNoCardOperation() {
      if (CpsOperationLease.inUse) {
        throw const CompanionAccessException(
          'Terminez l’opération CPS avant de réaffecter les patients.',
        );
      }
    }

    requireNoCardOperation();
    await _run((db) async {
      final failure = await _checkRecoveryKey(db, key);
      if (failure != null) return failure;
      final rows = await db.rawQuery(
        '''SELECT p.patient_id FROM patients p
        LEFT JOIN companion_patient_access a USING(patient_id)
        WHERE a.referring_practitioner_id IS ?''',
        [sourceId],
      );
      final available = rows.map((r) => r['patient_id'] as String).toSet();
      if (!available.containsAll(changes.keys) ||
          (entireSource && available.length != changes.length)) {
        throw const CompanionAccessException(
          'Les dossiers ou leur référent ont changé. Rechargez la liste avant de confirmer.',
        );
      }
      for (final target in changes.values.toSet()) {
        if (target == sourceId) {
          throw const CompanionAccessException(
            'Choisissez un nouveau référent différent du précédent.',
          );
        }
        await _active(db, target);
      }
      await _purge(db);
      for (final entry in changes.entries) {
        final count = await db.update(
          'companion_patient_access',
          {'referring_practitioner_id': entry.value},
          where: 'patient_id = ?',
          whereArgs: [entry.key],
        );
        if (count == 0) {
          await db.insert('companion_patient_access', {
            'patient_id': entry.key,
            'referring_practitioner_id': entry.value,
          });
        }
        // Preserve departure history and clinical/document source rows.
        await db.insert('companion_access_events', {
          'occurred_at': _now().millisecondsSinceEpoch,
          'action': 'patient_reassigned_with_key',
          'patient_id': entry.key,
          'actor_practitioner_id': null,
          'previous_practitioner_id': sourceId,
          'target_practitioner_id': entry.value,
          'reason': 'recovery_key',
        });
      }
      requireNoCardOperation();
      return null;
    });
    patientAssignmentsChanged.value = Set.unmodifiable(changes.keys);
    return changes.length;
  }
}

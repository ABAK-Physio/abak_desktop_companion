import '../../companion_access/companion_access_service.dart';
import 'practitioner_departure_patient.dart';
import '../../../core/database/database_service.dart';
import '../../../core/database/companion_access_schema.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/practitioner.dart';

class PractitionerRepository {
  PractitionerRepository({Future<Database> Function()? database})
    : _database = database ?? (() => DatabaseService.database);
  final Future<Database> Function() _database;
  Future<List<Practitioner>> getActivePractitioners() async {
    final db = await _database();

    final rows = await db.query(
      'practitioners',
      where: 'archived_at IS NULL AND is_active = 1',
      orderBy: 'display_name COLLATE NOCASE ASC',
    );

    return rows.map(Practitioner.fromMap).toList();
  }

  Future<void> insertPractitioner(Practitioner practitioner) async {
    final db = await _database();

    await db.transaction((txn) async {
      await txn.insert('practitioners', practitioner.toMap());
      await completeInitialCompanionAssignments(txn);
    });
  }

  Future<void> updatePractitioner(Practitioner practitioner) async {
    final db = await _database();

    await db.update(
      'practitioners',
      practitioner.toMap(),
      where: 'practitioner_id = ?',
      whereArgs: [practitioner.practitionerId],
    );
  }

  Future<void> archivePractitioner(
    String practitionerId, {
    DateTime? departureDate,
    Set<String>? expectedPatientIds,
    Future<void> Function(Transaction)? verifyExport,
  }) async {
    final db = await _database();
    final now = DateTime.now().millisecondsSinceEpoch;

    final departure = departureDate ?? DateTime.now();
    final day = DateTime(departure.year, departure.month, departure.day);
    if (day.isAfter(DateTime.now())) {
      throw StateError('La date de départ ne peut pas être future.');
    }
    final affected = <String>{};
    await db.transaction((txn) async {
      final person = await txn.query(
        'practitioners',
        where: 'practitioner_id = ? AND archived_at IS NULL',
        whereArgs: [practitionerId],
      );
      if (person.isEmpty) {
        throw StateError('Ce kiné est absent ou déjà archivé.');
      }
      final administrators = await txn.query(
        'companion_practitioner_access',
        where: 'practitioner_id = ? AND is_administrator = 1',
        whereArgs: [practitionerId],
      );
      if (administrators.isNotEmpty) {
        throw StateError(
          'Retirez le statut administrateur avant d’archiver ce kiné.',
        );
      }
      final rows = await txn.query(
        'companion_patient_access',
        columns: ['patient_id'],
        where: 'referring_practitioner_id = ?',
        whereArgs: [practitionerId],
      );
      affected.addAll(rows.map((r) => r['patient_id'] as String));
      if (expectedPatientIds != null &&
          (affected.length != expectedPatientIds.length ||
              !affected.containsAll(expectedPatientIds))) {
        throw StateError(
          'La liste des patients a changé. Rechargez-la avant d’archiver.',
        );
      }
      await verifyExport?.call(txn);
      await txn.update(
        'companion_patient_access',
        {
          'referring_practitioner_id': null,
          'former_practitioner_id': practitionerId,
          'departure_date': day.millisecondsSinceEpoch,
        },
        where: 'referring_practitioner_id = ?',
        whereArgs: [practitionerId],
      );
      await txn.update(
        'practitioners',
        {'archived_at': now, 'updated_at': now},
        where: 'practitioner_id = ?',
        whereArgs: [practitionerId],
      );
      final cutoff = DateTime(
        DateTime.now().year - 1,
        DateTime.now().month,
        DateTime.now().day,
      ).millisecondsSinceEpoch;
      await txn.delete(
        'companion_access_events',
        where: 'occurred_at < ?',
        whereArgs: [cutoff],
      );
      for (final patientId in affected) {
        await txn.insert('companion_access_events', {
          'occurred_at': now,
          'action': 'patient_unassigned_on_departure',
          'patient_id': patientId,
          'previous_practitioner_id': practitionerId,
        });
      }
      await txn.insert('companion_access_events', {
        'occurred_at': now,
        'action': 'practitioner_archived',
        'target_practitioner_id': practitionerId,
      });
    });
    CompanionAccessService.patientAssignmentsChanged.value = Set.unmodifiable(
      affected,
    );
    CompanionAccessService.practitionerArchived.value = null;
    CompanionAccessService.practitionerArchived.value = practitionerId;
  }

  Future<List<PractitionerDeparturePatient>> departurePatients(
    String practitionerId, {
    DateTime? now,
  }) async {
    final db = await _database();
    if ((await db.query(
      'companion_practitioner_access',
      where: 'practitioner_id=? AND is_administrator=1',
      whereArgs: [practitionerId],
    )).isNotEmpty) {
      throw StateError(
        'Retirez le statut administrateur avant d’archiver ce kiné.',
      );
    }
    final time = now ?? DateTime.now();
    final cutoff = threeCalendarMonthsBefore(time).millisecondsSinceEpoch;
    final rows = await db.rawQuery(
      """WITH activity AS (
      SELECT e.patient_id, r.createdAt AS stamp, 0 AS inferred FROM desktop_results r JOIN care_episodes e USING(care_episode_id)
      UNION ALL SELECT e.patient_id, b.assessment_date, 0 FROM care_episode_assessments b JOIN care_episodes e USING(care_episode_id)
      UNION ALL SELECT e.patient_id, a.last_content_at, a.inferred FROM companion_report_activity a
        JOIN care_episode_reports r USING(report_id) JOIN care_episodes e USING(care_episode_id)
      UNION ALL SELECT e.patient_id, d.updated_at, 1 FROM care_episode_document_edit_drafts d
        JOIN care_episode_reports r ON d.document_id = r.report_id AND d.document_type = 'report'
        JOIN care_episodes e USING(care_episode_id)
    ) SELECT p.patient_id, p.last_name, p.first_name, p.archived_at,
      MAX(x.stamp) AS last_activity, MAX(CASE WHEN x.stamp >= ? THEN x.inferred ELSE 0 END) AS inferred
      FROM patients p JOIN companion_patient_access a USING(patient_id)
      LEFT JOIN activity x ON x.patient_id = p.patient_id AND x.stamp <= ?
      WHERE a.referring_practitioner_id = ? GROUP BY p.patient_id
      ORDER BY p.last_name COLLATE NOCASE, p.first_name COLLATE NOCASE, p.patient_id""",
      [cutoff, time.millisecondsSinceEpoch, practitionerId],
    );
    return rows.map((r) {
      final stamp = r['last_activity'] as int?;
      return PractitionerDeparturePatient(
        id: r['patient_id'] as String,
        name: '${r['last_name']} ${r['first_name']}',
        archived: r['archived_at'] != null,
        active: stamp != null && stamp >= cutoff,
        inferred: r['inferred'] == 1,
        lastActivity: stamp == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(stamp),
      );
    }).toList();
  }

  Future<List<Practitioner>> getArchivedPractitioners() async {
    final db = await _database();

    final rows = await db.query(
      'practitioners',
      where: 'archived_at IS NOT NULL',
      orderBy: 'archived_at DESC',
    );

    return rows.map(Practitioner.fromMap).toList();
  }

  Future<void> restorePractitioner(String practitionerId) async {
    final db = await _database();

    await db.update(
      'practitioners',
      {
        'archived_at': null,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'practitioner_id = ?',
      whereArgs: [practitionerId],
    );
  }

  Future<Practitioner?> getPractitionerById(String practitionerId) async {
    final db = await _database();

    final rows = await db.query(
      'practitioners',
      where: 'practitioner_id = ?',
      whereArgs: [practitionerId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return Practitioner.fromMap(rows.first);
  }
}

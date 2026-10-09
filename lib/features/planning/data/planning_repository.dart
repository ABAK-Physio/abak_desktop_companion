import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/planning_appointment.dart';
import '../models/planning_opening_hours.dart';
import 'planning_opening_hours_repository.dart';
import '../../patients/models/patient.dart';

/// Explicit database provider: constructing this repository never opens or
/// migrates the Companion database. Resolve on every operation for restoration.
class PlanningRepository {
  const PlanningRepository({required this.database});

  final Future<Database> Function() database;
  static const _table = 'planning_appointments';
  static const _select =
      'SELECT a.*, '
      "trim(p.last_name || ' ' || p.first_name) || CASE WHEN p.archived_at IS NOT NULL THEN ' (archivé)' ELSE '' END AS patient_label "
      'FROM planning_appointments a LEFT JOIN patients p ON p.patient_id = a.patient_id';

  Future<PlanningOpeningHours?> loadOpeningHours() =>
      PlanningOpeningHoursRepository(database: database).load();

  Future<Patient?> getPatient(String id) async {
    final db = await database();
    final rows = await db.query(
      'patients',
      where: 'patient_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : Patient.fromMap(rows.single);
  }

  Future<List<Patient>> searchPatients(String query) async {
    final db = await database();
    final rows = await db.query(
      'patients',
      where: 'archived_at IS NULL',
      orderBy:
          'last_name COLLATE NOCASE, first_name COLLATE NOCASE, patient_id',
    );
    final words = query.trim().toLowerCase().split(RegExp(r'\s+'));
    return rows
        .map(Patient.fromMap)
        .where((patient) {
          final text = '${patient.displayName} ${patient.birthDate ?? ''}'
              .toLowerCase();
          return words.every(text.contains);
        })
        .take(30)
        .toList();
  }

  Future<void> _checkPatient(DatabaseExecutor db, String? id) async {
    if (id == null) return;
    final rows = await db.query(
      'patients',
      columns: ['patient_id'],
      where: 'patient_id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) throw StateError('Patient introuvable.');
  }

  Future<List<PlanningAppointment>> listAll() async {
    final db = await database();
    final rows = await db.rawQuery(
      '$_select ORDER BY a.appointment_date, a.start_minute, a.appointment_id',
    );
    return rows.map(PlanningAppointment.fromMap).toList();
  }

  /// Civil-date interval [from, until), shared by day/week/month views.
  Future<List<PlanningAppointment>> list({
    required DateTime from,
    required DateTime until,
  }) async {
    final first = PlanningAppointment.dateKey(from);
    final last = PlanningAppointment.dateKey(until);
    if (first.compareTo(last) >= 0) {
      throw ArgumentError('La fin de période doit suivre son début.');
    }
    final db = await database();
    final rows = await db.rawQuery(
      '$_select WHERE a.appointment_date >= ? AND a.appointment_date < ? ORDER BY a.appointment_date, a.start_minute, a.appointment_id',
      [first, last],
    );
    return rows.map(PlanningAppointment.fromMap).toList();
  }

  /// Also restores a deleted appointment with its original identifier.
  /// Duplicate identifiers fail instead of silently overwriting another row.
  Future<void> insert(PlanningAppointment appointment) async {
    final db = await database();
    await db.transaction((txn) async {
      await _checkPatient(txn, appointment.patientId);
      await txn.insert(
        _table,
        appointment.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    });
  }

  Future<void> update(PlanningAppointment appointment) async {
    final db = await database();
    final count = await db.transaction((txn) async {
      await _checkPatient(txn, appointment.patientId);
      return txn.update(
        _table,
        appointment.toMap(),
        where: 'appointment_id = ?',
        whereArgs: [appointment.id],
      );
    });
    if (count != 1) throw StateError('Rendez-vous introuvable.');
  }

  Future<void> delete(String id) async {
    final db = await database();
    final count = await db.delete(
      _table,
      where: 'appointment_id = ?',
      whereArgs: [id],
    );
    if (count != 1) throw StateError('Rendez-vous introuvable.');
  }
}

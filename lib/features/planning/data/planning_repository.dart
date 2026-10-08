import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/planning_appointment.dart';

/// Explicit database provider: constructing this repository never opens or
/// migrates the Companion database. Resolve on every operation for restoration.
class PlanningRepository {
  const PlanningRepository({required this.database});

  final Future<Database> Function() database;
  static const _table = 'planning_appointments';

  Future<List<PlanningAppointment>> listAll() async {
    final db = await database();
    final rows = await db.query(
      _table,
      orderBy: 'appointment_date, start_minute, appointment_id',
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
    final rows = await db.query(
      _table,
      where: 'appointment_date >= ? AND appointment_date < ?',
      whereArgs: [first, last],
      orderBy: 'appointment_date, start_minute, appointment_id',
    );
    return rows.map(PlanningAppointment.fromMap).toList();
  }

  /// Also restores a deleted appointment with its original identifier.
  /// Duplicate identifiers fail instead of silently overwriting another row.
  Future<void> insert(PlanningAppointment appointment) async {
    final db = await database();
    await db.insert(
      _table,
      appointment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  Future<void> update(PlanningAppointment appointment) async {
    final db = await database();
    final count = await db.update(
      _table,
      appointment.toMap(),
      where: 'appointment_id = ?',
      whereArgs: [appointment.id],
    );
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

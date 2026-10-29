import '../../../core/database/database_service.dart';
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

    await db.insert('practitioners', practitioner.toMap());
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

  Future<void> archivePractitioner(String practitionerId) async {
    final db = await _database();
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'practitioners',
      {'archived_at': now, 'updated_at': now},
      where: 'practitioner_id = ?',
      whereArgs: [practitionerId],
    );
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

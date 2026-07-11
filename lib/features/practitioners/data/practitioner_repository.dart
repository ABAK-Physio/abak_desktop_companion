import '../../../core/database/database_service.dart';
import '../models/practitioner.dart';

class PractitionerRepository {
  Future<List<Practitioner>> getActivePractitioners() async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'practitioners',
      where: 'archived_at IS NULL',
      orderBy: 'display_name COLLATE NOCASE ASC',
    );

    return rows.map(Practitioner.fromMap).toList();
  }

  Future<void> insertPractitioner(Practitioner practitioner) async {
    final db = await DatabaseService.database;

    await db.insert('practitioners', practitioner.toMap());
  }

  Future<void> updatePractitioner(Practitioner practitioner) async {
    final db = await DatabaseService.database;

    await db.update(
      'practitioners',
      practitioner.toMap(),
      where: 'practitioner_id = ?',
      whereArgs: [practitioner.practitionerId],
    );
  }

  Future<void> archivePractitioner(String practitionerId) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'practitioners',
      {'archived_at': now, 'updated_at': now},
      where: 'practitioner_id = ?',
      whereArgs: [practitionerId],
    );
  }

  Future<List<Practitioner>> getArchivedPractitioners() async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'practitioners',
      where: 'archived_at IS NOT NULL',
      orderBy: 'archived_at DESC',
    );

    return rows.map(Practitioner.fromMap).toList();
  }

  Future<void> restorePractitioner(String practitionerId) async {
    final db = await DatabaseService.database;

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
}

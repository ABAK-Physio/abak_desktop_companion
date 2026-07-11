import '../../../core/database/database_service.dart';
import '../models/patient_identity.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

class PatientIdentityRepository {
  Future<PatientIdentity?> getByPatientId(String patientId) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'patient_identity',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return PatientIdentity.fromMap(rows.first);
  }

  Future<void> upsert(PatientIdentity identity) async {
    final db = await DatabaseService.database;

    await db.insert(
      'patient_identity',
      identity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteByPatientId(String patientId) async {
    final db = await DatabaseService.database;

    await db.delete(
      'patient_identity',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
  }
}

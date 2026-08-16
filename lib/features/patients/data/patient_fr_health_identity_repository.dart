import '../../../core/database/database_service.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/patient_fr_health_identity.dart';

class PatientFrHealthIdentityRepository {
  Future<PatientFrHealthIdentity?> getByPatientId(
      String patientId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'patient_fr_health_identity',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return PatientFrHealthIdentity.fromMap(rows.first);
  }

  Future<void> save(
      PatientFrHealthIdentity identity,
      ) async {
    final db = await DatabaseService.database;

    await db.insert(
      'patient_fr_health_identity',
      identity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }
}
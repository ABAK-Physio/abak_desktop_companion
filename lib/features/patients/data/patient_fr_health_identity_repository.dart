import '../../../core/database/database_service.dart';
import '../models/patient_fr_health_identity.dart';

class PatientFrHealthIdentityRepository {
  Future<PatientFrHealthIdentity?> getByPatientId(String patientId) async {
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

  Future<void> save(PatientFrHealthIdentity identity) async {
    final db = await DatabaseService.database;

    // Preserve additional identity/provenance columns not represented by this
    // legacy model. REPLACE would delete them when updating an existing INS.
    await db.transaction((txn) async {
      final count = await txn.update(
        'patient_fr_health_identity',
        identity.toMap(),
        where: 'patient_id = ?',
        whereArgs: [identity.patientId],
      );
      if (count == 0) {
        await txn.insert('patient_fr_health_identity', identity.toMap());
      }
    });
  }
}

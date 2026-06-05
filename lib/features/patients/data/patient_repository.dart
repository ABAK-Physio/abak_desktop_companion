import '../../../core/database/database_service.dart';
import 'package:uuid/uuid.dart';
import '../models/patient.dart';

class PatientRepository {
  Future<List<Patient>> getAllPatients() async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'patients',
      where: 'archived_at IS NULL',
      orderBy: 'last_name COLLATE NOCASE ASC, first_name COLLATE NOCASE ASC',
    );

    return rows.map(Patient.fromMap).toList();
  }

  // Methodes

  Future<void> deletePatientPermanently(
      String patientId,
      ) async {
    final db = await DatabaseService.database;

    await db.delete(
      'patients',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
  }

  Future<Patient> createPatient({
    required String lastName,
    required String firstName,
    String? birthDate,
    String sexCode = 'U',
  }) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final patient = Patient(
      patientId: const Uuid().v4(),
      lastName: lastName,
      firstName: firstName,
      birthDate: birthDate,
      sexCode: sexCode,
      createdAt: now,
      updatedAt: now,
    );

    await db.insert(
      'patients',
      patient.toMap(),
    );

    return patient;
  }

  Future<List<Patient>> getPatients() async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'patients',
      where: 'archived_at IS NULL',
      orderBy: 'last_name COLLATE NOCASE ASC, first_name COLLATE NOCASE ASC',
    );

    return rows.map(Patient.fromMap).toList();
  }


  Future<void> archivePatient(String patientId) async {
    final db = await DatabaseService.database;

    await db.update(
      'patients',
      {
        'archived_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
  }

  Future<void> insertPatient(Patient patient) async {
    final db = await DatabaseService.database;

    await db.insert(
      'patients',
      patient.toMap(),
    );
  }

  Future<void> updatePatient(Patient patient) async {
    final db = await DatabaseService.database;

    await db.update(
      'patients',
      patient.toMap(),
      where: 'patient_id = ?',
      whereArgs: [patient.patientId],
    );
  }

  Future<List<Patient>> getArchivedPatients() async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'patients',
      where: 'archived_at IS NOT NULL',
      orderBy: 'archived_at DESC',
    );

    return rows.map(Patient.fromMap).toList();
  }

  Future<void> restorePatient(String patientId) async {
    final db = await DatabaseService.database;

    await db.update(
      'patients',
      {
        'archived_at': null,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
  }

  Future<Patient?> getPatientById(String patientId) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'patients',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return Patient.fromMap(rows.first);
  }

}
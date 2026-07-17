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

  // Méthodes

  Future<void> deletePatientPermanently(String patientId) async {
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
    String? nir,
  }) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final patient = Patient(
      patientId: const Uuid().v4(),
      lastName: lastName,
      firstName: firstName,
      birthDate: birthDate,
      sexCode: sexCode,
      nir: nir?.trim().isEmpty == true ? null : nir?.trim(),
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

  // Le patient possède un nir
  Future<Patient?> getPatientByNir(String nir) async {
    final normalizedNir = nir.trim();

    if (normalizedNir.isEmpty) {
      return null;
    }

    final db = await DatabaseService.database;

    final rows = await db.query(
      'patients',
      where: '''
      archived_at IS NULL
      AND nir = ?
    ''',
      whereArgs: [normalizedNir],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return Patient.fromMap(rows.first);
  }

  // Recherche un patient archivé par NIR.
  Future<Patient?> getArchivedPatientByNir(String nir) async {
    final normalizedNir = nir.trim();

    if (normalizedNir.isEmpty) {
      return null;
    }

    final db = await DatabaseService.database;

    final rows = await db.query(
      'patients',
      where: '''
      archived_at IS NOT NULL
      AND nir = ?
    ''',
      whereArgs: [normalizedNir],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return Patient.fromMap(rows.first);
  }

  // pas de nir recherche par identité
  Future<List<Patient>> findPatientsByIdentity({
    required String lastName,
    required String firstName,
    required String birthDate,
  }) async {
    final normalizedLastName = lastName.trim();
    final normalizedFirstName = firstName.trim();
    final normalizedBirthDate = birthDate.trim();

    if (normalizedLastName.isEmpty ||
        normalizedFirstName.isEmpty ||
        normalizedBirthDate.isEmpty) {
      return [];
    }

    final db = await DatabaseService.database;

    final rows = await db.query(
      'patients',
      where: '''
      archived_at IS NULL
      AND last_name = ? COLLATE NOCASE
      AND first_name = ? COLLATE NOCASE
      AND birth_date = ?
    ''',
      whereArgs: [
        normalizedLastName,
        normalizedFirstName,
        normalizedBirthDate,
      ],
      orderBy: 'last_name COLLATE NOCASE, first_name COLLATE NOCASE',
    );

    return rows.map(Patient.fromMap).toList();
  }

  // Recherche des patients archivés par nom, prénom et date de naissance.
  Future<List<Patient>> findArchivedPatientsByIdentity({
    required String lastName,
    required String firstName,
    required String birthDate,
  }) async {
    final normalizedLastName = lastName.trim();
    final normalizedFirstName = firstName.trim();
    final normalizedBirthDate = birthDate.trim();

    if (normalizedLastName.isEmpty ||
        normalizedFirstName.isEmpty ||
        normalizedBirthDate.isEmpty) {
      return [];
    }

    final db = await DatabaseService.database;

    final rows = await db.query(
      'patients',
      where: '''
      archived_at IS NOT NULL
      AND last_name = ? COLLATE NOCASE
      AND first_name = ? COLLATE NOCASE
      AND birth_date = ?
    ''',
      whereArgs: [
        normalizedLastName,
        normalizedFirstName,
        normalizedBirthDate,
      ],
      orderBy: 'archived_at DESC',
    );

    return rows.map(Patient.fromMap).toList();
  }

  // permet de rattacher un nir à un patient créé manuellement
  Future<void> attachNirToPatient({
    required String patientId,
    required String nir,
  }) async {
    final normalizedNir = nir.trim();

    if (normalizedNir.isEmpty) {
      return;
    }

    final db = await DatabaseService.database;

    await db.transaction((transaction) async {
      final existingRows = await transaction.query(
        'patients',
        columns: ['patient_id'],
        where: '''
        nir = ?
        AND patient_id <> ?
      ''',
        whereArgs: [
          normalizedNir,
          patientId,
        ],
        limit: 1,
      );

      if (existingRows.isNotEmpty) {
        throw StateError(
          'Ce NIR est déjà associé à un autre patient.',
        );
      }

      await transaction.update(
        'patients',
        {
          'nir': normalizedNir,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'patient_id = ?',
        whereArgs: [patientId],
      );
    });
  }

}
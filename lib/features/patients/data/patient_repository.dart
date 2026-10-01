import '../../../core/database/database_service.dart';
import 'package:uuid/uuid.dart';

import '../models/patient.dart';

class PatientRepository {
  // Compare name formatting without changing the stored identity.
  static String normalizeIdentityName(String value) {
    return value.toUpperCase()
        .replaceAll(RegExp(r'[-\u2010-\u2015\u2212]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

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

    // Delete children explicitly: existing databases do not cascade patient
    // deletion, and foreign-key enforcement may be disabled. No archive filter
    // is applied, so both active and archived episodes are removed.
    await db.transaction((txn) async {
      const episodes =
          'SELECT care_episode_id FROM care_episodes WHERE patient_id = ?';
      const assessments =
          'SELECT assessment_id FROM care_episode_assessments '
          'WHERE care_episode_id IN ($episodes)';
      const reports =
          'SELECT report_id FROM care_episode_reports '
          'WHERE care_episode_id IN ($episodes)';
      const notes =
          'SELECT note_id FROM care_episode_notes '
          'WHERE care_episode_id IN ($episodes)';
      const results =
          'SELECT result_id FROM desktop_results '
          'WHERE patient_id = ? OR care_episode_id IN ($episodes)';
      const sessions =
          'SELECT import_session_id FROM desktop_import_sessions '
          'WHERE selected_patient_id = ? '
          'OR selected_care_episode_id IN ($episodes)';

      await txn.delete(
        'care_episode_document_edit_drafts',
        where: '(document_type = ? AND document_id IN ($assessments)) '
            'OR (document_type = ? AND document_id IN ($reports))',
        whereArgs: ['assessment', patientId, 'report', patientId],
      );
      for (final table in [
        'care_episode_report_tests',
        'care_episode_report_notes',
      ]) {
        await txn.delete(
          table,
          where: 'report_id IN ($reports)',
          whereArgs: [patientId],
        );
      }
      for (final table in [
        'care_episode_assessment_tests',
        'care_episode_assessment_notes',
      ]) {
        await txn.delete(
          table,
          where: 'assessment_id IN ($assessments)',
          whereArgs: [patientId],
        );
      }
      // Also remove references to these notes from any other document.
      for (final table in [
        'care_episode_report_notes',
        'care_episode_assessment_notes',
      ]) {
        await txn.delete(
          table,
          where: 'note_id IN ($notes)',
          whereArgs: [patientId],
        );
      }
      await txn.update(
        'care_episode_reports',
        {'source_assessment_id': null},
        where: 'source_assessment_id IN ($assessments)',
        whereArgs: [patientId],
      );
      for (final table in [
        'desktop_result_metrics',
        'desktop_result_conflicts',
      ]) {
        await txn.delete(
          table,
          where: 'result_id IN ($results)',
          whereArgs: [patientId, patientId],
        );
      }
      await txn.delete(
        'desktop_results',
        where: 'patient_id = ? OR care_episode_id IN ($episodes)',
        whereArgs: [patientId, patientId],
      );
      await txn.delete(
        'desktop_import_session_files',
        where: 'import_session_id IN ($sessions)',
        whereArgs: [patientId, patientId],
      );
      await txn.delete(
        'desktop_import_sessions',
        where: 'selected_patient_id = ? '
            'OR selected_care_episode_id IN ($episodes)',
        whereArgs: [patientId, patientId],
      );
      await txn.delete(
        'episode_documents',
        where: 'case_id IN ($episodes)',
        whereArgs: [patientId],
      );
      for (final table in [
        'care_episode_reports',
        'care_episode_assessments',
        'care_episode_notes',
        'care_episode_referring_practitioners',
        'care_episode_bodymaps',
        'assessment_template_drafts',
      ]) {
        await txn.delete(
          table,
          where: 'care_episode_id IN ($episodes)',
          whereArgs: [patientId],
        );
      }
      for (final table in [
        'care_episodes',
        'patient_identity',
        'patient_attributes',
        'patient_fr_health_identity',
        'patients',
      ]) {
        await txn.delete(
          table,
          where: 'patient_id = ?',
          whereArgs: [patientId],
        );
      }
    });
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
    final normalizedLastName = normalizeIdentityName(lastName);
    final normalizedFirstName = normalizeIdentityName(firstName);
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
      AND birth_date = ?
    ''',
      whereArgs: [
        normalizedBirthDate,
      ],
      orderBy: 'last_name COLLATE NOCASE, first_name COLLATE NOCASE',
    );

    return rows.map(Patient.fromMap).where((patient) {
      return normalizeIdentityName(patient.lastName) == normalizedLastName &&
          normalizeIdentityName(patient.firstName) == normalizedFirstName;
    }).toList();
  }

  // Recherche des patients archivés par nom, prénom et date de naissance.
  Future<List<Patient>> findArchivedPatientsByIdentity({
    required String lastName,
    required String firstName,
    required String birthDate,
  }) async {
    final normalizedLastName = normalizeIdentityName(lastName);
    final normalizedFirstName = normalizeIdentityName(firstName);
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
      AND birth_date = ?
    ''',
      whereArgs: [
        normalizedBirthDate,
      ],
      orderBy: 'archived_at DESC',
    );

    return rows.map(Patient.fromMap).where((patient) {
      return normalizeIdentityName(patient.lastName) == normalizedLastName &&
          normalizeIdentityName(patient.firstName) == normalizedFirstName;
    }).toList();
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

    await db.update(
      'patients',
      {
        'nir': normalizedNir,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
  }

}
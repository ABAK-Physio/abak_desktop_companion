import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../core/database/database_service.dart';
import '../models/case_patient_link.dart';
import '../models/mobile_case.dart';

class MobileCaseRepository {
  Future<MobileCase?> getCaseById(String caseId) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'mobile_cases',
      where: 'case_id = ?',
      whereArgs: [caseId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return MobileCase.fromMap(rows.first);
  }

  Future<void> upsertMobileCase(MobileCase mobileCase) async {
    final db = await DatabaseService.database;

    await db.insert(
      'mobile_cases',
      mobileCase.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<CasePatientLink?> getLinkForCase(String caseId) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'case_patient_links',
      where: 'case_id = ? AND status = ?',
      whereArgs: [caseId, 'linked'],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return CasePatientLink.fromMap(rows.first);
  }

  Future<void> linkCaseToPatient({
    required String caseId,
    required String patientId,
    String? practitionerId,
  }) async {
    final db = await DatabaseService.database;

    final link = CasePatientLink(
      caseId: caseId,
      patientId: patientId,
      linkedAt: DateTime.now().millisecondsSinceEpoch,
      linkedByPractitionerId: practitionerId,
    );

    await db.insert(
      'case_patient_links',
      link.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<String?> getLinkedPatientIdForCase(String caseId) async {
    final link = await getLinkForCase(caseId);
    return link?.patientId;
  }

  Future<List<MobileCase>> getCasesForPatient(String patientId) async {
    final db = await DatabaseService.database;

    final rows = await db.rawQuery(
      '''
    SELECT mc.*
    FROM mobile_cases mc
    INNER JOIN case_patient_links cpl
      ON cpl.case_id = mc.case_id
    WHERE cpl.patient_id = ?
      AND cpl.status = ?
      AND mc.archived_at IS NULL
    ORDER BY mc.updated_at DESC, mc.created_at DESC
    ''',
      [patientId, 'linked'],
    );

    return rows.map(MobileCase.fromMap).toList();
  }
}
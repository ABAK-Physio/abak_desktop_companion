import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_service.dart';
import '../models/patient_attribute.dart';

class PatientAttributeRepository {
  final Uuid _uuid = const Uuid();

  Future<List<PatientAttribute>> getByPatientId(String patientId) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'patient_attributes',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'attribute_key ASC',
    );

    return rows.map(PatientAttribute.fromMap).toList();
  }

  Future<PatientAttribute?> getOne({
    required String patientId,
    required String attributeKey,
  }) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'patient_attributes',
      where: 'patient_id = ? AND attribute_key = ?',
      whereArgs: [patientId, attributeKey],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return PatientAttribute.fromMap(rows.first);
  }

  Future<void> upsertValue({
    required String patientId,
    required String attributeKey,
    required String? attributeValue,
  }) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final existing = await getOne(
      patientId: patientId,
      attributeKey: attributeKey,
    );

    final attribute = PatientAttribute(
      attributeId: existing?.attributeId ?? _uuid.v4(),
      patientId: patientId,
      attributeKey: attributeKey,
      attributeValue: attributeValue,
      updatedAt: now,
    );

    await db.insert(
      'patient_attributes',
      attribute.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteOne({
    required String patientId,
    required String attributeKey,
  }) async {
    final db = await DatabaseService.database;

    await db.delete(
      'patient_attributes',
      where: 'patient_id = ? AND attribute_key = ?',
      whereArgs: [patientId, attributeKey],
    );
  }

  Future<void> deleteByPatientId(String patientId) async {
    final db = await DatabaseService.database;

    await db.delete(
      'patient_attributes',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
  }
}

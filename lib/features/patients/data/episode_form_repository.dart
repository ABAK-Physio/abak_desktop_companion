import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_service.dart';
import '../models/contact_form_field.dart';
import '../models/episode_form.dart';
import '../models/episode_form_answer.dart';

class EpisodeFormRepository {
  final Uuid _uuid = const Uuid();

  Future<List<EpisodeForm>> getFormsByCaseId(String caseId) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'episode_forms',
      where: 'case_id = ? AND archived_at IS NULL',
      whereArgs: [caseId],
      orderBy: 'created_at DESC',
    );

    return rows.map(EpisodeForm.fromMap).toList();
  }

  Future<EpisodeForm?> getById(String formId) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'episode_forms',
      where: 'form_id = ?',
      whereArgs: [formId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return EpisodeForm.fromMap(rows.first);
  }

  Future<EpisodeForm> createForm({
    required String caseId,
    required String templateId,
  }) async {
    final existing = await getFormForCaseAndTemplate(
      caseId: caseId,
      templateId: templateId,
    );

    if (existing != null) {
      return existing;
    }

    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final form = EpisodeForm(
      formId: _uuid.v4(),
      caseId: caseId,
      templateId: templateId,
      createdAt: now,
    );

    await db.insert(
      'episode_forms',
      form.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    return form;
  }

  Future<List<EpisodeFormAnswer>> getAnswers(String formId) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'episode_form_answers',
      where: 'form_id = ?',
      whereArgs: [formId],
      orderBy: 'updated_at ASC',
    );

    return rows.map(EpisodeFormAnswer.fromMap).toList();
  }

  Future<void> upsertAnswer({
    required String formId,
    required String fieldId,
    required String? value,
  }) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final existing = await db.query(
      'episode_form_answers',
      where: 'form_id = ? AND field_id = ?',
      whereArgs: [formId, fieldId],
      limit: 1,
    );

    final answer = EpisodeFormAnswer(
      answerId: existing.isEmpty
          ? _uuid.v4()
          : existing.first['answer_id'] as String,
      formId: formId,
      fieldId: fieldId,
      value: value,
      updatedAt: now,
    );

    await db.insert(
      'episode_form_answers',
      answer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<bool> isFormComplete(String formId) async {
    final data = await getFormWithAnswers(
      formId: formId,
    );

    for (final entry in data.entries) {
      final field = entry.key;
      final answer = entry.value;

      if (!field.required) {
        continue;
      }

      final value = answer?.value?.trim() ?? '';

      if (value.isEmpty) {
        return false;
      }
    }

    return true;
  }

  Future<void> archiveForm(String formId) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'episode_forms',
      {
        'archived_at': now,
        'updated_at': now,
      },
      where: 'form_id = ?',
      whereArgs: [formId],
    );
  }

  Future<Map<ContactFormField, EpisodeFormAnswer?>> getFormWithAnswers({
    required String formId,
  }) async {
    final db = await DatabaseService.database;

    final rows = await db.rawQuery(
      '''
      SELECT
        f.field_id,
        f.template_id,
        f.label,
        f.field_type,
        f.target_scope,
        f.sort_order,
        f.required,
        f.options_json,
        f.created_at,
        f.updated_at,
        f.archived_at,

        a.answer_id AS answer_id,
        a.form_id AS answer_form_id,
        a.value AS answer_value,
        a.updated_at AS answer_updated_at
      FROM episode_forms ef
      INNER JOIN contact_form_fields f
        ON f.template_id = ef.template_id
      LEFT JOIN episode_form_answers a
        ON a.field_id = f.field_id
        AND a.form_id = ef.form_id
      WHERE ef.form_id = ?
        AND f.archived_at IS NULL
      ORDER BY f.sort_order ASC
      ''',
      [formId],
    );

    final result = <ContactFormField, EpisodeFormAnswer?>{};

    for (final row in rows) {
      final field = ContactFormField.fromMap(row);

      final answerId = row['answer_id'] as String?;

      final answer = answerId == null
          ? null
          : EpisodeFormAnswer(
        answerId: answerId,
        formId: row['answer_form_id'] as String,
        fieldId: row['field_id'] as String,
        value: row['answer_value'] as String?,
        updatedAt: row['answer_updated_at'] as int,
      );

      result[field] = answer;
    }

    return result;
  }

  Future<EpisodeForm?> getFormForCaseAndTemplate({
    required String caseId,
    required String templateId,
  }) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'episode_forms',
      where: 'case_id = ? AND template_id = ? AND archived_at IS NULL',
      whereArgs: [caseId, templateId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return EpisodeForm.fromMap(rows.first);
  }
}
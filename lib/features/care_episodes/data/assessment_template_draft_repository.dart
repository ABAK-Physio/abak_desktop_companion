import 'dart:convert';

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../core/database/database_service.dart';
import '../models/assessment_templates/assessment_template_answers.dart';

class AssessmentTemplateDraftRepository {
  Future<AssessmentTemplateAnswers?> getDraft({
    required String careEpisodeId,
    required String templateId,
  }) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'assessment_template_drafts',
      where: 'care_episode_id = ? AND template_id = ?',
      whereArgs: [
        careEpisodeId,
        templateId,
      ],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    final answersJson =
        rows.first['answers_json']?.toString() ?? '{}';

    final decoded = jsonDecode(answersJson);

    if (decoded is! Map<String, dynamic>) {
      return null;
    }

    return AssessmentTemplateAnswers(
      templateId: templateId,
      values: decoded,
    );
  }

  Future<void> saveDraft({
    required String careEpisodeId,
    required AssessmentTemplateAnswers answers,
  }) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    final existing = await db.query(
      'assessment_template_drafts',
      columns: [
        'draft_id',
        'created_at',
      ],
      where: 'care_episode_id = ? AND template_id = ?',
      whereArgs: [
        careEpisodeId,
        answers.templateId,
      ],
      limit: 1,
    );

    final draftId = existing.isNotEmpty
        ? existing.first['draft_id']!.toString()
        : '${careEpisodeId}_${answers.templateId}';

    final createdAt = existing.isNotEmpty
        ? (existing.first['created_at'] as num).toInt()
        : now;

    await db.insert(
      'assessment_template_drafts',
      {
        'draft_id': draftId,
        'care_episode_id': careEpisodeId,
        'template_id': answers.templateId,
        'answers_json': jsonEncode(answers.values),
        'created_at': createdAt,
        'updated_at': now,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteDraft({
    required String careEpisodeId,
    required String templateId,
  }) async {
    final db = await DatabaseService.database;

    await db.delete(
      'assessment_template_drafts',
      where: 'care_episode_id = ? AND template_id = ?',
      whereArgs: [
        careEpisodeId,
        templateId,
      ],
    );
  }
}
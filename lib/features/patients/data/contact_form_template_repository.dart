import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../core/database/database_service.dart';
import '../models/contact_form_template.dart';
import '../models/contact_form_field.dart';

class ContactFormTemplateRepository {
  Future<List<ContactFormTemplate>> getActiveTemplates() async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'contact_form_templates',
      where: 'archived_at IS NULL',
      orderBy: 'name ASC',
    );

    return rows.map(ContactFormTemplate.fromMap).toList();
  }

  Future<ContactFormTemplate?> getById(String templateId) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'contact_form_templates',
      where: 'template_id = ?',
      whereArgs: [templateId],
      limit: 1,
    );

    if (rows.isEmpty) return null;

    return ContactFormTemplate.fromMap(rows.first);
  }

  Future<List<ContactFormField>> getFields(String templateId) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'contact_form_fields',
      where: 'template_id = ? AND archived_at IS NULL',
      whereArgs: [templateId],
      orderBy: 'sort_order ASC',
    );

    return rows.map(ContactFormField.fromMap).toList();
  }

  Future<void> upsertTemplate(ContactFormTemplate template) async {
    final db = await DatabaseService.database;

    await db.insert(
      'contact_form_templates',
      template.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> upsertField(ContactFormField field) async {
    final db = await DatabaseService.database;

    await db.insert(
      'contact_form_fields',
      field.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> archiveTemplate(String templateId) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'contact_form_templates',
      {'archived_at': now, 'updated_at': now},
      where: 'template_id = ?',
      whereArgs: [templateId],
    );
  }

  Future<void> archiveField(String fieldId) async {
    final db = await DatabaseService.database;
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.update(
      'contact_form_fields',
      {'archived_at': now, 'updated_at': now},
      where: 'field_id = ?',
      whereArgs: [fieldId],
    );
  }
}

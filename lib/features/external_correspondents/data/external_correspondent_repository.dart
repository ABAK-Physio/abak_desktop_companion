import '../../../core/database/database_service.dart';
import '../models/external_correspondent.dart';

class ExternalCorrespondentRepository {
  Future<List<ExternalCorrespondent>> getActiveCorrespondents() async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'external_correspondents',
      where: 'archived_at IS NULL',
      orderBy: 'last_name COLLATE NOCASE, first_name COLLATE NOCASE',
    );

    return rows
        .map(ExternalCorrespondent.fromMap)
        .toList();
  }

  Future<ExternalCorrespondent?> getById(
      String correspondentId,
      ) async {
    final db = await DatabaseService.database;

    final rows = await db.query(
      'external_correspondents',
      where: 'correspondent_id = ?',
      whereArgs: [correspondentId],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return ExternalCorrespondent.fromMap(rows.first);
  }

  Future<void> insert(
      ExternalCorrespondent correspondent,
      ) async {
    final db = await DatabaseService.database;

    await db.insert(
      'external_correspondents',
      correspondent.toMap(),
    );
  }

  Future<void> update(
      ExternalCorrespondent correspondent,
      ) async {
    final db = await DatabaseService.database;

    await db.update(
      'external_correspondents',
      correspondent.toMap(),
      where: 'correspondent_id = ?',
      whereArgs: [correspondent.correspondentId],
    );
  }

  Future<void> archive(
      String correspondentId,
      ) async {
    final db = await DatabaseService.database;

    await db.update(
      'external_correspondents',
      {
        'archived_at': DateTime.now().millisecondsSinceEpoch,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'correspondent_id = ?',
      whereArgs: [correspondentId],
    );
  }
}
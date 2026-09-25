import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/database/database_service.dart';
import 'pain_record.dart';
import 'regions.dart';
import 'joint_regions.dart';

/// One current record per care episode. Graphics and their IDs stay versioned
/// inside the payload; ownership is enforced through the parent care episode.
class BodymapRepository {
  BodymapRepository({Future<Database> Function()? database})
    : _database = database ?? (() => DatabaseService.database);
  final Future<Database> Function() _database;

  Future<void> _checkOwner(
    DatabaseExecutor db,
    String episode,
    String patient,
  ) async {
    final rows = await db.query(
      'care_episodes',
      columns: ['care_episode_id'],
      where: 'care_episode_id = ? AND patient_id = ? AND archived_at IS NULL',
      whereArgs: [episode, patient],
      limit: 1,
    );
    if (rows.isEmpty) {
      throw StateError(
        'Épisode absent, archivé ou associé à un autre patient.',
      );
    }
  }

  void _validate(PainRecord record) {
    if (record.needsLateralityReview ||
        record.entries.keys.any(
          (id) => !regionLabels.containsKey(id) && !jointLabels.containsKey(id),
        )) {
      throw const FormatException('Carte ou zone non prise en charge.');
    }
    for (final entry in record.entries.values) {
      PainEntry.fromJson(entry.toJson());
    }
  }

  Future<PainRecord?> load({
    required String careEpisodeId,
    required String patientId,
  }) async {
    final db = await _database();
    return db.transaction((txn) async {
      await _checkOwner(txn, careEpisodeId, patientId);
      final rows = await txn.query(
        'care_episode_bodymaps',
        where: 'care_episode_id = ?',
        whereArgs: [careEpisodeId],
        limit: 1,
      );
      if (rows.isEmpty) return null;
      final record = PainRecord.fromJson(
        jsonDecode(rows.single['record_json'] as String)
            as Map<String, dynamic>,
      );
      _validate(record);
      return record;
    });
  }

  Future<void> save({
    required String careEpisodeId,
    required String patientId,
    required PainRecord record,
  }) async {
    _validate(record);
    final payload = jsonEncode(record.toJson());
    final db = await _database();
    await db.transaction((txn) async {
      await _checkOwner(txn, careEpisodeId, patientId);
      await txn.insert('care_episode_bodymaps', {
        'care_episode_id': careEpisodeId,
        'record_json': payload,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }
}

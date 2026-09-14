import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/features/results/models/desktop_result.dart';
import 'package:abak_desktop_companion/features/results/models/result_walking_aid.dart';
import 'package:abak_desktop_companion/features/results/utils/result_hash_utils.dart';

void main() {
  String payload(String code, String label, [String? description]) =>
      jsonEncode({
        'context': {
          'walkingAidCode': code,
          'walkingAidLabel': label,
          'walkingAidDescription': description,
        },
      });

  test('Accessory survives the result SQLite round trip', () async {
    sqfliteFfiInit();
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);
    final original = DesktopResult(
      resultId: 'test-result',
      careEpisodeId: 'test-episode',
      createdAt: 1,
      importedAt: 2,
      exoId: 'E76',
      exportSimpleText: '',
      structuredJson: payload(
        'other',
        'Deux cannes anglaises',
        'Deux cannes anglaises',
      ),
    );
    final map = original.toMap();
    await db.execute(
      'CREATE TABLE results (${map.keys.map((k) => '"$k"').join(', ')})',
    );
    await db.insert('results', map);
    final restored = DesktopResult.fromMap((await db.query('results')).single);
    expect(restored.walkingAid?.code, 'other');
    expect(restored.walkingAid?.label, 'Deux cannes anglaises');
    expect(restored.walkingAid?.description, 'Deux cannes anglaises');
    expect(restored.copyWith(comment: 'Note').walkingAid?.code, 'other');
  });

  test('Reads each Mobile choice and accepts a JSON object', () {
    for (final code in [
      'none',
      'cane',
      'walkerTwoWheels',
      'rollatorFourWheels',
      'other',
    ]) {
      final raw = payload(code, 'Libellé');
      expect(ResultWalkingAid.fromStructuredJson(raw)?.code, code);
      expect(ResultWalkingAid.fromStructuredJson(jsonDecode(raw))?.code, code);
    }
    for (final raw in [null, '', 'invalid', '{}', '{"context":null}']) {
      expect(ResultWalkingAid.fromStructuredJson(raw), isNull);
    }
  });

  test('Import detects accessory changes without changing legacy hashes', () {
    String hash(Object? data) => ResultHashUtils.computeHash(
      resultId: 'r',
      exoId: 'E76',
      exportSimpleText: '',
      createdAt: 1,
      structuredJson: data,
    );
    expect(hash(null), hash('{}'));
    expect(
      hash(payload('none', 'Aucun')),
      isNot(hash(payload('cane', 'Canne simple'))),
    );
    expect(
      hash(payload('other', 'Autre', 'A')),
      isNot(hash(payload('other', 'Autre', 'B'))),
    );
    expect(
      hash(payload('cane', 'Canne simple')),
      hash(jsonDecode(payload('cane', 'Canne simple'))),
    );
  });
}

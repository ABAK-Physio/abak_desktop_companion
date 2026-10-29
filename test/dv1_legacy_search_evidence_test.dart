import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/search_targets.dart';

void main() {
  test(
    'reviewed evidence retains external provenance and document identity',
    () {
      final bytes = File(
        'test/fixtures/dv1_search/reviewed_legacy_bonnel.json',
      ).readAsBytesSync();
      final target = Dv1SearchTargets.decodeLegacy(bytes);
      expect(target.id, Dv1SearchTargets.legacyId);
      expect(target.data['origin'], 'reviewed_legacy');
      expect(target.data['ins'], '187012425258307');
      expect(target.uniqueId, '2.25.319790098659318552794330109432267023866');
      expect(target.label, contains('Archive technique externe'));
      expect(target.data.containsKey('birth_place_code'), isFalse);
    },
  );
  test('changed evidence is rejected before parsing or use', () {
    final bytes = File(
      'test/fixtures/dv1_search/reviewed_legacy_bonnel.json',
    ).readAsBytesSync();
    bytes[100] ^= 1;
    expect(() => Dv1SearchTargets.decodeLegacy(bytes), throwsStateError);
    expect(() => Dv1SearchTargets.decodeLegacy([]), throwsStateError);
  });
}

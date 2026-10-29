import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/search_targets.dart';

void main() {
  test(
    'suggests archived structure only for the same non-replacement actor',
    () {
      const data = {
        'professional': '12345678901',
        'structure': '123456789012345',
        'replacementFor': '',
      };
      expect(
        Dv1SearchTarget(data).suggestedStructure('12345678901'),
        '123456789012345',
      );
      expect(Dv1SearchTarget(data).suggestedStructure('99999999999'), isNull);
      expect(
        Dv1SearchTarget({
          ...data,
          'replacementFor': '99999999999',
        }).suggestedStructure('12345678901'),
        isNull,
      );
      expect(
        Dv1SearchTarget({
          ...data,
          'structure': '',
        }).suggestedStructure('12345678901'),
        isNull,
      );
      expect(Dv1SearchTarget({}).suggestedStructure('12345678901'), isNull);
    },
  );
}

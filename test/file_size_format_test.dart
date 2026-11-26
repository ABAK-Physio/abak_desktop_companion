import 'package:abak_desktop_companion/core/utils/file_size_format.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const units = ['octets', 'Kio', 'Mio', 'Gio', 'Tio'];
  String fr(int bytes) =>
      formatBinaryFileSize(bytes, locale: 'fr_FR', units: units);
  test('Binary thresholds, optional decimal and French examples', () {
    expect(fr(0), '0 octets');
    expect(fr(512), '512 octets');
    expect(fr(1023), '1 023 octets');
    expect(fr(1024), '1 Kio');
    expect(fr(12624), '12,3 Kio');
    expect(fr((245.8 * 1024 * 1024).round()), '245,8 Mio');
    expect(fr((3.5 * 1024 * 1024 * 1024).round()), '3,5 Gio');
    var boundary = 1024;
    for (var unit = 1; unit <= 4; unit++) {
      expect(fr(boundary), '1 ${units[unit]}');
      expect(fr(boundary - 1).endsWith(' ${units[unit - 1]}'), isTrue);
      expect(fr(boundary + 1).endsWith(' ${units[unit]}'), isTrue);
      boundary *= 1024;
    }
    expect(fr(5 * 1024 * 1024 * 1024 * 1024), '5 Tio');
  });
  for (final locale in [
    'fr_FR',
    'en_GB',
    'de_DE',
    'es_ES',
    'it_IT',
    'pt_PT',
    'nl_NL',
  ]) {
    test(
      'Locale $locale supplies number punctuation and localized binary units',
      () async {
        final parts = locale.split('_');
        await S.load(Locale(parts[0], parts[1]));
        final s = S.current;
        final result = formatBinaryFileSize(
          12624,
          locale: locale,
          units: [
            s.migration_unit_bytes,
            s.migration_unit_kib,
            s.migration_unit_mib,
            s.migration_unit_gib,
            s.migration_unit_tib,
          ],
        );
        expect(
          result,
          locale == 'fr_FR'
              ? '12,3 Kio'
              : locale == 'en_GB'
              ? '12.3 KiB'
              : '12,3 KiB',
        );
      },
    );
  }
  test('Invalid inputs are rejected; byte input remains exact', () {
    expect(() => fr(-1), throwsArgumentError);
    expect(
      () => formatBinaryFileSize(1, locale: 'fr_FR', units: []),
      throwsArgumentError,
    );
    const bytes = 12624;
    fr(bytes);
    expect(bytes, 12624);
  });
}

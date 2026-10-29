import 'package:abak_desktop_companion/core/settings/macos_launch_history_service.dart';
import 'package:flutter_test/flutter_test.dart';

// Only the three comparisons explicitly approved for the CNDA version rename.
// No startup service, preferences, database, CPS or transport is instantiated.
void main() {
  test('CNDA build 23 is not older than 1.1.1 build 10', () {
    expect(
      const CompanionVersion('1.0.2', '23').isOlderThan(
        const CompanionVersion('1.1.1', '10'),
      ),
      isFalse,
    );
  });

  test('CNDA rename at build 23 is not a downgrade', () {
    expect(
      const CompanionVersion('1.0.2', '23').isOlderThan(
        const CompanionVersion('1.1.1', '23'),
      ),
      isFalse,
    );
  });

  test('Returning to build 10 remains blocked', () {
    expect(
      const CompanionVersion('1.1.1', '10').isOlderThan(
        const CompanionVersion('1.0.2', '23'),
      ),
      isTrue,
    );
  });
}

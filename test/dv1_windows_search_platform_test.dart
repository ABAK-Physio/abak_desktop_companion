import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/platform_support.dart';

void main() {
  test('Windows accepts the read-only search for an archived deposit', () {
    expect(
      dv1AccessPlatformSupported(platform: 'windows', documentSearch: true),
      isTrue,
    );
  });
  test('Windows keeps generic access unavailable in this screen', () {
    expect(dv1AccessPlatformSupported(platform: 'windows'), isFalse);
  });
  test('Windows refuses search mixed with another operation', () {
    expect(
      dv1AccessPlatformSupported(
        platform: 'windows',
        documentSearch: true,
        otherAction: true,
      ),
      isFalse,
    );
  });
  test('Windows refuses other operations without a search target', () {
    expect(
      dv1AccessPlatformSupported(platform: 'windows', otherAction: true),
      isFalse,
    );
  });
  test('macOS retains all existing operation combinations', () {
    for (final search in [false, true]) {
      for (final other in [false, true]) {
        expect(
          dv1AccessPlatformSupported(
            platform: 'macos',
            documentSearch: search,
            otherAction: other,
          ),
          isTrue,
        );
      }
    }
  });
  test('other platforms cannot execute any access operation', () {
    for (final platform in ['linux', 'android', 'ios', 'fuchsia', '']) {
      for (final search in [false, true]) {
        for (final other in [false, true]) {
          expect(
            dv1AccessPlatformSupported(
              platform: platform,
              documentSearch: search,
              otherAction: other,
            ),
            isFalse,
          );
        }
      }
    }
  });
}

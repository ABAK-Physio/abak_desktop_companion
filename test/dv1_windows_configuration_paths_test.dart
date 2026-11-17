import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import '../lib/features/patients/services/dmp_chain/native/dv1_configuration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('abak_dmp_fr');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  int calls = 0;
  Object? response;
  setUp(() {
    calls = 0;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls++;
      expect(call.method, 'windowsCpsLibraryPath');
      expect(
        call.arguments,
        isNull,
      ); // Metadata request has no PIN or identity.
      return response;
    });
  });
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));
  for (final value in [
    r'C:\Windows\System32\cps3_pkcs11_w64.dll',
    r'D:\Windows\System32\cps3_pkcs11_w64.dll',
  ]) {
    test('OS CPS metadata accepts $value without a card request', () async {
      response = value;
      expect(await Dv1ConfigurationService.windowsCpsLibraryPath(), value);
      expect(calls, 1);
    });
  }
  for (final value in [
    null,
    '',
    'relative.dll',
    r'C:\Windows\System32\other.dll',
    r'\\server\System32\cps3_pkcs11_w64.dll',
    r'C:\..\System32\cps3_pkcs11_w64.dll',
  ]) {
    test('invalid OS CPS metadata $value blocks configuration', () async {
      response = value;
      await expectLater(
        Dv1ConfigurationService.windowsCpsLibraryPath(),
        throwsStateError,
      );
      expect(calls, 1);
    });
  }
}

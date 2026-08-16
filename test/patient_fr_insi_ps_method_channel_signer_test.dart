import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ps_method_channel_signer.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('abak_dmp_fr');
  const signer = PatientFrInsiPsMethodChannelSigner();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('sign sends canonical SignedInfo and returns SignatureValue', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      channel,
          (MethodCall call) async {
        expect(
          call.method,
          'signInsiPsAssertion',
        );

        expect(
          call.arguments,
          {
            'canonicalSignedInfo': '<ds:SignedInfo>TEST</ds:SignedInfo>',
          },
        );

        return 'TEST_SIGNATURE_BASE64';
      },
    );

    final result = await signer.sign(
      canonicalSignedInfo: '<ds:SignedInfo>TEST</ds:SignedInfo>',
    );

    expect(
      result,
      'TEST_SIGNATURE_BASE64',
    );
  });
}
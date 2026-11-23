import 'dart:convert';
import 'package:abak_desktop_companion/features/cps/cps_access_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/cps/cps_operation_lease.dart';

List<int> tlv(int tag, List<int> bytes) => [tag, bytes.length, ...bytes];
Map<String, List<int>> profile() => {
  'CPS_NAME_PS': tlv(0xe4, tlv(0x84, latin1.encode('TEST'))),
  'CPS_INFO_PS': tlv(0xed, [
    ...tlv(0x80, [0]),
    ...tlv(0x81, '800000000001'.codeUnits),
    ...tlv(0x82, [70]),
    ...tlv(0x84, 'FICTIF'.codeUnits),
  ]),
  'CPS_ACTIVITY_01_PS': tlv(0xee, [
    ...tlv(0x80, [1]),
    ...tlv(0x81, [2]),
    ...tlv(0x83, [1]),
  ]),
};
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const service = CpsAccessService();
  const channel = MethodChannel('abak_dmp_fr');
  const pin = '13572468'; // Dummy PIN, no card.
  const id = '800000000001';
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final calls = <MethodCall>[];
  var response = <String, dynamic>{};
  setUp(() {
    calls.clear();
    response = {
      'success': true,
      'platform': 'windows',
      'objects': profile(),
      'nationalId': id,
      'certificates': [
        {'role': 'signature'},
        {'role': 'authentification'},
      ],
    };
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return response;
    });
  });
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test(
    'preparation and signing reuse the shared explicit business lease',
    () async {
      final lease = await CpsOperationLease.acquireAvailable();
      try {
        final material = await service.prepareDmpLotLocal(
          pin,
          id,
          lease: lease,
        );
        expect(service.profileFromResult(material).nationalId, id);
        expect(calls.single.method, 'prepareDmpLotLocal');
        expect((calls.single.arguments as Map).keys.toSet(), {
          'pin',
          'expectedNationalId',
        });
        expect(CpsOperationLease.inUse, isTrue);
        const info =
            '<SignedInfo>\n<DigestValue>exact</DigestValue>\n</SignedInfo>';
        await service.signDmpLotLocal(pin, id, info, 'Ag==', lease: lease);
        expect(calls.map((c) => c.method), [
          'prepareDmpLotLocal',
          'signDmpLotLocal',
        ]);
        expect((calls.last.arguments as Map)['signedInfo'], info);
        expect((calls.last.arguments as Map)['certificateBase64'], 'Ag==');
        expect((calls.last.arguments as Map)['expectedNationalId'], id);
        expect(lease.active, isTrue);
      } finally {
        lease.release();
      }
      expect(CpsOperationLease.inUse, isFalse);
    },
  );
  for (final step in [
    'identity',
    'certificates',
    'keyBinding',
    'C_SignInit',
    'C_Sign(size)',
    'C_Sign',
    'verification',
  ]) {
    test('Windows signing error $step stops without retry', () async {
      response = {
        'success': false,
        'platform': 'windows',
        'step': step,
        'returnCode': 0,
        'error': 'Signature locale interrompue.',
      };
      await expectLater(
        service.signDmpLotLocal(pin, id, 'exact', 'Ag=='),
        throwsA(
          isA<PlatformException>().having(
            (e) => e.message,
            'message',
            allOf(
              contains('Signature locale interrompue.'),
              isNot(contains(pin)),
            ),
          ),
        ),
      );
      expect(calls.length, 1);
      expect(CpsOperationLease.inUse, isFalse);
    });
  }
  test('incorrect PIN is not retried by signing', () async {
    response = {'success': false, 'step': 'C_Login', 'returnCode': 0xa0};
    await expectLater(
      service.signDmpLotLocal(pin, id, 'exact', 'Ag=='),
      throwsA(
        isA<PlatformException>().having(
          (e) => e.message,
          'message',
          contains('PIN incorrect'),
        ),
      ),
    );
    expect(calls.length, 1);
  });
  test(
    'diagnostic signature requires verified result and matching profile',
    () async {
      response.addAll({'verified': true, 'tamperedMessageRejected': true});
      await service.testSignature(pin, id);
      expect(calls.single.method, 'testCpsSignature');
      response['verified'] = false;
      await expectLater(service.testSignature(pin, id), throwsFormatException);
      response['verified'] = true;
      response['nationalId'] = 'different';
      await expectLater(service.testSignature(pin, id), throwsFormatException);
    },
  );
  test('invalid input and closed lease never request native signing', () async {
    await expectLater(
      service.signDmpLotLocal('abc', id, 'exact', 'Ag=='),
      throwsFormatException,
    );
    await expectLater(
      service.signDmpLotLocal(pin, '', 'exact', 'Ag=='),
      throwsFormatException,
    );
    final lease = CpsOperationLease.acquire();
    lease.release();
    await expectLater(
      service.signDmpLotLocal(pin, id, 'exact', 'Ag==', lease: lease),
      throwsStateError,
    );
    expect(calls, isEmpty);
  });
}

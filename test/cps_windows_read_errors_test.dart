

import 'package:abak_desktop_companion/features/cps/cps_access_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('abak_dmp_fr');
  const service = CpsAccessService();
  const pin = '13572468'; // Dummy data; no real CPS is accessed by this test.
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  var calls = 0;
  var response = <String, Object?>{};

  setUp(() {
    calls = 0;
    response = {};
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls++;
      expect(call.method, 'readCpsProfile');
      expect((call.arguments as Map)['pin'], pin);
      return response;
    });
  });
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  Future<PlatformException> failure() async {
    try {
      await service.read(pin);
      fail('Reading must fail for this mocked reply');
    } on PlatformException catch (error) {
      expect(calls, 1);
      expect(error.message, isNot(contains(pin)));
      expect(error.details.toString(), isNot(contains(pin)));
      return error;
    }
  }

  test('Windows typed bytes use the existing CPS profile decoder', () async {
    response = {
      'success': true,
      'platform': 'windows',
      'objects': {
        'CPS_NAME_PS': Uint8List.fromList([
          0xe4,
          5,
          0x84,
          3,
          0xc9,
          86,
          65,
          0,
          0,
        ]),
        'CPS_INFO_PS': Uint8List.fromList([
          0xed,
          26,
          0x80,
          1,
          0,
          0x81,
          12,
          ...'800000000001'.codeUnits,
          0x82,
          1,
          70,
          0x84,
          4,
          ...'TEST'.codeUnits,
        ]),
        'CPS_ACTIVITY_01_PS': Uint8List.fromList([
          0xee,
          9,
          0x80,
          1,
          1,
          0x81,
          1,
          2,
          0x83,
          1,
          1,
          0,
          0,
        ]),
      },
    };
    final profile = await service.read(pin);
    expect(profile.givenName, 'ÉVA');
    expect(profile.familyName, 'TEST');
    expect(profile.nationalId, '800000000001');
    expect(profile.professionCode, 70);
    expect(profile.situations.single.number, 1);
    expect(calls, 1);
  });

  test('Windows loader failure displays the Windows code', () async {
    response = {
      'success': false,
      'platform': 'windows',
      'step': 'LoadLibrary',
      'returnCode': 0,
      'windowsError': 126,
    };
    final error = await failure();
    expect(error.code, 'CPS_READ_FAILED');
    expect(error.message, contains('charger la Cryptolib'));
    expect(error.message, contains('Windows : 0x0000007E'));
  });

  test('Windows missing export is reported without another login', () async {
    response = {
      'success': false,
      'step': 'GetProcAddress',
      'returnCode': 0,
      'windowsError': 127,
    };
    expect((await failure()).message, contains('fonctions nécessaires'));
  });

  test('No inserted card is distinct from incorrect PIN', () async {
    response = {
      'success': false,
      'step': 'C_GetSlotList',
      'returnCode': 0,
      'tokenSlotCount': 0,
    };
    expect((await failure()).message, contains('aucune CPS'));
  });

  test('Incorrect PIN is shown after exactly one request', () async {
    response = {'success': false, 'step': 'C_Login', 'returnCode': 0xa0};
    expect((await failure()).message, contains('PIN incorrect'));
  });

  test('Cleanup failure blocks successful reading', () async {
    response = {'success': false, 'step': 'C_Finalize', 'returnCode': 6};
    expect((await failure()).message, contains('fermeture'));
  });

  test('Invalid PIN format does not invoke the native channel', () async {
    await expectLater(service.read('abc'), throwsFormatException);
    expect(calls, 0);
  });
}

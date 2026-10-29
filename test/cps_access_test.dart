import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/cps/cps_profile.dart';
import 'package:abak_desktop_companion/features/cps/cps_access_service.dart';
import 'package:abak_desktop_companion/features/cps/cps_access_screen.dart';

List<int> tlv(int tag, List<int> bytes) => [
  tag,
  if (bytes.length >= 128) 0x81,
  bytes.length,
  ...bytes,
];
List<int> text(int tag, String value) => tlv(tag, latin1.encode(value));
Map<String, List<int>> fixture({bool replacement = false}) => {
  'CPS_NAME_PS': tlv(0xe4, text(0x84, 'Élodie')),
  'CPS_INFO_PS': tlv(0xed, [
    ...tlv(0x80, [0]),
    ...text(0x81, '800000000001'),
    ...tlv(0x82, [70]),
    ...text(0x84, 'TEST'),
  ]),
  'CPS_ACTIVITY_01_PS': tlv(0xee, [
    ...tlv(0x80, [1]),
    ...tlv(0x81, [2]),
    ...tlv(0x83, [1]),
    if (!replacement) ...[
      ...text(0x84, 'Cabinet de test'),
      ...text(0x85, '3000000000'),
      ...text(0x86, 'SA07'),
    ],
  ]),
};

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('abak_dmp_fr');
  const service = CpsAccessService();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test(
    'local lot signing uses a distinct method and preserves canonical bytes',
    () async {
      final calls = <MethodCall>[];
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call);
        return {'success': true};
      });
      await service.signDmpLotLocal(
        '1234',
        '899700870597',
        '<SignedInfo>\n</SignedInfo>',
        'certificate',
      );
      expect(calls.single.method, 'signDmpLotLocal');
      expect(
        calls.single.arguments['signedInfo'],
        '<SignedInfo>\n</SignedInfo>',
      );
      expect(calls.single.arguments['expectedNationalId'], '899700870597');
      await expectLater(
        service.signDmpLotLocal('1234', '', '', ''),
        throwsFormatException,
      );
      expect(calls.length, 1);
    },
  );
  test('decodes Latin-1 identity and actual hexadecimal profession', () {
    final p = CpsProfile.fromObjects(fixture());
    expect(p.givenName, 'Élodie');
    expect(p.professionCode, 70);
    expect(p.situations.single.sector, 'SA07');
  });
  test('replacement does not invent a structure', () {
    final p = CpsProfile.fromObjects(fixture(replacement: true));
    expect(p.situations.single.structureId, isNull);
    expect(p.situations.single.sector, isNull);
  });
  test('preserves several situations and long BER lengths', () {
    final data = fixture();
    data['CPS_ACTIVITY_02_PS'] = tlv(0xee, [
      ...tlv(0x80, [2]),
      ...tlv(0x81, [1]),
      ...tlv(0x83, [2]),
      ...text(0x84, 'Autre cabinet'),
      ...tlv(0x90, List.filled(130, 0)),
    ]);
    expect(CpsProfile.fromObjects(data).situations.map((s) => s.number), [
      1,
      2,
    ]);
  });
  test('rejects truncated, duplicate and wrong objects', () {
    for (final bad in [
      <int>[0xed, 4, 0x80],
      <int>[0xe4, 0],
      tlv(0xed, [
        ...tlv(0x80, [0]),
        ...tlv(0x80, [0]),
      ]),
    ]) {
      expect(
        () => CpsProfile.fromObjects({...fixture(), 'CPS_INFO_PS': bad}),
        throwsFormatException,
      );
    }
    expect(() => CpsProfile.fromObjects({}), throwsFormatException);
  });
  test(
    'diagnostic distinguishes card data failure from a rejected PIN',
    () async {
      messenger.setMockMethodCallHandler(
        channel,
        (_) async => {
          'success': false,
          'step': 'C_GetAttributeValue',
          'returnCode': 0x12,
          'objectLabel': 'CPS_ACTIVITY_01_PS',
        },
      );
      await expectLater(
        service.read('9876'),
        throwsA(
          isA<PlatformException>()
              .having(
                (e) => e.message,
                'authenticated',
                contains('authentification a réussi'),
              )
              .having((e) => e.message, 'native code', contains('0x00000012'))
              .having(
                (e) => e.message,
                'object',
                contains('CPS_ACTIVITY_01_PS'),
              )
              .having((e) => e.message, 'no PIN', isNot(contains('9876'))),
        ),
      );
    },
  );
  test('missing token and library failure have distinct diagnostics', () async {
    for (final item in [
      ({'success': false, 'step': 'dlopen'}, 'charger la Cryptolib'),
      (
        {
          'success': false,
          'step': 'C_GetSlotList',
          'returnCode': 0,
          'tokenSlotCount': 0,
        },
        'aucune CPS',
      ),
      (
        {'success': false, 'step': 'C_Login', 'loginReturnCode': 0x100},
        'déjà active',
      ),
    ]) {
      messenger.setMockMethodCallHandler(channel, (_) async => item.$1);
      await expectLater(
        service.read('9876'),
        throwsA(
          isA<PlatformException>().having(
            (e) => e.message,
            'specific cause',
            contains(item.$2),
          ),
        ),
      );
    }
  });
  test('library loading exposes macOS reason before any PIN attempt', () async {
    messenger.setMockMethodCallHandler(
      channel,
      (_) async => {
        'success': false,
        'step': 'dlopen',
        'error': 'mapping process and mapped file have different Team IDs',
      },
    );
    await expectLater(
      service.read('9876'),
      throwsA(
        isA<PlatformException>()
            .having(
              (e) => e.message,
              'loader reason',
              contains('different Team IDs'),
            )
            .having((e) => e.message, 'no PIN', isNot(contains('9876'))),
      ),
    );
  });
  test('accepts zero padding only after a complete outer card object', () {
    final data = fixture();
    for (final label in ['CPS_NAME_PS', 'CPS_INFO_PS', 'CPS_ACTIVITY_01_PS']) {
      data[label] = [...data[label]!, ...List.filled(139, 0)];
    }
    final p = CpsProfile.fromObjects(data);
    expect(p.givenName, 'Élodie');
    expect(p.cardType, 0); // A legitimate zero-valued field is preserved.
    expect(p.situations.single.sector, 'SA07');
  });
  test('padding does not hide a malformed object or duplicate fields', () {
    final base = fixture();
    final badObjects = <List<int>>[
      [...base['CPS_NAME_PS']!, 0, 0, 1],
      [...base['CPS_NAME_PS']!, ...base['CPS_NAME_PS']!],
      [0xe4, 10, 0x84, 3, 65],
      tlv(0xe4, [...text(0x84, 'Alice'), ...text(0x84, 'Alice')]),
    ];
    for (final bytes in badObjects) {
      expect(
        () => CpsProfile.fromObjects({...base, 'CPS_NAME_PS': bytes}),
        throwsA(
          isA<FormatException>().having(
            (e) => e.message,
            'object context',
            contains('CPS_NAME_PS'),
          ),
        ),
      );
    }
  });
  test(
    'signature uses one dedicated call and binds result to the selected identity',
    () async {
      var calls = 0;
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls++;
        expect(call.method, 'testCpsSignature');
        expect(call.arguments['expectedNationalId'], '800000000001');
        return {
          'success': true,
          'objects': fixture(),
          'nationalId': '800000000001',
          'verified': true,
          'tamperedMessageRejected': true,
          'certificates': [
            {'role': 'signature'},
            {'role': 'authentification'},
          ],
        };
      });
      final result = await service.testSignature('9876', '800000000001');
      expect(result['verified'], true);
      expect(calls, 1);
    },
  );
  test(
    'signature rejects incomplete verification or changed identity',
    () async {
      for (final change in [
        {'nationalId': '800000000002'},
        {'verified': false},
        {'tamperedMessageRejected': false},
        {'certificates': []},
      ]) {
        messenger.setMockMethodCallHandler(
          channel,
          (_) async => {
            'success': true,
            'objects': fixture(),
            'nationalId': '800000000001',
            'verified': true,
            'tamperedMessageRejected': true,
            'certificates': [
              {'role': 'signature'},
              {'role': 'authentification'},
            ],
            ...change,
          },
        );
        await expectLater(
          service.testSignature('9876', '800000000001'),
          throwsFormatException,
        );
      }
    },
  );
  test('failed PIN during signature is not retried', () async {
    var calls = 0;
    messenger.setMockMethodCallHandler(channel, (_) async {
      calls++;
      return {'success': false, 'step': 'C_Login', 'loginReturnCode': 0xa0};
    });
    await expectLater(
      service.testSignature('9876', '800000000001'),
      throwsA(isA<PlatformException>()),
    );
    expect(calls, 1);
  });
  testWidgets('cancelling the signature prompt performs no card operation', (
    tester,
  ) async {
    var calls = 0;
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls++;
      expect(call.method, 'readCpsProfile');
      return {'success': true, 'objects': fixture()};
    });
    await tester.pumpWidget(const MaterialApp(home: CpsAccessScreen()));
    await tester.enterText(find.byType(TextField), '9876');
    await tester.tap(find.text('Lire la CPS'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Certificats et test de signature'));
    await tester.tap(find.text('Certificats et test de signature'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(calls, 1);
  });
  test('invalid PIN never invokes the card', () async {
    var calls = 0;
    messenger.setMockMethodCallHandler(channel, (_) async {
      calls++;
      return null;
    });
    await expectLater(service.read(''), throwsFormatException);
    await expectLater(service.read('abcd'), throwsFormatException);
    expect(calls, 0);
  });
  test('incorrect or blocked PIN is attempted exactly once', () async {
    for (final code in [0xa0, 0xa4]) {
      var calls = 0;
      messenger.setMockMethodCallHandler(channel, (_) async {
        calls++;
        return {'success': false, 'loginReturnCode': code};
      });
      await expectLater(
        service.read('0000'),
        throwsA(isA<PlatformException>()),
      );
      expect(calls, 1);
    }
  });
  testWidgets(
    'read requires user action, clears PIN and old identity on failure',
    (tester) async {
      var calls = 0;
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls++;
        expect(call.method, 'readCpsProfile');
        if (calls > 1) return {'success': false, 'loginReturnCode': 0xa0};
        return {
          'success': true,
          'objects': fixture().map(
            (k, v) => MapEntry(k, Uint8List.fromList(v)),
          ),
        };
      });
      await tester.pumpWidget(const MaterialApp(home: CpsAccessScreen()));
      expect(calls, 0);
      await tester.enterText(find.byType(TextField), '0000');
      await tester.tap(find.text('Lire la CPS'));
      await tester.pumpAndSettle();
      expect(find.text('Élodie TEST'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        isEmpty,
      );
      await tester.enterText(find.byType(TextField), '0001');
      await tester.tap(find.text('Lire la CPS'));
      await tester.pumpAndSettle();
      expect(find.text('Élodie TEST'), findsNothing);
      expect(find.textContaining('PIN incorrect'), findsOneWidget);
      expect(calls, 2);
    },
  );
}

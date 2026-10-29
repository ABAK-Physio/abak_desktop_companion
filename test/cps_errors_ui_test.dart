import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/cps/cps_access_screen.dart';
import 'cps_access_test.dart' as data;

// All native CPS calls terminate in this mock. No card or network is used.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('abak_dmp_fr');
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  Future<void> mount(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1200, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(home: CpsAccessScreen()));
  }

  Future<void> read(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField), '9876');
    await tester.tap(find.text('Lire la CPS'));
    await tester.pumpAndSettle();
  }

  void blocked(WidgetTester tester) {
    expect(find.text('Élodie TEST'), findsNothing);
    expect(find.byType(DropdownButtonFormField<int>), findsNothing);
    expect(find.text('Certificats et test de signature'), findsNothing);
    expect(find.text('Préparer le CDA et le lot TD2.1 — local'), findsNothing);
    expect(
      tester.widget<TextField>(find.byType(TextField)).controller!.text,
      isEmpty,
    );
    expect(find.textContaining('9876'), findsNothing);
  }

  final cases = <(String, Map<String, dynamic>, String)>[
    (
      'PIN incorrect',
      {'success': false, 'loginReturnCode': 0xa0},
      'PIN incorrect',
    ),
    ('PIN bloqué', {'success': false, 'loginReturnCode': 0xa4}, 'PIN bloqué'),
    ('PIN expiré', {'success': false, 'loginReturnCode': 0xa3}, 'PIN expiré'),
    (
      'aucune carte',
      {'success': false, 'step': 'C_GetSlotList', 'tokenSlotCount': 0},
      'aucune CPS',
    ),
    (
      'carte retirée',
      {'success': false, 'returnCode': 0xe0},
      'ne détecte plus la CPS',
    ),
    (
      'lecteur interrompu',
      {'success': false, 'returnCode': 0x30},
      'communication avec la carte',
    ),
    (
      'Cryptolib absente',
      {'success': false, 'step': 'dlopen'},
      'charger la Cryptolib',
    ),
    (
      'session occupée',
      {'success': false, 'loginReturnCode': 0x100},
      'déjà active',
    ),
    (
      'lecture après authentification',
      {'success': false, 'step': 'C_GetAttributeValue', 'returnCode': 0x12},
      'authentification a réussi',
    ),
    (
      'objet tronqué',
      {
        'success': true,
        'objects': {
          ...data.fixture(),
          'CPS_INFO_PS': [0xed, 4, 0x80],
        },
      },
      'CPS_INFO_PS',
    ),
    ('réponse invalide', {'success': true}, 'Réponse CPS invalide'),
  ];
  for (final scenario in cases) {
    testWidgets(
      '${scenario.$1}: message, contexte effacé, signature inaccessible, aucun réessai',
      (tester) async {
        var calls = 0;
        messenger.setMockMethodCallHandler(channel, (call) async {
          expect(call.method, 'readCpsProfile');
          calls++;
          return calls == 1
              ? {'success': true, 'objects': data.fixture()}
              : scenario.$2;
        });
        await mount(tester);
        expect(calls, 0);
        await read(tester);
        expect(find.text('Élodie TEST'), findsOneWidget);
        await read(tester);
        expect(find.textContaining(scenario.$3), findsOneWidget);
        blocked(tester);
        await tester.pump(const Duration(seconds: 5));
        expect(calls, 2); // One success, then exactly one simulated failure.
      },
    );
  }

  testWidgets('PIN vide: message de saisie et aucun appel au service', (
    tester,
  ) async {
    var calls = 0;
    messenger.setMockMethodCallHandler(channel, (_) async {
      calls++;
      return null;
    });
    await mount(tester);
    await tester.tap(find.text('Lire la CPS'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Saisissez le PIN'), findsOneWidget);
    blocked(tester);
    expect(calls, 0);
  });

  testWidgets(
    'lecture en cours: PIN effacé et double clic sans deuxième appel',
    (tester) async {
      var calls = 0;
      final pending = Completer<Map<String, dynamic>>();
      messenger.setMockMethodCallHandler(channel, (call) async {
        expect(call.method, 'readCpsProfile');
        calls++;
        return pending.future;
      });
      await mount(tester);
      await tester.enterText(find.byType(TextField), '9876');
      await tester.tap(find.text('Lire la CPS'));
      await tester.pump();
      expect(
        tester.widget<FilledButton>(find.byType(FilledButton)).onPressed,
        isNull,
      );
      expect(tester.widget<TextField>(find.byType(TextField)).enabled, false);
      blocked(tester);
      await tester.tap(find.byType(FilledButton));
      await tester.pump();
      expect(calls, 1);
      pending.complete({'success': false, 'loginReturnCode': 0xa0});
      await tester.pumpAndSettle();
      expect(calls, 1);
    },
  );

  for (final failure in [
    {
      'success': false,
      'step': 'identity',
      'error': 'La carte présente ne correspond pas au professionnel attendu.',
    },
    {
      'success': false,
      'step': 'C_Sign',
      'error': 'Signature impossible pour ce test simulé.',
    },
    {'success': false, 'loginReturnCode': 0xa4},
  ]) {
    testWidgets(
      'échec signature $failure: ancienne identité et accès CDA supprimés',
      (tester) async {
        final calls = <String>[];
        messenger.setMockMethodCallHandler(channel, (call) async {
          calls.add(call.method);
          if (call.method == 'readCpsProfile') {
            return {'success': true, 'objects': data.fixture()};
          }
          expect(call.method, 'testCpsSignature');
          expect(call.arguments['expectedNationalId'], '800000000001');
          return failure;
        });
        await mount(tester);
        await read(tester);
        await tester.tap(find.text('Certificats et test de signature'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(TextField),
          ),
          '9876',
        );
        await tester.tap(find.text('Signer le test'));
        await tester.pumpAndSettle();
        expect(
          find.textContaining(failure['error'] as String? ?? 'PIN bloqué'),
          findsOneWidget,
        );
        blocked(tester);
        await tester.pump(const Duration(seconds: 5));
        expect(calls, ['readCpsProfile', 'testCpsSignature']);
      },
    );
  }
}

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abak_desktop_companion/features/patients/screens/patient_insi_verification_dialog.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_verification_response_parser.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_insi_retrieval_service.dart';

void main() {
  const soap = 'http://www.w3.org/2003/05/soap-envelope';
  Map<String, String> sample() => {
    'number': '1900463220899', 'key': '81', 'oid': '1.2.250.1.213.1.4.8',
    'name': "D'ARTAGNAN DE L'HERAULT", 'names': 'PIERRE-ALAIN BRUCE GORDON',
    'sex': 'M', 'date': '1990-04-14', 'place': '63220',
  };

  InsiVerificationResponse response(String code, {bool fault = false}) {
    final body = fault
      ? '<s:Fault><s:Code><s:Value>s:Receiver</s:Value></s:Code>'
        '<s:Reason><s:Text xml:lang="fr">Indisponible</s:Text></s:Reason></s:Fault>'
      : '<r:ResultatUnitaire xmlns:r="http://www.cnamts.fr/INSiLot2/REPUnitaire" '
        'xmlns:c="http://www.cnamts.fr/MRA/CommunLot"><r:CrUnitaire><c:CR>'
        '<c:Code>$code</c:Code><c:Libelle>Compte rendu</c:Libelle>'
        '</c:CR></r:CrUnitaire></r:ResultatUnitaire>';
    final xml = '<s:Envelope xmlns:s="$soap"><s:Body>$body</s:Body></s:Envelope>';
    return InsiVerificationResponse(
      id: 'test-exchange', xml: xml, requestHash: 'test-hash',
      professional: '899700870597', receivedAt: DateTime.utc(2026, 11, 21),
      result: const PatientFrInsiVerificationResponseParser().parseXml(xml),
    );
  }

  Future<void> open(WidgetTester tester, {
    Map<String, String>? initial,
    required Future<InsiVerificationResponse> Function(Map<String, String>, String) verify,
  }) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: Builder(
      builder: (context) => TextButton(
        onPressed: () => showDialog<void>(context: context, barrierDismissible: false,
          builder: (_) => PatientInsiVerificationDialog(initial: initial ?? sample(), onVerify: verify)),
        child: const Text('Ouvrir'),
      ),
    ))));
    await tester.tap(find.text('Ouvrir'));
    await tester.pumpAndSettle();
  }

  Future<void> enterPin(WidgetTester tester) => tester.enterText(
    find.byKey(const ValueKey('verify-pin')), '1234');

  testWidgets('opening, editing and cancelling never invoke verification', (tester) async {
    var calls = 0;
    await open(tester, verify: (_, _) async { calls++; return response('00'); });
    await tester.enterText(find.byKey(const ValueKey('verify-name')), 'AUTRE NOM');
    await enterPin(tester);
    expect(calls, 0);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(find.byType(PatientInsiVerificationDialog), findsNothing);
    expect(calls, 0);
  });

  testWidgets('missing INS data prevents the callback even with a PIN', (tester) async {
    var calls = 0;
    await open(tester, initial: sample()..['key'] = '',
      verify: (_, _) async { calls++; return response('00'); });
    await enterPin(tester);
    await tester.tap(find.text('Vérifier l’INS'));
    await tester.pumpAndSettle();
    expect(find.text('La clé INS doit comporter deux chiffres.'), findsOneWidget);
    expect(calls, 0);
  });

  testWidgets('a PIN is required before any callback', (tester) async {
    var calls = 0;
    await open(tester, verify: (_, _) async { calls++; return response('00'); });
    await tester.tap(find.text('Vérifier l’INS'));
    await tester.pumpAndSettle();
    expect(find.text('Saisissez le PIN de la CPS de test.'), findsOneWidget);
    expect(calls, 0);
  });

  testWidgets('an explicit action sends the reviewed values once and shows 00', (tester) async {
    var calls = 0;
    await open(tester, verify: (values, pin) async {
      calls++;
      expect(values, sample());
      expect(pin, '1234');
      return response('00');
    });
    await enterPin(tester);
    await tester.tap(find.text('Vérifier l’INS'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(find.text('INS vérifiée avec succès — code 00'), findsOneWidget);
    expect(find.textContaining('Aucune qualification effectuée'), findsOneWidget);
    expect(find.text('Vérifier l’INS'), findsNothing);
    expect(find.byKey(const ValueKey('verify-pin')), findsNothing);
    expect(find.text('Fermer'), findsOneWidget);
  });

  testWidgets('01 is displayed as unsuccessful verification', (tester) async {
    await open(tester, verify: (_, _) async => response('01'));
    await enterPin(tester);
    await tester.tap(find.text('Vérifier l’INS'));
    await tester.pumpAndSettle();
    expect(find.text('Vérification sans succès — code 01'), findsOneWidget);
    expect(find.textContaining('succès — code 00'), findsNothing);
  });

  testWidgets('an ongoing call blocks duplicate calls, cancellation and back navigation', (tester) async {
    var calls = 0;
    final pending = Completer<InsiVerificationResponse>();
    await open(tester, verify: (_, _) { calls++; return pending.future; });
    await enterPin(tester);
    await tester.tap(find.text('Vérifier l’INS'));
    await tester.pump();
    expect(tester.widget<FilledButton>(find.widgetWithText(FilledButton, 'Vérifier l’INS')).onPressed, isNull);
    expect(tester.widget<TextButton>(find.widgetWithText(TextButton, 'Annuler')).onPressed, isNull);
    expect(tester.widget<TextField>(find.byKey(const ValueKey('verify-pin'))).controller!.text, isEmpty);
    await tester.binding.handlePopRoute();
    await tester.pump();
    expect(find.byType(PatientInsiVerificationDialog), findsOneWidget);
    expect(calls, 1);
    pending.complete(response('00'));
    await tester.pumpAndSettle();
    expect(find.text('Fermer'), findsOneWidget);
  });

  testWidgets('technical failures keep inputs, clear the PIN and never retry automatically', (tester) async {
    var calls = 0;
    await open(tester, verify: (_, _) async {
      calls++;
      throw StateError('Service indisponible');
    });
    await enterPin(tester);
    await tester.tap(find.text('Vérifier l’INS'));
    await tester.pumpAndSettle();
    expect(find.text('Service indisponible'), findsOneWidget);
    expect(tester.widget<TextField>(find.byKey(const ValueKey('verify-number'))).controller!.text,
      sample()['number']);
    expect(tester.widget<TextField>(find.byKey(const ValueKey('verify-pin'))).controller!.text, isEmpty);
    await tester.tap(find.text('Vérifier l’INS'));
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(find.text('Vérification sans succès — code 01'), findsNothing);
  });

  testWidgets('even a returned SOAP fault cannot be displayed as code 01', (tester) async {
    await open(tester, verify: (_, _) async => response('', fault: true));
    await enterPin(tester);
    await tester.tap(find.text('Vérifier l’INS'));
    await tester.pumpAndSettle();
    expect(find.text('Erreur technique INSi : aucune vérification concluante.'), findsOneWidget);
    expect(find.text('Vérification sans succès — code 01'), findsNothing);
  });
}

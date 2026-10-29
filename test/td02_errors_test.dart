import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_td02/td02_result.dart';
import 'package:abak_desktop_companion/features/dmp_td02/td02_screen.dart';

void main() {
  test(
    'SOAP Fault recognized on HTTP 200 and 500 without requiring success headers',
    () {
      for (final status in [200, 500]) {
        final r = Td02Reader.read(
          request: File('assets/dmp_local/td02/request.xml').readAsStringSync(),
          response: File(
            'assets/dmp_local/td02/SYNTHETIQUE-soap-fault.xml',
          ).readAsStringSync(),
          httpStatus: status,
          context: const Td02Context(
            ins: '187012425258307',
            oid: '1.2.250.1.213.1.4.10',
            professional: '899700854237',
          ),
        );
        expect(r.state, DmpState.unknown);
        expect(r.detail, contains('Erreur SOAP'));
        expect(r.message, isNot(contains('Aucun DMP trouvé')));
        expect(r.canSendNetworkRequest, false);
      }
    },
  );
  for (final scenario in [
    'Erreur SOAP',
    'Réponse destinée à une autre requête',
    'Service DMP indisponible',
    'Erreur applicative DMP',
    'Réponse illisible',
    'Réponse pour un autre patient',
  ]) {
    testWidgets(
      'Active -> $scenario suspends every action and clears old result',
      (tester) async {
        rootBundle.clear();
        tester.view.physicalSize = const Size(1200, 2400);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        await tester.pumpWidget(const MaterialApp(home: Td02Screen()));
        Future<void> choose(String label) async {
          await tester.tap(find.byType(DropdownButtonFormField<String>));
          await tester.pumpAndSettle();
          await tester.tap(find.text(label).last);
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 50)),
          );
          await tester.pumpAndSettle();
        }

        await choose('Consultation autorisée');
        tester
            .widget<SwitchListTile>(
              find.widgetWithText(
                SwitchListTile,
                'Consentement à la consultation',
              ),
            )
            .onChanged!(true);
        await tester.pump();
        expect(
          tester
              .widget<OutlinedButton>(
                find.byKey(const ValueKey(DmpAction.consult)),
              )
              .onPressed,
          isNotNull,
        );
        await tester.tap(find.byKey(const ValueKey(DmpAction.deposit)));
        await tester.pump();
        expect(find.textContaining('Simulation terminée'), findsOneWidget);
        await choose(scenario);
        expect(
          find.text('Vérification du DMP impossible. Aucun envoi effectué.'),
          findsOneWidget,
        );
        expect(find.textContaining('Simulation terminée'), findsNothing);
        expect(find.textContaining('Aucun DMP trouvé'), findsNothing);
        for (final action in DmpAction.values) {
          expect(
            tester
                .widget<OutlinedButton>(find.byKey(ValueKey(action)))
                .onPressed,
            isNull,
          );
        }
        if (scenario == 'Erreur SOAP') {
          expect(find.textContaining('Erreur SOAP :'), findsOneWidget);
        }
        if (scenario == 'Réponse destinée à une autre requête') {
          expect(find.textContaining('résultat ignoré'), findsOneWidget);
        }
        await tester.tap(
          find.widgetWithText(SwitchListTile, 'Opposition aux nouveaux dépôts'),
        );
        await tester.pump();
        for (final action in DmpAction.values) {
          expect(
            tester
                .widget<OutlinedButton>(find.byKey(ValueKey(action)))
                .onPressed,
            isNull,
          );
        }
      },
    );
  }
}

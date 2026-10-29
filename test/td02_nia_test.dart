import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_td02/td02_result.dart';
import 'package:abak_desktop_companion/features/dmp_td02/td02_screen.dart';

void main() {
  test('Official NIA fixture refused before parsing without a response', () {
    final r = Td02Reader.read(
      request: '',
      response: '',
      context: const Td02Context(
        ins: '109076322088835',
        oid: '1.2.250.1.213.1.4.9',
        professional: '899700870597',
      ),
    );
    expect(r.state, DmpState.nia);
    expect(r.canSendNetworkRequest, false);
    for (final action in DmpAction.values) {
      expect(
        r.allows(
          action,
          opposition: false,
          functionalRights: true,
          authorRights: true,
          consultationConsent: true,
        ),
        false,
      );
    }
  });
  testWidgets(
    'Switching active to official NIA clears permission for all actions',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: Td02Screen()));
      Future<void> choose(String name) async {
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text(name).last);
        await tester.pumpAndSettle();
      }

      await choose('Consultation autorisée');
      expect(
        tester
            .widget<OutlinedButton>(
              find.byKey(const ValueKey(DmpAction.deposit)),
            )
            .onPressed,
        isNotNull,
      );
      await tester.tap(find.byKey(const ValueKey(DmpAction.deposit)));
      await tester.pump();
      expect(find.textContaining('Simulation terminée'), findsOneWidget);
      await choose('Identifiant NIA');
      expect(find.textContaining('MATRICULE PROVISOIRE'), findsOneWidget);
      expect(
        find.textContaining('Accès DMP indisponible : identité NIA'),
        findsOneWidget,
      );
      expect(find.textContaining('Simulation terminée'), findsNothing);
      for (final action in DmpAction.values) {
        expect(
          tester.widget<OutlinedButton>(find.byKey(ValueKey(action))).onPressed,
          isNull,
        );
      }
      await tester.tap(
        find.widgetWithText(SwitchListTile, 'Consentement à la consultation'),
      );
      await tester.pump();
      expect(
        tester
            .widget<OutlinedButton>(
              find.byKey(const ValueKey(DmpAction.consult)),
            )
            .onPressed,
        isNull,
      );
    },
  );
}

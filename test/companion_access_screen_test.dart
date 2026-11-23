import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_access_screen.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_access_service.dart';
import 'support/companion_access_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory temp;
  late Database db;
  late CompanionAccessService service;
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('companion_access_ui_');
    db = await openAccessTestDatabase('${temp.path}/synthetic.db');
    service = CompanionAccessService(
      database: () async => db,
      hasher: FastTestCodeHasher(),
    );
  });
  tearDown(() async {
    await db.close();
    await temp.delete(recursive: true);
  });

  Future<void> waitFor(WidgetTester tester, bool Function() ready) async {
    for (var i = 0; i < 100; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      // Let SQLite make progress in real time while the loading indicator is
      // animating; pumpAndSettle cannot finish during that animation.
      await tester.pump(const Duration(milliseconds: 50));
      if (ready()) {
        await tester.pumpAndSettle();
        return;
      }
    }
    fail('The access screen did not finish the operation.');
  }

  Future<void> show(WidgetTester tester, String id) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: CompanionAccessScreen(practitionerId: id, service: service),
      ),
    );
    await waitFor(
      tester,
      () => find.byType(CheckboxListTile).evaluate().isNotEmpty,
    );
  }

  testWidgets('first administrator confirms a four-digit code before saving', (
    tester,
  ) async {
    await show(tester, 'a');
    await tester.tap(find.byType(CheckboxListTile));
    await tester.pumpAndSettle();
    expect(find.text('Mot de passe initial'), findsOneWidget);
    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'admin');
    await tester.enterText(fields.at(1), '0123');
    await tester.enterText(fields.at(2), '4321');
    await tester.tap(find.text('Valider'));
    await tester.pumpAndSettle();
    expect(
      find.text('Les deux nouveaux codes sont différents.'),
      findsOneWidget,
    );
    expect(await tester.runAsync(service.hasAdministrators), isFalse);
    await tester.enterText(fields.at(2), '0123');
    await tester.tap(find.text('Valider'));
    await waitFor(
      tester,
      () => find.text('Modification enregistrée.').evaluate().isNotEmpty,
    );
    expect(find.byType(AlertDialog), findsNothing);
    expect(
      tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
      isTrue,
    );
    await tester.runAsync(() => service.verifyCode('a', '0123'));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'wrong administrator code is refused, correct code grants rights, cancel preserves them',
    (tester) async {
      await tester.runAsync(() async {
        await service.initializeAdministrator('a', 'admin', '0123');
        await service.createCode('b', '1234');
      });
      await show(tester, 'b');
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '9999');
      await tester.tap(find.text('Valider'));
      await waitFor(
        tester,
        () => find.text('Code incorrect.').evaluate().isNotEmpty,
      );
      expect(
        tester.widget<CheckboxListTile>(find.byType(CheckboxListTile)).value,
        isFalse,
      );
      await tester.enterText(find.byType(TextFormField), '0123');
      await tester.tap(find.text('Valider'));
      await waitFor(tester, () => find.byType(AlertDialog).evaluate().isEmpty);
      await waitFor(
        tester,
        () =>
            tester
                .widget<CheckboxListTile>(find.byType(CheckboxListTile))
                .value ==
            true,
      );
      await tester.tap(find.byType(CheckboxListTile));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      final people = await tester.runAsync(service.practitioners);
      expect(people!.singleWhere((p) => p.id == 'b').isAdministrator, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'administrator reset offers code creation again without exposing the old code',
    (tester) async {
      await tester.runAsync(() async {
        await service.initializeAdministrator('a', 'admin', '0123');
        await service.createCode('b', '1234');
      });
      await show(tester, 'b');
      await tester.tap(find.text('Code oublié'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '0123');
      await tester.tap(find.text('Valider'));
      await waitFor(
        tester,
        () => find.text('Créer mon code').evaluate().isNotEmpty,
      );
      expect(find.text('Changer mon code'), findsNothing);
      expect(find.text('1234'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

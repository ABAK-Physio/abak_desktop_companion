import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_access_service.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_session.dart';
import 'package:abak_desktop_companion/features/companion_access/recovery_key_screen.dart';
import 'package:abak_desktop_companion/features/dmp_session/dmp_work_context.dart';
import 'package:abak_desktop_companion/features/dmp_session/practitioner_session_banner.dart';
import 'package:abak_desktop_companion/features/practitioners/models/practitioner.dart';
import 'support/companion_access_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory temp;
  late Database db;
  late CompanionAccessService auth;
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('recovery_ui_');
    db = await openAccessTestDatabase('${temp.path}/test.db');
    auth = CompanionAccessService(
      database: () async => db,
      hasher: FastTestCodeHasher(),
    );
    await auth.initializeAdministrator('a', 'admin', '0123');
    await auth.createCode('b', '1234');
  });
  tearDown(() async {
    await db.close();
    await temp.delete(recursive: true);
  });
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 15; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  void large(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets(
    'generation requires code and warning acknowledgement; key appears once',
    (tester) async {
      large(tester);
      var closed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecoveryKeyPanel(
              generate: true,
              service: auth,
              onClose: () => closed = true,
            ),
          ),
        ),
      );
      await settle(tester);
      final generate = find.widgetWithText(
        FilledButton,
        'Générer la clé de récupération',
      );
      expect(tester.widget<FilledButton>(generate).onPressed, isNull);
      await tester.tap(
        find.text('Je conserverai la clé dans un endroit protégé.'),
      );
      await tester.pump();
      await tester.enterText(find.byType(TextField), '9999');
      await tester.tap(generate);
      await settle(tester);
      expect(find.text('Code incorrect.'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '0123');
      await tester.tap(generate);
      await settle(tester);
      final key = tester
          .widget<SelectableText>(find.byType(SelectableText))
          .data!;
      expect(key, startsWith('ABAK-'));
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Fermer'))
            .onPressed,
        isNull,
      );
      await tester.tap(
        find.text('J’ai conservé cette clé dans un endroit sûr.'),
      );
      await tester.pump();
      await tester.tap(find.text('Fermer'));
      expect(closed, isTrue);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecoveryKeyPanel(
              generate: true,
              service: auth,
              onClose: () {},
            ),
          ),
        ),
      );
      await settle(tester);
      expect(find.text(key), findsNothing);
      expect(find.textContaining('invalidera immédiatement'), findsOneWidget);
    },
  );
  testWidgets(
    'key recovery lets a successor create an administrator with a confirmed code',
    (tester) async {
      large(tester);
      final key = await tester.runAsync(
        () => auth.generateRecoveryKey(actorId: 'a', actorCode: '0123'),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RecoveryKeyPanel(service: auth, onClose: () {}),
          ),
        ),
      );
      await settle(tester);
      await tester.enterText(
        find.widgetWithText(TextField, 'Clé de récupération'),
        key!,
      );
      await tester.tap(
        find.text('Créer la fiche d’un nouveau kiné administrateur'),
      );
      await tester.pump();
      await tester.enterText(
        find.widgetWithText(TextField, 'Nom du nouveau kiné'),
        'Successeur',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Nouveau code Companion'),
        '0007',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Confirmer le nouveau code'),
        '9999',
      );
      await tester.tap(find.text('Rétablir l’accès administrateur'));
      await tester.pump();
      expect(find.textContaining('confirmez le nouveau code'), findsOneWidget);
      await tester.enterText(
        find.widgetWithText(TextField, 'Confirmer le nouveau code'),
        '0007',
      );
      await tester.tap(find.text('Rétablir l’accès administrateur'));
      await settle(tester);
      expect(
        find.textContaining('L’accès administrateur est rétabli.'),
        findsOneWidget,
      );
      final people = (await tester.runAsync(() => auth.practitioners()))!;
      final person = people.singleWhere((p) => p.name == 'Successeur');
      expect(person.isAdministrator, isTrue);
      await tester.runAsync(() => auth.verifyCode(person.id, '0007'));
    },
  );
  testWidgets(
    'recovery is reachable while locked and cancelling preserves the lock',
    (tester) async {
      large(tester);
      final session = CompanionSession(
        access: auth,
        dmpContext: DmpWorkContext(),
        loadNationalId: (_) async => null,
        cpsBusy: () => false,
      )..setEnabled(true);
      final people = (await tester.runAsync(
        () => db.query('practitioners'),
      ))!.map(Practitioner.fromMap).toList();
      await tester.pumpWidget(
        MaterialApp(
          builder: (_, child) => PractitionerSessionBanner(
            session: session,
            loadEnabled: () async => true,
            loadIdleMinutes: () async => 15,
            loadPractitioners: () async => people,
            child: child!,
          ),
          home: const Scaffold(body: Text('Accueil')),
        ),
      );
      await settle(tester);
      await tester.runAsync(() => session.signIn('a', '0123'));
      session.lock();
      await settle(tester);
      await tester.tap(find.text('Clé de récupération'));
      await settle(tester);
      expect(find.text('Récupérer un accès administrateur'), findsOneWidget);
      expect(find.text('Companion verrouillé'), findsNothing);
      await tester.tap(find.text('Annuler'));
      await settle(tester);
      expect(session.locked, isTrue);
      expect(find.text('Companion verrouillé'), findsOneWidget);
      final key = await tester.runAsync(
        () => auth.generateRecoveryKey(actorId: 'a', actorCode: '0123'),
      );
      await tester.tap(find.text('Clé de récupération'));
      await settle(tester);
      await tester.tap(find.text('Kiné A'));
      await tester.pump();
      await tester.enterText(
        find.widgetWithText(TextField, 'Clé de récupération'),
        key!,
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Nouveau code Companion'),
        '0007',
      );
      await tester.enterText(
        find.widgetWithText(TextField, 'Confirmer le nouveau code'),
        '0007',
      );
      await tester.tap(find.text('Rétablir l’accès administrateur'));
      await settle(tester);
      expect(session.authenticated, isFalse);
      expect(session.locked, isFalse);
      expect(
        find.textContaining('L’accès administrateur est rétabli.'),
        findsOneWidget,
      );
      await tester.runAsync(() => auth.verifyCode('a', '0007'));
      await tester.pumpWidget(const SizedBox());
      session.dispose();
    },
  );
}

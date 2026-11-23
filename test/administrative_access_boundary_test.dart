import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/features/companion_access/administrative_access_service.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_access_service.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_session.dart';
import 'package:abak_desktop_companion/features/companion_access/patient_access_boundary.dart';
import 'package:abak_desktop_companion/features/companion_access/patient_access_service.dart';
import 'package:abak_desktop_companion/features/dmp_session/dmp_work_context.dart';
import 'support/companion_access_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory temp;
  late Database db;
  late CompanionAccessService auth;
  late CompanionSession session;
  late AdministrativeAccessService admin;
  late PatientAccessService patients;
  var constructed = 0;
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('admin_gate_ui_');
    db = await openAccessTestDatabase('${temp.path}/test.db');
    auth = CompanionAccessService(
      database: () async => db,
      hasher: FastTestCodeHasher(),
    );
    await auth.createCode('a', '0123');
    await auth.createCode('b', '1234');
    await auth.initializeAdministrator('a', 'admin', '0123');
    session = CompanionSession(
      access: auth,
      dmpContext: DmpWorkContext(),
      loadNationalId: (_) async => null,
      cpsBusy: () => false,
    )..setEnabled(true);
    admin = AdministrativeAccessService(
      database: () async => db,
      session: session,
    );
    patients = PatientAccessService(database: () async => db, session: session);
    await db.insert('patients', {
      'patient_id': 'p',
      'last_name': 'Test',
      'first_name': 'Patient',
      'created_at': 1,
    });
    await db.insert('companion_patient_access', {
      'patient_id': 'p',
      'referring_practitioner_id': 'b',
    });
    constructed = 0;
  });
  tearDown(() async {
    admin.dispose();
    patients.dispose();
    session.dispose();
    await db.close();
    await temp.delete(recursive: true);
  });
  Future<void> settle(WidgetTester tester) async {
    for (var i = 0; i < 20; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 10)),
      );
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  Future<void> mount(WidgetTester tester) async {
    var selected = 0;
    await tester.pumpWidget(
      MaterialApp(
        builder: (_, child) => PatientAccessBoundary(
          service: patients,
          administrativeService: admin,
          child: child!,
        ),
        home: StatefulBuilder(
          builder: (context, update) => Scaffold(
            body: Column(
              children: [
                for (var i = 0; i < 3; i++)
                  TextButton(
                    onPressed: () => update(() => selected = i),
                    child: Text(
                      ['Accueil', 'Ouvrir paramètres', 'Ouvrir assistance'][i],
                    ),
                  ),
                Expanded(
                  child: selected == 0
                      ? const Text('Accueil disponible')
                      : PatientAccessScope.administrative(
                          key: ValueKey(selected),
                          section: selected == 1 ? 'Paramètres' : 'Assistance',
                          onCancel: () => update(() => selected = 0),
                          builder: (context) {
                            constructed++;
                            return Column(
                              children: [
                                Text(
                                  selected == 1
                                      ? 'Réglages protégés'
                                      : 'Assistance protégée',
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (context) => Scaffold(
                                        appBar: AppBar(
                                          title: const Text('Outil assistance'),
                                        ),
                                        body: const Text('Contenu outil'),
                                      ),
                                    ),
                                  ),
                                  child: const Text('Ouvrir outil'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => PatientAccessScope(
                                        patientId: 'p',
                                        builder: (_) => const Scaffold(
                                          body: Text('Dossier patient'),
                                        ),
                                      ),
                                    ),
                                  ),
                                  child: const Text('Ouvrir patient'),
                                ),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ouvrir paramètres'));
    await settle(tester);
  }

  Future<void> emergency(WidgetTester tester, {String pin = '1234'}) async {
    await tester.tap(find.text('Urgence'));
    await tester.pump();
    await tester.tap(find.text('Avec l’accord de l’administrateur'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), pin);
    await tester.tap(find.text('Autoriser l’accès'));
    await settle(tester);
  }

  testWidgets(
    'non-administrator sees no settings content and can cancel to dashboard',
    (tester) async {
      await tester.runAsync(() => session.signIn('b', '1234'));
      await mount(tester);
      expect(constructed, 0);
      expect(find.text('Vous n’êtes pas administrateur.'), findsOneWidget);
      await tester.tap(find.text('Annuler'));
      await settle(tester);
      expect(find.text('Accueil disponible'), findsOneWidget);
    },
  );
  testWidgets('one exception opens both functions without repeating the code', (
    tester,
  ) async {
    await tester.runAsync(() => session.signIn('b', '1234'));
    await mount(tester);
    await emergency(tester, pin: '9999');
    expect(constructed, 0);
    expect(find.text('Code incorrect.'), findsOneWidget);
    await tester.enterText(find.byType(TextField), '1234');
    await tester.tap(find.text('Autoriser l’accès'));
    await settle(tester);
    expect(find.text('Réglages protégés'), findsOneWidget);
    await tester.tap(find.text('Ouvrir assistance'));
    await settle(tester);
    expect(find.text('Assistance protégée'), findsOneWidget);
    expect(find.text('Urgence'), findsNothing);
    final rows = await tester.runAsync(
      () => db.query(
        'companion_access_events',
        where: "action = 'administrative_exception_granted'",
      ),
    );
    expect(rows, hasLength(1));
  });
  testWidgets(
    'administrator opens directly and losing rights masks existing content',
    (tester) async {
      await tester.runAsync(() => session.signIn('a', '0123'));
      await mount(tester);
      expect(find.text('Réglages protégés'), findsOneWidget);
      await tester.runAsync(() async {
        await auth.setAdministrator(
          actorId: 'a',
          actorCode: '0123',
          targetId: 'b',
          enabled: true,
        );
        await auth.setAdministrator(
          actorId: 'b',
          actorCode: '1234',
          targetId: 'a',
          enabled: false,
        );
      });
      await settle(tester);
      expect(find.text('Réglages protégés'), findsNothing);
      expect(find.text('Vous n’êtes pas administrateur.'), findsOneWidget);
    },
  );
  testWidgets('lock masks an assistance subpage and cancellation closes it', (
    tester,
  ) async {
    await tester.runAsync(() => session.signIn('b', '1234'));
    await mount(tester);
    await emergency(tester);
    await tester.tap(find.text('Ouvrir outil'));
    await tester.pumpAndSettle();
    expect(find.text('Contenu outil'), findsOneWidget);
    session.lock();
    await tester.pump();
    expect(find.text('Contenu outil'), findsNothing);
    await tester.runAsync(() => session.signIn('b', '1234'));
    await settle(tester);
    expect(find.text('Vous n’êtes pas administrateur.'), findsOneWidget);
    await tester.tap(find.text('Annuler'));
    await settle(tester);
    expect(find.text('Accueil disponible'), findsOneWidget);
    expect(find.text('Contenu outil'), findsNothing);
  });
  testWidgets(
    'a permitted patient route cannot expose a revoked underlying administrative page',
    (tester) async {
      await tester.runAsync(() => session.signIn('b', '1234'));
      await mount(tester);
      await emergency(tester);
      await tester.tap(find.text('Ouvrir patient'));
      await settle(tester);
      expect(find.text('Dossier patient'), findsOneWidget);
      session.lock();
      await tester.runAsync(() => session.signIn('b', '1234'));
      await settle(tester);
      expect(find.text('Dossier patient'), findsNothing);
      expect(find.text('Vous n’êtes pas administrateur.'), findsOneWidget);
      await emergency(tester);
      expect(find.text('Dossier patient'), findsOneWidget);
    },
  );
  testWidgets(
    'DMP disabled keeps ordinary settings accessible without identity',
    (tester) async {
      session.setEnabled(false);
      await mount(tester);
      expect(find.text('Réglages protégés'), findsOneWidget);
      expect(find.text('Urgence'), findsNothing);
    },
  );
  testWidgets(
    'no administrators requires initial password instead of emergency',
    (tester) async {
      await tester.runAsync(() async {
        await auth.setAdministrator(
          actorId: 'a',
          actorCode: '0123',
          targetId: 'a',
          enabled: false,
        );
        await session.signIn('b', '1234');
      });
      await mount(tester);
      expect(find.text('Urgence'), findsNothing);
      expect(find.text('Mot de passe initial'), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'admin');
      await tester.tap(find.text('Autoriser l’accès'));
      await settle(tester);
      expect(find.text('Réglages protégés'), findsOneWidget);
    },
  );
}

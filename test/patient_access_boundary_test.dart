import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_access_service.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_session.dart';
import 'package:abak_desktop_companion/features/companion_access/patient_access_service.dart';
import 'package:abak_desktop_companion/features/companion_access/patient_access_boundary.dart';
import 'package:abak_desktop_companion/features/dmp_session/dmp_work_context.dart';
import 'support/companion_access_test_support.dart';

class FailableAccess extends PatientAccessService {
  FailableAccess(Database db, CompanionSession session)
    : super(database: () async => db, session: session);
  bool fail = false;
  @override
  Future<PatientAccessState> inspect(String id) {
    if (fail) throw StateError('test');
    return super.inspect(id);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory temp;
  late Database db;
  late CompanionSession session;
  late FailableAccess access;
  var constructed = 0;
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('patient_gate_ui_');
    db = await openAccessTestDatabase('${temp.path}/test.db');
    final auth = CompanionAccessService(
      database: () async => db,
      hasher: FastTestCodeHasher(),
    );
    await auth.createCode('a', '0123');
    await auth.createCode('b', '1234');
    session = CompanionSession(
      access: auth,
      dmpContext: DmpWorkContext(),
      loadNationalId: (_) async => null,
      cpsBusy: () => false,
    )..setEnabled(true);
    access = FailableAccess(db, session);
    constructed = 0;
    for (final id in ['p', 'q']) {
      await db.insert('patients', {
        'patient_id': id,
        'last_name': 'Test',
        'first_name': id,
        'created_at': 1,
      });
      await db.insert('companion_patient_access', {
        'patient_id': id,
        'referring_practitioner_id': 'a',
      });
    }
  });
  tearDown(() async {
    access.dispose();
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
    await tester.pumpWidget(
      MaterialApp(
        builder: (_, child) =>
            PatientAccessBoundary(service: access, child: child!),
        home: Builder(
          builder: (context) => Scaffold(
            body: Column(
              children: [
                for (final id in ['p', 'q'])
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => PatientAccessScope(
                          patientId: id,
                          builder: (context) {
                            constructed++;
                            return Scaffold(
                              appBar: AppBar(title: Text('Patient $id')),
                              body: Column(
                                children: [
                                  Text('Données $id'),
                                  TextButton(
                                    onPressed: () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (context) => Scaffold(
                                          appBar: AppBar(
                                            title: const Text('Rapport'),
                                          ),
                                          body: Column(
                                            children: [
                                              const Text(
                                                'Rapport confidentiel',
                                              ),
                                              TextButton(
                                                onPressed: () => showDialog<void>(
                                                  context: context,
                                                  builder: (_) =>
                                                      const AlertDialog(
                                                        content: Text(
                                                          'Dialogue confidentiel',
                                                        ),
                                                      ),
                                                ),
                                                child: const Text('Dialogue'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    child: const Text('Ouvrir rapport'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    child: Text('Ouvrir $id'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Ouvrir p'));
    await settle(tester);
  }

  Future<void> authorize(WidgetTester tester, {String pin = '1234'}) async {
    await tester.tap(find.text('Urgence'));
    await tester.pump();
    await tester.tap(find.text('Avec l’accord du kiné référent'));
    await tester.pump();
    await tester.enterText(find.byType(TextField), pin);
    await tester.tap(find.text('Autoriser l’accès'));
    await settle(tester);
  }

  testWidgets(
    'denied dossier is not constructed; cancel returns to previous page',
    (tester) async {
      await tester.runAsync(() => session.signIn('b', '1234'));
      await mount(tester);
      expect(constructed, 0);
      expect(find.text('Vous n’êtes pas le kiné référent.'), findsOneWidget);
      await tester.tap(find.text('Annuler'));
      await settle(tester);
      expect(find.text('Ouvrir p'), findsOneWidget);
      expect(find.text('Données p'), findsNothing);
    },
  );

  testWidgets(
    'wrong code stays denied, valid code opens only the requested patient',
    (tester) async {
      await tester.runAsync(() => session.signIn('b', '1234'));
      await mount(tester);
      await authorize(tester, pin: '9999');
      expect(find.text('Code incorrect.'), findsOneWidget);
      expect(constructed, 0);
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Autoriser l’accès'));
      await settle(tester);
      expect(find.text('Données p'), findsOneWidget);
      expect(
        (await tester.runAsync(() => access.inspect('q')))!.allowed,
        isFalse,
      );
      final rows = (await tester.runAsync(
        () => db.query(
          'companion_access_events',
          where: "action = 'patient_exception_granted'",
        ),
      ))!;
      expect(rows, hasLength(1));
      expect(rows.single['reason'], 'withAgreement');
    },
  );

  testWidgets(
    'lock masks report and dialog; same-user unlock requires a fresh exception',
    (tester) async {
      await tester.runAsync(() => session.signIn('b', '1234'));
      await mount(tester);
      await authorize(tester);
      await tester.tap(find.text('Ouvrir rapport'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dialogue'));
      await tester.pumpAndSettle();
      expect(find.text('Dialogue confidentiel'), findsOneWidget);
      session.lock();
      await tester.pump();
      expect(find.text('Dialogue confidentiel'), findsNothing);
      expect(find.text('Rapport confidentiel'), findsNothing);
      await tester.runAsync(() => session.signIn('b', '1234'));
      await settle(tester);
      expect(find.text('Vous n’êtes pas le kiné référent.'), findsOneWidget);
      expect(find.text('Dialogue confidentiel'), findsNothing);
      await authorize(tester);
      expect(find.text('Dialogue confidentiel'), findsOneWidget);
    },
  );

  testWidgets(
    'cancel after unlock closes report and patient without exposing their content',
    (tester) async {
      await tester.runAsync(() => session.signIn('b', '1234'));
      await mount(tester);
      await authorize(tester);
      await tester.tap(find.text('Ouvrir rapport'));
      await tester.pumpAndSettle();
      session.lock();
      await tester.runAsync(() => session.signIn('b', '1234'));
      await settle(tester);
      await tester.tap(find.text('Annuler'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Rapport confidentiel'), findsNothing);
      expect(find.text('Données p'), findsNothing);
      await settle(tester);
      expect(find.text('Ouvrir p'), findsOneWidget);
    },
  );

  testWidgets('referrer reopens after unlock without an exception', (
    tester,
  ) async {
    await tester.runAsync(() => session.signIn('a', '0123'));
    await mount(tester);
    expect(find.text('Données p'), findsOneWidget);
    session.lock();
    await tester.pump();
    expect(find.text('Données p'), findsNothing);
    await tester.runAsync(() => session.signIn('a', '0123'));
    await settle(tester);
    expect(find.text('Données p'), findsOneWidget);
    expect(find.text('Urgence'), findsNothing);
  });

  testWidgets('DMP disabled opens without selecting an identity', (
    tester,
  ) async {
    session.setEnabled(false);
    await mount(tester);
    expect(find.text('Données p'), findsOneWidget);
    expect(find.text('Urgence'), findsNothing);
  });

  testWidgets(
    'database error fails closed and retry checks authorization again',
    (tester) async {
      await tester.runAsync(() => session.signIn('a', '0123'));
      access.fail = true;
      await mount(tester);
      expect(constructed, 0);
      expect(find.text('Réessayer'), findsOneWidget);
      access.fail = false;
      await tester.tap(find.text('Réessayer'));
      await settle(tester);
      expect(find.text('Données p'), findsOneWidget);
    },
  );
  testWidgets(
    'reassignment immediately masks an already-open report for the former referrer',
    (tester) async {
      await tester.runAsync(() => session.signIn('a', '0123'));
      await mount(tester);
      await tester.tap(find.text('Ouvrir rapport'));
      await tester.pumpAndSettle();
      expect(find.text('Rapport confidentiel'), findsOneWidget);
      await tester.runAsync(() async {
        await session.access.initializeAdministrator('a', 'admin', '0123');
        final key = await session.access.generateRecoveryKey(
          actorId: 'a',
          actorCode: '0123',
        );
        await session.access.reassignPatientsWithKey(
          key: key,
          sourceId: 'a',
          assignments: {'p': 'b'},
        );
      });
      await settle(tester);
      expect(find.text('Rapport confidentiel'), findsNothing);
      expect(find.text('Vous n’êtes pas le kiné référent.'), findsOneWidget);
      expect(
        (await tester.runAsync(() => access.inspect('q')))!.allowed,
        isTrue,
      );
    },
  );
}

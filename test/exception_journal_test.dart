import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_access_service.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_session.dart';
import 'package:abak_desktop_companion/features/companion_access/exception_journal_screen.dart';
import 'package:abak_desktop_companion/features/dmp_session/dmp_work_context.dart';
import 'support/companion_access_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory temp;
  late Database db;
  late CompanionAccessService service;
  final now = DateTime.utc(2026, 11, 23);
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('exception_journal_');
    db = await openAccessTestDatabase('${temp.path}/test.db');
    service = CompanionAccessService(
      database: () async => db,
      hasher: FastTestCodeHasher(),
      now: () => now,
    );
    await service.initializeAdministrator('a', 'admin', '0123');
    await service.createCode('b', '1234');
    await db.insert('patients', {
      'patient_id': 'p',
      'last_name': 'Patient',
      'first_name': 'Test',
      'created_at': 1,
    });
    for (final event in [
      {
        'occurred_at': now.millisecondsSinceEpoch - 1,
        'action': 'patient_exception_granted',
        'patient_id': 'p',
        'previous_practitioner_id': 'a',
        'reason': 'unexpectedAbsence',
      },
      {
        'occurred_at': now.millisecondsSinceEpoch,
        'action': 'administrative_exception_granted',
        'reason': 'withAgreement',
      },
      {'occurred_at': now.millisecondsSinceEpoch, 'action': 'code_changed'},
      {
        'occurred_at': DateTime.utc(2025, 11, 22).millisecondsSinceEpoch,
        'action': 'patient_exception_granted',
      },
    ]) {
      await db.insert('companion_access_events', {
        ...event,
        'actor_practitioner_id': 'b',
        'session_id': 'test-session',
      });
    }
  });
  tearDown(() async {
    await db.close();
    await temp.delete(recursive: true);
  });
  test(
    'administrator reads only recent exceptions, newest first, without changing the journal',
    () async {
      final before = await db.query('companion_access_events');
      final rows = await service.readExceptionJournal(
        administratorId: 'a',
        code: '0123',
      );
      expect(rows.length, 2);
      expect(rows.first['action'], 'administrative_exception_granted');
      expect(rows.last['patient_last_name'], 'Patient');
      expect(rows.last['actor_name'], 'Kiné B');
      expect(rows.last['referrer_name'], 'Kiné A');
      expect(await db.query('companion_access_events'), before);
    },
  );
  test(
    'nonadministrator and wrong code are refused; failures enforce cooldown',
    () async {
      final denied = throwsA(isA<CompanionAccessException>());
      await expectLater(
        service.readExceptionJournal(administratorId: 'b', code: '1234'),
        denied,
      );
      for (var i = 0; i < 5; i++) {
        await expectLater(
          service.readExceptionJournal(administratorId: 'a', code: '9999'),
          denied,
        );
      }
      await expectLater(
        service.readExceptionJournal(administratorId: 'a', code: '0123'),
        denied,
      );
    },
  );
  test('archived actor names remain readable', () async {
    await db.update(
      'practitioners',
      {'archived_at': now.millisecondsSinceEpoch},
      where: 'practitioner_id=?',
      whereArgs: ['b'],
    );
    expect(
      (await service.readExceptionJournal(
        administratorId: 'a',
        code: '0123',
      )).first['actor_name'],
      'Kiné B',
    );
  });
  testWidgets('journal displays readable labels and clears on session change', (
    tester,
  ) async {
    final session = CompanionSession(
      access: service,
      dmpContext: DmpWorkContext(),
      loadNationalId: (_) async => null,
      cpsBusy: () => false,
    );
    addTearDown(session.dispose);
    Future<void> settle() async {
      for (var i = 0; i < 15; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)),
        );
        await tester.pump(const Duration(milliseconds: 50));
      }
    }

    await tester.pumpWidget(
      MaterialApp(
        home: ExceptionJournalScreen(service: service, session: session),
      ),
    );
    await settle();
    expect(find.text('Dossier patient : Patient Test'), findsNothing);
    await tester.enterText(find.byType(TextField), '0123');
    await tester.tap(find.text('Consulter le journal'));
    await settle();
    expect(find.text('Dossier patient : Patient Test'), findsOneWidget);
    expect(
      find.text('Motif : Avec l’accord de l’administrateur'),
      findsOneWidget,
    );
    session.setEnabled(true);
    await settle();
    expect(find.text('Dossier patient : Patient Test'), findsNothing);
    expect(find.text('Consulter le journal'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });
}

import 'dart:async';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/features/companion_access/administrative_access_service.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_access_service.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_session.dart';
import 'package:abak_desktop_companion/features/dmp_session/dmp_work_context.dart';
import 'support/companion_access_test_support.dart';

class DelayedAdminAuth extends CompanionAccessService {
  DelayedAdminAuth(Database db, DateTime Function() now)
    : super(database: () async => db, hasher: FastTestCodeHasher(), now: now);
  Completer<void>? started, gate;
  @override
  Future<void> verifyCode(String id, String code) async {
    await super.verifyCode(id, code);
    started?.complete();
    await gate?.future;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  late Directory temp;
  late Database db;
  late DelayedAdminAuth auth;
  late CompanionSession session;
  late AdministrativeAccessService access;
  late DateTime now;
  final denied = throwsA(isA<CompanionAccessException>());
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('admin_access_');
    db = await openAccessTestDatabase('${temp.path}/test.db');
    now = DateTime.utc(2026, 11, 23);
    auth = DelayedAdminAuth(db, () => now);
    await auth.createCode('a', '0123');
    await auth.createCode('b', '1234');
    await auth.initializeAdministrator('a', 'admin', '0123');
    session = CompanionSession(
      access: auth,
      dmpContext: DmpWorkContext(),
      loadNationalId: (_) async => null,
      cpsBusy: () => false,
    )..setEnabled(true);
    access = AdministrativeAccessService(
      database: () async => db,
      session: session,
      now: () => now,
    );
  });
  tearDown(() async {
    access.dispose();
    session.dispose();
    await db.close();
    await temp.delete(recursive: true);
  });
  Future<void> grant([String code = '1234']) => access.grantException(
    code: code,
    reason: AdministrativeAccessReason.withAgreement,
  );

  test(
    'only active administrators enter directly; disabled DMP leaves ordinary access open',
    () async {
      expect(
        await access.inspect(),
        AdministrativeAccessDecision.identification,
      );
      await session.signIn('a', '0123');
      expect(
        await access.inspect(),
        AdministrativeAccessDecision.administrator,
      );
      await session.signIn('b', '1234');
      expect(await access.inspect(), AdministrativeAccessDecision.denied);
      session.setEnabled(false);
      expect(await access.inspect(), AdministrativeAccessDecision.unrestricted);
      await db.insert('application_settings', {
        'setting_key': 'dmp_enabled',
        'setting_value': 'true',
        'updated_at': 1,
      });
      expect(
        await access.inspect(),
        AdministrativeAccessDecision.identification,
      );
    },
  );
  test(
    'exception logs actor, reason and session but never grants administrator rights',
    () async {
      await session.signIn('b', '1234');
      await expectLater(grant('0123'), denied);
      await grant();
      expect(await access.inspect(), AdministrativeAccessDecision.exception);
      await grant();
      final rows = await db.query(
        'companion_access_events',
        where: "action = 'administrative_exception_granted'",
      );
      expect(rows, hasLength(1));
      expect(rows.single['reason'], 'withAgreement');
      expect(rows.single['actor_practitioner_id'], 'b');
      expect(rows.single['session_id'], session.sessionId);
      expect(rows.single.values, isNot(contains('1234')));
      await expectLater(
        auth.setAdministrator(
          actorId: 'b',
          actorCode: '1234',
          targetId: 'b',
          enabled: true,
        ),
        denied,
      );
      await expectLater(
        auth.resetCode(actorId: 'b', actorCode: '1234', targetId: 'a'),
        denied,
      );
      await expectLater(access.requireDatabaseReplacementAccess(), denied);
      expect(
        (await db.query(
          'companion_practitioner_access',
          where: "practitioner_id = 'b'",
        )),
        isEmpty,
      );
    },
  );
  test(
    'lock, logout, switching and DMP changes end the common exception',
    () async {
      await session.signIn('b', '1234');
      await grant();
      session.lock();
      await session.signIn('b', '1234');
      expect(await access.inspect(), AdministrativeAccessDecision.denied);
      await grant();
      session.signOut();
      await session.signIn('b', '1234');
      expect(await access.inspect(), AdministrativeAccessDecision.denied);
      await grant();
      await session.signIn('a', '0123');
      await session.signIn('b', '1234');
      expect(await access.inspect(), AdministrativeAccessDecision.denied);
      await grant();
      session.setEnabled(false);
      session.setEnabled(true);
      await session.signIn('b', '1234');
      expect(await access.inspect(), AdministrativeAccessDecision.denied);
      await grant();
      access.dispose();
      access = AdministrativeAccessService(
        database: () async => db,
        session: session,
      );
      expect(await access.inspect(), AdministrativeAccessDecision.denied);
    },
  );
  test('5 errors impose the shared 30-second delay', () async {
    await session.signIn('b', '1234');
    for (var i = 0; i < 5; i++) {
      await expectLater(grant('9999'), denied);
    }
    await expectLater(grant(), denied);
    now = now.add(const Duration(seconds: 30));
    await grant();
    expect(await access.inspect(), AdministrativeAccessDecision.exception);
  });
  test(
    'lock while code is being verified cannot install a late grant',
    () async {
      await session.signIn('b', '1234');
      auth.started = Completer<void>();
      auth.gate = Completer<void>();
      final failure = expectLater(grant(), denied);
      await auth.started!.future;
      session.lock();
      auth.gate!.complete();
      await failure;
      auth.started = auth.gate = null;
      await session.signIn('b', '1234');
      expect(await access.inspect(), AdministrativeAccessDecision.denied);
      expect(
        await db.query(
          'companion_access_events',
          where: "action = 'administrative_exception_granted'",
        ),
        isEmpty,
      );
    },
  );
  test(
    'removing administrator rights immediately invalidates the open administrative area',
    () async {
      await session.signIn('a', '0123');
      await auth.setAdministrator(
        actorId: 'a',
        actorCode: '0123',
        targetId: 'b',
        enabled: true,
      );
      var notifications = 0;
      access.addListener(() => notifications++);
      await auth.setAdministrator(
        actorId: 'b',
        actorCode: '1234',
        targetId: 'a',
        enabled: false,
      );
      expect(notifications, greaterThan(0));
      expect(await access.inspect(), AdministrativeAccessDecision.denied);
    },
  );
  test(
    'initial password is unavailable with admins, returns after removal and does not create an admin',
    () async {
      await session.signIn('b', '1234');
      await expectLater(access.unlockBootstrap('admin'), denied);
      await auth.setAdministrator(
        actorId: 'a',
        actorCode: '0123',
        targetId: 'a',
        enabled: false,
      );
      expect(
        await access.inspect(),
        AdministrativeAccessDecision.bootstrapRequired,
      );
      await expectLater(grant(), denied);
      await expectLater(access.unlockBootstrap('wrong'), denied);
      await access.unlockBootstrap('admin');
      expect(await access.inspect(), AdministrativeAccessDecision.bootstrap);
      expect(await auth.hasAdministrators(), isFalse);
      await auth.initializeAdministrator('a', 'admin', '0123');
      expect(await access.inspect(), AdministrativeAccessDecision.denied);
      await expectLater(access.unlockBootstrap('admin'), denied);
    },
  );
  test('bootstrap errors use the persisted bootstrap counter', () async {
    await session.signIn('b', '1234');
    await auth.setAdministrator(
      actorId: 'a',
      actorCode: '0123',
      targetId: 'a',
      enabled: false,
    );
    for (var i = 0; i < 5; i++) {
      await expectLater(access.unlockBootstrap('wrong'), denied);
    }
    await expectLater(
      auth.initializeAdministrator('a', 'admin', '0123'),
      denied,
    );
    now = now.add(const Duration(seconds: 30));
    await access.unlockBootstrap('admin');
    session.lock();
    await session.signIn('b', '1234');
    expect(
      await access.inspect(),
      AdministrativeAccessDecision.bootstrapRequired,
    );
  });
  test(
    'journal failure prevents access; successful grant purges entries older than twelve months',
    () async {
      await session.signIn('b', '1234');
      await db.insert('companion_access_events', {
        'action': 'old',
        'occurred_at': 1,
      });
      await db.execute(
        "CREATE TRIGGER reject_admin_exception BEFORE INSERT ON companion_access_events WHEN NEW.action = 'administrative_exception_granted' BEGIN SELECT RAISE(ABORT, 'test'); END",
      );
      await expectLater(grant(), throwsA(isA<DatabaseException>()));
      expect(await access.inspect(), AdministrativeAccessDecision.denied);
      await db.execute('DROP TRIGGER reject_admin_exception');
      await grant();
      expect(
        await db.query('companion_access_events', where: "action = 'old'"),
        isEmpty,
      );
    },
  );
  test('archived or inactive actors cannot use a retained session', () async {
    await session.signIn('b', '1234');
    await grant();
    await db.update('practitioners', {
      'is_active': 0,
    }, where: "practitioner_id = 'b'");
    await expectLater(access.inspect(), denied);
    await expectLater(grant(), denied);
  });
}

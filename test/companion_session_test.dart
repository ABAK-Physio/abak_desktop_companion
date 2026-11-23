import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_access_service.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_session.dart';
import 'package:abak_desktop_companion/features/dmp_session/dmp_work_context.dart';
import 'support/session_access_fake.dart';

void main() {
  late SessionAccessFake access;
  late CompanionSession session;
  late DmpWorkContext dmp;
  var busy = false;
  final denied = throwsA(isA<CompanionAccessException>());
  setUp(() {
    busy = false;
    access = SessionAccessFake();
    dmp = DmpWorkContext();
    session = CompanionSession(
      access: access,
      dmpContext: dmp,
      loadNationalId: (id) async => id == 'a' ? 'cps-a' : null,
      cpsBusy: () => busy,
    )..setEnabled(true);
  });
  tearDown(() => session.dispose());

  test('archiving the active practitioner ends the session; another departure preserves it', () async {
    await session.signIn('a', '0123');
    final ticket = session.bind();
    CompanionAccessService.practitionerArchived.value = 'b';
    ticket();
    CompanionAccessService.practitionerArchived.value = 'a';
    expect(session.authenticated, isFalse);
    expect(session.practitionerId, isNull);
    expect(ticket, throwsA(isA<CompanionAccessException>()));
    CompanionAccessService.practitionerArchived.value = null;
  });

  test(
    'selection requires the target code and binds stored CPS identity only',
    () async {
      await expectLater(session.signIn('a', '9999'), denied);
      expect(session.sessionId, isNull);
      await session.signIn('a', '0123');
      expect(session.practitionerId, 'a');
      expect(session.authenticated, isTrue);
      dmp.bind('cps-a')();
      expect(() => dmp.bind('cps-b'), throwsStateError);
    },
  );

  test(
    'a practitioner without a CPS can sign in and lock but cannot start DMP',
    () async {
      await session.signIn('b', '1234');
      expect(session.authenticated, isTrue);
      expect(() => dmp.bind('cps-a'), throwsStateError);
      expect(session.lock(), isTrue);
      expect(session.sessionId, isNull);
      await session.signIn('b', '1234');
      expect(session.authenticated, isTrue);
    },
  );

  test(
    'failed or cancelled switching preserves the previous identity and tickets',
    () async {
      await session.signIn('a', '0123');
      final id = session.sessionId;
      final localTicket = session.bind(), dmpTicket = dmp.bind('cps-a');
      await expectLater(session.signIn('b', '0123'), denied);
      session.cancelAuthentication();
      expect(session.sessionId, id);
      expect(session.practitionerId, 'a');
      localTicket();
      dmpTicket();
    },
  );

  test(
    'lock ends the session and same-user unlock never revives old tickets',
    () async {
      await session.signIn('a', '0123');
      final id = session.sessionId;
      final localTicket = session.bind(), dmpTicket = dmp.bind('cps-a');
      session.lock();
      expect(session.sessionId, isNull);
      expect(session.practitionerId, 'a');
      expect(localTicket, throwsA(isA<CompanionAccessException>()));
      await expectLater(session.signIn('a', '1234'), denied);
      expect(session.locked, isTrue);
      await session.signIn('a', '0123');
      expect(session.sessionId, isNot(id));
      expect(localTicket, throwsA(isA<CompanionAccessException>()));
      expect(dmpTicket, throwsStateError);
    },
  );

  test(
    'switch, logout and mode changes each invalidate existing sessions',
    () async {
      await session.signIn('a', '0123');
      final first = session.bind();
      await session.signIn('b', '1234');
      expect(first, throwsA(isA<CompanionAccessException>()));
      final second = session.bind();
      expect(session.signOut(), isTrue);
      expect(session.practitionerId, isNull);
      expect(second, throwsA(isA<CompanionAccessException>()));
      await session.signIn('a', '0123');
      final third = session.bind();
      session.setEnabled(false);
      await expectLater(session.signIn('a', '0123'), denied);
      session.setEnabled(true);
      expect(session.authenticated, isFalse);
      expect(third, throwsA(isA<CompanionAccessException>()));
    },
  );

  test(
    'a late authentication cannot reopen a disabled and re-enabled session',
    () async {
      access.verificationGate = Completer<void>();
      final attempt = session.signIn('a', '0123');
      final rejected = expectLater(attempt, denied);
      session.setEnabled(false);
      session.setEnabled(true);
      access.verificationGate!.complete();
      await rejected;
      expect(session.sessionId, isNull);
      expect(() => dmp.bind('cps-a'), throwsStateError);
    },
  );

  test('cancelling an in-flight switch retains the old session', () async {
    await session.signIn('a', '0123');
    final id = session.sessionId;
    access.verificationGate = Completer<void>();
    final rejected = expectLater(session.signIn('b', '1234'), denied);
    session.cancelAuthentication();
    access.verificationGate!.complete();
    await rejected;
    expect(session.sessionId, id);
  });

  test(
    'a card operation prevents changing or locking its working context',
    () async {
      await session.signIn('a', '0123');
      final id = session.sessionId;
      busy = true;
      expect(session.lock(), isFalse);
      expect(session.signOut(), isFalse);
      await expectLater(session.signIn('b', '1234'), denied);
      expect(session.sessionId, id);
      busy = false;
      expect(session.lock(), isTrue);
    },
  );

  test(
    'card ownership is rechecked after asynchronous authentication',
    () async {
      access.verificationGate = Completer<void>();
      final rejected = expectLater(session.signIn('a', '0123'), denied);
      busy = true;
      access.verificationGate!.complete();
      await rejected;
      expect(session.authenticated, isFalse);
    },
  );

  test(
    'a newly constructed session never restores the previous identity',
    () async {
      await session.signIn('a', '0123');
      final restarted = CompanionSession(
        access: access,
        dmpContext: DmpWorkContext(),
        loadNationalId: (_) async => null,
      )..setEnabled(true);
      expect(restarted.sessionId, isNull);
      expect(restarted.practitionerId, isNull);
      restarted.dispose();
    },
  );
}

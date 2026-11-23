import 'dart:async';
import 'package:abak_desktop_companion/features/cps/cps_operation_lease.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/companion_access/companion_session.dart';
import 'package:abak_desktop_companion/features/dmp_session/dmp_work_context.dart';
import 'package:abak_desktop_companion/features/dmp_session/practitioner_session_banner.dart';
import 'package:abak_desktop_companion/features/dmp_setup/dmp_setup_service.dart';
import 'package:abak_desktop_companion/features/practitioners/models/practitioner.dart';
import 'support/session_access_fake.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late SessionAccessFake access;
  late CompanionSession session;
  late TextEditingController draft;
  var enabled = false;
  var identityChanges = 0;
  var nativeCalls = 0;
  const people = [
    Practitioner(
      practitionerId: 'a',
      displayName: 'Kiné A',
      isActive: true,
      createdAt: 0,
    ),
    Practitioner(
      practitionerId: 'b',
      displayName: 'Kiné B',
      isActive: true,
      createdAt: 1,
    ),
  ];
  setUp(() {
    enabled = false;
    identityChanges = nativeCalls = 0;
    access = SessionAccessFake();
    session = CompanionSession(
      access: access,
      dmpContext: DmpWorkContext(),
      loadNationalId: (_) async => null,
    );
    draft = TextEditingController();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('abak_dmp_fr'), (
          _,
        ) async {
          nativeCalls++;
          throw StateError('Unexpected card access');
        });
  });
  tearDown(() {
    expect(nativeCalls, 0);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel('abak_dmp_fr'), null);
    session.dispose();
    draft.dispose();
  });

  Future<void> show(WidgetTester tester, {bool resetNavigation = false}) async {
    tester.view.physicalSize = const Size(1100, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var navigationKey = GlobalKey<NavigatorState>();
    await tester.pumpWidget(
      StatefulBuilder(
        builder: (context, rebuild) => MaterialApp(
          navigatorKey: navigationKey,
          builder: (_, child) => PractitionerSessionBanner(
            session: session,
            now: tester.binding.clock.now,
            loadIdleMinutes: () async => 15,
            loadEnabled: () async => enabled,
            loadPractitioners: () async => people,
            onIdentityChanged: () {
              identityChanges++;
              if (resetNavigation) {
                rebuild(() => navigationKey = GlobalKey<NavigatorState>());
              }
            },
            child: child!,
          ),
          home: Scaffold(
            body: Builder(
              builder: (context) => Column(
                children: [
                  TextField(controller: draft),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            const Scaffold(body: Text('Second écran')),
                      ),
                    ),
                    child: const Text('Suite'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> choose(WidgetTester tester, String name) async {
    await tester.tap(
      find
          .text(
            session.practitionerId == null
                ? 'Choisir le praticien'
                : 'Changer de praticien',
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  Future<void> signIn(WidgetTester tester, String name, String code) async {
    await choose(tester, name);
    await tester.enterText(
      find.widgetWithText(TextField, 'Code personnel Companion'),
      code,
    );
    await tester.tap(find.text('S’identifier'));
    await tester.pumpAndSettle();
  }

  testWidgets(
    'personal code selection and unlock preserve drafts without any card access',
    (tester) async {
      await show(tester);
      expect(find.text('Praticien non sélectionné'), findsNothing);
      await tester.enterText(find.byType(TextField), 'Brouillon conservé');
      await tester.tap(find.text('Suite'));
      await tester.pumpAndSettle();
      enabled = true;
      DmpSetupService.changes.value++;
      await tester.pumpAndSettle();
      await choose(tester, 'Kiné A');
      expect(session.authenticated, isFalse);
      await tester.enterText(find.byType(TextField), '9999');
      await tester.tap(find.text('S’identifier'));
      await tester.pumpAndSettle();
      expect(find.text('Code incorrect.'), findsOneWidget);
      expect(session.authenticated, isFalse);
      await tester.enterText(find.byType(TextField), '0123');
      await tester.tap(find.text('S’identifier'));
      await tester.pumpAndSettle();
      expect(find.text('Kiné actif : Kiné A'), findsOneWidget);
      final id = session.sessionId;
      await tester.tap(find.text('Verrouiller'));
      await tester.pumpAndSettle();
      expect(find.text('Second écran'), findsNothing);
      expect(session.sessionId, isNull);
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Déverrouiller'));
      await tester.pumpAndSettle();
      expect(find.text('Companion verrouillé'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '0123');
      await tester.tap(find.text('Déverrouiller'));
      await tester.pumpAndSettle();
      expect(find.text('Second écran'), findsOneWidget);
      expect(session.sessionId, isNot(id));
      expect(identityChanges, 1);
      expect(draft.text, 'Brouillon conservé');
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('cancelled and failed switches keep the previous practitioner', (
    tester,
  ) async {
    enabled = true;
    await show(tester);
    await signIn(tester, 'Kiné A', '0123');
    final id = session.sessionId;
    await choose(tester, 'Kiné B');
    await tester.enterText(find.byType(TextField), '0123');
    await tester.tap(find.text('S’identifier'));
    await tester.pumpAndSettle();
    expect(session.practitionerId, 'a');
    expect(session.sessionId, id);
    await tester.tap(find.text('Annuler'));
    await tester.pumpAndSettle();
    expect(session.sessionId, id);
    expect(identityChanges, 1);
    await signIn(tester, 'Kiné B', '1234');
    expect(session.practitionerId, 'b');
    expect(session.sessionId, isNot(id));
    expect(identityChanges, 2);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('first selection creates and confirms the code inline', (
    tester,
  ) async {
    enabled = true;
    access.codes.remove('b');
    await show(tester);
    await choose(tester, 'Kiné B');
    await tester.enterText(
      find.widgetWithText(TextField, 'Nouveau code Companion'),
      '0123',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirmer le nouveau code'),
      '4321',
    );
    await tester.tap(find.text('Créer mon code et m’identifier'));
    await tester.pumpAndSettle();
    expect(
      find.text('Les deux nouveaux codes sont différents.'),
      findsOneWidget,
    );
    expect(access.creations, 0);
    await tester.enterText(
      find.widgetWithText(TextField, 'Confirmer le nouveau code'),
      '0123',
    );
    await tester.tap(find.text('Créer mon code et m’identifier'));
    await tester.pumpAndSettle();
    expect(access.creations, 1);
    expect(session.practitionerId, 'b');
    expect(session.authenticated, isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
    'inactivity without an associated CPS locks after 15 minutes and waits for an actual card operation',
    (tester) async {
      enabled = true;
      await show(tester);
      await signIn(tester, 'Kiné A', '0123');
      final lease = CpsOperationLease.acquire();
      addTearDown(lease.release);
      await tester.pump(const Duration(minutes: 15));
      expect(session.locked, isFalse);
      lease.release();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Companion verrouillé'), findsOneWidget);
      expect(session.sessionId, isNull);
      enabled = false;
      DmpSetupService.changes.value++;
      await tester.pumpAndSettle();
      expect(find.text('Companion verrouillé'), findsNothing);
      await tester.pump(const Duration(hours: 1));
      enabled = true;
      DmpSetupService.changes.value++;
      await tester.pumpAndSettle();
      expect(session.sessionId, isNull);
      expect(find.text('Praticien non sélectionné'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'a different practitioner can authenticate from the locked screen',
    (tester) async {
      enabled = true;
      await show(tester);
      await signIn(tester, 'Kiné A', '0123');
      await tester.tap(find.text('Verrouiller'));
      await tester.pumpAndSettle();
      await choose(tester, 'Kiné B');
      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();
      expect(find.text('Companion verrouillé'), findsOneWidget);
      await signIn(tester, 'Kiné B', '1234');
      expect(session.practitionerId, 'b');
      expect(session.locked, isFalse);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'successful switches close former routes, same-user unlock keeps them',
    (tester) async {
      enabled = true;
      await show(tester, resetNavigation: true);
      await signIn(tester, 'Kiné A', '0123');
      await tester.tap(find.text('Suite'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Verrouiller'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '0123');
      await tester.tap(find.text('Déverrouiller'));
      await tester.pumpAndSettle();
      expect(find.text('Second écran'), findsOneWidget);
      await signIn(tester, 'Kiné B', '1234');
      expect(find.text('Second écran'), findsNothing);
      expect(find.text('Suite'), findsOneWidget);
      await tester.tap(find.text('Déconnecter'));
      await tester.pumpAndSettle();
      expect(session.sessionId, isNull);
      expect(find.text('Praticien non sélectionné'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('disabling during verification cannot reopen the session', (
    tester,
  ) async {
    enabled = true;
    await show(tester);
    await choose(tester, 'Kiné A');
    access.verificationGate = Completer<void>();
    await tester.enterText(find.byType(TextField), '0123');
    await tester.tap(find.text('S’identifier'));
    await tester.pump();
    enabled = false;
    DmpSetupService.changes.value++;
    await tester.pump();
    await tester.pump();
    access.verificationGate!.complete();
    await tester.pumpAndSettle();
    expect(session.authenticated, isFalse);
    expect(session.sessionId, isNull);
    expect(find.text('Kiné actif : Kiné A'), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
}

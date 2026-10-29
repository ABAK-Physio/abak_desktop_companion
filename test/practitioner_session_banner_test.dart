import 'package:abak_desktop_companion/features/cps/cps_operation_lease.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_session/practitioner_session_banner.dart';
import 'package:abak_desktop_companion/features/dmp_setup/dmp_setup_service.dart';
import 'package:abak_desktop_companion/features/practitioners/models/practitioner.dart';
import 'package:abak_desktop_companion/features/cps/cps_profile.dart';

void main() {
  testWidgets(
    'optional banner preserves route and draft; lock rejects another CPS',
    (tester) async {
      bool enabled = false;
      int reads = 0;
      String cardId = 'other';
      final draft = TextEditingController();
      addTearDown(draft.dispose);
      const practitioner = Practitioner(
        practitionerId: 'p1',
        displayName: 'Kiné test',
        isActive: true,
        createdAt: 0,
      );
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => PractitionerSessionBanner(
            now: tester.binding.clock.now,
            loadIdleMinutes: () async => 15,
            loadEnabled: () async => enabled,
            loadPractitioners: () async => [practitioner],
            loadNationalId: (_) async => 'expected',
            readCard: (_) async {
              reads++;
              return CpsProfile(
                nationalId: cardId,
                familyName: 'TEST',
                givenName: 'KINE',
                professionCode: 70,
                cardType: 0,
                situations: [],
              );
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
      );
      await tester.pumpAndSettle();
      expect(find.text('Praticien non sélectionné'), findsNothing);
      await tester.enterText(find.byType(TextField), 'Brouillon conservé');
      await tester.tap(find.text('Suite'));
      await tester.pumpAndSettle();
      enabled = true;
      DmpSetupService.changes.value++;
      await tester.pumpAndSettle();
      expect(find.text('Second écran'), findsOneWidget);
      expect(find.text('Praticien non sélectionné'), findsOneWidget);
      await tester.tap(find.text('Choisir le praticien'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Kiné test'));
      await tester.pumpAndSettle();
      expect(reads, 0);
      await tester.tap(find.text('Verrouiller'));
      await tester.pumpAndSettle();
      expect(find.text('Second écran'), findsNothing);
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Déverrouiller avec ma CPS'));
      await tester.pumpAndSettle();
      expect(find.text('Companion verrouillé'), findsOneWidget);
      cardId = 'expected';
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Déverrouiller avec ma CPS'));
      await tester.pumpAndSettle();
      expect(find.text('Second écran'), findsOneWidget);
      final lease = CpsOperationLease.acquire();
      addTearDown(lease.release);
      await tester.pump(const Duration(minutes: 15));
      expect(find.text('Second écran'), findsOneWidget);
      lease.release();
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Companion verrouillé'), findsOneWidget);
      expect(reads, 2); // No automatic card access when the timeout expires.
      enabled = false;
      DmpSetupService.changes.value++;
      await tester.pumpAndSettle();
      expect(find.textContaining('Praticien sélectionné'), findsNothing);
      expect(find.text('Second écran'), findsOneWidget);
      await tester.pump(const Duration(hours: 1));
      expect(find.text('Companion verrouillé'), findsNothing);
      expect(draft.text, 'Brouillon conservé');
      expect(reads, 2);
      await tester.pumpWidget(const SizedBox());
    },
  );
}

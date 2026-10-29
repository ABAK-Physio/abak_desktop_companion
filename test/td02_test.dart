import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_td02/td02_result.dart';
import 'package:abak_desktop_companion/features/dmp_td02/td02_screen.dart';

void main() {
  final request = File('assets/dmp_local/td02/request.xml').readAsStringSync();
  const context = Td02Context(
    ins: '187012425258307',
    oid: '1.2.250.1.213.1.4.10',
    professional: '899700854237',
  );
  String fixture(String name) =>
      File('assets/dmp_local/td02/SYNTHETIQUE-$name.xml').readAsStringSync();
  Td02Result read(String name) => Td02Reader.read(
    request: request,
    response: fixture(name),
    context: context,
  );
  bool allows(
    Td02Result r,
    DmpAction a, {
    bool opposition = false,
    bool consent = false,
    bool rights = true,
    bool author = true,
  }) => r.allows(
    a,
    opposition: opposition,
    functionalRights: rights,
    authorRights: author,
    consultationConsent: consent,
  );
  test(
    'Absent and closed block all actions; closure details survive unknown code',
    () {
      for (final name in ['inexistant', 'ferme-motif-inconnu']) {
        final r = read(name);
        for (final a in DmpAction.values) {
          expect(allows(r, a, consent: true), false);
        }
        expect(r.canSendNetworkRequest, false);
      }
      final r = read('ferme-motif-inconnu');
      expect(r.state, DmpState.closed);
      expect(r.message, contains('DMP fermé'));
      expect(r.closedAt, '20261001090000');
      expect(r.closureDetails, contains('Motif non reconnu'));
    },
  );
  test(
    'Consultation restrictions never become blanket alimentation restrictions',
    () {
      for (final name in [
        'actif-non-existe',
        'actif-EXPIRE',
        'actif-INTERDIT',
      ]) {
        final r = read(name);
        expect(r.state, DmpState.active);
        expect(allows(r, DmpAction.consult, consent: true), false);
        expect(allows(r, DmpAction.deposit), true);
        expect(allows(r, DmpAction.deposit, opposition: true), false);
        expect(allows(r, DmpAction.replace, opposition: true), true);
        expect(allows(r, DmpAction.delete, opposition: true), true);
        expect(allows(r, DmpAction.deposit, author: false), false);
        expect(allows(r, DmpAction.technicalSearch, rights: false), false);
        expect(r.canSendNetworkRequest, false);
      }
      expect(read('actif-EXPIRE').message, contains('expirée'));
      expect(read('actif-INTERDIT').message, contains('bloquée'));
      expect(allows(read('actif-VALIDE'), DmpAction.consult), false);
      expect(
        allows(read('actif-VALIDE'), DmpAction.consult, consent: true),
        true,
      );
    },
  );
  for (final name in [
    'NF-contradictoire',
    'correlation-soap',
    'correlation-query',
    'correlation-message',
    'autre-patient',
    'erreur-hl7',
    'xml-invalide',
    'soap-fault',
    'query-inconnu',
  ]) {
    test('Reject $name without claiming DMP absent', () {
      final r = read(name);
      expect(r.state, DmpState.unknown);
      for (final a in DmpAction.values) {
        expect(allows(r, a, consent: true), false);
      }
    });
  }
  test('Unknown/missing/duplicate authorization suspends actions', () {
    for (final xml in [
      fixture('actif-EXPIRE').replaceAll('code="EXPIRE"', 'code="INCONNU"'),
      fixture('actif-EXPIRE').replaceAll('code="AUTORISATION"', 'code="AUTRE"'),
    ]) {
      final r = Td02Reader.read(
        request: request,
        response: xml,
        context: context,
      );
      expect(r.right, ConsultationRight.unknown);
      expect(allows(r, DmpAction.deposit), false);
    }
  });
  test(
    'Context patient, professional and NIA guarded before any operation',
    () {
      for (final c in [
        const Td02Context(
          ins: 'autre',
          oid: '1.2.250.1.213.1.4.10',
          professional: '899700854237',
        ),
        const Td02Context(
          ins: '187012425258307',
          oid: '1.2.250.1.213.1.4.10',
          professional: '899700870597',
        ),
      ]) {
        expect(
          Td02Reader.read(
            request: request,
            response: fixture('actif-VALIDE'),
            context: c,
          ).state,
          DmpState.unknown,
        );
      }
      expect(
        Td02Reader.read(
          request: '',
          response: '',
          context: const Td02Context(
            ins: 'nia',
            oid: '1.2.250.1.213.1.4.9',
            professional: 'x',
          ),
        ).state,
        DmpState.nia,
      );
    },
  );
  test('HTTP errors, unknown status and hostile XML cannot enable actions', () {
    for (final status in [302, 500, 503]) {
      expect(
        Td02Reader.read(
          request: request,
          response: fixture('actif-VALIDE'),
          context: context,
          httpStatus: status,
        ).state,
        DmpState.unknown,
      );
    }
    expect(
      Td02Reader.read(
        request: request,
        response: fixture(
          'actif-VALIDE',
        ).replaceAll('code="active"', 'code="ETAT_INCONNU"'),
        context: context,
      ).state,
      DmpState.unknown,
    );
    expect(
      Td02Reader.read(
        request: request,
        response: "<!DOCTYPE x>${fixture('actif-VALIDE')}",
        context: context,
      ).state,
      DmpState.unknown,
    );
  });
  test('Duplicate fields and wrong namespaces fail closed', () {
    final source = fixture('actif-VALIDE');
    final authPattern = RegExp(
      r'<attentionLine>.*?code="AUTORISATION".*?</attentionLine>',
      dotAll: true,
    );
    final match = authPattern.firstMatch(source);
    expect(match, isNotNull);
    final duplicate = source.replaceFirst(
      match!.group(0)!,
      '${match.group(0)}${match.group(0)}',
    );
    final r = Td02Reader.read(
      request: request,
      response: duplicate,
      context: context,
    );
    expect(r.right, ConsultationRight.unknown);
    expect(allows(r, DmpAction.deposit), false);
    final wrong = source.replaceAll('urn:hl7-org:v3', 'urn:untrusted');
    expect(
      Td02Reader.read(
        request: request,
        response: wrong,
        context: context,
      ).state,
      DmpState.unknown,
    );
  });
  testWidgets(
    'Interface resets actions and displays closed/expired/blocked correctly',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 2400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const MaterialApp(home: Td02Screen()));
      Future<void> choose(String label) async {
        final dropdown = find.byType(DropdownButtonFormField<String>);
        await tester.ensureVisible(dropdown);
        await tester.tap(dropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text(label).last);
        await tester.pumpAndSettle();
      }

      Future<OutlinedButton> button(DmpAction a) async {
        final f = find.byKey(ValueKey(a));
        await tester.ensureVisible(f);
        await tester.pumpAndSettle();
        return tester.widget<OutlinedButton>(f);
      }

      await choose('Autorisation expirée');
      expect(
        find.textContaining('Autorisation de consultation expirée.'),
        findsOneWidget,
      );
      expect((await button(DmpAction.deposit)).onPressed, isNotNull);
      expect((await button(DmpAction.consult)).onPressed, isNull);
      await choose('DMP fermé');
      expect(find.textContaining('DMP fermé. Envoi'), findsOneWidget);
      for (final a in DmpAction.values) {
        expect((await button(a)).onPressed, isNull);
      }
      await choose('Consultation bloquée');
      expect(find.textContaining('Consultation bloquée pour'), findsOneWidget);
      expect((await button(DmpAction.deposit)).onPressed, isNotNull);
      final toggle = find.widgetWithText(
        SwitchListTile,
        'Opposition aux nouveaux dépôts',
      );
      await tester.ensureVisible(toggle);
      await tester.tap(toggle);
      await tester.pumpAndSettle();
      expect((await button(DmpAction.deposit)).onPressed, isNull);
      expect((await button(DmpAction.delete)).onPressed, isNotNull);
      await choose('DMP inexistant');
      expect((await button(DmpAction.delete)).onPressed, isNull);
      expect(find.textContaining('patientPerson/name'), findsNothing);
    },
  );
}

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_setup/dmp_setup_service.dart';
import 'package:abak_desktop_companion/features/dmp_td02/td02_result.dart';
import 'package:abak_desktop_companion/features/dmp_td02/patient_person_panel.dart';
import 'dmp_setup_test.dart' show SettingsDb;

class DeferredSettings extends DmpSetupService {
  final reads = <Completer<bool>>[];
  @override
  Future<bool> showPatientPerson() {
    final pending = Completer<bool>();
    reads.add(pending);
    return pending.future;
  }
}

void main() {
  final request = File('assets/dmp_local/td02/request.xml').readAsStringSync();
  String fixture(String name) =>
      File('assets/dmp_local/td02/SYNTHETIQUE-$name.xml').readAsStringSync();
  Td02Result read(String response) => Td02Reader.read(
    request: request,
    response: response,
    context: const Td02Context(
      ins: '187012425258307',
      oid: '1.2.250.1.213.1.4.10',
      professional: '899700854237',
    ),
  );

  test('validated identity stays separate from rights and INS context', () {
    for (final name in [
      'actif-VALIDE',
      'actif-non-existe',
      'ferme-motif-inconnu',
    ]) {
      final result = read(fixture(name));
      expect(result.patientPerson?.traits['Prénoms'], 'Sylvain');
      expect(result.patientPerson?.traits['Nom de naissance'], 'Bonnel');
      expect(result.patientPerson?.traits['Date de naissance'], '19870101');
      expect(result.canSendNetworkRequest, false);
      expect(
        () => result.patientPerson!.traits['Prénoms'] = 'changed',
        throwsUnsupportedError,
      );
    }
  });
  test('rejected and absent responses never expose identity', () {
    for (final name in [
      'autre-patient',
      'correlation-soap',
      'correlation-query',
      'correlation-message',
      'erreur-hl7',
      'xml-invalide',
      'soap-fault',
      'inexistant',
    ]) {
      expect(read(fixture(name)).patientPerson, isNull, reason: name);
    }
  });
  test('optional identity absent or ambiguous does not alter DMP rights', () {
    final xml = fixture('actif-VALIDE');
    final pattern = RegExp(r'<patientPerson[\s\S]*?</patientPerson>');
    final person = pattern.firstMatch(xml)!.group(0)!;
    for (final replacement in [
      '',
      person + person,
      '<patientPerson nullFlavor="UNK"/>',
    ]) {
      final result = read(xml.replaceFirst(pattern, replacement));
      expect(result.state, DmpState.active);
      expect(result.right, ConsultationRight.valid);
      expect(result.patientPerson, isNull);
    }
  });
  test(
    'preference is opt-in and persists without tools or card operations',
    () async {
      final db = SettingsDb();
      DmpSetupService service() => DmpSetupService(
        database: () async => db,
        tools: () async => throw StateError('Must not inspect tools'),
        probe: (_) async => throw StateError('Must not run tools'),
      );
      expect(await service().showPatientPerson(), false);
      expect(db.writes, 0);
      await service().setShowPatientPerson(true);
      expect(await service().showPatientPerson(), true);
      await service().setShowPatientPerson(false);
      expect(await service().showPatientPerson(), false);
      db.patientPerson = 'invalid';
      expect(await service().showPatientPerson(), false);
      expect(db.value, isNull);
      expect(db.idle, isNull);
    },
  );
  testWidgets(
    'hidden by default, toggles immediately and clears with patient',
    (tester) async {
      final db = SettingsDb();
      final settings = DmpSetupService(database: () async => db);
      final person = read(fixture('actif-VALIDE')).patientPerson;
      Future<void> render(bool hasPatient) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: PatientPersonPanel(
                person: hasPatient ? person : null,
                settings: settings,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      await render(true);
      expect(find.textContaining('Sylvain'), findsNothing);
      await settings.setShowPatientPerson(true);
      await tester.pumpAndSettle();
      expect(find.textContaining('Sylvain'), findsOneWidget);
      expect(
        find.textContaining('Seuls les traits de l’INS font foi'),
        findsOneWidget,
      );
      await settings.setShowPatientPerson(false);
      await tester.pump();
      expect(find.textContaining('Sylvain'), findsNothing);
      await settings.setShowPatientPerson(true);
      await tester.pumpAndSettle();
      await render(false);
      expect(find.textContaining('Sylvain'), findsNothing);
    },
  );
  testWidgets('failed or stale preference reads never reveal identity', (
    tester,
  ) async {
    final settings = DeferredSettings();
    final person = read(fixture('actif-VALIDE')).patientPerson;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PatientPersonPanel(person: person, settings: settings),
        ),
      ),
    );
    expect(settings.reads.length, 1);
    DmpSetupService.changes.value++;
    expect(settings.reads.length, 2);
    settings.reads[1].complete(false);
    await tester.pumpAndSettle();
    settings.reads[0].complete(true);
    await tester.pumpAndSettle();
    expect(find.textContaining('Sylvain'), findsNothing);
    DmpSetupService.changes.value++;
    settings.reads[2].completeError(StateError('Local settings unavailable'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Sylvain'), findsNothing);
  });
}

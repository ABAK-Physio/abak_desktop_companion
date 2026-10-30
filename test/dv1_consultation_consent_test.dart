import 'dart:io';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/bridge.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/ports.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/consultation_consent.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/access_screen.dart';
import 'package:abak_desktop_companion/features/dmp_td02/td02_result.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/td03.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/access_context.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/contracts.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/wire/package.dart';

class SerializationOnly extends Fake implements DmpWireMaterial {
  @override
  void check(DmpSession session, DateTime now) {}
  @override
  DmpWireConfiguration get configuration => const DmpWireConfiguration(
    endpoint: DmpNativeTd03.endpoint,
    sourceId: '2.25.123',
    lpsId: 'TEST',
    lpsName: 'TEST',
    lpsVersion: 'TEST',
    homologationId: 'TEST',
  );
  @override
  String get authenticationDer => File(
    'test/fixtures/dmp_local_certificate.pem',
  ).readAsStringSync().replaceAll(RegExp(r'-----[^\n]+-----|\s'), '');
}

void main() {
  test(
    'Oui seul ne modifie jamais une autorisation; consultation explicite requise',
    () {
      for (final right in [
        ConsultationRight.absent,
        ConsultationRight.expired,
        ConsultationRight.valid,
      ]) {
        final state = Td02Result(DmpState.active, right: right);
        expect(
          authorizationChange(
            state,
            granted: true,
            consultationRequested: false,
          ),
          AuthorizationChange.none,
        );
        expect(
          authorizationChange(
            state,
            granted: true,
            consultationRequested: true,
          ),
          right == ConsultationRight.valid
              ? AuthorizationChange.none
              : AuthorizationChange.add,
        );
        expect(
          authorizationChange(
            state,
            granted: false,
            consultationRequested: false,
          ),
          right == ConsultationRight.valid
              ? AuthorizationChange.remove
              : AuthorizationChange.none,
        );
      }
      for (final state in [
        const Td02Result(DmpState.absent),
        const Td02Result(DmpState.closed),
        const Td02Result(DmpState.unknown),
        const Td02Result(DmpState.active, right: ConsultationRight.blocked),
        const Td02Result(DmpState.active),
      ]) {
        expect(
          () => authorizationChange(
            state,
            granted: true,
            consultationRequested: true,
          ),
          throwsStateError,
        );
      }
    },
  );
  test(
    'refus persistant après interruption, isolé par patient et praticien, reprise explicite',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'synthetic-consent-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final store = ConsultationConsentStore(directory);
      Future<void> save(bool yes, bool pending) async {
        await store.save(
          '12345678901',
          '123456789012345',
          patient: 'SYNTHETIQUE',
          source: 'fixture',
          granted: yes,
          pendingWithdrawal: pending,
          now: DateTime.utc(2026, 10, 27),
        );
      }

      await save(true, false);
      await save(false, true);
      final reloaded = ConsultationConsentStore(directory);
      expect(
        (await reloaded.latest('12345678901', '123456789012345'))!['granted'],
        false,
      );
      expect(
        (await reloaded.latest(
          '12345678901',
          '123456789012345',
        ))!['pendingWithdrawal'],
        true,
      );
      expect(await reloaded.latest('98765432101', '123456789012345'), isNull);
      expect(await reloaded.latest('12345678901', '987654321012345'), isNull);
      await expectLater(save(true, false), throwsStateError);
      await save(false, false);
      await save(true, false);
      final files = await directory
          .list(recursive: true)
          .where((e) => e is File)
          .toList();
      expect(files.length, 4);
      await (files.first as File).writeAsString('broken');
      await expectLater(
        reloaded.latest('12345678901', '123456789012345'),
        throwsA(anything),
      );
    },
  );
  test(
    'TD0.3 sérialise AJOUT/SUPPRESSION et conserve identité, secret et corrélation',
    () {
      final now = DateTime.utc(2026, 10, 27, 12);
      final context = Dv1AccessContext(
        professional: '12345678901',
        structure: '123456789',
        sector: 'SA07',
        ins: '123456789012345',
        patientLabel: 'SYNTHETIQUE',
        source: 'fixture',
        scenario: 'PRE_TD0.3',
        confirmedAt: now,
        birthDate: '2014-01-01',
        minorsEnabled: true,
        secretConnection: true,
      );
      final session = DmpSession(
        id: 'TEST',
        professional: context.professional,
        authority: '2.25.123',
        structure: context.structure,
        certificateHash: '',
        contextHash: '',
        issuedAt: now,
        expiresAt: now.add(const Duration(minutes: 2)),
      );
      for (final add in [true, false]) {
        final request = DmpNativeTd03.build(
          context,
          session,
          SerializationOnly(),
          now,
          add: add,
        );
        final xml = XmlDocument.parse(request);
        expect(
          xml
              .findAllElements('Action', namespaceUri: Td02Reader.wsa)
              .single
              .innerText,
          'urn:si-dmp-habilitations:HabilitationsEndPoint:setAuthorization',
        );
        final action = xml
            .findAllElements('action', namespaceUri: DmpNativeTd03.ns)
            .single;
        expect(action.innerText, add ? 'AJOUT' : 'SUPPRESSION');
        expect(request, contains(context.ins));
        expect(request, contains('INVISIBLE_REPRESENTANTS_LEGAUX'));
        expect(request, isNot(contains('MEDECIN_TRAITANT')));
        final messageId = xml
            .findAllElements('MessageID', namespaceUri: Td02Reader.wsa)
            .single
            .innerText;
        String response({String? id, String status = 'DMPOk'}) =>
            '<s:Envelope xmlns:s="${Td02Reader.soap}" xmlns:w="${Td02Reader.wsa}" xmlns:h="${DmpNativeTd03.ns}"><s:Header><w:RelatesTo>${id ?? messageId}</w:RelatesTo></s:Header><s:Body><h:setAuthorizationResponse><h:output><h:status>$status</h:status></h:output></h:setAuthorizationResponse></s:Body></s:Envelope>';
        expect(
          DmpNativeTd03.read(request, DmpTd02Reply(200, response())).status,
          'DMPOk',
        );
        expect(
          DmpNativeTd03.read(
            request,
            DmpTd02Reply(200, response(status: 'DMPError')),
          ).status,
          'DMPError',
        );
        expect(
          () => DmpNativeTd03.read(
            request,
            DmpTd02Reply(200, response(id: 'other')),
          ),
          throwsStateError,
        );
        expect(
          () => DmpNativeTd03.read(request, DmpTd02Reply(503, response())),
          throwsStateError,
        );
        expect(
          () => DmpNativeTd03.read(
            request,
            DmpTd02Reply(200, response().replaceAll('h:status', 'h:unknown')),
          ),
          throwsFormatException,
        );
        expect(
          () => DmpNativeTd03.read(
            request,
            const DmpTd02Reply(200, '<invalid/>'),
          ),
          throwsFormatException,
        );
      }
    },
  );
  test('SOAP Fault HTTP 500 corrélé affichable sans annoncer de succès', () {
    const request =
        '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:w="http://www.w3.org/2005/08/addressing"><s:Header><w:MessageID>urn:uuid:synthetic-request</w:MessageID></s:Header><s:Body/></s:Envelope>';
    final fault = File(
      'test/fixtures/td03-action-not-supported.xml',
    ).readAsStringSync();
    final result = DmpNativeTd03.read(request, DmpTd02Reply(500, fault));
    expect(result.status, 'ns2:ActionNotSupported');
    expect(
      result.detail,
      'Action urn:hl7-org:v3:setAuthorization not supported',
    );
    expect(result.status, isNot('DMPOk'));
    expect(
      () => DmpNativeTd03.read(
        request,
        DmpTd02Reply(
          500,
          fault.replaceAll(
            'urn:uuid:synthetic-request',
            'urn:uuid:another-request',
          ),
        ),
      ),
      throwsStateError,
    );
  });
  test('la commande de vérification traverse le protocole natif réel', () async {
    // Synthetic stdio peer: no CPS, certificate, network or application data.
    final bridge = DmpProcessBridge(
      executable: '/usr/bin/python3',
      arguments: [
        '-u',
        '-c',
        "import sys,base64\nfor line in sys.stdin:\n p=line.rstrip('\\n').split('\\t')\n print(p[0]+'\\tOK\\toperation='+base64.b64encode(p[1].encode()).decode(),flush=True)\n if p[1]=='close': break",
      ],
    );
    addTearDown(bridge.close);
    final reply = await bridge.call(
      DocumentDmpNativePorts.authorizationRecheckOperation,
      {'id': 'SYNTHETIC'},
    );
    expect(
      reply['operation'],
      DocumentDmpNativePorts.authorizationRecheckOperation,
    );
    final native = File(
      'assets/dmp_native/DmpNativeBridge.java',
    ).readAsStringSync();
    expect(
      native,
      contains(
        'case "authorization", "${DocumentDmpNativePorts.authorizationRecheckOperation}" ->',
      ),
    );
  });
  testWidgets('aucune présélection même après un accord, Oui/Non exclusifs', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: PatientConsultationConsentDialog(
            patient: 'SYNTHETIQUE',
            professional: 'TEST',
            previous: {'granted': true},
          ),
        ),
      ),
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Enregistrer la réponse'),
          )
          .onPressed,
      isNull,
    );
    await tester.tap(find.widgetWithText(ChoiceChip, 'Non'));
    await tester.pump();
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Non'))
          .selected,
      true,
    );
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Oui'))
          .selected,
      false,
    );
    expect(
      tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, 'Enregistrer la réponse'),
          )
          .onPressed,
      isNotNull,
    );
    await tester.tap(find.widgetWithText(ChoiceChip, 'Oui'));
    await tester.pump();
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Non'))
          .selected,
      false,
    );
  });
}

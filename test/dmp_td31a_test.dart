import 'package:abak_desktop_companion/features/dmp_dv1_access/consultation_recipe.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
import 'dv1_consultation_consent_test.dart' show SerializationOnly;
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/td31a.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/td31b.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/access_context.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/contracts.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/access_service.dart';
import 'package:abak_desktop_companion/features/dmp_td02/td02_result.dart';

void main() {
  const ins = '123456789012345';
  const uuid = 'urn:uuid:11111111-1111-4111-8111-111111111111';
  const soap = 'http://www.w3.org/2003/05/soap-envelope';
  const wsa = 'http://www.w3.org/2005/08/addressing';
  const rim = DmpNativeTd31b.rim;
  const criteria = Dv1DocumentCriteria(typeCode: '11506-3');
  final now = DateTime.utc(2026, 10, 29);
  String build([Dv1DocumentCriteria filters = criteria]) =>
      DmpNativeTd31a.build(
        Dv1AccessContext(
          professional: '12345678901',
          structure: '123456789',
          sector: 'SA07',
          ins: ins,
          patientLabel: 'PATIENT SYNTHETIQUE',
          source: 'fixture',
          scenario: 'PRE_CONS_RECH',
          confirmedAt: now,
          birthDate: '1980-01-01',
        ),
        DmpSession(
          id: 'TEST',
          professional: '12345678901',
          authority: '2.25.1',
          structure: '123456789',
          certificateHash: '',
          contextHash: '',
          issuedAt: now,
          expiresAt: now.add(const Duration(minutes: 2)),
        ),
        SerializationOnly(),
        now,
        filters,
      );
  String doc({
    String patient = ins,
    String status = Dv1DocumentCriteria.approved,
    String type = '11506-3',
  }) =>
      '<ExtrinsicObject xmlns="$rim" id="$uuid" status="$status" mimeType="text/xml">'
      '<Name><LocalizedString value="Rapport synthétique"/></Name>'
      '<ExternalIdentifier identificationScheme="${DmpNativeTd31a.patientScheme}" value="$patient^^^&amp;1.2.250.1.213.1.4.10&amp;ISO^NH"/>'
      '<ExternalIdentifier identificationScheme="${DmpNativeTd31a.uniqueScheme}" value="2.25.123"/>'
      '<Classification classificationScheme="${DmpNativeTd31a.typeScheme}" nodeRepresentation="$type">'
      '<Slot name="codingScheme"><ValueList><Value>2.16.840.1.113883.6.1</Value></ValueList></Slot>'
      '<Name><LocalizedString value="Note de suivi"/></Name></Classification></ExtrinsicObject>';
  String response(String request, String objects) {
    final id = XmlDocument.parse(
      request,
    ).findAllElements('MessageID', namespace: wsa).single.innerText;
    return '<s:Envelope xmlns:s="$soap" xmlns:w="$wsa"><s:Header><w:RelatesTo>$id</w:RelatesTo><w:Action>${DmpNativeTd31b.action}Response</w:Action></s:Header><s:Body>'
        '<AdhocQueryResponse xmlns="${DmpNativeTd31b.query}" status="urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success"><RegistryObjectList xmlns="$rim">$objects</RegistryObjectList></AdhocQueryResponse></s:Body></s:Envelope>';
  }

  test(
    'GetDocuments exact identifiers accepts all three statuses and rejects unrelated identities',
    () {
      const filters = Dv1DocumentCriteria(
        uniqueIds: ['2.25.123', '2.25.456'],
        archived: true,
        deprecated: true,
      );
      final q = build(filters);
      final xml = XmlDocument.parse(q);
      expect(
        xml
            .findAllElements('AdhocQuery', namespace: rim)
            .single
            .getAttribute('id'),
        DmpNativeTd31b.getDocuments,
      );
      final slots = xml.findAllElements('Slot', namespace: rim).toList();
      expect(slots.length, 1);
      expect(slots.single.getAttribute('name'), r'$XDSDocumentEntryUniqueId');
      expect(slots.single.innerText, "('2.25.123','2.25.456')");
      expect(q, contains('$ins^^^&amp;1.2.250.1.213.1.4.10&amp;ISO^NH'));
      for (final status in filters.statuses) {
        final rows = DmpNativeTd31a.read(
          q,
          DmpTd02Reply(200, response(q, doc(status: status))),
          ins,
          filters,
        );
        expect(rows.single['status'], status);
      }
      for (final bad in [
        doc(patient: '987654321012345'),
        doc().replaceAll('1.2.250.1.213.1.4.10', '1.2.250.1.213.1.4.11'),
        doc().replaceAll('2.25.123', '2.25.999'),
      ]) {
        expect(
          () => DmpNativeTd31a.read(
            q,
            DmpTd02Reply(200, response(q, bad)),
            ins,
            filters,
          ),
          throwsStateError,
        );
      }
      expect(
        DmpNativeTd31a.read(
          q,
          DmpTd02Reply(200, response(q, '')),
          ins,
          filters,
        ),
        isEmpty,
      );
      final fixture = Platform.environment['ABAK_IDENTIFIER_QUERY'];
      if (fixture != null) File(fixture).writeAsStringSync(q);
    },
  );
  test(
    'exact identifier query rejects injection, duplicate and oversized lists',
    () {
      for (final ids in [
        <String>["2.25.1')"],
        ['2.25.1', '2.25.1'],
        ['2.25.1', '2.25.2', '2.25.3', '2.25.4', '2.25.5'],
      ]) {
        expect(
          () => build(
            Dv1DocumentCriteria(
              uniqueIds: ids,
              archived: true,
              deprecated: true,
            ),
          ),
          throwsStateError,
        );
      }
    },
  );
  test(
    'recipe uses editor-supplied Corinne identity and rejects previous patient',
    () {
      Dv1AccessContext recipe(String identity, String birth) =>
          Dv1AccessContext(
            professional: '12345678901',
            structure: '123456789',
            sector: 'SA07',
            ins: identity,
            patientLabel: 'CORINNE DUPRE',
            source: Dv1ConsultationRecipe.source,
            scenario: 'PRE_CONS_RECH',
            confirmedAt: now,
            birthDate: birth,
          );
      Dv1ConsultationRecipe.check(recipe('148115530271002', '1948-11-09'));
      expect(
        () => Dv1ConsultationRecipe.check(
          recipe('187012425258307', '1987-01-01'),
        ),
        throwsStateError,
      );
      expect(
        () => Dv1ConsultationRecipe.check(
          recipe('148115530271002', '1987-01-01'),
        ),
        throwsStateError,
      );
    },
  );
  test(
    'FindDocuments LeafClass: patient CX NH, statuses and coded type, no mutation',
    () {
      final request = build(
        const Dv1DocumentCriteria(
          archived: true,
          deprecated: true,
          typeCode: '11506-3',
        ),
      );
      final xml = XmlDocument.parse(request);
      expect(
        xml
            .findAllElements('AdhocQuery', namespace: rim)
            .single
            .getAttribute('id'),
        DmpNativeTd31a.findDocuments,
      );
      final slots = {
        for (final e in xml.findAllElements('Slot', namespace: rim))
          e.getAttribute('name'): e.innerText,
      };
      expect(
        slots[r'$XDSDocumentEntryPatientId'],
        "'${DmpNativeTd31a.patientId(ins)}'",
      );
      expect(
        slots[r'$XDSDocumentEntryTypeCode'],
        "('11506-3^^2.16.840.1.113883.6.1')",
      );
      expect(
        slots[r'$XDSDocumentEntryStatus'],
        contains(Dv1DocumentCriteria.archivedStatus),
      );
      expect(request, isNot(contains('setAuthorization')));
      expect(request, isNot(contains('SubmitObjectsRequest')));
      File(
        '/private/tmp/abak-finddocuments-synthetic.xml',
      ).writeAsStringSync(request);
      final simple = XmlDocument.parse(build(const Dv1DocumentCriteria()));
      expect(simple.findAllElements('Slot', namespace: rim).length, 2);
    },
  );
  test(
    'patient CX accepts only exact identity with optional valid dated suffix',
    () {
      final base = DmpNativeTd31a.patientId(ins);
      expect(DmpNativeTd31a.matchesPatientId(base, ins), isTrue);
      expect(DmpNativeTd31a.matchesPatientId('$base^^20260820', ins), isTrue);
      expect(DmpNativeTd31a.matchesPatientId('$base^^20240229', ins), isTrue);
      for (final invalid in [
        base.replaceFirst(ins, '987654321012345'),
        base.replaceFirst('1.2.250.1.213.1.4.10', '1.2.250.1.213.1.4.11'),
        base.replaceFirst('&ISO', '&OTHER'),
        base.replaceFirst('^NH', '^PI'),
        '$base^^20260820^extra',
        '$base^facility^20260820',
        '$base^^20260229',
        '$base^^20261301',
        '$base^^20260800',
        '$base^^00000101',
        '$base^^202608',
        '$base^^garbage',
        '$base^^',
        '$base^',
        '$base trailing',
      ]) {
        expect(
          DmpNativeTd31a.matchesPatientId(invalid, ins),
          isFalse,
          reason: invalid,
        );
      }
      final q = build();
      final dated = response(
        q,
        doc(),
      ).replaceAll('&amp;ISO^NH', '&amp;ISO^NH^^20260820');
      expect(
        DmpNativeTd31a.read(q, DmpTd02Reply(200, dated), ins, criteria).length,
        1,
      );
      for (final invalid in [
        dated.replaceAll('1.2.250.1.213.1.4.10', '1.2.250.1.213.1.4.11'),
        dated.replaceAll(ins, '987654321012345'),
        dated.replaceAll('20260820', '20260230'),
      ]) {
        expect(
          () =>
              DmpNativeTd31a.read(q, DmpTd02Reply(200, invalid), ins, criteria),
          throwsStateError,
        );
      }
    },
  );

  test('rejects query injection in type and invalid coding scheme', () {
    expect(
      () => build(const Dv1DocumentCriteria(typeCode: "x')")),
      throwsStateError,
    );
    expect(
      () => build(
        const Dv1DocumentCriteria(typeCode: '11506-3', typeSystem: 'LOINC'),
      ),
      throwsStateError,
    );
  });
  test('reads correlated metadata and distinguishes empty results', () {
    final q = build();
    final rows = DmpNativeTd31a.read(
      q,
      DmpTd02Reply(200, response(q, doc())),
      ins,
      criteria,
    );
    expect(rows.single['title'], 'Rapport synthétique');
    expect(rows.single['uniqueId'], '2.25.123');
    expect(
      DmpNativeTd31a.read(q, DmpTd02Reply(200, response(q, '')), ins, criteria),
      isEmpty,
    );
  });
  test(
    'rejects other patient, status, type, duplicate, uncorrelated or failed response',
    () {
      final q = build();
      for (final objects in [
        doc(patient: '987654321012345'),
        doc(status: Dv1DocumentCriteria.deprecatedStatus),
        doc(type: '34133-9'),
        doc() + doc(),
        '<RegistryError xmlns="$rim"/>',
      ]) {
        expect(
          () => DmpNativeTd31a.read(
            q,
            DmpTd02Reply(200, response(q, objects)),
            ins,
            criteria,
          ),
          throwsA(anything),
        );
      }
      for (final xml in [
        response(q, doc()).replaceAll(
          'ResponseStatusType:Success',
          'ResponseStatusType:Failure',
        ),
        response(
          q,
          doc(),
        ).replaceAll('RegistryStoredQueryResponse', 'unexpected'),
        response(build(), doc()),
      ]) {
        expect(
          () => DmpNativeTd31a.read(q, DmpTd02Reply(200, xml), ins, criteria),
          throwsA(anything),
        );
      }
      expect(
        () => DmpNativeTd31a.read(
          q,
          DmpTd02Reply(500, response(q, doc())),
          ins,
          criteria,
        ),
        throwsStateError,
      );
    },
  );
  test(
    'consultation requires both recorded agreement and active valid DMP right',
    () {
      for (final decision in [
        null,
        <String, dynamic>{'granted': false},
        <String, dynamic>{'granted': true, 'pendingWithdrawal': true},
      ]) {
        expect(
          () => Dv1AccessService.requireSearchConsent(decision),
          throwsStateError,
        );
      }
      Dv1AccessService.requireSearchConsent({
        'granted': true,
        'pendingWithdrawal': false,
      });
      for (final right in ConsultationRight.values) {
        final result = Td02Result(DmpState.active, right: right);
        if (right == ConsultationRight.valid) {
          Dv1AccessService.requireSearchRight(result);
        } else {
          expect(
            () => Dv1AccessService.requireSearchRight(result),
            throwsStateError,
          );
        }
      }
      expect(
        () => Dv1AccessService.requireSearchRight(
          const Td02Result(DmpState.closed, right: ConsultationRight.valid),
        ),
        throwsStateError,
      );
    },
  );
}

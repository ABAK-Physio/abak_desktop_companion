import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/td31_submission.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/td31a.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/td31b.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/contracts.dart';

const ins = '123456789012345';
const soap = 'http://www.w3.org/2003/05/soap-envelope';
const wsa = 'http://www.w3.org/2005/08/addressing';
const rim = DmpNativeTd31b.rim;
const envelope =
    '<s:Envelope xmlns:s="$soap" xmlns:w="$wsa"><s:Header><w:MessageID>urn:uuid:initial</w:MessageID><w:To>synthetic</w:To><w:Action>synthetic</w:Action></s:Header><s:Body/></s:Envelope>';
String id(int n) =>
    'urn:uuid:00000000-0000-4000-8000-${n.toString().padLeft(12, '0')}';
String slot(String key, String value) =>
    '<Slot name="$key"><ValueList><Value>$value</Value></ValueList></Slot>';
String lot(int n, {String time = '20251029120000', String patient = ins}) =>
    '<RegistryPackage id="${id(n)}" status="${Dv1DocumentCriteria.approved}">${slot('submissionTime', time)}'
    '<ExternalIdentifier identificationScheme="${DmpSubmissionSearch.patientScheme}" value="$patient^^^&amp;1.2.250.1.213.1.4.10&amp;ISO^NH"/></RegistryPackage>';
String association(
  int n,
  int source,
  int target, {
  String type = 'urn:oasis:names:tc:ebxml-regrep:AssociationType:HasMember',
}) =>
    '<Association id="${id(n)}" sourceObject="${id(source)}" targetObject="${id(target)}" associationType="$type">${slot('SubmissionSetStatus', 'Original')}</Association>';
String document(int n, {String patient = ins}) =>
    '<ExtrinsicObject id="${id(n)}" status="${Dv1DocumentCriteria.approved}" mimeType="text/xml">'
    '<Name><LocalizedString value="Test"/></Name>${slot('creationTime', '20000101000000')}'
    '<ExternalIdentifier identificationScheme="${DmpNativeTd31a.patientScheme}" value="$patient^^^&amp;1.2.250.1.213.1.4.10&amp;ISO^NH^^20260820"/>'
    '<ExternalIdentifier identificationScheme="${DmpNativeTd31a.uniqueScheme}" value="2.25.$n"/>'
    '<Classification classificationScheme="${DmpNativeTd31a.typeScheme}" nodeRepresentation="11506-3">${slot('codingScheme', '2.16.840.1.113883.6.1')}</Classification></ExtrinsicObject>';
DmpTd02Reply reply(
  String request,
  String objects, {
  String status = 'Success',
  bool correlated = true,
}) {
  final message = XmlDocument.parse(
    request,
  ).findAllElements('MessageID', namespace: wsa).single.innerText;
  return DmpTd02Reply(
    200,
    '<s:Envelope xmlns:s="$soap" xmlns:w="$wsa"><s:Header><w:RelatesTo>${correlated ? message : 'wrong'}</w:RelatesTo><w:Action>${DmpNativeTd31b.action}Response</w:Action></s:Header><s:Body><AdhocQueryResponse xmlns="${DmpNativeTd31b.query}" status="urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:$status"><RegistryObjectList xmlns="$rim">$objects</RegistryObjectList></AdhocQueryResponse></s:Body></s:Envelope>',
  );
}

void main() {
  final period = Dv1SubmissionPeriod.days('2025-10-29', '2025-10-29');
  Future<Map<String, dynamic>> run({
    String? lots,
    String? links,
    String? docs,
    bool correlated = true,
    String status = 'Success',
    List<String>? stages,
  }) => DmpSubmissionSearch().run(
    envelope: envelope,
    ins: ins,
    period: period,
    exchange: (stage, request) async {
      stages?.add(stage);
      return reply(
        request,
        switch (stage) {
          'submissions' => lots ?? lot(1),
          'associations' => links ?? association(3, 1, 2),
          _ => docs ?? document(2),
        },
        correlated: correlated,
        status: status,
      );
    },
  );
  test(
    'calendar dates validated, inclusive last day converted to exclusive next midnight',
    () {
      expect(
        () => Dv1SubmissionPeriod.days('2025-02-30', '2025-03-01'),
        throwsStateError,
      );
      expect(
        () => Dv1SubmissionPeriod.days('29/10/2025', '2025-10-29'),
        throwsStateError,
      );
      expect(
        () => Dv1SubmissionPeriod.days('2025-10-30', '2025-10-29').check(),
        throwsStateError,
      );
      expect(period.from, DateTime(2025, 10, 29).toUtc());
      expect(period.to, DateTime(2025, 10, 30).toUtc());
      final dst = Dv1SubmissionPeriod.days('2025-10-26', '2025-10-26');
      expect(dst.to, DateTime(2025, 10, 27).toUtc());
    },
  );
  test(
    'three read-only stages, deposit date differs from clinical date, new correlation IDs',
    () async {
      final messages = <String>{};
      final stages = <String>[];
      final found = await DmpSubmissionSearch().run(
        envelope: envelope,
        ins: ins,
        period: period,
        exchange: (stage, request) async {
          stages.add(stage);
          expect(
            messages.add(
              XmlDocument.parse(
                request,
              ).findAllElements('MessageID', namespace: wsa).single.innerText,
            ),
            isTrue,
          );
          expect(request, isNot(contains('CreationTimeFrom')));
          File('/private/tmp/abak-sub-$stage.xml').writeAsStringSync(request);
          if (stage == 'submissions') {
            expect(request, contains(r'$XDSSubmissionSetSubmissionTimeFrom'));
            expect(request, contains(Dv1SubmissionPeriod.stamp(period.from)));
            expect(request, contains(Dv1SubmissionPeriod.stamp(period.to)));
            final slots = XmlDocument.parse(
              request,
            ).findAllElements('Slot', namespace: rim);
            for (final bound in ['From', 'To']) {
              final value = slots
                  .singleWhere(
                    (s) =>
                        s.getAttribute('name') ==
                        r'$XDSSubmissionSetSubmissionTime' + bound,
                  )
                  .findAllElements('Value', namespace: rim)
                  .single
                  .innerText;
              expect(value, matches(RegExp(r'^\d{14}$')));
              expect(value, isNot(contains("'")));
            }
          }
          return reply(
            request,
            stage == 'submissions'
                ? lot(1)
                : stage == 'associations'
                ? association(3, 1, 2)
                : document(2),
          );
        },
      );
      expect(stages, ['submissions', 'associations', 'documents']);
      final doc = (found['documents'] as List).single as Map;
      expect(doc['submissionTime'], '20251029120000');
      expect(doc['creationTime'], '20000101000000');
      expect(found['unreturnedDocumentIds'], isEmpty);
    },
  );
  test(
    'only explicit Approved signs of the same lot explain absent signatures',
    () async {
      String signs(int lot, {String status = Dv1DocumentCriteria.approved}) =>
          '<Association id="${id(5)}" sourceObject="${id(4)}" targetObject="${id(lot)}" status="$status" associationType="urn:ihe:iti:2007:AssociationType:signs"/>';
      final links = association(3, 1, 2) + association(6, 1, 4);
      final ok = await run(links: links + signs(1));
      expect(ok['documents'], hasLength(1));
      expect(ok['unreturnedDocumentIds'], isEmpty);
      expect(ok['omittedSignatureIds'], [id(4)]);
      expect(ok['unreturnedMemberIds'], [id(4)]);
      for (final bad in [
        links,
        links + signs(1, status: Dv1DocumentCriteria.deprecatedStatus),
      ]) {
        final result = await run(links: bad);
        expect(result['unreturnedDocumentIds'], [id(4)]);
        expect(result['omittedSignatureIds'], isEmpty);
      }
      final wrongLot = await run(
        lots: lot(1) + lot(7),
        links: links + signs(7),
      );
      expect(wrongLot['unreturnedDocumentIds'], [id(4)]);
      final onlySignature = await run(
        links: association(6, 1, 4) + signs(1),
        docs: '',
      );
      expect(
        onlySignature['documents'],
        isEmpty,
      ); // Cannot validate an empty search.
    },
  );
  test('empty lots stops without further requests', () async {
    final stages = <String>[];
    final found = await run(lots: '', stages: stages);
    expect(stages, ['submissions']);
    expect(found['documents'], isEmpty);
  });
  test(
    'wrong patient, authority, out-of-range and duplicate lots rejected',
    () async {
      for (final bad in [
        lot(1, patient: '999999999999999'),
        lot(1).replaceAll('1.4.10', '1.4.9'),
        lot(1, time: '20251030120000'),
        lot(1, time: '20250230120000'),
        lot(1) + lot(1),
      ]) {
        await expectLater(run(lots: bad), throwsA(anything));
      }
      await expectLater(
        run(lots: lot(1, time: Dv1SubmissionPeriod.stamp(period.to))),
        throwsStateError,
      );
      expect(
        (await run(
          lots: lot(1, time: Dv1SubmissionPeriod.stamp(period.from)),
        ))['documents'],
        hasLength(1),
      );
    },
  );
  test('foreign associations/documents and wrong patient rejected', () async {
    await expectLater(run(links: association(3, 9, 2)), throwsStateError);
    await expectLater(run(docs: document(9)), throwsStateError);
    await expectLater(
      run(docs: document(2, patient: '999999999999999')),
      throwsStateError,
    );
    expect(
      (await run(
        links: association(
          3,
          1,
          2,
          type: 'urn:ihe:iti:2010:AssociationType:UpdateAvailabilityStatus',
        ),
      ))['documents'],
      isEmpty,
    );
  });
  test(
    'correlation and partial success rejected, missing documents exposed',
    () async {
      await expectLater(run(correlated: false), throwsStateError);
      await expectLater(run(status: 'PartialSuccess'), throwsStateError);
      final found = await run(docs: '');
      expect(found['documents'], isEmpty);
      expect(found['unreturnedDocumentIds'], [id(2)]);
    },
  );
  test(
    'batching preserves all linked documents and deduplicates memberships',
    () async {
      final stages = <String>[];
      final found =
          await DmpSubmissionSearch(associationBatch: 1, documentBatch: 1).run(
            envelope: envelope,
            ins: ins,
            period: period,
            exchange: (stage, request) async {
              stages.add(stage);
              if (stage == 'submissions') {
                return reply(request, lot(1) + lot(4));
              }
              if (stage == 'associations') {
                return reply(
                  request,
                  request.contains(id(1))
                      ? association(3, 1, 2)
                      : association(5, 4, 2) + association(6, 4, 7),
                );
              }
              return reply(
                request,
                request.contains(id(2)) ? document(2) : document(7),
              );
            },
          );
      expect(stages, [
        'submissions',
        'associations',
        'associations',
        'documents',
        'documents',
      ]);
      expect(found['documents'], hasLength(2));
      expect(
        ((found['documents'] as List).first as Map)['submissionSets'],
        '${id(1)}, ${id(4)}',
      );
      expect(
        DmpSubmissionSearch.batches(
          List.generate(177, id),
          88,
        ).map((e) => e.length),
        [88, 88, 1],
      );
    },
  );
  test('failure in last stage does not return a success or retry', () async {
    var calls = 0;
    await expectLater(
      DmpSubmissionSearch().run(
        envelope: envelope,
        ins: ins,
        period: period,
        exchange: (stage, request) async {
          calls++;
          if (stage == 'documents') throw StateError('transport failure');
          return reply(
            request,
            stage == 'submissions' ? lot(1) : association(3, 1, 2),
          );
        },
      ),
      throwsStateError,
    );
    expect(calls, 3);
  });
}

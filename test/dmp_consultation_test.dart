import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/consulted_document.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/consultation_viewer.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/td32.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/td31_submission.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/td31b.dart';

const ins = '148115530271002';
const envelope =
    '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:To>old</a:To><a:Action>old</a:Action><a:MessageID>urn:uuid:11111111-1111-4111-8111-111111111111</a:MessageID></s:Header><s:Body/></s:Envelope>';
String cda({
  String patient = ins,
  String authority = '1.2.250.1.213.1.4.10',
  String? body,
}) =>
    '<ClinicalDocument xmlns="urn:hl7-org:v3"><id root="2.25.1"/><title>Compte rendu de test</title><recordTarget><patientRole><id root="$authority" extension="$patient"/><patient><name><given>Corinne</given><family>DUPRE</family></name></patient></patientRole></recordTarget><author><assignedAuthor><id root="1.2.3" extension="auteur"/></assignedAuthor></author><component>${body ?? '<nonXMLBody><text mediaType="text/plain" representation="B64">${base64Encode(utf8.encode('Contenu témoin')).replaceAll('=', '')}</text></nonXMLBody>'}</component></ClinicalDocument>';
Map<String, String> metadata(Uint8List data) => {
  'uniqueId': '2.25.1',
  'repositoryUniqueId': '1.2.3',
  'entryUUID': 'urn:uuid:11111111-1111-4111-8111-111111111111',
  'mimeType': 'text/xml',
  'size': '${data.length}',
  'hash': sha1.convert(data).toString(),
  'title': 'Témoin',
  'confidentiality': 'INVISIBLE_PATIENT|INVISIBLE_REPRESENTANTS_LEGAUX',
};
String response(
  String request,
  String payload, {
  String? uniqueId,
  String status = 'Success',
}) {
  final id = RegExp(
    r'<a:MessageID>(.*?)</a:MessageID>',
  ).firstMatch(request)!.group(1);
  return '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://www.w3.org/2005/08/addressing"><s:Header><a:Action>${DmpNativeTd32.action}Response</a:Action><a:RelatesTo>$id</a:RelatesTo></s:Header><s:Body><RetrieveDocumentSetResponse xmlns="${DmpNativeTd32.ns}"><rs:RegistryResponse xmlns:rs="${DmpNativeTd31b.rs}" status="urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:$status"/><DocumentResponse><RepositoryUniqueId>1.2.3</RepositoryUniqueId><DocumentUniqueId>${uniqueId ?? '2.25.1'}</DocumentUniqueId><mimeType>text/xml</mimeType><Document>$payload</Document></DocumentResponse></RetrieveDocumentSetResponse></s:Body></s:Envelope>';
}

void main() {
  final bytes = Uint8List.fromList(utf8.encode(cda()));
  final meta = metadata(bytes);
  final request = DmpNativeTd32.build(envelope, meta);
  test('one selected document, fresh request, no deposit', () {
    expect(request, contains('RetrieveDocumentSetRequest'));
    expect(request, contains(DmpNativeTd32.endpoint));
    expect(request, isNot(contains('ProvideAndRegister')));
    File('/private/tmp/abak-cons-retrieve.xml').writeAsStringSync(request);
    File('/private/tmp/abak-cons-metadata.xml').writeAsStringSync(
      DmpSubmissionSearch.query(envelope, DmpNativeTd31b.getDocuments, {
        r'$XDSDocumentEntryEntryUUID': DmpSubmissionSearch.ids([
          meta['entryUUID']!,
        ]),
      }),
    );
  });
  test('inline base64, exact IDs and SHA1, CDA header and text', () {
    final data = DmpNativeTd32.read(
      request,
      200,
      '',
      Uint8List.fromList(utf8.encode(response(request, base64Encode(bytes)))),
      meta,
    );
    final d = ConsultedDocument.parse(data, meta, ins);
    expect(d.header, contains('Auteur'));
    expect(d.header, contains('DUPRE'));
    expect(utf8.decode(d.payload!), 'Contenu témoin');
    expect(d.warnings.length, 2);
    final payload = d.payload!;
    d.dispose();
    expect(payload.every((v) => v == 0), true);
    expect(d.cda, null);
    expect(d.header, '');
  });
  test(
    'MTOM bytes preserved, reference decoded, no UTF8 conversion of whole body',
    () {
      final soap = response(
        request,
        '<x:Include xmlns:x="http://www.w3.org/2004/08/xop/include" href="cid:doc%40test"/>',
      );
      final raw = Uint8List.fromList([
        ...utf8.encode(
          '--b\r\nContent-Type: application/xop+xml\r\nContent-ID: <soap>\r\n\r\n$soap\r\n--b\r\nContent-Type: text/xml\r\nContent-ID: <doc@test>\r\n\r\n',
        ),
        ...bytes,
        ...utf8.encode('\r\n--b--\r\n'),
      ]);
      expect(
        DmpNativeTd32.read(
          request,
          200,
          'Content-Type: multipart/related; boundary="b"; start="<soap>"',
          raw,
          meta,
        ),
        bytes,
      );
    },
  );
  test('reject correlation, wrong document, partial and HTTP errors', () {
    final good = response(request, base64Encode(bytes));
    for (final bad in [
      good.replaceFirst('RelatesTo>', 'RelatesTo>wrong'),
      response(request, base64Encode(bytes), uniqueId: '2.25.9'),
      response(request, base64Encode(bytes), status: 'PartialSuccess'),
      good.replaceFirst('1.2.3</Repository', '1.2.4</Repository'),
    ]) {
      expect(
        () => DmpNativeTd32.read(
          request,
          200,
          '',
          Uint8List.fromList(utf8.encode(bad)),
          meta,
        ),
        throwsA(anything),
      );
    }
    expect(
      () => DmpNativeTd32.read(request, 500, '', bytes, meta),
      throwsStateError,
    );
  });
  test('reject altered payload or size', () {
    final raw = Uint8List.fromList(
      utf8.encode(response(request, base64Encode(bytes))),
    );
    expect(
      () => DmpNativeTd32.read(request, 200, '', raw, {
        ...meta,
        'hash': '0' * 40,
      }),
      throwsStateError,
    );
    expect(
      () => DmpNativeTd32.read(request, 200, '', raw, {...meta, 'size': '1'}),
      throwsStateError,
    );
  });
  test('reject wrong INS, authority, DTD and external CDA body', () {
    for (final xml in [
      cda(patient: '248115530271002'),
      cda(authority: '1.2.3'),
      '<!DOCTYPE ClinicalDocument SYSTEM "file:///etc/passwd">${cda()}',
      cda(
        body:
            '<nonXMLBody><text mediaType="text/plain"><reference value="https://example.invalid"/></text></nonXMLBody>',
      ),
    ]) {
      expect(
        () => ConsultedDocument.parse(
          Uint8List.fromList(utf8.encode(xml)),
          meta,
          ins,
        ),
        throwsA(anything),
      );
    }
  });
  test('structured narrative and PDF copy prioritized', () {
    final body =
        '<structuredBody><component><section><title>Résultats</title><text><paragraph>Normal</paragraph></text></section></component><component><section><code code="55108-5" codeSystem="2.16.840.1.113883.6.1"/><title>Copie</title><text>PDF</text><entry><observationMedia><value mediaType="application/pdf" representation="B64">JVBERi0=</value></observationMedia></entry></section></component></structuredBody>';
    final d = ConsultedDocument.parse(
      Uint8List.fromList(utf8.encode(cda(body: body))),
      meta,
      ins,
    );
    expect(d.mediaType, 'application/pdf');
    expect(ascii.decode(d.payload!), '%PDF-');
    expect(d.sections.length, 2);
    d.dispose();
  });
  test('unsupported embedded narrative cannot produce a false success', () {
    final body =
        '<structuredBody><component><section><title>Image</title><text><renderMultiMedia referencedObject="image"/></text></section></component></structuredBody>';
    expect(
      () => ConsultedDocument.parse(
        Uint8List.fromList(utf8.encode(cda(body: body))),
        meta,
        ins,
      ),
      throwsStateError,
    );
  });
  testWidgets(
    'success requires content and opening CDA header; close available',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1200, 2000));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final d = ConsultedDocument.parse(bytes, meta, ins);
      await tester.pumpWidget(
        MaterialApp(home: DmpConsultationViewer(document: d)),
      );
      await tester.pumpAndSettle();
      final button = find.widgetWithText(
        FilledButton,
        'Contenu et en-tête affichés — terminer le test',
      );
      expect(tester.widget<FilledButton>(button).onPressed, null);
      await tester.tap(
        find.text('En-tête CDA — patient, auteur, dates et contexte'),
      );
      await tester.pumpAndSettle();
      expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
      await tester.pumpWidget(const SizedBox());
      d.dispose();
    },
  );
}

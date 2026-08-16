import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';

import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_contexte_bam_builder.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_contexte_lps_builder.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_message_id_builder.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ws_ins2_envelope_builder.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_fr_insi_ws_ins2_request_builder.dart';

void main() {
  const bodyBuilder = PatientFrInsiWsIns2RequestBuilder();
  const contexteLpsBuilder = PatientFrInsiContexteLpsBuilder();
  const contexteBamBuilder = PatientFrInsiContexteBamBuilder();
  const messageIdBuilder = PatientFrInsiMessageIdBuilder();
  const envelopeBuilder = PatientFrInsiWsIns2EnvelopeBuilder();

  test('build creates WS_INS2 SOAP envelope without Security', () {
    final contexteBamXml = contexteBamBuilder.build(
      id: 'bam-id',
      time: DateTime.utc(2026, 8, 15, 14, 0),
      emitter: '899900063480',
    );

    final messageIdXml = messageIdBuilder.build(
      'e451e702-85aa-4c55-a083-7f02da22cc40',
    );

    final contexteLpsXml = contexteLpsBuilder.build(
      id: 'lps-id',
      time: DateTime.utc(2026, 8, 15, 14, 0),
      emitter: '899900063480',
      idam: 'NumAutorisation',
      idamReference: '4',
      lpsVersion: '01.00',
      instance: 'test-instance',
      name: 'ABAK',
    );

    final bodyXml = bodyBuilder.buildBody(
      birthLastName: 'ADRDEUX',
      firstNames: const ['LAURENT'],
      sexCode: 'M',
      birthDate: '1981-01-01',
    );

    final xml = envelopeBuilder.build(
      contexteLpsXml: contexteLpsXml,
      messageIdXml: messageIdXml,
      contexteBamXml: contexteBamXml,
      bodyXml: bodyXml,
    );

    final document = XmlDocument.parse(xml);
    final envelope = document.rootElement;

    expect(envelope.name.local, 'Envelope');
    expect(
      envelope.name.namespaceUri,
      PatientFrInsiWsIns2EnvelopeBuilder.soapNamespace,
    );

    final header = envelope.descendants
        .whereType<XmlElement>()
        .singleWhere((element) => element.name.local == 'Header');

    expect(
      header.descendants
          .whereType<XmlElement>()
          .where((element) => element.name.local == 'ContexteBAM'),
      hasLength(1),
    );

    expect(
      header.descendants
          .whereType<XmlElement>()
          .where((element) => element.name.local == 'ContexteLPS'),
      hasLength(1),
    );

    expect(
      header.descendants
          .whereType<XmlElement>()
          .where((element) => element.name.local == 'MessageID'),
      hasLength(1),
    );

    final action = header.descendants
        .whereType<XmlElement>()
        .singleWhere((element) => element.name.local == 'Action');

    expect(
      action.innerText,
      PatientFrInsiWsIns2EnvelopeBuilder.action,
    );

    final body = envelope.descendants
        .whereType<XmlElement>()
        .singleWhere((element) => element.name.local == 'Body');

    final request = body.descendants
        .whereType<XmlElement>()
        .singleWhere((element) => element.name.local == 'RECSANSVITALE');

    expect(
      request.descendants
          .whereType<XmlElement>()
          .singleWhere((element) => element.name.local == 'NomNaissance')
          .innerText,
      'ADRDEUX',
    );

    expect(
      request.descendants
          .whereType<XmlElement>()
          .singleWhere((element) => element.name.local == 'Prenom')
          .innerText,
      'LAURENT',
    );

    expect(
      document.descendants
          .whereType<XmlElement>()
          .where((element) => element.name.local == 'Security'),
      isEmpty,
    );
  });
}
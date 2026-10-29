import 'dart:io';
import 'package:abak_desktop_companion/features/dmp_dv1_access/depublication.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:xml/xml.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/td33c.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/contracts.dart';

void main() {
  test(
    'durable reservation prevents repeated and concurrent updates',
    () async {
      final dir = await Directory.systemTemp.createTemp(
        'abak-delete-reservation-',
      );
      addTearDown(() => dir.delete(recursive: true));
      final file = File('${dir.path}/target.json');
      await Dv1Depublication.reserveFile(file, {'state': 'reserved'});
      await expectLater(
        Dv1Depublication.reserveFile(File(file.path), {'state': 'retry'}),
        throwsA(isA<FileSystemException>()),
      );
      expect(await file.readAsString(), contains('reserved'));
      final competing = File('${dir.path}/concurrent.json');
      final outcomes = await Future.wait([
        for (var i = 0; i < 2; i++)
          Dv1Depublication.reserveFile(competing, {
            'attempt': i,
          }).then((_) => true).catchError((Object _) => false),
      ]);
      expect(outcomes.where((ok) => ok), hasLength(1));
    },
  );
  const soap = 'http://www.w3.org/2003/05/soap-envelope';
  const wsa = 'http://www.w3.org/2005/08/addressing';
  const rim = 'urn:oasis:names:tc:ebxml-regrep:xsd:rim:3.0';
  const target = 'urn:uuid:11111111-2222-3333-4444-555555555555';
  const fresh =
      '<s:Envelope xmlns:s="$soap" xmlns:w="$wsa"><s:Header><w:MessageID>old</w:MessageID><w:Action>old</w:Action><w:To>old</w:To></s:Header><s:Body/></s:Envelope>';
  const archive =
      '<s:Envelope xmlns:s="$soap" xmlns:rim="$rim"><s:Body><rim:RegistryPackage id="old-submission"><rim:Slot name="submissionTime"><rim:ValueList><rim:Value>20200101000000</rim:Value></rim:ValueList></rim:Slot><rim:ExternalIdentifier id="ext" registryObject="old-submission" identificationScheme="urn:uuid:96fdda7c-d067-4183-912e-bf5ee74998a8" value="2.25.123"/></rim:RegistryPackage><rim:ExtrinsicObject id="must-not-be-sent"/></s:Body></s:Envelope>';
  String build() => DmpNativeTd33c.build(
    fresh,
    archive,
    target,
    DateTime.utc(2026, 10, 29, 9),
  );
  test(
    'TD3.3c emits only a new SubmissionSet and one Approved to Deleted association',
    () {
      final request = build();
      final xml = XmlDocument.parse(request);
      final a = xml.findAllElements('Association', namespace: rim).single;
      final pack = xml
          .findAllElements('RegistryPackage', namespace: rim)
          .single;
      expect(a.getAttribute('targetObject'), target);
      expect(a.getAttribute('sourceObject'), pack.getAttribute('id'));
      expect(a.getAttribute('associationType'), DmpNativeTd33c.association);
      expect(
        a.findAllElements('Value', namespace: rim).map((v) => v.innerText),
        [DmpNativeTd33c.approved, DmpNativeTd33c.deleted],
      );
      expect(xml.findAllElements('ExtrinsicObject', namespace: rim), isEmpty);
      expect(
        pack
            .findAllElements('ExternalIdentifier', namespace: rim)
            .single
            .getAttribute('value'),
        isNot('2.25.123'),
      );
      expect(request, contains('20261029090000'));
      expect(build(), isNot(request));
      final output = Platform.environment['ABAK_DELETE_TEST_REQUEST'];
      if (output != null) File(output).writeAsStringSync(request);
    },
  );
  test('invalid or multiple targets rejected', () {
    for (final id in ['', 'abc', '$target $target']) {
      expect(
        () => DmpNativeTd33c.build(fresh, archive, id, DateTime.now()),
        throwsStateError,
      );
    }
  });
  test('only correlated successful RegistryResponse confirms deletion', () {
    final request = build();
    final id = XmlDocument.parse(
      request,
    ).findAllElements('MessageID', namespace: wsa).single.innerText;
    final response =
        '<s:Envelope xmlns:s="$soap" xmlns:w="$wsa"><s:Header><w:RelatesTo>$id</w:RelatesTo><w:Action>${DmpNativeTd33c.action}-Response</w:Action></s:Header><s:Body><RegistryResponse xmlns="urn:oasis:names:tc:ebxml-regrep:xsd:rs:3.0" status="urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success"/></s:Body></s:Envelope>';
    DmpNativeTd33c.read(request, DmpTd02Reply(200, response));
    for (final bad in [
      response.replaceAll(id, 'unrelated'),
      response.replaceAll('Success', 'Failure'),
      response.replaceAll('-Response', 'Response'),
    ]) {
      expect(
        () => DmpNativeTd33c.read(request, DmpTd02Reply(200, bad)),
        throwsStateError,
      );
    }
    expect(
      () => DmpNativeTd33c.read(request, DmpTd02Reply(500, response)),
      throwsStateError,
    );
  });
}

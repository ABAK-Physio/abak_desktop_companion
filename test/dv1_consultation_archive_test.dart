import 'dart:io';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/td31a.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/contracts.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';

void main() {
  final directory = Platform.environment['DV1_CONS_RECH_ARCHIVE'];
  test(
    'read-only replay of archived PRE_CONS_RECH response',
    () {
      final root = Directory(directory!);
      final files = {
        for (final name in [
          'result.json',
          'td31a-request.xml',
          'td31a-response.xml',
          'td31a-http.txt',
        ])
          name: File('${root.path}/$name').readAsBytesSync(),
      };
      final envelope = jsonDecode(utf8.decode(files['result.json']!));
      final record = Map<String, dynamic>.from(envelope['record']);
      expect(medicalHash(record), envelope['sha256']);
      final request = utf8.decode(files['td31a-request.xml']!);
      final response = utf8.decode(files['td31a-response.xml']!);
      expect(medicalHash(request), record['td31aRequestHash']);
      expect(medicalHash(response), record['td31aResponseHash']);
      final rows = DmpNativeTd31a.read(
        request,
        DmpTd02Reply(
          record['td31aHttpStatus'],
          response,
          headers: utf8.decode(files['td31a-http.txt']!),
        ),
        '148115530271002',
        const Dv1DocumentCriteria(),
      );
      expect(rows.length, 79);
      expect(rows.map((r) => r['entryUUID']).toSet().length, 79);
      expect(
        rows.every((r) => r['status'] == Dv1DocumentCriteria.approved),
        isTrue,
      );
      expect(
        record['state'],
        'interrupted',
      ); // Original evidence is not rewritten.
      for (final file in files.entries) {
        expect(File('${root.path}/${file.key}').readAsBytesSync(), file.value);
      }
    },
    skip: directory == null
        ? 'Opt-in local archive; no network or CPS.'
        : false,
  );
}

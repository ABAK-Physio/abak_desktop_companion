import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/contracts.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/td31a.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/td32.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';

void main() {
  final path = Platform.environment['DV1_CONS_DOCUMENT_ARCHIVE'];
  test(
    'archived real metadata can prepare retrieval without fetching any content',
    () async {
      final root = Directory(path!);
      final wrapped = jsonDecode(
        await File('${root.path}/result.json').readAsString(),
      );
      final record = wrapped['record'] as Map<String, dynamic>;
      expect(medicalHash(record), wrapped['sha256']);
      final identity = record['context']['identity'];
      final ins = '${identity['ins_number']}${identity['ins_key']}';
      var count = 0;
      for (final e in record['submissionExchanges']) {
        if (e['stage'] != 'documents') continue;
        final prefix = '${root.path}/${e['files']}';
        final query = await File('$prefix-request.xml').readAsString();
        final reply = await File('$prefix-response.xml').readAsString();
        expect(medicalHash(query), e['requestHash']);
        expect(medicalHash(reply), e['responseHash']);
        final rows = DmpNativeTd31a.read(
          query,
          DmpTd02Reply(
            e['httpStatus'],
            reply,
            headers: await File('$prefix-http.txt').readAsString(),
          ),
          ins,
          const Dv1DocumentCriteria(archived: true, deprecated: true),
        );
        for (final d in rows) {
          DmpNativeTd32.checkMetadata(d);
          expect(
            DmpNativeTd32.build(query, d),
            contains(d['repositoryUniqueId']!),
          );
          count++;
        }
      }
      expect(count, 203);
    },
    skip: path == null ? 'Archive locale non fournie.' : false,
  );
}

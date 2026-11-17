import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:abak_desktop_companion/features/patients/models/episode_document_version.dart';
import 'package:abak_desktop_companion/features/patients/services/final_pdf_document_service.dart';

const id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
const portable = 'version-$id/document.pdf';
const windows = 'version-$id\\document.pdf';

void main() {
  test('retained version paths accept Windows and portable separators', () {
    expect(FinalPdfDocumentService.normalizedVersionPath(portable), portable);
    expect(FinalPdfDocumentService.normalizedVersionPath(windows), portable);
  });

  test('version paths still reject traversal and unexpected components', () {
    for (final value in [
      '../$portable',
      '..\\$windows',
      '/$portable',
      'C:\\$windows',
      'version-$id/../document.pdf',
      'version-$id\\..\\document.pdf',
      'version-$id//document.pdf',
      '$portable/extra',
      '$portable\n',
      '$portable\u0000',
      'version-invalid/document.pdf',
    ]) {
      expect(
        () => FinalPdfDocumentService.normalizedVersionPath(value),
        throwsA(isA<FinalPdfException>()),
        reason: value,
      );
    }
  });

  for (final relative in [portable, windows]) {
    test('retained bytes remain checked for $relative', () async {
      final temporary = await Directory.systemTemp.createTemp('abak-pdf-path-');
      final root = Directory(await temporary.resolveSymbolicLinks());
      addTearDown(() => root.delete(recursive: true));
      final file = File(p.join(root.path, 'version-$id', 'document.pdf'));
      await file.parent.create();
      final bytes = Uint8List.fromList('%PDF-synthetic fixture'.codeUnits);
      await file.writeAsBytes(bytes, flush: true);
      final service = FinalPdfDocumentService(root: () async => root);
      final version = EpisodeDocumentVersion({
        'relative_path': relative,
        'byte_size': bytes.length,
        'sha256': FinalPdfDocumentService.hash(bytes),
      });
      final verified = await service.verifyStoredBytes(version);
      expect(verified.path, file.path);
      expect(await verified.readAsBytes(), bytes);
      final altered = Uint8List.fromList(bytes);
      altered[altered.length - 1] ^= 1;
      await file.writeAsBytes(altered, flush: true);
      await expectLater(
        service.verifyStoredBytes(version),
        throwsA(isA<FinalPdfException>()),
      );
    });
  }
}

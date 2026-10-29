import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Conversion provenance is committed with the PDF, never an approval or a CPS
/// signature. The existing immutable journal binds the complete file manifest.
class PdfConversionEvidence {
  PdfConversionEvidence(Map<String, List<int>> files)
    : files = Map.unmodifiable({
        for (final e in files.entries) e.key: Uint8List.fromList(e.value),
      });
  final Map<String, Uint8List> files;
  static const names = {
    'source.docx',
    'conversion.json',
    'conversion-pdfa.xml',
    'conversion-pdfa-launch.json',
  };
  static String digest(List<int> bytes) => sha256.convert(bytes).toString();

  Future<String> write(Directory target, List<int> pdf) async {
    if (files.keys.toSet().difference(names).isNotEmpty ||
        names.difference(files.keys.toSet()).isNotEmpty) {
      throw StateError('Preuves de conversion incomplètes.');
    }
    final conversion = jsonDecode(utf8.decode(files['conversion.json']!));
    if (conversion['pdfHash'] != digest(pdf) ||
        conversion['sourceHash'] != digest(files['source.docx']!) ||
        conversion['pdfa'] != 'conforme') {
      throw StateError('Conversion non conforme ou liée à un autre contenu.');
    }
    for (final entry in files.entries) {
      await File(
        p.join(target.path, entry.key),
      ).writeAsBytes(entry.value, flush: true);
    }
    final manifest = utf8.encode(
      jsonEncode({
        'protocol': 1,
        'pdfHash': digest(pdf),
        'files': {for (final e in files.entries) e.key: digest(e.value)},
      }),
    );
    await File(
      p.join(target.path, 'conversion-manifest.json'),
    ).writeAsBytes(manifest, flush: true);
    return digest(manifest);
  }

  static Future<void> verify(
    DatabaseExecutor db,
    String versionId,
    Directory directory,
    String pdfHash,
  ) async {
    final table = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='document_events'",
    );
    final events = table.isEmpty
        ? <Map<String, Object?>>[]
        : await db.query(
            'document_events',
            where: 'version_id=? AND kind=?',
            whereArgs: [versionId, 'docx_converted'],
          );
    final manifest = File(p.join(directory.path, 'conversion-manifest.json'));
    final exists = await FileSystemEntity.type(
      manifest.path,
      followLinks: false,
    );
    if (events.isEmpty && exists == FileSystemEntityType.notFound) return;
    if (events.length != 1 || exists != FileSystemEntityType.file) {
      throw StateError('Preuve de conversion absente ou sans rattachement.');
    }
    final bytes = await manifest.readAsBytes();
    if (digest(bytes) != events.single['reference_id']) {
      throw StateError('Preuve de conversion modifiée.');
    }
    final data = jsonDecode(utf8.decode(bytes));
    final hashes = Map<String, dynamic>.from(data['files']);
    if (data['protocol'] != 1 ||
        data['pdfHash'] != pdfHash ||
        hashes.keys.toSet().difference(names).isNotEmpty ||
        names.difference(hashes.keys.toSet()).isNotEmpty) {
      throw StateError('Manifeste de conversion incohérent.');
    }
    for (final e in hashes.entries) {
      final file = File(p.join(directory.path, e.key));
      if (await FileSystemEntity.type(file.path, followLinks: false) !=
              FileSystemEntityType.file ||
          digest(await file.readAsBytes()) != e.value) {
        throw StateError(
          'Source DOCX ou rapport de conversion absent ou modifié.',
        );
      }
    }
  }
}

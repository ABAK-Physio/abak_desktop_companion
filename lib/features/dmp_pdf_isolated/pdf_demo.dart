import 'dart:io';
import 'dart:typed_data';
import 'final_pdf_bench.dart';

/// Only bundled synthetic fixtures. No user file picker or business repository.
class PdfDemo {
  PdfDemo._(this.base, this.bench);
  final Directory base;
  FinalPdfBench bench;
  static const fixtures = {
    'rapport_final.pdf': 'Rapport final fictif',
    'rapport_modifie.pdf': 'Rapport modifié après validation',
    'deux_pages.pdf': 'Document de deux pages',
    'page_blanche.pdf': 'Page blanche',
    'entete_seul.pdf': 'En-tête sans contenu clinique',
    'graphique.pdf': 'Document graphique sans texte extractible',
  };
  static PdfDemo open(
    Directory base,
    LocalPdfInspector inspector, {
    bool fresh = false,
  }) {
    if (FileSystemEntity.typeSync(base.path, followLinks: false) ==
        FileSystemEntityType.link) {
      throw const PdfBlocked('Stockage isolé indisponible.');
    }
    base.createSync(recursive: true);
    final pointer = File('${base.path}/exercice.txt');
    if (FileSystemEntity.typeSync(pointer.path, followLinks: false) ==
        FileSystemEntityType.link) {
      throw const PdfBlocked('Pointeur interdit.');
    }
    if (!fresh && pointer.existsSync()) {
      final name = pointer.readAsStringSync().trim();
      if (!RegExp(r'^pdf-isole-[a-zA-Z0-9_-]+$').hasMatch(name)) {
        throw const PdfBlocked('Pointeur invalide.');
      }
      return PdfDemo._(
        base,
        FinalPdfBench.reopen(Directory('${base.path}/$name'), inspector),
      );
    }
    if (!fresh && base.listSync().isNotEmpty) {
      throw const PdfBlocked(
        'État précédent incertain. Créer explicitement un nouvel exercice.',
      );
    }
    final bench = FinalPdfBench.create(base, inspector);
    final tmp = File('${base.path}/exercice.tmp');
    if (FileSystemEntity.typeSync(tmp.path, followLinks: false) ==
        FileSystemEntityType.link) {
      throw const PdfBlocked('Pointeur interdit.');
    }
    tmp.writeAsStringSync(
      bench.root.uri.pathSegments.where((s) => s.isNotEmpty).last,
      flush: true,
    );
    tmp.renameSync(pointer.path);
    return PdfDemo._(base, bench);
  }

  void importFixture(String name, Uint8List bytes) {
    if (!fixtures.containsKey(name)) {
      throw const PdfBlocked('Fixture inconnue.');
    }
    final f = File('${bench.root.path}/fixture-import.pdf');
    if (FileSystemEntity.typeSync(f.path, followLinks: false) ==
        FileSystemEntityType.link) {
      throw const PdfBlocked('Chemin interdit.');
    }
    f.writeAsBytesSync(bytes, flush: true);
    bench.importPdf(f, bench.context(), 'source-fictive-1');
  }

  Uint8List page(Map<String, dynamic> current, int index) {
    final images =
        (current['inspection']['previews'] as Map).keys.cast<String>().toList()
          ..sort();
    final dir = current['preview'] as String;
    if (!RegExp(r'^preview-\d+$').hasMatch(dir) ||
        !RegExp(r'^page-\d+\.png$').hasMatch(images[index])) {
      throw const PdfBlocked('Aperçu indisponible.');
    }
    final folder = Directory('${bench.root.path}/$dir');
    final f = File('${folder.path}/${images[index]}');
    if (FileSystemEntity.typeSync(folder.path, followLinks: false) !=
            FileSystemEntityType.directory ||
        FileSystemEntity.typeSync(f.path, followLinks: false) !=
            FileSystemEntityType.file) {
      throw const PdfBlocked('Aperçu indisponible.');
    }
    final bytes = f.readAsBytesSync();
    if (pdfDigest(bytes) != current['inspection']['previews'][images[index]]) {
      throw const PdfBlocked('Aperçu altéré : validation bloquée.');
    }
    return bytes;
  }
}

/// Verified render cache for the six bundled fixtures only. This lets the
/// sandboxed desktop app demonstrate the bench without external PDF binaries.
/// A different PDF is refused, never assigned an approximate cached preview.
class BundledPdfInspector extends LocalPdfInspector {
  BundledPdfInspector(this.entries, this.assets) : super('');
  final Map<String, dynamic> entries;
  final Map<String, Uint8List> assets;
  @override
  Map<String, dynamic> inspect(File file, Directory preview) {
    final entry = entries[pdfDigest(file.readAsBytesSync())];
    if (entry == null) {
      throw const PdfBlocked('PDF extérieur aux fixtures : import bloqué.');
    }
    final result = Map<String, dynamic>.from(entry['inspection'] as Map);
    for (final e in (entry['images'] as Map).entries) {
      final name = e.key as String;
      if (!RegExp(r'^page-\d+\.png$').hasMatch(name)) {
        throw const PdfBlocked('Aperçu invalide.');
      }
      final bytes = assets[e.value['asset']];
      if (bytes == null ||
          pdfDigest(bytes) != e.value['sha256'] ||
          result['previews'][name] != e.value['sha256']) {
        throw const PdfBlocked('Aperçu intégré altéré.');
      }
      File('${preview.path}/$name').writeAsBytesSync(bytes, flush: true);
    }
    if ((entry['images'] as Map).length != result['pages']) {
      throw const PdfBlocked('Aperçu intégré incomplet.');
    }
    return result;
  }
}

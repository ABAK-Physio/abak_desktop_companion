import '../dmp_pdf_cda_unified/snapshot_contract.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

String pdfDigest(List<int> bytes) => sha256.convert(bytes).toString();

class PdfBlocked implements Exception {
  const PdfBlocked(this.message);
  final String message;
  @override
  String toString() => message;
}

/// Local tools only. No transport, CPS, patient repository or INSi dependency.
/// Deployment must keep this bench in an OS network-denied sandbox.
class LocalPdfInspector {
  LocalPdfInspector(this.bin);
  final String bin;
  String command(String name, List<String> args) {
    final r = Process.runSync(
      '/usr/bin/sandbox-exec',
      [
        '-p',
        '(version 1)(allow default)(deny network*)',
        '$bin/$name',
        ...args,
      ],
      environment: {'LC_ALL': 'C'},
    );
    if (r.exitCode != 0 || r.stderr.toString().contains('Syntax Error')) {
      throw const PdfBlocked('PDF illisible, chiffré ou endommagé.');
    }
    return r.stdout.toString();
  }

  Map<String, dynamic> inspect(File file, Directory preview) {
    final info = command('pdfinfo', [file.path]);
    if (!RegExp(r'Encrypted:\s+no').hasMatch(info)) {
      throw const PdfBlocked('PDF chiffré : import bloqué.');
    }
    final pages =
        int.tryParse(
          RegExp(r'Pages:\s+(\d+)').firstMatch(info)?.group(1) ?? '',
        ) ??
        0;
    if (pages < 1 || pages > 40) {
      throw const PdfBlocked(
        'Nombre de pages non pris en charge dans le banc.',
      );
    }
    final text = command('pdftotext', ['-layout', file.path, '-']);
    command('pdftoppm', [
      '-png',
      '-scale-to',
      '1000',
      file.path,
      '${preview.path}/page',
    ]);
    final images =
        preview
            .listSync()
            .whereType<File>()
            .where((p) => p.path.endsWith('.png'))
            .toList()
          ..sort((a, b) => a.path.compareTo(b.path));
    if (images.length != pages) {
      throw const PdfBlocked('Aperçu incomplet : validation bloquée.');
    }
    // Pixel inspection identifies a completely white render, not clinical meaning.
    command('pdftoppm', [
      '-gray',
      '-scale-to',
      '1000',
      file.path,
      '${preview.path}/pixels',
    ]);
    final rasters = preview
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.pgm'))
        .toList();
    if (rasters.length != pages) {
      throw const PdfBlocked('Contrôle visuel incomplet.');
    }
    var allWhite = true;
    for (final raster in rasters) {
      final data = raster.readAsBytesSync();
      final header = RegExp(
        r'^P5\s+(\d+)\s+(\d+)\s+255\s',
      ).firstMatch(latin1.decode(data.take(100).toList()));
      if (header == null) {
        throw const PdfBlocked('Contrôle visuel indisponible.');
      }
      final count = int.parse(header.group(1)!) * int.parse(header.group(2)!);
      if (data.length - header.end != count) {
        throw const PdfBlocked('Contrôle visuel incomplet.');
      }
      if (data.skip(header.end).any((pixel) => pixel != 255)) allWhite = false;
    }
    return {
      'allWhite': allWhite,
      'pages': pages,
      'text': text,
      'previews': {
        for (final f in images)
          f.uri.pathSegments.last: pdfDigest(f.readAsBytesSync()),
      },
    };
  }
}

/// Capability is created only by createTemp, or reopened with its marker.
/// This is a durable rehearsal journal, not a production migration.
class FinalPdfBench {
  FinalPdfBench._(this.root, this.inspector);
  final Directory root;
  final LocalPdfInspector inspector;
  static const marker = 'ABAK-PDF-SYNTHETIQUE-1';
  static FinalPdfBench create(Directory parent, LocalPdfInspector inspector) {
    final root = parent.createTempSync('pdf-isole-');
    File('${root.path}/scope').writeAsStringSync(marker, flush: true);
    final b = FinalPdfBench._(root, inspector);
    b._save({'current': null, 'history': [], 'attempts': {}, 'calls': 0});
    return b;
  }

  static FinalPdfBench reopen(Directory root, LocalPdfInspector inspector) {
    if (FileSystemEntity.typeSync(root.path, followLinks: false) !=
            FileSystemEntityType.directory ||
        !root.uri.pathSegments
            .where((s) => s.isNotEmpty)
            .last
            .startsWith('pdf-isole-') ||
        File('${root.path}/scope').readAsStringSync() != marker) {
      throw const PdfBlocked('Stockage isolé requis.');
    }
    final b = FinalPdfBench._(root, inspector);
    b.state;
    return b;
  }

  File _file(String relative) {
    if (relative.contains('..') || relative.startsWith('/')) {
      throw const PdfBlocked('Chemin interdit.');
    }
    var path = root.path;
    for (final part in relative.split('/')) {
      path = '$path/$part';
      if (FileSystemEntity.typeSync(path, followLinks: false) ==
          FileSystemEntityType.link) {
        throw const PdfBlocked('Lien symbolique interdit.');
      }
    }
    return File(path);
  }

  Map<String, dynamic> get state =>
      jsonDecode(_file('journal.json').readAsStringSync())
          as Map<String, dynamic>;
  void _save(Map<String, dynamic> s) {
    _file('journal.tmp').writeAsStringSync(jsonEncode(s), flush: true);
    _file('journal.tmp').renameSync(_file('journal.json').path);
  }

  T _locked<T>(T Function() f) {
    final handle = _file('lock').openSync(mode: FileMode.append);
    handle.lockSync(FileLock.blockingExclusive);
    try {
      return f();
    } finally {
      handle.unlockSync();
      handle.closeSync();
    }
  }

  Map<String, String> context({
    String patient = 'SIM-A',
    String episode = 'SIM-E1',
    String document = 'SIM-DOC1',
    String author = 'SIM-KINE',
    String type = 'bilan',
    String visibility = 'normal',
  }) {
    if (!patient.startsWith('SIM-') ||
        !episode.startsWith('SIM-') ||
        !document.startsWith('SIM-') ||
        !author.startsWith('SIM-')) {
      throw const PdfBlocked('Identifiants synthétiques requis.');
    }
    return {
      'patient': patient,
      'episode': episode,
      'document': document,
      'author': author,
      'type': type,
      'visibility': visibility,
    };
  }

  String importPdf(
    File source,
    Map<String, String> ctx,
    String sourceRevision,
  ) => _locked(() {
    context(
      patient: ctx['patient']!,
      episode: ctx['episode']!,
      document: ctx['document']!,
      author: ctx['author']!,
    );
    final s = state;
    final old = s['current'];
    // Failed imports must never leave the previous approval active.
    s['current'] = null;
    _save(s);
    final bytes = source.readAsBytesSync();
    if (bytes.isEmpty) throw const PdfBlocked('Document vide : import bloqué.');
    if (bytes.length > 20 * 1024 * 1024 ||
        !ascii
            .decode(bytes.take(5).toList(), allowInvalid: true)
            .startsWith('%PDF-') ||
        !latin1.decode(bytes).trimRight().endsWith('%%EOF')) {
      throw const PdfBlocked('Format PDF invalide.');
    }
    final digest = pdfDigest(bytes);
    final copy = _file('copies/$digest.pdf');
    copy.parent.createSync(recursive: true);
    if (copy.existsSync() && pdfDigest(copy.readAsBytesSync()) != digest) {
      throw const PdfBlocked('Copie figée altérée.');
    }
    if (!copy.existsSync()) copy.writeAsBytesSync(bytes, flush: true);
    final preview = Directory(
      '${root.path}/preview-${DateTime.now().microsecondsSinceEpoch}',
    )..createSync();
    final inspection = inspector.inspect(copy, preview);
    final id = pdfDigest(
      utf8.encode(jsonEncode([digest, ctx, sourceRevision])),
    );
    final current = <String, dynamic>{
      'id': id,
      'digest': digest,
      'context': ctx,
      'sourceRevision': sourceRevision,
      'inspection': inspection,
      'preview': preview.uri.pathSegments.where((s) => s.isNotEmpty).last,
      'approved': false,
      'held': true,
    };
    if (old != null && old['id'] == id) {
      current['approved'] = old['approved'];
      current['held'] = old['held'];
      current['review'] = old['review'];
    }
    s['current'] = current;
    (s['history'] as List).add({'event': 'import', 'id': id});
    _save(s);
    return id;
  });
  Map<String, dynamic> _current(Map<String, dynamic> s) {
    if (s['current'] == null) throw const PdfBlocked('PDF final requis.');
    return s['current'] as Map<String, dynamic>;
  }

  Uint8List _verify(Map<String, dynamic> c) {
    final file = _file('copies/${c['digest']}.pdf');
    if (!file.existsSync()) throw const PdfBlocked('Copie figée indisponible.');
    final bytes = file.readAsBytesSync();
    if (pdfDigest(bytes) != c['digest']) {
      throw const PdfBlocked(
        'Copie figée altérée. Nouvelle validation requise.',
      );
    }
    return bytes;
  }

  void approve({
    required Set<int> reviewedPages,
    required bool clinicalContent,
    required String reviewedPatient,
    required String currentSourceRevision,
    required bool consent,
  }) => _locked(() {
    final s = state;
    final c = _current(s);
    c['approved'] = false;
    _save(s);
    _verify(c);
    final n = c['inspection']['pages'] as int;
    if (!consent ||
        reviewedPages.length != n ||
        !List.generate(n, (i) => i + 1).every(reviewedPages.contains)) {
      throw const PdfBlocked(
        'Toutes les pages et une validation explicite sont requises.',
      );
    }
    for (final e in (c['inspection']['previews'] as Map).entries) {
      final f = _file('${c['preview']}/${e.key}');
      if (!f.existsSync() || pdfDigest(f.readAsBytesSync()) != e.value) {
        throw const PdfBlocked('Aperçu altéré ou indisponible.');
      }
    }
    if (!clinicalContent || c['inspection']['allWhite'] == true) {
      throw const PdfBlocked(
        'Document sans contenu clinique : validation bloquée.',
      );
    }
    if (reviewedPatient != c['context']['patient']) {
      throw const PdfBlocked('Patient différent : validation bloquée.');
    }
    // Only synthetic identifiers are recognized here. Real identity validation is absent.
    final ids = RegExp(r'SIM-[AB]\b')
        .allMatches(c['inspection']['text'] as String)
        .map((m) => m.group(0))
        .toSet();
    if (ids.isNotEmpty && (ids.length != 1 || !ids.contains(reviewedPatient))) {
      throw const PdfBlocked('Patient différent : validation bloquée.');
    }
    if (currentSourceRevision != c['sourceRevision']) {
      throw const PdfBlocked(
        'Données sources modifiées : réexport et nouvelle validation requis.',
      );
    }
    c['approved'] = true;
    c['review'] = {
      'at': DateTime.now().toUtc().toIso8601String(),
      'pages': reviewedPages.toList(),
      'patient': reviewedPatient,
      'author': c['context']['author'],
    };
    (s['history'] as List).add({
      'event': 'validation',
      'id': c['id'],
      'review': c['review'],
    });
    _save(s);
  });
  void hold(bool value) => _locked(() {
    final s = state;
    _current(s)['held'] = value;
    _save(s);
  });

  /// A single durable claim per logical document, including failures/uncertainty.
  /// No automatic retry path and no real transport implementation.
  String simulate({
    required String currentSourceRevision,
    String outcome = 'accepted',
    bool interrupt = false,
    void Function()? afterSnapshot,
  }) => _locked(() {
    final s = state;
    final c = _current(s);
    final bytes = _verify(c);
    if (currentSourceRevision != c['sourceRevision']) {
      throw const PdfBlocked('Données sources modifiées.');
    }
    final key = pdfDigest(
      utf8.encode(
        jsonEncode([c['context']['patient'], c['context']['episode']]),
      ),
    );
    if ((s['attempts'] as Map).containsKey(key)) {
      throw const PdfBlocked('Tentative existante : renvoi bloqué.');
    }
    if (c['approved'] != true) {
      throw const PdfBlocked(
        'Cette version nécessite une validation médicale.',
      );
    }
    if (c['held'] == true) throw const PdfBlocked('Document retenu.');
    s['attempts'][key] = {
      'id': c['id'],
      'digest': c['digest'],
      'context': c['context'],
      'outcome': 'indeterminate',
    };
    _save(s);
    if (interrupt) return 'indeterminate';
    afterSnapshot?.call();
    // Use captured bytes only; even an external file mutation cannot change payload.
    final envelope = {
      'simulation': true,
      'profile': 'NON_VALIDE_DMP',
      'mime': 'application/pdf',
      'digest': pdfDigest(bytes),
      'context': c['context'],
      'payload': base64Encode(bytes),
    };
    _file(
      'enveloppe-fictive.json',
    ).writeAsStringSync(jsonEncode(envelope), flush: true);
    s['calls'] = (s['calls'] as int) + 1;
    final result =
        {'accepted', 'signatureRejected', 'metadataRejected'}.contains(outcome)
        ? outcome
        : 'indeterminate';
    s['attempts'][key]['outcome'] = result;
    _save(s);
    return result;
  });

  /// Export to a NEW synthetic store; never calls simulate or releases a hold.
  /// Full CDA context confirmation is separate from the PDF page review.
  void exportNativeSnapshot(
    Directory destination,
    Map<String, String> cdaContext, {
    required String currentSourceRevision,
    required bool contextConfirmed,
  }) => _locked(() {
    final c = _current(state);
    final bytes = _verify(c);
    checkCdaContext(cdaContext);
    if (currentSourceRevision != c['sourceRevision'] ||
        cdaContext['patient'] != c['context']['patient'] ||
        cdaContext['author'] != c['context']['author']) {
      throw const PdfBlocked(
        'Version ou contexte différent. Nouvelle validation requise.',
      );
    }
    if (destination.existsSync() ||
        !destination.path.split('/').last.startsWith('snapshot-isole-')) {
      throw const PdfBlocked('Destination synthétique neuve requise.');
    }
    var parent = destination.parent;
    while (parent.path != parent.parent.path) {
      if (FileSystemEntity.typeSync(parent.path, followLinks: false) ==
          FileSystemEntityType.link) {
        throw const PdfBlocked('Lien symbolique interdit.');
      }
      parent = parent.parent;
    }
    final previews = <String, List<int>>{};
    for (final e in (c['inspection']['previews'] as Map).entries) {
      final data = _file('${c['preview']}/${e.key}').readAsBytesSync();
      if (pdfDigest(data) != e.value) throw const PdfBlocked('Aperçu altéré.');
      previews[e.key as String] = data;
    }
    final versionData = <String, Object>{
      'schema': 1,
      'pdfSha': pdfDigest(bytes),
      'pdfContext': c['context'],
      'cdaContext': cdaContext,
      'sourceRevision': c['sourceRevision'],
    };
    final version = snapshotHash(versionData);
    final approved = c['approved'] == true && contextConfirmed;
    final manifest = <String, Object>{
      ...versionData,
      'version': version,
      'scope': 'ABAK-PDF-CDA-SNAPSHOT-1',
      'clinical': approved,
      'review': approved
          ? {
              'version': version,
              'pages': c['review']['pages'],
              'patient': cdaContext['patient']!,
              'contextConfirmed': true,
            }
          : <String, Object>{},
      'allWhite': c['inspection']['allWhite'] == true,
      'previews': {for (final e in previews.entries) e.key: pdfDigest(e.value)},
    };
    destination.createSync();
    File(
      '${destination.path}/document.pdf',
    ).writeAsBytesSync(bytes, flush: true);
    for (final e in previews.entries) {
      File(
        '${destination.path}/${e.key}',
      ).writeAsBytesSync(e.value, flush: true);
    }
    File(
      '${destination.path}/snapshot.json',
    ).writeAsStringSync(canonicalSnapshot(manifest), flush: true);
  });

  String get conformity =>
      'Conformité DMP/PDF-A non vérifiée : aucun envoi réel disponible.';
}

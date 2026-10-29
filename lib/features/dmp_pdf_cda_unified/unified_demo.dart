import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import '../dmp_pdf_isolated/final_pdf_bench.dart';
import '../dmp_pdf_isolated/pdf_demo.dart';
import 'snapshot_contract.dart';
import 'ui_assets_digest.dart';

class UnifiedDemo {
  UnifiedDemo(this.root, this.assets, this.catalog);
  final Directory root;
  final Map<String, Uint8List> assets;
  final Map<String, dynamic> catalog;
  late FinalPdfBench bench;
  String fixture = 'positif', mode = 'native', pending = '', version = '';
  Map<String, dynamic> result = {};
  static Future<UnifiedDemo> open(
    Directory root,
    Future<Uint8List> Function(String) loader,
  ) async {
    if (FileSystemEntity.typeSync(root.path, followLinks: false) !=
            FileSystemEntityType.directory ||
        File('${root.path}/demo.scope').readAsStringSync() !=
            'ABAK-UNIFIED-DEMO-1') {
      throw const PdfBlocked(
        'Choisir le dossier créé par le service de démonstration.',
      );
    }
    final raw = await loader('manifest.json');
    if (pdfDigest(raw) != unifiedAssetsDigest) {
      throw const PdfBlocked('Catalogue altéré.');
    }
    final catalog = jsonDecode(utf8.decode(raw)) as Map<String, dynamic>;
    final assets = <String, Uint8List>{};
    for (final e in (catalog['files'] as Map).entries) {
      final bytes = await loader(e.key);
      if (pdfDigest(bytes) != e.value) throw const PdfBlocked('Témoin altéré.');
      assets[e.key] = bytes;
    }
    final d = UnifiedDemo(root, assets, catalog);
    final inspector = BundledPdfInspector(
      Map<String, dynamic>.from(catalog['entries']),
      assets,
    );
    final file = d.file('ui.json');
    if (file.existsSync()) {
      final envelope = jsonDecode(file.readAsStringSync());
      final s = envelope['state'];
      if (snapshotHash(s) != envelope['digest']) {
        throw const PdfBlocked('Journal altéré.');
      }
      final name = s['bench'] as String;
      if (!RegExp(r'^pdf-isole-[a-zA-Z0-9_-]+$').hasMatch(name)) {
        throw const PdfBlocked('Stockage invalide.');
      }
      d.bench = FinalPdfBench.reopen(
        Directory('${root.path}/$name'),
        inspector,
      );
      d.fixture = s['fixture'];
      d.mode = s['mode'];
      d.pending = s['pending'];
      d.version = s['version'];
      d.result = Map<String, dynamic>.from(s['result']);
      if (!(catalog['fixtures'] as Map).containsKey(d.fixture) ||
          !['native', 'missing', 'different'].contains(d.mode)) {
        throw const PdfBlocked('Scénario invalide.');
      }
      d.verify();
      await d.poll();
    } else {
      d.bench = FinalPdfBench.create(root, inspector);
      d.select('positif');
    }
    return d;
  }

  File file(String name) {
    if (name.contains('..') || name.startsWith('/')) {
      throw const PdfBlocked('Chemin interdit.');
    }
    var p = root.path;
    if (FileSystemEntity.typeSync(p, followLinks: false) ==
        FileSystemEntityType.link) {
      throw const PdfBlocked('Lien interdit.');
    }
    for (final part in name.split('/')) {
      p = '$p/$part';
      if (FileSystemEntity.typeSync(p, followLinks: false) ==
          FileSystemEntityType.link) {
        throw const PdfBlocked('Lien interdit.');
      }
    }
    return File(p);
  }

  Map<String, dynamic> get current =>
      Map<String, dynamic>.from(bench.state['current']);
  bool get clinicalBlocked =>
      catalog['fixtures'][fixture]['clinicalBlocked'] == true;
  bool get approved => current['approved'] == true;
  bool get ready {
    try {
      final s = jsonDecode(file('ready.json').readAsStringSync());
      return s['scope'] == 'ABAK-UNIFIED-DEMO-1' &&
          DateTime.now().millisecondsSinceEpoch / 1000 - s['at'] < 20;
    } catch (_) {
      return false;
    }
  }

  void verify() {
    final c = current;
    final bytes = File(
      '${bench.root.path}/copies/${c['digest']}.pdf',
    ).readAsBytesSync();
    if (pdfDigest(bytes) != c['digest'] ||
        c['digest'] !=
            pdfDigest(assets[catalog['fixtures'][fixture]['file']]!)) {
      throw const PdfBlocked('Copie figée altérée.');
    }
    for (var i = 0; i < (c['inspection']['pages'] as int); i++) {
      page(i);
    }
  }

  Uint8List page(int index) {
    final c = current;
    final images =
        (c['inspection']['previews'] as Map).keys.cast<String>().toList()
          ..sort();
    final bytes = file(
      '${bench.root.path.split('/').last}/${c['preview']}/${images[index]}',
    ).readAsBytesSync();
    if (pdfDigest(bytes) != c['inspection']['previews'][images[index]]) {
      throw const PdfBlocked('Aperçu altéré.');
    }
    return bytes;
  }

  void save() {
    final state = {
      'bench': bench.root.path.split('/').last,
      'fixture': fixture,
      'mode': mode,
      'pending': pending,
      'version': version,
      'result': result,
    };
    file('ui.tmp').writeAsStringSync(
      jsonEncode({'state': state, 'digest': snapshotHash(state)}),
      flush: true,
    );
    file('ui.tmp').renameSync(file('ui.json').path);
  }

  void select(String name) {
    if (pending.isNotEmpty) throw const PdfBlocked('Contrôle en cours.');
    if (!(catalog['fixtures'] as Map).containsKey(name)) {
      throw const PdfBlocked('Scénario inconnu.');
    }
    fixture = name;
    result = {};
    version = '';
    final f = File('${bench.root.path}/import.pdf')
      ..writeAsBytesSync(
        assets[catalog['fixtures'][name]['file']]!,
        flush: true,
      );
    bench.importPdf(f, bench.context(), 'synthetique-$name');
    bench.hold(true);
    save();
  }

  void approve(Set<int> pages, bool clinical, bool patient, bool context) {
    verify();
    if (clinicalBlocked || !context) {
      throw const PdfBlocked('Validation clinique ou contexte incomplet.');
    }
    bench.approve(
      reviewedPages: pages,
      clinicalContent: clinical,
      reviewedPatient: patient ? 'SIM-A' : '',
      currentSourceRevision: 'synthetique-$fixture',
      consent: context,
    );
    save();
  }

  void setMode(String value) {
    if (pending.isNotEmpty) throw const PdfBlocked('Contrôle en cours.');
    mode = value;
    result = {};
    save();
  }

  void request() {
    verify();
    if (!approved || clinicalBlocked || pending.isNotEmpty || !ready) {
      throw const PdfBlocked(
        'Validation requise ou service local indisponible.',
      );
    }
    final id = const Uuid().v4().replaceAll('-', '');
    final capture = Directory('${root.path}/snapshots/snapshot-isole-$id');
    bench.exportNativeSnapshot(
      capture,
      Map<String, String>.from(catalog['context']),
      currentSourceRevision: 'synthetique-$fixture',
      contextConfirmed: true,
    );
    final manifest = jsonDecode(
      File('${capture.path}/snapshot.json').readAsStringSync(),
    );
    version = manifest['version'];
    pending = id;
    result = {};
    save();
    final req = {
      'id': id,
      'snapshot': 'snapshot-isole-$id',
      'version': version,
      'mode': mode,
    };
    file('requests/$id.tmp').writeAsStringSync(jsonEncode(req), flush: true);
    file('requests/$id.tmp').renameSync(file('requests/$id.json').path);
  }

  Future<void> poll() async {
    if (pending.isEmpty) return;
    if (!RegExp(r'^[a-f0-9]{32}$').hasMatch(pending)) {
      throw const PdfBlocked('Requête invalide.');
    }
    final f = file('responses/$pending.json');
    if (!f.existsSync()) return;
    verify();
    final envelope = jsonDecode(f.readAsStringSync());
    final r = envelope['result'];
    if (snapshotHash(r) != envelope['digest'] ||
        r['id'] != pending ||
        r['version'] != version ||
        r['held'] != true ||
        r['calls'] != 0 ||
        r['mode'] != mode ||
        ![
          'conforme',
          'refuse',
          'non_verifie',
          'revue_requise',
        ].contains(r['status'])) {
      throw const PdfBlocked('Résultat non corrélé ou altéré.');
    }
    result = Map<String, dynamic>.from(r);
    pending = '';
    save();
  }
}

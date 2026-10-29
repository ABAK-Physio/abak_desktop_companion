import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import '../dmp_pdf_cda_unified/snapshot_contract.dart';

class PieceDemo {
  PieceDemo(this.root) {
    if (file('demo.scope').readAsStringSync() != 'ABAK-PIECE-DEMO-1') {
      throw StateError('Dossier incorrect');
    }
    if (file('pending.txt').existsSync()) {
      pending = file('pending.txt').readAsStringSync();
    }
    read();
  }
  final Directory root;
  Map<String, dynamic> state = {};
  String pending = '', error = '';
  File file(String n) {
    if (n.contains('..') || n.startsWith('/')) {
      throw StateError('Chemin interdit');
    }
    var p = root.path;
    for (final part in ['', ...n.split('/')]) {
      if (part.isNotEmpty) {
        p = '$p/$part';
      }
      if (FileSystemEntity.typeSync(p, followLinks: false) ==
          FileSystemEntityType.link) {
        throw StateError('Lien interdit');
      }
    }
    return File(p);
  }

  bool get ready {
    try {
      final r = jsonDecode(file('ready.json').readAsStringSync());
      final age = DateTime.now().millisecondsSinceEpoch / 1000 - r['at'];
      return r['scope'] == 'ABAK-PIECE-DEMO-1' && age >= 0 && age < 20;
    } catch (_) {
      return false;
    }
  }

  void read() {
    final e = jsonDecode(file('view.json').readAsStringSync());
    final s = e['state'];
    if (snapshotHash(s) != e['digest'] ||
        s['scope'] != 'ABAK-PIECE-DEMO-1' ||
        s['held'] != true ||
        s['calls'] != 0) {
      throw StateError('État altéré');
    }
    state = Map<String, dynamic>.from(s);
    if (pending.isNotEmpty) {
      if (!RegExp(r'^[a-f0-9]{32}$').hasMatch(pending)) {
        throw StateError('Commande invalide');
      }
      final f = file('responses/$pending.json');
      if (f.existsSync()) {
        final e = jsonDecode(f.readAsStringSync());
        final r = e['result'];
        if (snapshotHash(r) != e['digest'] || r['id'] != pending) {
          throw StateError('Réponse altérée');
        }
        error = r['error'];
        pending = '';
        file('pending.txt').writeAsStringSync('', flush: true);
      }
    }
  }

  void send(
    String action, {
    String? mode,
    String? binding,
    Map<String, dynamic>? review,
  }) {
    if (!ready || pending.isNotEmpty) {
      throw StateError('Service absent ou occupé');
    }
    final id = const Uuid().v4().replaceAll('-', '');
    final q = {
      'id': id,
      'action': action,
      'binding': binding ?? state['binding'],
      'mode': mode ?? state['mode'],
      'review': review ?? <String, dynamic>{},
    };
    pending = id;
    error = '';
    file('pending.txt').writeAsStringSync(id, flush: true);
    file('requests/$id.tmp').writeAsStringSync(jsonEncode(q), flush: true);
    file('requests/$id.tmp').renameSync(file('requests/$id.json').path);
  }
}

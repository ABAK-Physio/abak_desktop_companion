import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'archive_digest.dart';

typedef ArchiveLoader = Future<List<int>> Function(String name);

class NativeArchive {
  NativeArchive(this.root, this.loader);
  final Directory root;
  final ArchiveLoader loader;
  List<Map<String, dynamic>> cases = [];
  String selected = 'positif';
  bool examined = false;
  Map<String, dynamic> pdf = {}, cda = {};
  Map<String, dynamic> get current =>
      cases.singleWhere((e) => e['id'] == selected);
  bool get conform =>
      pdf['status'] == 'conforme' && cda['status'] == 'conforme';
  bool get canRecord => conform && current['clinicalBlock'] == false;
  Future<void> open() async {
    final bytes = await loader('manifest.json');
    if (sha256.convert(bytes).toString() != archiveDigest) {
      throw StateError('Archive altérée');
    }
    cases = (jsonDecode(utf8.decode(bytes)) as List)
        .cast<Map<String, dynamic>>();
    if (root.existsSync() &&
        root.listSync().isNotEmpty &&
        !File('${root.path}/isole.txt').existsSync()) {
      throw StateError('Stockage non isolé');
    }
    root.createSync(recursive: true);
    final marker = File('${root.path}/isole.txt');
    if (marker.existsSync() &&
        marker.readAsStringSync() != 'ABAK-NATIVE-ARCHIVE-1') {
      throw StateError('Stockage incorrect');
    }
    marker.writeAsStringSync('ABAK-NATIVE-ARCHIVE-1', flush: true);
    final journal = File('${root.path}/journal.json');
    if (journal.existsSync()) {
      final envelope = jsonDecode(journal.readAsStringSync());
      final String payload = envelope['payload'];
      if (sha256.convert(utf8.encode(payload)).toString() != envelope['digest']) {
        throw StateError('Journal altéré');
      }
      final state = jsonDecode(payload);
      if (state['archive'] != archiveDigest ||
          state['held'] != true ||
          state['calls'] != 0) {
        throw StateError('État invalide');
      }
      selected = state['selected'] as String;
      examined = state['examined'] as bool;
    }
    await verify();
    if (examined && !canRecord) throw StateError('Conclusion incohérente');
  }

  Future<void> verify() async {
    for (final item in (current['files'] as Map).entries) {
      if (sha256.convert(await loader(item.key as String)).toString() !=
          item.value) {
        throw StateError('Preuve absente ou altérée');
      }
    }
    pdf = jsonDecode(utf8.decode(await loader(current['pdfResult'])));
    cda = current['cdaResult'] == null
        ? {}
        : jsonDecode(utf8.decode(await loader(current['cdaResult'])));
    if (pdf['sha256'] !=
        sha256.convert(await loader(current['pdf'])).toString()) {
      throw StateError('PDF non corrélé');
    }
  }

  Future<void> select(String id) async {
    selected = id;
    examined = false;
    await verify();
    save();
  }

  Future<void> record() async {
    await verify();
    if (!canRecord) throw StateError('Contrôle bloqué');
    examined = true;
    save();
  }

  void save() {
    final payload = jsonEncode({
      'archive': archiveDigest,
      'selected': selected,
      'examined': examined,
      'held': true,
      'calls': 0,
    });
    final tmp = File('${root.path}/journal.tmp');
    tmp.writeAsStringSync(
      jsonEncode({
        'payload': payload,
        'digest': sha256.convert(utf8.encode(payload)).toString(),
      }),
      flush: true,
    );
    tmp.renameSync('${root.path}/journal.json');
  }
}

import 'dart:convert';
import 'dart:io';

/// Only synthetic lots. Never imports, reads or unlocks real deposit archives.
class SimulatedLotStore {
  SimulatedLotStore(Directory support)
    : directory = Directory('${support.path}/abak-dmp-simulated-lots-v1');
  final Directory directory;
  static const terminal = {
    'accepted',
    'signatureRejected',
    'metadataRejected',
    'rejected',
    'indeterminate',
  };
  File _file(String id, String suffix) {
    if (!RegExp(r'^simulation-[a-zA-Z0-9-]{1,80}$').hasMatch(id)) {
      throw ArgumentError('Identifiant de simulation invalide');
    }
    return File('${directory.path}/$id.$suffix');
  }

  String? read(String id) {
    final marker = _file(id, 'attempt');
    final result = _file(id, 'result.json');
    final tls = _file(id, 'tls.json');
    if (marker.existsSync()) {
      // Empty/torn marker or missing receipt always means possibly attempted.
      return result.existsSync()
          ? _decode(result, id, terminal)
          : 'indeterminate';
    }
    if (result.existsSync()) {
      throw const FormatException('Résultat sans trace de tentative');
    }
    return tls.existsSync() ? _decode(tls, id, {'tlsFailed'}) : null;
  }

  String _decode(File file, String id, Set<String> allowed) {
    if (file.lengthSync() > 32768) {
      throw const FormatException('État trop volumineux');
    }
    final data = jsonDecode(file.readAsStringSync());
    if (data is! Map ||
        data['version'] != 1 ||
        data['simulation'] != true ||
        data['lot'] != id ||
        !allowed.contains(data['state'])) {
      throw const FormatException('État du lot simulé invalide');
    }
    return data['state'] as String;
  }

  String readDetail(String id) {
    final file = _file(id, 'result.json');
    if (!file.existsSync()) return '';
    _decode(file, id, terminal);
    final data = jsonDecode(file.readAsStringSync()) as Map;
    final detail = data['detail'];
    if (detail == null) return '';
    if (detail is! String || detail.length > 16000) {
      throw const FormatException('Diagnostic invalide');
    }
    return detail;
  }

  bool begin(String id) {
    directory.createSync(recursive: true);
    // Validate any existing state before creating the irreversible claim.
    final prior = read(id);
    if (prior != null && prior != 'tlsFailed') return false;
    final marker = _file(id, 'attempt');
    try {
      marker.createSync(exclusive: true);
    } on FileSystemException {
      if (marker.existsSync()) return false;
      rethrow;
    }
    marker.writeAsStringSync('SIMULATION — tentative réservée\n', flush: true);
    return true;
  }

  void finish(String id, String state, {String detail = ''}) {
    if (!terminal.contains(state) || !_file(id, 'attempt').existsSync()) {
      throw StateError('Résultat sans tentative simulée');
    }
    _save(id, state, 'result.json', detail: detail);
  }

  void tlsFailed(String id) {
    directory.createSync(recursive: true);
    _save(id, 'tlsFailed', 'tls.json');
  }

  void _save(String id, String state, String suffix, {String detail = ''}) {
    if (detail.length > 16000) {
      throw const FormatException('Diagnostic trop volumineux');
    }
    final target = _file(id, suffix);
    final temp = File(
      '${target.path}.${DateTime.now().microsecondsSinceEpoch}.tmp',
    );
    temp.createSync(exclusive: true);
    temp.writeAsStringSync(
      jsonEncode({
        'version': 1,
        'simulation': true,
        'lot': id,
        'state': state,
        'detail': detail,
        'recordedAt': DateTime.now().toUtc().toIso8601String(),
      }),
      flush: true,
    );
    temp.renameSync(target.path);
  }
}

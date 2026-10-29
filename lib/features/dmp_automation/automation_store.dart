import 'dart:convert';
import 'dart:io';
import 'automation_model.dart';

class AutoRecord {
  AutoRecord({
    this.document = const AutoDocument(),
    this.rule = const AutoRule(),
    this.held = false,
    this.validated,
    this.history,
    this.outcome,
  });
  AutoDocument document;
  AutoRule rule;
  bool held;
  String? validated;
  AutoDocument? history;
  String? outcome;
  Map<String, Object?> toJson() => {
    'scope': 'ABAK-AUTOMATION-SIMULATION-1',
    'document': document.toJson(),
    'rule': rule.toJson(),
    'held': held,
    'validated': validated,
    'history': history?.toJson(),
    'outcome': outcome,
  };
  factory AutoRecord.fromJson(Map<String, dynamic> j) {
    if (j['scope'] != 'ABAK-AUTOMATION-SIMULATION-1' ||
        j['held'] is! bool ||
        (j['validated'] != null &&
            (j['validated'] is! String ||
                !RegExp(r'^[a-f0-9]{64}$').hasMatch(j['validated']))) ||
        ![
          null,
          'accepted',
          'rejected',
          'indeterminate',
          'tlsFailed',
        ].contains(j['outcome'])) {
      throw const FormatException('État invalide');
    }
    return AutoRecord(
      document: AutoDocument.fromJson(Map<String, dynamic>.from(j['document'])),
      rule: AutoRule.fromJson(Map<String, dynamic>.from(j['rule'])),
      held: j['held'],
      validated: j['validated'],
      history: j['history'] == null
          ? null
          : AutoDocument.fromJson(Map<String, dynamic>.from(j['history'])),
      outcome: j['outcome'],
    );
  }
}

/// One simulation workspace/lineage, not an application database. Synchronous
/// mutations are serialized in the UI isolate; exclusive claim survives crashes.
class AutoStore {
  AutoStore(this.directory);
  final Directory directory;
  File get file => File('${directory.path}/automation-fictive.json');
  File get claim => File('${directory.path}/tentative-fictive.claim');
  AutoRecord read() {
    if (!file.existsSync()) {
      if (claim.existsSync()) throw const FormatException('Trace sans état');
      return AutoRecord();
    }
    if (file.lengthSync() > 1024 * 1024) {
      throw const FormatException('État trop volumineux');
    }
    final record = AutoRecord.fromJson(
      Map<String, dynamic>.from(jsonDecode(file.readAsStringSync())),
    );
    if (claim.existsSync() && record.outcome == null) {
      record.outcome = 'indeterminate';
    }
    if (!claim.existsSync() &&
        ['accepted', 'rejected', 'indeterminate'].contains(record.outcome)) {
      throw const FormatException('Résultat sans trace');
    }
    return record;
  }

  void write(AutoRecord value) {
    // Validate values before writing, including simulation identities.
    AutoRecord.fromJson(value.toJson());
    directory.createSync(recursive: true);
    final temp = File('${file.path}.pending');
    temp.writeAsStringSync(jsonEncode(value.toJson()), flush: true);
    temp.renameSync(file.path);
  }

  void change(void Function(AutoRecord) update) {
    final record = read();
    update(record);
    write(record);
  }

  bool reserve() {
    final record = read();
    if (record.outcome != null || record.held) return false;
    // Ensure an initial durable state exists before the exclusive marker.
    write(record);
    try {
      claim.createSync(exclusive: true);
    } on FileSystemException {
      if (claim.existsSync()) return false;
      rethrow;
    }
    claim.writeAsStringSync('SIMULATION — tentative réservée', flush: true);
    return true;
  }

  void finish(String result, AutoDocument sent) {
    if (!claim.existsSync()) throw StateError('Tentative absente');
    final record = read();
    record.outcome = result;
    if (result == 'accepted') record.history = sent;
    write(record);
  }
}

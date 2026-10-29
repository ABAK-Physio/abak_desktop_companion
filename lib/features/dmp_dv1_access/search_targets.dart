import 'dart:io';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../patients/services/document_journal_service.dart';
import '../patients/services/document_medical_service.dart';
import '../patients/services/document_cda_builder.dart';
import '../patients/services/dmp_chain/native/dv1_records.dart';
import '../patients/services/dmp_chain/native/access_context.dart';

class Dv1SearchTarget {
  Dv1SearchTarget(Map<String, String> data) : data = Map.unmodifiable(data);
  final Map<String, String> data;
  String get id => data['attemptId']!;
  String get uniqueId => data['uniqueId']!;
  String? suggestedStructure(String professional) {
    final structure = data['structure'];
    return data['professional'] == professional &&
            data['replacementFor'] == '' &&
            RegExp(r'^\d{1,30}$').hasMatch(structure ?? '')
        ? structure
        : null;
  }

  String get label =>
      '${data['origin'] == 'reviewed_legacy' ? 'Archive technique externe · ' : ''}'
      '${data['title']} · ${data['patient']} · version ${data['version']}';
  void checkContext(Dv1AccessContext context) {
    if (context.ins != data['ins'] ||
        context.patientLabel != data['patient'] ||
        context.birthDate != data['birth'] ||
        context.source != data['source']) {
      throw StateError(
        'Le patient a changé. Sélectionnez à nouveau le dépôt à rechercher.',
      );
    }
  }
}

class Dv1SearchTargets {
  Dv1SearchTargets(this.journal);
  final DocumentJournalService journal;
  // Exact evidence reviewed offline. This is not a general trust-on-import path.
  static const legacyEvidenceHash =
      '9b9b2c3931c24b3e22147e436aa3864382463d000c22496e5e4fa17e5b32aa11';
  static const legacyId = 'legacy-c544acd5-9fdd-43c1-9b75-b176eee37e80';

  static Dv1SearchTarget decodeLegacy(List<int> bytes) {
    if (sha256.convert(bytes).toString() != legacyEvidenceHash) {
      throw StateError(
        'Cette archive ne correspond pas à la preuve historique vérifiée.',
      );
    }
    final payload = jsonDecode(utf8.decode(bytes)) as Map;
    return Dv1SearchTarget({
      ...Map<String, String>.from(payload['target'] as Map),
      'evidenceHash': legacyEvidenceHash,
    });
  }

  Future<File> get legacyFile async => File(
    '${(await journal.controls.root).path}/legacy-search-evidence/$legacyId.json',
  );

  Future<void> importLegacy(File source) async {
    if (await source.length() > 1024 * 1024) {
      throw StateError('Archive historique trop volumineuse.');
    }
    final bytes = await source.readAsBytes();
    decodeLegacy(bytes);
    final destination = await legacyFile;
    await destination.parent.create(recursive: true);
    final temporary = File('${destination.path}.tmp');
    await temporary.writeAsBytes(bytes, flush: true);
    await temporary.rename(destination.path);
  }

  Future<Dv1SearchTarget> load(String attemptId) async {
    if (attemptId == legacyId) {
      final file = await legacyFile;
      if (await file.length() > 1024 * 1024) {
        throw StateError('Archive historique trop volumineuse.');
      }
      return decodeLegacy(await file.readAsBytes());
    }
    final db = await journal.database;
    final reservation = (await db.query(
      'document_chain_steps',
      where: 'chain_id=? AND phase=?',
      whereArgs: [attemptId, 'dv1_reservation'],
    )).single;
    final verified = await Dv1Records.verify(
      db,
      reservation,
      controlsRoot: await journal.controls.root,
    );
    if (verified['outcome'] != 'accepted') {
      throw StateError('Dépôt non confirmé par le DMP.');
    }
    final saved = Dv1Records.data(reservation);
    final approval = (await db.query(
      'document_medical_approvals',
      where: 'approval_id=?',
      whereArgs: [saved['approvalId']],
    )).single;
    final snapshot = jsonDecode(approval['snapshot_json'] as String) as Map;
    final identity = snapshot['identity'] as Map;
    final practice = jsonDecode(snapshot['practice']['data_json']) as Map;
    final prep = jsonDecode(snapshot['preparation']['data_json']) as Map;
    final patient =
        '${identity['birth_last_name']} ${identity['birth_first_names']}'
            .trim();
    final ins = '${identity['ins_number']}${identity['ins_key']}';
    final birth = '${identity['birth_date']}';
    if (identity['ins_oid'] != '1.2.250.1.213.1.4.10' ||
        identity['birth_last_name'] is! String ||
        identity['birth_first_names'] is! String ||
        (identity['birth_last_name'] as String).trim().isEmpty ||
        (identity['birth_first_names'] as String).trim().isEmpty ||
        !RegExp(r'^\d{15}$').hasMatch(ins) ||
        !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(birth)) {
      throw StateError('Identité archivée incomplète.');
    }
    return Dv1SearchTarget({
      'attemptId': attemptId,
      'professional': '${practice['identifier'] ?? ''}',
      'structure': '${practice['structureId'] ?? ''}',
      'replacementFor': '${practice['replacementFor'] ?? ''}',
      'reservationHash': reservation['data_hash'] as String,
      'snapshotHash': approval['snapshot_hash'] as String,
      'documentId': '${reservation['document_id']}',
      'versionId': '${reservation['version_id']}',
      'version': '${snapshot['version']['sequence_number']}',
      'title':
          '${prep['title'] ?? snapshot['document']['title'] ?? 'Document déposé'}',
      'patient': patient,
      'ins': ins,
      'birth': birth,
      'source': 'Dépôt DV1 archivé $attemptId',
      'uniqueId': DocumentCdaBuilder.documentId(snapshot),
    });
  }

  Future<void> verify(Dv1SearchTarget target) async {
    if (medicalHash((await load(target.id)).data) != medicalHash(target.data)) {
      throw StateError(
        'Les preuves du dépôt ont changé. Reprenez la sélection.',
      );
    }
  }

  Future<({List<Dv1SearchTarget> targets, int excluded})> list({
    String? versionId,
  }) async {
    final db = await journal.database;
    final rows = await db.query(
      'document_chain_steps',
      columns: ['chain_id'],
      where: versionId == null ? 'phase=?' : 'phase=? AND version_id=?',
      whereArgs: ['dv1_reservation', ?versionId],
      orderBy: 'rowid DESC',
    );
    final targets = <Dv1SearchTarget>[];
    var excluded = 0;
    for (final row in rows) {
      try {
        targets.add(await load(row['chain_id'] as String));
      } catch (_) {
        excluded++;
      }
    }
    final legacy = await legacyFile;
    if (versionId == null && await legacy.exists()) {
      try {
        targets.add(await load(legacyId));
      } catch (_) {
        excluded++;
      }
    }
    return (targets: targets, excluded: excluded);
  }
}

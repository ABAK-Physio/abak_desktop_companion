import 'dart:convert';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../models/episode_document_version.dart';
import '../../document_cda_builder.dart';
import '../../document_medical_service.dart';
import 'dv1_records.dart';

/// Explicit replacement intent, frozen in the medical preparation before review.
/// Never authorizes replay of a reserved version or an uncertain deposit.
class Dv1Replacement {
  static Map<String, dynamic>? fromPreparation(Map data) {
    final raw = data['dv1Replacement'];
    if (raw == null) return null;
    final value = jsonDecode(raw as String) as Map<String, dynamic>;
    if (value['schema'] != 1 ||
        !RegExp(r'^2\.25\.\d+$').hasMatch('${value['uniqueId']}') ||
        [
          'attemptId',
          'versionId',
          'snapshotHash',
          'reservationHash',
        ].any((key) => '${value[key] ?? ''}'.isEmpty)) {
      throw StateError('Cible de remplacement invalide.');
    }
    return value;
  }

  static Future<Map<String, dynamic>> candidate(
    DatabaseExecutor db,
    EpisodeDocumentVersion v,
  ) async {
    final versions = await db.query(
      'episode_document_versions',
      where: 'document_id=?',
      whereArgs: [v.documentId],
      orderBy: 'sequence_number DESC',
      limit: 1,
    );
    if (versions.isEmpty ||
        versions.single['version_id'] != v.id ||
        versions.single['sha256'] != v.digest ||
        versions.single['patient_id'] != v.values['patient_id']) {
      throw StateError(
        'Sélectionnez la nouvelle version courante de cette pièce.',
      );
    }
    final rows = await Dv1Records.reservations(db, v);
    if (rows.isEmpty) throw StateError('Aucun dépôt antérieur à remplacer.');
    final row = rows.first;
    final result = await Dv1Records.verify(db, row);
    if (result['outcome'] != 'accepted' ||
        row['version_id'] == v.id ||
        row['document_id'] != v.documentId) {
      throw StateError(
        'Le remplacement exige une nouvelle version du même document et un dernier dépôt accepté.',
      );
    }
    final saved = Dv1Records.data(row);
    final approval = (await db.query(
      'document_medical_approvals',
      where: 'approval_id=?',
      whereArgs: [saved['approvalId']],
    )).single;
    final snapshot = jsonDecode(approval['snapshot_json'] as String) as Map;
    final old = snapshot['version'] as Map;
    if (old['patient_id'] != v.values['patient_id'] ||
        (old['sequence_number'] as int) >= v.number ||
        old['sha256'] == v.digest) {
      throw StateError(
        'Importez une nouvelle version PDF modifiée pour le même patient.',
      );
    }
    return {
      'schema': 1,
      'attemptId': row['chain_id'],
      'versionId': row['version_id'],
      'snapshotHash': approval['snapshot_hash'],
      'reservationHash': row['data_hash'],
      'uniqueId': DocumentCdaBuilder.documentId(snapshot),
      'patientCx':
          '${snapshot['identity']['ins_number']}${snapshot['identity']['ins_key']}^^^&${snapshot['identity']['ins_oid']}&ISO',
    };
  }

  static Future<Map<String, dynamic>?> check(
    DatabaseExecutor db,
    EpisodeDocumentVersion v,
  ) async {
    final rows = await db.query(
      'document_preparations',
      where: 'version_id=?',
      whereArgs: [v.id],
    );
    if (rows.isEmpty) return null;
    final intent = fromPreparation(
      jsonDecode(rows.single['data_json'] as String),
    );
    if (intent == null) return null;
    if (medicalHash(intent) != medicalHash(await candidate(db, v))) {
      throw StateError(
        'Le dépôt à remplacer a changé. Nouvelle préparation requise.',
      );
    }
    return intent;
  }

  static Future<void> configure(
    Database db,
    EpisodeDocumentVersion v,
  ) => db.transaction((tx) async {
    final intent = await candidate(tx, v);
    final rows = await tx.query(
      'document_preparations',
      where: 'version_id=?',
      whereArgs: [v.id],
    );
    if (rows.isEmpty) {
      throw StateError(
        'Enregistrez d’abord les informations de préparation de cette nouvelle version.',
      );
    }
    final row = rows.single;
    final data = jsonDecode(row['data_json'] as String) as Map<String, dynamic>;
    data['dv1Replacement'] = medicalCanonical(intent);
    // The existing preparation trigger invalidates prior review/controls.
    await tx.update(
      'document_preparations',
      {
        'revision': (row['revision'] as int) + 1,
        'data_json': medicalCanonical(data),
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'version_id=?',
      whereArgs: [v.id],
    );
  });
}

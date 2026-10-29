import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import '../models/episode_document_version.dart';
import 'document_journal_service.dart';
import 'document_medical_service.dart';
import 'document_native_controls.dart';
import 'document_reconciliation_records.dart';
import 'final_pdf_document_service.dart';

/// Immutable two-stage review. Creating a preview has no write side effect.
class DocumentReconciliationReview {
  const DocumentReconciliationReview._(this._json);
  final String _json;
  Map<String, dynamic> get _data => jsonDecode(_json);
  String get outcome => _data['decision']['outcome'];
  String get message =>
      '${_data['decision']['detail']} Renvoi bloqué. Aucun dépôt réel attesté.';
  String get documentId => _data['documentId'];
  String get versionId => _data['versionId'];
}

/// Wired to the common journal; write capability is restricted to an explicitly
/// isolated harness. There is no socket, CPS, INSi, retry or barrier-release API.
class DocumentReconciliationService {
  DocumentReconciliationService({
    required this.journal,
    required this.directory,
  });
  final DocumentJournalService journal;
  final Directory directory;

  Future<Database> _scope() async {
    final db = await journal.database;
    await DocumentLocalSimulation(
      directory: directory,
    ).checkScope(db, await journal.medical.pdf.root());
    return db;
  }

  Future<MedicalRow> _context(
    DatabaseExecutor db,
    String versionId,
    String? attemptId,
  ) async {
    final binding = await DocumentReconciliationRecords.binding(
      db,
      versionId,
      attemptId,
    );
    final rows = await DocumentReconciliationRecords.verifyTarget(
      db,
      DocumentReconciliationRecords.key(versionId, attemptId),
    );
    final result = attemptId == null
        ? <MedicalRow>[]
        : await db.query(
            'document_attempt_results',
            where: 'attempt_id=?',
            whereArgs: [attemptId],
          );
    return {
      'binding': binding,
      'barriers': await DocumentReconciliationRecords.barriers(db),
      'previousHash': rows.isEmpty ? '' : rows.last['evidence_hash'],
      'initialResult': result,
    };
  }

  Future<void> _files(MedicalRow binding) async {
    final v = EpisodeDocumentVersion(
      Map<String, Object?>.from(binding['version'] as Map),
    );
    await journal.medical.pdf.verifyStoredBytes(v);
    final attempt = binding['attempt'] as Map?;
    if (attempt == null) return;
    final runs = binding['runs'] as List;
    if (runs.length != 1) {
      return; // Insufficient proof is retained as indeterminate.
    }
    final dir = runs.single['directory'] as String;
    if (!RegExp(r'^[0-9a-f-]{36}$').hasMatch(dir)) {
      throw const FormatException('Répertoire de preuve invalide');
    }
    final file = File(
      p.join((await journal.controls.root).path, dir, 'document.xml'),
    );
    await LocalDocumentControlRunner.regular(file.path);
    if (FinalPdfDocumentService.hash(await file.readAsBytes()) !=
        attempt['payload_hash']) {
      throw const FormatException('Copie CDA différente de la tentative');
    }
  }

  /// Null headers/body explicitly records that no usable archive was found.
  /// The selected version may have changed: target the original attempted
  /// version, not the newly selected PDF or another piece sharing its hash.
  Future<DocumentReconciliationReview> preview(
    EpisodeDocumentVersion selected, {
    String? headers,
    List<int>? bytes,
  }) async {
    if ((headers == null) != (bytes == null) ||
        (headers?.length ?? 0) > 32768 ||
        (bytes?.length ?? 0) > 2 * 1024 * 1024) {
      throw const FormatException(
        'Archive absente, incomplète ou trop volumineuse',
      );
    }
    final source = {
      'headers': headers,
      'body': bytes == null ? null : base64Encode(bytes),
    };
    final db = await _scope();
    // Check that callers cannot supply a fabricated selected version.
    final stored = (await db.query(
      'episode_document_versions',
      where: 'version_id=?',
      whereArgs: [selected.id],
    )).single;
    if (medicalCanonical(stored) != medicalCanonical(selected.values)) {
      throw StateError('Version non reconnue');
    }
    final status = await journal.status(selected), attempt = status.attempt;
    final versionId = (attempt?['version_id'] ?? selected.id) as String,
        attemptId = attempt?['attempt_id'] as String?;
    final context = await db.transaction(
      (tx) => _context(tx, versionId, attemptId),
    );
    final restored = (context['barriers'] as List).isNotEmpty;
    if (attemptId == null && !restored ||
        attemptId != null &&
            !restored &&
            context['previousHash'] == '' &&
            attempt?['outcome'] != null &&
            attempt?['outcome'] != 'indeterminate') {
      throw StateError('Aucune tentative indéterminée ou restaurée à examiner');
    }
    final binding = Map<String, Object?>.from(context['binding'] as Map);
    await _files(binding);
    return DocumentReconciliationReview._(
      medicalCanonical({
        'versionId': versionId,
        'documentId': (binding['version'] as Map)['document_id'],
        'attemptId': attemptId,
        'contextHash': medicalHash(context),
        'source': source,
        'decision': DocumentReconciliationRecords.assess(binding, source),
      }),
    );
  }

  Future<String> confirm(
    DocumentReconciliationReview review, {
    required bool confirmed,
  }) async {
    if (!confirmed) {
      throw StateError('Confirmation explicite de l’examen requise');
    }
    final db = await _scope(), data = review._data;
    return db.transaction((tx) async {
      final versionId = data['versionId'] as String,
          attemptId = data['attemptId'] as String?;
      final target = DocumentReconciliationRecords.key(versionId, attemptId);
      final context = await _context(tx, versionId, attemptId);
      final binding = Map<String, Object?>.from(context['binding'] as Map),
          source = Map<String, Object?>.from(data['source'] as Map);
      final restoreHash = medicalHash(context['barriers']),
          sourceHash = medicalHash(source);
      await _files(binding);
      // A double confirmation of an already retained review is idempotent.
      final duplicate = await tx.query(
        'document_reconciliations',
        where: 'target_key=? AND source_hash=? AND restore_hash=?',
        whereArgs: [target, sourceHash, restoreHash],
      );
      if (duplicate.isNotEmpty) return duplicate.single['review_id'] as String;
      if (data['contextHash'] != medicalHash(context)) {
        throw StateError(
          'Journal modifié depuis l’examen. Rechargez les preuves.',
        );
      }
      final decision = DocumentReconciliationRecords.assess(binding, source);
      if (medicalCanonical(decision) != medicalCanonical(data['decision'])) {
        throw StateError('Conclusion modifiée');
      }
      final id = const Uuid().v4(),
          now = journal.medical.now().millisecondsSinceEpoch;
      final evidence = {
        'schema': 1,
        'scope': 'isolated-simulation',
        'reviewId': id,
        'reviewedAt': now,
        'target': target,
        'bindingHash': medicalHash(binding),
        'barriers': context['barriers'],
        'previousHash': context['previousHash'],
        'source': source,
        'decision': decision,
      };
      await tx.insert('document_reconciliations', {
        'review_id': id,
        'target_key': target,
        'version_id': versionId,
        'document_id': data['documentId'],
        'attempt_id': attemptId,
        'previous_hash': context['previousHash'],
        'source_hash': sourceHash,
        'restore_hash': restoreHash,
        'outcome': decision['outcome'],
        'detail': '${decision['detail']} Renvoi bloqué.',
        'reviewed_at': now,
        'evidence_json': medicalCanonical(evidence),
        'evidence_hash': medicalHash(evidence),
      });
      return id;
    });
  }
}

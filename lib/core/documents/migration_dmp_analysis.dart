import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../features/maintenance/services/document_backup_contents.dart';
import '../../features/patients/services/document_medical_service.dart';
import '../../features/patients/services/dmp_chain/native/dv1_records.dart';
import '../../features/patients/services/document_reconciliation_records.dart';

/// Counts are IDs, not UI status evaluations: status() has write side effects.
class MigrationDmpImpact {
  MigrationDmpImpact(this.data);
  final Map<String, Object?> data;
  List<String> get approvalIds => List<String>.from(data['approvals'] as List);
  bool get requiresConsent => approvalIds.isNotEmpty;
  List<String> get blockers => List<String>.from(data['blockers'] as List);
}

/// Classification only, after immutable archive verification. Feed reservations
/// in rowid order: an older rejection must not mask a later accepted retry, and
/// an accepted old version must not hide a rejected replacement.
class MigrationTransmissionSummary {
  final acceptedDocuments = <String>{};
  final acceptedVersions = <String>{};
  final acceptedSimulations = <String>{};
  final uncertainSimulations = <String>{};
  final _latestDv1 = <String, String>{};

  void recordDv1(String document, String version, String outcome) {
    _latestDv1[document] = outcome;
    if (outcome == 'accepted') {
      acceptedDocuments.add(document);
      acceptedVersions.add(version);
    }
  }

  void recordSimulation(String document, String outcome) {
    if (outcome == 'accepted') {
      acceptedSimulations.add(document);
    } else if (outcome != 'rejected') {
      uncertainSimulations.add(document);
    }
  }

  Set<String> get uncertain => {
    ...uncertainSimulations,
    ..._latestDv1.entries
        .where((e) => !['accepted', 'rejected'].contains(e.value))
        .map((e) => e.key),
  };
  bool get hasPendingRetry => _latestDv1.values.contains('rejected');
}

class MigrationDmpAnalysis {
  static Future<List<Map<String, Object?>>> rows(
    DatabaseExecutor db,
    String table,
  ) async {
    if (!await DocumentBackupContents.table(db, table)) return [];
    return db.query(table);
  }

  static Future<MigrationDmpImpact> inspect(
    DatabaseExecutor db,
    Directory support,
    String source,
    List<Map<String, Object?>> changes,
  ) async {
    final blockers = <String>{};
    final approvals = await rows(db, 'document_medical_approvals');
    final invalid = (await rows(
      db,
      'document_approval_invalidations',
    )).map((r) => r['approval_id']).toSet();
    final controlsInvalid = (await rows(
      db,
      'document_control_invalidations',
    )).map((r) => r['run_id']).toSet();
    final versions = await rows(db, 'episode_document_versions');
    final affectedVersions = versions
        .where(
          (v) => changes.any(
            (c) =>
                c['table'] == 'care_episodes' && c['id'] == v['episode_id'] ||
                c['table'] == 'episode_documents' &&
                    c['id'] == v['document_id'],
          ),
        )
        .toList();
    final affected = approvals
        .where(
          (a) => changes.any(
            (c) =>
                c['table'] == 'care_episodes' && c['id'] == a['episode_id'] ||
                c['table'] == 'episode_documents' &&
                    c['id'] == a['document_id'],
          ),
        )
        .toList();
    final newApprovals = affected
        .where((a) => !invalid.contains(a['approval_id']))
        .map((a) => a['approval_id'] as String)
        .toSet();
    final runs = await rows(db, 'document_control_runs');
    final newRuns = runs
        .where(
          (r) =>
              newApprovals.contains(r['approval_id']) &&
              !controlsInvalid.contains(r['run_id']),
        )
        .map((r) => r['run_id'] as String)
        .toSet();
    final transmissions = MigrationTransmissionSummary();
    try {
      // Same evidence verification as backups, without copying or rebinding.
      await DocumentBackupContents.validate(db, support, [
        for (final name in DocumentBackupContents.names)
          {
            'name': name,
            'sourceRoot': p.join(support.path, name),
            'present': await Directory(p.join(support.path, name)).exists(),
          },
      ], managedDirectory: support);
      for (final a in approvals) {
        final linked = versions.where(
          (v) =>
              v['version_id'] == a['version_id'] &&
              v['document_id'] == a['document_id'] &&
              v['episode_id'] == a['episode_id'] &&
              v['patient_id'] == a['patient_id'],
        );
        if (linked.length != 1) throw const FormatException('approval_orphan');
        final snapshot = jsonDecode(a['snapshot_json'] as String);
        if (medicalHash(snapshot) != a['snapshot_hash']) {
          throw const FormatException('approval_hash');
        }
        // A historical document pointer must still identify its frozen copy.
        final document = snapshot['document'];
        if (document is Map &&
            document['file_path'] is String &&
            !p.equals(
              document['file_path'] as String,
              p.join(
                support.path,
                'episode_document_versions',
                linked.single['relative_path'] as String,
              ),
            )) {
          blockers.add('historical_document_dependency');
        }
        // The episode's DOCX pointer is historical context, not a proof locator.
        final copy = jsonDecode(jsonEncode(snapshot)) as Map;
        (copy['episode'] as Map?)?.remove('initial_report_docx_path');
        (copy['document'] as Map?)?.remove('file_path');
        if (_references(copy, source)) {
          blockers.add('historical_dependency_unknown');
        }
      }
      final steps =
          await DocumentBackupContents.table(db, 'document_chain_steps')
          ? await db.query('document_chain_steps', orderBy: 'rowid')
          : <Map<String, Object?>>[];
      for (final step in steps) {
        if (step['phase'] != 'dv1_reservation') continue;
        final result = await Dv1Records.verify(
          db,
          step,
          controlsRoot: Directory(
            p.join(support.path, 'episode_document_versions', 'controls'),
          ),
        );
        final doc = step['document_id'] as String;
        transmissions.recordDv1(
          doc,
          step['version_id'] as String,
          result['outcome'] as String,
        );
      }
      for (final attempt in await rows(db, 'document_attempts')) {
        final results = await db.query(
          'document_attempt_results',
          where: 'attempt_id=?',
          whereArgs: [attempt['attempt_id']],
        );
        final outcome = results.isEmpty
            ? 'indeterminate'
            : results.single['outcome'] as String;
        if (results.isNotEmpty &&
            (jsonDecode(results.single['evidence_json'] as String)
                    as Map)['outcome'] !=
                outcome) {
          throw const FormatException('result_outcome_mismatch');
        }
        final summary = await DocumentReconciliationRecords.summary(
          db,
          attempt['version_id'] as String,
          attempt['attempt_id'] as String,
          outcome,
        );
        final doc = attempt['document_id'] as String;
        transmissions.recordSimulation(doc, summary['state'] as String);
      }
      // Do not rewrite opaque proof/configuration JSON containing a root path.
      for (final table in [
        'document_control_results',
        'document_chain_steps',
        'document_attempt_results',
        'document_reconciliations',
        'document_dv1_configurations',
        'document_control_config',
        'document_preparations',
      ]) {
        for (final row in await rows(db, table)) {
          for (final entry in row.entries.where(
            (e) => e.key.endsWith('_json'),
          )) {
            if (entry.value is String &&
                _references(jsonDecode(entry.value as String), source)) {
              blockers.add('historical_dependency_unknown');
            }
          }
        }
      }
    } catch (_) {
      blockers.add('historical_evidence_unverifiable');
    }
    if (transmissions.uncertain.isNotEmpty) {
      blockers.add('transmission_uncertain');
    }
    if ((await rows(db, 'document_restore_barriers')).isNotEmpty) {
      blockers.add('restore_barrier');
    }
    // Fail closed, including the global dependencyEpoch retry exception.
    // A rejected lineage superseded by an accepted deposit of the same document
    // no longer needs its earlier retry route.
    if (changes.isNotEmpty && transmissions.hasPendingRetry) {
      blockers.add('dv1_retry_continuity');
    }
    final settings = await db.query(
      'application_settings',
      where: 'setting_key=?',
      whereArgs: ['dmp_enabled'],
    );
    List<String> sorted(Iterable<String> ids) => ids.toList()..sort();
    return MigrationDmpImpact({
      'enabled':
          settings.isNotEmpty &&
          ['true', '1'].contains(settings.single['setting_value']),
      'approvals': sorted(newApprovals),
      'controls': sorted(newRuns),
      'documents': sorted(
        affected.map((a) => a['document_id'] as String).toSet(),
      ),
      'versions': sorted(
        affected.map((a) => a['version_id'] as String).toSet(),
      ),
      'preparingDocuments': sorted(
        affectedVersions
            .where(
              (v) => !approvals.any((a) => a['version_id'] == v['version_id']),
            )
            .map((v) => v['document_id'] as String)
            .toSet(),
      ),
      'alreadyInvalidated': affected
          .where((a) => invalid.contains(a['approval_id']))
          .length,
      'acceptedDocuments': sorted(transmissions.acceptedDocuments),
      'acceptedVersions': sorted(transmissions.acceptedVersions),
      'acceptedSimulationDocuments': sorted(transmissions.acceptedSimulations),
      // This is an impact inventory, never a queue or authorization to send.
      'remainingVersions': sorted(
        affectedVersions
            .where(
              (v) => !transmissions.acceptedVersions.contains(v['version_id']),
            )
            .map((v) => v['version_id'] as String)
            .toSet(),
      ),
      'remainingDocuments': sorted(
        affectedVersions
            .where(
              (v) => !transmissions.acceptedVersions.contains(v['version_id']),
            )
            .map((v) => v['document_id'] as String)
            .toSet(),
      ),
      'uncertainDocuments': sorted(transmissions.uncertain),
      'blockers': sorted(blockers),
    });
  }

  static bool _references(Object? value, String source) {
    if (value is String) {
      return value.contains(source) ||
          (Platform.isWindows &&
              value.toLowerCase().contains(source.toLowerCase()));
    }
    if (value is Map) return value.values.any((v) => _references(v, source));
    if (value is List) return value.any((v) => _references(v, source));
    return false;
  }
}

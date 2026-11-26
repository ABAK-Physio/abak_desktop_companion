import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import '../../features/maintenance/services/backup_directory_access.dart';
import '../../features/patients/services/document_medical_service.dart';
import '../../features/cps/cps_operation_lease.dart';
import 'document_activity_coordinator.dart';
import '../settings/macos_directory_access_service.dart';
import '../settings/generated_documents_directory_service.dart';
import 'migration_dmp_analysis.dart';
import 'migration_files.dart';

const migrationRootKey = 'assessment_documents_directory';
const migrationReceiptPrefix = 'document_root_migration_receipt_v1_';

class MigrationBlocked implements Exception {
  const MigrationBlocked(this.code, {this.dmp});
  final MigrationDmpImpact? dmp;
  final String code;
  @override
  String toString() => 'MigrationBlocked($code)';
}

class MigrationCancellation {
  bool cancelled = false;
  void check() {
    if (cancelled) throw const MigrationBlocked('cancelled');
  }
}

/// Immutable serialized plan, so a consent binds to exactly one inventory and DB.
class DocumentMigrationPlan {
  DocumentMigrationPlan(Map<String, Object?> data)
    : _json = medicalCanonical(data);
  DocumentMigrationPlan._(this._json);
  final String _json;
  Map<String, dynamic> get data => jsonDecode(_json) as Map<String, dynamic>;
  late final String hash = medicalHash(data);
  late final String id = data['id'] as String;
  late final String source = data['source'] as String;
  late final String destination = data['destination'] as String;
  MigrationDmpImpact get dmp =>
      MigrationDmpImpact(Map<String, Object?>.from(data['dmp'] as Map));
  List<Map<String, Object?>> get manifest => _maps(data['manifest']);
  List<Map<String, Object?>> get changes => _maps(data['changes']);
  List<Map<String, Object?>> get associations => _maps(data['associations']);
  List<String> get folders =>
      associations.map((r) => r['folder_name'] as String).toList();
  static List<Map<String, Object?>> _maps(Object? v) =>
      (v as List).map((e) => Map<String, Object?>.from(e as Map)).toList();
}

class MigrationConsent {
  const MigrationConsent({
    required this.planHash,
    this.invalidations = false,
    this.unknownSpace = false,
  });
  final String planHash;
  final bool invalidations, unknownSpace;
}

class MigrationRecovery {
  const MigrationRecovery(this.id, this.state, {this.sourcesRetained = false});
  final bool sourcesRetained;
  final String id;

  /// sourceRetained, committed, or completed; cleanup outcome is separate.
  final String state;
}

/// Migration and manifest-constrained cleanup; no transmission or DMP rule changes.
class DocumentRootMigration {
  DocumentRootMigration({
    required this.database,
    required this.support,
    BackupDirectoryAccess? access,
    DocumentActivityCoordinator? coordinator,
    Future<int?> Function(String)? availableBytes,
    this.checkpoint,
    this.progress,
  }) : access = access ?? const BackupDirectoryAccess(),
       coordinator = coordinator ?? DocumentActivityCoordinator.shared,
       availableBytes = availableBytes ?? MigrationFiles.availableBytes;
  final List<String> diagnostics = [];
  final Database database;
  final Directory support;
  final BackupDirectoryAccess access;
  final DocumentActivityCoordinator coordinator;
  // Unknown is deliberately not conflated with sufficient disk space (D6).
  final Future<int?> Function(String) availableBytes;
  final Future<void> Function(String)? checkpoint;
  final void Function(String phase, int done, int total)? progress;
  Directory get journal =>
      Directory(p.join(support.path, 'document_root_migrations'));

  Future<BackupDirectoryLease?> chooseDestination(String localizedTitle) =>
      access.choose(localizedTitle);

  Future<void> authorizeRoot(String root, String localizedTitle) async {
    if (!Platform.isMacOS) return;
    final lease = await const MacosDirectoryAccessService().chooseDirectory(
      title: localizedTitle,
      expectedPath: root,
      initialPath: root,
    );
    if (lease == null) throw const MigrationBlocked('cancelled');
    try {
      if (!p.equals(lease.path, root)) {
        throw const MigrationBlocked('authorization_root_changed');
      }
    } finally {
      await lease.release();
    }
  }

  Future<T> _exclusive<T>(Future<T> Function() body, {bool recovery = false}) =>
      coordinator.exclusive(() async {
        if (CpsOperationLease.inUse || BackupOperation.isActive) {
          throw const MigrationBlocked('activity_busy');
        }
        await CpsOperationLease.closeIdle();
        return body();
      }, recovery: recovery);

  Future<void> _releaseAll(List<BackupDirectoryLease> leases) async {
    for (final lease in leases.reversed) {
      try {
        await lease.release();
      } catch (_) {
        diagnostics.add('authorization_release_failed');
      }
    }
  }

  Future<BackupDirectoryLease> _acquire(String path) async {
    final lease = await access.acquire(path);
    if (!p.equals(p.normalize(lease.path), p.normalize(path))) {
      await lease.release();
      throw const MigrationBlocked('authorization_root_changed');
    }
    try {
      await MigrationFiles.regular(path, directory: true);
    } catch (_) {
      await lease.release();
      rethrow;
    }
    return lease;
  }

  Future<DocumentMigrationPlan> plan(String destination) =>
      _exclusive(() async {
        await _assertNoPending();
        final source = await _root(database);
        final leases = <BackupDirectoryLease>[];
        try {
          leases.add(await _acquire(source));
          leases.add(await _acquire(destination));
          return await _plan(source, destination, leases);
        } finally {
          await _releaseAll(leases);
        }
      });

  Future<DocumentMigrationPlan> _plan(
    String source,
    String destination,
    List<BackupDirectoryLease> leases, {
    String? id,
  }) async {
    if (!p.isAbsolute(source) ||
        !p.isAbsolute(destination) ||
        p.normalize(source) != source ||
        p.normalize(destination) != destination) {
      throw const MigrationBlocked('invalid_root');
    }
    final actualSource = await Directory(source).resolveSymbolicLinks();
    final actualTarget = await Directory(destination).resolveSymbolicLinks();
    bool overlap(String a, String b) =>
        p.equals(a, b) || p.isWithin(a, b) || p.isWithin(b, a);
    if (overlap(actualSource, actualTarget)) {
      throw const MigrationBlocked('overlapping_roots');
    }
    if (p.isWithin(source, database.path) ||
        p.isWithin(destination, database.path)) {
      throw const MigrationBlocked('database_storage_overlap');
    }
    final actualSupport = await support.resolveSymbolicLinks();
    if (overlap(actualSource, actualSupport) ||
        overlap(actualTarget, actualSupport)) {
      throw const MigrationBlocked('private_storage_overlap');
    }
    if (await Directory(destination).list(followLinks: false).isEmpty ==
        false) {
      throw const MigrationBlocked('destination_not_empty');
    }
    await const GeneratedDocumentsDirectoryService().validateDirectory(
      destination,
    );
    final before = await _databaseHash(database);
    final all = await database.query(
      'patient_document_folders',
      orderBy: 'patient_id,root_path',
    );
    final associations = all.where((r) => r['root_path'] == source).toList();
    final names = <String>{};
    for (final row in associations) {
      final name = row['folder_name'] as String;
      if (name != p.basename(name) ||
          name.contains('\\') ||
          name == '.' ||
          name == '..' ||
          !names.add(name.toLowerCase())) {
        throw const MigrationBlocked('association_conflict');
      }
    }
    final historical = <String>{};
    for (final row in all.where((r) => r['root_path'] != source)) {
      final root = row['root_path'] as String;
      if (p.equals(root, destination)) {
        throw const MigrationBlocked('destination_association');
      }
      if (historical.add(root)) leases.add(await _acquire(root));
      final real = await Directory(root).resolveSymbolicLinks();
      if (overlap(real, actualSource) || overlap(real, actualTarget)) {
        throw const MigrationBlocked('historical_alias');
      }
      final folder = row['folder_name'] as String;
      if (folder != p.basename(folder) ||
          folder.contains('\\') ||
          folder == '.' ||
          folder == '..') {
        throw const MigrationBlocked('association_conflict');
      }
      final entries = await MigrationFiles.inventory(root, [folder]);
      if (entries.any((e) => e['directory'] == false)) {
        throw const MigrationBlocked('historical_consolidation');
      }
    }
    final manifest = await MigrationFiles.inventory(
      source,
      associations.map((r) => r['folder_name'] as String).toList(),
    );
    final files = {
      for (final e in manifest.where((r) => r['directory'] == false))
        p.joinAll([source, ...(e['path'] as String).split('/')]): e,
    };
    final changes = <Map<String, Object?>>[];
    const specs = [
      ['care_episodes', 'care_episode_id', 'initial_report_docx_path'],
      ['episode_documents', 'document_id', 'file_path'],
      ['care_episode_reports', 'report_id', 'docx_file_name'],
      ['care_episode_assessments', 'assessment_id', 'docx_file_name'],
    ];
    for (final spec in specs) {
      for (final row in await MigrationDmpAnalysis.rows(database, spec[0])) {
        final value = row[spec[2]];
        if (value is! String || value.isEmpty || !p.isAbsolute(value)) continue;
        if (p.isWithin(source, value)) {
          if (!files.containsKey(p.normalize(value))) {
            throw const MigrationBlocked('unmapped_document');
          }
          if (spec[0] == 'care_episode_reports' ||
              spec[0] == 'care_episode_assessments') {
            // source_revision hashes the complete source row; never modify it.
            throw const MigrationBlocked('clinical_source_path');
          }
          final next = p.join(destination, p.relative(value, from: source));
          if (value != next) {
            changes.add({
              'table': spec[0],
              'key': spec[1],
              'column': spec[2],
              'id': row[spec[1]],
              'before': value,
              'after': next,
            });
          }
        } else if (spec[0] == 'care_episodes' ||
            spec[0] == 'episode_documents') {
          if (!p.isWithin(support.path, value)) {
            throw const MigrationBlocked('external_document_dependency');
          }
        }
      }
    }
    // Operational paths outside the document whitelist cannot be silently moved.
    const other = {
      'desktop_import_session_files': ['file_path'],
      'desktop_backups': ['file_path'],
      'desktop_restore_history': ['source_backup_path', 'safety_backup_path'],
      'kobus_runs': ['temporary_path'],
      'kobus_items': ['storage_path'],
      'kobus_archives': ['storage_path'],
    };
    for (final entry in other.entries) {
      for (final row in await MigrationDmpAnalysis.rows(database, entry.key)) {
        for (final column in entry.value) {
          final value = row[column];
          if (value is String &&
              p.isAbsolute(value) &&
              (p.equals(source, value) || p.isWithin(source, value))) {
            throw const MigrationBlocked('unclassified_dependency');
          }
        }
      }
    }
    for (final row in await database.query('application_settings')) {
      if (row['setting_key'] == migrationRootKey ||
          (row['setting_key'] as String).startsWith(migrationReceiptPrefix)) {
        continue;
      }
      final value = row['setting_value'];
      if (value is String && p.isAbsolute(value) && overlap(source, value)) {
        throw const MigrationBlocked('settings_dependency');
      }
    }
    final dmp = await MigrationDmpAnalysis.inspect(
      database,
      support,
      source,
      changes,
    );
    if (dmp.blockers.isNotEmpty) {
      throw MigrationBlocked(dmp.blockers.join(','), dmp: dmp);
    }
    final space = await availableBytes(destination);
    final bytes = manifest.fold<int>(0, (n, e) => n + (e['size'] as int? ?? 0));
    if (space != null && space < bytes) {
      throw const MigrationBlocked('insufficient_space');
    }
    final foreign =
        (await Directory(source).list(followLinks: false).toList())
            .map((e) => p.basename(e.path))
            .where((n) => !associations.any((a) => a['folder_name'] == n))
            .toList()
          ..sort();
    if (before != await _databaseHash(database)) {
      throw const MigrationBlocked('plan_changed');
    }
    return DocumentMigrationPlan({
      'format': 1,
      'deleteTransferredSources': true,
      'id': id ?? const Uuid().v4(),
      'source': source,
      'destination': destination,
      'actualSource': actualSource,
      'actualDestination': actualTarget,
      'associations': associations,
      'manifest': manifest,
      'changes': changes,
      'databaseHash': before,
      'bytes': bytes,
      'files': files.length,
      'directories': manifest.length - files.length,
      'foreignEntries': foreign,
      'historicalEmptyRoots': historical.toList()..sort(),
      'spaceUnknown': space == null,
      'dmp': dmp.data,
    });
  }

  /// Returns whether any transferred sources could not be safely removed.
  Future<bool> execute(
    DocumentMigrationPlan plan,
    MigrationConsent consent, {
    MigrationCancellation? cancellation,
  }) => _exclusive(() async {
    progress?.call('preflight', 0, 0);
    final token = cancellation ?? MigrationCancellation();
    final manifest = plan.manifest;
    final folders = plan.folders;
    if (consent.planHash != plan.hash ||
        plan.dmp.requiresConsent && !consent.invalidations ||
        plan.data['spaceUnknown'] == true && !consent.unknownSpace) {
      throw const MigrationBlocked('explicit_consent_required');
    }
    await _assertNoPending();
    final leases = <BackupDirectoryLease>[];
    var journalStarted = false;
    try {
      leases.add(await _acquire(plan.source));
      leases.add(await _acquire(plan.destination));
      token.check();
      final fresh = await _plan(
        plan.source,
        plan.destination,
        leases,
        id: plan.id,
      );
      if (fresh.hash != plan.hash) throw const MigrationBlocked('plan_changed');
      await _write(plan, 'prepared');
      journalStarted = true;
      coordinator.recoveryRequired = true;
      await checkpoint?.call('prepared');
      token.check();
      final stage = Directory(
        p.join(plan.destination, '.abak_migration_${plan.id}'),
      );
      if (await FileSystemEntity.type(stage.path, followLinks: false) !=
          FileSystemEntityType.notFound) {
        throw const MigrationBlocked('destination_conflict');
      }
      await stage.create();
      await MigrationFiles.syncDirectory(plan.destination);
      progress?.call('copy', 0, manifest.length);
      await MigrationFiles.copy(
        plan.source,
        stage.path,
        manifest,
        checkCancelled: token.check,
        progress: (n) async {
          progress?.call('copy', n, manifest.length);
          await checkpoint?.call('copy:$n');
        },
      );
      progress?.call('verifying', 0, 0);
      await checkpoint?.call('copied');
      token.check();
      await _verify(plan, stage.path);
      await _verify(plan, plan.source);
      await _write(plan, 'installing');
      for (final folder in folders) {
        token.check();
        await MigrationFiles.install(
          p.join(stage.path, folder),
          p.join(plan.destination, folder),
        );
        await MigrationFiles.syncDirectory(plan.destination);
        await checkpoint?.call('installed:$folder');
      }
      await stage.delete();
      await MigrationFiles.syncDirectory(plan.destination);
      await _verify(plan, plan.destination);
      await _verify(plan, plan.source);
      if ((await Directory(
            plan.destination,
          ).list(followLinks: false).toList()).length !=
          folders.length) {
        throw const MigrationBlocked('destination_changed');
      }
      final restored = await _acquire(plan.destination);
      await restored.release();
      await _write(plan, 'committing');
      await checkpoint?.call('beforeCommit');
      token.check();
      // Repeat physical and historical checks after the last interruptible hook.
      await _verify(plan, plan.source);
      await _verify(plan, plan.destination);
      final impact = await MigrationDmpAnalysis.inspect(
        database,
        support,
        plan.source,
        plan.changes,
      );
      if (medicalHash(impact.data) != medicalHash(plan.dmp.data)) {
        throw const MigrationBlocked('plan_changed');
      }
      token.check();
      progress?.call('activating', 0, 0);
      await database.transaction((tx) async {
        if (await _databaseHash(tx) != plan.data['databaseHash']) {
          throw const MigrationBlocked('plan_changed');
        }
        for (final row in plan.associations) {
          final n = await tx.update(
            'patient_document_folders',
            {'root_path': plan.destination},
            where: 'patient_id=? AND root_path=? AND folder_name=?',
            whereArgs: [row['patient_id'], plan.source, row['folder_name']],
          );
          if (n != 1) throw const MigrationBlocked('association_changed');
        }
        for (final c in plan.changes) {
          final n = await tx.update(
            c['table'] as String,
            {c['column'] as String: c['after']},
            where: '${c['key']}=? AND ${c['column']}=?',
            whereArgs: [c['id'], c['before']],
          );
          if (n != 1) throw const MigrationBlocked('reference_changed');
        }
        final n = await tx.update(
          'application_settings',
          {'setting_value': plan.destination},
          where: 'setting_key=? AND setting_value=?',
          whereArgs: [migrationRootKey, plan.source],
        );
        if (n != 1) throw const MigrationBlocked('root_changed');
        await tx.insert('application_settings', {
          'setting_key': '$migrationReceiptPrefix${plan.id}',
          'setting_value': medicalCanonical({
            'id': plan.id,
            'hash': plan.hash,
            'destination': plan.destination,
          }),
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        });
        await checkpoint?.call('transaction');
      });
      await checkpoint?.call('afterCommit');
      final retained = await _cleanup(plan);
      await _write(plan, retained ? 'completedWithRetained' : 'completed');
      coordinator.recoveryRequired = false;
      progress?.call('completed', manifest.length, manifest.length);
      return retained;
    } catch (_) {
      // No guessing, rollback-by-path, deletion, or automatic retry after a crash.
      if (journalStarted) coordinator.recoveryRequired = true;
      rethrow;
    } finally {
      await _releaseAll(leases);
    }
  });

  Future<List<MigrationRecoveryDetails>> recoveryDetails() async {
    final records = await _records();
    final result = <MigrationRecoveryDetails>[];
    for (final record in records) {
      if ([
        'completed',
        'completedWithRetained',
        'abandoned',
      ].contains(record.$2)) {
        continue;
      }
      final receipt = await database.query(
        'application_settings',
        where: 'setting_key=?',
        whereArgs: ['$migrationReceiptPrefix${record.$1.id}'],
      );
      if (receipt.isNotEmpty) {
        final plan = record.$1;
        final expected = medicalCanonical({
          'id': plan.id,
          'hash': plan.hash,
          'destination': plan.destination,
        });
        if (receipt.single['setting_value'] != expected) {
          throw const MigrationBlocked('receipt_conflict');
        }
        if (await _root(database) != plan.destination) {
          throw const MigrationBlocked('committed_root_conflict');
        }
      }
      result.add(MigrationRecoveryDetails(record.$1, receipt.isNotEmpty));
    }
    return result;
  }

  Future<List<MigrationRecovery>> recover() => _exclusive(() async {
    coordinator.recoveryRequired = true;
    final result = <MigrationRecovery>[];
    final records = await _records();
    final receipts = await database.query(
      'application_settings',
      where: 'setting_key GLOB ?',
      whereArgs: ['$migrationReceiptPrefix*'],
    );
    for (final receipt in receipts) {
      if (!records.any(
        (r) => '$migrationReceiptPrefix${r.$1.id}' == receipt['setting_key'],
      )) {
        throw const MigrationBlocked('journal_missing');
      }
    }
    for (final record in records) {
      final plan = record.$1, state = record.$2;
      final receipt = await database.query(
        'application_settings',
        where: 'setting_key=?',
        whereArgs: ['$migrationReceiptPrefix${plan.id}'],
      );
      if (receipt.isNotEmpty) {
        final expected = medicalCanonical({
          'id': plan.id,
          'hash': plan.hash,
          'destination': plan.destination,
        });
        if (receipt.single['setting_value'] != expected ||
            state == 'abandoned') {
          throw const MigrationBlocked('receipt_conflict');
        }
        if (['completed', 'completedWithRetained'].contains(state)) {
          result.add(
            MigrationRecovery(
              plan.id,
              'completed',
              sourcesRetained:
                  state == 'completedWithRetained' ||
                  plan.data['deleteTransferredSources'] != true,
            ),
          );
          continue;
        }
        if (await _root(database) != plan.destination) {
          throw const MigrationBlocked('committed_root_conflict');
        }
        // Legacy consent retained sources: preserve its original recovery checks.
        if (plan.data['deleteTransferredSources'] != true) {
          await _verifyReferences(plan, committed: true);
          final lease = await _acquire(plan.destination);
          try {
            await _verify(plan, plan.destination);
          } finally {
            await _releaseAll([lease]);
          }
        }
        final retained = await _cleanup(plan, acquire: true);
        await _write(plan, retained ? 'completedWithRetained' : 'completed');
        result.add(
          MigrationRecovery(plan.id, 'committed', sourcesRetained: retained),
        );
      } else {
        if ([
          'completed',
          'completedWithRetained',
          'cleaning',
        ].contains(state)) {
          throw const MigrationBlocked('receipt_missing');
        }
        if (state == 'abandoned') continue;
        if (await _root(database) != plan.source) {
          throw const MigrationBlocked('source_root_conflict');
        }
        await _verifyReferences(plan, committed: false);
        // Leave all partial copies untouched, including unknown destination files.
        // Uncommitted migrations never authorize source cleanup.
        await _write(plan, 'abandoned');
        result.add(MigrationRecovery(plan.id, 'sourceRetained'));
      }
    }
    coordinator.recoveryRequired = false;
    return result;
  }, recovery: true);

  /// Returns true when anything could not be safely removed. A durable cleaning
  /// record precedes every deletion; restart rechecks the remaining manifest.
  Future<bool> _cleanup(
    DocumentMigrationPlan plan, {
    bool acquire = false,
  }) async {
    if (plan.data['deleteTransferredSources'] != true) return true;
    await _write(plan, 'cleaning');
    await checkpoint?.call('cleanupStarted');
    final leases = <BackupDirectoryLease>[];
    var retained = false;
    final files = plan.manifest.where((e) => e['directory'] == false).toList();
    progress?.call('cleaning', 0, files.length);
    try {
      try {
        if (await _root(database) != plan.destination) {
          throw const MigrationBlocked('committed_root_conflict');
        }
        await _verifyReferences(plan, committed: true);
        if (acquire) {
          leases.add(await _acquire(plan.destination));
          leases.add(await _acquire(plan.source));
        }
        await _cleanupDependencies(plan);
        await _cleanupPath(plan, plan.source);
        await _cleanupPath(plan, plan.destination);
      } catch (_) {
        diagnostics.add('cleanup_safety_unverifiable');
        return true;
      }
      var done = 0;
      for (final entry in files) {
        final relative = entry['path'] as String;
        // Hooks are outside the per-file error handler to simulate interruption.
        await checkpoint?.call('beforeDelete:$relative');
        try {
          await _cleanupPath(plan, plan.source, relative: relative);
          final from = p.joinAll([plan.source, ...relative.split('/')]);
          if (await FileSystemEntity.type(from, followLinks: false) !=
              FileSystemEntityType.notFound) {
            await _cleanupPath(plan, plan.destination, relative: relative);
            final copied = await MigrationFiles.inventory(plan.destination, [
              relative,
            ]);
            final original = await MigrationFiles.inventory(plan.source, [
              relative,
            ]);
            if (medicalHash(copied) != medicalHash([entry]) ||
                medicalHash(original) != medicalHash([entry])) {
              throw const MigrationBlocked('cleanup_content_changed');
            }
            await checkpoint?.call('deleting:$relative');
            await File(from).delete();
            await MigrationFiles.syncDirectory(p.dirname(from));
          }
        } catch (_) {
          retained = true;
          diagnostics.add('cleanup_file_retained');
        }
        progress?.call('cleaning', ++done, files.length);
        await checkpoint?.call('deleted:$relative');
      }
      // Only manifest directories, deepest first; never recursive deletion.
      for (final entry in plan.manifest.reversed.where(
        (e) => e['directory'] == true,
      )) {
        final relative = entry['path'] as String;
        final path = p.joinAll([plan.source, ...relative.split('/')]);
        try {
          await _cleanupPath(plan, plan.source, relative: relative);
          if (await FileSystemEntity.type(path, followLinks: false) ==
              FileSystemEntityType.notFound) {
            continue;
          }
          await MigrationFiles.regular(path, directory: true);
          if (await Directory(path).list(followLinks: false).isEmpty) {
            await Directory(path).delete();
            await MigrationFiles.syncDirectory(p.dirname(path));
          }
        } catch (_) {
          retained = true;
          diagnostics.add('cleanup_directory_retained');
        }
      }
      try {
        await _cleanupPath(plan, plan.source);
        if (await Directory(plan.source).list(followLinks: false).isEmpty) {
          await Directory(plan.source).delete();
          await MigrationFiles.syncDirectory(p.dirname(plan.source));
        }
      } catch (_) {
        retained = true;
        diagnostics.add('cleanup_root_retained');
      }
      return retained;
    } finally {
      await _releaseAll(leases);
    }
  }

  Future<void> _cleanupPath(
    DocumentMigrationPlan plan,
    String root, {
    String? relative,
  }) async {
    await MigrationFiles.regular(root, directory: true);
    final expected = root == plan.source
        ? plan.data['actualSource']
        : plan.data['actualDestination'];
    if (await Directory(root).resolveSymbolicLinks() != expected) {
      throw const MigrationBlocked('root_identity_changed');
    }
    if (relative == null) return;
    final segments = relative.split('/');
    if (p.isAbsolute(relative) ||
        segments.any(
          (s) => s.isEmpty || s == '.' || s == '..' || s.contains('\\'),
        )) {
      throw const MigrationBlocked('invalid_manifest_path');
    }
    var parent = root;
    for (final part in segments.take(segments.length - 1)) {
      parent = p.join(parent, part);
      if (await FileSystemEntity.type(parent, followLinks: false) ==
          FileSystemEntityType.notFound) {
        return;
      }
      await MigrationFiles.regular(parent, directory: true);
    }
  }

  Future<void> _cleanupDependencies(DocumentMigrationPlan plan) async {
    final impact = await MigrationDmpAnalysis.inspect(
      database,
      support,
      plan.source,
      [],
    );
    if (impact.blockers.isNotEmpty) {
      throw const MigrationBlocked('cleanup_historical_dependency');
    }
    // Recheck live pointers, including changes made between commit and restart.
    const columns = {
      'patient_document_folders': ['root_path'],
      'care_episodes': ['initial_report_docx_path'],
      'episode_documents': ['file_path'],
      'care_episode_reports': ['docx_file_name'],
      'care_episode_assessments': ['docx_file_name'],
      'desktop_import_session_files': ['file_path'],
      'desktop_backups': ['file_path'],
      'desktop_restore_history': ['source_backup_path', 'safety_backup_path'],
      'kobus_runs': ['temporary_path'],
      'kobus_items': ['storage_path'],
      'kobus_archives': ['storage_path'],
      'application_settings': ['setting_value'],
    };
    for (final spec in columns.entries) {
      for (final row in await MigrationDmpAnalysis.rows(database, spec.key)) {
        if (spec.key == 'application_settings' &&
            (row['setting_key'] as String).startsWith(migrationReceiptPrefix)) {
          continue;
        }
        for (final column in spec.value) {
          final value = row[column];
          if (value is String &&
              p.isAbsolute(value) &&
              (p.equals(plan.source, value) ||
                  p.isWithin(plan.source, value))) {
            throw const MigrationBlocked('cleanup_live_dependency');
          }
        }
      }
    }
  }

  Future<void> _verifyReferences(
    DocumentMigrationPlan plan, {
    required bool committed,
  }) async {
    for (final a in plan.associations) {
      final rows = await database.query(
        'patient_document_folders',
        where: 'patient_id=? AND root_path=? AND folder_name=?',
        whereArgs: [
          a['patient_id'],
          committed ? plan.destination : plan.source,
          a['folder_name'],
        ],
      );
      if (rows.length != 1) {
        throw const MigrationBlocked('recovery_association_conflict');
      }
    }
    for (final c in plan.changes) {
      final rows = await database.query(
        c['table'] as String,
        where: '${c['key']}=?',
        whereArgs: [c['id']],
      );
      if (rows.length != 1 ||
          rows.single[c['column']] != c[committed ? 'after' : 'before']) {
        throw const MigrationBlocked('recovery_reference_conflict');
      }
    }
  }

  Future<void> _verify(DocumentMigrationPlan plan, String root) async {
    await MigrationFiles.regular(root, directory: true);
    final actual = await Directory(root).resolveSymbolicLinks();
    if (root == plan.source && actual != plan.data['actualSource'] ||
        root == plan.destination && actual != plan.data['actualDestination']) {
      throw const MigrationBlocked('root_identity_changed');
    }
    if (medicalHash(await MigrationFiles.inventory(root, plan.folders)) !=
        medicalHash(plan.manifest)) {
      throw const MigrationBlocked('manifest_mismatch');
    }
  }

  static Future<String> _root(DatabaseExecutor db) async {
    final rows = await db.query(
      'application_settings',
      where: 'setting_key=?',
      whereArgs: [migrationRootKey],
    );
    if (rows.length != 1 || (rows.single['setting_value'] as String).isEmpty) {
      throw const MigrationBlocked('root_not_configured');
    }
    return rows.single['setting_value'] as String;
  }

  static Future<String> _databaseHash(DatabaseExecutor db) async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%' ORDER BY name",
    );
    final data = <String, Object?>{};
    for (final table in tables) {
      final name = table['name'] as String;
      final rows = await db.rawQuery(
        'SELECT * FROM "${name.replaceAll('"', '""')}"',
      );
      data[name] = rows.map(medicalCanonical).toList()..sort();
    }
    return medicalHash(data);
  }

  Future<void> _assertNoPending() async {
    for (final record in await _records()) {
      if (![
        'completed',
        'completedWithRetained',
        'abandoned',
      ].contains(record.$2)) {
        throw const MigrationBlocked('recovery_required');
      }
    }
  }

  Future<void> _write(DocumentMigrationPlan plan, String state) async {
    await journal.create(recursive: true);
    MigrationFiles.protectJournalDirectory(journal.path);
    final dir = Directory(p.join(journal.path, plan.id));
    await dir.create();
    MigrationFiles.protectJournalDirectory(dir.path);
    await MigrationFiles.syncDirectory(support.path);
    await MigrationFiles.syncDirectory(journal.path);
    final files = await dir.list(followLinks: false).toList();
    final sequence = files.where((f) => f.path.endsWith('.json')).length;
    final payload = {
      'format': 1,
      'sequence': sequence,
      'state': state,
      'plan': plan.data,
      'planHash': plan.hash,
    };
    final tmp = File(p.join(dir.path, '${const Uuid().v4()}.tmp'));
    await tmp.writeAsString(
      jsonEncode({'payload': payload, 'hash': medicalHash(payload)}),
      flush: true,
    );
    await MigrationFiles.install(
      tmp.path,
      p.join(dir.path, '${sequence.toString().padLeft(6, '0')}.json'),
    );
    await MigrationFiles.syncDirectory(dir.path);
  }

  Future<List<(DocumentMigrationPlan, String)>> _records() async {
    if (!await journal.exists()) return [];
    await MigrationFiles.regular(journal.path, directory: true);
    final result = <(DocumentMigrationPlan, String)>[];
    final dirs = await journal.list(followLinks: false).toList();
    dirs.sort((a, b) => a.path.compareTo(b.path));
    for (final dir in dirs) {
      await MigrationFiles.regular(dir.path, directory: true);
      if (!RegExp(r'^[0-9a-f-]{36}$').hasMatch(p.basename(dir.path))) {
        throw const MigrationBlocked('journal_corrupt');
      }
      final entries = await Directory(
        dir.path,
      ).list(followLinks: false).toList();
      if (entries.any(
        (e) => !e.path.endsWith('.json') && !e.path.endsWith('.tmp'),
      )) {
        throw const MigrationBlocked('journal_corrupt');
      }
      final files = entries.where((e) => e.path.endsWith('.json')).toList()
        ..sort((a, b) => a.path.compareTo(b.path));
      if (files.isEmpty) throw const MigrationBlocked('journal_incomplete');
      DocumentMigrationPlan? plan;
      String? state;
      for (var i = 0; i < files.length; i++) {
        await MigrationFiles.regular(files[i].path, directory: false);
        final envelope =
            jsonDecode(await File(files[i].path).readAsString()) as Map;
        final payload = envelope['payload'] as Map;
        final next = DocumentMigrationPlan._(medicalCanonical(payload['plan']));
        if (payload['format'] != 1 ||
            payload['sequence'] != i ||
            medicalHash(payload) != envelope['hash'] ||
            payload['planHash'] != next.hash ||
            next.id != p.basename(dir.path) ||
            plan != null && plan.hash != next.hash ||
            ![
              'prepared',
              'installing',
              'committing',
              'completed',
              'completedWithRetained',
              'cleaning',
              'abandoned',
            ].contains(payload['state'])) {
          throw const MigrationBlocked('journal_corrupt');
        }
        plan = next;
        state = payload['state'] as String;
      }
      result.add((plan!, state!));
    }
    return result;
  }
}

class MigrationRecoveryDetails {
  const MigrationRecoveryDetails(this.plan, this.committed);
  final DocumentMigrationPlan plan;
  final bool committed;
  String get requiredRoot => committed ? plan.destination : plan.source;
}

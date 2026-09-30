import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_service.dart';
import '../../../core/settings/application_settings_service.dart';
import '../../../generated/l10n.dart';
import '../../maintenance/services/backup_directory_access.dart';
import '../../maintenance/services/companion_backup_archive.dart';
import '../models/restore_result.dart';

class LocalDatabaseRestoreService {
  const LocalDatabaseRestoreService({
    this.access = const BackupDirectoryAccess(),
  });
  final BackupDirectoryAccess access;

  Future<RestoreResult> restoreDatabase({required String backupPath}) async {
    try {
      return await BackupOperation.run(() => _restore(backupPath));
    } catch (error) {
      return RestoreResult(
        success: false,
        message: S.current.localDatabaseRestoreService_failure(
          error.toString(),
        ),
        sourceBackupPath: backupPath,
      );
    }
  }

  // Separate the final file installation so rollback can be fault-tested.
  Future<void> installDatabase(String source, String destination) async {
    await File(source).copy(destination);
  }

  Future<RestoreResult> _restore(String backupPath) async {
    final leases = <BackupDirectoryLease>[];
    final roots = <String, BackupDirectoryLease>{};
    final plans = <_FolderRestore>[];
    PreparedBackup? prepared;
    Database? candidate;
    String? safetyBackupPath;
    String? databasePath;
    bool replacedDatabase = false;
    bool committed = false;
    bool restoring = false;
    final id = const Uuid().v4();
    final stamp =
        '${DateTime.now().toIso8601String().replaceAll(RegExp(r'[^0-9]'), '')}_$id';
    try {
      // Restore persistent authorization for backups selected from history.
      final sourceAccess = await access.read(p.dirname(backupPath));
      leases.add(sourceAccess);
      final source = p.join(sourceAccess.path, p.basename(backupPath));
      if (!await File(source).exists()) {
        throw FileSystemException(
          S.current.localDatabaseRestoreService_missing,
          source,
        );
      }
      final current = await DatabaseService.database;
      prepared = await const CompanionBackupArchive().prepare(source);
      candidate = await DatabaseService.openDatabaseFile(prepared.databasePath);
      final currentRows = await current.query('patient_document_folders');
      if (prepared.legacy) {
        // Older .db files predate document associations. Keep links to current
        // folders for patients that also exist in the restored database.
        final patientIds = (await candidate.query(
          'patients',
          columns: ['patient_id'],
        )).map((row) => row['patient_id']).toSet();
        for (final row in currentRows) {
          if (patientIds.contains(row['patient_id'])) {
            await candidate.insert(
              'patient_document_folders',
              row,
              conflictAlgorithm: ConflictAlgorithm.ignore,
            );
          }
        }
      }

      final destinations = <String>{};
      for (final folder in prepared.folders) {
        final root = folder['sourceRoot'] as String;
        if (roots.containsKey(root)) continue;
        final lease = await access.restore(root);
        leases.add(lease);
        // Distinct original roots must not be merged implicitly.
        final canonical = await Directory(lease.path).resolveSymbolicLinks();
        if (!destinations.add(canonical.toLowerCase())) {
          throw const FormatException(
            'Choisissez un emplacement distinct pour chaque dossier d’origine',
          );
        }
        roots[root] = lease;
      }
      if (!prepared.legacy) await candidate.delete('patient_document_folders');
      final reserved = <String>{};
      for (final folder in prepared.folders) {
        final root = roots[folder['sourceRoot']]!.path;
        final patientId = folder['patientId'] as String;
        final currentMatches = currentRows.where(
          (r) =>
              r['patient_id'] == patientId &&
              p.equals(r['root_path'] as String, root),
        );
        var name = currentMatches.isEmpty
            ? folder['folderName'] as String
            : currentMatches.first['folder_name'] as String;
        CompanionBackupArchive.validatePath(name);
        if (name.contains('/')) {
          throw const FormatException('Nom de dossier patient invalide');
        }
        var destination = p.join(root, name);
        if (currentMatches.isEmpty) {
          final base = name;
          var suffix = 2;
          while (await FileSystemEntity.type(destination, followLinks: false) !=
                  FileSystemEntityType.notFound ||
              currentRows.any(
                (r) =>
                    p.equals(r['root_path'] as String, root) &&
                    (r['folder_name'] as String).toLowerCase() ==
                        name.toLowerCase(),
              ) ||
              reserved.contains(destination.toLowerCase())) {
            name = '${base}_$suffix';
            suffix++;
            destination = p.join(root, name);
          }
        }
        if (!reserved.add(destination.toLowerCase())) {
          throw const FormatException('Collision entre dossiers patients');
        }
        final type = await FileSystemEntity.type(
          destination,
          followLinks: false,
        );
        if (type != FileSystemEntityType.directory &&
            type != FileSystemEntityType.notFound) {
          throw FileSystemException(
            'Un fichier ou un lien occupe le dossier patient',
            destination,
          );
        }
        final temporary = p.join(root, '.abak_restore_$id', '${plans.length}');
        final safety = p.join(root, 'ABAK_AVANT_RESTAURATION_$stamp', name);
        final plan = _FolderRestore(
          destination,
          temporary,
          safety,
          type == FileSystemEntityType.directory,
        );
        plans.add(plan);
        if (plan.hadOriginal) {
          await CompanionBackupArchive.copyTree(
            Directory(destination),
            Directory(temporary),
          );
        } else {
          await Directory(temporary).create(recursive: true);
        }
        // Overlay the saved versions in staging; newer, unrelated files remain.
        await CompanionBackupArchive.copyTree(
          Directory(
            p.join(prepared.directory.path, folder['archivePath'] as String),
          ),
          Directory(temporary),
        );
        for (final child in ['Bilan', 'Rapport', 'Autre']) {
          await Directory(p.join(temporary, child)).create();
        }
        await candidate.insert('patient_document_folders', {
          'patient_id': patientId,
          'root_path': root,
          'folder_name': name,
        });
      }
      // Rebind the configured root to the authorized destination on this machine.
      final configured = await candidate.query(
        'application_settings',
        where: 'setting_key = ?',
        whereArgs: [ApplicationSettingsService.assessmentDocumentsDirectoryKey],
      );
      if (configured.isNotEmpty) {
        final relocated = roots[configured.first['setting_value']];
        if (relocated != null) {
          await candidate.update(
            'application_settings',
            {'setting_value': relocated.path},
            where: 'setting_key = ?',
            whereArgs: [
              ApplicationSettingsService.assessmentDocumentsDirectoryKey,
            ],
          );
        }
      }
      final safetyDirectory = Directory(
        p.join(
          p.dirname(await DatabaseService.databasePath),
          'pre_restore_$stamp',
        ),
      );
      await safetyDirectory.create();
      safetyBackupPath = p.join(safetyDirectory.path, 'database.db');
      await File(p.join(safetyDirectory.path, 'documents.json')).writeAsString(
        jsonEncode([
          for (final plan in plans)
            {
              'destination': plan.destination,
              'previousVersion': plan.hadOriginal ? plan.safety : null,
            },
        ]),
      );
      final documentSafetyPaths = plans
          .where((p) => p.hadOriginal)
          .map((p) => p.safety)
          .toList();
      final message =
          '${S.current.localDatabaseRestoreService_success}'
          '${prepared.legacy ? '\n${S.current.backupArchive_legacy}' : ''}\n'
          '${S.current.backupArchive_safetyCopies}\n$safetyBackupPath'
          '${documentSafetyPaths.isEmpty ? '' : '\n${documentSafetyPaths.join('\n')}'}';
      // Keep the selected archive available even though its history entry was
      // written after the database snapshot inside that archive.
      final knownBackup = await candidate.query(
        'desktop_backups',
        where: 'file_path = ?',
        whereArgs: [source],
        limit: 1,
      );
      if (knownBackup.isEmpty) {
        await candidate.insert('desktop_backups', {
          'backup_id': const Uuid().v4(),
          'file_name': p.basename(source),
          'file_path': source,
          'created_at': (await File(
            source,
          ).lastModified()).millisecondsSinceEpoch,
          'file_size': await File(source).length(),
          'status': 'completed',
          'notes': null,
        });
      }
      await candidate.insert('desktop_restore_history', {
        'restore_id': id,
        'restored_at': DateTime.now().millisecondsSinceEpoch,
        'source_backup_path': backupPath,
        'safety_backup_path': safetyBackupPath,
        'success': 1,
        'message': message,
      });
      await candidate.close();
      candidate = null;
      await CompanionBackupArchive.validateDatabase(prepared.databasePath);
      databasePath = await DatabaseService.databasePath;
      await DatabaseService.beginRestore();
      restoring = true;
      await File(databasePath).copy(safetyBackupPath);
      // The originals stay on the same volume and are renamed, never overwritten.
      for (final plan in plans) {
        if (plan.hadOriginal) {
          await Directory(p.dirname(plan.safety)).create(recursive: true);
          await Directory(plan.destination).rename(plan.safety);
          plan.originalMoved = true;
        }
        await Directory(plan.temporary).rename(plan.destination);
        plan.installed = true;
      }
      replacedDatabase = true;
      await installDatabase(prepared.databasePath, databasePath);
      await DatabaseService.endRestore();
      restoring = false;
      committed = true;
      return RestoreResult(
        success: true,
        message: message,
        sourceBackupPath: backupPath,
        safetyBackupPath: safetyBackupPath,
        documentSafetyPaths: documentSafetyPaths,
      );
    } catch (error) {
      final rollbackErrors = <String>[];
      if (replacedDatabase &&
          databasePath != null &&
          safetyBackupPath != null) {
        try {
          await DatabaseService.closeDatabase();
          await File(safetyBackupPath).copy(databasePath);
        } catch (rollback) {
          rollbackErrors.add(rollback.toString());
        }
      }
      for (final plan in plans.reversed) {
        try {
          if (plan.installed) {
            await Directory(plan.destination).delete(recursive: true);
          }
          if (plan.originalMoved) {
            await Directory(plan.safety).rename(plan.destination);
          }
        } catch (rollback) {
          rollbackErrors.add(rollback.toString());
        }
      }
      return RestoreResult(
        success: false,
        message: S.current.localDatabaseRestoreService_failure(
          '$error${rollbackErrors.isEmpty ? '' : '\nRetour à l’état précédent incomplet : ${rollbackErrors.join('; ')}\n$safetyBackupPath'}',
        ),
        sourceBackupPath: backupPath,
        safetyBackupPath: safetyBackupPath,
      );
    } finally {
      await candidate?.close();
      // Only discard our private staging folders, never a safety copy.
      for (final root in roots.values) {
        final temp = Directory(p.join(root.path, '.abak_restore_$id'));
        try {
          if (await temp.exists()) await temp.delete(recursive: true);
        } catch (_) {}
      }
      try {
        await prepared?.dispose();
      } catch (_) {}
      for (final lease in leases.reversed) {
        try {
          await lease.release();
        } catch (_) {}
      }
      if (restoring) await DatabaseService.endRestore();
      if (!committed) {
        await DatabaseService.database;
      }
    }
  }
}

class _FolderRestore {
  _FolderRestore(
    this.destination,
    this.temporary,
    this.safety,
    this.hadOriginal,
  );
  final String destination;
  final String temporary;
  final String safety;
  final bool hadOriginal;
  bool originalMoved = false;
  bool installed = false;
}

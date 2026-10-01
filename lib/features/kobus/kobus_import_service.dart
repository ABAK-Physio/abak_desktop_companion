import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import '../../core/database/database_service.dart';
import '../patients/models/patient.dart';
import 'kobus_identity.dart';
import 'kobus_models.dart';

class KobusImportService {
  KobusImportService({this.database, this.storageRoot, this.beforeCopy});
  final Database? database;
  final String? storageRoot;
  final Future<void> Function(KobusFolder)? beforeCopy;
  static bool running = false;
  bool stopRequested = false;
  Future<Database> get db async => database ?? await DatabaseService.database;
  Future<String> get root async =>
      storageRoot ??
      p.join((await getApplicationSupportDirectory()).path, 'kobus_archives');

  Future<List<Map<String, Object?>>> history() async =>
      (await db).query('kobus_runs', orderBy: 'started_at DESC');
  Future<List<Map<String, Object?>>> items(String run) async =>
      (await db).query(
        'kobus_items',
        where: 'run_id = ?',
        whereArgs: [run],
        orderBy: 'source_path',
      );
  Future<List<Map<String, Object?>>> archives(String patient) async =>
      (await db).query(
        'kobus_archives',
        where: 'patient_id = ?',
        whereArgs: [patient],
      );

  Future<String> patientDirectory(String patient) async {
    final rows = await archives(patient);
    if (rows.isEmpty) throw StateError('Aucune archive KOBUS rattachée.');
    final directory = p.join(await root, patient);
    for (final row in rows) {
      if (!await Directory(row['storage_path'] as String).exists()) {
        throw StateError('Une archive KOBUS est introuvable.');
      }
    }
    if (!await Directory(directory).exists()) {
      throw StateError('Dossier KOBUS introuvable.');
    }
    return directory;
  }

  /// Final database transaction is the commit record. A crash before it leaves
  /// only an unreferenced directory and a pending item; recover both together.
  Future<void> recover() async {
    if (running) return;
    final database = await db;
    for (final run in await database.query(
      'kobus_runs',
      where: "status = 'running'",
    )) {
      final id = run['run_id'] as String;
      for (final item in await items(id)) {
        if (item['status'] != 'pending') continue;
        final path = item['storage_path'] as String?;
        if (path != null) await _removeUncommitted(database, path);
      }
      final temporary = run['temporary_path'] as String?;
      if (temporary != null &&
          p.isWithin(Directory.systemTemp.path, temporary) &&
          p.basename(temporary).startsWith('abak_kobus_') &&
          await Directory(temporary).exists()) {
        await Directory(temporary).delete(recursive: true);
      }
      await database.transaction((txn) async {
        await txn.update(
          'kobus_items',
          {
            'status': 'interrupted',
            'reason': 'Import interrompu avant finalisation.',
          },
          where: 'run_id = ? AND status = ?',
          whereArgs: [id, 'pending'],
        );
        await txn.update(
          'kobus_runs',
          {
            'status': 'interrupted',
            'finished_at': DateTime.now().millisecondsSinceEpoch,
          },
          where: 'run_id = ?',
          whereArgs: [id],
        );
      });
    }
  }

  Future<void> _removeUncommitted(
    DatabaseExecutor database,
    String path,
  ) async {
    if (!p.isWithin(await root, path)) {
      throw StateError('Chemin de nettoyage hors stockage KOBUS.');
    }
    if ((await database.query(
      'kobus_archives',
      where: 'storage_path = ?',
      whereArgs: [path],
    )).isNotEmpty) {
      return;
    }
    if (await Directory(path).exists()) {
      await Directory(path).delete(recursive: true);
    }
    var parent = Directory(p.dirname(path));
    while (p.isWithin(await root, parent.path) &&
        await parent.exists() &&
        await parent.list().isEmpty) {
      await parent.delete();
      parent = parent.parent;
    }
  }

  Future<String> import(
    KobusPreparation preparation, {
    required bool includeShared,
    void Function(int done, int total)? progress,
  }) async {
    if (running) throw StateError('Un import KOBUS est déjà en cours.');
    running = true;
    stopRequested = false;
    final run = const Uuid().v4();
    try {
      final database = await db;
      await database.transaction((txn) async {
        await txn.insert('kobus_runs', {
          'run_id': run,
          'zip_name': preparation.zipName,
          'temporary_path': preparation.temporaryPath,
          'started_at': DateTime.now().millisecondsSinceEpoch,
          'status': 'running',
        });
        for (final folder in preparation.folders) {
          final excluded =
              (folder.shared && !includeShared) ||
              folder.decision == KobusDecision.skip ||
              folder.decision == KobusDecision.unresolved;
          final rejected =
              folder.rejection != null && !(folder.shared && !includeShared);
          await txn.insert('kobus_items', {
            'item_id': folder.id,
            'run_id': run,
            'source_path': folder.sourcePath,
            'shared': folder.shared ? 1 : 0,
            'practitioner': folder.practitioner,
            'identity_label': folder.label,
            'status': rejected
                ? 'rejected'
                : excluded
                ? 'skipped'
                : 'pending',
            'reason': rejected
                ? folder.rejection!
                : excluded
                ? (folder.shared && !includeShared
                      ? 'Dossiers partagés non sélectionnés.'
                      : 'Dossier exclu ou rapprochement non résolu.')
                : '',
            'warnings': (folder.identity?.warnings ?? []).join('\n'),
          });
        }
      });
      final resolved = <String, String>{};
      for (var i = 0; i < preparation.folders.length; i++) {
        final folder = preparation.folders[i];
        final state = (await database.query(
          'kobus_items',
          where: 'item_id = ?',
          whereArgs: [folder.id],
        )).single;
        if (state['status'] == 'pending') {
          if (stopRequested) {
            await _status(
              database,
              folder,
              'interrupted',
              'Non traité après interruption.',
            );
          } else {
            String? destination;
            try {
              final identity = folder.identity!;
              final target = folder.target;
              final create = folder.decision == KobusDecision.create;
              String patientId;
              if (create) {
                patientId = const Uuid().v4();
              } else {
                if (target == null) {
                  throw const _Aside('Rapprochement non résolu.');
                }
                patientId = target.sourceItemId == null
                    ? target.patient.patientId
                    : resolved[target.sourceItemId] ?? '';
                if (patientId.isEmpty) {
                  throw const _Aside(
                    'Le dossier du lot choisi comme cible n’a pas été importé.',
                  );
                }
              }
              final earlier = await database.query(
                'kobus_archives',
                where: 'patient_id = ? AND run_id <> ?',
                whereArgs: [patientId, run],
              );
              if (earlier.isNotEmpty) {
                throw const _Aside(
                  'Archive KOBUS issue d’un import antérieur : réimport hors périmètre.',
                );
              }
              if (!create &&
                  (await database.query(
                    'patients',
                    where: 'patient_id = ?',
                    whereArgs: [patientId],
                  )).isEmpty) {
                throw const _Aside(
                  'Patient cible supprimé depuis la préparation.',
                );
              }
              if (patientId.contains(RegExp(r'[/\\]')) ||
                  patientId == '.' ||
                  patientId == '..') {
                throw StateError(
                  'Identifiant patient incompatible avec le stockage KOBUS.',
                );
              }
              destination = p.join(
                await root,
                patientId,
                folder.id,
                p.posix.basename(folder.sourcePath),
              );
              await database.update(
                'kobus_items',
                {'storage_path': destination},
                where: 'item_id = ?',
                whereArgs: [folder.id],
              );
              await beforeCopy?.call(folder);
              await _copyAndVerify(folder, destination);
              await database.transaction((txn) async {
                // Recheck at commit: other import paths may have created a new
                // candidate while the confirmation screen was open.
                if (create) {
                  for (final row in await txn.query('patients')) {
                    if (kobusMatch(identity, Patient.fromMap(row)) != null) {
                      throw const _Aside(
                        'Nom et prénom déjà présents dans Companion.',
                      );
                    }
                  }
                  await txn.insert(
                    'patients',
                    identity.patient(patientId).toMap(),
                  );
                  if (identity.profession != null) {
                    await txn.insert('patient_attributes', {
                      'attribute_id': const Uuid().v4(),
                      'patient_id': patientId,
                      'attribute_key': 'profession',
                      'attribute_value': identity.profession,
                      'updated_at': DateTime.now().millisecondsSinceEpoch,
                    });
                  }
                } else if ((await txn.query(
                  'patients',
                  where: 'patient_id = ?',
                  whereArgs: [patientId],
                )).isEmpty) {
                  throw const _Aside(
                    'Patient cible supprimé pendant la copie.',
                  );
                }
                await txn.insert('kobus_archives', {
                  'archive_id': folder.id,
                  'patient_id': patientId,
                  'run_id': run,
                  'source_path': folder.sourcePath,
                  'shared': folder.shared ? 1 : 0,
                  'practitioner': folder.practitioner,
                  'storage_path': destination,
                  'manifest_json': jsonEncode(folder.manifest),
                  'created_at': DateTime.now().millisecondsSinceEpoch,
                });
                await txn.update(
                  'kobus_items',
                  {
                    'status': 'imported',
                    'reason': '',
                    'patient_id': patientId,
                    'created_patient': create ? 1 : 0,
                  },
                  where: 'item_id = ?',
                  whereArgs: [folder.id],
                );
              });
              resolved[folder.id] = patientId;
            } catch (error) {
              // Never remove a committed archive if a post-commit operation fails.
              if (destination != null) {
                await _removeUncommitted(database, destination);
              }
              await _status(
                database,
                folder,
                error is _Aside ? 'skipped' : 'failed',
                error.toString(),
              );
            }
          }
        }
        progress?.call(i + 1, preparation.folders.length);
        await Future<void>.delayed(Duration.zero);
      }
      await database.update(
        'kobus_runs',
        {
          'status': stopRequested ? 'interrupted' : 'complete',
          'finished_at': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'run_id = ?',
        whereArgs: [run],
      );
      return run;
    } finally {
      running = false;
    }
  }

  Future<void> _status(
    DatabaseExecutor database,
    KobusFolder folder,
    String status,
    String reason,
  ) => database.update(
    'kobus_items',
    {'status': status, 'reason': reason},
    where: 'item_id = ?',
    whereArgs: [folder.id],
  );

  Future<void> _copyAndVerify(KobusFolder folder, String destination) async {
    if (await FileSystemEntity.type(destination, followLinks: false) !=
        FileSystemEntityType.notFound) {
      throw StateError('Destination déjà présente.');
    }
    await Directory(destination).create(recursive: true);
    for (final entry in folder.manifest.entries) {
      final relative = entry.key.endsWith('/')
          ? entry.key.substring(0, entry.key.length - 1)
          : entry.key;
      final target = p.joinAll([destination, ...relative.split('/')]);
      final source = p.joinAll([folder.directory, ...relative.split('/')]);
      if (!p.isWithin(destination, target) ||
          !p.isWithin(folder.directory, source)) {
        throw StateError('Chemin hors archive.');
      }
      final type = await FileSystemEntity.type(source, followLinks: false);
      if (entry.value == 'directory') {
        if (type != FileSystemEntityType.directory) {
          throw StateError('Répertoire source modifié : $relative');
        }
        await Directory(target).create(recursive: true);
      } else {
        if (type != FileSystemEntityType.file) {
          throw StateError('Fichier source modifié : $relative');
        }
        await File(target).parent.create(recursive: true);
        await File(source).copy(target);
        final digest = await sha256.bind(File(target).openRead()).first;
        if (digest.toString() != entry.value) {
          throw StateError('Copie différente : $relative');
        }
      }
    }
    for (final path in [folder.directory, destination]) {
      final inventory = <String>{};
      await for (final entity in Directory(
        path,
      ).list(recursive: true, followLinks: false)) {
        final name = p
            .relative(entity.path, from: path)
            .split(p.separator)
            .join('/');
        inventory.add(entity is Directory ? '$name/' : name);
      }
      if (inventory.length != folder.manifest.length ||
          !inventory.containsAll(folder.manifest.keys)) {
        throw StateError('Inventaire différent après copie.');
      }
    }
  }
}

class _Aside implements Exception {
  const _Aside(this.reason);
  final String reason;
  @override
  String toString() => reason;
}

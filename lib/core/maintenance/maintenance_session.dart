import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../database/database_service.dart';

class StartupRequest {
  const StartupRequest({
    this.maintenance = false,
    this.syntheticRoot,
    this.authorizeDirectory = false,
    this.bundleResourcesRecipe = false,
    this.coordinatedPhase,
    this.rollbackPlanHash,
  });
  final bool maintenance;
  final String? syntheticRoot;
  final bool authorizeDirectory;
  final bool bundleResourcesRecipe;
  final String? coordinatedPhase, rollbackPlanHash;
  static StartupRequest parse(List<String> args) {
    var maintenance = false;
    var authorize = false;
    var bundleResources = false;
    String? root;
    String? phase, plan;
    for (final arg in args) {
      if (arg == '--abak-maintenance' && !maintenance) {
        maintenance = true;
      } else if (arg.startsWith('--abak-maintenance-root=') && root == null) {
        root = arg.substring('--abak-maintenance-root='.length);
      } else if (arg == '--abak-maintenance-authorize' && !authorize) {
        authorize = true;
      } else if (arg == '--abak-bundle-resources' && !bundleResources) {
        bundleResources = true;
      } else if (arg.startsWith('--abak-coordinated-phase=') && phase == null) {
        phase = arg.substring('--abak-coordinated-phase='.length);
      } else if (arg.startsWith('--abak-rollback-plan=') && plan == null) {
        plan = arg.substring('--abak-rollback-plan='.length);
      } else if (arg.startsWith('--abak-')) {
        throw const FormatException(
          'Option de maintenance inconnue ou répétée.',
        );
      }
      // Finder/platform arguments are unrelated to this protocol.
    }
    if (phase != null &&
        (!maintenance ||
            !authorize ||
            root == null ||
            bundleResources ||
            !{
              'seed',
              'upgrade',
              'blocked',
              'restore-crash',
              'recover',
              'verify',
            }.contains(phase))) {
      throw const FormatException('Recette coordonnée isolée obligatoire.');
    }
    if ((plan != null &&
            (phase == null || !RegExp(r'^[a-f0-9]{64}$').hasMatch(plan))) ||
        ({'blocked', 'restore-crash', 'recover'}.contains(phase) &&
            plan == null)) {
      throw const FormatException('Empreinte du plan de retour obligatoire.');
    }
    if ((root != null && (!maintenance || !p.isAbsolute(root))) ||
        (authorize && (!maintenance || root == null)) ||
        (bundleResources && (!maintenance || root == null || !authorize))) {
      throw const FormatException(
        'La base synthétique exige le mode maintenance et un chemin absolu.',
      );
    }
    return StartupRequest(
      maintenance: maintenance,
      syntheticRoot: root,
      authorizeDirectory: authorize,
      bundleResourcesRecipe: bundleResources,
      coordinatedPhase: phase,
      rollbackPlanHash: plan,
    );
  }
}

/// Refuse links in any ancestor. No creation, repair, or fallback to user data.
Future<void> regularMaintenancePath(
  String path, {
  bool directory = false,
}) async {
  if (!p.isAbsolute(path) || p.normalize(path) != path) {
    throw const FormatException('Chemin de maintenance non canonique.');
  }
  var parent = path;
  while (true) {
    if (await FileSystemEntity.type(parent, followLinks: false) ==
        FileSystemEntityType.link) {
      throw const FormatException('Lien symbolique interdit en maintenance.');
    }
    final next = p.dirname(parent);
    if (next == parent) break;
    parent = next;
  }
  final expected = directory
      ? FileSystemEntityType.directory
      : FileSystemEntityType.file;
  if (await FileSystemEntity.type(path, followLinks: false) != expected) {
    throw const FileSystemException('Ressource de maintenance absente.');
  }
}

class CompanionAlreadyRunning implements Exception {
  const CompanionAlreadyRunning();
  @override
  String toString() =>
      'Une autre instance utilise ce stockage. Fermez-la avant de poursuivre.';
}

/// POSIX lock shared with the deployment tool. Never unlink the lock file:
/// a stale pathname is harmless; the kernel releases ownership on process exit.
class CompanionInstanceLock {
  CompanionInstanceLock._(this.file, this.path);
  final RandomAccessFile file;
  final String path;
  bool _closed = false;
  static final _owned = <String>{};
  static Future<CompanionInstanceLock> acquire(File target) async {
    await regularMaintenancePath(target.parent.path, directory: true);
    final key = target.path;
    if (_owned.contains(key)) throw const CompanionAlreadyRunning();
    final type = await FileSystemEntity.type(key, followLinks: false);
    if (type != FileSystemEntityType.notFound &&
        type != FileSystemEntityType.file) {
      throw const FormatException('Fichier de verrou non régulier.');
    }
    _owned.add(key);
    RandomAccessFile? handle;
    try {
      handle = await target.open(mode: FileMode.append);
      await handle.lock(FileLock.exclusive);
      return CompanionInstanceLock._(handle, key);
    } catch (_) {
      await handle?.close();
      _owned.remove(key);
      throw const CompanionAlreadyRunning();
    }
  }

  Future<void> close() async {
    if (_closed) return;
    _closed = true;
    try {
      await file.close();
    } finally {
      _owned.remove(path);
    }
  }
}

class MaintenanceSession {
  static const _access = MethodChannel('abak/maintenance_access');
  MaintenanceSession._(
    this.lock,
    this.database,
    this.path,
    this.version,
    this.integrity,
    this.synthetic,
    this.authorizedDirectory,
  );
  final CompanionInstanceLock lock;
  final Database database;
  final String path;
  final int version;
  final bool integrity, synthetic;
  final bool authorizedDirectory;
  static Future<MaintenanceSession> open(StartupRequest request) async {
    if (!request.maintenance) throw StateError('Mode maintenance requis.');
    if (request.authorizeDirectory) {
      final root = request.syntheticRoot;
      if (root == null ||
          !p.isAbsolute(root) ||
          p.normalize(root) != root ||
          !p.basename(root).startsWith('abak-maintenance-') ||
          p
              .split(root)
              .any(
                (v) => [
                  'Applications',
                  'Containers',
                  'Group Containers',
                ].contains(v),
              )) {
        throw const FormatException('Racine synthétique non autorisée.');
      }
      final selected = await _access.invokeMethod<String>('authorize', {
        'path': root,
      });
      if (selected != root) {
        throw StateError(
          'Autorisation du dossier synthétique annulée ou refusée.',
        );
      }
    }
    try {
      return await _openAuthorized(request);
    } catch (_) {
      if (request.authorizeDirectory) {
        await _access.invokeMethod<void>('release');
      }
      rethrow;
    }
  }

  static Future<MaintenanceSession> _openAuthorized(
    StartupRequest request,
  ) async {
    late String support, lockPath;
    if (request.syntheticRoot case final String root) {
      await regularMaintenancePath(root, directory: true);
      if (!p.basename(root).startsWith('abak-maintenance-') ||
          p
              .split(root)
              .any(
                (v) => [
                  'Applications',
                  'Containers',
                  'Group Containers',
                ].contains(v),
              )) {
        throw const FormatException('Racine synthétique non autorisée.');
      }
      final marker = File(p.join(root, 'SYNTHETIC-ONLY'));
      await regularMaintenancePath(marker.path);
      if (await marker.readAsString() != 'ABAK-MAINTENANCE-SYNTHETIC-V1\n') {
        throw const FormatException(
          'Marqueur synthétique absent ou différent.',
        );
      }
      support = p.join(root, 'active', 'support');
      lockPath = p.join(root, '.companion-instance.lock');
    } else {
      support = (await getApplicationSupportDirectory()).path;
      lockPath = p.join(support, '.companion-instance.lock');
    }
    final lock = await CompanionInstanceLock.acquire(File(lockPath));
    Database? database;
    try {
      if (request.syntheticRoot != null &&
          await File(
            p.join(request.syntheticRoot!, 'coordinated.pending.json'),
          ).exists() &&
          !{
            'blocked',
            'restore-crash',
            'recover',
          }.contains(request.coordinatedPhase)) {
        throw StateError(
          'Retour arrière incomplet : reprise bloquée, maintenance de récupération requise.',
        );
      }
      final path = p.join(support, 'database', 'abak_desktop.db');
      await regularMaintenancePath(path);
      // Refuse ambiguous live/WAL recovery. Maintenance must never recover or
      // checkpoint a user's database as a side effect of merely inspecting it.
      for (final suffix in ['-wal', '-shm', '-journal']) {
        final sidecar = File('$path$suffix');
        if (await sidecar.exists() && await sidecar.length() > 0) {
          throw StateError(
            'Fermeture SQLite à vérifier sur copie avant maintenance.',
          );
        }
      }
      sqfliteFfiInit();
      database = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
      );
      final version = await database.getVersion();
      if (version < 1 || version > DatabaseService.schemaVersion) {
        throw StateError(
          'Version de base incompatible : $version. Aucune migration effectuée.',
        );
      }
      final rows = await database.rawQuery('PRAGMA integrity_check');
      return MaintenanceSession._(
        lock,
        database,
        path,
        version,
        rows.length == 1 && rows.single.values.single == 'ok',
        request.syntheticRoot != null,
        request.authorizeDirectory,
      );
    } catch (_) {
      await database?.close();
      await lock.close();
      rethrow;
    }
  }

  Future<void> close() async {
    try {
      await database.close();
    } finally {
      try {
        await lock.close();
      } finally {
        if (authorizedDirectory) await _access.invokeMethod<void>('release');
      }
    }
  }
}

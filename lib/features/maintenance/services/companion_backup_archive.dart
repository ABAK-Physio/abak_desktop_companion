import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../../../core/database/database_service.dart';
import 'backup_directory_access.dart';

class PreparedBackup {
  PreparedBackup(this.directory, this.folders, {required this.legacy});
  final Directory directory;
  final List<Map<String, dynamic>> folders;
  final bool legacy;
  String get databasePath => p.join(directory.path, 'database.db');
  Future<void> dispose() => directory.delete(recursive: true);
}

class CompanionBackupArchive {
  const CompanionBackupArchive();

  static Future<String> digest(File file) async =>
      (await sha256.bind(file.openRead()).first).toString();

  static void validatePath(String path) {
    if (path.isEmpty ||
        p.posix.isAbsolute(path) ||
        RegExp(r'[\\:\x00]').hasMatch(path) ||
        path
            .split('/')
            .any((part) => part.isEmpty || part == '.' || part == '..')) {
      throw FormatException('Chemin de sauvegarde invalide : $path');
    }
  }

  static Future<void> copyTree(Directory source, Directory target) async {
    if (await FileSystemEntity.type(source.path, followLinks: false) !=
        FileSystemEntityType.directory) {
      throw FileSystemException(
        'Dossier patient absent ou lien non pris en charge',
        source.path,
      );
    }
    await target.create(recursive: true);
    await for (final entry in source.list(followLinks: false)) {
      final name = p.basename(entry.path);
      validatePath(name);
      final destination = p.join(target.path, name);
      if (entry is Link) {
        throw FileSystemException(
          'Lien non pris en charge dans une sauvegarde',
          entry.path,
        );
      } else if (entry is Directory) {
        await copyTree(entry, Directory(destination));
      } else if (entry is File) {
        final before = await entry.stat();
        await entry.copy(destination);
        final after = await entry.stat();
        if (before.size != after.size || before.modified != after.modified) {
          throw FileSystemException(
            'Document modifié pendant la sauvegarde',
            entry.path,
          );
        }
      } else {
        throw FileSystemException(
          'Type de fichier non pris en charge',
          entry.path,
        );
      }
    }
  }

  static Future<void> validateDatabase(String path) async {
    final db = await databaseFactoryFfi.openDatabase(
      path,
      options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
    );
    try {
      final integrity = await db.rawQuery('PRAGMA integrity_check');
      if (integrity.length != 1 || integrity.single.values.single != 'ok') {
        throw const FormatException('La base sauvegardée est endommagée');
      }
      final version = await db.getVersion();
      if (version < 1 || version > DatabaseService.schemaVersion) {
        throw FormatException(
          'Version de sauvegarde non prise en charge : $version',
        );
      }
      for (final table in ['patients', 'care_episodes', 'desktop_results']) {
        final rows = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = ?",
          [table],
        );
        if (rows.isEmpty) {
          throw const FormatException(
            'Ce fichier n’est pas une sauvegarde Companion',
          );
        }
      }
    } finally {
      await db.close();
    }
  }

  Future<void> create({
    required String outputPath,
    required BackupDirectoryAccess access,
  }) async {
    final staging = await Directory.systemTemp.createTemp('abak_backup_');
    final leases = <String, BackupDirectoryLease>{};
    ZipFileEncoder? encoder;
    try {
      final db = await DatabaseService.database;
      final snapshot = p.join(staging.path, 'database.db');
      // SQLite makes a consistent snapshot, including committed WAL contents.
      await db.execute('VACUUM INTO ?', [snapshot]);
      await validateDatabase(snapshot);
      final copy = await databaseFactoryFfi.openDatabase(
        snapshot,
        options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
      );
      late List<Map<String, Object?>> rows;
      try {
        rows = await copy.query(
          'patient_document_folders',
          orderBy: 'root_path, patient_id',
        );
      } finally {
        await copy.close();
      }
      final folders = <Map<String, dynamic>>[];
      for (final row in rows) {
        final root = row['root_path'] as String;
        final name = row['folder_name'] as String;
        validatePath(name);
        if (name.contains('/')) {
          throw const FormatException('Nom de dossier patient invalide');
        }
        final lease = leases[root] ??= await access.read(root);
        final source = Directory(p.join(lease.path, name));
        if (p.isWithin(source.path, p.absolute(outputPath))) {
          throw FileSystemException(
            'La sauvegarde doit être placée hors des dossiers patients',
            outputPath,
          );
        }
        final archivePath = 'documents/${folders.length}';
        await copyTree(source, Directory(p.join(staging.path, archivePath)));
        folders.add({
          'patientId': row['patient_id'],
          'sourceRoot': root,
          'folderName': name,
          'archivePath': archivePath,
        });
      }
      final entries = <Map<String, dynamic>>[];
      await for (final entry in staging.list(
        recursive: true,
        followLinks: false,
      )) {
        final name = p
            .relative(entry.path, from: staging.path)
            .split(p.separator)
            .join('/');
        validatePath(name);
        entries.add(
          entry is Directory
              ? {'path': name, 'directory': true}
              : {
                  'path': name,
                  'directory': false,
                  'size': await File(entry.path).length(),
                  'sha256': await digest(File(entry.path)),
                },
        );
      }
      await File(p.join(staging.path, 'manifest.json')).writeAsString(
        jsonEncode({
          'format': 'abak-companion-backup',
          'version': 1,
          'createdAt': DateTime.now().toUtc().toIso8601String(),
          'folders': folders,
          'entries': entries,
        }),
      );
      encoder = ZipFileEncoder()..create(outputPath);
      await encoder.addDirectory(
        staging,
        includeDirName: false,
        followLinks: false,
      );
      await encoder.close();
      encoder = null;
    } finally {
      if (encoder != null) await encoder.close();
      for (final lease in leases.values) {
        await lease.release();
      }
      await staging.delete(recursive: true);
    }
  }

  Future<PreparedBackup> prepare(String backupPath) async {
    final staging = await Directory.systemTemp.createTemp('abak_restore_');
    InputFileStream? input;
    try {
      if (p.extension(backupPath).toLowerCase() == '.db') {
        await File(backupPath).copy(p.join(staging.path, 'database.db'));
        await validateDatabase(p.join(staging.path, 'database.db'));
        return PreparedBackup(staging, [], legacy: true);
      }
      input = InputFileStream(backupPath);
      final decoder = ZipDecoder();
      final archive = decoder.decodeStream(input);
      final names = <String>{};
      for (final header in decoder.directory.fileHeaders) {
        final name = header.filename.replaceFirst(RegExp(r'/$'), '');
        validatePath(name);
        if (!names.add(name.toLowerCase())) {
          throw const FormatException('Entrées de sauvegarde en double');
        }
      }
      final manifestFile = archive.find('manifest.json');
      if (manifestFile == null ||
          manifestFile.size > 16 * 1024 * 1024 ||
          manifestFile.isSymbolicLink) {
        throw const FormatException(
          'Manifeste de sauvegarde absent ou invalide',
        );
      }
      final manifest =
          jsonDecode(utf8.decode(manifestFile.readBytes()!))
              as Map<String, dynamic>;
      if (manifest['format'] != 'abak-companion-backup' ||
          manifest['version'] != 1) {
        throw const FormatException('Format de sauvegarde non pris en charge');
      }
      final entries = (manifest['entries'] as List)
          .cast<Map<String, dynamic>>();
      final folders = (manifest['folders'] as List)
          .cast<Map<String, dynamic>>();
      final allowed = <String>{'manifest.json'};
      for (final entry in entries) {
        final name = entry['path'] as String;
        validatePath(name);
        if (!allowed.add(name)) throw const FormatException('Entrée dupliquée');
        final file = archive.find(name) ?? archive.find('$name/');
        if (file == null ||
            file.isSymbolicLink ||
            file.isDirectory != entry['directory']) {
          throw FormatException(
            'Entrée de sauvegarde absente ou invalide : $name',
          );
        }
        final target = p.joinAll([staging.path, ...name.split('/')]);
        if (file.isDirectory) {
          await Directory(target).create(recursive: true);
        } else {
          if (file.size != entry['size']) {
            throw FormatException('Taille incorrecte : $name');
          }
          await Directory(p.dirname(target)).create(recursive: true);
          final output = OutputFileStream(target);
          try {
            file.writeContent(output);
          } finally {
            await output.close();
          }
          if (await File(target).length() != entry['size'] ||
              await digest(File(target)) != entry['sha256']) {
            throw FormatException('Document endommagé : $name');
          }
        }
      }
      if (archive.length != allowed.length ||
          !allowed.contains('database.db')) {
        throw const FormatException('Contenu de sauvegarde inattendu');
      }
      final seen = <String>{};
      for (var i = 0; i < folders.length; i++) {
        final folder = folders[i];
        final name = folder['folderName'] as String;
        validatePath(name);
        if (name.contains('/') ||
            folder['archivePath'] != 'documents/$i' ||
            !seen.add('${folder['patientId']}\x00${folder['sourceRoot']}') ||
            !allowed.contains('documents/$i')) {
          throw const FormatException('Association patient invalide');
        }
      }
      for (final entry in entries) {
        final name = entry['path'] as String;
        if (name != 'database.db' &&
            name != 'documents' &&
            !folders.any(
              (f) =>
                  name == f['archivePath'] ||
                  name.startsWith('${f['archivePath']}/'),
            )) {
          throw const FormatException('Document sans rattachement patient');
        }
      }
      final databasePath = p.join(staging.path, 'database.db');
      await validateDatabase(databasePath);
      final db = await databaseFactoryFfi.openDatabase(
        databasePath,
        options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
      );
      try {
        final associations = await db.query('patient_document_folders');
        if (associations.length != folders.length ||
            folders.any(
              (folder) => !associations.any(
                (row) =>
                    row['patient_id'] == folder['patientId'] &&
                    row['root_path'] == folder['sourceRoot'] &&
                    row['folder_name'] == folder['folderName'],
              ),
            )) {
          throw const FormatException(
            'Les documents ne correspondent pas à la base sauvegardée',
          );
        }
      } finally {
        await db.close();
      }
      return PreparedBackup(staging, folders, legacy: false);
    } catch (_) {
      await staging.delete(recursive: true);
      rethrow;
    } finally {
      await input?.close();
    }
  }
}

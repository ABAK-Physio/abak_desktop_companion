import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive_io.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/core/settings/application_settings_service.dart';
import 'package:abak_desktop_companion/features/patients/data/patient_repository.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_documents_service.dart';
import 'package:abak_desktop_companion/features/maintenance/data/database_backup_repository.dart';
import 'package:abak_desktop_companion/features/maintenance/services/backup_directory_access.dart';
import 'package:abak_desktop_companion/features/maintenance/services/companion_backup_archive.dart';
import 'package:abak_desktop_companion/features/maintenance/services/local_database_backup_service.dart';
import 'package:abak_desktop_companion/features/desktop_backup/services/local_database_restore_service.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import 'package:flutter/widgets.dart';

class _Paths extends PathProviderPlatform {
  _Paths(this.path);
  final String path;
  @override
  Future<String?> getApplicationSupportPath() async => path;
}

class _Access extends BackupDirectoryAccess {
  _Access(this.output);
  String output;
  final remap = <String, String>{};
  int acquired = 0;
  int released = 0;
  bool cancel = false;
  BackupDirectoryLease lease(String path) {
    acquired++;
    return BackupDirectoryLease(path, () async {
      released++;
    });
  }

  @override
  Future<BackupDirectoryLease?> choose(String title) async =>
      cancel ? null : lease(output);
  @override
  Future<BackupDirectoryLease> acquire(String path) async => lease(path);
  @override
  Future<BackupDirectoryLease> restore(String path) async =>
      lease(remap[path] ?? path);
}

class _FailingRestore extends LocalDatabaseRestoreService {
  const _FailingRestore({required super.access});
  @override
  Future<void> installDatabase(String source, String destination) async {
    throw const FileSystemException(
      'Simulated write failure after directory replacement',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temp;
  late Directory root;
  late _Access access;
  late PathProviderPlatform previous;
  late String patientId;
  late PatientDocumentFolders folders;

  setUp(() async {
    await S.load(const Locale('fr', 'FR'));
    temp = await Directory.systemTemp.createTemp('abak_backup_test_');
    previous = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _Paths(p.join(temp.path, 'support'));
    root = await Directory(p.join(temp.path, 'patients')).create();
    final output = await Directory(p.join(temp.path, 'backups')).create();
    access = _Access(output.path);
    final patient = await PatientRepository().createPatient(
      lastName: 'Dupont',
      firstName: 'Élodie',
      birthDate: '1980-03-12',
    );
    patientId = patient.patientId;
    await const ApplicationSettingsService().setString(
      ApplicationSettingsService.assessmentDocumentsDirectoryKey,
      root.path,
    );
    folders = await const PatientDocumentsService().ensureInRoot(
      patientId: patientId,
      rootPath: root.path,
    );
    await File(
      p.join(folders.assessment, 'bilan.docx'),
    ).writeAsBytes([1, 2, 3]);
    await File(
      p.join(folders.report, 'rapport.docx'),
    ).writeAsString('Saved report');
    await Directory(p.join(folders.other, 'Sous dossier')).create();
    await File(
      p.join(folders.other, 'Sous dossier', 'pièce jointe.bin'),
    ).writeAsBytes([0, 255, 128, 12]);
    await Directory(p.join(folders.other, 'Vide')).create();
  });
  tearDown(() async {
    await DatabaseService.closeDatabase();
    PathProviderPlatform.instance = previous;
    await temp.delete(recursive: true);
  });

  Future<LocalDatabaseBackupResult> backupResult() =>
      LocalDatabaseBackupService(access: access).createBackup(
        databaseNotFoundMessage: 'Missing',
        chooseBackupFolderTitle: 'Choose',
        cancelledMessage: 'Cancelled',
      );
  Future<String> backup() async {
    final result = await backupResult();
    expect(result.success, isTrue, reason: result.error);
    expect(access.acquired, access.released);
    return result.backupPath!;
  }

  Future<void> changeIdentity(String name) async {
    final db = await DatabaseService.database;
    await db.update(
      'patients',
      {'last_name': name},
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );
  }

  Future<String> lastName() async =>
      (await PatientRepository().getPatientById(patientId))!.lastName;
  Future<void> rewriteArchive(
    String path,
    void Function(Archive archive) edit,
  ) async {
    final archive = ZipDecoder().decodeBytes(await File(path).readAsBytes());
    edit(archive);
    await File(path).writeAsBytes(ZipEncoder().encode(archive));
  }

  test(
    'Archive contains database, links, nested documents and empty folders',
    () async {
      final path = await backup();
      expect(p.extension(path), '.zip');
      final prepared = await const CompanionBackupArchive().prepare(path);
      try {
        expect(prepared.folders.single['patientId'], patientId);
        expect(
          await File(
            p.join(
              prepared.directory.path,
              'documents/0/Autre/Sous dossier/pièce jointe.bin',
            ),
          ).readAsBytes(),
          [0, 255, 128, 12],
        );
        expect(
          await Directory(
            p.join(prepared.directory.path, 'documents/0/Autre/Vide'),
          ).exists(),
          isTrue,
        );
        expect(
          (await DatabaseBackupRepository().getBackups()).single.filePath,
          path,
        );
      } finally {
        await prepared.dispose();
      }
    },
  );

  test(
    'Restores saved versions, retaining current folders and newer files',
    () async {
      final path = await backup();
      await changeIdentity('Changed');
      await File(
        p.join(folders.report, 'rapport.docx'),
      ).writeAsString('Current report');
      await File(p.join(folders.other, 'new.txt')).writeAsString('New file');
      final result = await LocalDatabaseRestoreService(
        access: access,
      ).restoreDatabase(backupPath: path);
      expect(result.success, isTrue, reason: result.message);
      expect(await lastName(), 'Dupont');
      expect(
        (await DatabaseBackupRepository().getBackups()).any(
          (b) => b.filePath == path,
        ),
        isTrue,
      );
      expect(
        await File(p.join(folders.report, 'rapport.docx')).readAsString(),
        'Saved report',
      );
      expect(
        await File(p.join(folders.other, 'new.txt')).readAsString(),
        'New file',
      );
      expect(
        await File(
          p.join(result.documentSafetyPaths.single, 'Rapport/rapport.docx'),
        ).readAsString(),
        'Current report',
      );
      final safety = await databaseFactoryFfi.openDatabase(
        result.safetyBackupPath!,
        options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
      );
      expect((await safety.query('patients')).single['last_name'], 'Changed');
      await safety.close();
      expect(
        (await const PatientDocumentsService().ensureInRoot(
          patientId: patientId,
          rootPath: root.path,
        )).path,
        folders.path,
      );
      expect(access.acquired, access.released);
    },
  );

  test('Can restore after loss of patient folders', () async {
    final path = await backup();
    await Directory(folders.path).delete(recursive: true);
    final result = await LocalDatabaseRestoreService(
      access: access,
    ).restoreDatabase(backupPath: path);
    expect(result.success, isTrue, reason: result.message);
    expect(await File(p.join(folders.assessment, 'bilan.docx')).readAsBytes(), [
      1,
      2,
      3,
    ]);
    expect(result.documentSafetyPaths, isEmpty);
  });

  test(
    'Relocates patient associations and configured root on another computer',
    () async {
      final path = await backup();
      final relocated = await Directory(
        p.join(temp.path, 'relocated'),
      ).create();
      access.remap[root.path] = relocated.path;
      final unrelated = await Directory(
        p.join(relocated.path, p.basename(folders.path)),
      ).create();
      await File(
        p.join(unrelated.path, 'private.txt'),
      ).writeAsString('Unrelated');
      final result = await LocalDatabaseRestoreService(
        access: access,
      ).restoreDatabase(backupPath: path);
      expect(result.success, isTrue, reason: result.message);
      final db = await DatabaseService.database;
      final row = (await db.query('patient_document_folders')).single;
      expect(row['root_path'], relocated.path);
      expect(row['folder_name'], '${p.basename(folders.path)}_2');
      expect(
        await const ApplicationSettingsService().getString(
          ApplicationSettingsService.assessmentDocumentsDirectoryKey,
        ),
        relocated.path,
      );
      expect(
        await File(p.join(unrelated.path, 'private.txt')).readAsString(),
        'Unrelated',
      );
      expect(
        await File(
          p.join(
            relocated.path,
            row['folder_name'] as String,
            'Rapport/rapport.docx',
          ),
        ).readAsString(),
        'Saved report',
      );
    },
  );

  test(
    'Legacy database backups restore the database without changing patient files',
    () async {
      final path = p.join(access.output, 'legacy.db');
      final db = await DatabaseService.database;
      await db.execute('VACUUM INTO ?', [path]);
      await changeIdentity('Changed');
      await File(
        p.join(folders.report, 'rapport.docx'),
      ).writeAsString('Current');
      final result = await LocalDatabaseRestoreService(
        access: access,
      ).restoreDatabase(backupPath: path);
      expect(result.success, isTrue, reason: result.message);
      expect(result.message, contains(S.current.backupArchive_legacy));
      expect(await lastName(), 'Dupont');
      expect(
        await File(p.join(folders.report, 'rapport.docx')).readAsString(),
        'Current',
      );
    },
  );

  test(
    'Legacy v29 backup migrates and keeps existing patient-folder links',
    () async {
      final path = p.join(access.output, 'before-patient-folders.db');
      final db = await DatabaseService.database;
      await db.execute('VACUUM INTO ?', [path]);
      final old = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(singleInstance: false),
      );
      await old.execute('DROP TABLE patient_document_folders');
      await old.setVersion(29);
      await old.close();
      await changeIdentity('Current');
      final result = await LocalDatabaseRestoreService(
        access: access,
      ).restoreDatabase(backupPath: path);
      expect(result.success, isTrue, reason: result.message);
      expect(await lastName(), 'Dupont');
      final linked = await const PatientDocumentsService().ensureInRoot(
        patientId: patientId,
        rootPath: root.path,
      );
      expect(linked.path, folders.path);
      expect(
        await File(p.join(linked.report, 'rapport.docx')).readAsString(),
        'Saved report',
      );
    },
  );

  test(
    'Missing patient folder fails backup without a successful history entry',
    () async {
      await Directory(folders.path).delete(recursive: true);
      final result = await backupResult();
      expect(result.success, isFalse);
      expect(await Directory(access.output).list().toList(), isEmpty);
      expect(await DatabaseBackupRepository().getBackups(), isEmpty);
      expect(access.acquired, access.released);
    },
  );

  test('Cancellation creates no backup', () async {
    access.cancel = true;
    final result = await backupResult();
    expect(result.success, isFalse);
    expect(result.error, 'Cancelled');
    expect(await Directory(access.output).list().toList(), isEmpty);
  });

  test(
    'Corrupted document is detected before changing database or documents',
    () async {
      final path = await backup();
      await rewriteArchive(path, (archive) {
        archive.add(
          ArchiveFile.bytes(
            'documents/0/Rapport/rapport.docx',
            Uint8List.fromList([9, 9, 9]),
          ),
        );
      });
      await changeIdentity('Current');
      final result = await LocalDatabaseRestoreService(
        access: access,
      ).restoreDatabase(backupPath: path);
      expect(result.success, isFalse);
      expect(await lastName(), 'Current');
      expect(
        await File(p.join(folders.report, 'rapport.docx')).readAsString(),
        'Saved report',
      );
      expect(result.safetyBackupPath, isNull);
    },
  );

  test('Unsafe archive paths are rejected before extraction', () async {
    final path = await backup();
    await rewriteArchive(path, (archive) {
      archive.add(ArchiveFile.bytes('../escape.txt', Uint8List.fromList([1])));
    });
    await changeIdentity('Current');
    final result = await LocalDatabaseRestoreService(
      access: access,
    ).restoreDatabase(backupPath: path);
    expect(result.success, isFalse);
    expect(await lastName(), 'Current');
  });

  test(
    'Database installation failure rolls back all replaced document folders',
    () async {
      final path = await backup();
      await changeIdentity('Current');
      await File(
        p.join(folders.report, 'rapport.docx'),
      ).writeAsString('Current');
      final result = await _FailingRestore(
        access: access,
      ).restoreDatabase(backupPath: path);
      expect(result.success, isFalse);
      expect(await lastName(), 'Current');
      expect(
        await File(p.join(folders.report, 'rapport.docx')).readAsString(),
        'Current',
      );
      expect(access.acquired, access.released);
      expect(
        await root
            .list()
            .where((f) => p.basename(f.path).startsWith('.abak_restore_'))
            .toList(),
        isEmpty,
      );
    },
  );

  test(
    'Symlinks inside documents fail backup without following them',
    () async {
      await Link(p.join(folders.other, 'link')).create(temp.path);
      final result = await backupResult();
      expect(result.success, isFalse);
      expect(await Directory(access.output).list().toList(), isEmpty);
    },
  );

  test('Backup location cannot be inside a patient folder', () async {
    access.output = folders.other;
    final result = await backupResult();
    expect(result.success, isFalse);
    expect(await DatabaseBackupRepository().getBackups(), isEmpty);
  });

  test('Snapshot includes committed SQLite WAL changes', () async {
    final db = await DatabaseService.database;
    await db.rawQuery('PRAGMA journal_mode = WAL');
    await changeIdentity('WAL name');
    final path = await backup();
    final prepared = await const CompanionBackupArchive().prepare(path);
    final saved = await databaseFactoryFfi.openDatabase(
      prepared.databasePath,
      options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
    );
    expect((await saved.query('patients')).single['last_name'], 'WAL name');
    await saved.close();
    await prepared.dispose();
  });

  test(
    'Multiple historical roots are included and cannot be merged implicitly',
    () async {
      final otherRoot = await Directory(
        p.join(temp.path, 'older_root'),
      ).create();
      final other = await const PatientDocumentsService().ensureInRoot(
        patientId: patientId,
        rootPath: otherRoot.path,
      );
      await File(p.join(other.other, 'older.txt')).writeAsString('Older');
      final path = await backup();
      final prepared = await const CompanionBackupArchive().prepare(path);
      expect(prepared.folders, hasLength(2));
      await prepared.dispose();
      access.remap[otherRoot.path] = root.path;
      final result = await LocalDatabaseRestoreService(
        access: access,
      ).restoreDatabase(backupPath: path);
      expect(result.success, isFalse);
      expect(
        await File(p.join(other.other, 'older.txt')).readAsString(),
        'Older',
      );
    },
  );

  test(
    'Archive restores into a fresh database and a different documents root',
    () async {
      final path = await backup();
      await DatabaseService.closeDatabase();
      final databasePath = await DatabaseService.databasePath;
      await File(databasePath).delete();
      await DatabaseService.reopenDatabase();
      final newRoot = await Directory(
        p.join(temp.path, 'new-computer'),
      ).create();
      access.remap[root.path] = newRoot.path;
      final result = await LocalDatabaseRestoreService(
        access: access,
      ).restoreDatabase(backupPath: path);
      expect(result.success, isTrue, reason: result.message);
      expect(await lastName(), 'Dupont');
      expect(
        await File(
          p.join(newRoot.path, p.basename(folders.path), 'Bilan/bilan.docx'),
        ).readAsBytes(),
        [1, 2, 3],
      );
      expect(
        (await DatabaseBackupRepository().getBackups()).single.filePath,
        path,
      );
    },
  );

  test(
    'Database-only installation can still create a complete ZIP backup',
    () async {
      final db = await DatabaseService.database;
      await db.delete('patient_document_folders');
      final path = await backup();
      final prepared = await const CompanionBackupArchive().prepare(path);
      expect(prepared.folders, isEmpty);
      await prepared.dispose();
      final result = await LocalDatabaseRestoreService(
        access: access,
      ).restoreDatabase(backupPath: path);
      expect(result.success, isTrue, reason: result.message);
    },
  );

  test('Database access waits while restore is replacing files', () async {
    await DatabaseService.beginRestore();
    var returned = false;
    final pending = DatabaseService.database.then((value) {
      returned = true;
      return value;
    });
    await Future<void>.delayed(Duration.zero);
    expect(returned, isFalse);
    await DatabaseService.endRestore();
    await pending;
    expect(returned, isTrue);
  });
}

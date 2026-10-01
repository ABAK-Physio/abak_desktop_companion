import 'dart:convert';
import 'dart:io';

import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/features/patients/data/patient_repository.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_documents_service.dart';
import 'package:abak_desktop_companion/features/episodes/report/services/episode_report_docx_export_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:abak_desktop_companion/core/settings/application_settings_service.dart';
import 'package:abak_desktop_companion/core/settings/macos_directory_access_service.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _Paths extends PathProviderPlatform {
  _Paths(this.path);
  final String path;
  @override
  Future<String?> getApplicationSupportPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temporary;
  late Directory root;
  late PathProviderPlatform previous;
  const service = PatientDocumentsService();
  final patients = PatientRepository();

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('abak_patient_folders_');
    root = await Directory(p.join(temporary.path, 'documents')).create();
    previous = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _Paths(p.join(temporary.path, 'support'));
  });
  tearDown(() async {
    await DatabaseService.closeDatabase();
    PathProviderPlatform.instance = previous;
    await temporary.delete(recursive: true);
  });

  Future<String> patient({
    String lastName = 'Dupont',
    String? birth = '1980-03-12',
  }) async => (await patients.createPatient(
    lastName: lastName,
    firstName: 'Élodie',
    birthDate: birth,
  )).patientId;
  Future<PatientDocumentFolders> ensure(String id) =>
      service.ensureInRoot(patientId: id, rootPath: root.path);

  test(
    'Opening a patient without a configured root does not prompt or create folders',
    () async {
      final id = await patient();
      expect(await service.ensureConfigured(id), isNull);
      expect(await root.list().toList(), isEmpty);
    },
  );

  test(
    'macOS authorization stays active during creation and is released after success or failure',
    () async {
      final id = await patient();
      const settings = ApplicationSettingsService();
      await settings.setString(
        ApplicationSettingsService.assessmentDocumentsDirectoryKey,
        root.path,
      );
      SharedPreferences.setMockInitialValues({
        'macos_directory_bookmark_v1_${base64Url.encode(utf8.encode(root.path))}':
            'test-bookmark',
      });
      const channel = MethodChannel('abak/directory_access');
      final calls = <String>[];
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call.method);
            if (call.method == 'restoreDirectory') {
              return {
                'path': root.path,
                'token': 'test-token',
                'bookmark': 'test-bookmark',
              };
            }
            if (call.method == 'releaseDirectory') return null;
            fail('Unexpected folder picker: ${call.method}');
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      final folders = await service.ensureConfigured(id);
      expect(await Directory(folders!.other).exists(), isTrue);
      expect(calls, ['restoreDirectory', 'releaseDirectory']);
      calls.clear();
      await Directory(folders.other).delete();
      await File(folders.other).writeAsString('Blocked');
      await expectLater(
        service.ensureConfigured(id),
        throwsA(isA<FileSystemException>()),
      );
      expect(calls, ['restoreDirectory', 'releaseDirectory']);
      SharedPreferences.setMockInitialValues({});
      calls.clear();
      await expectLater(
        service.ensureConfigured(id),
        throwsA(isA<DirectoryAuthorizationRequired>()),
      );
      expect(calls, isEmpty);
    },
    skip: !Platform.isMacOS,
  );

  test(
    'Creates the three folders, associates them and preserves documents on reopen',
    () async {
      final id = await patient();
      final folders = await ensure(id);
      expect(p.basename(folders.path), 'DUPONT_ELODIE_1980-03-12');
      expect(
        await Directory(
          folders.path,
        ).list().map((e) => p.basename(e.path)).toList(),
        unorderedEquals(['Bilan', 'Rapport', 'Autre']),
      );
      final file = await File(
        p.join(folders.other, 'note.txt'),
      ).writeAsString('Keep me');
      await DatabaseService.closeDatabase();
      expect((await ensure(id)).path, folders.path);
      expect(await file.readAsString(), 'Keep me');
    },
  );

  test('Complete homonyms and concurrent allocations stay separate', () async {
    final ids = [await patient(), await patient()];
    final folders = await Future.wait(ids.map(ensure));
    expect(folders.map((f) => f.path).toSet(), hasLength(2));
    expect(
      folders.map((f) => p.basename(f.path)),
      unorderedEquals([
        'DUPONT_ELODIE_1980-03-12',
        'DUPONT_ELODIE_1980-03-12_2',
      ]),
    );
    expect((await ensure(ids.first)).path, folders.first.path);
  });

  test('An existing unrelated directory is never adopted', () async {
    final existing = await Directory(
      p.join(root.path, 'DUPONT_ELODIE_1980-03-12'),
    ).create();
    final file = await File(
      p.join(existing.path, 'private.txt'),
    ).writeAsString('Other person');
    final folders = await ensure(await patient());
    expect(p.basename(folders.path), endsWith('_2'));
    expect(await file.readAsString(), 'Other person');
    expect(await Directory(p.join(existing.path, 'Bilan')).exists(), isFalse);
  });

  test(
    'Accents, ligatures and punctuation produce uppercase ASCII names',
    () async {
      final patient = await patients.createPatient(
        lastName: "D’Œuf / Müller",
        firstName: 'E\u0301lodie-Æna ß',
        birthDate: '1980-03-12',
      );
      final folders = await ensure(patient.patientId);
      expect(
        p.basename(folders.path),
        'D_OEUF_MULLER_ELODIE-AENA_SS_1980-03-12',
      );
      expect(p.basename(folders.path), matches(RegExp(r'^[A-Z0-9_-]+$')));
      final stored = await patients.getPatientById(patient.patientId);
      expect(stored!.lastName, patient.lastName);
      expect(stored.firstName, patient.firstName);
    },
  );

  test(
    'Names that become identical after normalization remain separate',
    () async {
      final first = await ensure(await patient(lastName: 'Évrard'));
      final second = await ensure(await patient(lastName: 'Evrard'));
      expect(p.basename(first.path), 'EVRARD_ELODIE_1980-03-12');
      expect(p.basename(second.path), 'EVRARD_ELODIE_1980-03-12_2');
    },
  );

  test(
    'Previously associated accented directories and files keep their path',
    () async {
      final id = await patient();
      final original = await ensure(id);
      const oldName = 'Dupont Élodie 1980-03-12';
      final oldPath = p.join(root.path, oldName);
      await Directory(original.path).rename(oldPath);
      final file = await File(
        p.join(oldPath, 'Autre', 'note.txt'),
      ).writeAsString('Keep');
      final db = await DatabaseService.database;
      await db.update(
        'patient_document_folders',
        {'folder_name': oldName},
        where: 'patient_id = ?',
        whereArgs: [id],
      );
      expect((await ensure(id)).path, oldPath);
      expect(await file.readAsString(), 'Keep');
    },
  );

  test('Identity corrections retain the patient association', () async {
    final id = await patient();
    final first = await ensure(id);
    final db = await DatabaseService.database;
    await db.update(
      'patients',
      {'last_name': 'Martin', 'birth_date': '1981-03-12'},
      where: 'patient_id = ?',
      whereArgs: [id],
    );
    expect((await ensure(id)).path, first.path);
  });

  test(
    'Changing root does not move files and returning to it reuses the association',
    () async {
      final id = await patient();
      final first = await ensure(id);
      final document = await File(
        p.join(first.assessment, 'old.docx'),
      ).writeAsString('Existing');
      final secondRoot = await Directory(
        p.join(temporary.path, 'new'),
      ).create();
      final second = await service.ensureInRoot(
        patientId: id,
        rootPath: secondRoot.path,
      );
      expect(second.path, isNot(first.path));
      expect(await document.readAsString(), 'Existing');
      expect((await ensure(id)).path, first.path);
    },
  );

  test(
    'Missing date and invalid filename characters stay inside the root',
    () async {
      final folders = await ensure(
        await patient(lastName: '../../Du:pont\\Name', birth: null),
      );
      expect(p.dirname(folders.path), root.path);
      expect(p.basename(folders.path), contains('SANS_DATE_DE_NAISSANCE'));
      expect(p.basename(folders.path), isNot(contains(':')));
      expect(p.basename(folders.path), isNot(contains('\\')));
    },
  );

  test('Long Unicode names fit the filesystem component limit', () async {
    final folders = await ensure(
      await patient(lastName: List.filled(200, '界').join()),
    );
    expect(
      utf8.encode(p.basename(folders.path)).length,
      lessThanOrEqualTo(180),
    );
    expect(await Directory(folders.other).exists(), isTrue);
  });

  test(
    'Unavailable roots are not recreated and do not assign a folder',
    () async {
      final id = await patient();
      await root.delete();
      await expectLater(ensure(id), throwsA(isA<FileSystemException>()));
      expect(await root.exists(), isFalse);
      final db = await DatabaseService.database;
      expect(await db.query('patient_document_folders'), isEmpty);
    },
  );

  test(
    'A failed subdirectory creation retries the same folder without modifying files',
    () async {
      final id = await patient();
      final first = await ensure(id);
      await Directory(first.other).delete();
      final file = await File(first.other).writeAsString('Do not overwrite');
      await expectLater(ensure(id), throwsA(isA<FileSystemException>()));
      expect(await file.readAsString(), 'Do not overwrite');
      await file.delete();
      expect((await ensure(id)).path, first.path);
      expect(await Directory(first.other).exists(), isTrue);
    },
  );

  test(
    'Symlinks cannot redirect patient documents outside the patient folder',
    () async {
      final id = await patient();
      final first = await ensure(id);
      await Directory(first.other).delete();
      await Link(first.other).create(temporary.path);
      await expectLater(ensure(id), throwsA(isA<FileSystemException>()));
    },
  );

  test('Migration from v29 preserves patients and existing files', () async {
    final id = await patient();
    final original = await File(
      p.join(root.path, 'existing.docx'),
    ).writeAsString('Keep');
    final db = await DatabaseService.database;
    await db.execute('DROP TABLE patient_document_folders');
    await db.setVersion(29);
    await DatabaseService.closeDatabase();
    final folders = await ensure(id);
    expect(await Directory(folders.path).exists(), isTrue);
    expect(await original.readAsString(), 'Keep');
    expect(
      await (await DatabaseService.database).getVersion(),
      DatabaseService.schemaVersion,
    );
  });

  test(
    'New exports use the appropriate subfolders without moving older files',
    () async {
      final original = await File(
        p.join(root.path, 'existing.docx'),
      ).writeAsString('Old');
      final folders = await ensure(await patient());
      const exporter = EpisodeReportDocxExportService();
      for (final folder in [folders.assessment, folders.report]) {
        final file = await exporter.exportToDocxFile(
          bytes: Uint8List.fromList([1, 2, 3]),
          directory: Directory(folder),
          fileName: 'Document',
        );
        expect(p.dirname(file.path), folder);
      }
      expect(await original.readAsString(), 'Old');
    },
  );

  test(
    'Patient deletion retains external files and prevents their reassignment',
    () async {
      final id = await patient();
      final first = await ensure(id);
      final file = await File(
        p.join(first.other, 'note.txt'),
      ).writeAsString('Keep');
      await patients.deletePatientPermanently(id);
      expect(await file.readAsString(), 'Keep');
      final second = await ensure(await patient());
      expect(second.path, isNot(first.path));
    },
  );
}

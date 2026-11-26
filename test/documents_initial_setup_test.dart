import 'dart:io';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/core/settings/application_settings_service.dart';
import 'package:abak_desktop_companion/core/settings/generated_documents_directory_service.dart';
import 'package:abak_desktop_companion/core/settings/macos_directory_access_service.dart';
import 'package:abak_desktop_companion/features/patients/data/patient_repository.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_documents_service.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/companion_access_test_support.dart';

class _Paths extends PathProviderPlatform {
  _Paths(this.root);
  final String root;
  @override
  Future<String?> getApplicationSupportPath() async => p.join(root, 'support');
  @override
  Future<String?> getApplicationDocumentsPath() async => Platform.isMacOS
      ? p.join(
          root,
          'Library',
          'Containers',
          'test.companion',
          'Data',
          'Documents',
        )
      : p.join(root, 'Documents');
}

class _Picker extends FilePicker {
  String? selection;
  String? initial;
  @override
  Future<String?> getDirectoryPath({
    String? dialogTitle,
    bool lockParentWindow = false,
    String? initialDirectory,
  }) async {
    initial = initialDirectory;
    return selection;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    FilePicker.platform = _Picker();
  });
  const service = GeneratedDocumentsDirectoryService();
  const settings = ApplicationSettingsService();
  const key = ApplicationSettingsService.assessmentDocumentsDirectoryKey;
  const channel = MethodChannel('abak/directory_access');
  late Directory temporary, documents;
  late PathProviderPlatform previous;
  late FilePicker previousPicker;
  late _Picker picker;
  final calls = <MethodCall>[];
  String? selected;
  bool cancel = false, denied = false;

  setUp(() async {
    temporary = await Directory.systemTemp.createTemp('abak_m1_');
    documents = await Directory(p.join(temporary.path, 'Documents')).create();
    previous = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _Paths(temporary.path);
    previousPicker = FilePicker.platform;
    picker = _Picker();
    FilePicker.platform = picker;
    SharedPreferences.setMockInitialValues({});
    await S.load(const Locale('fr', 'FR'));
    calls.clear();
    selected = null;
    cancel = false;
    denied = false;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          final args = Map<String, dynamic>.from(call.arguments as Map? ?? {});
          if (call.method == 'userDocumentsPath') return documents.path;
          if (call.method == 'releaseDirectory') return null;
          if (call.method == 'chooseDirectory') {
            if (cancel) return null;
            if (denied) {
              throw PlatformException(code: 'DIRECTORY_ACCESS_FAILED');
            }
            if (args['createDocumentsChild'] == true) {
              expect(args['expectedPath'], documents.path);
              expect(args['initialPath'], documents.path);
              expect(await settings.getString(key), isNull);
              selected = (await Directory(
                p.join(documents.path, 'ABAK_DOCUMENTS'),
              ).create()).path;
            }
          }
          if (call.method == 'chooseDirectory' ||
              call.method == 'restoreDirectory') {
            return {'path': selected, 'token': 'token', 'bookmark': 'bookmark'};
          }
          fail('Unexpected method ${call.method}');
        });
  });
  tearDown(() async {
    await DatabaseService.closeDatabase();
    PathProviderPlatform.instance = previous;
    FilePicker.platform = previousPicker;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
    await temporary.delete(recursive: true);
  });
  Future<void> select(String path) async {
    selected = path;
    picker.selection = path;
  }

  test(
    'M2.3 secondary reauthorization preserves SQLite row and exact root',
    () async {
      await select(documents.path);
      await service.chooseAndSave();
      final db = await DatabaseService.database;
      final before = await db.query('application_settings');
      calls.clear();
      expect(await service.chooseAndSave(), documents.path);
      expect(await service.useRecommended(), documents.path);
      expect(await db.query('application_settings'), before);
      if (Platform.isMacOS) {
        for (final call in calls.where((c) => c.method == 'chooseDirectory')) {
          expect(call.arguments['expectedPath'], documents.path);
          expect(call.arguments['initialPath'], documents.path);
        }
      }
      expect(
        await Directory(p.join(documents.path, 'ABAK_DOCUMENTS')).exists(),
        isFalse,
      );
    },
  );
  test('M2.3 direct setter and remove cannot bypass migration', () async {
    await settings.setString(key, documents.path);
    final db = await DatabaseService.database;
    final before = await db.query('application_settings');
    await settings.setString(key, documents.path); // No needless UPDATE.
    expect(await db.query('application_settings'), before);
    await expectLater(
      settings.setString(key, p.join(temporary.path, 'other')),
      throwsStateError,
    );
    await expectLater(settings.setString(key, ''), throwsStateError);
    await expectLater(settings.remove(key), throwsStateError);
    expect(await db.query('application_settings'), before);
  });
  test(
    'M2.3 mismatched native selection cannot change a configured root',
    () async {
      await select(documents.path);
      await service.chooseAndSave();
      final other = await Directory(p.join(temporary.path, 'other')).create();
      await select(other.path); // Simulate an unexpected platform response.
      await expectLater(
        service.chooseAndSave(),
        throwsA(isA<DirectoryAuthorizationRequired>()),
      );
      expect(await settings.getString(key), documents.path);
      expect(calls.last.method, 'releaseDirectory');
    },
    skip: !Platform.isMacOS,
  );
  test('M2.3 relocated bookmark cannot silently change export root', () async {
    await select(documents.path);
    await service.chooseAndSave();
    final other = await Directory(p.join(temporary.path, 'relocated')).create();
    await select(other.path);
    await expectLater(
      service.acquireForExport(),
      throwsA(isA<DirectoryAuthorizationRequired>()),
    );
    expect(await settings.getString(key), documents.path);
    expect(calls.last.method, 'releaseDirectory');
  }, skip: !Platform.isMacOS);
  test(
    'Fresh SQLite: suggestion creates no folder and writes no setting',
    () async {
      expect(await service.needsInitialConfiguration(), isTrue);
      expect(
        await service.recommendedPath(),
        p.join(documents.path, 'ABAK_DOCUMENTS'),
      );
      expect(await documents.list().toList(), isEmpty);
      expect(await settings.getString(key), isNull);
      final db = await DatabaseService.database;
      expect(await db.query('application_settings'), isEmpty);
    },
  );
  test(
    'macOS recommendation ignores the path_provider sandbox Documents',
    () async {
      final container = (await PathProviderPlatform.instance
          .getApplicationDocumentsPath())!;
      expect(container, contains('/Library/Containers/'));
      expect(
        await service.recommendedPath(),
        p.join(documents.path, 'ABAK_DOCUMENTS'),
      );
      expect(await Directory(container).exists(), isFalse);
      expect(await documents.list().toList(), isEmpty);
      expect(await settings.getString(key), isNull);
    },
    skip: !Platform.isMacOS,
  );

  test(
    'An already saved sandbox path is preserved without resolving a recommendation',
    () async {
      final container = (await PathProviderPlatform.instance
          .getApplicationDocumentsPath())!;
      final existing = p.join(container, 'ABAK_DOCUMENTS');
      await settings.setString(key, existing);
      expect(await service.needsInitialConfiguration(), isFalse);
      expect(await settings.getString(key), existing);
      expect(calls, isEmpty);
      expect(await Directory(container).exists(), isFalse);
    },
    skip: !Platform.isMacOS,
  );

  test('Empty setting still needs configuration and stays empty', () async {
    await settings.setString(key, '');
    expect(await service.needsInitialConfiguration(), isTrue);
    await service.recommendedPath();
    expect(await settings.getString(key), '');
  });
  test(
    'Accept recommendation, validate, save and restore after restart',
    () async {
      final path = await service.useRecommended();
      expect(path, p.join(documents.path, 'ABAK_DOCUMENTS'));
      expect(await Directory(path!).list().toList(), isEmpty);
      expect(await settings.getString(key), path);
      await DatabaseService.closeDatabase();
      expect(await service.needsInitialConfiguration(), isFalse);
      final access = await service.acquireConfigured();
      expect(access!.path, path);
      await access.release();
      if (Platform.isMacOS) {
        expect(
          calls.where((c) => c.method == 'restoreDirectory'),
          hasLength(1),
        );
        expect(
          calls.where((c) => c.method == 'releaseDirectory'),
          hasLength(2),
        );
        expect(
          (await SharedPreferences.getInstance()).getKeys().any(
            (k) => k.startsWith('macos_directory_bookmark_v1_'),
          ),
          isTrue,
        );
      }
    },
  );
  test(
    'Custom folder is validated and saved; picker starts in Documents',
    () async {
      final custom = await Directory(p.join(temporary.path, 'custom')).create();
      await select(custom.path);
      expect(await service.chooseAndSave(), custom.path);
      expect(await settings.getString(key), custom.path);
      expect(await custom.list().toList(), isEmpty);
      if (Platform.isMacOS) {
        final call = calls.singleWhere((c) => c.method == 'chooseDirectory');
        expect(call.arguments['initialPath'], documents.path);
      } else {
        expect(picker.initial, documents.path);
      }
    },
  );
  test('Cancelling picker changes neither settings nor directories', () async {
    cancel = true;
    expect(await service.chooseAndSave(), isNull);
    expect(await settings.getString(key), isNull);
    expect(await documents.list().toList(), isEmpty);
    expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
  });
  test('Cancelling native recommended authorization creates nothing', () async {
    cancel = true;
    expect(await service.useRecommended(), isNull);
    expect(await settings.getString(key), isNull);
    expect(await documents.list().toList(), isEmpty);
  }, skip: !Platform.isMacOS);
  for (final existing in ['historical', 'project', 'missing']) {
    test(
      'Preserves existing $existing root without prompting or replacing it',
      () async {
        // Even the simulated project directory is temporary: no real patient data.
        final path = p.join(temporary.path, existing);
        if (existing != 'missing') await Directory(path).create();
        await settings.setString(key, path);
        expect(await service.needsInitialConfiguration(), isFalse);
        expect(await settings.getString(key), path);
        expect(calls, isEmpty);
        expect(await documents.list().toList(), isEmpty);
      },
    );
  }
  test(
    'Unavailable selection never saves a root and releases authorization',
    () async {
      await select(p.join(temporary.path, 'missing'));
      await expectLater(
        service.chooseAndSave(),
        throwsA(isA<FileSystemException>()),
      );
      expect(await settings.getString(key), isNull);
      if (Platform.isMacOS) expect(calls.last.method, 'releaseDirectory');
    },
  );
  test(
    'Creation failure never saves a path or changes existing contents',
    () async {
      final blocker = await File(
        p.join(documents.path, 'ABAK_DOCUMENTS'),
      ).writeAsString('Keep');
      await expectLater(
        service.useRecommended(),
        throwsA(
          Platform.isMacOS
              ? isA<PlatformException>()
              : isA<FileSystemException>(),
        ),
      );
      expect(await settings.getString(key), isNull);
      expect(await blocker.readAsString(), 'Keep');
    },
  );
  test('macOS denial leaves SQLite and Documents unchanged', () async {
    denied = true;
    await expectLater(
      service.useRecommended(),
      throwsA(isA<PlatformException>()),
    );
    expect(await settings.getString(key), isNull);
    expect(await documents.list().toList(), isEmpty);
    expect((await SharedPreferences.getInstance()).getKeys(), isEmpty);
  }, skip: !Platform.isMacOS);
  test(
    'An existing path without macOS authorization is not silently replaced',
    () async {
      await settings.setString(key, documents.path);
      await expectLater(
        service.acquireConfigured(),
        throwsA(isA<DirectoryAuthorizationRequired>()),
      );
      expect(await settings.getString(key), documents.path);
      expect(calls, isEmpty);
    },
    skip: !Platform.isMacOS,
  );
  test(
    'Explicit root change preserves patient folder associations and documents',
    () async {
      final patient = await PatientRepository().createPatient(
        referringPractitionerId: await seedPatientReferrer(),
        lastName: 'Test',
        firstName: 'M1',
      );
      final folders = await const PatientDocumentsService().ensureInRoot(
        patientId: patient.patientId,
        rootPath: documents.path,
      );
      final file = await File(
        p.join(folders.other, 'keep.txt'),
      ).writeAsString('Test document');
      final db = await DatabaseService.database;
      final before = await db.query('patient_document_folders');
      final custom = await Directory(p.join(temporary.path, 'custom')).create();
      await select(custom.path);
      await service.chooseAndSave();
      expect(await db.query('patient_document_folders'), before);
      expect(await file.readAsString(), 'Test document');
      expect(await custom.list().toList(), isEmpty);
    },
  );
  test(
    'An export destination remains transient and does not configure the root',
    () async {
      await select(documents.path);
      final access = await service.acquireForExport();
      expect(access!.path, documents.path);
      await access.release();
      expect(await settings.getString(key), isNull);
    },
  );
  test('Read-only directory is rejected without persisting it', () async {
    await Process.run('chmod', ['500', documents.path]);
    try {
      await select(documents.path);
      await expectLater(
        service.chooseAndSave(),
        throwsA(isA<FileSystemException>()),
      );
      expect(await settings.getString(key), isNull);
    } finally {
      await Process.run('chmod', ['700', documents.path]);
    }
  }, skip: Platform.isWindows);
}

import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:abak_desktop_companion/core/settings/application_settings_service.dart';
import 'package:abak_desktop_companion/core/settings/macos_directory_access_service.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';
import 'package:abak_desktop_companion/features/patients/data/patient_repository.dart';
import 'package:abak_desktop_companion/features/patients/data/episode_document_repository.dart';
import 'package:abak_desktop_companion/features/patients/models/episode_document.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_attachment_service.dart';

class Paths extends PathProviderPlatform {
  Paths(this.path);
  final String path;
  @override
  Future<String?> getApplicationSupportPath() async => path;
}

class Access extends AttachmentDirectoryAccess {
  Access(this.root);
  String? root;
  int held = 0;
  final acquired = <String>[];
  AttachmentDirectoryLease lease(String path) {
    held++;
    return AttachmentDirectoryLease(path, () async {
      held--;
    });
  }

  @override
  Future<AttachmentDirectoryLease?> configured() async =>
      root == null ? null : lease(root!);
  @override
  Future<AttachmentDirectoryLease> acquire(String path) async {
    acquired.add(path);
    return lease(path);
  }
}

class FailingRepository extends EpisodeDocumentRepository {
  @override
  Future<EpisodeDocument> create({
    required String caseId,
    required String title,
    required String filePath,
    String? mimeType,
    String? source,
  }) async => throw StateError('insert failed');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temp, root, support;
  late PathProviderPlatform previous;
  late Access access;
  late PatientAttachmentService service;
  late File source;
  late String patient;
  setUp(() async {
    await S.load(const Locale('fr', 'FR'));
    temp = Directory.systemTemp.createTempSync('patient-attachments-');
    root = Directory(p.join(temp.path, 'documents'))..createSync();
    support = Directory(p.join(temp.path, 'support'))..createSync();
    previous = PathProviderPlatform.instance;
    PathProviderPlatform.instance = Paths(support.path);
    patient = (await PatientRepository().createPatient(
      lastName: 'Dupont',
      firstName: 'Jean',
    )).patientId;
    final db = await DatabaseService.database;
    await db.insert('care_episodes', {
      'care_episode_id': 'episode',
      'patient_id': patient,
      'title': 'Episode',
      'pathology_label': 'Test',
      'created_at': 1,
    });
    source = File(p.join(temp.path, 'note.txt'))..writeAsStringSync('original');
    access = Access(root.path);
    service = PatientAttachmentService(access: access);
  });
  tearDown(() async {
    expect(access.held, 0);
    await DatabaseService.closeDatabase();
    PathProviderPlatform.instance = previous;
    temp.deleteSync(recursive: true);
  });
  test(
    'macOS bookmark access covers add and open, while cancel or revocation preserves data',
    () async {
      const settings = ApplicationSettingsService();
      await settings.setString(
        ApplicationSettingsService.assessmentDocumentsDirectoryKey,
        root.path,
      );
      final key =
          'macos_directory_bookmark_v1_${base64Url.encode(utf8.encode(root.path))}';
      SharedPreferences.setMockInitialValues({key: 'bookmark'});
      const channel = MethodChannel('abak/directory_access');
      final calls = <String>[];
      var held = 0;
      final messenger =
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
      messenger.setMockMethodCallHandler(channel, (call) async {
        calls.add(call.method);
        if (call.method == 'restoreDirectory') {
          held++;
          return {'path': root.path, 'token': 'lease', 'bookmark': 'bookmark'};
        }
        if (call.method == 'releaseDirectory') {
          held--;
          return null;
        }
        if (call.method == 'chooseDirectory') return null;
        throw StateError('Unexpected native call');
      });
      addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
      final native = PatientAttachmentService();
      final doc = await native.add(caseId: 'episode', sourcePath: source.path);
      expect(calls, ['restoreDirectory', 'releaseDirectory']);
      expect(held, 0);
      await native.open(
        doc,
        openFile: (_) async {
          expect(held, 1);
        },
      );
      expect(held, 0);
      expect(await native.access.configure(), isFalse);
      expect(
        await settings.getString(
          ApplicationSettingsService.assessmentDocumentsDirectoryKey,
        ),
        root.path,
      );
      SharedPreferences.setMockInitialValues({});
      final previousCalls = calls.length;
      await expectLater(
        native.add(caseId: 'episode', sourcePath: source.path),
        throwsA(isA<DirectoryAuthorizationRequired>()),
      );
      await expectLater(
        native.open(doc),
        throwsA(isA<DirectoryAuthorizationRequired>()),
      );
      expect(calls.length, previousCalls);
      expect(File(doc.filePath).readAsStringSync(), 'original');
      expect(
        (await EpisodeDocumentRepository().getByCaseId('episode')).length,
        1,
      );
    },
    skip: !Platform.isMacOS,
  );

  test(
    'symlink occupying Autre is refused without writing outside patient folder',
    () async {
      final good = await service.add(
        caseId: 'episode',
        sourcePath: source.path,
      );
      final other = Directory(p.dirname(good.filePath));
      await other.rename('${other.path}-saved');
      final outside = Directory(p.join(temp.path, 'outside'))..createSync();
      await Link(other.path).create(outside.path);
      await expectLater(
        service.add(caseId: 'episode', sourcePath: source.path),
        throwsA(isA<FileSystemException>()),
      );
      expect(outside.listSync(), isEmpty);
    },
    skip: Platform.isWindows,
  );

  test(
    'new copy in Autre survives restart; authorization remains active during opening',
    () async {
      final doc = await service.add(caseId: 'episode', sourcePath: source.path);
      expect(p.basename(p.dirname(doc.filePath)), 'Autre');
      expect(doc.source, 'local_copy');
      expect(doc.mimeType, 'text/plain');
      expect(source.readAsStringSync(), 'original');
      expect(
        await Directory(p.join(support.path, 'episode_documents')).exists(),
        isFalse,
      );
      await DatabaseService.closeDatabase();
      final saved = (await EpisodeDocumentRepository().getById(
        doc.documentId,
      ))!;
      await service.open(
        saved,
        openFile: (path) async {
          expect(access.held, 1);
          expect(File(path).readAsStringSync(), 'original');
        },
      );
    },
  );
  test(
    'concurrent same names and importing an existing destination never overwrite',
    () async {
      final docs = await Future.wait(
        List.generate(
          4,
          (_) => service.add(caseId: 'episode', sourcePath: source.path),
        ),
      );
      expect(docs.map((d) => d.filePath).toSet().length, 4);
      final copy = await service.add(
        caseId: 'episode',
        sourcePath: docs.first.filePath,
      );
      expect(copy.filePath, isNot(docs.first.filePath));
      for (final d in [...docs, copy]) {
        expect(File(d.filePath).readAsStringSync(), 'original');
      }
    },
  );
  test(
    'same patient shares Autre, complete homonyms remain isolated',
    () async {
      final db = await DatabaseService.database;
      final other = (await PatientRepository().createPatient(
        lastName: 'Dupont',
        firstName: 'Jean',
      )).patientId;
      for (final entry in {'same': patient, 'other': other}.entries) {
        await db.insert('care_episodes', {
          'care_episode_id': entry.key,
          'patient_id': entry.value,
          'title': 'Episode',
          'pathology_label': 'Test',
          'created_at': 1,
        });
      }
      final a = await service.add(caseId: 'episode', sourcePath: source.path);
      final b = await service.add(caseId: 'same', sourcePath: source.path);
      final c = await service.add(caseId: 'other', sourcePath: source.path);
      expect(p.dirname(a.filePath), p.dirname(b.filePath));
      expect(p.dirname(a.filePath), isNot(p.dirname(c.filePath)));
      expect(
        (await EpisodeDocumentRepository().getByCaseId('episode')).length,
        1,
      );
    },
  );
  test(
    'missing configuration and unavailable root never fall back to internal storage',
    () async {
      access.root = null;
      await expectLater(
        service.add(caseId: 'episode', sourcePath: source.path),
        throwsA(isA<AttachmentDestinationRequired>()),
      );
      access.root = p.join(temp.path, 'unavailable');
      await expectLater(
        service.add(caseId: 'episode', sourcePath: source.path),
        throwsA(isA<FileSystemException>()),
      );
      expect(Directory(access.root!).existsSync(), isFalse);
      expect(await EpisodeDocumentRepository().getByCaseId('episode'), isEmpty);
    },
  );
  test(
    'registration failure removes only its own copy and releases authorization',
    () async {
      final good = await service.add(
        caseId: 'episode',
        sourcePath: source.path,
      );
      final failing = PatientAttachmentService(
        access: access,
        repository: FailingRepository(),
      );
      await expectLater(
        failing.add(caseId: 'episode', sourcePath: source.path),
        throwsStateError,
      );
      expect(Directory(p.dirname(good.filePath)).listSync().length, 1);
      expect(File(good.filePath).readAsStringSync(), 'original');
      expect(source.existsSync(), isTrue);
    },
  );
  test('changing root retains old path and its own authorization', () async {
    final old = await service.add(caseId: 'episode', sourcePath: source.path);
    final next = Directory(p.join(temp.path, 'next'))..createSync();
    access.root = next.path;
    final fresh = await service.add(caseId: 'episode', sourcePath: source.path);
    expect(p.isWithin(next.path, fresh.filePath), isTrue);
    await service.open(
      old,
      openFile: (path) async {
        expect(path, old.filePath);
      },
    );
    expect(access.acquired.last, root.path);
  });
  test(
    'legacy attachment opens without moving or external authorization',
    () async {
      final file = File(
        p.join(support.path, 'episode_documents', 'episode', 'old.txt'),
      );
      file.parent.createSync(recursive: true);
      file.writeAsStringSync('legacy');
      final doc = await EpisodeDocumentRepository().create(
        caseId: 'episode',
        title: 'Old',
        filePath: file.path,
        source: 'local_copy',
      );
      access.root = null;
      await service.open(
        doc,
        openFile: (path) async {
          expect(path, file.path);
        },
      );
      expect(access.acquired, isEmpty);
      expect(file.readAsStringSync(), 'legacy');
    },
  );
  test(
    'missing files, foreign patient paths and final PDFs cannot be opened here',
    () async {
      final doc = await service.add(caseId: 'episode', sourcePath: source.path);
      await expectLater(
        service.open(
          EpisodeDocument(
            documentId: 'x',
            caseId: 'episode',
            title: 'x',
            filePath: source.path,
            source: 'local_copy',
            createdAt: 1,
          ),
        ),
        throwsStateError,
      );
      await expectLater(
        service.open(
          EpisodeDocument(
            documentId: 'x',
            caseId: 'episode',
            title: 'x',
            filePath: doc.filePath,
            source: 'final_pdf',
            createdAt: 1,
          ),
        ),
        throwsStateError,
      );
      File(doc.filePath).deleteSync();
      await expectLater(service.open(doc), throwsA(isA<FileSystemException>()));
    },
  );
  test(
    'opening failure releases authorization and leaves attachment intact',
    () async {
      final doc = await service.add(caseId: 'episode', sourcePath: source.path);
      await expectLater(
        service.open(
          doc,
          openFile: (_) async => throw StateError('open failed'),
        ),
        throwsStateError,
      );
      expect(File(doc.filePath).existsSync(), isTrue);
    },
  );
  test('invalid episode does not acquire a root or copy files', () async {
    await expectLater(
      service.add(caseId: 'missing', sourcePath: source.path),
      throwsStateError,
    );
    expect(root.listSync(), isEmpty);
  });
}

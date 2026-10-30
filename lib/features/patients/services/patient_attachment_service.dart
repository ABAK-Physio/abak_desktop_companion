import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../core/database/database_service.dart';
import '../../../core/settings/generated_documents_directory_service.dart';
import '../../../core/settings/macos_directory_access_service.dart';
import '../../../generated/l10n.dart';
import '../data/episode_document_repository.dart';
import '../models/episode_document.dart';
import 'document_mime.dart';
import 'patient_documents_service.dart';

class AttachmentDestinationRequired implements Exception {}

/// Hold the authorization until copying, registering or opening has finished.
class AttachmentDirectoryLease {
  AttachmentDirectoryLease(this.path, [this._release]);
  final String path;
  final Future<void> Function()? _release;
  Future<void> release() async => _release?.call();
}

class AttachmentDirectoryAccess {
  const AttachmentDirectoryAccess();
  Future<AttachmentDirectoryLease?> configured() async {
    final access = await const GeneratedDocumentsDirectoryService()
        .acquireConfigured();
    return access == null
        ? null
        : AttachmentDirectoryLease(access.path, access.release);
  }

  Future<AttachmentDirectoryLease> acquire(String root) async {
    if (!Platform.isMacOS) return AttachmentDirectoryLease(root);
    final access = await const MacosDirectoryAccessService().acquireDirectory(
      root,
    );
    return AttachmentDirectoryLease(access.path, access.release);
  }

  Future<bool> configure() async =>
      await const GeneratedDocumentsDirectoryService().chooseAndSave() != null;
  Future<bool> authorize(String root) async {
    if (!Platform.isMacOS) return false;
    final access = await const MacosDirectoryAccessService().chooseDirectory(
      title: S.current.episodeAttachments_authorizeFolder,
      expectedPath: root,
      initialPath: root,
    );
    if (access == null) return false;
    try {
      if (!p.equals(p.normalize(access.path), p.normalize(root))) {
        throw DirectoryAuthorizationRequired(root);
      }
      return true;
    } finally {
      await access.release();
    }
  }
}

/// Ordinary attachments only. Final PDFs and their version services are untouched.
class PatientAttachmentService {
  PatientAttachmentService({
    Future<Database> Function()? database,
    EpisodeDocumentRepository? repository,
    this.access = const AttachmentDirectoryAccess(),
    Future<Directory> Function()? supportDirectory,
    Future<PatientDocumentFolders> Function(String patientId, String root)?
    ensureFolders,
  }) : _database = database ?? (() => DatabaseService.database),
       _repository =
           repository ?? EpisodeDocumentRepository(database: database),
       _supportDirectory = supportDirectory ?? getApplicationSupportDirectory,
       _ensureFolders =
           ensureFolders ??
           ((patient, root) => const PatientDocumentsService().ensureInRoot(
             patientId: patient,
             rootPath: root,
           ));
  final Future<Database> Function() _database;
  final EpisodeDocumentRepository _repository;
  final AttachmentDirectoryAccess access;
  final Future<Directory> Function() _supportDirectory;
  final Future<PatientDocumentFolders> Function(String, String) _ensureFolders;

  Future<String> _patient(String caseId, {bool active = true}) async {
    final rows = await (await _database()).query(
      'care_episodes',
      columns: ['patient_id'],
      where: active
          ? 'care_episode_id = ? AND archived_at IS NULL'
          : 'care_episode_id = ?',
      whereArgs: [caseId],
    );
    if (rows.length != 1) {
      throw StateError(S.current.episodeAttachments_episodeUnavailable);
    }
    return rows.single['patient_id'] as String;
  }

  Future<EpisodeDocument> add({
    required String caseId,
    required String sourcePath,
  }) async {
    final patient = await _patient(caseId);
    final lease = await access.configured();
    if (lease == null) throw AttachmentDestinationRequired();
    File? copied;
    var registered = false;
    try {
      if (!await Directory(lease.path).exists()) {
        throw FileSystemException(
          S.current.episodeAttachments_destinationUnavailable,
          lease.path,
        );
      }
      final folders = await _ensureFolders(patient, lease.path);
      final source = File(sourcePath);
      if (!await source.exists()) {
        throw FileSystemException(
          S.current.episodeDocuments_fileNotFound,
          sourcePath,
        );
      }
      final raw = p
          .basename(sourcePath)
          .replaceAll(RegExp(r'[\/:*?"<>|]'), '_')
          .trim();
      final safe = raw.isEmpty || raw == '.' || raw == '..' ? 'document' : raw;
      final stem = p.basenameWithoutExtension(safe),
          extension = p.extension(safe);
      for (var suffix = 0; ; suffix++) {
        final candidate = File(
          p.join(
            folders.other,
            suffix == 0 ? safe : '${stem}_$suffix$extension',
          ),
        );
        try {
          // Reserve atomically: two imports cannot overwrite the same name.
          await candidate.create(exclusive: true);
          copied = candidate;
          break;
        } on FileSystemException {
          if (await FileSystemEntity.type(candidate.path, followLinks: false) ==
              FileSystemEntityType.notFound) {
            rethrow;
          }
        }
      }
      await source.openRead().pipe(copied.openWrite());
      final mime = await DocumentMime.forFile(copied);
      // Recheck after filesystem work, before associating the copy.
      if (await _patient(caseId) != patient) {
        throw StateError(S.current.episodeAttachments_episodeUnavailable);
      }
      final document = await _repository.create(
        caseId: caseId,
        title: p.basename(sourcePath),
        filePath: copied.path,
        mimeType: mime,
        source: 'local_copy',
      );
      registered = true;
      return document;
    } finally {
      try {
        if (!registered && copied != null && await copied.exists()) {
          await copied.delete();
        }
      } finally {
        await lease.release();
      }
    }
  }

  Future<void> open(
    EpisodeDocument document, {
    Future<void> Function(String)? openFile,
  }) async {
    if (document.source != 'local_copy') {
      throw StateError(S.current.episodeAttachments_invalidAttachment);
    }
    final patient = await _patient(document.caseId, active: false);
    final path = p.normalize(p.absolute(document.filePath));
    final support = await _supportDirectory();
    final legacy = p.join(support.path, 'episode_documents', document.caseId);
    AttachmentDirectoryLease? lease;
    var resolved = path;
    try {
      if (!p.isWithin(legacy, path)) {
        final rows = await (await _database()).query(
          'patient_document_folders',
          where: 'patient_id = ?',
          whereArgs: [patient],
        );
        final matches = rows.where((row) {
          final name = row['folder_name'] as String;
          return p.basename(name) == name &&
              name != '.' &&
              name != '..' &&
              !name.contains('\\') &&
              p.isWithin(
                p.join(row['root_path'] as String, name, 'Autre'),
                path,
              );
        }).toList();
        if (matches.length != 1) {
          throw StateError(S.current.episodeAttachments_invalidAttachment);
        }
        final root = matches.single['root_path'] as String;
        lease = await access.acquire(root);
        resolved = p.join(lease.path, p.relative(path, from: root));
        // Do not follow a replacement symlink outside the authorized root.
        if (await File(resolved).exists() &&
            !p.isWithin(
              await Directory(lease.path).resolveSymbolicLinks(),
              await File(resolved).resolveSymbolicLinks(),
            )) {
          throw StateError(S.current.episodeAttachments_invalidAttachment);
        }
      }
      if (!await File(resolved).exists()) {
        throw FileSystemException(
          S.current.episodeDocuments_fileNotFound,
          resolved,
        );
      }
      if (openFile != null) {
        await openFile(resolved);
        return;
      }
      final ProcessResult result;
      if (Platform.isMacOS) {
        result = await Process.run('open', [resolved]);
      } else if (Platform.isWindows) {
        result = await Process.run('cmd', [
          '/c',
          'start',
          '',
          resolved,
        ], runInShell: true);
      } else {
        throw UnsupportedError(S.current.episodeDocuments_platformNotSupported);
      }
      if (result.exitCode != 0) {
        throw FileSystemException(result.stderr.toString(), resolved);
      }
    } finally {
      await lease?.release();
    }
  }
}

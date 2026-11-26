import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'package:path/path.dart' as p;
import '../../features/maintenance/services/companion_backup_archive.dart';

/// Same-volume installation must not replace even an empty existing directory.
class MigrationFiles {
  static String windowsExtendedPath(String path) {
    if (path.startsWith(r'\\?\')) return path;
    if (path.startsWith(r'\\')) return r'\\?\UNC\' + path.substring(2);
    return r'\\?\' + path;
  }

  static Future<int?> availableBytes(String path) =>
      Isolate.run(() => _availableBytes(path));

  static int? _availableBytes(String path) {
    try {
      if (Platform.isMacOS && sizeOf<IntPtr>() == 8) {
        // macOS SDK: ulong sizes/flags, but 32-bit fsblkcnt_t/fsfilcnt_t.
        final f = DynamicLibrary.process()
            .lookupFunction<
              Int32 Function(Pointer<Utf8>, Pointer<_MacStatVfs>),
              int Function(Pointer<Utf8>, Pointer<_MacStatVfs>)
            >('statvfs');
        final name = path.toNativeUtf8(), values = calloc<_MacStatVfs>();
        try {
          return f(name, values) == 0
              ? values.ref.fragmentSize * values.ref.availableBlocks
              : null;
        } finally {
          calloc.free(name);
          calloc.free(values);
        }
      }
      if (Platform.isWindows) {
        final f = DynamicLibrary.open('kernel32.dll')
            .lookupFunction<
              Int32 Function(
                Pointer<Utf16>,
                Pointer<Uint64>,
                Pointer<Uint64>,
                Pointer<Uint64>,
              ),
              int Function(
                Pointer<Utf16>,
                Pointer<Uint64>,
                Pointer<Uint64>,
                Pointer<Uint64>,
              )
            >('GetDiskFreeSpaceExW');
        final name = windowsExtendedPath(path).toNativeUtf16(),
            values = calloc<Uint64>(3);
        try {
          return f(name, values, values + 1, values + 2) != 0
              ? values.value
              : null;
        } finally {
          calloc.free(name);
          calloc.free(values);
        }
      }
    } catch (_) {
      /* Unknown space requires explicit D6 consent. */
    }
    return null;
  }

  static Future<void> install(String from, String to) =>
      Isolate.run(() => _install(from, to));

  static void _install(String from, String to) {
    if (Platform.isMacOS) {
      final f = DynamicLibrary.process()
          .lookupFunction<
            Int32 Function(Pointer<Utf8>, Pointer<Utf8>, Uint32),
            int Function(Pointer<Utf8>, Pointer<Utf8>, int)
          >('renamex_np');
      final a = from.toNativeUtf8(), b = to.toNativeUtf8();
      try {
        if (f(a, b, 4) != 0) {
          throw const FileSystemException('migration_install_failed');
        }
      } finally {
        calloc.free(a);
        calloc.free(b);
      }
    } else if (Platform.isWindows) {
      final f = DynamicLibrary.open('kernel32.dll')
          .lookupFunction<
            Int32 Function(Pointer<Utf16>, Pointer<Utf16>, Uint32),
            int Function(Pointer<Utf16>, Pointer<Utf16>, int)
          >('MoveFileExW');
      final a = windowsExtendedPath(from).toNativeUtf16(),
          b = windowsExtendedPath(to).toNativeUtf16();
      try {
        if (f(a, b, 8) == 0) {
          throw const FileSystemException('migration_install_failed');
        }
      } finally {
        calloc.free(a);
        calloc.free(b);
      }
    } else {
      throw UnsupportedError('migration_platform');
    }
  }

  static void protectJournalDirectory(String path) {
    if (!Platform.isMacOS) return; // Windows inherits the app-support ACL.
    final chmod = DynamicLibrary.process()
        .lookupFunction<
          Int32 Function(Pointer<Utf8>, Uint16),
          int Function(Pointer<Utf8>, int)
        >('chmod');
    final name = path.toNativeUtf8();
    try {
      if (chmod(name, 0x1c0) != 0) {
        throw const FileSystemException('migration_journal_permissions');
      }
    } finally {
      calloc.free(name);
    }
  }

  static Future<void> syncDirectory(String path) =>
      Isolate.run(() => _syncDirectory(path));

  static void _syncDirectory(String path) {
    // Windows installation uses WRITE_THROUGH; all file contents are flushed.
    if (Platform.isWindows) return;
    final lib = DynamicLibrary.process();
    final open = lib
        .lookupFunction<
          Int32 Function(Pointer<Utf8>, Int32),
          int Function(Pointer<Utf8>, int)
        >('open');
    final sync = lib.lookupFunction<Int32 Function(Int32), int Function(int)>(
      'fsync',
    );
    final close = lib.lookupFunction<Int32 Function(Int32), int Function(int)>(
      'close',
    );
    final name = path.toNativeUtf8();
    final fd = open(name, 0);
    calloc.free(name);
    if (fd < 0) {
      throw const FileSystemException('migration_directory_unavailable');
    }
    try {
      if (sync(fd) != 0) {
        throw const FileSystemException('migration_sync_failed');
      }
    } finally {
      close(fd);
    }
  }

  static Future<void> regular(String path, {required bool directory}) async {
    final expected = directory
        ? FileSystemEntityType.directory
        : FileSystemEntityType.file;
    if (await FileSystemEntity.type(path, followLinks: false) != expected) {
      throw const FileSystemException('migration_unsupported_entry');
    }
    // Resolve each descendant too: Windows junctions/reparse aliases must not
    // silently escape the inventory, even if exposed as a Directory by dart:io.
    final actual = await (directory
        ? Directory(path).resolveSymbolicLinks()
        : File(path).resolveSymbolicLinks());
    final parent = await Directory(p.dirname(path)).resolveSymbolicLinks();
    if (!p.equals(actual, p.join(parent, p.basename(path)))) {
      throw const FileSystemException('migration_alias');
    }
  }

  static Future<List<Map<String, Object?>>> inventory(
    String root,
    List<String> folders,
  ) => Isolate.run(() => _inventory(root, folders));

  static Future<List<Map<String, Object?>>> _inventory(
    String root,
    List<String> folders,
  ) async {
    final result = <Map<String, Object?>>[];
    final names = <String>{};
    Future<void> visit(String relative) async {
      CompanionBackupArchive.validatePath(relative);
      // Portable target names; conservatively reject case aliases on all volumes.
      if (!names.add(relative.toLowerCase()) ||
          relative
              .split('/')
              .any(
                (s) =>
                    s.endsWith('.') ||
                    s.endsWith(' ') ||
                    RegExp(r'[<>"|?*]').hasMatch(s) ||
                    RegExp(
                      r'^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(\.|$)',
                      caseSensitive: false,
                    ).hasMatch(s),
              )) {
        throw const FormatException('migration_name_collision');
      }
      final path = p.joinAll([root, ...relative.split('/')]);
      final type = await FileSystemEntity.type(path, followLinks: false);
      if (type == FileSystemEntityType.directory) {
        await regular(path, directory: true);
        result.add({'path': relative, 'directory': true});
        final children = await Directory(
          path,
        ).list(followLinks: false).toList();
        children.sort((a, b) => a.path.compareTo(b.path));
        for (final child in children) {
          await visit('$relative/${p.basename(child.path)}');
        }
      } else {
        await regular(path, directory: false);
        final file = File(path), before = await File(path).stat();
        final hash = await CompanionBackupArchive.digest(file);
        final after = await file.stat();
        if (before.size != after.size ||
            before.modified != after.modified ||
            before.changed != after.changed) {
          throw const FileSystemException('migration_source_changed');
        }
        result.add({
          'path': relative,
          'directory': false,
          'size': after.size,
          'sha256': hash,
        });
      }
    }

    for (final folder in [...folders]..sort()) {
      await visit(folder);
    }
    return result;
  }

  static Future<void> copy(
    String source,
    String target,
    List<Map<String, Object?>> manifest, {
    required void Function() checkCancelled,
    Future<void> Function(int)? progress,
  }) async {
    var count = 0;
    for (final entry in manifest) {
      checkCancelled();
      await regular(source, directory: true);
      await regular(target, directory: true);
      final relative = entry['path'] as String;
      final to = p.joinAll([target, ...relative.split('/')]);
      await regular(p.dirname(to), directory: true);
      if (await FileSystemEntity.type(to, followLinks: false) !=
          FileSystemEntityType.notFound) {
        throw const FileSystemException('migration_destination_conflict');
      }
      if (entry['directory'] == true) {
        await Directory(to).create();
      } else {
        final from = p.joinAll([source, ...relative.split('/')]);
        await regular(from, directory: false);
        await File(to).create(exclusive: true);
        final output = await File(to).open(mode: FileMode.writeOnly);
        try {
          await for (final chunk in File(from).openRead()) {
            checkCancelled();
            await output.writeFrom(chunk);
          }
          await output.flush();
        } finally {
          await output.close();
        }
      }
      await progress?.call(++count);
    }
    for (final entry in manifest.reversed.where(
      (e) => e['directory'] == true,
    )) {
      await syncDirectory(
        p.joinAll([target, ...(entry['path'] as String).split('/')]),
      );
    }
    await syncDirectory(target);
  }
}

final class _MacStatVfs extends Struct {
  @Uint64()
  external int blockSize;
  @Uint64()
  external int fragmentSize;
  @Uint32()
  external int blocks;
  @Uint32()
  external int freeBlocks;
  @Uint32()
  external int availableBlocks;
  @Uint32()
  external int files;
  @Uint32()
  external int freeFiles;
  @Uint32()
  external int availableFiles;
  @Uint64()
  external int id;
  @Uint64()
  external int flags;
  @Uint64()
  external int nameMax;
}

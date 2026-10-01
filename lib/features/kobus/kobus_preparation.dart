import 'dart:io';
import 'dart:isolate';
import 'package:archive/archive_io.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../patients/data/patient_repository.dart';
import '../patients/models/patient.dart';
import 'kobus_identity.dart';
import 'kobus_models.dart';

const _roots = {'Mes patients', 'Patients partagés', 'Patients partages'};

/// No changes to application data. Runs decompression/hashing off the UI isolate.
Future<KobusPreparation> prepareKobus(String path, {bool? windowsPaths}) =>
    Isolate.run(() => _prepare(path, windowsPaths ?? Platform.isWindows));

String _safePath(String name) {
  final n = name.endsWith('/') ? name.substring(0, name.length - 1) : name;
  if (n.isEmpty ||
      n.startsWith('/') ||
      n.contains('\\') ||
      n
          .split('/')
          .any(
            (c) =>
                c.isEmpty ||
                c == '.' ||
                c == '..' ||
                RegExp(r'[\x00-\x1f]').hasMatch(c) ||
                RegExp(r'^[A-Za-z]:').hasMatch(c),
          )) {
    throw FormatException('Chemin ZIP non pris en charge : $name');
  }
  return n;
}

// Compatibility is distinct from traversal protection. POSIX names may end
// with spaces/dots and must never be trimmed or silently renamed. On Windows,
// reject only the affected patient folder, leaving other patients importable.
void _checkPlatformPath(String name, bool windowsPaths) {
  if (!windowsPaths) return;
  if (name
      .split('/')
      .any(
        (component) =>
            RegExp(r'[<>:"|?*]').hasMatch(component) ||
            component.endsWith('.') ||
            component.endsWith(' ') ||
            RegExp(
              r'^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(?:\.|$)',
              caseSensitive: false,
            ).hasMatch(component),
      )) {
    throw FormatException(
      'Nom non pris en charge sous Windows, conservé sans modification dans le ZIP : $name',
    );
  }
}

Future<KobusPreparation> _prepare(String path, bool windowsPaths) async {
  final temporary = await Directory.systemTemp.createTemp('abak_kobus_');
  InputFileStream? input;
  try {
    input = InputFileStream(path);
    // ZipDecoder merges entries with identical names before callers can check
    // them. Read the central directory so every occurrence is verified.
    final directory = ZipDirectory()..read(input);
    if (directory.fileHeaders.length > 100000 ||
        directory.fileHeaders.fold<int>(0, (n, f) => n + f.uncompressedSize) >
            8 * 1024 * 1024 * 1024) {
      throw const FormatException(
        'Export trop volumineux (100 000 entrées / 8 Gio décompressés maximum).',
      );
    }
    final roots = <String>{};
    for (final header in directory.fileHeaders) {
      final name = _safePath(header.filename);
      final parts = name.split('/');
      final index = parts.indexWhere(_roots.contains);
      if (index >= 0 && index <= 1) roots.add(parts.take(index).join('/'));
    }
    if (roots.length != 1) {
      throw const FormatException(
        'Structure KOBUS absente ou plusieurs répertoires englobants ambigus.',
      );
    }
    final prefix = roots.single.isEmpty ? '' : '${roots.single}/';
    final grouped = <String, List<ArchiveFile>>{};
    final standalone = <String>{};
    final shared = <String, bool>{};
    final practitioners = <String, String>{};
    for (final header in directory.fileHeaders) {
      final name = _safePath(header.filename);
      final content = header.file!;
      if (_safePath(content.filename) != name) {
        throw FormatException('Noms ZIP local et central incohérents : $name');
      }
      final entry = header.filename.endsWith('/')
          ? ArchiveFile.directory(header.filename)
          : ArchiveFile.file(header.filename, header.uncompressedSize, content);
      entry.mode = header.externalFileAttributes >> 16;
      entry.crc32 = header.crc32;
      if (!name.startsWith(prefix)) continue;
      final parts = name.substring(prefix.length).split('/');
      if (!_roots.contains(parts.first)) continue;
      final isShared = parts.first != 'Mes patients';
      final depth = isShared ? 3 : 2;
      if (parts.length < depth) {
        if (entry.isFile) {
          throw FormatException(
            'Fichier inattendu dans la structure KOBUS : $name',
          );
        }
        continue;
      }
      if (parts.length == depth && entry.isFile) {
        // A patient without attachments may be exported as a standalone
        // identity workbook. Validate its contents rather than its filename.
        if (p.posix.extension(name).toLowerCase() != '.xlsx') {
          throw FormatException('Fiche patient Excel attendue : $name');
        }
        standalone.add(name);
      }
      final folder = '$prefix${parts.take(depth).join('/')}';
      grouped.putIfAbsent(folder, () => []).add(entry);
      shared[folder] = isShared;
      if (isShared) practitioners[folder] = parts[1];
    }
    if (grouped.isEmpty) {
      throw const FormatException('Aucun dossier patient dans cet export.');
    }
    final folders = <KobusFolder>[];
    final paths = grouped.keys.toList()..sort();
    for (final path in paths) {
      final id = const Uuid().v4();
      final folder = KobusFolder(
        id: id,
        sourcePath: path,
        shared: shared[path]!,
        practitioner: practitioners[path],
        directory: p.join(temporary.path, id),
        manifest: {},
      );
      folders.add(folder);
      try {
        _checkPlatformPath(p.posix.basename(path), windowsPaths);
        await Directory(folder.directory).create();
        final pathSpellings = <String, String>{};
        final pathTypes = <String, bool>{};
        final repeatedFiles = <String, int>{};
        for (final entry in grouped[path]!) {
          final name = _safePath(entry.name);
          final type = entry.mode & 0xf000;
          if (entry.isSymbolicLink ||
              (type != 0 && type != 0x8000 && type != 0x4000)) {
            throw FormatException(
              'Entrée non prise en charge (lien ou fichier spécial) : $name',
            );
          }
          final isStandalone = standalone.contains(path);
          if (isStandalone && (name != path || !entry.isFile)) {
            throw FormatException(
              'Collision entre fiche et dossier patient : $path',
            );
          }
          if (!isStandalone && name == path) continue;
          final relative = isStandalone
              ? p.posix.basename(name)
              : name.substring(path.length + 1);
          _checkPlatformPath(relative, windowsPaths);
          final components = relative.split('/');
          for (var i = 1; i <= components.length; i++) {
            final spelling = components.take(i).join('/');
            final key = spelling.toLowerCase();
            final isFile = i == components.length && entry.isFile;
            if (pathSpellings.containsKey(key) &&
                (pathSpellings[key] != spelling || pathTypes[key] != isFile)) {
              throw FormatException(
                'Chemins incompatibles dans ce dossier : '
                '${pathSpellings[key]} / $spelling',
              );
            }
            pathSpellings[key] = spelling;
            pathTypes[key] = isFile;
          }
          final destination = p.joinAll([
            folder.directory,
            ...relative.split('/'),
          ]);
          if (!p.isWithin(folder.directory, destination)) {
            throw const FormatException('Chemin hors destination.');
          }
          if (entry.size > 256 * 1024 * 1024) {
            throw FormatException('Fichier supérieur à 256 Mio : $relative');
          }
          if (entry.isFile) {
            final bytes = entry.content;
            if (bytes.length != entry.size || getCrc32(bytes) != entry.crc32) {
              throw FormatException('Fichier corrompu : $relative');
            }
            final digest = sha256.convert(bytes).toString();
            if (folder.manifest.containsKey(relative)) {
              if (folder.manifest[relative] != digest) {
                throw FormatException(
                  'Entrées ZIP de contenus différents pour le même chemin : $relative',
                );
              }
              repeatedFiles.update(
                relative,
                (count) => count + 1,
                ifAbsent: () => 1,
              );
              entry.clear();
              continue;
            }
            if (await FileSystemEntity.type(destination, followLinks: false) !=
                FileSystemEntityType.notFound) {
              throw FormatException('Collision de noms : $relative');
            }
            await File(destination).parent.create(recursive: true);
            await File(destination).writeAsBytes(bytes, flush: true);
            folder.manifest[relative] = digest;
            entry.clear();
          } else {
            await Directory(destination).create(recursive: true);
            folder.manifest['$relative/'] = 'directory';
          }
        }
        // Include implicit and empty directories in the verified inventory.
        for (final entity in Directory(
          folder.directory,
        ).listSync(recursive: true, followLinks: false)) {
          if (entity is Directory) {
            folder.manifest['${p.relative(entity.path, from: folder.directory).split(p.separator).join('/')}/'] =
                'directory';
          }
        }
        final excel = Directory(folder.directory)
            .listSync()
            .whereType<File>()
            .where((f) => p.extension(f.path).toLowerCase() == '.xlsx')
            .toList();
        if (excel.length != 1) {
          throw FormatException(
            excel.isEmpty
                ? 'Fiche Excel .xlsx absente à la racine du dossier patient.'
                : 'Plusieurs fiches Excel à la racine : identité ambiguë.',
          );
        }
        final fields = KobusExcel.fields(await excel.single.readAsBytes());
        folder.readableIdentity = [
          'Nom de famille',
          'Prénom',
          'Date de naissance',
        ].map((k) => fields[k] ?? '').join(' ').trim();
        folder.identity = KobusExcel.identity(fields);
        if (folder.manifest.keys.where((name) => !name.endsWith('/')).length ==
            1) {
          folder.identity!.warnings.add('Aucun document joint');
        }
        for (final repetition in repeatedFiles.entries) {
          folder.identity!.warnings.add(
            'Entrée ZIP répétée à contenu identique : '
            '${repetition.key} (${repetition.value + 1} occurrences vérifiées, un fichier conservé).',
          );
        }
      } catch (error) {
        folder.rejection = error is FormatException
            ? error.message
            : 'Dossier ou classeur illisible : $error';
        folder.decision = KobusDecision.skip;
        if (await Directory(folder.directory).exists()) {
          await Directory(folder.directory).delete(recursive: true);
        }
      }
    }
    return KobusPreparation(p.basename(path), temporary.path, folders);
  } catch (_) {
    await temporary.delete(recursive: true);
    rethrow;
  } finally {
    await input?.close();
  }
}

Future<void> findKobusCandidates(
  KobusPreparation preparation,
  bool includeShared, {
  List<Patient>? existing,
}) async {
  final repository = PatientRepository();
  final patients =
      existing ??
      [
        ...await repository.getAllPatients(),
        ...await repository.getArchivedPatients(),
      ];
  final previous = <KobusFolder>[];
  for (final folder in preparation.folders) {
    folder.candidates.clear();
    folder.target = null;
    folder.duplicateReason = null;
    if (folder.identity == null || (folder.shared && !includeShared)) continue;
    for (final patient in patients) {
      final reason = kobusMatch(folder.identity!, patient);
      if (reason != null) {
        folder.candidates.add(KobusCandidate(patient, reason));
        folder.duplicateReason = reason;
      }
    }
    for (final other in previous) {
      final patient = other.identity!.patient(other.id);
      final reason = kobusMatch(folder.identity!, patient);
      if (reason != null) {
        folder.candidates.add(
          KobusCandidate(
            patient,
            reason,
            sourceItemId: other.id,
            sourcePath: other.sourcePath,
          ),
        );
      }
    }
    folder.decision = folder.candidates.isEmpty
        ? KobusDecision.create
        : KobusDecision.unresolved;
    previous.add(folder);
  }
}

Future<void> disposeKobus(KobusPreparation preparation) async {
  final directory = Directory(preparation.temporaryPath);
  if (await directory.exists()) await directory.delete(recursive: true);
}

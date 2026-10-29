import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:printing/printing.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database_service.dart';
import '../models/episode_document_version.dart';
import 'pdf_conversion_evidence.dart';

typedef DocumentDatabase = Future<Database> Function();
typedef DocumentRoot = Future<Directory> Function();

class FinalPdfException implements Exception {
  const FinalPdfException(this.message);
  final String message;
  @override
  String toString() => message;
}

abstract interface class FinalPdfInspector {
  Future<int> inspect(Uint8List bytes);
}

/// Uses the already bundled printing plugin, without URLs or developer tool paths.
/// Rendering establishes readability, not PDF/A or medical content conformity.
class PrintingFinalPdfInspector implements FinalPdfInspector {
  @override
  Future<int> inspect(Uint8List bytes) async {
    var pages = 0;
    try {
      await for (final page in Printing.raster(
        bytes,
        dpi: 36,
      ).timeout(const Duration(seconds: 30))) {
        if (++pages > 40 || page.width < 1 || page.height < 1) {
          throw const FinalPdfException('PDF limité à 40 pages lisibles.');
        }
      }
    } catch (_) {
      throw const FinalPdfException(
        'Lecture du PDF impossible : fichier endommagé, protégé ou lecteur indisponible.',
      );
    }
    if (pages == 0) {
      throw const FinalPdfException('Le PDF ne contient aucune page lisible.');
    }
    return pages;
  }
}

class PdfOrigin {
  const PdfOrigin(this.kind, {this.id, this.label});
  final String kind;
  final String? id, label;
}

/// Historical conversion evidence, independent of medical approval and of the
/// later PDF/CDA controls. Reading it never launches a converter or validator.
class PdfConversionStatus {
  const PdfConversionStatus(this.message, {this.convertedAt});
  final String message;
  final int? convertedAt;
}

class FinalPdfDocumentService {
  FinalPdfDocumentService({
    DocumentDatabase? database,
    DocumentRoot? root,
    FinalPdfInspector? inspector,
    this.checkpoint,
  }) : database = database ?? (() => DatabaseService.database),
       root = root ?? defaultRoot,
       inspector = inspector ?? PrintingFinalPdfInspector();
  final DocumentDatabase database;
  final DocumentRoot root;
  final FinalPdfInspector inspector;
  // Fault/race injection at storage boundaries; absent in the product.
  final Future<void> Function(String)? checkpoint;
  static const limit = 20 * 1024 * 1024;
  static final Set<String> _busyRoots = {};
  static Future<Directory> defaultRoot() async => Directory(
    p.join(
      (await getApplicationSupportDirectory()).path,
      'episode_document_versions',
    ),
  );
  static String hash(List<int> bytes) => sha256.convert(bytes).toString();
  static void fail(String text) => throw FinalPdfException(text);

  Future<Directory> _root() async {
    final dir = await root();
    await _noLinks(dir.path);
    await dir.create(recursive: true);
    return dir;
  }

  static Future<void> _noLinks(String path) async {
    var current = p.absolute(path);
    while (true) {
      if (await FileSystemEntity.type(current, followLinks: false) ==
          FileSystemEntityType.link) {
        fail('Lien symbolique non autorisé pour une copie figée.');
      }
      final parent = p.dirname(current);
      if (parent == current) break;
      current = parent;
    }
  }

  Future<T> _exclusive<T>(Future<T> Function(Directory) action) async {
    final dir = await _root();
    final name = p.absolute(dir.path);
    if (!_busyRoots.add(name)) fail('Un import PDF est déjà en cours.');
    RandomAccessFile? lock;
    try {
      await _noLinks(p.join(name, 'import.lock'));
      lock = await File(
        p.join(name, 'import.lock'),
      ).open(mode: FileMode.append);
      await lock.lock(FileLock.exclusive);
      return await action(dir);
    } on FileSystemException {
      throw const FinalPdfException(
        'Stockage PDF indisponible ou utilisé par un autre import.',
      );
    } finally {
      await lock?.close();
      _busyRoots.remove(name);
    }
  }

  Future<Uint8List> _read(File file) async {
    await _noLinks(file.path);
    if (await FileSystemEntity.type(file.path, followLinks: false) !=
        FileSystemEntityType.file) {
      fail('Fichier PDF introuvable.');
    }
    final before = await file.stat();
    if (before.size == 0 || before.size > limit) {
      fail('Le PDF doit être non vide et ne pas dépasser 20 Mio.');
    }
    final f = await file.open();
    late Uint8List bytes;
    try {
      bytes = await f.read(limit + 1);
    } finally {
      await f.close();
    }
    final after = await file.stat();
    if (bytes.length != before.size ||
        bytes.length > limit ||
        before.modified != after.modified ||
        before.changed != after.changed) {
      fail('Fichier modifié pendant la copie.');
    }
    return bytes;
  }

  Future<Map<String, Object?>> _context(
    DatabaseExecutor db,
    String episode,
    String? document,
    PdfOrigin origin,
  ) async {
    final e = await db.query(
      'care_episodes',
      where: 'care_episode_id = ?',
      whereArgs: [episode],
    );
    if (e.length != 1 || e.single['archived_at'] != null) {
      fail('Épisode absent ou archivé.');
    }
    final patient = await db.query(
      'patients',
      where: 'patient_id = ?',
      whereArgs: [e.single['patient_id']],
    );
    if (patient.length != 1 || patient.single['archived_at'] != null) {
      fail('Patient absent ou archivé.');
    }
    Map<String, Object?>? piece;
    if (document != null) {
      final rows = await db.query(
        'episode_documents',
        where: 'document_id = ?',
        whereArgs: [document],
      );
      if (rows.length != 1 ||
          rows.single['case_id'] != episode ||
          rows.single['archived_at'] != null) {
        fail('Pièce absente, archivée ou rattachée à un autre épisode.');
      }
      piece = rows.single;
    }
    Map<String, Object?>? source;
    if (origin.kind == 'report' || origin.kind == 'assessment') {
      final table = origin.kind == 'report'
          ? 'care_episode_reports'
          : 'care_episode_assessments';
      final id = origin.kind == 'report' ? 'report_id' : 'assessment_id';
      final rows = await db.query(
        table,
        where: '$id = ?',
        whereArgs: [origin.id],
      );
      if (rows.length != 1 ||
          rows.single['care_episode_id'] != episode ||
          rows.single['archived_at'] != null) {
        fail('Origine clinique absente ou rattachée à un autre épisode.');
      }
      source = rows.single;
    } else if (origin.kind == 'legacy_piece') {
      if (document == null || origin.id != document) {
        fail('Pièce d’origine incohérente.');
      }
      source = piece;
    } else if (origin.kind != 'external' || origin.id != null) {
      fail('Origine du PDF non reconnue.');
    }
    final versions = document == null
        ? <Map<String, Object?>>[]
        : await db.query(
            'episode_document_versions',
            where: 'document_id = ?',
            whereArgs: [document],
            orderBy: 'sequence_number DESC',
            limit: 1,
          );
    return {
      'patient': e.single['patient_id'],
      'episode': e.single,
      'piece': piece,
      'source': source,
      'previous': versions.isEmpty ? null : versions.single,
    };
  }

  // Keep conversions from a clinical history in the existing PDF lineage,
  // including its journal and any previous deposit attempt.
  Future<String?> _documentForOrigin(
    DatabaseExecutor db,
    String episode,
    PdfOrigin origin,
  ) async {
    if (!['assessment', 'report'].contains(origin.kind) || origin.id == null) {
      fail('Origine clinique requise.');
    }
    final links = await db.rawQuery(
      'SELECT DISTINCT document_id FROM episode_document_versions '
      'WHERE episode_id = ? AND source_kind = ? AND source_id = ?',
      [episode, origin.kind, origin.id],
    );
    if (links.isEmpty) return null;
    if (links.length != 1) {
      fail(
        'Plusieurs pièces PDF sont liées à ce document. '
        'Consultez leurs versions dans les documents de la prise en charge.',
      );
    }
    final id = links.single['document_id'] as String;
    final context = await _context(db, episode, id, origin);
    final latest = context['previous'] as Map<String, Object?>?;
    if (latest == null ||
        latest['source_kind'] != origin.kind ||
        latest['source_id'] != origin.id) {
      fail('Le rattachement du PDF a changé. Consultez la pièce existante.');
    }
    return id;
  }

  Future<EpisodeDocumentVersion?> latestForOrigin(
    String episode,
    PdfOrigin origin,
  ) async {
    final db = await database();
    return db.transaction((txn) async {
      final id = await _documentForOrigin(txn, episode, origin);
      if (id == null) return null;
      final context = await _context(txn, episode, id, origin);
      return EpisodeDocumentVersion(
        Map.unmodifiable(context['previous'] as Map<String, Object?>),
      );
    });
  }

  Future<List<PdfOrigin>> origins(String episode) async {
    final db = await database();
    await _context(db, episode, null, const PdfOrigin('external'));
    final result = <PdfOrigin>[
      const PdfOrigin('external', label: 'PDF externe'),
    ];
    for (final kind in ['report', 'assessment']) {
      final table = kind == 'report'
          ? 'care_episode_reports'
          : 'care_episode_assessments';
      final id = kind == 'report' ? 'report_id' : 'assessment_id';
      final rows = await db.query(
        table,
        where: 'care_episode_id = ? AND archived_at IS NULL',
        whereArgs: [episode],
      );
      for (final row in rows) {
        result.add(
          PdfOrigin(
            kind,
            id: row[id] as String,
            label:
                '${kind == 'report' ? 'Rapport' : 'Bilan'} : ${row['title'] ?? row[id]}',
          ),
        );
      }
    }
    return result;
  }

  Future<EpisodeDocumentVersion> importPdf({
    required String episodeId,
    required String sourcePath,
    required String title,
    String? documentId,
    PdfOrigin origin = const PdfOrigin('external'),
    PdfConversionEvidence? conversion,
    bool reuseOriginDocument = false,
    String? expectedSourceRevision,
  }) async => _exclusive((dir) async {
    if (title.trim().isEmpty) fail('Un titre est nécessaire.');
    final db = await database();
    var targetDocumentId = documentId;
    final before = await db.transaction((txn) async {
      if (reuseOriginDocument) {
        if (documentId != null) fail('Sélection de pièce ambiguë.');
        targetDocumentId = await _documentForOrigin(txn, episodeId, origin);
      }
      return _context(txn, episodeId, targetDocumentId, origin);
    });
    if (expectedSourceRevision != null &&
        hash(utf8.encode(jsonEncode(before['source']))) !=
            expectedSourceRevision) {
      fail('Le bilan ou le rapport a changé. Rechargez-le avant conversion.');
    }
    final bytes = await _read(File(sourcePath));
    if (!latin1.decode(bytes.take(8).toList()).startsWith('%PDF-') ||
        !latin1
            .decode(
              bytes
                  .skip(bytes.length > 1024 ? bytes.length - 1024 : 0)
                  .toList(),
            )
            .trimRight()
            .endsWith('%%EOF')) {
      fail('Le fichier sélectionné n’est pas un PDF complet.');
    }
    final versionId = const Uuid().v4();
    final pending = Directory(p.join(dir.path, '.pending-$versionId'));
    final finalDir = Directory(p.join(dir.path, 'version-$versionId'));
    final relative = p.join('version-$versionId', 'document.pdf');
    await pending.create();
    try {
      final conversionHash = await conversion?.write(pending, bytes);
      await File(
        p.join(pending.path, 'document.pdf'),
      ).writeAsBytes(bytes, flush: true);
      final pages = await inspector.inspect(bytes);
      if (pages < 1 || pages > 40) fail('PDF limité à 40 pages lisibles.');
      await checkpoint?.call('inspected');
      if (hash(await _read(File(sourcePath))) != hash(bytes)) {
        fail('Le PDF source a changé pendant l’import.');
      }
      await pending.rename(finalDir.path);
      await checkpoint?.call('copied');
      final version = await db.transaction((txn) async {
        if (reuseOriginDocument &&
            await _documentForOrigin(txn, episodeId, origin) !=
                targetDocumentId) {
          fail('Le rattachement du PDF a changé pendant la conversion.');
        }
        final current = await _context(
          txn,
          episodeId,
          targetDocumentId,
          origin,
        );
        if (jsonEncode(before) != jsonEncode(current)) {
          fail(
            'Le dossier ou la pièce a changé pendant l’import. Recommencez la sélection.',
          );
        }
        final previous = before['previous'] as Map<String, Object?>?;
        final id = targetDocumentId ?? const Uuid().v4();
        final now = DateTime.now().millisecondsSinceEpoch;
        final row = <String, Object?>{
          'version_id': versionId,
          'document_id': id,
          'patient_id': before['patient'],
          'episode_id': episodeId,
          'sequence_number': (previous?['sequence_number'] as int? ?? 0) + 1,
          'previous_version_id': previous?['version_id'],
          'relative_path': relative,
          'sha256': hash(bytes),
          'byte_size': bytes.length,
          'mime_type': 'application/pdf',
          'page_count': pages,
          'source_kind': origin.kind,
          'source_id': origin.id,
          'source_revision': before['source'] == null
              ? null
              : hash(utf8.encode(jsonEncode(before['source']))),
          'captured_at': now,
        };
        if (targetDocumentId == null) {
          await txn.insert('episode_documents', {
            'document_id': id,
            'case_id': episodeId,
            'title': title.trim(),
            'file_path': p.join(dir.path, relative),
            'mime_type': 'application/pdf',
            'source': 'final_pdf',
            'created_at': now,
          });
        } else {
          await txn.update(
            'episode_documents',
            {
              'file_path': p.join(dir.path, relative),
              'mime_type': 'application/pdf',
              'source': 'final_pdf',
              'updated_at': now,
            },
            where: 'document_id = ?',
            whereArgs: [id],
          );
        }
        await checkpoint?.call('beforeCommit');
        await txn.insert('episode_document_versions', row);
        if (conversionHash != null) {
          await txn.insert('document_events', {
            'document_id': id,
            'version_id': versionId,
            'kind': 'docx_converted',
            'reference_id': conversionHash,
            'detail':
                'DOCX converti en PDF/A-1b ; conformité technique vérifiée. Revue et validation médicale requises.',
            'created_at': now,
          });
        }
        return EpisodeDocumentVersion(Map.unmodifiable(row));
      });
      return version;
    } catch (_) {
      // Never delete a possibly committed copy if the commit outcome cannot be read.
      try {
        final rows = await db.query(
          'episode_document_versions',
          where: 'version_id = ?',
          whereArgs: [versionId],
        );
        if (rows.isEmpty && await finalDir.exists()) {
          await finalDir.delete(recursive: true);
        }
      } catch (_) {
        /* Leave an orphan for explicit recovery, not an approved version. */
      }
      rethrow;
    } finally {
      if (await pending.exists()) await pending.delete(recursive: true);
    }
  });
  Future<List<EpisodeDocumentVersion>> versions(String documentId) async {
    final db = await database();
    return (await db.query(
      'episode_document_versions',
      where: 'document_id = ?',
      whereArgs: [documentId],
      orderBy: 'sequence_number DESC',
    )).map((row) => EpisodeDocumentVersion(Map.unmodifiable(row))).toList();
  }

  Future<File> verifiedFile(EpisodeDocumentVersion version) async {
    final db = await database();
    final rows = await db.query(
      'episode_document_versions',
      where: 'version_id = ?',
      whereArgs: [version.id],
    );
    if (rows.length != 1 ||
        (rows.single.length != version.values.length ||
            rows.single.entries.any((e) => version.values[e.key] != e.value))) {
      fail('Version PDF non reconnue.');
    }
    final context = await _context(
      db,
      version.values['episode_id'] as String,
      version.documentId,
      const PdfOrigin('external'),
    );
    if (context['patient'] != version.values['patient_id']) {
      fail('Rattachement patient modifié : ouverture bloquée.');
    }
    await verifyConversionEvidence(db, version);
    return verifyStoredBytes(version);
  }

  Future<PdfConversionStatus> conversionStatus(
    EpisodeDocumentVersion version,
  ) async {
    try {
      // A journal label alone cannot establish conformity: verify the retained
      // PDF, its attachment and the conversion manifest/files before displaying
      // the successful conversion recorded for this exact version.
      await verifiedFile(version);
      final db = await database();
      final table = await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='document_events'",
      );
      final events = table.isEmpty
          ? <Map<String, Object?>>[]
          : await db.query(
              'document_events',
              where: 'version_id=? AND document_id=? AND kind=?',
              whereArgs: [version.id, version.documentId, 'docx_converted'],
            );
      if (events.length != 1) {
        return const PdfConversionStatus(
          'Aucune preuve de conversion DOCX en PDF/A conservée pour cette version. Cela ne signifie pas que le PDF est non conforme.',
        );
      }
      return PdfConversionStatus(
        'PDF/A-1b conforme à la conversion. La preuve conservée correspond à cette version du PDF.',
        convertedAt: events.single['created_at'] as int,
      );
    } catch (e) {
      return PdfConversionStatus(
        'Conformité à la conversion non vérifiable : $e',
      );
    }
  }

  Future<void> verifyConversionEvidence(
    DatabaseExecutor db,
    EpisodeDocumentVersion version,
  ) async {
    if (!RegExp(
      r'^version-[a-f0-9-]{36}/document\.pdf$',
    ).hasMatch(version.relativePath)) {
      fail('Chemin de version invalide.');
    }
    final directory = Directory(
      p.dirname(p.join((await _root()).path, version.relativePath)),
    );
    await _noLinks(directory.path);
    await PdfConversionEvidence.verify(
      db,
      version.id,
      directory,
      version.digest,
    );
  }

  /// File-only check for callers holding an existing database transaction.
  /// The caller must verify the stored version and current attachment in that transaction.
  Future<File> verifyStoredBytes(EpisodeDocumentVersion version) async {
    final dir = await _root();
    if (!RegExp(
      r'^version-[a-f0-9-]{36}/document\.pdf$',
    ).hasMatch(p.posix.joinAll(p.split(version.relativePath)))) {
      fail('Chemin de version invalide.');
    }
    final file = File(p.join(dir.path, version.relativePath));
    final bytes = await _read(file);
    if (bytes.length != version.size || hash(bytes) != version.digest) {
      fail('Copie PDF absente ou modifiée : ouverture bloquée.');
    }
    return file;
  }

  /// External viewers receive a disposable copy, never the retained version.
  Future<File> previewFile(EpisodeDocumentVersion version) async {
    final retained = await verifiedFile(version);
    final bytes = await _read(retained);
    if (hash(bytes) != version.digest) {
      fail('Copie PDF modifiée : ouverture bloquée.');
    }
    final dir = await _root();
    final previews = Directory(p.join(dir.path, 'previews'));
    await _noLinks(previews.path);
    await previews.create();
    // Unique name prevents a viewer from holding an obsolete or edited copy.
    final file = File(p.join(previews.path, '${const Uuid().v4()}.pdf'));
    await file.writeAsBytes(bytes, flush: true);
    return file;
  }

  /// Explicit recovery after interruption: serialized with imports, retains all referenced files.
  Future<int> recoverOrphans() async => _exclusive((dir) async {
    final db = await database();
    final referenced = (await db.query(
      'episode_document_versions',
      columns: ['relative_path'],
    )).map((r) => p.dirname(r['relative_path'] as String)).toSet();
    var count = 0;
    await for (final entry in dir.list(followLinks: false)) {
      final name = p.basename(entry.path);
      if (entry is Directory &&
          RegExp(r'^(version-|\.pending-)[a-f0-9-]{36}$').hasMatch(name) &&
          !referenced.contains(name)) {
        await _noLinks(entry.path);
        final quarantine = Directory(p.join(dir.path, 'quarantine'));
        await _noLinks(quarantine.path);
        await quarantine.create();
        await entry.rename(
          p.join(quarantine.path, '${const Uuid().v4()}-$name'),
        );
        count++;
      }
    }
    return count;
  });
}

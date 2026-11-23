import 'dart:convert';
import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../../core/database/database_service.dart';
import '../../maintenance/services/backup_directory_access.dart';
import '../../maintenance/services/companion_backup_archive.dart';
import '../../patients/services/document_native_controls.dart';

typedef DepartureData = Map<String, Map<String, List<Map<String, Object?>>>>;

class DepartureExportReceipt {
  DepartureExportReceipt(this.path, this._verify);
  final String path;
  final Future<void> Function(Transaction) _verify;
  Future<void> verifyDatabase(Transaction txn) => _verify(txn);
}

/// Portable clinical dossiers, deliberately distinct from a restorable backup.
/// Only explicitly patient-owned tables are exported; no global credentials.
class PractitionerDepartureExportService {
  PractitionerDepartureExportService({
    Future<Database> Function()? database,
    BackupDirectoryAccess? access,
    Future<Directory> Function()? support,
  }) : database = database ?? (() => DatabaseService.database),
       access = access ?? const BackupDirectoryAccess(),
       support = support ?? getApplicationSupportDirectory;
  final Future<Database> Function() database;
  final BackupDirectoryAccess access;
  final Future<Directory> Function() support;

  Future<DepartureData> _capture(
    DatabaseExecutor db,
    String source,
    Set<String> ids,
  ) async {
    final result = <String, Map<String, List<Map<String, Object?>>>>{};
    for (final id in ids.toList()..sort()) {
      final data = <String, List<Map<String, Object?>>>{};
      Future<void> take(
        String table,
        String where, [
        List<Object?>? args,
      ]) async {
        data[table] = await db.query(
          table,
          where: where,
          whereArgs: args ?? [id],
          orderBy: 'rowid',
        );
      }

      await take('patients', 'patient_id=?');
      await take(
        'companion_patient_access',
        'patient_id=? AND referring_practitioner_id=?',
        [id, source],
      );
      if (data['patients']!.length != 1 ||
          data['companion_patient_access']!.length != 1) {
        throw StateError('La sélection des patients a changé. Rechargez-la.');
      }
      for (final table in [
        'patient_identity',
        'patient_attributes',
        'patient_fr_health_identity',
        'patient_vitale_readings',
        'patient_identity_events',
        'patient_document_folders',
        'kobus_archives',
      ]) {
        await take(table, 'patient_id=?');
      }
      const episodes =
          'SELECT care_episode_id FROM care_episodes WHERE patient_id=?';
      await take('care_episodes', 'patient_id=?');
      await take(
        'external_correspondents',
        'correspondent_id IN (SELECT prescribing_correspondent_id FROM care_episodes WHERE patient_id=?)',
      );
      for (final table in [
        'desktop_results',
        'care_episode_assessments',
        'care_episode_reports',
        'care_episode_notes',
        'care_episode_referring_practitioners',
        'care_episode_bodymaps',
        'assessment_template_drafts',
      ]) {
        await take(table, 'care_episode_id IN ($episodes)');
      }
      for (final row in data['desktop_results']!) {
        if (row['patient_id'] != null && row['patient_id'] != id) {
          throw StateError(
            'Résultat associé à deux patients différents. Export interrompu.',
          );
        }
      }
      await take(
        'desktop_result_metrics',
        'result_id IN (SELECT result_id FROM desktop_results WHERE care_episode_id IN ($episodes))',
      );
      for (final kind in ['assessment', 'report']) {
        final documents =
            'SELECT ${kind}_id FROM care_episode_${kind}s WHERE care_episode_id IN ($episodes)';
        for (final suffix in ['tests', 'notes']) {
          await take(
            'care_episode_${kind}_$suffix',
            '${kind}_id IN ($documents)',
          );
        }
      }
      await take(
        'care_episode_document_edit_drafts',
        "(document_type='report' AND document_id IN (SELECT report_id FROM care_episode_reports WHERE care_episode_id IN ($episodes))) OR (document_type='assessment' AND document_id IN (SELECT assessment_id FROM care_episode_assessments WHERE care_episode_id IN ($episodes)))",
        [id, id],
      );
      await take('episode_documents', 'case_id IN ($episodes)');
      await take('episode_document_versions', 'patient_id=?');
      final episodeIds = data['care_episodes']!
          .map((r) => r['care_episode_id'])
          .toSet();
      if (data['episode_document_versions']!.any(
        (r) => !episodeIds.contains(r['episode_id']),
      )) {
        throw StateError(
          'Copie PDF associée à un autre dossier. Export interrompu.',
        );
      }
      final people = <String>{source};
      for (final rows in data.values) {
        for (final row in rows) {
          for (final field in [
            'practitioner_id',
            'author_practitioner_id',
            'referring_practitioner_id',
            'former_practitioner_id',
          ]) {
            if (row[field] is String) people.add(row[field] as String);
          }
        }
      }
      data['practitioner_names'] = [];
      for (final person in people.toList()..sort()) {
        data['practitioner_names']!.addAll(
          await db.query(
            'practitioners',
            columns: ['practitioner_id', 'display_name'],
            where: 'practitioner_id=?',
            whereArgs: [person],
          ),
        );
      }
      result[id] = data;
    }
    return result;
  }

  Future<DepartureExportReceipt?> export(
    String source,
    Set<String> selected,
  ) => BackupOperation.run(() async {
    if (selected.isEmpty) {
      throw StateError('Sélectionnez au moins un patient à exporter.');
    }
    final ids = Set<String>.of(selected);
    final destination = await access.choose(
      'Exporter les dossiers des patients sélectionnés',
    );
    if (destination == null) return null;
    Directory? staging;
    String? partial;
    final leases = <BackupDirectoryLease>[];
    try {
      final db = await database();
      final snapshot = await db.transaction(
        (txn) => _capture(txn, source, ids),
      );
      final fingerprint = jsonEncode(snapshot);
      final base = await support();
      staging = await Directory.systemTemp.createTemp('abak_departure_');
      var index = 0;
      for (final entry in snapshot.entries) {
        final data = entry.value;
        final dir = Directory(p.join(staging.path, 'Patient_${++index}'));
        await dir.create();
        await File(
          p.join(dir.path, 'Dossier.json'),
        ).writeAsString(const JsonEncoder.withIndent('  ').convert(data));
        final locations = <String, String>{};
        var folderIndex = 0;
        for (final row in data['patient_document_folders']!) {
          final name = row['folder_name'] as String;
          CompanionBackupArchive.validatePath(name);
          if (name != p.basename(name)) {
            throw StateError('Dossier patient invalide.');
          }
          final lease = await access.read(row['root_path'] as String);
          leases.add(lease);
          final root = p.join(lease.path, name);
          await LocalDocumentControlRunner.regular(root, directory: true);
          final relative = 'Documents_${++folderIndex}';
          await CompanionBackupArchive.copyTree(
            Directory(root),
            Directory(p.join(dir.path, relative)),
          );
          locations[root] = relative;
        }
        Future<void> copyFile(String path, {String? expectedHash}) async {
          final absolute = p.normalize(path);
          if (!p.isAbsolute(absolute)) {
            throw StateError('Chemin de document invalide : $path');
          }
          await LocalDocumentControlRunner.regular(absolute);
          for (final root in locations.keys.toList()) {
            if (p.isWithin(root, absolute)) {
              return; // Already copied with the patient tree.
            }
          }
          final legacy = p.join(base.path, 'episode_documents');
          final versions = p.join(base.path, 'episode_document_versions');
          final allowed =
              p.isWithin(versions, absolute) ||
              data['care_episodes']!.any(
                (e) => p.isWithin(
                  p.join(legacy, e['care_episode_id'] as String),
                  absolute,
                ),
              );
          if (!allowed) {
            throw StateError(
              'Document hors des répertoires du patient : $path. Déplacez-le dans son dossier avant l’export.',
            );
          }
          final relative = p.join(
            'Pieces',
            '${locations.length}_${p.basename(absolute)}',
          );
          final target = File(p.join(dir.path, relative));
          await target.parent.create(recursive: true);
          final before = await File(absolute).stat();
          await File(absolute).copy(target.path);
          final after = await File(absolute).stat();
          final hash = await CompanionBackupArchive.digest(target);
          if (before.size != after.size ||
              before.modified != after.modified ||
              hash != await CompanionBackupArchive.digest(File(absolute)) ||
              expectedHash != null && hash != expectedHash) {
            throw StateError(
              'Document modifié ou altéré pendant l’export : $path',
            );
          }
          locations[absolute] = relative;
        }

        for (final kind in ['assessment', 'report']) {
          for (final row in data['care_episode_${kind}s']!) {
            final name = row['docx_file_name'] as String?;
            if (name == null || name.isEmpty) continue;
            CompanionBackupArchive.validatePath(name);
            if (name != p.basename(name)) {
              throw StateError('Nom de document invalide.');
            }
            final subfolder = kind == 'assessment' ? 'Bilan' : 'Rapport';
            var found = false;
            for (final root in locations.keys) {
              final candidate = File(p.join(root, subfolder, name));
              if (await candidate.exists()) {
                found = true;
                break;
              }
            }
            if (!found) {
              throw StateError(
                'Document généré introuvable : $name. Export interrompu.',
              );
            }
          }
        }
        for (final row in data['episode_documents']!) {
          await copyFile(row['file_path'] as String);
        }
        for (final row in data['episode_document_versions']!) {
          final relative = row['relative_path'] as String;
          CompanionBackupArchive.validatePath(relative);
          await copyFile(
            p.join(base.path, 'episode_document_versions', relative),
            expectedHash: row['sha256'] as String,
          );
        }
        for (final row in data['care_episodes']!) {
          final path = row['initial_report_docx_path'] as String?;
          if (path != null && path.isNotEmpty) await copyFile(path);
        }
        for (final row in data['kobus_archives']!) {
          final path = row['storage_path'] as String;
          CompanionBackupArchive.validatePath(entry.key);
          if (!p.isWithin(
            p.join(base.path, 'kobus_archives', entry.key),
            path,
          )) {
            throw StateError('Chemin KOBUS invalide.');
          }
          await LocalDocumentControlRunner.regular(path, directory: true);
          final relative = 'Kobus_${locations.length}';
          await CompanionBackupArchive.copyTree(
            Directory(path),
            Directory(p.join(dir.path, relative)),
          );
          locations[path] = relative;
        }
        await File(
          p.join(dir.path, 'Emplacements.json'),
        ).writeAsString(const JsonEncoder.withIndent('  ').convert(locations));
      }
      await File(p.join(staging.path, 'Lisez-moi.txt')).writeAsString(
        'Export des dossiers sélectionnés : données cliniques JSON et documents disponibles dans leurs répertoires enregistrés, pièces jointes et copies PDF figées.\nCet export contient des données de santé en clair. Conservez-le dans un endroit protégé.\nIl ne constitue pas une sauvegarde restaurable dans Companion : les réglages, codes, clés et preuves techniques des échanges DMP ne sont pas exportés.\nLes identifiants des rédacteurs historiques sont conservés. Emplacements.json associe les chemins d’origine aux copies exportées.\n',
      );
      final manifest = <String, String>{};
      await for (final file in staging.list(recursive: true)) {
        if (file is File) {
          manifest[p
              .relative(file.path, from: staging.path)
              .replaceAll('\\', '/')] = await CompanionBackupArchive.digest(
            file,
          );
        }
      }
      await File(
        p.join(staging.path, 'Integrite.json'),
      ).writeAsString(jsonEncode(manifest));
      final output = p.join(
        destination.path,
        'ABAK_Depart_${DateTime.now().microsecondsSinceEpoch}.zip',
      );
      partial = '$output.partial';
      final encoder = ZipFileEncoder()..create(partial);
      try {
        await encoder.addDirectory(staging, includeDirName: false);
      } finally {
        encoder.close();
      }
      // archive 4.x does not implement verify:true CRC checking. Read back
      // every entry and compare it with the staged SHA-256 manifest instead.
      final input = InputFileStream(partial);
      try {
        final archive = ZipDecoder().decodeStream(input);
        final expected = {
          ...manifest,
          'Integrite.json': await CompanionBackupArchive.digest(
            File(p.join(staging.path, 'Integrite.json')),
          ),
        };
        final seen = <String>{};
        final check = File(p.join(staging.path, '_zip_check'));
        for (final entry in archive) {
          if (!entry.isFile) continue;
          if (!seen.add(entry.name) || !expected.containsKey(entry.name)) {
            throw StateError('Archive exportée incohérente.');
          }
          final output = OutputFileStream(check.path);
          try {
            entry.writeContent(output);
          } finally {
            output.close();
          }
          if (await CompanionBackupArchive.digest(check) !=
              expected[entry.name]) {
            throw StateError('Vérification de l’export échouée.');
          }
        }
        if (seen.length != expected.length) {
          throw StateError('Archive exportée incomplète.');
        }
      } finally {
        input.close();
      }
      await File(partial).rename(output);
      partial = null;
      return DepartureExportReceipt(output, (txn) async {
        if (jsonEncode(await _capture(txn, source, ids)) != fingerprint) {
          throw StateError(
            'Les dossiers ont changé pendant l’export. L’archive est conservée ; recommencez avant d’archiver le kiné.',
          );
        }
      });
    } finally {
      if (partial != null && await File(partial).exists()) {
        await File(partial).delete();
      }
      if (staging != null) await staging.delete(recursive: true);
      // Release errors must not turn an already published archive into a failed export.
      for (final lease in [...leases, destination]) {
        try {
          await lease.release();
        } catch (_) {
          /* Access will end with the process. */
        }
      }
    }
  });
}

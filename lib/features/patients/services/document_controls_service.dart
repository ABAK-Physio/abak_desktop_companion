import 'dmp_chain/native/dv1_retry.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import '../models/episode_document_version.dart';
import 'document_cda_builder.dart';
import 'document_medical_service.dart';
import 'document_native_controls.dart';
import 'final_pdf_document_service.dart';

class DocumentControlStatus {
  const DocumentControlStatus(
    this.pdfa,
    this.cda,
    this.message, {
    this.run,
    this.result,
  });
  final String pdfa, cda, message;
  final MedicalRow? run;
  final Map? result;
  static String label(String s) =>
      const {
        'conforme': 'conforme',
        'refuse': 'refusé',
        'non_verifie': 'non vérifié',
        'running': 'en cours',
        'invalidated': 'à reprendre',
      }[s] ??
      'non vérifié';
}

class DocumentControlsService {
  DocumentControlsService({
    required this.medical,
    DocumentControlRunner? runner,
    this.checkpoint,
  }) : runner = runner ?? LocalDocumentControlRunner();
  final DocumentMedicalService medical;
  final DocumentControlRunner runner;
  final Future<void> Function(String)? checkpoint;
  static final _active = <String>{};
  Future<Directory> get root async =>
      Directory(p.join((await medical.pdf.root()).path, 'controls'));
  Future<MedicalRow?> configuration() async {
    final rows = await (await medical.pdf.database()).query(
      'document_control_config',
    );
    return rows.isEmpty ? null : rows.single;
  }

  Future<void> configure(
    Map<String, String> paths, {
    required int expectedRevision,
  }) async {
    final config = await runner.inspect(Map.unmodifiable(paths));
    final db = await medical.pdf.database();
    await db.transaction((tx) async {
      final old = await tx.query('document_control_config');
      if ((old.isEmpty ? 0 : old.single['revision']) != expectedRevision) {
        throw StateError('Configuration modifiée ailleurs. Rechargez-la.');
      }
      final row = {
        'id': 1,
        'revision': expectedRevision + 1,
        'data_json': medicalCanonical(config),
        'fingerprint': medicalHash(config),
      };
      if (old.isEmpty) {
        await tx.insert('document_control_config', row);
      } else {
        await tx.update('document_control_config', row, where: 'id=1');
      }
    });
  }

  Future<void> invalidate(
    DatabaseExecutor db,
    String run,
    String reason,
  ) async {
    await db.insert('document_control_invalidations', {
      'run_id': run,
      'reason': reason,
      'invalidated_at': medical.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  Future<MedicalRow?> last(String id) async {
    final rows = await (await medical.pdf.database()).rawQuery(
      '''SELECT r.*, x.data_json AS result_json, i.reason
      FROM document_control_runs r LEFT JOIN document_control_results x ON x.run_id=r.run_id
      LEFT JOIN document_control_invalidations i ON i.run_id=r.run_id
      WHERE r.version_id=? ORDER BY r.rowid DESC LIMIT 1''',
      [id],
    );
    return rows.isEmpty ? null : rows.single;
  }

  Future<void> verifyFiles(MedicalRow run, Map result) async {
    final directory = p.join((await root).path, run['directory'] as String);
    if (!RegExp(r'^[0-9a-f-]{36}$').hasMatch(run['directory'] as String)) {
      throw StateError('Dossier de preuve invalide');
    }
    await LocalDocumentControlRunner.regular(directory, directory: true);
    for (final e in (result['files'] as Map).entries) {
      if (e.key != p.basename(e.key) || e.key == '.' || e.key == '..') {
        throw StateError('Chemin de preuve invalide');
      }
      final file = File(p.join(directory, e.key));
      await LocalDocumentControlRunner.regular(file.path);
      if (FinalPdfDocumentService.hash(await file.readAsBytes()) != e.value) {
        throw StateError('Preuve absente ou modifiée');
      }
    }
  }

  Future<DocumentControlStatus> status(
    EpisodeDocumentVersion version, {
    Dv1RetryReview? retry,
  }) async {
    final r = await last(version.id);
    if (r == null) {
      return const DocumentControlStatus(
        'non_verifie',
        'non_verifie',
        'Contrôles locaux non effectués.',
      );
    }
    if (r['reason'] != null &&
        !(retry?.allowsControlInvalidations(r['run_id'] as String, [r]) ??
            false)) {
      return DocumentControlStatus(
        'invalidated',
        'invalidated',
        r['reason'] as String,
        run: r,
      );
    }
    try {
      final cfg = await configuration();
      if (cfg == null ||
          cfg['fingerprint'] != r['configuration_hash'] ||
          cfg['revision'] != r['configuration_revision']) {
        throw StateError('Configuration changée');
      }
      final data = Map<String, Object?>.from(
        jsonDecode(cfg['data_json'] as String),
      );
      var toolsCurrent = false;
      try {
        toolsCurrent =
            medicalHash(
              await runner.inspect(
                Map<String, String>.from(data['paths'] as Map),
              ),
            ) ==
            cfg['fingerprint'];
      } catch (_) {
        /* Missing tools cannot establish conformity. */
      }
      final db = await medical.pdf.database();
      await db.transaction((tx) async {
        final approval = await (retry == null
            ? medical.approvedCapture(tx, version)
            : retry.capture(medical, tx, version));
        if (approval['approval_id'] != r['approval_id'] ||
            approval['snapshot_hash'] != r['snapshot_hash']) {
          throw StateError('Validation médicale modifiée');
        }
      });
      if (r['result_json'] == null) {
        final active = _active.contains('${db.path}:${version.id}');
        return DocumentControlStatus(
          active ? 'running' : 'non_verifie',
          active ? 'running' : 'non_verifie',
          active
              ? 'Contrôles locaux en cours.'
              : 'Contrôle interrompu : aucune conformité établie. Relance manuelle nécessaire.',
          run: r,
        );
      }
      final result = jsonDecode(r['result_json'] as String) as Map;
      await verifyFiles(r, result);
      if (!toolsCurrent &&
          !(result['pdfa'] == 'non_verifie' &&
              result['cda'] == 'non_verifie')) {
        throw StateError('Outils ou références indisponibles ou modifiés');
      }

      // Recheck receipt after filesystem / configuration checks.
      final fresh = await last(version.id);
      if (fresh?['run_id'] != r['run_id'] ||
          (fresh?['reason'] != null &&
              !(retry?.allowsControlInvalidations(r['run_id'] as String, [
                    fresh!,
                  ]) ??
                  false))) {
        throw StateError('Résultat remplacé ou invalidé');
      }
      await db.transaction((tx) async {
        final receipt = await (retry == null
            ? medical.approvedCapture(tx, version)
            : retry.capture(medical, tx, version));
        final settings = (await tx.query('document_control_config')).single;
        final invalid = await tx.query(
          'document_control_invalidations',
          where: 'run_id=?',
          whereArgs: [r['run_id']],
        );
        if (receipt['approval_id'] != r['approval_id'] ||
            settings['revision'] != r['configuration_revision'] ||
            (invalid.isNotEmpty &&
                !(retry?.allowsControlInvalidations(
                      r['run_id'] as String,
                      invalid,
                    ) ??
                    false))) {
          throw StateError(
            'Préparation modifiée pendant la relecture des preuves',
          );
        }
      });
      return DocumentControlStatus(
        result['pdfa'],
        result['cda'],
        result['message'],
        run: r,
        result: result,
      );
    } catch (e) {
      if (retry == null) {
        await invalidate(
          await medical.pdf.database(),
          r['run_id'] as String,
          e.toString(),
        );
      }
      return DocumentControlStatus(
        'invalidated',
        'invalidated',
        'Résultats à reprendre : $e',
        run: r,
      );
    }
  }

  Future<DocumentControlStatus> run(EpisodeDocumentVersion version) async {
    final db = await medical.pdf.database(),
        key = '${(await medical.pdf.database()).path}:${version.id}';
    if (!_active.add(key)) {
      throw StateError('Un contrôle est déjà en cours pour cette version.');
    }
    String? runId;
    try {
      final cfg = await configuration();
      if (cfg == null) {
        throw StateError('Configurez les outils et références locaux.');
      }
      final config = Map<String, Object?>.from(
        jsonDecode(cfg['data_json'] as String),
      );
      // A missing runtime during an explicit attempt is saved as non verified.
      final approval = await db.transaction(
        (tx) => medical.approvedCapture(tx, version),
      );
      final snapshot = jsonDecode(approval['snapshot_json'] as String) as Map;
      final id = const Uuid().v4();
      final job = Directory(p.join((await root).path, id));
      await job.create(recursive: true);
      await LocalDocumentControlRunner.regular(job.path, directory: true);
      final data = await (await medical.pdf.verifyStoredBytes(
        version,
      )).readAsBytes();
      if (FinalPdfDocumentService.hash(data) != version.digest) {
        throw StateError('PDF modifié');
      }
      await File(
        p.join(job.path, 'document.pdf'),
      ).writeAsBytes(data, flush: true);
      await File(
        p.join(job.path, 'context.json'),
      ).writeAsString(approval['snapshot_json'] as String, flush: true);
      await File(
        p.join(job.path, 'configuration.json'),
      ).writeAsString(cfg['data_json'] as String, flush: true);
      var mapping = '';
      List<int>? cda;
      try {
        cda = DocumentCdaBuilder.build(
          snapshot,
          data,
          approval['approved_at'] as int,
        );
        await File(
          p.join(job.path, 'document.xml'),
        ).writeAsBytes(cda, flush: true);
      } catch (e) {
        mapping = e.toString();
      }
      await db.transaction((tx) async {
        final current = await medical.approvedCapture(tx, version);
        final setting = (await tx.query('document_control_config')).single;
        if (current['approval_id'] != approval['approval_id'] ||
            setting['revision'] != cfg['revision']) {
          throw StateError('Préparation modifiée');
        }
        await tx.insert('document_control_runs', {
          'run_id': id,
          'version_id': version.id,
          'approval_id': approval['approval_id'],
          'snapshot_hash': approval['snapshot_hash'],
          'configuration_hash': cfg['fingerprint'],
          'configuration_revision': cfg['revision'],
          'directory': id,
          'started_at': medical.now().millisecondsSinceEpoch,
        });
      });
      runId = id;
      NativeControlOutput out;
      var toolsAvailable = false;
      try {
        if (medicalHash(
              await runner.inspect(
                Map<String, String>.from(config['paths'] as Map),
              ),
            ) !=
            cfg['fingerprint']) {
          throw StateError('Outils ou références modifiés');
        }
        toolsAvailable = true;
        out = await runner.execute(config, job);
      } catch (e) {
        out = NativeControlOutput(
          'non_verifie',
          'non_verifie',
          'Contrôles indisponibles : $e',
          [],
        );
      }
      await checkpoint?.call('executed');
      final names = {
        'document.pdf',
        'context.json',
        'configuration.json',
        if (cda != null) 'document.xml',
        ...out.files,
      };
      final hashes = <String, String>{};
      for (final n in names) {
        if (n != p.basename(n) || n == '.' || n == '..') {
          throw StateError('Nom de preuve invalide');
        }
        final f = File(p.join(job.path, n));
        await LocalDocumentControlRunner.regular(f.path);
        hashes[n] = FinalPdfDocumentService.hash(await f.readAsBytes());
      }
      if (hashes['document.pdf'] != version.digest ||
          hashes['context.json'] !=
              FinalPdfDocumentService.hash(
                utf8.encode(approval['snapshot_json'] as String),
              ) ||
          hashes['configuration.json'] !=
              FinalPdfDocumentService.hash(
                utf8.encode(cfg['data_json'] as String),
              ) ||
          cda != null &&
              hashes['document.xml'] != FinalPdfDocumentService.hash(cda)) {
        throw StateError('Contenu contrôlé différent de la copie validée');
      }
      // Configuration mutations during execution never validate a stale run.
      if (toolsAvailable &&
          medicalHash(
                await runner.inspect(
                  Map<String, String>.from(config['paths'] as Map),
                ),
              ) !=
              cfg['fingerprint']) {
        throw StateError('Configuration modifiée pendant le contrôle');
      }
      await db.transaction((tx) async {
        final current = await medical.approvedCapture(tx, version);
        final settings = (await tx.query('document_control_config')).single;
        final invalid = await tx.query(
          'document_control_invalidations',
          where: 'run_id=?',
          whereArgs: [id],
        );
        if (current['approval_id'] != approval['approval_id'] ||
            settings['revision'] != cfg['revision'] ||
            invalid.isNotEmpty) {
          throw StateError(
            'Résultat tardif : validation ou configuration modifiée',
          );
        }
        final result = {
          'pdfa': out.pdfa,
          'cda': mapping.isEmpty ? out.cda : 'non_verifie',
          'message': [
            if (mapping.isNotEmpty) mapping,
            out.message,
            'Contrôles locaux du profil sélectionné uniquement. Classe documentaire et correspondance type/classe encore déclarées. Aucune signature CPS ni autorisation d’envoi.',
          ].where((e) => e.isNotEmpty).join('\n'),
          'files': hashes,
          'scope': DocumentCdaBuilder.protocol,
          'networkCalls': 0,
        };
        await tx.insert('document_control_results', {
          'run_id': id,
          'data_json': medicalCanonical(result),
          'completed_at': medical.now().millisecondsSinceEpoch,
        });
      });
      return await status(version);
    } catch (e) {
      if (runId != null) {
        await invalidate(db, runId, e.toString());
        return DocumentControlStatus(
          'invalidated',
          'invalidated',
          'Contrôle inutilisable : $e',
        );
      }
      rethrow;
    } finally {
      _active.remove(key);
    }
  }
}

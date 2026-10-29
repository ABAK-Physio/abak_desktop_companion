import 'dart:convert';
import 'dart:io';
import 'package:xml/xml.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../patients/services/document_native_controls.dart';
import '../../patients/services/document_medical_service.dart';
import '../../patients/services/document_reconciliation_records.dart';
import '../../patients/services/pdf_conversion_evidence.dart';
import '../../patients/services/document_lot_signature_records.dart';
import 'companion_backup_archive.dart';
import '../../patients/services/dmp_chain/wire/package.dart';
import '../../patients/services/dmp_chain/wire/crypto.dart';
import '../../patients/services/dmp_chain/native/dv1_records.dart';
import '../../patients/services/dmp_chain/native/dv1_configuration.dart';
import '../../practitioners/data/practitioner_cps_service.dart';
import '../../../core/settings/cabinet_practice_service.dart';

/// Managed attachment roots. Runtime binaries and external source PDFs are not
/// needed to restore frozen copies and their raw verification reports.
class DocumentBackupContents {
  static const names = ['episode_documents', 'episode_document_versions'];
  static Future<Directory> support() => getApplicationSupportDirectory();
  static Future<List<Map<String, dynamic>>> capture(
    Database db,
    Directory staging,
  ) async {
    final base = await support(), roots = <Map<String, dynamic>>[];
    for (final name in names) {
      final source = Directory(p.join(base.path, name));
      final exists =
          await FileSystemEntity.type(source.path, followLinks: false) !=
          FileSystemEntityType.notFound;
      if (exists) {
        await LocalDocumentControlRunner.regular(source.path, directory: true);
        await CompanionBackupArchive.copyTree(
          source,
          Directory(p.join(staging.path, 'managed', name)),
        );
      }
      roots.add({'name': name, 'sourceRoot': source.path, 'present': exists});
    }
    await validate(db, staging, roots);
    return roots;
  }

  static void validateRoots(List<Map<String, dynamic>> roots) {
    if (roots.length != names.length ||
        roots.map((e) => e['name']).toSet().length != names.length ||
        !roots.every(
          (e) =>
              names.contains(e['name']) &&
              e['present'] is bool &&
              e['sourceRoot'] is String &&
              p.isAbsolute(e['sourceRoot'] as String) &&
              p.basename(e['sourceRoot'] as String) == e['name'],
        )) {
      throw const FormatException('Racines des pièces invalides');
    }
  }

  static Future<bool> table(DatabaseExecutor db, String name) async =>
      (await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
        [name],
      )).isNotEmpty;
  static Future<void> validate(
    DatabaseExecutor db,
    Directory staging,
    List<Map<String, dynamic>> roots,
  ) async {
    validateRoots(roots);
    final versionsRoot = Directory(
      p.join(staging.path, 'managed', 'episode_document_versions'),
    );
    Future<File> file(String root, String relative) async {
      CompanionBackupArchive.validatePath(relative);
      final f = File(p.join(root, relative));
      await LocalDocumentControlRunner.regular(f.path);
      return f;
    }

    if (await table(db, 'episode_document_versions')) {
      for (final v in await db.query('episode_document_versions')) {
        final f = await file(versionsRoot.path, v['relative_path'] as String);
        await PdfConversionEvidence.verify(
          db,
          v['version_id'] as String,
          f.parent,
          v['sha256'] as String,
        );
        if (await f.length() != v['byte_size'] ||
            await CompanionBackupArchive.digest(f) != v['sha256']) {
          throw const FormatException(
            'Copie PDF figée absente ou altérée dans la sauvegarde',
          );
        }
      }
    }
    if (await table(db, 'document_control_runs')) {
      for (final run in await db.rawQuery(
        '''SELECT r.*,x.data_json FROM document_control_runs r
        LEFT JOIN document_control_results x ON r.run_id=x.run_id''',
      )) {
        final dir = run['directory'] as String;
        if (!RegExp(r'^[0-9a-f-]{36}$').hasMatch(dir)) {
          throw const FormatException('Répertoire de preuves invalide');
        }
        // Even interrupted controls retain their input evidence. A completed
        // report must preserve exactly every file covered by its receipt.
        final required = <String, dynamic>{
          'document.pdf': null,
          'context.json': null,
          'configuration.json': null,
        };
        if (run['data_json'] != null) {
          required.addAll(
            Map<String, dynamic>.from(
              jsonDecode(run['data_json'] as String)['files'],
            ),
          );
        }
        for (final e in required.entries) {
          if (e.key != p.basename(e.key)) {
            throw const FormatException('Nom de preuve invalide');
          }
          final f = await file(
            p.join(versionsRoot.path, 'controls', dir),
            e.key,
          );
          if (e.value != null &&
              await CompanionBackupArchive.digest(f) != e.value) {
            throw const FormatException(
              'Preuve de contrôle absente ou altérée',
            );
          }
        }
      }
    }
    if (await table(db, 'document_dv1_configurations')) {
      for (final row in await db.query('document_dv1_configurations')) {
        final configuration = Dv1Configuration(row);
        configuration.check(
          DateTime.fromMillisecondsSinceEpoch(
            row['created_at'] as int,
            isUtc: true,
          ),
        );
      }
    }
    if (await table(db, 'document_chain_steps')) {
      for (final step in await db.query('document_chain_steps')) {
        final versions = await db.query(
          'episode_document_versions',
          where: 'version_id=? AND document_id=?',
          whereArgs: [step['version_id'], step['document_id']],
        );
        if (versions.length != 1 ||
            medicalHash(jsonDecode(step['data_json'] as String)) !=
                step['data_hash']) {
          throw const FormatException(
            'Preuve de chaîne DMP altérée ou orpheline',
          );
        }
        final data = jsonDecode(step['data_json'] as String);
        if (step['phase'] == DocumentLotSignatureRecords.started) {
          await DocumentLotSignatureRecords.verifyChain(
            db,
            step['chain_id'] as String,
            Directory(p.join(versionsRoot.path, 'controls')),
          );
        }
        if (DocumentLotSignatureRecords.phases.contains(step['phase']) &&
            (await db.query(
                  'document_chain_steps',
                  where: 'chain_id=? AND phase=?',
                  whereArgs: [
                    step['chain_id'],
                    DocumentLotSignatureRecords.started,
                  ],
                )).length !=
                1) {
          throw const FormatException(
            'Preuve de signature sans préparation correspondante',
          );
        }
        if (step['phase'] == 'dv1_reservation') {
          await Dv1Records.verify(
            db,
            step,
            controlsRoot: Directory(p.join(versionsRoot.path, 'controls')),
          );
          continue;
        }
        if (step['phase'] == 'dv1_response' &&
            (await db.query(
                  'document_chain_steps',
                  where: 'chain_id=? AND phase=?',
                  whereArgs: [step['chain_id'], 'dv1_reservation'],
                )).length !=
                1) {
          throw const FormatException('Réponse DV1 sans tentative réservée.');
        }
        if (step['state'] == 'reserved' &&
            (await db.query(
                  'document_attempts',
                  where: 'attempt_id=? AND version_id=?',
                  whereArgs: [data['attemptId'], step['version_id']],
                )).length !=
                1) {
          throw const FormatException(
            'Réservation de chaîne sans tentative correspondante',
          );
        }
        if (step['state'] == 'reserved') {
          Future<Map<String, dynamic>> phase(String name) async {
            final rows = await db.query(
              'document_chain_steps',
              where: 'chain_id=? AND version_id=? AND phase=? AND state=?',
              whereArgs: [step['chain_id'], step['version_id'], name, 'passed'],
            );
            if (rows.length != 1) {
              throw const FormatException('Chaîne réservée incomplète');
            }
            return jsonDecode(rows.single['data_json'] as String)
                as Map<String, dynamic>;
          }

          final package = await phase('package'),
              signature = await phase('signature'),
              authentication = await phase('authentication');
          final attempt = (await db.query(
            'document_attempts',
            where: 'attempt_id=?',
            whereArgs: [data['attemptId']],
          )).single;
          if (package['wire'] != null) {
            final approval = (await db.query(
              'document_medical_approvals',
              where: 'approval_id=?',
              whereArgs: [attempt['approval_id']],
            )).single;
            if (package['wire']['replay']['approvedAt'] !=
                approval['approved_at']) {
              throw const FormatException(
                'Horodatage de validation médicale incohérent',
              );
            }
            DmpWireDraft.verifyArchived(
              package,
              jsonDecode(approval['snapshot_json'] as String),
              authentication,
            );
            if (signature['value'] !=
                    DmpWireCrypto.one(
                      DmpWireCrypto.parse(package['wire']['signatureXml']),
                      'SignatureValue',
                    ).innerText ||
                signature['format'] != 'XAdES-1.1.1-RSA-SHA1-SEL-MP-037-2.10') {
              throw const FormatException(
                'Preuve de signature différente du paquet',
              );
            }
          }
          if (medicalHash(package) != data['packageHash'] ||
              signature['packageHash'] != data['packageHash'] ||
              signature['certificateHash'] !=
                  (package['wire'] == null
                      ? authentication['certificateHash']
                      : package['wire']['signingCertificateHash']) ||
              package['sessionHash'] != medicalHash(authentication) ||
              package['snapshotHash'] != attempt['snapshot_hash'] ||
              package['cdaHash'] != attempt['payload_hash']) {
            throw const FormatException(
              'Chaîne et tentative portent sur des contenus différents',
            );
          }
        }
      }
    }
    if (await table(db, 'document_attempts')) {
      for (final attempt in await db.query('document_attempts')) {
        final versions = await db.query(
          'episode_document_versions',
          where: 'version_id=?',
          whereArgs: [attempt['version_id']],
        );
        final approvals = await db.query(
          'document_medical_approvals',
          where: 'approval_id=?',
          whereArgs: [attempt['approval_id']],
        );
        final runs = await db.query(
          'document_control_runs',
          where: 'run_id=?',
          whereArgs: [attempt['control_run_id']],
        );
        if (versions.length != 1 ||
            approvals.length != 1 ||
            runs.length != 1 ||
            versions.single['document_id'] != attempt['document_id'] ||
            versions.single['patient_id'] != attempt['patient_id'] ||
            versions.single['sha256'] != attempt['pdf_hash'] ||
            approvals.single['snapshot_hash'] != attempt['snapshot_hash'] ||
            runs.single['approval_id'] != attempt['approval_id']) {
          throw const FormatException(
            'Journal et preuves de tentative incohérents',
          );
        }
        final payload = await file(
          p.join(
            versionsRoot.path,
            'controls',
            runs.single['directory'] as String,
          ),
          'document.xml',
        );
        if (await CompanionBackupArchive.digest(payload) !=
            attempt['payload_hash']) {
          throw const FormatException(
            'Contenu de tentative différent de la preuve',
          );
        }
      }
      for (final result in await db.query('document_attempt_results')) {
        if (medicalHash(jsonDecode(result['evidence_json'] as String)) !=
                result['evidence_hash'] ||
            (await db.query(
              'document_attempts',
              where: 'attempt_id=?',
              whereArgs: [result['attempt_id']],
            )).isEmpty) {
          throw const FormatException(
            'Preuve de résultat altérée ou orpheline',
          );
        }
      }
    }
    if (await table(db, 'practitioner_cps_profiles')) {
      for (final row in await db.query('practitioner_cps_profiles')) {
        PractitionerCpsReading.fromStored(row);
        final people = await db.query(
          'practitioners',
          where: 'practitioner_id=?',
          whereArgs: [row['practitioner_id']],
        );
        if (people.length != 1) {
          throw const FormatException('Fiche CPS sans praticien local associé');
        }
      }
    } else if ((await db.rawQuery('PRAGMA user_version')).single.values.single
            as int >=
        39) {
      throw const FormatException(
        'Données professionnelles CPS absentes de la sauvegarde',
      );
    }
    if (await table(db, 'practitioner_cps_dates')) {
      for (final row in await db.query('practitioner_cps_dates')) {
        await PractitionerCpsService.storedDates(
          db,
          row['practitioner_id'] as String,
        );
      }
    } else if ((await db.rawQuery('PRAGMA user_version')).single.values.single
            as int >=
        40) {
      throw const FormatException(
        'Dates professionnelles déclarées absentes de la sauvegarde',
      );
    }
    final hasCabinets = await table(db, 'cabinet_practices');
    final hasMemberships = await table(db, 'practitioner_cabinet_memberships');
    if (hasCabinets != hasMemberships ||
        !hasCabinets &&
            ((await db.rawQuery('PRAGMA user_version')).single.values.single
                    as int) >=
                41) {
      throw const FormatException(
        'Cabinet ou rattachements absents de la sauvegarde',
      );
    }
    if (hasCabinets) {
      for (final row in await db.query('cabinet_practices')) {
        CabinetPracticeService.checkData(CabinetPracticeService.data(row));
      }
      for (final row in await db.query('practitioner_cabinet_memberships')) {
        CabinetPracticeService.checkMembership(row);
        if ((await db.query(
                  'cabinet_practices',
                  where: 'cabinet_id=?',
                  whereArgs: [row['cabinet_id']],
                )).length !=
                1 ||
            (await db.query(
                  'practitioners',
                  where: 'practitioner_id=?',
                  whereArgs: [row['practitioner_id']],
                )).length !=
                1) {
          throw const FormatException(
            'Rattachement au cabinet orphelin dans la sauvegarde',
          );
        }
      }
    }
    if ((await db.rawQuery('PRAGMA user_version')).single.values.single as int >= 42) {
      for (final name in ['patient_fr_health_identity', 'patient_vitale_readings',
        'patient_identity_events']) {
        if (!await table(db, name)) {
          throw const FormatException('Identités et preuves locales absentes de la sauvegarde');
        }
      }
    }
    if (await table(db, 'document_reconciliations')) {
      await DocumentReconciliationRecords.validateAll(db);
    } else if ((await db.rawQuery('PRAGMA user_version')).single.values.single
                as int >=
            37 ||
        (await table(db, 'document_events') &&
            (await db.query(
              'document_events',
              where: "kind='reconciliation'",
              limit: 1,
            )).isNotEmpty)) {
      throw const FormatException('Registre de réconciliation absent');
    }
    if (await table(db, 'episode_documents')) {
      for (final doc in await db.query('episode_documents')) {
        final path = doc['file_path'] as String?;
        if (path == null || path.isEmpty) continue;
        for (final root in roots) {
          final source = root['sourceRoot'] as String;
          if (p.isWithin(source, path)) {
            await file(
              p.join(staging.path, 'managed', root['name']),
              p.relative(path, from: source),
            );
          }
        }
      }
    }
  }

  static Future<void> rebind(
    DatabaseExecutor db,
    List<Map<String, dynamic>> roots,
    Directory destination,
  ) async {
    for (final doc in await db.query('episode_documents')) {
      final path = doc['file_path'] as String?;
      if (path == null) continue;
      for (final root in roots) {
        final source = root['sourceRoot'] as String;
        if (!p.isWithin(source, path)) continue;
        final target = p.join(
          destination.path,
          root['name'] as String,
          p.relative(path, from: source),
        );
        if (!p.equals(path, target)) {
          await db.update(
            'episode_documents',
            {'file_path': target},
            where: 'document_id=?',
            whereArgs: [doc['document_id']],
          );
        }
      }
    }
  }

  /// Preserve files created after an older backup. A conflicting immutable copy
  /// or report is never overwritten; it requires explicit recovery work.
  static Future<void> overlay(
    Directory source,
    Directory target, {
    required bool immutable,
  }) async {
    await target.create(recursive: true);
    await for (final e in source.list(followLinks: false)) {
      final dst = p.join(target.path, p.basename(e.path));
      final type = await FileSystemEntity.type(dst, followLinks: false);
      if (e is Link || type == FileSystemEntityType.link) {
        throw const FormatException('Lien interdit dans une restauration');
      }
      if (e is Directory) {
        await overlay(e, Directory(dst), immutable: immutable);
      } else if (e is File) {
        if (type == FileSystemEntityType.file &&
            immutable &&
            await CompanionBackupArchive.digest(e) !=
                await CompanionBackupArchive.digest(File(dst))) {
          throw const FormatException(
            'Conflit de copie figée ou de preuve : restauration annulée, fichiers conservés',
          );
        }
        await e.copy(dst);
      } else {
        throw const FormatException('Type de pièce non pris en charge');
      }
    }
  }
}

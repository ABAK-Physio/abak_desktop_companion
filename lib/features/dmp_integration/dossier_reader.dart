import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../patients/models/patient_fr_health_identity.dart';
import '../patients/models/episode_document.dart';
import '../care_episodes/models/care_episode_report.dart';

String fingerprint(Object? value) {
  Object? canonical(Object? v) {
    if (v is Map) {
      final keys = v.keys.cast<String>().toList()..sort();
      return {for (final k in keys) k: canonical(v[k])};
    }
    if (v is List) return v.map(canonical).toList();
    return v;
  }

  return sha256.convert(utf8.encode(jsonEncode(canonical(value)))).toString();
}

class IntegrationBlocked implements Exception {
  const IntegrationBlocked(this.code);
  final String code;
  @override
  String toString() => code;
}

/// Explicit boundary: no default application paths and no symlink traversal.
class IsolatedFiles {
  IsolatedFiles(Directory root) : root = root.resolveSymbolicLinksSync();
  final String root;
  File checked(String path) {
    if (!p.isAbsolute(path) || !p.isWithin(root, p.normalize(path))) {
      throw const IntegrationBlocked('chemin_interdit');
    }
    var current = root;
    for (final part in p.split(p.relative(path, from: root))) {
      if (part == '..' || part == '.') {
        throw const IntegrationBlocked('chemin_interdit');
      }
      current = p.join(current, part);
      if (FileSystemEntity.typeSync(current, followLinks: false) ==
          FileSystemEntityType.link) {
        throw const IntegrationBlocked('chemin_interdit');
      }
    }
    return File(path);
  }

  List<int> read(String path) {
    final file = checked(path);
    try {
      if (file.lengthSync() > 2000000) {
        throw const IntegrationBlocked('format_indisponible');
      }
      return file.readAsBytesSync();
    } on FileSystemException {
      throw const IntegrationBlocked('fichier_indisponible');
    }
  }
}

/// Deliberately injected: clinical rendering and INS validation are not invented
/// by the adapter. The bench uses non-routable fixtures only.
abstract interface class ClinicalDecoder {
  String report(String content);
  String attachment(String mime, List<int> bytes);
}

abstract interface class IdentityVerifier {
  bool verifiedNir(PatientFrHealthIdentity identity);
}

class DossierSnapshot {
  DossierSnapshot({
    required this.patientId,
    required this.episodeId,
    required this.documentId,
    required this.author,
    required this.saved,
    required this.identity,
    required this.clinicalText,
    required Map<String, Object?> payload,
  }) : canonicalPayload = jsonEncode(payload);
  final String patientId, episodeId, documentId, author, clinicalText;
  final bool saved;
  final PatientFrHealthIdentity identity;
  // Encoded copy keeps nested dependency data immutable after the transaction.
  final String canonicalPayload;
  String get identityVersion => fingerprint(identity.toMap());
  String get version => fingerprint(jsonDecode(canonicalPayload));
  String get lineage => fingerprint([patientId, episodeId, documentId]);
}

/// SELECT-only adapter. Caller supplies an already-open read-only connection.
/// No DatabaseService singleton, migrations, INSi, CPS, network or UI imports.
class DossierReader {
  DossierReader(this.db, this.files, this.decoder, this.identities);
  final Database db;
  final IsolatedFiles files;
  final ClinicalDecoder decoder;
  final IdentityVerifier identities;

  Future<Map<String, Object?>> _one(
    DatabaseExecutor tx,
    String table,
    String column,
    String id,
  ) async {
    final rows = await tx.query(table, where: '$column = ?', whereArgs: [id]);
    if (rows.length != 1 || rows.single['archived_at'] != null) {
      throw const IntegrationBlocked('rattachement_invalide');
    }
    return rows.single;
  }

  void checkIdentity(PatientFrHealthIdentity i) {
    if (!i.isQualified ||
        i.identityDoubtful ||
        [
          i.insNumber,
          i.insKey,
          i.insOid,
          i.birthLastName,
          i.birthFirstNames,
          i.birthDate,
          i.sexCode,
          i.birthPlaceCode,
        ].any((v) => v == null || v.trim().isEmpty) ||
        !identities.verifiedNir(i)) {
      throw const IntegrationBlocked('identite_bloquee');
    }
  }

  Future<DossierSnapshot> read(
    String id,
    String expectedPatient, {
    bool attachment = false,
  }) async {
    if ((await db.rawQuery('PRAGMA query_only')).single.values.first != 1) {
      throw const IntegrationBlocked('lecture_seule_requise');
    }
    return db.transaction((tx) async {
      final raw = await _one(
        tx,
        attachment ? 'episode_documents' : 'care_episode_reports',
        attachment ? 'document_id' : 'report_id',
        id,
      );
      final report = attachment ? null : CareEpisodeReport.fromMap(raw);
      final piece = attachment ? EpisodeDocument.fromMap(raw) : null;
      // The actual schema FK episode_documents.case_id targets care_episodes.
      final episodeId = report?.careEpisodeId ?? piece!.caseId;
      final ep = await _one(tx, 'care_episodes', 'care_episode_id', episodeId);
      if (ep['patient_id'] != expectedPatient) {
        throw const IntegrationBlocked('rattachement_invalide');
      }
      await _one(tx, 'patients', 'patient_id', expectedPatient);
      final identity = PatientFrHealthIdentity.fromMap(
        await _one(
          tx,
          'patient_fr_health_identity',
          'patient_id',
          expectedPatient,
        ),
      );
      checkIdentity(identity);
      final dependencies = <Object?>[];
      if (report != null) {
        final notes = await tx.query(
          'care_episode_report_notes',
          where: 'report_id = ?',
          whereArgs: [id],
          orderBy: 'note_id',
        );
        for (final link in notes) {
          final note = await _one(
            tx,
            'care_episode_notes',
            'note_id',
            link['note_id'] as String,
          );
          if (note['care_episode_id'] != episodeId) {
            throw const IntegrationBlocked('rattachement_invalide');
          }
          dependencies.add(note);
        }
        final tests = await tx.query(
          'care_episode_report_tests',
          where: 'report_id = ?',
          whereArgs: [id],
          orderBy: 'exo_id',
        );
        for (final link in tests) {
          final results = await tx.query(
            'desktop_results',
            where: 'care_episode_id = ? AND exoId = ? AND archived_at IS NULL',
            whereArgs: [episodeId, link['exo_id']],
            orderBy: 'result_id',
          );
          if (results.isEmpty ||
              results.any(
                (r) =>
                    r['patient_id'] != null &&
                    r['patient_id'] != expectedPatient,
              )) {
            throw const IntegrationBlocked('rattachement_invalide');
          }
          dependencies.add(results);
        }
        if (report.sourceAssessmentId != null) {
          final source = await _one(
            tx,
            'care_episode_assessments',
            'assessment_id',
            report.sourceAssessmentId!,
          );
          if (source['care_episode_id'] != episodeId) {
            throw const IntegrationBlocked('rattachement_invalide');
          }
          dependencies.add(source);
        }
      }
      final bytes = piece == null ? null : files.read(piece.filePath);
      final clinical = report != null
          ? decoder.report(report.contentJson)
          : decoder.attachment(piece!.mimeType ?? '', bytes!);
      if (clinical.trim().isEmpty) {
        throw const IntegrationBlocked('document_vide');
      }
      // Conservative versioning includes all source fields/dependencies: better
      // revalidate a harmless edit than silently omit a clinical dependency.
      return DossierSnapshot(
        patientId: expectedPatient,
        episodeId: episodeId,
        documentId: '${attachment ? 'piece' : 'report'}:$id',
        author: report?.authorPractitionerId ?? '',
        saved: report?.isSaved ?? false,
        identity: identity,
        clinicalText: clinical,
        payload: {
          'source': raw,
          'episode': ep,
          'identity': identity.toMap(),
          'dependencies': dependencies,
          'bytes': bytes == null ? null : sha256.convert(bytes).toString(),
        },
      );
    });
  }
}

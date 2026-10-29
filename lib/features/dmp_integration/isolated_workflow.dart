import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../dmp_td02/td02_result.dart';
import 'dossier_reader.dart';

/// A rehearsal capability, never a real patient/session authorization.
class IntegrationContext {
  const IntegrationContext({
    required this.patient,
    required this.professional,
    required this.structure,
    required this.identityVersion,
    required this.session,
    required this.checkedSession,
    required this.result,
    this.opposition = false,
    this.functional = true,
    this.authorRights = true,
    this.minor = false,
    this.secret,
    this.rlVisible = false,
    this.patientVisible = false,
    this.correlated = true,
  });
  final String patient,
      professional,
      structure,
      identityVersion,
      session,
      checkedSession;
  final Td02Result result;
  final bool opposition,
      functional,
      authorRights,
      minor,
      rlVisible,
      patientVisible,
      correlated;
  final bool? secret;
  String get stamp =>
      fingerprint([patient, professional, structure, identityVersion, session]);
  String version(DossierSnapshot s) => fingerprint([
    s.version,
    professional,
    structure,
    rlVisible,
    patientVisible,
  ]);
  String? guard(DossierSnapshot s) {
    if (!patient.startsWith('fixture-') ||
        !professional.startsWith('fixture-') ||
        !structure.startsWith('fixture-')) {
      return 'simulation_uniquement';
    }
    if (s.patientId != patient ||
        s.author != professional ||
        identityVersion != s.identityVersion ||
        session != checkedSession ||
        !correlated) {
      return 'contexte_perime';
    }
    if (minor && secret == null) return 'choix_session_requis';
    if (minor && secret == true && rlVisible) return 'visibilite_incompatible';
    if (!result.allows(
      DmpAction.deposit,
      opposition: opposition,
      functionalRights: functional,
      authorRights: authorRights,
      consultationConsent: false,
    )) {
      return result.state != DmpState.active
          ? 'dmp_${result.state.name}'
          : 'droits_ou_opposition';
    }
    return null;
  }
}

final class IntegrationFakeService {
  IntegrationFakeService({this.outcome = 'accepted', this.gate});
  final String outcome;
  final Future<void>? gate;
  final sentVersions = <String>[];
  Future<String> send(String version) async {
    sentVersions.add(version);
    if (gate != null) await gate;
    return {
          'accepted',
          'signatureRejected',
          'metadataRejected',
        }.contains(outcome)
        ? outcome
        : 'indeterminate';
  }
}

/// Two databases inside the isolated root. The witness is deliberately outside
/// the simulated restorable journal. No production backup hook is installed.
class IntegrationJournal {
  IntegrationJournal._(this.db, this.witness);
  final Database db, witness;
  // Fault injection confined to this simulation class.
  String? failAt;
  static Future<IntegrationJournal> open(IsolatedFiles files) async {
    Future<Database> open(String name) async {
      final path = files.checked('${files.root}/$name').path;
      final db = await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(singleInstance: false),
      );
      await db.execute('PRAGMA synchronous=FULL');
      await db.execute('CREATE TABLE IF NOT EXISTS scope(value TEXT NOT NULL)');
      final scope = await db.query('scope');
      if (scope.isEmpty) {
        await db.insert('scope', {'value': 'DMP-INTEGRATION-FICTIVE-1'});
      } else if (scope.length != 1 ||
          scope.single['value'] != 'DMP-INTEGRATION-FICTIVE-1') {
        await db.close();
        throw const IntegrationBlocked('stockage_bloque');
      }
      return db;
    }

    final db = await open('journal.sqlite');
    final witness = await open('temoin-non-restaure.sqlite');
    await db.execute(
      'CREATE TABLE IF NOT EXISTS validation(lineage TEXT PRIMARY KEY, version TEXT NOT NULL, source TEXT NOT NULL, author TEXT NOT NULL, at TEXT NOT NULL, held INTEGER NOT NULL)',
    );
    await db.execute(
      'CREATE TABLE IF NOT EXISTS attempts(lineage TEXT PRIMARY KEY, version TEXT NOT NULL, source TEXT NOT NULL, outcome TEXT NOT NULL, unique_id TEXT NOT NULL, entry_uuid TEXT)',
    );
    await witness.execute(
      'CREATE TABLE IF NOT EXISTS claims(lineage TEXT PRIMARY KEY, version TEXT NOT NULL)',
    );
    return IntegrationJournal._(db, witness);
  }

  void fault(String point) {
    if (failAt == point) throw const IntegrationBlocked('stockage_bloque');
  }

  Future<void> validate(
    DossierSnapshot s,
    IntegrationContext c,
    DateTime date, {
    bool held = false,
  }) async {
    if (!s.saved) throw const IntegrationBlocked('validation_impossible');
    if (c.guard(s) case final String error) throw IntegrationBlocked(error);
    fault('validation');
    await db.insert('validation', {
      'lineage': s.lineage,
      'version': c.version(s),
      'source': s.version,
      'author': c.professional,
      'at': date.toUtc().toIso8601String(),
      'held': held ? 1 : 0,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> hold(String lineage, bool value) async {
    await db.update(
      'validation',
      {'held': value ? 1 : 0},
      where: 'lineage = ?',
      whereArgs: [lineage],
    );
  }

  Future<String?> prior(DossierSnapshot s, IntegrationContext c) async {
    final attempts = await db.query(
      'attempts',
      where: 'lineage = ?',
      whereArgs: [s.lineage],
    );
    final claims = await witness.query(
      'claims',
      where: 'lineage = ?',
      whereArgs: [s.lineage],
    );
    if (claims.isEmpty && attempts.isEmpty) return null;
    if (claims.length != 1 ||
        attempts.length != 1 ||
        claims.single['version'] != attempts.single['version']) {
      return 'rapprochement_requis';
    }
    final old = attempts.single;
    if (old['outcome'] == 'accepted' && old['version'] != c.version(s)) {
      return old['source'] == s.version
          ? 'modification_a_preparer'
          : 'remplacement_a_preparer';
    }
    return switch (old['outcome']) {
      'accepted' => 'deja_accepte',
      'signatureRejected' => 'signature_rejetee',
      'metadataRejected' => 'metadonnees_rejetees',
      _ => 'indetermine',
    };
  }

  Future<bool> reserve(DossierSnapshot s, IntegrationContext c) async {
    fault('reserve');
    try {
      await witness.insert('claims', {
        'lineage': s.lineage,
        'version': c.version(s),
      }, conflictAlgorithm: ConflictAlgorithm.abort);
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) return false;
      rethrow;
    }
    // Witness-first: a failed journal write leaves a durable blocking witness.
    fault('afterWitness');
    await db.insert('attempts', {
      'lineage': s.lineage,
      'version': c.version(s),
      'source': s.version,
      'outcome': 'pending',
      'unique_id': 'fixture-${s.lineage}',
      'entry_uuid': null,
    });
    return true;
  }

  Future<void> finish(String lineage, String outcome) async {
    fault('finish');
    await db.update(
      'attempts',
      {
        'outcome': outcome,
        'entry_uuid': outcome == 'accepted' ? 'fixture-entry-$lineage' : null,
      },
      where: 'lineage = ?',
      whereArgs: [lineage],
    );
  }

  Future<void> close() async {
    await db.close();
    await witness.close();
  }
}

class IntegrationWorkflow {
  IntegrationWorkflow(this.reader, this.journal, this.service, this.context);
  final DossierReader reader;
  final IntegrationJournal journal;
  final IntegrationFakeService service;
  IntegrationContext context; // ephemeral; never restored from journal
  Future<void> Function()? beforeReserve;
  Future<void> Function()? afterReserve;
  bool interruptAfterReserve = false;
  Future<String> run(String id) async {
    var reserved = false;
    try {
      var s = await reader.read(id, context.patient);
      final initialStamp = context.stamp;
      final initialVersion = context.version(s);
      if (beforeReserve != null) await beforeReserve!();
      s = await reader.read(id, context.patient);
      if (context.stamp != initialStamp ||
          context.version(s) != initialVersion) {
        return 'contexte_perime';
      }
      final guard = context.guard(s);
      if (guard != null) return guard;
      final prior = await journal.prior(s, context);
      if (prior != null) return prior;
      final rows = await journal.db.query(
        'validation',
        where: 'lineage = ?',
        whereArgs: [s.lineage],
      );
      if (!s.saved ||
          rows.length != 1 ||
          rows.single['version'] != context.version(s)) {
        return 'validation_requise';
      }
      if (rows.single['held'] == 1) return 'retenu';
      if (!await journal.reserve(s, context)) return 'tentative_existante';
      reserved = true;
      if (interruptAfterReserve) return 'indetermine';
      if (afterReserve != null) await afterReserve!();
      final latest = await reader.read(id, context.patient);
      final validation = await journal.db.query(
        'validation',
        where: 'lineage = ?',
        whereArgs: [s.lineage],
      );
      if (context.stamp != initialStamp ||
          context.version(latest) != initialVersion ||
          context.guard(latest) != null ||
          validation.length != 1 ||
          validation.single['held'] != 0 ||
          validation.single['version'] != initialVersion) {
        return 'indetermine'; // reservation retained, never silently reused
      }
      final outcome = await service.send(initialVersion);
      await journal.finish(s.lineage, outcome);
      return switch (outcome) {
        'accepted' => 'accepte_simule',
        'signatureRejected' => 'signature_rejetee',
        'metadataRejected' => 'metadonnees_rejetees',
        _ => 'indetermine',
      };
    } on IntegrationBlocked catch (e) {
      return reserved ? 'indetermine' : e.code;
    } on DatabaseException {
      return reserved ? 'indetermine' : 'stockage_bloque';
    } on FileSystemException {
      return reserved ? 'indetermine' : 'stockage_bloque';
    }
  }
}

String integrationMessage(String code) => switch (code) {
  'accepte_simule' => 'Traitement fictif accepté. Aucun envoi réseau.',
  'deja_accepte' => 'Document déjà accepté en simulation : renvoi bloqué.',
  'signature_rejetee' =>
    'Signature rejetée en simulation : aucun réessai automatique.',
  'metadonnees_rejetees' =>
    'Métadonnées rejetées en simulation : correction requise.',
  'indetermine' || 'rapprochement_requis' || 'tentative_existante' =>
    'Tentative existante ou résultat incertain : renvoi bloqué, contrôle requis.',
  'validation_requise' => 'Cette version nécessite une validation médicale.',
  'retenu' => 'Document retenu. Aucun traitement lancé.',
  'document_vide' => 'Document sans contenu clinique : traitement bloqué.',
  'identite_bloquee' =>
    'Identité non utilisable pour le DMP. Aucun traitement lancé.',
  'contexte_perime' =>
    'Contexte modifié ou non corrélé : renouveler les contrôles.',
  'choix_session_requis' =>
    'Choisir une connexion normale ou secrète pour cette session.',
  'visibilite_incompatible' =>
    'Visibilité incompatible avec la connexion secrète.',
  'dmp_absent' => 'Aucun DMP trouvé. Traitement bloqué.',
  'dmp_closed' => 'DMP fermé. Traitement bloqué.',
  'dmp_unknown' => 'Vérification du DMP impossible. Traitement bloqué.',
  'droits_ou_opposition' =>
    'Droits insuffisants ou opposition : traitement bloqué.',
  'remplacement_a_preparer' =>
    'Version modifiée : préparer un remplacement, sans nouvel envoi.',
  'modification_a_preparer' =>
    'Visibilité modifiée : préparer le parcours dédié, sans nouvel envoi.',
  _ => 'Traitement suspendu : données ou stockage indisponibles.',
};

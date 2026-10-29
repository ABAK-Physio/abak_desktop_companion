import 'dart:io';
import 'dart:convert';
import 'search_targets.dart';
import '../patients/services/document_journal_service.dart';
import '../patients/services/document_medical_service.dart';
import '../patients/services/dmp_chain/native/access_context.dart';
import '../patients/services/dmp_chain/native/dv1_records.dart';

/// Persistent no-replay marker survives an uncertain server response or restart.
class Dv1Depublication {
  Dv1Depublication(this.journal);
  final DocumentJournalService journal;
  Future<File> marker(Dv1SearchTarget target) async => File(
    '${(await journal.controls.root).path}/dv1-depublication-reservations/${medicalHash(target.uniqueId)}.json',
  );
  Future<String> prepare(
    Dv1SearchTarget target,
    Dv1AccessContext context,
  ) async {
    target.checkContext(context);
    if (context.scenario != 'PRE_ALIM_SUPPR' ||
        target.data['origin'] == 'reviewed_legacy' ||
        target.data['professional'] != context.professional ||
        target.data['structure'] != context.structure) {
      throw StateError(
        'Dépublication réservée à l’auteur du dépôt local, dans son contexte et le scénario PRE_ALIM_SUPPR.',
      );
    }
    await Dv1SearchTargets(journal).verify(target);
    final db = await journal.database;
    final latest = (await db.query(
      'document_chain_steps',
      columns: ['chain_id'],
      where: 'document_id=? AND phase=?',
      whereArgs: [target.data['documentId'], 'dv1_reservation'],
      orderBy: 'rowid DESC',
      limit: 1,
    )).single;
    if (latest['chain_id'] != target.id) {
      throw StateError(
        'Sélectionnez le dernier document accepté, après remplacement.',
      );
    }
    if (await (await marker(target)).exists()) {
      throw StateError(
        'Dépublication déjà réservée ou exécutée : renvoi bloqué. Consultez les preuves.',
      );
    }
    final row = (await db.query(
      'document_chain_steps',
      where: 'chain_id=? AND phase=?',
      whereArgs: [target.id, 'dv1_package'],
    )).single;
    return Dv1Records.data(row)['request'] as String;
  }

  Future<void> reserve(
    Dv1SearchTarget target,
    Dv1AccessContext context,
    String historyId,
    String request,
  ) async {
    await prepare(target, context);
    await reserveFile(await marker(target), {
      'historyId': historyId,
      'target': target.data,
      'requestHash': medicalHash(request),
      'state': 'reserved',
    });
  }

  static Future<void> reserveFile(
    File file,
    Map<String, dynamic> evidence,
  ) async {
    await file.parent.create(recursive: true);
    // Exclusive creation survives response uncertainty, restart and concurrent requests.
    await file.create(exclusive: true);
    await file.writeAsString(jsonEncode(evidence), flush: true);
  }
}

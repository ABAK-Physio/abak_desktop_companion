import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Additive migration only. Existing simulated attempts and real attachments
/// are never rewritten. DV1 reservations live in the common immutable chain.
Future<void> createDocumentDv1Tables(DatabaseExecutor db) async {
  await db.execute('''CREATE TABLE IF NOT EXISTS document_dv1_configurations (
    revision INTEGER PRIMARY KEY, data_json TEXT NOT NULL, data_hash TEXT NOT NULL,
    created_at INTEGER NOT NULL)''');
  for (final verb in ['UPDATE', 'DELETE']) {
    await db.execute(
      '''CREATE TRIGGER IF NOT EXISTS dv1_config_${verb.toLowerCase()}
      BEFORE $verb ON document_dv1_configurations BEGIN
      SELECT RAISE(ABORT,'Configuration DV1 immuable'); END''',
    );
  }
  await db.execute('''CREATE TRIGGER IF NOT EXISTS dv1_config_revision
    BEFORE INSERT ON document_dv1_configurations WHEN
    NEW.revision != COALESCE((SELECT MAX(revision) FROM document_dv1_configurations),0)+1
    BEGIN SELECT RAISE(ABORT,'Configuration DV1 remplacée ailleurs'); END''');
  await db.execute(
    '''CREATE TRIGGER IF NOT EXISTS dv1_config_event
    AFTER INSERT ON document_dv1_configurations BEGIN INSERT INTO document_events
    (kind,reference_id,detail,created_at) VALUES('dv1_configuration',NEW.revision,
    'Configuration de recette DV1 enregistrée ; aucune connexion déclenchée',NEW.created_at); END''',
  );
  await db.execute('''CREATE UNIQUE INDEX IF NOT EXISTS dv1_chain_phase
    ON document_chain_steps(chain_id,phase) WHERE phase LIKE 'dv1_%' ''');
  // Replaced by schema 48: keep the durable duplicate guard, with one
  // explicitly linked retry. Full SOAP/cryptographic checks run in the same
  // reservation transaction in DocumentJournalService. No rows are rewritten.
  await db.execute('DROP TRIGGER IF EXISTS dv1_reservation_guard');
  await db.execute(
    r'''CREATE TRIGGER dv1_reservation_guard
    BEFORE INSERT ON document_chain_steps WHEN NEW.phase='dv1_reservation' AND (
      NEW.state!='reserved' OR
      NOT EXISTS(SELECT 1 FROM episode_document_versions WHERE version_id=NEW.version_id AND document_id=NEW.document_id) OR
      EXISTS(SELECT 1 FROM document_restore_barriers) OR
      EXISTS(SELECT 1 FROM document_attempts a JOIN episode_document_versions v ON v.version_id=NEW.version_id
        WHERE a.document_id=NEW.document_id OR (a.patient_id=v.patient_id AND a.pdf_hash=v.sha256)) OR
      (EXISTS(SELECT 1 FROM document_chain_steps s
        JOIN episode_document_versions old ON old.version_id=s.version_id
        JOIN episode_document_versions v ON v.version_id=NEW.version_id
        WHERE s.phase='dv1_reservation' AND
          (s.document_id=NEW.document_id OR (old.patient_id=v.patient_id AND old.sha256=v.sha256)))
      AND NOT (
        CASE WHEN json_valid(NEW.data_json) THEN
          json_extract(NEW.data_json,'$.replacement.schema')=1 AND
          NOT EXISTS(SELECT 1 FROM document_chain_steps z
            JOIN episode_document_versions ov ON ov.version_id=z.version_id
            JOIN episode_document_versions nv ON nv.version_id=NEW.version_id
            WHERE z.phase='dv1_reservation' AND (z.version_id=NEW.version_id OR
              (ov.patient_id=nv.patient_id AND ov.sha256=nv.sha256))) AND
          EXISTS(SELECT 1 FROM document_chain_steps src
            JOIN episode_document_versions ov ON ov.version_id=src.version_id
            JOIN episode_document_versions nv ON nv.version_id=NEW.version_id
            JOIN document_chain_steps result ON result.chain_id=src.chain_id AND result.phase='dv1_response'
            WHERE src.phase='dv1_reservation' AND src.document_id=NEW.document_id AND
              src.chain_id=json_extract(NEW.data_json,'$.replacement.attemptId') AND
              src.version_id=json_extract(NEW.data_json,'$.replacement.versionId') AND
              src.data_hash=json_extract(NEW.data_json,'$.replacement.reservationHash') AND
              ov.patient_id=nv.patient_id AND ov.sequence_number<nv.sequence_number AND ov.sha256!=nv.sha256 AND
              json_extract(result.data_json,'$.outcome')='accepted' AND
              NOT EXISTS(SELECT 1 FROM document_chain_steps later WHERE later.phase='dv1_reservation'
                AND later.document_id=NEW.document_id AND later.rowid>src.rowid))
        ELSE 0 END IS 1 OR (
        CASE WHEN json_valid(NEW.data_json) THEN
          (json_extract(NEW.data_json,'$.retry.reason')='SOAP-MustUnderstand-Security' OR
           (json_extract(NEW.data_json,'$.retry.reason')='XDS-patientId-missing-NH' AND
            json_extract(NEW.data_json,'$.retry.correctedPatientIdProfile')='ins-nh-1') OR
           (json_extract(NEW.data_json,'$.retry.reason')='XDS-labels-signature' AND
            json_extract(NEW.data_json,'$.retry.correctedPatientIdProfile')='ins-nh-1' AND
            json_extract(NEW.data_json,'$.retry.correctedMetadataProfile')='dv1-labels-signature-1') OR
           (json_extract(NEW.data_json,'$.retry.reason')='XDS-signature-title' AND
            json_extract(NEW.data_json,'$.retry.correctedPatientIdProfile')='ins-nh-1' AND
            json_extract(NEW.data_json,'$.retry.correctedMetadataProfile')='dv1-labels-signature-1' AND
            json_extract(NEW.data_json,'$.retry.correctedSignatureTitleProfile')='event-source-1')) AND
          json_extract(NEW.data_json,'$.retry.correctedProfile')='dv1-20261028' AND
          json_extract(NEW.data_json,'$.retry.preparationPolicy')='identical-content-preserve-invalidation' AND
          length(json_extract(NEW.data_json,'$.retry.evidenceHash'))=64 AND
          (SELECT COUNT(*) FROM document_chain_steps s
            JOIN episode_document_versions old ON old.version_id=s.version_id
            JOIN episode_document_versions v ON v.version_id=NEW.version_id
            WHERE s.phase='dv1_reservation' AND
              (s.document_id=NEW.document_id OR (old.patient_id=v.patient_id AND old.sha256=v.sha256)))=
            CASE json_extract(NEW.data_json,'$.retry.reason') WHEN 'SOAP-MustUnderstand-Security' THEN 1 WHEN 'XDS-patientId-missing-NH' THEN 2 WHEN 'XDS-labels-signature' THEN 3 ELSE 4 END AND
          EXISTS(SELECT 1 FROM document_chain_steps original
            WHERE original.phase='dv1_reservation' AND original.state='reserved' AND
              original.chain_id=json_extract(NEW.data_json,'$.retry.previousAttemptId') AND
              original.chain_id!=NEW.chain_id AND original.version_id=NEW.version_id AND
              original.document_id=NEW.document_id AND
              json_extract(original.data_json,'$.approvalId')=json_extract(NEW.data_json,'$.approvalId') AND
              json_extract(original.data_json,'$.snapshotHash')=json_extract(NEW.data_json,'$.snapshotHash') AND
              json_extract(original.data_json,'$.controlRunId')=json_extract(NEW.data_json,'$.controlRunId') AND
              json_extract(original.data_json,'$.cdaHash')=json_extract(NEW.data_json,'$.cdaHash') AND
              (json_extract(NEW.data_json,'$.retry.reason')='SOAP-MustUnderstand-Security' OR
                (json_extract(NEW.data_json,'$.retry.reason')='XDS-patientId-missing-NH' AND
                 json_extract(original.data_json,'$.retry.reason')='SOAP-MustUnderstand-Security' AND
                 json_extract(original.data_json,'$.retry.previousAttemptId')=json_extract(NEW.data_json,'$.retry.firstAttemptId') AND
                 EXISTS(SELECT 1 FROM document_chain_steps first
                   WHERE first.phase='dv1_reservation' AND first.version_id=NEW.version_id AND first.document_id=NEW.document_id AND
                   first.chain_id=json_extract(NEW.data_json,'$.retry.firstAttemptId') AND first.chain_id!=original.chain_id)) OR
                (json_extract(NEW.data_json,'$.retry.reason')='XDS-labels-signature' AND
                 json_extract(original.data_json,'$.retry.reason')='XDS-patientId-missing-NH' AND
                 json_extract(original.data_json,'$.retry.previousAttemptId')=json_extract(NEW.data_json,'$.retry.secondAttemptId') AND
                 json_extract(original.data_json,'$.retry.firstAttemptId')=json_extract(NEW.data_json,'$.retry.firstAttemptId') AND
                 EXISTS(SELECT 1 FROM document_chain_steps second JOIN document_chain_steps first
                   ON first.chain_id=json_extract(second.data_json,'$.retry.previousAttemptId')
                   WHERE second.phase='dv1_reservation' AND first.phase='dv1_reservation' AND
                     second.version_id=NEW.version_id AND first.version_id=NEW.version_id AND
                     second.document_id=NEW.document_id AND first.document_id=NEW.document_id AND
                     second.chain_id=json_extract(NEW.data_json,'$.retry.secondAttemptId') AND
                     first.chain_id=json_extract(NEW.data_json,'$.retry.firstAttemptId') AND
                     json_extract(second.data_json,'$.retry.reason')='SOAP-MustUnderstand-Security' AND
                     first.chain_id!=second.chain_id AND second.chain_id!=original.chain_id AND first.chain_id!=original.chain_id)) OR
                (json_extract(NEW.data_json,'$.retry.reason')='XDS-signature-title' AND
                 json_extract(original.data_json,'$.retry.reason')='XDS-labels-signature' AND
                 json_extract(original.data_json,'$.retry.previousAttemptId')=json_extract(NEW.data_json,'$.retry.thirdAttemptId') AND
                 json_extract(original.data_json,'$.retry.firstAttemptId')=json_extract(NEW.data_json,'$.retry.firstAttemptId') AND
                 json_extract(original.data_json,'$.retry.secondAttemptId')=json_extract(NEW.data_json,'$.retry.secondAttemptId') AND
                 EXISTS(SELECT 1 FROM document_chain_steps third
                   JOIN document_chain_steps second ON second.chain_id=json_extract(third.data_json,'$.retry.previousAttemptId')
                   JOIN document_chain_steps first ON first.chain_id=json_extract(second.data_json,'$.retry.previousAttemptId')
                   WHERE third.phase='dv1_reservation' AND second.phase='dv1_reservation' AND first.phase='dv1_reservation' AND
                     third.version_id=NEW.version_id AND second.version_id=NEW.version_id AND first.version_id=NEW.version_id AND
                     third.document_id=NEW.document_id AND second.document_id=NEW.document_id AND first.document_id=NEW.document_id AND
                     third.chain_id=json_extract(NEW.data_json,'$.retry.thirdAttemptId') AND
                     second.chain_id=json_extract(NEW.data_json,'$.retry.secondAttemptId') AND
                     first.chain_id=json_extract(NEW.data_json,'$.retry.firstAttemptId') AND
                     json_extract(third.data_json,'$.retry.reason')='XDS-patientId-missing-NH' AND
                     json_extract(third.data_json,'$.retry.firstAttemptId')=first.chain_id AND
                     json_extract(second.data_json,'$.retry.reason')='SOAP-MustUnderstand-Security' AND
                     third.chain_id!=original.chain_id AND third.chain_id!=second.chain_id AND third.chain_id!=first.chain_id AND
                     first.chain_id!=second.chain_id AND second.chain_id!=original.chain_id AND first.chain_id!=original.chain_id))))
        ELSE 0 END IS 1))))
    BEGIN SELECT RAISE(ABORT,'Renvoi DV1 bloqué : tentative ou restauration'); END''',
  );
  await db.execute(
    '''CREATE TRIGGER IF NOT EXISTS simulation_after_dv1_guard
    BEFORE INSERT ON document_attempts WHEN EXISTS(
      SELECT 1 FROM document_chain_steps s JOIN episode_document_versions v ON v.version_id=s.version_id
      WHERE s.phase='dv1_reservation' AND (s.document_id=NEW.document_id OR
        (v.patient_id=NEW.patient_id AND v.sha256=NEW.pdf_hash)))
    BEGIN SELECT RAISE(ABORT,'Tentative DV1 existante : renvoi bloqué'); END''',
  );
}

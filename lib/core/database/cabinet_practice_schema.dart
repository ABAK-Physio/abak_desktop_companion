import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// The configured cabinet is independent of the public structures on CPS cards.
/// Existing practitioners are never assigned to it by a migration.
Future<void> createCabinetPracticeTables(DatabaseExecutor db) async {
  await db.execute(
    '''CREATE TABLE IF NOT EXISTS cabinet_practices (
    cabinet_id TEXT PRIMARY KEY, data_json TEXT NOT NULL,
    revision INTEGER NOT NULL CHECK(revision > 0), updated_at INTEGER NOT NULL)''',
  );
  await db.execute(
    '''CREATE TABLE IF NOT EXISTS practitioner_cabinet_memberships (
    membership_id TEXT PRIMARY KEY,
    cabinet_id TEXT NOT NULL REFERENCES cabinet_practices(cabinet_id),
    practitioner_id TEXT NOT NULL REFERENCES practitioners(practitioner_id),
    role TEXT NOT NULL, start_date TEXT, end_date TEXT,
    cps_situation_number INTEGER, active INTEGER NOT NULL CHECK(active IN (0,1)),
    revision INTEGER NOT NULL CHECK(revision > 0), updated_at INTEGER NOT NULL,
    UNIQUE(cabinet_id, practitioner_id))''',
  );
  for (final entry in {
    'cabinet_practices': 'cabinet_id',
    'practitioner_cabinet_memberships': 'membership_id',
  }.entries) {
    final contextKey = entry.key == 'cabinet_practices'
        ? 'cabinetId'
        : 'cabinetMembershipId';
    for (final action in ['INSERT', 'UPDATE', 'DELETE']) {
      final row = action == 'DELETE' ? 'OLD' : 'NEW';
      await db.execute(
        '''CREATE TRIGGER IF NOT EXISTS medical_${entry.key}_${action.toLowerCase()}
        AFTER $action ON ${entry.key} BEGIN
        INSERT INTO document_medical_changes(source_table,source_id)
          VALUES('${entry.key}', $row.${entry.value});
        INSERT OR IGNORE INTO document_approval_invalidations
          SELECT a.approval_id, 'Cabinet ou rattachement professionnel actualisé',
            CAST(strftime('%s','now') AS INTEGER)*1000
          FROM document_medical_approvals a JOIN document_practice_contexts c
            ON c.context_id=a.context_id
          WHERE json_extract(c.data_json,'\$.$contextKey')=$row.${entry.value};
        END''',
      );
    }
  }
  // A change followed by a reversal must not revive an older approval.
  for (final action in ['INSERT', 'UPDATE', 'DELETE']) {
    final row = action == 'DELETE' ? 'OLD' : 'NEW';
    await db.execute(
      '''CREATE TRIGGER IF NOT EXISTS medical_cabinet_identity_${action.toLowerCase()}
      AFTER $action ON application_settings
      WHEN $row.setting_key IN ('organization_id','cabinet_name',
        'cabinet_address_line1','cabinet_address_line2','cabinet_postal_code',
        'cabinet_city','cabinet_phone','cabinet_email')
      BEGIN
      INSERT INTO document_medical_changes(source_table,source_id)
        SELECT 'cabinet_identity', cabinet_id FROM cabinet_practices;
      INSERT OR IGNORE INTO document_approval_invalidations
        SELECT a.approval_id, 'Identité du cabinet actualisée',
          CAST(strftime('%s','now') AS INTEGER)*1000
        FROM document_medical_approvals a JOIN document_practice_contexts c
          ON c.context_id=a.context_id
        WHERE COALESCE(json_extract(c.data_json,'\$.cabinetId'),'')<>'';
      END''',
    );
  }
}

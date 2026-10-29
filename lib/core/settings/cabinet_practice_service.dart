import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import '../database/database_service.dart';
import '../../features/practitioners/data/practitioner_cps_service.dart';
import '../../features/practitioners/models/practitioner_cps_dates.dart';

typedef CabinetRow = Map<String, Object?>;

/// Declared cabinet data and explicit affiliations. No card or network access.
class CabinetPracticeService {
  CabinetPracticeService({Future<Database> Function()? database})
    : database = database ?? (() => DatabaseService.database);
  final Future<Database> Function() database;
  static const fields = [
    'legalName',
    'legalForm',
    'legalIdentifierType',
    'legalIdentifier',
    'setting',
    'facilityCode',
    'facilityLabel',
  ];
  static const roles = [
    'Associé',
    'Assistant',
    'Collaborateur',
    'Salarié',
    'Remplaçant',
    'Autre',
  ];
  static const identityKeys = [
    'organization_id',
    'cabinet_name',
    'cabinet_address_line1',
    'cabinet_address_line2',
    'cabinet_postal_code',
    'cabinet_city',
    'cabinet_phone',
    'cabinet_email',
  ];
  static const bindingKeys = [
    'cabinetId',
    'cabinetRevision',
    'cabinetIdentityHash',
    'cabinetMembershipId',
    'cabinetMembershipRevision',
  ];
  static Map<String, String> data(CabinetRow? row) => row == null
      ? {for (final key in fields) key: ''}
      : Map<String, String>.from(jsonDecode(row['data_json'] as String));

  static Future<Map<String, String>> identity(DatabaseExecutor db) async {
    final rows = await db.query(
      'application_settings',
      where: 'setting_key IN (${identityKeys.map((_) => '?').join(',')})',
      whereArgs: identityKeys,
    );
    return {
      for (final key in identityKeys)
        key:
            rows
                    .where((r) => r['setting_key'] == key)
                    .firstOrNull?['setting_value']
                as String? ??
            '',
    };
  }

  static String identityHash(Map identity) => sha256
      .convert(
        utf8.encode(
          jsonEncode({
            for (final key in identityKeys) key: identity[key] ?? '',
          }),
        ),
      )
      .toString();

  Future<CabinetRow> load() async => (await database()).transaction((db) async {
    final details = await identity(db);
    final cabinets = await db.query(
      'cabinet_practices',
      where: 'cabinet_id=?',
      whereArgs: [details['organization_id']],
    );
    return {
      'identity': details,
      'cabinet': cabinets.firstOrNull,
      'memberships': await db.query(
        'practitioner_cabinet_memberships',
        where: 'cabinet_id=?',
        whereArgs: [details['organization_id']],
      ),
      'practitioners': await db.query(
        'practitioners',
        where: 'is_active=1 AND archived_at IS NULL',
        orderBy: 'display_name',
      ),
    };
  });

  static void checkData(Map<String, String> values) {
    if (values.keys.toSet().difference(fields.toSet()).isNotEmpty ||
        fields.any((key) => !values.containsKey(key))) {
      throw StateError('Paramètres du cabinet incomplets.');
    }
    if ((values['legalIdentifier']!.isEmpty) !=
        (values['legalIdentifierType']!.isEmpty)) {
      throw StateError(
        'Renseignez ensemble le type et l’identifiant juridique, ou laissez-les vides.',
      );
    }
    if ((values['facilityCode']!.isEmpty) !=
        (values['facilityLabel']!.isEmpty)) {
      throw StateError(
        'Le code et le libellé du lieu de soins doivent être renseignés ensemble.',
      );
    }
  }

  Future<void> saveCabinet(
    Map<String, String> values,
    int expectedRevision,
  ) async {
    final normalized = {
      for (final key in fields) key: (values[key] ?? '').trim(),
    };
    checkData(normalized);
    await (await database()).transaction((db) async {
      final details = await identity(db);
      var id = details['organization_id']!;
      final rows = id.isEmpty
          ? <CabinetRow>[]
          : await db.query(
              'cabinet_practices',
              where: 'cabinet_id=?',
              whereArgs: [id],
            );
      final old = rows.firstOrNull;
      if ((old?['revision'] ?? 0) != expectedRevision) {
        throw StateError(
          'Le cabinet a été modifié ailleurs. Fermez puis rouvrez cet écran.',
        );
      }
      if (old != null && jsonEncode(data(old)) == jsonEncode(normalized)) {
        return;
      }
      if (id.isEmpty) {
        id = const Uuid().v4();
        await db.insert('application_settings', {
          'setting_key': 'organization_id',
          'setting_value': id,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      final row = <String, Object?>{
        'cabinet_id': id,
        'data_json': jsonEncode(normalized),
        'revision': expectedRevision + 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };
      if (old == null) {
        await db.insert('cabinet_practices', row);
      } else {
        await db.update(
          'cabinet_practices',
          row,
          where: 'cabinet_id=?',
          whereArgs: [id],
        );
      }
    });
  }

  static void checkMembership(CabinetRow row) {
    if (!roles.contains(row['role']) || ![0, 1].contains(row['active'])) {
      throw StateError('Rôle ou état du rattachement invalide.');
    }
    final start = PractitionerCpsDates.optionalDate(
      row['start_date'] as String?,
    );
    final end = PractitionerCpsDates.optionalDate(row['end_date'] as String?);
    if (start != null && end != null && end.compareTo(start) < 0) {
      throw StateError('La fin d’exercice précède le début.');
    }
  }

  Future<void> saveMembership({
    required String cabinetId,
    required String practitionerId,
    required String role,
    String? startDate,
    String? endDate,
    int? cpsSituation,
    required bool active,
    required int expectedRevision,
  }) async {
    final values = <String, Object?>{
      'role': role,
      'start_date': PractitionerCpsDates.optionalDate(startDate),
      'end_date': PractitionerCpsDates.optionalDate(endDate),
      'cps_situation_number': cpsSituation,
      'active': active ? 1 : 0,
    };
    checkMembership(values);
    await (await database()).transaction((db) async {
      if ((await db.query(
            'cabinet_practices',
            where: 'cabinet_id=?',
            whereArgs: [cabinetId],
          )).isEmpty ||
          (await db.query(
            'practitioners',
            where: 'practitioner_id=? AND is_active=1 AND archived_at IS NULL',
            whereArgs: [practitionerId],
          )).isEmpty) {
        throw StateError('Cabinet ou praticien indisponible.');
      }
      if (cpsSituation != null) {
        final row = await PractitionerCpsService.stored(db, practitionerId);
        if (row == null ||
            !PractitionerCpsReading.fromStored(
              row,
            ).profile.situations.any((s) => s.number == cpsSituation)) {
          throw StateError(
            'Cette situation ne figure pas dans la fiche CPS enregistrée.',
          );
        }
      }
      final rows = await db.query(
        'practitioner_cabinet_memberships',
        where: 'cabinet_id=? AND practitioner_id=?',
        whereArgs: [cabinetId, practitionerId],
      );
      final old = rows.firstOrNull;
      if ((old?['revision'] ?? 0) != expectedRevision) {
        throw StateError(
          'Le rattachement a changé. Fermez puis rouvrez cet écran.',
        );
      }
      if (old != null && values.entries.every((e) => old[e.key] == e.value)) {
        return;
      }
      final row = <String, Object?>{
        ...values,
        'membership_id': old?['membership_id'] ?? const Uuid().v4(),
        'cabinet_id': cabinetId,
        'practitioner_id': practitionerId,
        'revision': expectedRevision + 1,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      };
      if (old == null) {
        await db.insert('practitioner_cabinet_memberships', row);
      } else {
        await db.update(
          'practitioner_cabinet_memberships',
          row,
          where: 'membership_id=?',
          whereArgs: [old['membership_id']],
        );
      }
    });
  }

  /// Only an explicit active affiliation grants prefill. CPS structure IDs are
  /// deliberately never compared to a cabinet ID or to its legal identifier.
  static Future<CabinetRow?> forAuthor(
    DatabaseExecutor db,
    String practitionerId,
  ) async {
    if ((await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='cabinet_practices'",
    )).isEmpty) {
      return null;
    }
    final details = await identity(db);
    final cabinets = await db.query(
      'cabinet_practices',
      where: 'cabinet_id=?',
      whereArgs: [details['organization_id']],
    );
    if (cabinets.isEmpty) return null;
    final links = await db.query(
      'practitioner_cabinet_memberships',
      where: 'cabinet_id=? AND practitioner_id=? AND active=1',
      whereArgs: [details['organization_id'], practitionerId],
    );
    if (links.isEmpty) return null;
    checkData(data(cabinets.single));
    checkMembership(links.single);
    return {
      'cabinet': cabinets.single,
      'membership': links.single,
      'identity': details,
    };
  }

  static Map<String, String> contextValues(CabinetRow source) {
    final cabinet = source['cabinet'] as Map,
        member = source['membership'] as Map;
    final values = data(Map<String, Object?>.from(cabinet));
    return {
      'cabinetId': cabinet['cabinet_id'] as String,
      'cabinetRevision': '${cabinet['revision']}',
      'cabinetIdentityHash': identityHash(source['identity'] as Map),
      'cabinetMembershipId': member['membership_id'] as String,
      'cabinetMembershipRevision': '${member['revision']}',
      for (final key in ['setting', 'facilityCode', 'facilityLabel'])
        if (values[key]!.isNotEmpty) key: values[key]!,
    };
  }

  static Future<CabinetRow?> verifyContext(
    DatabaseExecutor db,
    String author,
    Map context,
  ) async {
    final source = await forAuthor(db, author);
    final bound = bindingKeys.any((k) => (context[k] ?? '') != '');
    if (source == null && !bound) {
      // No cabinet configuration existed for older installations and archives.
      if ((await db.rawQuery(
        "SELECT name FROM sqlite_master WHERE type='table' AND name='cabinet_practices'",
      )).isEmpty) {
        return null;
      }
      final details = await identity(db);
      if ((await db.query(
        'cabinet_practices',
        where: 'cabinet_id=?',
        whereArgs: [details['organization_id']],
      )).isEmpty) {
        return null;
      }
      throw StateError(
        'Rattachez le rédacteur au cabinet dans les paramètres avant d’enregistrer son contexte.',
      );
    }
    if (source == null ||
        contextValues(source).entries.any((e) => context[e.key] != e.value)) {
      throw StateError(
        'Le cabinet ou le rattachement du rédacteur a changé. Reprenez le préremplissage de la situation.',
      );
    }
    final member = source['membership'] as Map;
    if (member['cps_situation_number'] != null &&
        context['cpsSituationNumber'] != '${member['cps_situation_number']}') {
      throw StateError(
        'Sélectionnez la situation CPS enregistrée pour ce rattachement au cabinet.',
      );
    }
    return source;
  }

  static void checkPeriod(CabinetRow source, String day) {
    final member = source['membership'] as Map;
    final start = member['start_date'] as String?,
        end = member['end_date'] as String?;
    if (start != null && day.compareTo(start) < 0 ||
        end != null && day.compareTo(end) > 0) {
      throw StateError(
        'La date est hors de la période de rattachement du rédacteur au cabinet.',
      );
    }
  }
}

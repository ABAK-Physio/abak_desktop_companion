import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/database_service.dart';
import '../../cps/cps_access_service.dart';
import '../../cps/cps_profile.dart';
import '../models/practitioner_cps_dates.dart';

typedef CpsTargetCheck = Future<void> Function(DatabaseExecutor db, String id);

/// A completed reading, not a live authentication or a signing authorization.
class PractitionerCpsReading {
  PractitionerCpsReading._(this.profile, this.readAt);
  final CpsProfile profile;
  final DateTime readAt;

  Map<String, Object?> get data => {
    'nationalId': profile.nationalId,
    'familyName': profile.familyName,
    'givenName': profile.givenName,
    'professionCode': profile.professionCode,
    'cardType': profile.cardType,
    'situations': [
      for (final s in profile.situations)
        {
          'number': s.number,
          'mode': s.mode,
          'status': s.status,
          'structureName': s.structureName,
          'structureId': s.structureId,
          'sector': s.sector,
        },
    ],
  };
  String get encoded => jsonEncode(data);
  String get digest => sha256.convert(utf8.encode(encoded)).toString();

  factory PractitionerCpsReading.fromStored(Map<String, Object?> row) {
    final data = jsonDecode(row['profile_json'] as String) as Map;
    final result = PractitionerCpsReading._(
      CpsProfile(
        nationalId: data['nationalId'] as String,
        familyName: data['familyName'] as String,
        givenName: data['givenName'] as String,
        professionCode: data['professionCode'] as int,
        cardType: data['cardType'] as int,
        situations: List.unmodifiable([
          for (final s in data['situations'] as List)
            CpsSituation(
              number: s['number'] as int,
              mode: s['mode'] as int,
              status: s['status'] as int,
              structureName: s['structureName'] as String?,
              structureId: s['structureId'] as String?,
              sector: s['sector'] as String?,
            ),
        ]),
      ),
      DateTime.fromMillisecondsSinceEpoch(row['read_at'] as int, isUtc: true),
    );
    result.check();
    if (row['provenance'] != 'cps_local_read' ||
        row['national_id'] != result.profile.nationalId ||
        row['profile_hash'] != result.digest) {
      throw StateError('Les données CPS enregistrées sont incohérentes.');
    }
    return result;
  }

  void check() {
    if (profile.nationalId.trim().isEmpty ||
        profile.familyName.trim().isEmpty ||
        profile.givenName.trim().isEmpty ||
        profile.professionCode != 70 ||
        profile.situations.isEmpty ||
        profile.situations.map((s) => s.number).toSet().length !=
            profile.situations.length) {
      throw StateError(
        'Une CPS de masseur-kinésithérapeute avec identité et situations lisibles est requise.',
      );
    }
  }

  /// Only facts actually read, plus the existing DMP coding of those facts.
  /// Clinical dates, practice validity, setting and structure authority stay blank.
  Map<String, String> contextValues(int number) {
    final s = profile.situations.singleWhere((s) => s.number == number);
    return {
      'identifierType': 'IDNPS',
      'identifier': profile.nationalId,
      'authority': '1.2.250.1.71.4.2.1',
      'professionCode': 'G15_70',
      'professionSystem': '1.2.250.1.213.1.1.4.5',
      'professionLabel': profile.professionLabel,
      'familyName': profile.familyName,
      'givenNames': profile.givenName,
      'situation': '$number',
      if (s.structureId?.isNotEmpty == true) 'structureId': s.structureId!,
      if (s.structureName?.isNotEmpty == true)
        'structureName': s.structureName!,
      'cpsProfileHash': digest,
      'cpsReadAt': '${readAt.millisecondsSinceEpoch}',
      'cpsSituationNumber': '$number',
    };
  }
}

class PractitionerCpsProposal {
  PractitionerCpsProposal._(
    this.reading,
    this.practitionerId,
    this.existing,
    this.previous,
    this.previousDates,
  );
  final PractitionerCpsReading reading;
  final String practitionerId;
  final Map<String, Object?>? existing, previous, previousDates;
  String get label =>
      existing?['display_name'] as String? ??
      '${reading.profile.givenName} ${reading.profile.familyName}';
}

class PractitionerCpsService {
  PractitionerCpsService({
    Future<Database> Function()? database,
    Future<CpsProfile> Function(String)? reader,
    DateTime Function()? now,
  }) : database = database ?? (() => DatabaseService.database),
       _reader = reader ?? ((pin) => const CpsAccessService().read(pin)),
       now = now ?? DateTime.now;

  final Future<Database> Function() database;
  final Future<CpsProfile> Function(String) _reader;
  final DateTime Function() now;

  /// This is the only card entry point; callers invoke it only after a PIN action.
  Future<PractitionerCpsReading> read(String pin) async {
    final result = PractitionerCpsReading._(await _reader(pin), now().toUtc());
    result.check();
    return result;
  }

  static bool sameIdentifier(String local, String national) {
    if (local == national) return true;
    // IDNPS carries its identifier namespace prefix. Do not match by name/length alone.
    return (RegExp(r'^8\d{11}$').hasMatch(national) ||
            RegExp(r'^0\d{9}$').hasMatch(national)) &&
        local == national.substring(1);
  }

  /// A cached reading never substitutes for the fresh reading made by signing.
  static bool matchesCurrentProfile(Map snapshot, CpsProfile actual) {
    final stored = snapshot['professionalCps'];
    if (stored == null) return true; // Existing declared-only preparation.
    try {
      final previous = PractitionerCpsReading.fromStored(
        Map<String, Object?>.from(stored as Map),
      );
      final current = PractitionerCpsReading._(
        actual,
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
      );
      current.check();
      return previous.digest == current.digest;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, Object?>>> practitioners() async =>
      (await database()).query(
        'practitioners',
        where: 'is_active=1 AND archived_at IS NULL',
        orderBy: 'display_name',
      );

  static Future<Map<String, Object?>?> stored(
    DatabaseExecutor db,
    String id,
  ) async {
    final rows = await db.query(
      'practitioner_cps_profiles',
      where: 'practitioner_id=?',
      whereArgs: [id],
    );
    if (rows.isEmpty) return null;
    PractitionerCpsReading.fromStored(rows.single);
    return rows.single;
  }

  static PractitionerCpsDates datesFromStored(
    PractitionerCpsReading reading,
    Map<String, Object?>? row,
  ) => row == null
      ? PractitionerCpsDates()
      : PractitionerCpsDates.fromStored(
          row,
          profileHash: reading.digest,
          readAt: reading.readAt.millisecondsSinceEpoch,
          situations: reading.profile.situations.map((s) => s.number),
        );

  static Future<Map<String, Object?>?> storedDates(
    DatabaseExecutor db,
    String practitionerId,
  ) async {
    final rows = await db.query(
      'practitioner_cps_dates',
      where: 'practitioner_id=?',
      whereArgs: [practitionerId],
    );
    if (rows.isEmpty) return null;
    final profile = await stored(db, practitionerId);
    if (profile == null) {
      throw StateError('Dates déclarées sans fiche CPS associée.');
    }
    datesFromStored(PractitionerCpsReading.fromStored(profile), rows.single);
    return rows.single;
  }

  Future<void> _writeDates(
    DatabaseExecutor db,
    String practitionerId,
    PractitionerCpsReading reading,
    PractitionerCpsDates dates,
    Map<String, Object?>? previous,
  ) async {
    dates.checkSituations(reading.profile.situations.map((s) => s.number));
    if (previous == null && dates.isEmpty) return;
    if (previous != null &&
        previous['profile_hash'] == reading.digest &&
        previous['read_at'] == reading.readAt.millisecondsSinceEpoch &&
        previous['issue_date'] == dates.issueDate &&
        previous['exercise_starts_json'] == dates.encodedStarts) {
      return;
    }
    final row = <String, Object?>{
      'practitioner_id': practitionerId,
      'profile_hash': reading.digest,
      'read_at': reading.readAt.millisecondsSinceEpoch,
      'issue_date': dates.issueDate,
      'exercise_starts_json': dates.encodedStarts,
      'revision': (previous?['revision'] as int? ?? 0) + 1,
      'updated_at': now().millisecondsSinceEpoch,
      'provenance': 'user_declared',
    };
    if (previous == null) {
      await db.insert('practitioner_cps_dates', row);
    } else {
      await db.update(
        'practitioner_cps_dates',
        row,
        where: 'practitioner_id=?',
        whereArgs: [practitionerId],
      );
    }
  }

  /// Edits declarations only. No card reader or update of the saved card facts.
  Future<PractitionerCpsDates> saveDates({
    required String practitionerId,
    required PractitionerCpsReading reading,
    required PractitionerCpsDates dates,
    required int expectedRevision,
  }) async => (await database()).transaction((tx) async {
    final current = await _prepare(tx, reading, practitionerId);
    if (current.previous?['profile_hash'] != reading.digest ||
        current.previous?['read_at'] != reading.readAt.millisecondsSinceEpoch ||
        (current.previousDates?['revision'] as int? ?? 0) != expectedRevision) {
      throw StateError(
        'La fiche CPS ou ses dates ont changé. Rouvrez la fiche avant d’enregistrer.',
      );
    }
    await _writeDates(
      tx,
      practitionerId,
      reading,
      dates,
      current.previousDates,
    );
    return datesFromStored(reading, await storedDates(tx, practitionerId));
  });

  static Future<Set<String>> _matches(
    DatabaseExecutor db,
    String national,
  ) async {
    final linked = await db.query(
      'practitioner_cps_profiles',
      where: 'national_id=?',
      whereArgs: [national],
    );
    final practitioners = await db.query('practitioners');
    return {
      for (final r in linked) r['practitioner_id'] as String,
      for (final r in practitioners)
        if (sameIdentifier(
          (r['professional_id'] as String? ?? '').trim(),
          national,
        ))
          r['practitioner_id'] as String,
    };
  }

  Future<String?> matchingPractitioner(PractitionerCpsReading reading) async {
    final matches = await _matches(
      await database(),
      reading.profile.nationalId,
    );
    if (matches.length > 1) {
      throw StateError(
        'Plusieurs fiches correspondent à cette CPS. Association bloquée.',
      );
    }
    return matches.firstOrNull;
  }

  static Future<PractitionerCpsProposal> _prepare(
    DatabaseExecutor db,
    PractitionerCpsReading reading,
    String? target,
  ) async {
    reading.check();
    final matches = await _matches(db, reading.profile.nationalId);
    if (matches.any((id) => id != target)) {
      throw StateError(
        'Cette CPS correspond déjà à une autre fiche. Aucun auteur ni identifiant ne sera remplacé.',
      );
    }
    Map<String, Object?>? existing, previous, previousDates;
    if (target != null) {
      final rows = await db.query(
        'practitioners',
        where: 'practitioner_id=?',
        whereArgs: [target],
      );
      if (rows.length != 1 ||
          rows.single['is_active'] != 1 ||
          rows.single['archived_at'] != null) {
        throw StateError('La fiche du kiné est absente ou inactive.');
      }
      existing = rows.single;
      final id = (existing['professional_id'] as String? ?? '').trim();
      previous = await stored(db, target);
      previousDates = await storedDates(db, target);
      if (id.isNotEmpty && !sameIdentifier(id, reading.profile.nationalId) ||
          previous != null &&
              previous['national_id'] != reading.profile.nationalId) {
        throw StateError(
          'La CPS ne correspond pas à l’identifiant du kiné sélectionné. Association bloquée.',
        );
      }
    }
    return PractitionerCpsProposal._(
      reading,
      target ?? const Uuid().v4(),
      existing,
      previous,
      previousDates,
    );
  }

  Future<PractitionerCpsProposal> prepare(
    PractitionerCpsReading reading,
    String? target,
  ) async => _prepare(await database(), reading, target);

  Future<String> confirm(
    PractitionerCpsProposal proposal, {
    CpsTargetCheck? checkTarget,
    PractitionerCpsDates? dates,
  }) async {
    final db = await database();
    return db.transaction((tx) async {
      final fresh = await _prepare(
        tx,
        proposal.reading,
        proposal.existing == null ? null : proposal.practitionerId,
      );
      if (jsonEncode(fresh.existing) != jsonEncode(proposal.existing) ||
          jsonEncode(fresh.previous) != jsonEncode(proposal.previous) ||
          jsonEncode(fresh.previousDates) !=
              jsonEncode(proposal.previousDates)) {
        throw StateError(
          'La fiche a changé pendant la confirmation. Reprenez son association.',
        );
      }
      await checkTarget?.call(tx, proposal.practitionerId);
      final profile = proposal.reading.profile;
      final values = <String, Object?>{
        'first_name': profile.givenName,
        'last_name': profile.familyName,
        'professional_id':
            (proposal.existing?['professional_id'] as String?)
                    ?.trim()
                    .isNotEmpty ==
                true
            ? proposal.existing!['professional_id']
            : profile.nationalId,
        'updated_at': now().millisecondsSinceEpoch,
      };
      if (proposal.existing == null) {
        await tx.insert('practitioners', {
          ...values,
          'practitioner_id': proposal.practitionerId,
          'display_name': proposal.label,
          'is_active': 1,
          'created_at': now().millisecondsSinceEpoch,
        });
      } else {
        // Keep display alias, contacts, local key and links to existing reports.
        await tx.update(
          'practitioners',
          values,
          where: 'practitioner_id=?',
          whereArgs: [proposal.practitionerId],
        );
      }
      final row = <String, Object?>{
        'practitioner_id': proposal.practitionerId,
        'national_id': profile.nationalId,
        'profile_json': proposal.reading.encoded,
        'profile_hash': proposal.reading.digest,
        'read_at': proposal.reading.readAt.millisecondsSinceEpoch,
        'revision': (proposal.previous?['revision'] as int? ?? 0) + 1,
        'provenance': 'cps_local_read',
      };
      if (proposal.previous == null) {
        await tx.insert('practitioner_cps_profiles', row);
      } else {
        await tx.update(
          'practitioner_cps_profiles',
          row,
          where: 'practitioner_id=?',
          whereArgs: [proposal.practitionerId],
        );
      }
      await _writeDates(
        tx,
        proposal.practitionerId,
        proposal.reading,
        dates ?? PractitionerCpsDates(),
        proposal.previousDates,
      );
      return proposal.practitionerId;
    });
  }

  /// A saved reading must still agree with the local person and selected practice.
  static Future<Map<String, Object?>?> verifyContext(
    DatabaseExecutor db,
    Map<String, Object?> practitioner,
    Map data,
  ) async {
    final hasBinding = [
      'cpsProfileHash',
      'cpsReadAt',
      'cpsSituationNumber',
      'cpsIssueDate',
      'cpsDatesRevision',
    ].any((k) => (data[k] as String? ?? '').isNotEmpty);
    final row = await stored(db, practitioner['practitioner_id'] as String);
    if (!hasBinding) {
      if (row != null) {
        throw StateError(
          'Préremplissez le contexte à partir des données CPS enregistrées pour ce kiné.',
        );
      }
      return null;
    }
    if (row == null) {
      throw StateError('Les données CPS de ce contexte sont absentes.');
    }
    final reading = PractitionerCpsReading.fromStored(row);
    final number = int.tryParse(data['cpsSituationNumber'] as String? ?? '');
    if (!reading.profile.situations.any((s) => s.number == number)) {
      throw StateError(
        'La situation n’existe plus dans la lecture CPS enregistrée.',
      );
    }
    final expected = reading.contextValues(number!);
    if (expected.entries.any((e) => data[e.key] != e.value) ||
        !sameIdentifier(
          (practitioner['professional_id'] as String? ?? '').trim(),
          reading.profile.nationalId,
        ) ||
        practitioner['first_name'] != reading.profile.givenName ||
        practitioner['last_name'] != reading.profile.familyName) {
      throw StateError(
        'La fiche du kiné, la lecture CPS ou sa situation ont changé. Préremplissez à nouveau le contexte.',
      );
    }
    final dateRow = await storedDates(
      db,
      practitioner['practitioner_id'] as String,
    );
    // Legacy contexts keep their declarations until dates are explicitly recorded.
    if (dateRow != null || (data['cpsDatesRevision'] ?? '') != '') {
      final dates = datesFromStored(reading, dateRow);
      if (dates
          .contextValues(number)
          .entries
          .any((e) => data[e.key] != e.value)) {
        throw StateError(
          'Les dates déclarées ont changé. Préremplissez à nouveau la situation depuis la fiche du kiné.',
        );
      }
    }
    return row;
  }
}

import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:path/path.dart' as p;
import 'package:intl/date_symbol_data_local.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/features/kobus/kobus_identity.dart';
import 'package:abak_desktop_companion/features/kobus/kobus_models.dart';
import 'package:abak_desktop_companion/features/kobus/kobus_preparation.dart';
import 'package:abak_desktop_companion/features/kobus/kobus_import_service.dart';
import 'package:abak_desktop_companion/features/kobus/kobus_report.dart';
import 'package:abak_desktop_companion/generated/l10n.dart';

// All identities and documents in these tests are synthetic.
Uint8List workbook({
  String name = 'Martin',
  String first = 'Camille',
  String date = '19800229',
  String extra = '',
  bool sharedStrings = false,
}) {
  final a = Archive();
  a.add(
    ArchiveFile.string(
      'xl/workbook.xml',
      '<workbook xmlns:r="relationships"><sheets><sheet name="Informations patient" r:id="rId1"/></sheets></workbook>',
    ),
  );
  a.add(
    ArchiveFile.string(
      'xl/_rels/workbook.xml.rels',
      '<Relationships><Relationship Id="rId1" Target="worksheets/sheet1.xml"/></Relationships>',
    ),
  );
  final data = {
    'Nom de famille': name,
    'Prénom': first,
    'Date de naissance': date,
    'Sexe': 'H',
    'Profession': 'Architecte',
    'NIR': 'invalide',
    'Loisirs': 'Natation',
  };
  final cells = <String>[], strings = <String>[];
  var row = 0;
  String escape(String v) => v.replaceAll('&', '&amp;').replaceAll('<', '&lt;');
  for (final e in data.entries) {
    row++;
    String cell(String column, String value) {
      if (sharedStrings) {
        strings.add(value);
        return '<c r="$column$row" t="s"><v>${strings.length - 1}</v></c>';
      }
      return '<c r="$column$row" t="inlineStr"><is><t>${escape(value)}</t></is></c>';
    }

    cells.add('<row r="$row">${cell('A', e.key)}${cell('B', e.value)}</row>');
  }
  a.add(
    ArchiveFile.string(
      'xl/worksheets/sheet1.xml',
      '<worksheet><sheetData>${cells.join()}$extra</sheetData></worksheet>',
    ),
  );
  if (sharedStrings) {
    a.add(
      ArchiveFile.string(
        'xl/sharedStrings.xml',
        '<sst>${strings.map((v) => '<si><t>${escape(v)}</t></si>').join()}</sst>',
      ),
    );
  }
  return Uint8List.fromList(ZipEncoder().encode(a));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  late Directory temp;
  late Database db;
  late KobusImportService service;
  final preparations = <KobusPreparation>[];
  setUp(() async {
    temp = await Directory.systemTemp.createTemp('kobus_test_');
    db = await DatabaseService.openDatabaseFile(p.join(temp.path, 'test.db'));
    service = KobusImportService(
      database: db,
      storageRoot: p.join(temp.path, 'archives'),
    );
    await S.load(const Locale('fr', 'FR'));
    await initializeDateFormatting('fr_FR');
  });
  tearDown(() async {
    for (final prepared in preparations) {
      await disposeKobus(prepared);
    }
    preparations.clear();
    await db.close();
    await temp.delete(recursive: true);
  });
  Future<KobusPreparation> prepare(
    Map<String, Uint8List?> entries, {
    bool shared = false,
    bool? windowsPaths,
  }) async {
    final archive = Archive();
    for (final e in entries.entries) {
      archive.add(
        e.value == null
            ? ArchiveFile.directory(e.key)
            : ArchiveFile.bytes(e.key, e.value!),
      );
    }
    final file = File(p.join(temp.path, 'synthetic.zip'));
    await file.writeAsBytes(ZipEncoder().encode(archive));
    final preparation = await prepareKobus(
      file.path,
      windowsPaths: windowsPaths,
    );
    preparations.add(preparation);
    await findKobusCandidates(
      preparation,
      shared,
      existing: (await db.query('patients'))
          .map(
            (r) => KobusIdentity(
              r['last_name'] as String,
              r['first_name'] as String,
              r['birth_date'] as String?,
            ).patient(r['patient_id'] as String),
          )
          .toList(),
    );
    return preparation;
  }

  Future<KobusPreparation> prepareEntries(List<ArchiveFile> entries) async {
    // Archive.add replaces same-name entries. Feed ZipEncoder directly to
    // reproduce real ZIPs that contain repeated central-directory records.
    final output = OutputMemoryStream();
    final encoder = ZipEncoder()..startEncode(output);
    for (final entry in entries) {
      encoder.add(entry);
    }
    encoder.endEncode();
    final file = File(p.join(temp.path, 'repeated.zip'));
    await file.writeAsBytes(output.getBytes());
    final result = await prepareKobus(file.path);
    preparations.add(result);
    await findKobusCandidates(result, false, existing: []);
    return result;
  }

  test(
    'identical repeated ZIP entries are verified and reported without losing other files',
    () async {
      final excel = workbook();
      final payload = Uint8List.fromList([1, 4, 9, 16]);
      final prepared = await prepareEntries([
        ArchiveFile.directory('Export/Mes patients/A/'),
        ArchiveFile.directory('Export/Mes patients/A/'),
        ArchiveFile.bytes('Export/Mes patients/A/a.xlsx', excel),
        ArchiveFile.bytes('Export/Mes patients/A/a.xlsx', excel),
        ArchiveFile.bytes('Export/Mes patients/A/a.xlsx', excel),
        ArchiveFile.bytes('Export/Mes patients/A/Autres/image.bin', payload),
        ArchiveFile.bytes('Export/Mes patients/A/Autres/image.bin', payload),
        ArchiveFile.bytes('Export/Mes patients/A/Autres/other.bin', payload),
        ArchiveFile.directory('Export/Mes patients/A/Vide/'),
        ArchiveFile.directory('Export/Mes patients/A/Vide/'),
      ]);
      final folder = prepared.folders.single;
      expect(folder.rejection, isNull);
      expect(
        folder.identity!.warnings.join(),
        contains('3 occurrences vérifiées'),
      );
      final run = await service.import(prepared, includeShared: false);
      final row = (await service.items(run)).single;
      expect(row['status'], 'imported');
      expect(row['warnings'], contains('Entrée ZIP répétée'));
      final copied = row['storage_path'] as String;
      expect(await File(p.join(copied, 'a.xlsx')).readAsBytes(), excel);
      expect(
        await File(p.join(copied, 'Autres/image.bin')).readAsBytes(),
        payload,
      );
      expect(
        await File(p.join(copied, 'Autres/other.bin')).readAsBytes(),
        payload,
      );
      expect(await Directory(p.join(copied, 'Vide')).exists(), isTrue);
    },
  );

  test(
    'conflicting repeated Excel rejects only its patient and never picks first or last',
    () async {
      final first = workbook();
      final prepared = await prepareEntries([
        ArchiveFile.bytes('Mes patients/A/a.xlsx', first),
        ArchiveFile.bytes('Mes patients/A/a.xlsx', workbook(name: 'Different')),
        ArchiveFile.bytes('Mes patients/A/a.xlsx', first),
        ArchiveFile.bytes('Mes patients/B/b.xlsx', workbook(name: 'Durand')),
      ]);
      expect(prepared.folders.first.rejection, contains('contenus différents'));
      final run = await service.import(prepared, includeShared: false);
      expect((await service.items(run)).map((r) => r['status']), [
        'rejected',
        'imported',
      ]);
      expect(await db.query('patients'), hasLength(1));
    },
  );

  test(
    'case and file-directory conflicts remain per-folder rejections',
    () async {
      final prepared = await prepareEntries([
        ArchiveFile.bytes('Mes patients/A/a.xlsx', workbook()),
        ArchiveFile.bytes('Mes patients/A/A.xlsx', workbook()),
        ArchiveFile.bytes('Mes patients/B/b.xlsx', workbook()),
        ArchiveFile.string('Mes patients/B/Autres', 'file'),
        ArchiveFile.directory('Mes patients/B/Autres/'),
        ArchiveFile.bytes('Mes patients/C/c.xlsx', workbook()),
        ArchiveFile.string('Mes patients/C/Autres/a.txt', 'a'),
        ArchiveFile.string('Mes patients/C/autres/b.txt', 'b'),
        ArchiveFile.bytes('Mes patients/D/d.xlsx', workbook(name: 'Durand')),
      ]);
      expect(prepared.folders.where((f) => f.rejection != null), hasLength(3));
      final run = await service.import(prepared, includeShared: false);
      expect(
        (await service.items(run)).where((r) => r['status'] == 'imported'),
        hasLength(1),
      );
    },
  );

  test('repeated link cannot hide behind a valid same-name file', () async {
    final prepared = await prepareEntries([
      ArchiveFile.bytes('Mes patients/A/a.xlsx', workbook()),
      ArchiveFile.string('Mes patients/A/document', 'safe'),
      ArchiveFile.string('Mes patients/A/document', '/tmp')..mode = 0xa1ff,
      ArchiveFile.bytes('Mes patients/B/b.xlsx', workbook(name: 'Durand')),
    ]);
    expect(prepared.folders.first.rejection, contains('lien'));
    expect(prepared.folders.last.rejection, isNull);
  });

  test('strict dates and absence placeholders', () {
    for (final date in ['19800229', '1980-02-29', '29/02/1980']) {
      expect(kobusDate(date), '1980-02-29');
    }
    for (final date in [
      '19000229',
      '19810229',
      '20260431',
      '1980-0229',
      '198002-29',
      '01/02/80',
      '99991231',
      '0',
      'non renseigné',
    ]) {
      expect(kobusDate(date), isNull, reason: date);
    }
    expect(missingKobus('  Non renseigné '), isTrue);
  });
  test('Excel labels, shared strings, whitespace, optional fields', () {
    for (final shared in [false, true]) {
      final identity = KobusExcel.identity(
        KobusExcel.fields(
          workbook(
            name: '  Martin  ',
            first: ' Camille ',
            sharedStrings: shared,
          ),
        ),
      );
      expect(identity.lastName, 'Martin');
      expect(identity.firstName, 'Camille');
      expect(identity.sex, 'M');
      expect(identity.nir, isNull);
      expect(identity.warnings, hasLength(1));
      expect(identity.profession, 'Architecte');
    }
  });
  test(
    'missing and invalid dates create patients with NULL birth date',
    () async {
      final prepared = await prepare({
        'Mes patients/A/a.xlsx': workbook(date: ''),
        'Mes patients/B/b.xlsx': workbook(name: 'Durand', date: 'inconnue'),
        'Mes patients/C/c.xlsx': workbook(name: 'Petit', date: '19810229'),
      });
      expect(prepared.folders.every((f) => f.rejection == null), isTrue);
      final run = await service.import(prepared, includeShared: false);
      expect(
        (await service.items(run)).every((r) => r['status'] == 'imported'),
        isTrue,
      );
      final patients = await db.query('patients');
      expect(patients, hasLength(3));
      expect(patients.every((p) => p['birth_date'] == null), isTrue);
    },
  );

  test(
    'existing name is rejected regardless of date and cannot be forced to create',
    () async {
      final original = KobusIdentity(
        'MARTIN',
        'Camille',
        '1990-01-01',
      ).patient('existing').toMap();
      await db.insert('patients', original);
      final prepared = await prepare({
        'Mes patients/A/a.xlsx': workbook(date: ''),
      });
      expect(prepared.folders.single.rejection, contains('Nom et prénom'));
      prepared.folders.single.decision = KobusDecision.create;
      final run = await service.import(prepared, includeShared: false);
      expect((await service.items(run)).single['status'], 'rejected');
      expect((await db.query('patients')).single, original);
      expect(await db.query('kobus_archives'), isEmpty);
    },
  );

  test('invalid and ambiguous identities are rejected', () {
    for (final bytes in [
      workbook(name: 'N/A'),
      workbook(name: ''),
      workbook(first: ''),
    ]) {
      expect(
        () => KobusExcel.identity(KobusExcel.fields(bytes)),
        throwsFormatException,
      );
    }
    expect(
      () => KobusExcel.fields(
        workbook(
          extra:
              '<row><c r="A99" t="inlineStr"><is><t>Prénom</t></is></c></row>',
        ),
      ),
      throwsFormatException,
    );
    expect(
      () => KobusExcel.fields(Uint8List.fromList([1, 2, 3])),
      throwsA(anything),
    );
  });
  test('duplicates use only normalized last and first names', () {
    final identity = KobusIdentity('Martin', 'Camille', '1980-02-29');
    expect(
      kobusMatch(
        identity,
        KobusIdentity('MARTIN', 'Camille', '1990-01-01').patient('a'),
      ),
      contains('Nom et prénom'),
    );
    expect(
      kobusMatch(
        identity,
        KobusIdentity('Martim', 'Camile', '1980-02-29').patient('b'),
      ),
      isNull,
    );
    expect(
      kobusMatch(
        identity,
        KobusIdentity('Autre', 'Personne', '1980-02-29').patient('c'),
      ),
      isNull,
    );
    expect(normalizeKobusName('Éloïse—D’Arc'), 'ELOISE D ARC');
    final base = '1800275123456';
    final nir =
        '$base${(97 - int.parse(base) % 97).toString().padLeft(2, '0')}';
    expect(kobusNir(nir), nir);
    expect(
      kobusMatch(
        KobusIdentity('X', 'Y', '1980-01-01', nir: nir),
        KobusIdentity('Z', 'W', '1970-01-01', nir: nir).patient('x'),
      ),
      isNull,
    );
  });
  test(
    'standalone patient sheets create patients without attachments',
    () async {
      final first = workbook();
      final second = workbook(name: 'Durand');
      final prepared = await prepare({
        'Export/Mes patients/fiche.xlsx': first,
        'Export/Patients partages/Kiné/global_patients_2.xlsx': second,
      }, shared: true);
      expect(prepared.folders, hasLength(2));
      for (final folder in prepared.folders) {
        expect(folder.rejection, isNull);
        expect(folder.identity!.warnings, contains('Aucun document joint'));
        expect(folder.manifest, hasLength(1));
      }
      expect(
        prepared.folders.where((f) => f.shared).single.practitioner,
        'Kiné',
      );
      final run = await service.import(prepared, includeShared: true);
      final items = await service.items(run);
      expect(items.every((row) => row['status'] == 'imported'), isTrue);
      expect(
        items.every(
          (row) => (row['warnings'] as String).contains('Aucun document joint'),
        ),
        isTrue,
      );
      expect(await db.query('patients'), hasLength(2));
      final copies = Directory(p.join(temp.path, 'archives'))
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.endsWith('.xlsx'))
          .toList();
      expect(copies, hasLength(2));
      expect(
        copies.map((f) => sha256.convert(f.readAsBytesSync()).toString()),
        containsAll([
          sha256.convert(first).toString(),
          sha256.convert(second).toString(),
        ]),
      );
    },
  );

  test(
    'identity-only folder reports no attachments but a PDF does not',
    () async {
      final prepared = await prepare({
        'Mes patients/A/a.xlsx': workbook(),
        'Mes patients/B/b.xlsx': workbook(name: 'Durand'),
        'Mes patients/B/document.pdf': Uint8List.fromList([1, 2, 3]),
      });
      expect(
        prepared.folders.first.identity!.warnings,
        contains('Aucun document joint'),
      );
      expect(
        prepared.folders.last.identity!.warnings,
        isNot(contains('Aucun document joint')),
      );
    },
  );

  test(
    'unreadable standalone sheet is reported instead of silently skipped',
    () async {
      final prepared = await prepare({
        'Patients partagés/Kiné/global_patients_2.xlsx': Uint8List.fromList([
          1,
          2,
        ]),
        'Mes patients/A/a.xlsx': workbook(),
      }, shared: true);
      expect(prepared.folders, hasLength(2));
      expect(prepared.folders.where((f) => f.rejection != null), hasLength(1));
      final run = await service.import(prepared, includeShared: true);
      expect(
        (await service.items(run)).map((r) => r['status']),
        containsAll(['imported', 'rejected']),
      );
      expect(await db.query('patients'), hasLength(1));
    },
  );

  test(
    'standalone file cannot mask a directory or conflicting repeated sheet',
    () async {
      final prepared = await prepareEntries([
        ArchiveFile.bytes('Mes patients/collision.xlsx', workbook()),
        ArchiveFile.bytes('Mes patients/collision.xlsx/fiche.xlsx', workbook()),
        ArchiveFile.bytes('Mes patients/repeated.xlsx', workbook()),
        ArchiveFile.bytes(
          'Mes patients/repeated.xlsx',
          workbook(name: 'Durand'),
        ),
      ]);
      expect(prepared.folders, hasLength(2));
      expect(prepared.folders.every((f) => f.rejection != null), isTrue);
    },
  );

  test('wrapper, own/shared option, unknown unrelated folders', () async {
    final prepared = await prepare({
      'Export/Mes patients/A/a.xlsx': workbook(),
      'Export/Patients partages/Kiné/B/b.xlsx': workbook(name: 'Durand'),
      'Export/Autre/C/c.xlsx': workbook(),
    });
    expect(prepared.folders, hasLength(2));
    expect(prepared.hasShared, isTrue);
    final run = await service.import(prepared, includeShared: false);
    expect(
      (await service.items(run)).map((r) => r['status']),
      containsAll(['imported', 'skipped']),
    );
    expect(await db.query('patients'), hasLength(1));
  });
  test(
    'missing Excel, multiple Excel, missing name do not create patients',
    () async {
      final prepared = await prepare({
        'Mes patients/A/document.pdf': Uint8List.fromList([1]),
        'Mes patients/B/a.xlsx': workbook(),
        'Mes patients/B/b.xlsx': workbook(),
        'Mes patients/C/c.xlsx': workbook(name: ''),
      });
      final run = await service.import(prepared, includeShared: false);
      expect(
        (await service.items(run)).every((r) => r['status'] == 'rejected'),
        isTrue,
      );
      expect(await db.query('patients'), isEmpty);
      expect(await db.query('kobus_archives'), isEmpty);
    },
  );
  test(
    'copy preserves names, bytes, empty dirs, profession, source independence and no clinical records',
    () async {
      final payload = Uint8List.fromList(List.generate(256, (i) => i));
      final prepared = await prepare({
        'Mes patients/Source/a.xlsx': workbook(),
        'Mes patients/Source/Autres/été%20#.bin': payload,
        'Mes patients/Source/Vide/': null,
      });
      expect(await db.query('patients'), isEmpty);
      final run = await service.import(prepared, includeShared: false);
      final item = (await service.items(run)).single;
      expect(item['status'], 'imported');
      final path = item['storage_path'] as String;
      await disposeKobus(prepared);
      await File(p.join(temp.path, 'synthetic.zip')).delete();
      expect(
        await File(p.join(path, 'Autres', 'été%20#.bin')).readAsBytes(),
        payload,
      );
      expect(await Directory(p.join(path, 'Vide')).exists(), isTrue);
      expect(
        (await db.query('patient_attributes')).single['attribute_value'],
        'Architecte',
      );
      expect(await db.query('care_episodes'), isEmpty);
      expect(await db.query('episode_documents'), isEmpty);
      expect(
        await service.patientDirectory(item['patient_id'] as String),
        isNotEmpty,
      );
    },
  );
  test(
    'all same-lot suspicions require decisions; multiple archives remain separate',
    () async {
      final prepared = await prepare({
        'Mes patients/A/a.xlsx': workbook(),
        'Patients partagés/Kiné/B/b.xlsx': workbook(),
      }, shared: true);
      final first = prepared.folders.first, last = prepared.folders.last;
      expect(last.decision, KobusDecision.unresolved);
      expect(last.candidates.single.sourceItemId, first.id);
      last.decision = KobusDecision.attach;
      last.target = last.candidates.single;
      final run = await service.import(prepared, includeShared: true);
      expect(await db.query('patients'), hasLength(1));
      expect(await db.query('kobus_archives'), hasLength(2));
      expect(
        (await service.items(run)).where((r) => r['created_patient'] == 1),
        hasLength(1),
      );
      final paths = (await db.query(
        'kobus_archives',
      )).map((r) => r['storage_path']).toSet();
      expect(paths, hasLength(2));
    },
  );
  test(
    'forced creation cannot duplicate a name created earlier in the lot',
    () async {
      final prepared = await prepare({
        'Mes patients/A/a.xlsx': workbook(),
        'Mes patients/B/b.xlsx': workbook(),
      });
      prepared.folders.last.decision = KobusDecision.create;
      final run = await service.import(prepared, includeShared: false);
      expect(await db.query('patients'), hasLength(1));
      expect(
        (await service.items(run)).map((r) => r['status']),
        containsAll(['imported', 'skipped']),
      );
    },
  );
  test('unresolved and excluded folders remain aside', () async {
    final prepared = await prepare({
      'Mes patients/A/a.xlsx': workbook(),
      'Mes patients/B/b.xlsx': workbook(),
      'Mes patients/C/c.xlsx': workbook(name: 'Durand'),
    });
    prepared.folders.last.decision = KobusDecision.skip;
    final run = await service.import(prepared, includeShared: false);
    expect(
      (await service.items(run)).where((r) => r['status'] == 'skipped'),
      hasLength(2),
    );
  });
  test(
    'existing archived patient is never changed; previous import is blocked',
    () async {
      final patient = KobusIdentity(
        'Martin',
        'Camille',
        '1980-02-29',
        profession: 'Autre',
      ).patient('existing');
      final original = {
        ...patient.toMap(),
        'archived_at': 123,
        'nir': 'preserved',
      };
      await db.insert('patients', original);
      final prepared = await prepare({'Mes patients/A/a.xlsx': workbook()});
      await findKobusCandidates(prepared, false, existing: [patient]);
      final folder = prepared.folders.single;
      folder.decision = KobusDecision.attach;
      folder.target = folder.candidates.single;
      await service.import(prepared, includeShared: false);
      expect((await db.query('patients')).single, original);
      final again = await prepare({'Mes patients/A/a.xlsx': workbook()});
      again.folders.single.decision = KobusDecision.attach;
      again.folders.single.target = again.folders.single.candidates.single;
      final run = await service.import(again, includeShared: false);
      expect((await service.items(run)).single['status'], 'rejected');
      expect(await db.query('kobus_archives'), isEmpty);
    },
  );
  test(
    'copy corruption rolls back patient and archive, preserving other successes',
    () async {
      final prepared = await prepare({
        'Mes patients/A/a.xlsx': workbook(),
        'Mes patients/B/b.xlsx': workbook(name: 'Durand'),
      });
      final importer = KobusImportService(
        database: db,
        storageRoot: p.join(temp.path, 'archives'),
        beforeCopy: (folder) async {
          if (folder == prepared.folders.last) {
            await File(
              p.join(folder.directory, 'b.xlsx'),
            ).writeAsString('corrupted');
          }
        },
      );
      final run = await importer.import(prepared, includeShared: false);
      expect((await service.items(run)).map((r) => r['status']), [
        'imported',
        'failed',
      ]);
      expect(await db.query('patients'), hasLength(1));
      expect(await db.query('kobus_archives'), hasLength(1));
    },
  );
  test('transaction failure leaves no new orphan patient', () async {
    final prepared = await prepare({'Mes patients/A/a.xlsx': workbook()});
    await db.execute(
      "CREATE TRIGGER fail_kobus BEFORE INSERT ON kobus_archives BEGIN SELECT RAISE(ABORT, 'synthetic failure'); END",
    );
    final run = await service.import(prepared, includeShared: false);
    expect((await service.items(run)).single['status'], 'failed');
    expect(await db.query('patients'), isEmpty);
  });
  test(
    'stop at folder boundary persists partial report and survives reopening',
    () async {
      final prepared = await prepare({
        'Mes patients/A/a.xlsx': workbook(),
        'Mes patients/B/b.xlsx': workbook(name: 'Durand'),
      });
      final run = await service.import(
        prepared,
        includeShared: false,
        progress: (done, total) {
          if (done == 1) service.stopRequested = true;
        },
      );
      expect((await service.items(run)).map((r) => r['status']), [
        'imported',
        'interrupted',
      ]);
      await db.close();
      db = await DatabaseService.openDatabaseFile(p.join(temp.path, 'test.db'));
      service = KobusImportService(
        database: db,
        storageRoot: p.join(temp.path, 'archives'),
      );
      expect((await service.history()).single['status'], 'interrupted');
      expect(await service.items(run), hasLength(2));
    },
  );
  test(
    'unsafe paths and incompatible entries are never silently copied',
    () async {
      for (final path in [
        '../escape',
        '/absolute',
        'Mes patients/A/../../escape',
        'C:/escape',
        'Mes patients/A/C:escape',
        'Mes patients/A/..\\escape',
      ]) {
        await expectLater(prepare({path: workbook()}), throwsFormatException);
      }
      final archive = Archive()
        ..add(ArchiveFile.bytes('Mes patients/A/a.xlsx', workbook()))
        ..add(ArchiveFile.string('Mes patients/A/link', '/tmp')..mode = 0xa1ff);
      final path = p.join(temp.path, 'link.zip');
      await File(path).writeAsBytes(ZipEncoder().encode(archive));
      final prepared = await prepareKobus(path);
      preparations.add(prepared);
      expect(prepared.folders.single.rejection, contains('lien'));
    },
  );
  test(
    'POSIX trailing spaces and dots survive preparation and archive copy unchanged',
    () async {
      final payload = Uint8List.fromList([4, 8, 15, 16, 23, 42]);
      final prepared = await prepare(
        {
          'Export/Mes patients/Patient fictif /fiche.xlsx': workbook(),
          'Export/Mes patients/Patient fictif /Autres /document.': payload,
          'Export/Patients partagés/Kiné fictif /Autre patient./fiche.xlsx':
              workbook(name: 'Durand'),
        },
        shared: true,
        windowsPaths: false,
      );
      expect(prepared.folders.every((f) => f.rejection == null), isTrue);
      final run = await service.import(prepared, includeShared: true);
      final items = await service.items(run);
      expect(items.every((r) => r['status'] == 'imported'), isTrue);
      final own = items.singleWhere((r) => r['shared'] == 0);
      expect(p.basename(own['storage_path'] as String), 'Patient fictif ');
      expect(
        await File(
          p.join(own['storage_path'] as String, 'Autres ', 'document.'),
        ).readAsBytes(),
        payload,
      );
      expect(
        prepared.folders.singleWhere((f) => f.shared).practitioner,
        'Kiné fictif ',
      );
    },
    skip: Platform.isWindows,
  );

  test(
    'Windows incompatible names reject only affected folders without trimming',
    () async {
      final prepared = await prepare({
        'Export/Mes patients/Patient fictif /fiche.xlsx': workbook(),
        'Export/Mes patients/Autre/fiche.xlsx': workbook(),
        'Export/Mes patients/Autre/CON.txt': Uint8List.fromList([1]),
        'Export/Mes patients/Flux/fiche.xlsx': workbook(),
        'Export/Mes patients/Flux/file:stream': Uint8List.fromList([2]),
        'Export/Mes patients/Valide/fiche.xlsx': workbook(name: 'Durand'),
      }, windowsPaths: true);
      expect(prepared.folders.where((f) => f.rejection != null), hasLength(3));
      expect(
        prepared.folders
            .where((f) => f.rejection != null)
            .every((f) => f.rejection!.contains('Windows')),
        isTrue,
      );
      final run = await service.import(prepared, includeShared: false);
      expect(
        (await service.items(run)).where((r) => r['status'] == 'imported'),
        hasLength(1),
      );
      expect(
        (await service.items(run)).where((r) => r['status'] == 'rejected'),
        hasLength(3),
      );
    },
  );

  test('PDF and report retain rejection provenance and accents', () async {
    final prepared = await prepare({
      'Patients partagés/Kiné/B/b.xlsx': workbook(first: ''),
    }, shared: true);
    final run = await service.import(prepared, includeShared: true);
    final text = kobusReportText(
      (await service.history()).single,
      await service.items(run),
      'rejected',
      S.current,
    );
    expect(text, contains('Kiné'));
    expect(text, contains('Nom ou prénom'));
    expect(text, contains('Martin'));
    final bytes = await kobusReportPdf(
      text,
      fontData: ByteData.sublistView(
        await File('assets/fonts/DejaVuSans.ttf').readAsBytes(),
      ),
    );
    expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
  });
  test(
    'recovery removes incomplete copy and temporary data, keeps committed archive',
    () async {
      final prepared = await prepare({'Mes patients/A/a.xlsx': workbook()});
      final run = await service.import(prepared, includeShared: false);
      final original = (await service.items(run)).single;
      final incomplete = p.join(
        temp.path,
        'archives',
        'missing',
        'partial',
        'Source',
      );
      await Directory(incomplete).create(recursive: true);
      await File(p.join(incomplete, 'partial.bin')).writeAsString('incomplete');
      await db.update(
        'kobus_runs',
        {'status': 'running'},
        where: 'run_id = ?',
        whereArgs: [run],
      );
      await db.insert('kobus_items', {
        'item_id': 'partial',
        'run_id': run,
        'source_path': 'Mes patients/Partial',
        'shared': 0,
        'identity_label': 'Synthétique',
        'status': 'pending',
        'reason': '',
        'warnings': '',
        'storage_path': incomplete,
      });
      await service.recover();
      expect(await Directory(incomplete).exists(), isFalse);
      expect(await Directory(prepared.temporaryPath).exists(), isFalse);
      expect(
        await Directory(original['storage_path'] as String).exists(),
        isTrue,
      );
      expect(
        (await service.items(run)).map((r) => r['status']),
        containsAll(['imported', 'interrupted']),
      );
      expect(await db.query('patients'), hasLength(1));
    },
  );

  test(
    'new candidate after preview is left aside rather than silently duplicated',
    () async {
      final prepared = await prepare({'Mes patients/A/a.xlsx': workbook()});
      await db.insert(
        'patients',
        KobusIdentity(
          'Martin',
          'Camille',
          '1980-02-29',
        ).patient('new-concurrent').toMap(),
      );
      final run = await service.import(prepared, includeShared: false);
      expect((await service.items(run)).single['status'], 'skipped');
      expect(await db.query('patients'), hasLength(1));
      expect(await db.query('kobus_archives'), isEmpty);
    },
  );

  test('attachment to excluded same-lot target stays aside', () async {
    final prepared = await prepare({
      'Mes patients/A/a.xlsx': workbook(),
      'Mes patients/B/b.xlsx': workbook(),
    });
    prepared.folders.first.decision = KobusDecision.skip;
    prepared.folders.last.decision = KobusDecision.attach;
    prepared.folders.last.target = prepared.folders.last.candidates.single;
    final run = await service.import(prepared, includeShared: false);
    expect(
      (await service.items(run)).every((r) => r['status'] == 'skipped'),
      isTrue,
    );
    expect(await db.query('patients'), isEmpty);
  });

  test(
    'PDF supports a full export of rejections and long source paths',
    () async {
      final text = List.generate(
        960,
        (i) =>
            'Dossier $i — Élodie\n${List.filled(220, 'M').join()}\nMotif : date invalide.',
      ).join('\n');
      final bytes = await kobusReportPdf(
        text,
        fontData: ByteData.sublistView(
          await File('assets/fonts/DejaVuSans.ttf').readAsBytes(),
        ),
      );
      expect(bytes.length, greaterThan(10000));
      expect(ascii.decode(bytes.take(5).toList()), '%PDF-');
    },
  );

  test(
    'optional malformed Excel cell warns without rejecting mandatory identity',
    () {
      final archive = ZipDecoder().decodeBytes(workbook());
      final sheet = archive.findFile('xl/worksheets/sheet1.xml')!;
      final xml = utf8
          .decode(sheet.content)
          .replaceFirst(
            '<c r="B4" t="inlineStr"><is><t>H</t></is></c>',
            '<c r="B4" t="e"><v>#VALUE!</v></c>',
          );
      archive.add(ArchiveFile.string(sheet.name, xml));
      final identity = KobusExcel.identity(
        KobusExcel.fields(Uint8List.fromList(ZipEncoder().encode(archive))),
      );
      expect(identity.sex, 'U');
      expect(identity.warnings.join(), contains('Sexe illisible'));
    },
  );

  test('migration from schema 30 preserves existing data', () async {
    await db.insert(
      'patients',
      KobusIdentity(
        'Migration',
        'Test',
        '1980-01-01',
      ).patient('preserved').toMap(),
    );
    for (final table in ['kobus_archives', 'kobus_items', 'kobus_runs']) {
      await db.execute('DROP TABLE $table');
    }
    await db.setVersion(30);
    await db.close();
    db = await DatabaseService.openDatabaseFile(p.join(temp.path, 'test.db'));
    expect(await db.getVersion(), 31);
    expect((await db.query('patients')).single['patient_id'], 'preserved');
    expect(await db.query('kobus_runs'), isEmpty);
  });
}

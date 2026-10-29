import 'dart:convert';
import 'dart:io';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../../core/database/database_service.dart';
import '../patients/models/patient_fr_health_identity.dart';
import '../dmp_td02/td02_result.dart';
import 'dossier_reader.dart';
import 'isolated_workflow.dart';

final class FixtureIdentity implements IdentityVerifier {
  @override
  bool verifiedNir(PatientFrHealthIdentity i) =>
      i.insNumber == 'FIXTURE-NIR-NON-ROUTABLE' &&
      i.insKey == 'FIXTURE-KEY' &&
      i.insOid == 'fixture:oid:nir';
}

final class FixtureDecoder implements ClinicalDecoder {
  @override
  String report(String content) {
    try {
      final j = jsonDecode(content);
      if (j is! Map || j['fixture'] != true || j['clinical'] is! String) {
        throw const IntegrationBlocked('format_indisponible');
      }
      return j['clinical'] as String;
    } on FormatException {
      throw const IntegrationBlocked('format_indisponible');
    }
  }

  @override
  String attachment(String mime, List<int> bytes) {
    if (mime != 'application/x-abak-fixture') {
      throw const IntegrationBlocked('format_indisponible');
    }
    return bytes.isEmpty ? '' : report(utf8.decode(bytes));
  }
}

String content(String text) => jsonEncode({'fixture': true, 'clinical': text});

/// Persistent fixture workspace, never an application database.
class DossierDemo {
  DossierDemo._(this.root);
  final Directory root;
  Database? _writer, _reader;
  IntegrationJournal? _journal;
  late DossierReader reader;
  late IntegrationWorkflow workflow;
  IntegrationFakeService service = IntegrationFakeService();
  DossierSnapshot? snapshot;
  String status = 'validation_requise';
  String text = '';
  bool held = false, validated = false;
  bool closed = false;
  Database get writer => _writer!;
  IntegrationJournal get journal => _journal!;
  String get file => '${root.path}/piece.fixture';
  int get calls => service.sentVersions.length;

  static Future<DossierDemo> open(Directory directory) async {
    sqfliteFfiInit();
    directory.createSync(recursive: true);
    final root = Directory(directory.resolveSymbolicLinksSync());
    final files = IsolatedFiles(root);
    final marker = files.checked('${root.path}/simulation.json');
    final fresh = root.listSync().isEmpty;
    if (!fresh &&
        (!marker.existsSync() ||
            marker.readAsStringSync() != 'DMP-DEMO-READY-1')) {
      throw const IntegrationBlocked('stockage_bloque');
    }
    final demo = DossierDemo._(root);
    try {
      if (fresh) {
        marker.writeAsStringSync('DMP-DEMO-INITIALIZING', flush: true);
        demo._writer = await DatabaseService.openDatabaseFile(
          files.checked('${root.path}/dossier.sqlite').path,
          factory: databaseFactoryFfi,
        );
        await demo.seed();
      } else {
        for (final name in [
          'dossier.sqlite',
          'journal.sqlite',
          'temoin-non-restaure.sqlite',
        ]) {
          if (!files.checked('${root.path}/$name').existsSync()) {
            throw const IntegrationBlocked('stockage_bloque');
          }
        }
        demo._writer = await databaseFactoryFfi.openDatabase(
          files.checked('${root.path}/dossier.sqlite').path,
          options: OpenDatabaseOptions(singleInstance: false),
        );
      }
      demo._reader = await databaseFactoryFfi.openDatabase(
        files.checked('${root.path}/dossier.sqlite').path,
        options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
      );
      await demo._reader!.execute('PRAGMA query_only=ON');
      demo.reader = DossierReader(
        demo._reader!,
        files,
        FixtureDecoder(),
        FixtureIdentity(),
      );
      demo._journal = await IntegrationJournal.open(files);
      final identity = PatientFrHealthIdentity.fromMap(
        (await demo.writer.query('patient_fr_health_identity')).single,
      );
      demo.reader.checkIdentity(identity);
      final session = DateTime.now().microsecondsSinceEpoch.toString();
      demo.workflow = IntegrationWorkflow(
        demo.reader,
        demo.journal,
        demo.service,
        IntegrationContext(
          patient: 'fixture-p',
          professional: 'fixture-ps',
          structure: 'fixture-cabinet',
          identityVersion: fingerprint(identity.toMap()),
          session: session,
          checkedSession: session,
          result: const Td02Result(
            DmpState.active,
            right: ConsultationRight.valid,
          ),
        ),
      );
      await demo.refresh();
      demo.held = await demo.readHold();
      if (fresh) marker.writeAsStringSync('DMP-DEMO-READY-1', flush: true);
      return demo;
    } catch (_) {
      await demo.close();
      rethrow;
    }
  }

  Future<void> seed() async {
    await writer.insert('patients', {
      'patient_id': 'fixture-p',
      'last_name': 'FICTIF',
      'first_name': 'TEST',
      'created_at': 1,
    });
    await writer.insert('care_episodes', {
      'care_episode_id': 'fixture-e',
      'patient_id': 'fixture-p',
      'title': 'Fictif',
      'pathology_label': 'Test',
      'created_at': 1,
    });
    await writer.insert(
      'patient_fr_health_identity',
      PatientFrHealthIdentity(
        patientId: 'fixture-p',
        insNumber: 'FIXTURE-NIR-NON-ROUTABLE',
        insKey: 'FIXTURE-KEY',
        insOid: 'fixture:oid:nir',
        birthLastName: 'FICTIF',
        birthFirstNames: 'TEST',
        birthDate: '2006-10-16',
        sexCode: 'M',
        birthPlaceCode: 'FIXTURE',
        identityStatus: 'qualified',
        identityValidatedAt: 1,
        insRetrievedAt: 1,
      ).toMap(),
    );
    await writer.insert('care_episode_reports', {
      'report_id': 'fixture-r',
      'care_episode_id': 'fixture-e',
      'author_practitioner_id': 'fixture-ps',
      'title': 'Rapport fictif',
      'content_json': content('Flexion fictive : 90 degrés'),
      'status': 'saved',
      'report_date': 1,
      'created_at': 1,
    });
    await writer.insert('care_episode_notes', {
      'note_id': 'fixture-note',
      'care_episode_id': 'fixture-e',
      'note_date': 1,
      'content': 'Note fictive',
      'created_at': 1,
    });
    await writer.insert('care_episode_report_notes', {
      'report_id': 'fixture-r',
      'note_id': 'fixture-note',
    });
    await writer.insert('desktop_results', {
      'result_id': 'fixture-result',
      'care_episode_id': 'fixture-e',
      'patient_id': 'fixture-p',
      'createdAt': 1,
      'imported_at': 1,
      'exoId': 'fixture-test',
      'exportSimpleText': 'Mesure fictive',
    });
    await writer.insert('care_episode_report_tests', {
      'report_id': 'fixture-r',
      'exo_id': 'fixture-test',
    });
    await File(file).writeAsString(content('Pièce fictive'));
    await writer.insert('episode_documents', {
      'document_id': 'fixture-piece',
      'case_id': 'fixture-e',
      'title': 'Pièce',
      'file_path': file,
      'mime_type': 'application/x-abak-fixture',
      'created_at': 1,
    });
  }

  Future<void> refresh() async {
    final raw = (await writer.query(
      'care_episode_reports',
      where: 'report_id = ?',
      whereArgs: ['fixture-r'],
    )).single;
    text = FixtureDecoder().report(raw['content_json'] as String);
    final rows = await journal.db.query('validation');
    held = rows.isNotEmpty && rows.single['held'] == 1;
    held = await readHold();
    try {
      snapshot = await reader.read('fixture-r', 'fixture-p');
      validated =
          rows.isNotEmpty &&
          rows.single['version'] == workflow.context.version(snapshot!);
      status =
          await journal.prior(snapshot!, workflow.context) ??
          (validated
              ? (held ? 'retenu' : 'pret_simule')
              : 'validation_requise');
    } on IntegrationBlocked catch (e) {
      snapshot = null;
      validated = false;
      status = e.code;
    }
  }

  Future<void> saveText(String value) async {
    await writer.update(
      'care_episode_reports',
      {'content_json': content(value)},
      where: 'report_id = ?',
      whereArgs: ['fixture-r'],
    );
    await refresh();
  }

  Future<void> setHeld(bool value) async {
    if (snapshot == null) return;
    // A pre-validation hold is persisted independently of medical validation.
    await writer.execute(
      'CREATE TABLE IF NOT EXISTS demo_hold(value INTEGER NOT NULL)',
    );
    await writer.delete('demo_hold');
    await writer.insert('demo_hold', {'value': value ? 1 : 0});
    await journal.hold(snapshot!.lineage, value);
    held = value;
  }

  Future<bool> readHold() async {
    final tables = await writer.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='demo_hold'",
    );
    if (tables.isEmpty) return held;
    final rows = await writer.query('demo_hold');
    return rows.isNotEmpty && rows.single['value'] == 1;
  }

  Future<void> validate() async {
    if (snapshot == null) return;
    final hold = await readHold();
    await journal.validate(
      snapshot!,
      workflow.context,
      DateTime.now().toUtc(),
      held: hold,
    );
    await run();
  }

  Future<void> run() async {
    status = await workflow.run('fixture-r');
    final result = status;
    await refresh();
    status = result;
  }

  void chooseOutcome(String outcome) {
    if (calls != 0) return;
    service = IntegrationFakeService(outcome: outcome);
    workflow = IntegrationWorkflow(reader, journal, service, workflow.context);
  }

  Future<String> piece() async {
    final s = await reader.read('fixture-piece', 'fixture-p', attachment: true);
    return 'Pièce fictive lue : ${s.clinicalText}. Rattachement au patient vérifié.';
  }

  Future<void> close() async {
    if (closed) return;
    closed = true;
    await _journal?.close();
    await _reader?.close();
    await _writer?.close();
  }
}

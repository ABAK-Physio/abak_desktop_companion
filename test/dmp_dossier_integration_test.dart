import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/features/dmp_integration/dossier_reader.dart';
import 'package:abak_desktop_companion/features/dmp_integration/isolated_workflow.dart';
import 'package:abak_desktop_companion/features/patients/models/patient_fr_health_identity.dart';
import 'package:abak_desktop_companion/features/dmp_td02/td02_result.dart';

class NoNetwork extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      throw StateError('Réseau interdit');
}

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

class Fixture {
  late Directory root;
  late Database writer, readerDb;
  late DossierReader reader;
  late IntegrationJournal journal;
  IntegrationFakeService service = IntegrationFakeService();
  late IntegrationWorkflow workflow;
  late DossierSnapshot snapshot;
  late List<Map<String, Object?>> initialIdentity;
  String get file => '${root.path}/piece.fixture';
  Future<void> open() async {
    root = await Directory.systemTemp.createTemp('abak-dmp-integration-');
    root = Directory(root.resolveSymbolicLinksSync());
    // Only explicit temporary path: never access DatabaseService.database.
    writer = await DatabaseService.openDatabaseFile(
      '${root.path}/dossier.sqlite',
    );
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
    readerDb = await databaseFactoryFfi.openDatabase(
      '${root.path}/dossier.sqlite',
      options: OpenDatabaseOptions(readOnly: true, singleInstance: false),
    );
    await readerDb.execute('PRAGMA query_only=ON');
    reader = DossierReader(
      readerDb,
      IsolatedFiles(root),
      FixtureDecoder(),
      FixtureIdentity(),
    );
    journal = await IntegrationJournal.open(IsolatedFiles(root));
    snapshot = await reader.read('fixture-r', 'fixture-p');
    workflow = IntegrationWorkflow(reader, journal, service, ctx());
    initialIdentity = await writer.query('patient_fr_health_identity');
  }

  IntegrationContext ctx({
    String patient = 'fixture-p',
    String ps = 'fixture-ps',
    String structure = 'fixture-cabinet',
    String? identity,
    String session = 'session-a',
    String checked = 'session-a',
    DmpState state = DmpState.active,
    ConsultationRight right = ConsultationRight.valid,
    bool opposition = false,
    bool functional = true,
    bool author = true,
    bool minor = false,
    bool? secret,
    bool rl = false,
    bool visible = false,
    bool correlated = true,
  }) => IntegrationContext(
    patient: patient,
    professional: ps,
    structure: structure,
    identityVersion: identity ?? snapshot.identityVersion,
    session: session,
    checkedSession: checked,
    result: Td02Result(state, right: right),
    opposition: opposition,
    functional: functional,
    authorRights: author,
    minor: minor,
    secret: secret,
    rlVisible: rl,
    patientVisible: visible,
    correlated: correlated,
  );
  Future<void> validate({bool held = false}) => journal.validate(
    snapshot,
    workflow.context,
    DateTime.utc(2026, 10, 16),
    held: held,
  );
  Future<void> change(String table, Map<String, Object?> values) =>
      writer.update(table, values).then((_) {});
  Future<void> reopen({IntegrationContext? context}) async {
    await journal.close();
    journal = await IntegrationJournal.open(IsolatedFiles(root));
    workflow = IntegrationWorkflow(
      reader,
      journal,
      service,
      context ?? ctx(session: 'session-b', checked: 'session-b'),
    );
  }

  Future<void> identityUnchanged() async =>
      expect(await writer.query('patient_fr_health_identity'), initialIdentity);
  Future<void> close() async {
    await journal.close();
    await readerDb.close();
    await writer.close();
    await root.delete(recursive: true);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;
  final previous = HttpOverrides.current;
  HttpOverrides.global = NoNetwork();
  tearDownAll(() {
    HttpOverrides.global = previous;
  });
  var variants = 0;
  var scenario = 0;
  final evidence = <Map<String, Object?>>[];
  Future<void> fixture(Future<void> Function(Fixture f) body) async {
    final f = Fixture();
    await f.open();
    variants++;
    try {
      await body(f);
      evidence.add({
        'scenario': 'I${scenario.toString().padLeft(2, '0')}',
        'variante': variants,
        'statut': 'REUSSI',
        'appels_fictifs': f.service.sentVersions.length,
        'racine_isolee': f.root.path,
        'lecture_query_only': true,
      });
    } finally {
      await f.close();
    }
  }

  Future<void> blocked(Fixture f, String expected) async {
    final result = await f.workflow.run('fixture-r');
    expect(result, expected);
    expect(f.service.sentVersions, isEmpty);
    expect(integrationMessage(result), isNotEmpty);
  }

  for (var id = 1; id <= 32; id++) {
    test('I${id.toString().padLeft(2, '0')} intégration isolée', () async {
      scenario = id;
      switch (id) {
        case 1:
          await fixture((f) async {
            expect(f.writer.path, startsWith(f.root.path));
            expect(f.readerDb.path, f.writer.path);
            expect(f.journal.db.path, startsWith(f.root.path));
            expect(f.journal.witness.path, startsWith(f.root.path));
            expect(
              (await f.readerDb.rawQuery(
                'PRAGMA query_only',
              )).single.values.first,
              1,
            );
            await expectLater(
              f.readerDb.update('patients', {'last_name': 'INTERDIT'}),
              throwsA(isA<DatabaseException>()),
            );
            expect(await f.readerDb.query('patients', columns: ['last_name']), [
              {'last_name': 'FICTIF'},
            ]);
          });
        case 2:
          await fixture((f) async {
            final files = IsolatedFiles(f.root);
            for (final path in [
              '/outside.fixture',
              '../piece.fixture',
              '${f.root.path}/../outside.fixture',
            ]) {
              expect(
                () => files.read(path),
                throwsA(isA<IntegrationBlocked>()),
              );
            }
            final outside = await Directory.systemTemp.createTemp(
              'abak-outside-fixture-',
            );
            try {
              await File('${outside.path}/canary').writeAsString('untouched');
              await Link('${f.root.path}/escape').create(outside.path);
              expect(
                () => files.read('${f.root.path}/escape/canary'),
                throwsA(isA<IntegrationBlocked>()),
              );
              expect(
                await File('${outside.path}/canary').readAsString(),
                'untouched',
              );
            } finally {
              await outside.delete(recursive: true);
            }
          });
        case 3:
          await fixture((f) async {
            expect(f.snapshot.patientId, 'fixture-p');
            expect(f.snapshot.episodeId, 'fixture-e');
            expect(f.snapshot.documentId, 'report:fixture-r');
            final piece = await f.reader.read(
              'fixture-piece',
              'fixture-p',
              attachment: true,
            );
            expect(piece.episodeId, 'fixture-e');
            expect(piece.documentId, 'piece:fixture-piece');
            expect(piece.clinicalText, 'Pièce fictive');
            expect(piece.lineage, isNot(f.snapshot.lineage));
          });
        case 4:
          for (final variant in ['missing', 'wrongPatient']) {
            await fixture((f) async {
              if (variant == 'missing') {
                await f.change('care_episode_reports', {
                  'care_episode_id': 'missing',
                });
              } else {
                f.workflow.context = f.ctx(patient: 'fixture-other');
              }
              await blocked(f, 'rattachement_invalide');
            });
          }
        case 5:
          await fixture((f) async {
            expect(f.snapshot.identity.isQualified, isTrue);
            await blocked(f, 'validation_requise');
            await f.identityUnchanged();
          });
        case 6:
          for (final status in [
            'provisional',
            'retrieved',
            'validated',
            'unknown',
          ]) {
            await fixture((f) async {
              await f.change('patient_fr_health_identity', {
                'identity_status': status,
              });
              final before = await f.writer.query('patient_fr_health_identity');
              await blocked(f, 'identite_bloquee');
              expect(
                await f.writer.query('patient_fr_health_identity'),
                before,
              );
            });
          }
        case 7:
          await fixture((f) async {
            await f.change('patient_fr_health_identity', {
              'identity_doubtful': 1,
            });
            await blocked(f, 'identite_bloquee');
          });
        case 8:
          for (final oid in [
            'fixture:oid:nia',
            null,
            'unknown',
            '1.2.250.1.213.1.4.9',
          ]) {
            await fixture((f) async {
              await f.change('patient_fr_health_identity', {'ins_oid': oid});
              await blocked(f, 'identite_bloquee');
            });
          }
        case 9:
          for (final field in [
            'birth_last_name',
            'birth_first_names',
            'birth_date',
            'sex_code',
            'birth_place_code',
            'ins_number',
            'ins_key',
          ]) {
            await fixture((f) async {
              await f.change('patient_fr_health_identity', {field: ''});
              await blocked(f, 'identite_bloquee');
            });
          }
          await fixture((f) async {
            await f.change('patient_fr_health_identity', {
              'ins_number': 'INVALID',
            });
            await blocked(f, 'identite_bloquee');
          });
        case 10:
          for (final state in ['draft', 'saved']) {
            await fixture((f) async {
              await f.change('care_episode_reports', {'status': state});
              await blocked(f, 'validation_requise');
            });
          }
        case 11:
          await fixture((f) async {
            await f.validate();
            await f.reopen();
            final row = (await f.journal.db.query('validation')).single;
            expect(row['version'], f.workflow.context.version(f.snapshot));
            expect(row['author'], 'fixture-ps');
            expect(row['at'], '2026-10-16T00:00:00.000Z');
            await f.identityUnchanged();
          });
        case 12:
          for (final variant in ['content', 'title', 'visibility']) {
            await fixture((f) async {
              await f.validate();
              if (variant == 'visibility') {
                f.workflow.context = f.ctx(visible: true);
              } else {
                await f.change('care_episode_reports', {
                  variant == 'title'
                      ? 'title'
                      : 'content_json': variant == 'title'
                      ? 'Nouveau titre'
                      : content('Nouvelle mesure'),
                });
              }
              await blocked(f, 'validation_requise');
            });
          }
          await fixture((f) async {
            final a = await f.reader.read(
              'fixture-piece',
              'fixture-p',
              attachment: true,
            );
            await File(f.file).writeAsString(content('Pièce modifiée'));
            final b = await f.reader.read(
              'fixture-piece',
              'fixture-p',
              attachment: true,
            );
            expect(a.version, isNot(b.version));
          });
        case 13:
          for (final table in ['care_episode_notes', 'desktop_results']) {
            await fixture((f) async {
              await f.validate();
              await f.change(table, {
                table == 'care_episode_notes' ? 'content' : 'exportSimpleText':
                    'Donnée modifiée',
              });
              await blocked(f, 'validation_requise');
            });
          }
          await fixture((f) async {
            await f.validate();
            await f.writer.delete('care_episode_report_tests');
            await blocked(f, 'validation_requise');
          });
          await fixture((f) async {
            await f.writer.insert('care_episode_assessments', {
              'assessment_id': 'fixture-source',
              'care_episode_id': 'fixture-e',
              'title': 'Source',
              'content_json': content('Source fictive'),
              'assessment_date': 1,
              'created_at': 1,
            });
            await f.change('care_episode_reports', {
              'source_assessment_id': 'fixture-source',
            });
            f.snapshot = await f.reader.read('fixture-r', 'fixture-p');
            await f.validate();
            await f.change('care_episode_assessments', {
              'content_json': content('Source changée'),
            });
            await blocked(f, 'validation_requise');
          });
        case 14:
          for (final value in ['', '   ']) {
            await fixture((f) async {
              await f.change('care_episode_reports', {
                'content_json': content(value),
              });
              await blocked(f, 'document_vide');
            });
          }
          await fixture((f) async {
            await f.change('care_episode_reports', {
              'content_json': jsonEncode({
                'fixture': true,
                'title': 'Gabarit',
                'clinical': '',
              }),
            });
            await blocked(f, 'document_vide');
          });
          await fixture((f) async {
            await File(f.file).writeAsString('');
            await expectLater(
              f.reader.read('fixture-piece', 'fixture-p', attachment: true),
              throwsA(
                isA<IntegrationBlocked>().having(
                  (e) => e.code,
                  'code',
                  'document_vide',
                ),
              ),
            );
          });
        case 15:
          for (final kind in ['missing', 'directory', 'mime']) {
            await fixture((f) async {
              if (kind == 'missing') {
                await File(f.file).delete();
              }
              if (kind == 'directory') {
                await File(f.file).delete();
                await Directory(f.file).create();
              }
              if (kind == 'mime') {
                await f.change('episode_documents', {
                  'mime_type':
                      'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
                });
              }
              await expectLater(
                f.reader.read('fixture-piece', 'fixture-p', attachment: true),
                throwsA(
                  isA<IntegrationBlocked>().having(
                    (e) => e.code,
                    'code',
                    kind == 'mime'
                        ? 'format_indisponible'
                        : 'fichier_indisponible',
                  ),
                ),
              );
              expect(f.service.sentVersions, isEmpty);
            });
          }
        case 16:
          await fixture((f) async {
            await f.validate(held: true);
            await f.reopen();
            await blocked(f, 'retenu');
            await f.journal.hold(f.snapshot.lineage, false);
            expect(await f.workflow.run('fixture-r'), 'accepte_simule');
            expect(f.service.sentVersions.length, 1);
          });
        case 17:
          await fixture((f) async {
            await f.validate();
            expect(f.workflow.context.result.canSendNetworkRequest, isFalse);
            expect(await f.workflow.run('fixture-r'), 'accepte_simule');
            expect(f.service.sentVersions.length, 1);
          });
        case 18:
          for (final state in [
            DmpState.absent,
            DmpState.closed,
            DmpState.unknown,
          ]) {
            await fixture((f) async {
              await f.validate();
              f.workflow.context = f.ctx(state: state);
              await blocked(f, 'dmp_${state.name}');
            });
          }
          await fixture((f) async {
            await f.validate();
            f.workflow.context = f.ctx(correlated: false);
            await blocked(f, 'contexte_perime');
          });
          await fixture((f) async {
            await f.validate();
            f.workflow.context = f.ctx(checked: 'old');
            await blocked(f, 'contexte_perime');
          });
        case 19:
          for (final variant in ['patient', 'ps', 'structure', 'identity']) {
            await fixture((f) async {
              await f.validate();
              f.workflow.beforeReserve = () async {
                if (variant == 'identity') {
                  await f.change('patient_fr_health_identity', {
                    'updated_at': 2,
                  });
                } else {
                  f.workflow.context = f.ctx(
                    patient: variant == 'patient'
                        ? 'fixture-other'
                        : 'fixture-p',
                    ps: variant == 'ps' ? 'fixture-other' : 'fixture-ps',
                    structure: variant == 'structure'
                        ? 'fixture-other'
                        : 'fixture-cabinet',
                  );
                }
              };
              final code = await f.workflow.run('fixture-r');
              expect([
                'contexte_perime',
                'rattachement_invalide',
              ], contains(code));
              expect(f.service.sentVersions, isEmpty);
            });
          }
          await fixture((f) async {
            await f.validate();
            f.workflow.afterReserve = () async {
              await f.change('care_episode_reports', {
                'content_json': content('Changement tardif'),
              });
            };
            await blocked(f, 'indetermine');
            await f.reopen();
            await blocked(f, 'indetermine');
          });
        case 20:
          for (final right in [
            ConsultationRight.absent,
            ConsultationRight.expired,
            ConsultationRight.blocked,
          ]) {
            await fixture((f) async {
              f.workflow.context = f.ctx(right: right);
              await f.validate();
              expect(await f.workflow.run('fixture-r'), 'accepte_simule');
              expect(f.service.sentVersions.length, 1);
            });
          }
        case 21:
          for (final variant in ['opposition', 'author', 'functional']) {
            await fixture((f) async {
              await f.validate();
              f.workflow.context = f.ctx(
                opposition: variant == 'opposition',
                author: variant != 'author',
                functional: variant != 'functional',
              );
              await blocked(f, 'droits_ou_opposition');
            });
          }
          await fixture((f) async {
            await f.change('care_episode_reports', {
              'author_practitioner_id': null,
            });
            await blocked(f, 'contexte_perime');
          });
        case 22:
          await fixture((f) async {
            f.workflow.context = f.ctx(minor: true, secret: true);
            await f.validate(held: true);
            await f.reopen(
              context: f.ctx(minor: true, session: 'b', checked: 'b'),
            );
            await f.journal.hold(f.snapshot.lineage, false);
            await blocked(f, 'choix_session_requis');
            f.workflow.context = f.ctx(minor: true, secret: true, rl: true);
            await blocked(f, 'visibilite_incompatible');
          });
        case 23:
          await fixture((f) async {
            await f.validate();
            final j = await IntegrationJournal.open(IsolatedFiles(f.root));
            try {
              final other = IntegrationWorkflow(
                f.reader,
                j,
                f.service,
                f.ctx(),
              );
              final results = await Future.wait([
                f.workflow.run('fixture-r'),
                other.run('fixture-r'),
              ]);
              expect(results, contains('accepte_simule'));
              expect(f.service.sentVersions.length, 1);
              expect(await f.workflow.run('fixture-r'), 'deja_accepte');
              expect(f.service.sentVersions.length, 1);
            } finally {
              await j.close();
            }
          });
        case 24:
          await fixture((f) async {
            await f.validate();
            expect(await f.workflow.run('fixture-r'), 'accepte_simule');
            final before = await f.journal.db.query('attempts');
            await f.reopen();
            expect(await f.workflow.run('fixture-r'), 'deja_accepte');
            expect(await f.journal.db.query('attempts'), before);
            expect(before.single['entry_uuid'], startsWith('fixture-entry-'));
            expect(f.service.sentVersions.length, 1);
          });
        case 25:
          for (final outcome in ['signatureRejected', 'metadataRejected']) {
            await fixture((f) async {
              f.service = IntegrationFakeService(outcome: outcome);
              await f.reopen();
              await f.validate();
              final expected = outcome == 'signatureRejected'
                  ? 'signature_rejetee'
                  : 'metadonnees_rejetees';
              expect(await f.workflow.run('fixture-r'), expected);
              await f.reopen();
              expect(await f.workflow.run('fixture-r'), expected);
              expect(f.service.sentVersions.length, 1);
            });
          }
        case 26:
          await fixture((f) async {
            await f.validate();
            f.workflow.interruptAfterReserve = true;
            expect(await f.workflow.run('fixture-r'), 'indetermine');
            await f.reopen();
            await blocked(f, 'indetermine');
          });
        case 27:
          for (final fault in ['reserve', 'afterWitness', 'finish']) {
            await fixture((f) async {
              await f.validate();
              f.journal.failAt = fault;
              expect(
                await f.workflow.run('fixture-r'),
                fault == 'finish' ? 'indetermine' : 'stockage_bloque',
              );
              expect(f.service.sentVersions.length, fault == 'finish' ? 1 : 0);
              await f.reopen();
              if (fault != 'reserve') {
                expect(
                  await f.workflow.run('fixture-r'),
                  fault == 'finish' ? 'indetermine' : 'rapprochement_requis',
                );
              }
            });
          }
          await fixture((f) async {
            await f.validate();
            await f.journal.witness.execute('PRAGMA query_only=ON');
            await blocked(f, 'stockage_bloque');
          });
          await fixture((f) async {
            await f.journal.db.execute('DROP TABLE validation');
            await blocked(f, 'stockage_bloque');
          });
          await fixture((f) async {
            await f.validate();
            final lock = await databaseFactoryFfi.openDatabase(
              f.journal.witness.path,
              options: OpenDatabaseOptions(singleInstance: false),
            );
            await f.journal.witness.execute('PRAGMA busy_timeout=1');
            await lock.execute('BEGIN IMMEDIATE');
            try {
              await blocked(f, 'stockage_bloque');
            } finally {
              await lock.execute('ROLLBACK');
              await lock.close();
            }
          });
        case 28:
          for (final visible in [true, false]) {
            await fixture((f) async {
              await f.validate();
              expect(await f.workflow.run('fixture-r'), 'accepte_simule');
              if (visible) {
                f.workflow.context = f.ctx(visible: true);
              } else {
                await f.change('care_episode_reports', {
                  'content_json': content('Nouvelle version'),
                });
              }
              expect(
                await f.workflow.run('fixture-r'),
                visible ? 'modification_a_preparer' : 'remplacement_a_preparer',
              );
              expect(f.service.sentVersions.length, 1);
            });
          }
        case 29:
          for (final deleted in [true, false]) {
            await fixture((f) async {
              await f.validate();
              await f.workflow.run('fixture-r');
              final trace = await f.journal.db.query('attempts');
              if (deleted) {
                await f.writer.delete('care_episode_reports');
              } else {
                await f.change('care_episode_reports', {'archived_at': 3});
              }
              expect(
                await f.workflow.run('fixture-r'),
                'rattachement_invalide',
              );
              expect(await f.journal.db.query('attempts'), trace);
              expect(f.service.sentVersions.length, 1);
            });
          }
        case 30:
          await fixture((f) async {
            await f.validate();
            await f.journal.close();
            await File(
              '${f.root.path}/journal.sqlite',
            ).copy('${f.root.path}/old.sqlite');
            f.journal = await IntegrationJournal.open(IsolatedFiles(f.root));
            f.workflow = IntegrationWorkflow(
              f.reader,
              f.journal,
              f.service,
              f.ctx(),
            );
            expect(await f.workflow.run('fixture-r'), 'accepte_simule');
            await f.journal.close();
            await File(
              '${f.root.path}/old.sqlite',
            ).copy('${f.root.path}/journal.sqlite');
            f.journal = await IntegrationJournal.open(IsolatedFiles(f.root));
            f.workflow = IntegrationWorkflow(
              f.reader,
              f.journal,
              f.service,
              f.ctx(),
            );
            expect(await f.workflow.run('fixture-r'), 'rapprochement_requis');
            expect(f.service.sentVersions.length, 1);
          });
        case 31:
          for (final outcome in [
            'accepted',
            'signatureRejected',
            'indeterminate',
          ]) {
            await fixture((f) async {
              f.service = IntegrationFakeService(outcome: outcome);
              await f.reopen();
              await f.validate(held: true);
              await f.workflow.run('fixture-r');
              await f.reopen();
              await f.journal.hold(f.snapshot.lineage, false);
              await f.workflow.run('fixture-r');
              await f.reopen();
              await f.workflow.run('fixture-r');
              await f.identityUnchanged();
            });
          }
        case 32:
          await fixture((f) async {
            expect(() => HttpClient(), throwsStateError);
            final messenger = TestDefaultBinaryMessengerBinding
                .instance
                .defaultBinaryMessenger;
            var attempts = 0;
            for (final name in [
              'plugins.flutter.io/url_launcher',
              'abak/insi',
              'abak/cps',
            ]) {
              messenger.setMockMethodCallHandler(MethodChannel(name), (
                call,
              ) async {
                attempts++;
                throw PlatformException(code: 'INTERDIT');
              });
            }
            await f.validate();
            expect(await f.workflow.run('fixture-r'), 'accepte_simule');
            expect(attempts, 0);
            await expectLater(
              const MethodChannel('abak/cps').invokeMethod<void>('probe'),
              throwsA(isA<PlatformException>()),
            );
            for (final name in [
              'plugins.flutter.io/url_launcher',
              'abak/insi',
              'abak/cps',
            ]) {
              messenger.setMockMethodCallHandler(MethodChannel(name), null);
            }
          });
      }
    });
  }
  tearDownAll(() {
    final destination = Platform.environment['ABAK_INTEGRATION_EVIDENCE'];
    if (destination != null) {
      File(destination).writeAsStringSync(
        const JsonEncoder.withIndent('  ').convert({
          'scenarios': 32,
          'variantes_executees': variants,
          'variantes_reussies': evidence.length,
          'details': evidence,
          'reseau_externe': false,
          'cps_sollicitee': false,
          'bases_reelles_ouvertes': false,
        }),
      );
    }
    // ignore: avoid_print
    print('Scénarios I01–I32 ; exécutions de variantes : $variants');
  });
}

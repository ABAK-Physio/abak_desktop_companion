import 'dart:async';
import 'dart:io';
import '../dmp_minors/minors_simulation.dart';
import '../dmp_td02/td02_result.dart';
import 'automation_cases.dart';
import 'automation_model.dart';
import 'automation_store.dart';
import 'automation_engine.dart';

class NoWriteAutoStore extends AutoStore {
  NoWriteAutoStore(super.directory);
  @override
  void write(AutoRecord value) =>
      throw const FileSystemException('Simulation écriture refusée');
}

Future<Map<String, Object>> runAutomationScenario(
  int number,
  Directory root,
) async {
  if (number < 1 || number > 42) throw ArgumentError('Scénario inconnu');
  final plan = automationCases[number - 1];
  root.createSync(recursive: true);
  final variants = switch (number) {
    24 => 2,
    30 => 3,
    32 => 3,
    33 => 2,
    37 => 3,
    41 => 3,
    _ => 1,
  };
  final reports = <Map<String, Object>>[];
  void check(bool ok, String message) {
    if (!ok) throw StateError('${plan['id']} : $message');
  }

  for (var variant = 0; variant < variants; variant++) {
    final directory = root.createTempSync('${plan['id']}-v$variant-');
    AutoStore store = AutoStore(directory);
    var ctx = const AutoContext();
    final r = AutoRecord();
    final input = Map<String, dynamic>.from(plan['initial']);
    if (input['patient'] == 'simulation-enfant') {
      r.document = r.document.copy(patient: SimPatient.child);
      ctx = ctx.copy(patient: SimPatient.child);
    }
    if (input['secret_choice'] is bool) {
      ctx = ctx.copy(secret: input['secret_choice']);
    }
    if (input['rule_enabled'] == false) r.rule = const AutoRule(enabled: false);
    if (input['document_type'] != null) {
      r.document = r.document.copy(type: input['document_type']);
    }
    r.held = input['held'] == true;
    switch (input['fixture']) {
      case 'vide':
      case 'gabarit':
        r.document = r.document.copy(content: '');
      case 'espaces':
        r.document = r.document.copy(content: ' \n\t ');
      case 'bilan-v2':
        r.document = r.document.copy(
          content: 'Bilan fictif : amplitude du genou mesurée à 100 degrés.',
        );
      case 'bilan-visible':
        r.document = r.document.copy(patientVisible: true);
    }
    if (input['previous_accepted'] != null) r.history = const AutoDocument();
    if (input['identity'] == 'nia') ctx = ctx.copy(identity: SimIdentity.nia);
    if (input['identity'] == 'unqualified') {
      ctx = ctx.copy(identity: SimIdentity.unqualified);
    }
    if (input['dmp_state'] != null) {
      ctx = ctx.copy(dmp: DmpState.values.byName(input['dmp_state']));
    }
    if (input['opposition'] == true) ctx = ctx.copy(opposition: true);
    if (input['metadata_valid'] == false) ctx = ctx.copy(metadataValid: false);
    if (input['rl_visible'] is bool) {
      r.document = r.document.copy(rlVisible: input['rl_visible']);
    }
    if (number == 32) {
      ctx = ctx.copy(
        right: [
          ConsultationRight.absent,
          ConsultationRight.expired,
          ConsultationRight.blocked,
        ][variant],
      );
    }
    if (number == 33) {
      ctx = ctx.copy(
        functionalRights: variant != 0,
        authorRights: variant != 1,
      );
    }
    if (number == 37) {
      if (variant == 0) r.history = r.document.copy(patientVisible: true);
      if (variant == 1) r.history = r.document.copy(rlVisible: true);
      if (variant == 2) r.document = r.document.copy(maskedPs: true);
    }
    store.write(r);
    if ([19, 20, 21, 23].contains(number)) {
      store.reserve();
      if (number != 23) {
        store.finish(switch (number) {
          19 => 'accepted',
          21 => 'rejected',
          _ => 'indeterminate',
        }, r.document);
      }
    }
    if (number == 24) {
      if (variant == 0) {
        store.file.writeAsStringSync('{corrompu');
      } else {
        store = NoWriteAutoStore(directory);
      }
    }
    final connection = [6, 9, 10, 30, 40, 41].contains(number)
        ? Completer<void>()
        : null;
    final result = number == 39 ? Completer<void>() : null;
    final service = AutoFakeService(
      tlsOk: number != 22,
      connectionGate: connection?.future,
      resultGate: result?.future,
    );
    var e = AutoEngine(store, service, context: ctx);
    AutoDecision? observed;
    var expectedCalls = plan['attendu']['appels_depot_simule'] as int;
    switch (number) {
      case 1:
        await e.process();
      case 6:
      case 9:
      case 10:
      case 30:
      case 40:
      case 41:
        final pending = e.validateAndRun();
        check(service.connections == 1, 'Préparation en attente du faux TLS');
        if (number == 6) e.hold(true);
        if (number == 9 || number == 40) {
          e.updateDocument(
            r.document.copy(content: 'Bilan fictif modifié après validation.'),
          );
        }
        if (number == 10) {
          e.updateDocument(r.document.copy(patientVisible: true));
        }
        if (number == 30) {
          e.setContext(switch (variant) {
            0 => ctx.copy(patient: SimPatient.child),
            1 => ctx.copy(professional: 'simulation-ps-b'),
            _ => ctx.copy(structure: 'simulation-cabinet-b'),
          });
        }
        if (number == 41) {
          e.updateRule(switch (variant) {
            0 => const AutoRule(enabled: false),
            1 => const AutoRule(majority: 21),
            _ => const AutoRule(cumulative: true),
          });
        }
        connection!.complete();
        await pending;
      case 7:
        e.validateOnly();
        e.close();
        e = AutoEngine(AutoStore(directory), service, context: ctx);
        await e.process();
        check(e.record!.held, 'Retenue perdue après réouverture');
      case 8:
        await e.validateAndRun();
        check(service.sent.isEmpty, 'Dépôt malgré retenue');
        await e.releaseAndRun();
      case 15:
        // Technical envelope fields are not part of AutoDocument at all.
        final oldVersion = r.document.version;
        final envelope = {
          'MessageID': 'simulation-2',
          'nonce': 'simulation-nonce-2',
          'signatureTime': '2026-10-16T11:00:00Z',
        };
        check(
          envelope.length == 3 && oldVersion == r.document.version,
          'Les champs techniques ont changé le document métier',
        );
        await e.validateAndRun();
      case 18:
        final other = AutoEngine(AutoStore(directory), service, context: ctx);
        await Future.wait([
          e.validateAndRun(),
          other.validateAndRun(),
          e.process(),
        ]);
        check(store.read().outcome == 'accepted', 'Résultat durable absent');
        observed = decision('accepte_simule');
        other.close();
      case 24:
        await e.validateAndRun();
        if (variant == 0) {
          check(
            store.file.readAsStringSync() == '{corrompu',
            'Stockage corrompu écrasé',
          );
        }
      case 38:
        await e.validateAndRun();
        e.close();
        e = AutoEngine(
          AutoStore(directory),
          service,
          context: const AutoContext(patient: SimPatient.child),
        );
        await e.releaseAndRun();
        check(e.context.secret == null, 'Secret hérité');
      case 39:
        final pending = e.validateAndRun();
        // Wait only for local microtasks to enter the fake deposit.
        for (var i = 0; i < 5 && service.sent.isEmpty; i++) {
          await Future<void>.delayed(Duration.zero);
        }
        check(e.reserved && service.sent.length == 1, 'Tentative non engagée');
        final before = service.sent.length;
        e.hold(true);
        observed = e.status;
        check(!store.read().held, 'Annulation trompeuse enregistrée');
        result!.complete();
        await pending;
        expectedCalls += before;
      default:
        await e.validateAndRun();
    }
    observed ??= e.status;
    check(
      observed.state == plan['attendu']['etat'],
      'État ${observed.state}, attendu ${plan['attendu']['etat']}',
    );
    check(
      observed.message.isNotEmpty && !observed.message.contains('Exception'),
      'Message utilisateur absent ou technique',
    );
    check(
      service.sent.length == expectedCalls,
      '${service.sent.length} appels, attendu $expectedCalls',
    );
    if (service.sent.isNotEmpty) {
      check(
        service.sent.every((d) => d.version == r.document.version),
        'Mauvaise version transmise au service fictif',
      );
    }
    check(
      !store.file.readAsStringSync().contains('secret'),
      'Choix secret persisté',
    );
    reports.add({
      'variante': variant + 1,
      'etat': observed.state,
      'message': observed.message,
      'appels_depot_simule': service.sent.length,
      'appels_reseau': 0,
      'stockage': directory.path,
      'controle': 'réussi',
    });
    e.close();
  }
  return {
    'id': plan['id'],
    'titre': plan['titre'],
    'statut': 'REUSSI_LOCALEMENT',
    'variantes': reports,
  };
}

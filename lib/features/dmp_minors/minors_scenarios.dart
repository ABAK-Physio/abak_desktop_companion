import 'dart:io';
import '../dmp_resources/dmp_resources.dart';
import 'minors_simulation.dart';

const minorScenarioTitles = [
  'Veille de majorité',
  'Jour de majorité',
  'Seuil à 21 ans',
  'Fonctions mineurs désactivées',
  'Naissance inconnue',
  'Naissance future',
  'Paramètres invalides',
  'Choix normal explicite',
  'Choix secret explicite',
  'Visibilité RL interdite en secret',
  'Document invisible en session normale',
  'Changement de patient et de professionnel',
  'Nouvelle session',
  'Annulation du passage visible',
  'Visibilité RL irréversible',
  'Remplacement incompatible avec le secret',
  'Visibilité patient irréversible',
  'Cumul interdit',
  'Cumul autorisé',
  'Aperçu périmé',
  'Aucun seuil minimum optionnel',
  'Opposition au nouveau dépôt',
  'Persistance isolée et absence de secret mémorisé',
];

class MinorScenarioResult {
  MinorScenarioResult(this.id, this.checks);
  final String id;
  final List<String> checks;
}

/// Executes the actual rules against a fresh subdirectory, never a real lot.
MinorScenarioResult runMinorScenario(int number, Directory root) {
  if (number < 1 || number > 23) throw ArgumentError('Scénario inconnu');
  final id = 'M${number.toString().padLeft(2, '0')}';
  root.createSync(recursive: true);
  final store = MinorSimulationStore(root.createTempSync('$id-'));
  final checks = <String>[];
  void check(bool condition, String label) {
    if (!condition) throw StateError('$id : contrôle échoué : $label');
    checks.add(label);
  }

  void refused(void Function() action, String text) {
    try {
      action();
    } on StateError catch (e) {
      check(
        e.message.toString().contains(text),
        'Refus confirmé : ${e.message}',
      );
      return;
    }
    throw StateError('$id : refus attendu absent ($text)');
  }

  MinorContext ctx({
    SimPatient patient = SimPatient.child,
    int day = 16,
    int majority = 18,
    bool enabled = true,
    bool valid = true,
    bool cumulative = false,
    String professional = 'PS fictif A',
  }) => MinorContext.fromParameters(
    patient: patient,
    today: DateTime.utc(2026, 10, day),
    parameters: valid ? DmpParameters(enabled, majority, cumulative, []) : null,
    professional: professional,
  );
  var s = MinorSession(ctx());
  SimDocument hidden() =>
      SimDocument(id: 'SIM-$id', patient: s.context.patient);
  switch (number) {
    case 1:
      s.changeContext(ctx(patient: SimPatient.threshold, day: 15));
      check(
        s.context.age == 17 &&
            s.context.minor &&
            s.context.secretAvailable &&
            s.secretChoice == null,
        '17 ans, choix secret proposé mais non sélectionné',
      );
    case 2:
      s.changeContext(ctx(patient: SimPatient.threshold));
      check(
        s.context.age == 18 && !s.context.minor && !s.context.secretAvailable,
        '18 ans : majeur',
      );
      refused(() => s.choose(true), 'indisponible');
    case 3:
      s.changeContext(ctx(patient: SimPatient.adult, majority: 21));
      check(
        s.context.age == 20 && s.context.minor && s.context.secretAvailable,
        'Seuil de 21 ans appliqué',
      );
    case 4:
      s.changeContext(ctx(enabled: false));
      check(
        s.context.age == 12 &&
            s.context.minor &&
            !s.context.secretAvailable &&
            !s.context.message.contains('Majeur'),
        '12 ans conservé, fonctions désactivées',
      );
    case 5:
      s.changeContext(ctx(patient: SimPatient.unknown));
      check(
        s.context.age == null && !s.ready,
        'Âge inconnu sans valeur par défaut',
      );
      refused(() => s.prepare(id: 'SIM-$id'), 'Contexte incomplet');
    case 6:
      s.changeContext(ctx(patient: SimPatient.future));
      check(
        s.context.message.contains('incohérente') && !s.ready,
        'Naissance future bloquée',
      );
      refused(() => s.prepare(id: 'SIM-$id'), 'Contexte incomplet');
    case 7:
      s.changeContext(ctx(valid: false));
      check(
        !s.ready && s.context.message.contains('Aucun paramètre validé'),
        'Paramètres invalides bloquants',
      );
      refused(() => s.prepare(id: 'SIM-$id'), 'Contexte incomplet');
    case 8:
      check(
        !s.ready && MinorSession.information.contains('traces'),
        'Information et choix explicite requis',
      );
      s.choose(false);
      check(!s.prepare(id: 'SIM-$id').secret, 'Aperçu normal');
    case 9:
      s.choose(true);
      final p = s.prepare(id: 'SIM-$id');
      check(
        p.secret &&
            !p.document.rlVisible &&
            p.text.contains('Connexion secrète'),
        'Secret et invisibilité RL imposée',
      );
    case 10:
      s.choose(true);
      refused(() => s.prepare(id: 'SIM-$id', rlVisible: true), 'obligatoire');
      check(
        !s.prepare(id: 'SIM-$id').document.rlVisible,
        'Invisibilité RL conservée',
      );
    case 11:
      s.choose(false);
      final p = s.prepare(id: 'SIM-$id');
      check(
        !p.secret && !p.document.rlVisible,
        'Invisibilité du document distincte du secret de session',
      );
    case 12:
      s.choose(true);
      final p = s.prepare(id: 'SIM-$id');
      s.changeContext(ctx(patient: SimPatient.threshold, day: 15));
      check(
        s.secretChoice == null && !s.current(p),
        'Choix et aperçu réinitialisés pour autre patient',
      );
      s.choose(true);
      refused(
        () => s.prepare(id: 'SIM-$id', replacing: p.document),
        'autre patient',
      );
      s.changeContext(
        ctx(
          patient: SimPatient.threshold,
          day: 15,
          professional: 'PS fictif B',
        ),
      );
      check(
        s.secretChoice == null,
        'Choix réinitialisé pour autre professionnel',
      );
    case 13:
      s.choose(true);
      s = MinorSession(ctx());
      check(
        s.secretChoice == null && !s.ready,
        'Nouvelle session : nouveau choix requis',
      );
    case 14:
      s.choose(false);
      final d = hidden();
      store.save(d);
      store.save(s.reveal(d, representatives: true, confirmed: false));
      check(!store.read().single.rlVisible, 'Annulation : stockage inchangé');
    case 15:
      s.choose(false);
      final d = s.reveal(hidden(), representatives: true, confirmed: true);
      store.save(d);
      final restored = MinorSimulationStore(store.directory).read().single;
      check(
        restored.rlVisible,
        'Visible RL conservé après réouverture du stockage',
      );
      refused(
        () => s.prepare(id: 'SIM-$id', replacing: restored),
        'Remasquage',
      );
      refused(() => store.save(hidden()), 'Remasquage');
    case 16:
      s.choose(true);
      final d = SimDocument(
        id: 'SIM-$id',
        patient: s.context.patient,
        rlVisible: true,
      );
      refused(() => s.prepare(id: d.id, replacing: d), 'Conflit');
      refused(
        () => s.prepare(id: d.id, replacing: d, rlVisible: true),
        'Conflit',
      );
      check(s.preview == null, 'Aucun aperçu ni contournement automatique');
    case 17:
      s.changeContext(ctx(patient: SimPatient.adult));
      final d = hidden();
      check(
        !s.reveal(d, representatives: false, confirmed: false).patientVisible,
        'Annulation respectée',
      );
      final visible = s.reveal(d, representatives: false, confirmed: true);
      store.save(visible);
      check(
        store.read().single.patientVisible && !visible.rlVisible,
        'Visibilité patient distincte des RL',
      );
      refused(() => s.prepare(id: d.id, replacing: visible), 'Remasquage');
    case 18:
      s.changeContext(ctx(patient: SimPatient.adult));
      refused(() => s.prepare(id: 'SIM-$id', maskedPs: true), 'Cumul');
    case 19:
      s.changeContext(ctx(patient: SimPatient.adult, cumulative: true));
      final p = s.prepare(id: 'SIM-$id', maskedPs: true);
      check(
        !p.document.patientVisible && p.document.maskedPs,
        'Cumul permis pour document nouveau',
      );
      final d = s.reveal(p.document, representatives: false, confirmed: true);
      refused(
        () => s.prepare(id: d.id, replacing: d, maskedPs: true),
        'Remasquage',
      );
    case 20:
      for (final next in [
        ctx(enabled: false),
        ctx(day: 17),
        ctx(majority: 10),
      ]) {
        s.changeContext(ctx());
        s.choose(true);
        final p = s.prepare(id: 'SIM-$id');
        s.changeContext(next);
        check(
          !s.current(p) && s.secretChoice == null,
          'Contexte modifié : aperçu périmé',
        );
        refused(() => s.retain(p, store), 'périmé');
      }
    case 21:
      check(
        s.context.secretAvailable,
        'Pas de suppression selon un seuil minimum optionnel',
      );
      s.choose(true);
      check(s.secretChoice == true, 'Choix explicite disponible');
      checks.add(
        'Option EX_0.1-1115 non implémentée : son comportement conditionnel n’est pas validé.',
      );
    case 22:
      s.choose(true);
      s.setOpposition(true);
      refused(() => s.prepare(id: 'SIM-$id'), 'Opposition');
      check(s.preview == null, 'Aucun aperçu de nouveau dépôt malgré secret');
    case 23:
      s.choose(true);
      final p = s.prepare(id: 'SIM-$id');
      s.retain(p, store);
      final saved = store.file.readAsStringSync();
      final restored = MinorSimulationStore(store.directory).read().single;
      s = MinorSession(ctx());
      check(
        restored.id == 'SIM-$id' &&
            !restored.rlVisible &&
            s.secretChoice == null,
        'Document conservé, choix secret absent après redémarrage',
      );
      check(
        !saved.contains('secret') &&
            !saved.contains('VIHF') &&
            p.text.startsWith('SIMULATION'),
        'Persistance limitée aux documents fictifs ; aperçu non signé',
      );
  }
  return MinorScenarioResult(id, checks);
}

import 'dart:convert';
import 'dart:io';
import 'package:abak_desktop_companion/features/dmp_pdf_isolated/final_pdf_bench.dart';

void check(bool value, String message) {
  if (!value) throw StateError(message);
}

void blocked(void Function() action, String text) {
  try {
    action();
  } on PdfBlocked catch (e) {
    check(e.message.contains(text), 'Message ${e.message}, attendu $text');
    return;
  }
  throw StateError('Blocage absent : $text');
}

void main(List<String> args) {
  if (args.first == '--reopen') {
    final b = FinalPdfBench.reopen(
      Directory(args[1]),
      LocalPdfInspector(args[2]),
    );
    blocked(
      () => b.simulate(currentSourceRevision: 'source-1'),
      'renvoi bloqué',
    );
    stdout.writeln('REOPEN_BLOCKED');
    return;
  }
  final fixtures = Directory(args[0]);
  final output = Directory(args[1])..createSync(recursive: true);
  final inspector = LocalPdfInspector(args[2]);
  final results = <Map<String, dynamic>>[];
  File f(String name) => File('${fixtures.path}/$name');
  FinalPdfBench fresh([String name = 'rapport_final.pdf']) {
    final b = FinalPdfBench.create(output, inspector);
    b.importPdf(f(name), b.context(), 'source-1');
    return b;
  }

  void approve(
    FinalPdfBench b, {
    bool clinical = true,
    String patient = 'SIM-A',
    String source = 'source-1',
    Set<int> pages = const {1},
  }) => b.approve(
    reviewedPages: pages,
    clinicalContent: clinical,
    reviewedPatient: patient,
    currentSourceRevision: source,
    consent: true,
  );
  String run(FinalPdfBench b, {String outcome = 'accepted'}) =>
      b.simulate(currentSourceRevision: 'source-1', outcome: outcome);
  void scenario(String id, void Function() action) {
    try {
      action();
      results.add({'id': id, 'result': 'PASS'});
      stdout.writeln('$id PASS');
    } catch (e, st) {
      results.add({'id': id, 'result': 'FAIL', 'error': '$e', 'stack': '$st'});
      stdout.writeln('$id FAIL $e');
    }
  }

  scenario('C01', () {
    final b = FinalPdfBench.create(output, inspector);
    blocked(
      () => b.importPdf(f('bilan_travail.docx'), b.context(), 'source-1'),
      'Format PDF',
    );
    blocked(() => run(b), 'PDF final');
  });
  scenario('C02', () {
    final b = fresh();
    blocked(
      () => b.importPdf(f('bilan_ajuste.docx'), b.context(), 'source-1'),
      'Format PDF',
    );
    check(b.state['current'] == null, 'Ancienne validation active');
    b.importPdf(f('rapport_final.pdf'), b.context(), 'source-1');
    check(
      b.state['current']['inspection']['text'].contains('110'),
      'Ajustement absent',
    );
    blocked(() => run(b), 'validation médicale');
  });
  scenario('C03', () {
    final b = fresh('deux_pages.pdf');
    blocked(() => approve(b), 'Toutes les pages');
    approve(b, pages: {1, 2});
    check(b.state['current']['approved'] == true, 'Validation absente');
    check(
      (b.state['current']['inspection']['previews'] as Map).length == 2,
      'Aperçu partiel',
    );
  });
  scenario('C04', () {
    final b = fresh();
    blocked(() => run(b), 'validation médicale');
    check(b.state['calls'] == 0, 'Appel avant validation');
  });
  scenario('C05', () {
    final b = FinalPdfBench.create(output, inspector);
    blocked(
      () => b.importPdf(f('zero_octet.pdf'), b.context(), 'source-1'),
      'Document vide',
    );
  });
  scenario('C06', () {
    final b = fresh('page_blanche.pdf');
    blocked(() => approve(b, clinical: true), 'sans contenu clinique');
    check(b.state['calls'] == 0, 'Appel vide');
  });
  scenario('C07', () {
    final b = fresh('entete_seul.pdf');
    blocked(() => approve(b, clinical: false), 'sans contenu clinique');
    check(b.state['calls'] == 0, 'Appel vide');
  });
  scenario('C08', () {
    final b = FinalPdfBench.create(output, inspector);
    blocked(
      () => b.importPdf(f('faux_pdf.pdf'), b.context(), 'source-1'),
      'Format PDF',
    );
  });
  scenario('C09', () {
    final b = fresh();
    approve(b);
    final old = b.state['current']['id'];
    b.importPdf(f('rapport_modifie.pdf'), b.context(), 'source-1');
    check(old != b.state['current']['id'], 'Version inchangée');
    blocked(() => run(b), 'validation médicale');
    check(
      (b.state['history'] as List)
              .where((e) => e['event'] == 'validation')
              .length ==
          1,
      'Historique perdu',
    );
  });
  scenario('C10', () {
    final b = fresh();
    approve(b);
    final copy = File('${b.root.path}/externe.pdf')
      ..writeAsBytesSync(f('rapport_final.pdf').readAsBytesSync());
    b.importPdf(copy, b.context(), 'source-1');
    copy.writeAsBytesSync(f('rapport_modifie.pdf').readAsBytesSync());
    b.importPdf(copy, b.context(), 'source-1');
    blocked(() => run(b), 'validation médicale');
  });
  scenario('C11', () {
    var b = fresh();
    approve(b);
    b.hold(false);
    run(b);
    b = FinalPdfBench.reopen(b.root, inspector);
    b.importPdf(f('copie_identique.pdf'), b.context(), 'source-1');
    blocked(() => run(b), 'renvoi bloqué');
    check(b.state['calls'] == 1, 'Renvoi');
  });
  scenario('C12', () {
    final b = fresh();
    approve(b);
    final text = b.state['current']['inspection']['text'];
    b.importPdf(f('rapport_metadata_seule.pdf'), b.context(), 'source-1');
    check(text == b.state['current']['inspection']['text'], 'Texte différent');
    blocked(() => run(b), 'validation médicale');
  });
  scenario('C13', () {
    final b = fresh('rapport_autre_patient.pdf');
    blocked(() => approve(b), 'Patient différent');
    check(b.state['calls'] == 0, 'Mauvais patient traité');
  });
  scenario('C14', () {
    final b = fresh();
    approve(b);
    blocked(() => approve(b, source: 'source-2'), 'sources modifiées');
    blocked(
      () => b.simulate(currentSourceRevision: 'source-2'),
      'sources modifiées',
    );
  });
  scenario('C15', () {
    var b = fresh();
    approve(b);
    b = FinalPdfBench.reopen(b.root, inspector);
    check(b.state['current']['approved'] == true, 'Validation perdue');
    blocked(() => run(b), 'retenu');
    check(b.state['calls'] == 0, 'Retenue ignorée');
  });
  scenario('C16', () {
    final b = fresh();
    approve(b);
    b.hold(false);
    final digest = b.state['current']['digest'];
    b.simulate(
      currentSourceRevision: 'source-1',
      afterSnapshot: () {
        File(
          '${b.root.path}/copies/$digest.pdf',
        ).writeAsBytesSync(f('rapport_modifie.pdf').readAsBytesSync());
      },
    );
    final e = jsonDecode(
      File('${b.root.path}/enveloppe-fictive.json').readAsStringSync(),
    );
    check(pdfDigest(base64Decode(e['payload'])) == digest, 'Payload mutable');
    blocked(() => approve(b), 'altérée');
  });
  scenario('C17', () {
    for (final outcome in [
      'accepted',
      'signatureRejected',
      'metadataRejected',
      'timeout',
    ]) {
      var b = fresh();
      approve(b);
      b.hold(false);
      final expected = outcome == 'timeout' ? 'indeterminate' : outcome;
      check(run(b, outcome: outcome) == expected, 'Mauvaise issue');
      b = FinalPdfBench.reopen(b.root, inspector);
      blocked(() => run(b), 'renvoi bloqué');
      check(b.state['calls'] == 1, 'Nouvel appel');
      final child = Process.runSync(Platform.resolvedExecutable, [
        Platform.script.toFilePath(),
        '--reopen',
        b.root.path,
        args[2],
      ]);
      check(
        child.exitCode == 0 &&
            child.stdout.toString().contains('REOPEN_BLOCKED'),
        'Réouverture processus : ${child.stderr}',
      );
    }
    var b = fresh();
    approve(b);
    b.hold(false);
    b.simulate(currentSourceRevision: 'source-1', interrupt: true);
    b = FinalPdfBench.reopen(b.root, inspector);
    blocked(() => run(b), 'renvoi bloqué');
    check(b.state['calls'] == 0, 'Appel après interruption');
  });
  scenario('C18', () {
    final b = fresh('graphique.pdf');
    check(
      (b.state['current']['inspection']['text'] as String).trim().isEmpty,
      'Fixture image attendue',
    );
    blocked(() => run(b), 'validation médicale');
    approve(b);
    check(b.state['current']['approved'] == true, 'Revue image refusée');
  });
  scenario('C19', () {
    final b = fresh('graphique.pdf');
    approve(b);
    b.importPdf(f('graphique_modifie.pdf'), b.context(), 'source-1');
    blocked(() => run(b), 'validation médicale');
  });
  scenario('C20', () {
    for (final name in ['chiffre.pdf', 'corrompu.pdf', 'tronque.pdf']) {
      final b = fresh();
      approve(b);
      try {
        b.importPdf(f(name), b.context(), 'source-1');
        throw StateError('PDF invalide accepté');
      } on PdfBlocked {
        check(b.state['current'] == null, 'Ancienne validation conservée');
      }
      check(b.state['calls'] == 0, 'PDF invalide traité');
    }
  });
  scenario('C21', () {
    final b = fresh();
    check(b.conformity.contains('non vérifiée'), 'Conformité déduite');
    check(b.conformity.contains('aucun envoi réel'), 'Voie réelle présente');
  });
  scenario('C22', () {
    final b = fresh('abak_bilan.pdf');
    final t = b.state['current']['inspection']['text'] as String;
    for (final v in [
      'SIM-A',
      'SIM-KINE',
      'Note <sélectionnée>',
      '12 s',
      'Canne & appui',
    ]) {
      check(t.contains(v), 'Bilan : $v absent');
    }
    check(!t.contains('NOTE_EXCLUE'), 'Note exclue');
    final n = b.state['current']['inspection']['pages'] as int;
    approve(b, pages: Set.from(List.generate(n, (i) => i + 1)));
    check(
      jsonDecode(f('generateurs_ok.json').readAsStringSync())['medias'] == 3,
      'Médias absents',
    );
  });
  scenario('C23', () {
    final b = fresh('abak_rapport.pdf');
    final t = b.state['current']['inspection']['text'] as String;
    for (final v in [
      'SIM-KINE',
      'PRESCRIPTEUR-SYNTHETIQUE',
      'REFERENT-SYNTHETIQUE',
    ]) {
      check(t.contains(v), 'Rapport : $v absent');
    }
    check(
      jsonDecode(
            f('generateurs_ok.json').readAsStringSync(),
          )['correspondantsMasques'] ==
          true,
      'Option correspondants',
    );
    final n = b.state['current']['inspection']['pages'] as int;
    approve(b, pages: Set.from(List.generate(n, (i) => i + 1)));
  });
  scenario('C24', () {
    final b = fresh();
    approve(b);
    File(
      '${b.root.path}/copies/${b.state['current']['digest']}.pdf',
    ).deleteSync();
    blocked(() => run(b), 'indisponible');
    check(b.state['calls'] == 0, 'Appel sans copie');
  });
  scenario('C25', () {
    for (final ctx in [
      {'author': 'SIM-AUTRE'},
      {'visibility': 'secret'},
      {'type': 'rapport'},
    ]) {
      final b = fresh();
      approve(b);
      final c = b.context()..addAll(ctx);
      b.importPdf(f('rapport_final.pdf'), c, 'source-1');
      blocked(() => run(b), 'validation médicale');
    }
    final b = fresh();
    approve(b);
    b.importPdf(
      f('rapport_final.pdf'),
      b.context(patient: 'SIM-B'),
      'source-1',
    );
    blocked(() => approve(b, patient: 'SIM-B'), 'Patient différent');
  });
  scenario('C26', () {
    final b = fresh();
    approve(b);
    b.hold(false);
    run(b);
    final e = jsonDecode(
      File('${b.root.path}/enveloppe-fictive.json').readAsStringSync(),
    );
    check(
      e['simulation'] == true && e['profile'] == 'NON_VALIDE_DMP',
      'Enveloppe ambiguë',
    );
    check(
      pdfDigest(base64Decode(e['payload'])) == b.state['current']['digest'],
      'Payload différent',
    );
    check(e['context']['patient'] == 'SIM-A', 'Contexte différent');
  });
  File(
    '${output.path}/Resultats_26.json',
  ).writeAsStringSync(const JsonEncoder.withIndent('  ').convert(results));
  if (results.any((r) => r['result'] != 'PASS')) exitCode = 1;
}

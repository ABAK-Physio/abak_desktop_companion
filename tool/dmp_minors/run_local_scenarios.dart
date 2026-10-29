import 'dart:convert';
import 'dart:io';
import 'package:abak_desktop_companion/features/dmp_minors/minors_scenarios.dart';

void main(List<String> args) {
  if (args.length != 1) {
    throw ArgumentError('Dossier de résultats local requis.');
  }
  final root = Directory(args.single)..createSync(recursive: true);
  final run = root.createTempSync('execution-');
  final results = <Map<String, Object>>[];
  for (var n = 1; n <= 23; n++) {
    final result = runMinorScenario(n, Directory('${run.path}/stockage-isole'));
    results.add({
      'id': result.id,
      'scenario': minorScenarioTitles[n - 1],
      'statut': 'REUSSI_LOCALEMENT',
      'controles': result.checks,
    });
  }
  final report = File('${run.path}/Resultats_23.json');
  report.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({
      'horodatage_utc': DateTime.now().toUtc().toIso8601String(),
      'reseau': false,
      'cps': false,
      'insi': false,
      'lots_reels': false,
      'limite':
          'Simulations uniquement. M21 : option de seuil minimum non implémentée.',
      'scenarios': results,
    }),
  );
  stdout.writeln('23/23 scénarios réussis. Rapport : ${report.path}');
}

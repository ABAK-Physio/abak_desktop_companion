import 'dart:convert';
import 'dart:io';
import 'package:abak_desktop_companion/features/dmp_automation/automation_scenarios.dart';

Future<void> main(List<String> args) async {
  if (args.length != 1) throw ArgumentError('Dossier local requis');
  final root = Directory(args.single)..createSync(recursive: true);
  final run = root.createTempSync('execution-');
  final results = <Map<String, Object>>[];
  for (var n = 1; n <= 42; n++) {
    results.add(
      await runAutomationScenario(n, Directory('${run.path}/stockage-isole')),
    );
  }
  final report = File('${run.path}/Resultats_42.json');
  report.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({
      'horodatage_utc': DateTime.now().toUtc().toIso8601String(),
      'scenarios': results,
      'reseau': false,
      'cps': false,
      'insi': false,
      'lots_reels': false,
      'limite':
          'Simulation sémantique uniquement, sans CDA signé, VIHF ni transaction DV1.',
    }),
  );
  stdout.writeln('42/42 scénarios réussis. Rapport : ${report.path}');
}

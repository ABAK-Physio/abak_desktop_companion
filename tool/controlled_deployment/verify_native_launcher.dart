import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/services/document_native_launcher.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  final root = Directory(Platform.environment['LAUNCHER_TEST_OUTPUT']!);
  await root.create(recursive: true);
  final job = await Directory('${root.path}/job').create();
  final checks = <String>[];
  var calls = 0;
  Map<String, dynamic> answer = {};
  dynamic sent;
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  messenger.setMockMethodCallHandler(NativeDocumentLauncher.channel, (
    call,
  ) async {
    calls++;
    sent = call.arguments;
    return answer;
  });
  void check(bool ok, String label) {
    if (!ok) throw StateError(label);
    checks.add(label);
  }

  Future<void> refuses(Future<dynamic> Function() action, String label) async {
    try {
      await action();
    } catch (_) {
      checks.add(label);
      return;
    }
    throw StateError(label);
  }

  Map<String, dynamic> good() => {
    'protocol': 1,
    'pid': 123,
    'exitCode': 0,
    'stdout': 'synthetic report',
    'stderr': '',
    'files': <String, String>{},
    'isolation': {
      'networkDenied': true,
      'callerJobWriteDenied': true,
      'privateWriteSucceeded': true,
      'serviceIdentifier': 'fr.abakphysio.documentcontrols',
    },
  };
  final pdf = [
    '-cp',
    '/synthetic/vera.jar',
    'org.verapdf.apps.GreenfieldCliWrapper',
    '--format',
    'xml',
    '--flavour',
    '1b',
    '${job.path}/document.pdf',
  ];
  final version = [
    '-cp',
    '/synthetic/vera.jar',
    'org.verapdf.apps.GreenfieldCliWrapper',
    '--version',
  ];
  final cda = [
    '--class-path',
    '${job.path}/references/schematrons/moteur/saxon9he.jar',
    '${job.path}/CdaCheck.java',
    '${job.path}/references',
    job.path,
  ];
  Future<ProcessResult> run(List<String> args) => NativeDocumentLauncher.run(
    '/synthetic/bin/java',
    args,
    job,
    const Duration(seconds: 2),
  );
  try {
    await refuses(
      () => run(['-jar', '/anything.jar']),
      'Commande générique refusée avant le pont natif',
    );
    check(calls == 0, 'Aucun appel natif pour une commande non prévue');
    answer = good();
    final result = await run(pdf);
    check(
      sent['operation'] == 'pdfa' &&
          !sent.containsKey('args') &&
          result.exitCode == 0,
      'Protocole fermé PDF/A sans arguments libres',
    );
    check(
      File('${job.path}/native-launch-pdfa.json').existsSync(),
      'Preuve native conservée dans le travail',
    );
    answer = good();
    await run(version);
    check(
      sent['operation'] == 'version',
      'Version veraPDF transmise par opération explicite',
    );
    answer = {'protocol': 1, 'error': 'service indisponible'};
    await refuses(() => run(cda), 'Service indisponible bloquant sans repli');
    answer = good();
    (answer['isolation'] as Map)['networkDenied'] = false;
    await refuses(
      () => run(cda),
      'Absence de preuve d’interdiction réseau bloquante',
    );
    answer = good();
    (answer['isolation'] as Map)['callerJobWriteDenied'] = false;
    await refuses(
      () => run(cda),
      'Écriture hors du privé non interdite : refus',
    );
    answer = good();
    (answer['isolation'] as Map)['serviceIdentifier'] = 'foreign';
    await refuses(() => run(cda), 'Identité de service incorrecte refusée');
    answer = good();
    answer['files'] = {
      '../escape': base64Encode([1]),
    };
    await refuses(() => run(cda), 'Rapport avec chemin sortant refusé');
    check(
      !File('${root.path}/escape').existsSync(),
      'Aucun fichier sortant créé',
    );
    answer = good();
    answer['files'] = {
      'document.xml': base64Encode([1]),
    };
    await refuses(
      () => run(cda),
      'Document source jamais écrasé par une réponse',
    );
    answer = good();
    answer['files'] = {'xsd.xml': 'bad base64'};
    await refuses(() => run(cda), 'Rapport mal encodé refusé');
    final preserved = File('${job.path}/xsd.xml');
    preserved.writeAsStringSync('preserved');
    answer = good();
    answer['files'] = {
      'xsd.xml': base64Encode([1]),
    };
    await refuses(() => run(cda), 'Rapport existant refusé');
    check(
      preserved.readAsStringSync() == 'preserved',
      'Rapport antérieur intact',
    );
    preserved.deleteSync();
    final existingEvidence = File('${job.path}/native-launch-cda.json');
    existingEvidence.writeAsStringSync('preserved evidence');
    await refuses(() => run(cda), 'Preuve de lancement existante refusée');
    check(!preserved.existsSync() &&
        existingEvidence.readAsStringSync() == 'preserved evidence',
        'Preuve occupée : aucun rapport écrit avant le refus');
    existingEvidence.deleteSync();
    answer = good();
    answer['files'] = {
      'completed.txt': base64Encode(utf8.encode('ABAK-CDA-1')),
      'xsd.xml': base64Encode(
        utf8.encode('<xsd completed="true" valid="true"/>'),
      ),
    };
    await run(cda);
    check(
      sent['operation'] == 'cda' && !sent.containsKey('jar'),
      'CDA utilise le helper embarqué, aucune classe libre',
    );
    check(
      File('${job.path}/completed.txt').readAsStringSync() == 'ABAK-CDA-1',
      'Rapports CDA restitués exactement',
    );
    await File('${root.path}/result.json').writeAsString(
      jsonEncode({
        'passed': true,
        'checks': checks,
        'assertions': checks.length,
        'scope':
            'Protocole Dart avec service simulé, complété par recette native séparée',
      }),
    );
    exit(0);
  } catch (e, st) {
    File('${root.path}/error.txt').writeAsStringSync('$e\n$st');
    exit(1);
  }
}

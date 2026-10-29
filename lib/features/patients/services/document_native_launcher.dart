import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;

/// Only the embedded, authenticated XPC service can execute validators on macOS.
/// No shell, generic command, nested sandbox, or unprotected fallback is exposed.
class NativeDocumentLauncher {
  static const channel = MethodChannel('abak/document_controls');
  static const cdaFiles = {
    'completed.txt',
    'xsd.xml',
    'xsd-error.txt',
    'profile-0.xml',
    'profile-1.xml',
    'profile-2.xml',
    'profile-3.xml',
    'profile-4.xml',
  };
  static Future<ProcessResult> run(
    String java,
    List<String> args,
    Directory job,
    Duration timeout,
  ) async {
    String operation;
    String? jar;
    if (args.length == 8 &&
        args[0] == '-cp' &&
        args[2] == 'org.verapdf.apps.GreenfieldCliWrapper' &&
        args.sublist(3, 7).join('|') == '--format|xml|--flavour|1b' &&
        args[7] == p.join(job.path, 'document.pdf')) {
      operation = 'pdfa';
      jar = args[1];
    } else if (args.length == 4 &&
        args[0] == '-cp' &&
        args[2] == 'org.verapdf.apps.GreenfieldCliWrapper' &&
        args[3] == '--version') {
      operation = 'version';
      jar = args[1];
    } else if (args.length == 5 &&
        args[0] == '--class-path' &&
        args[1] ==
            p.join(job.path, 'references/schematrons/moteur/saxon9he.jar') &&
        args[2] == p.join(job.path, 'CdaCheck.java') &&
        args[3] == p.join(job.path, 'references') &&
        args[4] == job.path) {
      operation = 'cda';
    } else {
      throw StateError('Commande de contrôle non autorisée.');
    }
    final response = await channel
        .invokeMapMethod<String, dynamic>('run', {
          'protocol': 1,
          'operation': operation,
          'java': java,
          'job': job.path,
          'jar': ?jar,
        })
        .timeout(timeout + const Duration(seconds: 45));
    if (response == null ||
        response['protocol'] != 1 ||
        response['error'] != null) {
      throw StateError(
        'Contrôle natif non exécuté : ${response?['error'] ?? 'réponse absente'}',
      );
    }
    final isolation = response['isolation'];
    if (response['pid'] is! int ||
        response['exitCode'] is! int ||
        response['stdout'] is! String ||
        response['stderr'] is! String ||
        isolation is! Map ||
        isolation['networkDenied'] != true ||
        isolation['callerJobWriteDenied'] != true ||
        isolation['privateWriteSucceeded'] != true ||
        isolation['serviceIdentifier'] != 'fr.abakphysio.documentcontrols') {
      throw StateError('Réponse native ou isolation non vérifiée.');
    }
    for (final key in ['stdout', 'stderr']) {
      if (utf8.encode(response[key] as String).length > 12 * 1024 * 1024) {
        throw StateError('Rapport natif trop volumineux.');
      }
    }
    final files = Map<String, dynamic>.from(response['files'] as Map);
    final decoded = <String, List<int>>{};
    for (final entry in files.entries) {
      if (operation != 'cda' ||
          !cdaFiles.contains(entry.key) ||
          entry.value is! String) {
        throw StateError('Fichier de rapport inattendu.');
      }
      final bytes = base64Decode(entry.value as String);
      if (bytes.length > 12 * 1024 * 1024 ||
          await FileSystemEntity.type(
                p.join(job.path, entry.key),
                followLinks: false,
              ) !=
              FileSystemEntityType.notFound) {
        throw StateError('Rapport trop volumineux ou emplacement occupé.');
      }
      decoded[entry.key] = bytes;
    }
    final evidence = File(p.join(job.path, 'native-launch-$operation.json'));
    if (await FileSystemEntity.type(evidence.path, followLinks: false) !=
        FileSystemEntityType.notFound) {
      throw StateError('Preuve de lancement déjà présente.');
    }
    for (final entry in decoded.entries) {
      await File(
        p.join(job.path, entry.key),
      ).writeAsBytes(entry.value, flush: true);
    }
    await evidence.writeAsString(
      jsonEncode({
        'protocol': 1,
        'operation': operation,
        'pid': response['pid'],
        'exitCode': response['exitCode'],
        'isolation': isolation,
      }),
      flush: true,
    );
    return ProcessResult(
      response['pid'] as int,
      response['exitCode'] as int,
      response['stdout'],
      response['stderr'],
    );
  }
}

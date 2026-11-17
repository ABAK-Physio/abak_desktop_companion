import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'windows_cda_reports.dart';

/// Windows sends document bytes to the installed LocalService broker. No user
/// path, Java command, output folder or shell is executed by the broker.
class WindowsDocumentExecution {
  static const channel = MethodChannel('abak/document_controls');
  static const limit = 20 * 1024 * 1024;
  static String digest(List<int> bytes) => sha256.convert(bytes).toString();

  static Map<String, dynamic> validate(
    Map<String, dynamic> response, {
    required String operation,
    required Uint8List input,
    Map<String, String>? cdaIdentity,
  }) {
    final isolation = response['isolation'];
    if (response['protocol'] != 1 ||
        response['operation'] != operation ||
        response['requestId'] is! String ||
        !RegExp(r'^[0-9a-f]{32}$').hasMatch(response['requestId'] as String) ||
        response['inputHash'] !=
            (operation == 'version' ? '' : digest(input)) ||
        response['pid'] is! int ||
        (response['pid'] as int) <= 0 ||
        response['exitCode'] is! int ||
        ![0, 1].contains(response['exitCode']) ||
        response['stdout'] is! String ||
        response['stderr'] is! String ||
        isolation is! Map ||
        isolation['platform'] != 'windows' ||
        isolation['serviceIdentifier'] != 'ABAKDocumentControls' ||
        isolation['networkDenied'] != true ||
        isolation['writeRestricted'] != true ||
        isolation['jobObject'] != true ||
        isolation['restrictingSids'] != 'service+World') {
      throw StateError('Réponse du service Windows non vérifiée.');
    }
    if (utf8.encode(response['stdout'] as String).length > 8 * 1024 * 1024 ||
        utf8.encode(response['stderr'] as String).length > 1024 * 1024) {
      throw StateError('Rapport Windows trop volumineux.');
    }
    if (operation == 'docx') {
      final pdf = response['pdf'];
      if (response['exitCode'] != 0 ||
          response['sourceHash'] != digest(input) ||
          response['engineSignatureVerified'] != true ||
          response['networkDenied'] != true ||
          response['privateProfile'] != true ||
          response['macrosDisabled'] != true ||
          response['officeVersion'] is! String ||
          (response['officeVersion'] as String).isEmpty ||
          response['officeLauncherHash'] is! String ||
          !RegExp(
            r'^[0-9a-f]{64}$',
          ).hasMatch(response['officeLauncherHash'] as String) ||
          response['officeBinaryHash'] is! String ||
          !RegExp(
            r'^[0-9a-f]{64}$',
          ).hasMatch(response['officeBinaryHash'] as String) ||
          pdf is! Uint8List ||
          pdf.length < 5 ||
          pdf.length > limit ||
          ascii.decode(pdf.sublist(0, 5), allowInvalid: true) != '%PDF-' ||
          response['pdfHash'] != digest(pdf)) {
        throw StateError('Conversion Windows non vérifiée.');
      }
    } else if (operation == 'pdfa') {
      final path = response['reportedPath'];
      if (path is! String ||
          path.isEmpty ||
          path.contains('\u0000') ||
          !p.windows.isAbsolute(path) ||
          p.windows.basename(path) != 'document.pdf') {
        throw StateError('Fichier contrôlé par veraPDF non identifié.');
      }
    } else if (operation == 'cda') {
      final reports = response['cdaReports'];
      if (cdaIdentity == null ||
          cdaIdentity.length != 3 ||
          cdaIdentity.values.any((value) => !WindowsCdaReports.hash(value)) ||
          cdaIdentity.entries.any((e) => response[e.key] != e.value) ||
          !cdaIdentity.keys.toSet().containsAll({
            'referenceManifestHash',
            'referenceFilesHash',
            'helperHash',
          }) ||
          reports is! Uint8List ||
          reports.length > WindowsCdaReports.limit ||
          response['cdaReportsHash'] != digest(reports)) {
        throw StateError('Rapports ou références CDA Windows non vérifiés.');
      }
      if (response['exitCode'] == 0) {
        WindowsCdaReports.decode(reports);
      } else if (reports.isNotEmpty) {
        throw StateError('Rapports CDA reçus après une exécution interrompue.');
      }
    } else if (operation != 'version' || response['exitCode'] != 0) {
      throw StateError('Opération Windows non prise en charge.');
    }
    return response;
  }

  static Future<Map<String, dynamic>> execute({
    required String operation,
    required Uint8List input,
    String? office,
    Map<String, String>? cdaIdentity,
  }) async {
    if (!['docx', 'pdfa', 'version', 'cda'].contains(operation) ||
        input.length >
            (operation == 'cda' ? WindowsCdaReports.inputLimit : limit) ||
        (operation == 'cda' && cdaIdentity == null) ||
        (operation == 'version' ? input.isNotEmpty : input.isEmpty)) {
      throw StateError('Contenu documentaire Windows invalide.');
    }
    final response = await channel
        .invokeMapMethod<String, dynamic>('runWindows', {
          'protocol': 1,
          'operation': operation,
          'input': input,
          'inputHash': operation == 'version' ? '' : digest(input),
          'office': ?office,
        })
        .timeout(const Duration(minutes: 5));
    if (response == null) {
      throw StateError('Service documentaire Windows sans réponse.');
    }
    return validate(
      response,
      operation: operation,
      input: input,
      cdaIdentity: cdaIdentity,
    );
  }

  static Future<Map<String, dynamic>> convert(
    Uint8List input,
    String office,
  ) async {
    final response = await execute(
      operation: 'docx',
      input: input,
      office: office,
    );
    return {...response, 'pdf': base64Encode(response['pdf'] as Uint8List)};
  }

  static Future<ProcessResult> run(String operation, Directory job) async {
    if (!['pdfa', 'version'].contains(operation)) {
      throw StateError(
        'Utilisez le service dédié pour les contrôles CDA Windows.',
      );
    }
    final input = operation == 'pdfa'
        ? await File(p.join(job.path, 'document.pdf')).readAsBytes()
        : Uint8List(0);
    final evidence = File(p.join(job.path, 'native-launch-$operation.json'));
    if (await FileSystemEntity.type(evidence.path, followLinks: false) !=
        FileSystemEntityType.notFound) {
      throw StateError('Une preuve de lancement est déjà présente.');
    }
    final response = await execute(operation: operation, input: input);
    await evidence.writeAsString(
      jsonEncode({
        for (final key in [
          'protocol',
          'operation',
          'requestId',
          'pid',
          'exitCode',
          'isolation',
          'inputHash',
          'reportedPath',
        ])
          key: response[key],
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

  static Future<ProcessResult> runCda(
    Directory job,
    Map<String, Object?> configuration,
  ) async {
    final identity = WindowsCdaReports.identity(configuration);
    final evidence = File(p.join(job.path, 'native-launch-cda.json'));
    for (final name in {...WindowsCdaReports.names, 'native-launch-cda.json'}) {
      if (await FileSystemEntity.type(
            p.join(job.path, name),
            followLinks: false,
          ) !=
          FileSystemEntityType.notFound) {
        throw StateError('Un espace de preuve CDA neuf est requis.');
      }
    }
    final input = await File(p.join(job.path, 'document.xml')).readAsBytes();
    final response = await execute(
      operation: 'cda',
      input: input,
      cdaIdentity: identity,
    );
    final files = response['exitCode'] == 0
        ? WindowsCdaReports.decode(response['cdaReports'] as Uint8List)
        : <String, Uint8List>{};
    final created = <File>[];
    try {
      for (final entry in files.entries) {
        final target = File(p.join(job.path, entry.key));
        created.add(target);
        await target.writeAsBytes(entry.value, flush: true);
      }
      created.add(evidence);
      await evidence.writeAsString(
        jsonEncode({
          for (final key in [
            'protocol',
            'operation',
            'requestId',
            'pid',
            'exitCode',
            'isolation',
            'inputHash',
            'cdaReportsHash',
            ...identity.keys,
          ])
            key: response[key],
        }),
        flush: true,
      );
    } catch (_) {
      for (final file in created.reversed) {
        if (await file.exists()) await file.delete();
      }
      rethrow;
    }
    return ProcessResult(
      response['pid'] as int,
      response['exitCode'] as int,
      response['stdout'],
      response['stderr'],
    );
  }

  /// veraPDF reports the service's disposable copy. Keep its original XML;
  /// correlate that path with the hash returned by the authenticated service.
  static String reportedInputPath(File pdf) {
    final evidence = File(p.join(pdf.parent.path, 'native-launch-pdfa.json'));
    if (!evidence.existsSync()) return pdf.path;
    if (FileSystemEntity.typeSync(evidence.path, followLinks: false) !=
        FileSystemEntityType.file) {
      throw StateError('Preuve de lancement Windows invalide.');
    }
    final data = jsonDecode(evidence.readAsStringSync()) as Map;
    final isolation = data['isolation'];
    final path = data['reportedPath'];
    if (data['protocol'] != 1 ||
        data['operation'] != 'pdfa' ||
        data['inputHash'] != digest(pdf.readAsBytesSync()) ||
        isolation is! Map ||
        isolation['platform'] != 'windows' ||
        isolation['serviceIdentifier'] != 'ABAKDocumentControls' ||
        isolation['networkDenied'] != true ||
        isolation['writeRestricted'] != true ||
        isolation['jobObject'] != true ||
        path is! String ||
        !p.windows.isAbsolute(path) ||
        p.windows.basename(path) != 'document.pdf') {
      throw StateError('Rapport veraPDF lié à un autre PDF.');
    }
    return path;
  }
}

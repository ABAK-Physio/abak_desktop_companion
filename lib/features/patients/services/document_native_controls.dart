import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;
import 'package:xml/xml.dart';
import 'document_medical_service.dart';
import 'document_native_launcher.dart';
import 'document_tools_access.dart';
import 'final_pdf_document_service.dart';

const cdaProfiles = [
  'Structuration minimale',
  'IHE',
  'Modèles de contenus CDA',
  'Modèles ANS',
  'Terminologies',
];
XmlDocument controlXml(String value) {
  if (value.contains('<!DOCTYPE') ||
      value.contains('<!ENTITY') ||
      value.contains('\u0000')) {
    throw StateError('DTD/entité interdite');
  }
  return XmlDocument.parse(value);
}

String pdfaVerdict(String report, int code, File pdf) {
  try {
    final root = controlXml(report).rootElement;
    XmlElement one(XmlElement e, String n) => e.findElements(n).single;
    int count(XmlElement e, String k) => int.parse(e.getAttribute(k)!);
    final job = one(one(root, 'jobs'), 'job'),
        summary = one(root, 'batchSummary');
    if (root.name.local != 'report' || count(summary, 'totalJobs') != 1) {
      throw StateError('Nombre de tâches');
    }
    final item = one(job, 'item');
    if (one(item, 'name').innerText != pdf.path ||
        count(item, 'size') != pdf.lengthSync()) {
      throw StateError('Réponse non corrélée');
    }
    for (final k in [
      'failedToParse',
      'encrypted',
      'outOfMemory',
      'veraExceptions',
    ]) {
      if (count(summary, k) != 0) throw StateError('Exécution incomplète');
    }
    if (root.descendants.whereType<XmlElement>().any(
      (e) => ['exception', 'taskException'].contains(e.name.local),
    )) {
      throw StateError('Exception');
    }
    final totals = one(summary, 'validationReports'),
        v = one(job, 'validationReport'),
        details = one(v, 'details');
    if (root.findAllElements('validationReport').length != 1 ||
        totals.innerText.trim() != '1' ||
        count(totals, 'failedJobs') != 0 ||
        v.getAttribute('profileName') != 'PDF/A-1b validation profile' ||
        v.getAttribute('jobEndStatus') != 'normal') {
      throw StateError('Profil ou rapport incomplet');
    }
    final valid = v.getAttribute('isCompliant');
    if (!['true', 'false'].contains(valid)) throw StateError('Verdict absent');
    final ok = valid == 'true';
    for (final k in [
      'passedRules',
      'passedChecks',
      'failedRules',
      'failedChecks',
    ]) {
      if (count(details, k) < 0) throw StateError('Compteur invalide');
    }
    if (ok
        ? count(details, 'failedRules') != 0 ||
              count(details, 'failedChecks') != 0 ||
              details.descendants.whereType<XmlElement>().any(
                (e) => e.getAttribute('status') == 'failed',
              )
        : count(details, 'failedRules') < 1 ||
              count(details, 'failedChecks') < 1) {
      throw StateError('Contradiction');
    }
    if (count(totals, 'compliant') != (ok ? 1 : 0) ||
        count(totals, 'nonCompliant') != (ok ? 0 : 1) ||
        code != (ok ? 0 : 1)) {
      throw StateError('Bilan contradictoire');
    }
    return ok ? 'conforme' : 'refuse';
  } catch (_) {
    return 'non_verifie';
  }
}

class NativeControlOutput {
  const NativeControlOutput(this.pdfa, this.cda, this.message, this.files);
  final String pdfa, cda, message;
  final List<String> files;
}

abstract class DocumentControlRunner {
  Future<Map<String, Object?>> inspect(Map<String, String> paths);
  Future<NativeControlOutput> execute(
    Map<String, Object?> configuration,
    Directory job,
  );
}

/// No shell, no inherited Java options, bounded processes, no network capability.
class LocalDocumentControlRunner implements DocumentControlRunner {
  LocalDocumentControlRunner({
    Future<String> Function()? helper,
    this.timeout = const Duration(minutes: 4),
  }) : helper =
           helper ??
           (() =>
               rootBundle.loadString('assets/document_controls/CdaCheck.java'));
  final Future<String> Function() helper;
  final Duration timeout;
  static Future<void> regular(String path, {bool directory = false}) async {
    if (!p.isAbsolute(path)) throw StateError('Chemin local absolu requis');
    var current = p.normalize(path);
    while (true) {
      if (await FileSystemEntity.type(current, followLinks: false) ==
          FileSystemEntityType.link) {
        throw StateError('Lien symbolique interdit : $current');
      }
      final parent = p.dirname(current);
      if (parent == current) break;
      current = parent;
    }
    final type = await FileSystemEntity.type(path, followLinks: false);
    if (type !=
        (directory
            ? FileSystemEntityType.directory
            : FileSystemEntityType.file)) {
      throw StateError('Ressource locale indisponible : $path');
    }
  }

  static Future<Map<String, String>> tree(String root) async {
    await regular(root, directory: true);
    final files = <String, String>{};
    var total = 0;
    await for (final e in Directory(
      root,
    ).list(recursive: true, followLinks: false)) {
      if (e is Link) throw StateError('Lien dans les ressources');
      if (e is! File) continue;
      final name = p.relative(e.path, from: root);
      // Prior bench products are never references.
      if (name.contains('.bench-') ||
          p.basename(name).startsWith('abak-') ||
          name == 'unified-configuration.json') {
        continue;
      }
      final size = await e.length();
      total += size;
      if (total > 800 * 1024 * 1024 || files.length > 18000) {
        throw StateError('Ressources trop volumineuses');
      }
      files[name] = (await sha256.bind(e.openRead()).first).toString();
    }
    return files;
  }

  @override
  Future<Map<String, Object?>> inspect(Map<String, String> paths) async {
    if (!Platform.isMacOS) {
      throw StateError('Contrôles locaux disponibles sur macOS uniquement.');
    }
    final access = await DocumentToolsAccess.acquire(paths);
    try {
      return await _inspectAuthorized(paths);
    } finally {
      await access.release();
    }
  }

  Future<Map<String, Object?>> _inspectAuthorized(
    Map<String, String> paths,
  ) async {
    for (final name in ['java', 'vera', 'references', 'label']) {
      if ((paths[name] ?? '').trim().isEmpty) {
        throw StateError('Configuration incomplète : $name');
      }
    }
    await regular(paths['java']!);
    await regular(paths['vera']!);
    final refs = await tree(paths['references']!);
    for (final name in [
      'infrastructure/cda/CDA_extended.xsd',
      'schematrons/moteur/saxon9he.jar',
      'schematrons/profils/IHE.sch',
    ]) {
      if (!refs.containsKey(name)) {
        throw StateError('Référentiel CDA incomplet');
      }
    }
    final javaHome = p.dirname(p.dirname(paths['java']!));
    final runtime = await tree(javaHome);
    final jars = await tree(p.dirname(paths['vera']!));
    if (!paths['vera']!.endsWith('.jar')) {
      throw StateError('Sélectionner le fichier CLI .jar de veraPDF');
    }
    return {
      'paths': paths,
      'references': refs,
      'runtime': runtime,
      'libraries': jars,
      'helper': FinalPdfDocumentService.hash(utf8.encode(await helper())),
      'protocol': 'ABAK-CONTROLS-1',
      'profile': 'PDF/A-1b',
      'cdaProfiles': cdaProfiles,
    };
  }

  Future<ProcessResult> process(
    String java,
    List<String> args,
    Directory job,
  ) async {
    return NativeDocumentLauncher.run(java, args, job, timeout);
  }

  @override
  Future<NativeControlOutput> execute(
    Map<String, Object?> configuration,
    Directory job,
  ) async {
    final access = await DocumentToolsAccess.acquire(
      Map<String, String>.from(configuration['paths'] as Map),
    );
    try {
      return await _executeAuthorized(configuration, job);
    } finally {
      await access.release();
    }
  }

  Future<NativeControlOutput> _executeAuthorized(
    Map<String, Object?> configuration,
    Directory job,
  ) async {
    final paths = Map<String, String>.from(configuration['paths'] as Map);
    final files = <String>[];
    var privateReferencesCreated = false;
    var pdfa = 'non_verifie', cda = 'non_verifie';
    final messages = <String>[];
    Future<void> write(String n, String s) async {
      await File(p.join(job.path, n)).writeAsString(s, flush: true);
      files.add(n);
    }

    try {
      if (medicalHash(await inspect(paths)) != medicalHash(configuration)) {
        throw StateError('Outils ou références modifiés');
      }
      final cp = await process(paths['java']!, [
        '-cp',
        paths['vera']!,
        'org.verapdf.apps.GreenfieldCliWrapper',
        '--format',
        'xml',
        '--flavour',
        '1b',
        p.join(job.path, 'document.pdf'),
      ], job);
      await write('verapdf.xml', cp.stdout as String);
      await write('verapdf.stderr', cp.stderr as String);
      await write('verapdf-exit.txt', '${cp.exitCode}');
      pdfa = pdfaVerdict(
        cp.stdout as String,
        cp.exitCode,
        File(p.join(job.path, 'document.pdf')),
      );
      final version = await process(paths['java']!, [
        '-cp',
        paths['vera']!,
        'org.verapdf.apps.GreenfieldCliWrapper',
        '--version',
      ], job);
      await write(
        'validator-version.txt',
        '${version.stdout}\n${version.stderr}',
      );
    } catch (e) {
      messages.add('PDF/A non vérifié : $e');
    }
    try {
      if (!File(p.join(job.path, 'document.xml')).existsSync()) {
        throw StateError('Contexte CDA non représentable');
      }
      final refs = Map<String, String>.from(configuration['references'] as Map);
      final scratch = Directory(p.join(job.path, 'references'));
      if (await FileSystemEntity.type(scratch.path, followLinks: false) !=
          FileSystemEntityType.notFound) {
        throw StateError('Un espace de contrôle neuf est requis');
      }
      await scratch.create();
      privateReferencesCreated = true;

      for (final item in refs.entries) {
        final src = File(p.join(paths['references']!, item.key));
        final bytes = await src.readAsBytes();
        if (FinalPdfDocumentService.hash(bytes) != item.value) {
          throw StateError('Référentiel modifié');
        }
        final dst = File(p.join(job.path, 'references', item.key));
        await dst.parent.create(recursive: true);
        await dst.writeAsBytes(bytes, flush: true);
      }
      await write('CdaCheck.java', await helper());
      final cp = await process(paths['java']!, [
        '--class-path',
        p.join(job.path, 'references/schematrons/moteur/saxon9he.jar'),
        p.join(job.path, 'CdaCheck.java'),
        p.join(job.path, 'references'),
        job.path,
      ], job);
      await write(
        'cda-execution.txt',
        'exit=${cp.exitCode}\n${cp.stdout}\n${cp.stderr}',
      );
      if (cp.exitCode != 0 ||
          File(p.join(job.path, 'completed.txt')).readAsStringSync() !=
              'ABAK-CDA-1') {
        throw StateError('Exécution CDA non aboutie');
      }
      files.addAll(['completed.txt', 'xsd.xml']);
      final xsd = controlXml(
        File(p.join(job.path, 'xsd.xml')).readAsStringSync(),
      ).rootElement;
      if (xsd.name.local != 'xsd' ||
          xsd.getAttribute('completed') != 'true' ||
          !['true', 'false'].contains(xsd.getAttribute('valid'))) {
        throw StateError('Preuve XSD incomplète');
      }
      var rejected = xsd.getAttribute('valid') != 'true';
      if (File(p.join(job.path, 'xsd-error.txt')).existsSync()) {
        files.add('xsd-error.txt');
      }
      for (var n = 0; n < cdaProfiles.length; n++) {
        final name = 'profile-$n.xml';
        final r = controlXml(
          File(p.join(job.path, name)).readAsStringSync(),
        ).rootElement;
        const ns = 'http://purl.oclc.org/dsdl/svrl';
        if (r.name.local != 'schematron-output' ||
            r.namespaceUri != ns ||
            r.findAllElements('active-pattern', namespaceUri: ns).isEmpty) {
          throw StateError('Rapport ${cdaProfiles[n]} incomplet');
        }
        final failures = r
            .findAllElements('failed-assert', namespaceUri: ns)
            .toList();
        rejected |= failures.isNotEmpty;
        files.add(name);
        messages.addAll(
          failures
              .take(3)
              .map((e) => e.innerText.trim().replaceAll(RegExp(r'\s+'), ' ')),
        );
      }
      cda = rejected ? 'refuse' : 'conforme';
    } catch (e) {
      messages.add('CDA non vérifié : $e');
    }
    // Only disposable copies created in this job are removed. Reports, the
    // PDF/CDA and the full reference hash manifest remain durable evidence.
    // Reopening verifies the original configured reference bundle; it never reruns.
    if (privateReferencesCreated) {
      try {
        await Directory(p.join(job.path, 'references')).delete(recursive: true);
      } catch (_) {
        messages.add(
          'Copies temporaires des références conservées : nettoyage local à prévoir.',
        );
      }
    }
    for (final operation in ['pdfa', 'version', 'cda']) {
      final name = 'native-launch-$operation.json';
      if (await File(p.join(job.path, name)).exists()) files.add(name);
    }
    return NativeControlOutput(pdfa, cda, messages.join('\n'), files);
  }
}

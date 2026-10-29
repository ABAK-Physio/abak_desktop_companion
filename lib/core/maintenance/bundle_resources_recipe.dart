// Visible only in maintenance with the signed recipe-only native channel.
// This uses the product validator and bundled helper, never the business database.
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import '../../features/patients/services/document_native_controls.dart';
import '../../features/patients/services/document_medical_service.dart';
import 'maintenance_session.dart';

class BundleResourcesRecipePanel extends StatefulWidget {
  const BundleResourcesRecipePanel({super.key, required this.root});
  final String root;
  @override
  State<BundleResourcesRecipePanel> createState() =>
      _BundleResourcesRecipePanelState();
}

class _BundleResourcesRecipePanelState
    extends State<BundleResourcesRecipePanel> {
  String message = 'Ressources de recette : contrôle local disponible.';
  bool busy = false, finished = false;
  File get report =>
      File(p.join(widget.root, 'native-resources', 'result.json'));
  static const channel = MethodChannel('abak/bundle_resources_recipe');

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    try {
      await channel.invokeMapMethod<String, dynamic>('context');
      if (await report.exists()) {
        final value = jsonDecode(await report.readAsString()) as Map;
        if (mounted) {
          setState(() {
            finished = true;
            message =
                '${value['message']} Résultat conservé ; aucune nouvelle exécution.';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          finished = true;
          message = 'Recette indisponible : $e';
        });
      }
    }
  }

  Future<void> _run() async {
    if (busy || finished) return;
    setState(() {
      busy = true;
      message = 'Vérification des ressources restaurées, puis PDF/A et CDA…';
    });
    final checks = <String>[];
    void check(bool ok, String label) {
      if (!ok) throw StateError(label);
      checks.add(label);
    }

    var passed = false;
    Map<String, dynamic>? context;
    String? generation;
    try {
      context = await channel.invokeMapMethod<String, dynamic>('context');
      generation = context?['generation'] as String?;
      check(
        context?['identity'] is String &&
            (context!['identity'] as String).startsWith(
              'fr.abakphysio.maintenance.recipe.',
            ),
        'Identité native de recette vérifiée',
      );
      check(
        generation != null && p.isWithin(widget.root, generation),
        'Application exécutée depuis la génération restaurée autorisée',
      );
      await regularMaintenancePath(generation!, directory: true);
      final descriptor = Map<String, dynamic>.from(
        jsonDecode(
              await File(p.join(generation, 'resources.json')).readAsString(),
            )
            as Map,
      );
      check(
        descriptor['format'] == 'ABAK-DURABLE-RESOURCES-RECIPE-1',
        'Paquet de ressources identifié',
      );
      final relative = Map<String, String>.from(descriptor['paths'] as Map);
      final paths = <String, String>{'label': descriptor['label'] as String};
      for (final entry in relative.entries) {
        check(
          !p.isAbsolute(entry.value) &&
              p.normalize(entry.value) == entry.value &&
              !p.split(entry.value).contains('..'),
          'Chemin de ressource relatif sûr : ${entry.key}',
        );
        paths[entry.key] = p.join(generation, entry.value);
      }
      final runner = LocalDocumentControlRunner();
      final config = await runner.inspect(paths);
      for (final key in ['runtime', 'libraries', 'references', 'helper']) {
        check(
          medicalHash(config[key]) == medicalHash(descriptor[key]),
          'Ressource restaurée identique : $key',
        );
      }
      final job = Directory(p.join(widget.root, 'native-resources'));
      check(!await job.exists(), 'Espace de preuve synthétique neuf');
      await job.create();
      for (final name in ['document.pdf', 'document.xml']) {
        final bytes = await File(
          p.join(generation, 'fixtures', name),
        ).readAsBytes();
        check(
          sha256.convert(bytes).toString() ==
              (descriptor['fixtures'] as Map)[name],
          'Témoin synthétique exact : $name',
        );
        await File(p.join(job.path, name)).writeAsBytes(bytes, flush: true);
      }
      await File(
        p.join(job.path, 'configuration.json'),
      ).writeAsString(jsonEncode(config), flush: true);
      final result = await runner.execute(config, job);
      await File(p.join(job.path, 'native-verdicts.json')).writeAsString(
        jsonEncode({
          'pdfa': result.pdfa,
          'cda': result.cda,
          'message': result.message,
          'files': result.files,
        }),
        flush: true,
      );
      check(
        result.pdfa == 'conforme',
        'veraPDF restauré : ${result.pdfa}. ${result.message}',
      );
      check(
        result.cda == 'conforme',
        'Références restaurées : CDA conforme (${result.cda}) ${result.message}',
      );
      check(
        medicalHash(await runner.inspect(paths)) == medicalHash(config),
        'Ressources intactes après exécution',
      );
      passed = true;
      message =
          'PDF/A-1b conforme. CDA conforme. ${checks.length} contrôles réussis. Aucun envoi.';
    } catch (e) {
      message = 'Contrôle des ressources non validé : $e. Aucun envoi.';
    }
    await report.parent.create(recursive: true);
    await report.writeAsString(
      const JsonEncoder.withIndent('  ').convert({
        'passed': passed,
        'message': message,
        'checks': checks,
        'identity': context?['identity'],
        'generation': generation,
        'pid': pid,
        'atUTC': DateTime.now().toUtc().toIso8601String(),
        'networkUsed': false,
        'CPSUsed': false,
        'realLotsUsed': false,
      }),
      flush: true,
    );
    if (mounted) {
      setState(() {
        busy = false;
        finished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Recette du bundle restauré — documents synthétiques uniquement.',
      ),
      Text(message),
      OutlinedButton(
        onPressed: busy || finished ? null : _run,
        child: const Text('Vérifier les ressources restaurées'),
      ),
      const SizedBox(height: 12),
    ],
  );
}

import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/settings/macos_directory_access_service.dart';
import 'unified_demo.dart';

class UnifiedScreen extends StatefulWidget {
  const UnifiedScreen({super.key, this.simulationRoot, this.loader});
  final Directory? simulationRoot;
  final Future<Uint8List> Function(String)? loader;
  @override
  State<UnifiedScreen> createState() => _UnifiedScreenState();
}

class _UnifiedScreenState extends State<UnifiedScreen> {
  UnifiedDemo? demo;
  MacosDirectoryAccess? access;
  Timer? timer;
  bool busy = false;
  String error = '';
  bool reviewed = false,
      clinical = false,
      patient = false,
      contextChecked = false;
  @override
  void initState() {
    super.initState();
    open();
    timer = Timer.periodic(const Duration(seconds: 1), (_) => poll());
  }

  @override
  void dispose() {
    timer?.cancel();
    access?.release();
    super.dispose();
  }

  Future<Uint8List> asset(String n) async => widget.loader != null
      ? widget.loader!(n)
      : (await rootBundle.load(
          'assets/dmp_local/pdf_cda_unified/$n',
        )).buffer.asUint8List();
  Future<File> pointer() async => File(
    '${(await getApplicationSupportDirectory()).path}/dmp-unified-demo-directory.txt',
  );
  Future<void> open({bool choose = false}) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      Directory? root = widget.simulationRoot;
      if (root == null) {
        final service = const MacosDirectoryAccessService();
        final p = await pointer();
        if (choose) {
          final selected = await service.chooseDirectory(
            title: 'Choisir le dossier de démonstration PDF/A et CDA',
          );
          if (selected == null) return;
          await access?.release();
          access = selected;
          root = Directory(selected.path);
        } else if (p.existsSync()) {
          access = await service.acquireDirectory(p.readAsStringSync());
          root = Directory(access!.path);
        }
        if (root == null) return;
      }
      final d = await UnifiedDemo.open(root, asset);
      if (widget.simulationRoot == null) {
        (await pointer()).writeAsStringSync(root.path, flush: true);
      }
      demo = d;
      error = '';
      reset();
    } catch (_) {
      demo = null;
      error =
          'Dossier, autorisation ou preuves indisponibles. Actions suspendues.';
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void reset() {
    reviewed = false;
    clinical = false;
    patient = false;
    contextChecked = false;
  }

  Future<void> action(void Function() f) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      f();
      error = '';
    } catch (_) {
      error =
          'Contrôle bloqué : vérifier le service local, la version et les preuves.';
    }
    if (mounted) setState(() => busy = false);
  }

  Future<void> poll() async {
    if (busy || demo == null || error.isNotEmpty) return;
    try {
      await demo!.poll();
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Résultat non corrélé ou stockage altéré. Actions suspendues.',
        );
      }
    }
  }

  String label(dynamic s) => switch (s) {
    'conforme' => 'Conforme',
    'refuse' => 'Non conforme',
    'en_cours' => 'En cours',
    _ => 'Non vérifié',
  };
  @override
  Widget build(BuildContext context) {
    final d = demo;
    final locked = busy || error.isNotEmpty || d?.pending.isNotEmpty == true;
    return Scaffold(
      appBar: AppBar(title: const Text('DMP — parcours PDF/A et CDA isolé')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DÉMONSTRATION SYNTHÉTIQUE — aucun envoi',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Dossier dédié. Aucun réseau, aucune CPS ni fonction INSi. Aucun effet sur les lots réels.',
            ),
            const Text(
              'Lancez le service local hors réseau, puis choisissez son dossier. Les échanges utilisent uniquement des fichiers.',
            ),
            OutlinedButton(
              key: const Key('directory'),
              onPressed: busy ? null : () => open(choose: true),
              child: const Text('Choisir le dossier de démonstration'),
            ),
            if (error.isNotEmpty) Text(error, key: const Key('error')),
            if (busy) const LinearProgressIndicator(),
            if (d != null) ...[
              Text(
                d.ready
                    ? 'Service local disponible.'
                    : 'Service local absent ou occupé. Aucun nouveau contrôle disponible.',
                key: const Key('service'),
              ),
              DropdownButton<String>(
                key: const Key('fixture'),
                isExpanded: true,
                value: d.fixture,
                items: (d.catalog['fixtures'] as Map).entries
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e.key,
                        child: Text(e.value['label']),
                      ),
                    )
                    .toList(),
                onChanged: locked
                    ? null
                    : (v) => action(() {
                        d.select(v!);
                        reset();
                      }),
              ),
              Text(
                'Patient SIM-A · épisode SIM-E1 · auteur SIM-KINE · structure SIM-CABINET',
              ),
              Text(
                'Titre : ${d.catalog['context']['title']} · date : ${d.catalog['context']['date']}',
              ),
              Text(
                'Type ${d.catalog['context']['type']} · classe ${d.catalog['context']['class']} · confidentialité ${d.catalog['context']['confidentiality']} · version CDA ${d.catalog['context']['version']}',
              ),
              Text('PDF : ${d.current['digest']}'),
              if (error.isEmpty)
                Center(
                  child: Image.memory(
                    d.page(0),
                    key: const Key('preview'),
                    height: 280,
                    fit: BoxFit.contain,
                  ),
                ),
              if (d.clinicalBlocked)
                const Text(
                  'Contenu clinique absent : validation bloquée, même si le format est conforme.',
                  key: Key('empty'),
                ),
              Text(
                d.approved
                    ? 'Validation clinique conservée pour cette version.'
                    : 'Cette version nécessite une validation clinique.',
                key: const Key('clinical-state'),
              ),
              CheckboxListTile(
                key: const Key('review'),
                title: const Text('J’ai examiné la page du PDF synthétique'),
                value: reviewed,
                onChanged: locked || d.approved || d.clinicalBlocked
                    ? null
                    : (v) => setState(() => reviewed = v!),
              ),
              CheckboxListTile(
                key: const Key('clinical'),
                title: const Text(
                  'Le document contient les informations cliniques fictives attendues',
                ),
                value: clinical,
                onChanged: locked || d.approved || d.clinicalBlocked
                    ? null
                    : (v) => setState(() => clinical = v!),
              ),
              CheckboxListTile(
                key: const Key('patient'),
                title: const Text('Le PDF correspond au patient fictif SIM-A'),
                value: patient,
                onChanged: locked || d.approved || d.clinicalBlocked
                    ? null
                    : (v) => setState(() => patient = v!),
              ),
              CheckboxListTile(
                key: const Key('context'),
                title: const Text(
                  'Je confirme le contexte synthétique affiché pour cette version',
                ),
                value: contextChecked,
                onChanged: locked || d.approved || d.clinicalBlocked
                    ? null
                    : (v) => setState(() => contextChecked = v!),
              ),
              FilledButton(
                key: const Key('approve'),
                onPressed:
                    !locked &&
                        !d.approved &&
                        !d.clinicalBlocked &&
                        reviewed &&
                        clinical &&
                        patient &&
                        contextChecked
                    ? () => action(
                        () => d.approve({1}, clinical, patient, contextChecked),
                      )
                    : null,
                child: const Text('Valider cette version synthétique'),
              ),
              DropdownButton<String>(
                key: const Key('mode'),
                isExpanded: true,
                value: d.mode,
                items: const [
                  DropdownMenuItem(
                    value: 'native',
                    child: Text('Contrôles natifs locaux'),
                  ),
                  DropdownMenuItem(
                    value: 'missing',
                    child: Text('Service indisponible — erreur simulée'),
                  ),
                  DropdownMenuItem(
                    value: 'different',
                    child: Text('PDF encapsulé différent — erreur simulée'),
                  ),
                ],
                onChanged: locked ? null : (v) => action(() => d.setMode(v!)),
              ),
              FilledButton(
                key: const Key('run'),
                onPressed:
                    !locked &&
                        d.approved &&
                        !d.clinicalBlocked &&
                        d.ready &&
                        d.result['status'] != 'conforme'
                    ? () => action(d.request)
                    : null,
                child: const Text('Lancer les contrôles locaux'),
              ),
              if (d.pending.isNotEmpty)
                const Text(
                  'Contrôles demandés. Aucune relance automatique.',
                  key: Key('pending'),
                ),
              Text(
                'PDF/A-1b : ${label(d.result['pdfStatus'])}',
                key: const Key('pdf-status'),
              ),
              Text(
                'CDA : ${label(d.result['cdaStatus'])}',
                key: const Key('cda-status'),
              ),
              Text(
                d.result.isEmpty
                    ? 'Contenu encapsulé : non contrôlé.'
                    : d.result['contentMatch'] == true
                    ? 'Contenu encapsulé : identique au PDF validé.'
                    : d.result['status'] == 'non_verifie'
                    ? 'Contenu encapsulé : non vérifié.'
                    : 'Contenu encapsulé différent ou contexte non corrélé.',
                key: const Key('content'),
              ),
              if (d.result.isNotEmpty)
                Text(d.result['message'], key: const Key('result')),
            ],
            const Text(
              'Retenue permanente · appels de transport : 0. Les contrôles techniques ne remplacent pas la validation clinique.',
            ),
            const FilledButton(
              key: Key('send'),
              onPressed: null,
              child: Text('Envoi indisponible — banc isolé'),
            ),
          ],
        ),
      ),
    );
  }
}

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'native_archive.dart';

class NativeArchiveScreen extends StatefulWidget {
  const NativeArchiveScreen({super.key, this.simulationRoot, this.loader});
  final Directory? simulationRoot;
  final ArchiveLoader? loader;
  @override
  State<NativeArchiveScreen> createState() => _NativeArchiveScreenState();
}

class _NativeArchiveScreenState extends State<NativeArchiveScreen> {
  NativeArchive? archive;
  bool failed = false, busy = true;
  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    try {
      final root =
          widget.simulationRoot ??
          Directory(
            '${(await getApplicationSupportDirectory()).path}/dmp-pdf-cda-native-demo-v1',
          );
      final a = NativeArchive(
        root,
        widget.loader ??
            (name) async => (await rootBundle.load(
              'assets/dmp_local/pdf_cda_native/$name',
            )).buffer.asUint8List(),
      );
      await a.open();
      archive = a;
    } catch (_) {
      failed = true;
    }
    if (mounted) setState(() => busy = false);
  }

  Future<void> action(Future<void> Function() fn) async {
    setState(() => busy = true);
    try {
      await fn();
    } catch (_) {
      failed = true;
    }
    if (mounted) setState(() => busy = false);
  }

  String status(Map<String, dynamic> r) => switch (r['status']) {
    'conforme' => 'Conforme aux contrôles archivés',
    'refuse' => 'Non conforme — contrôle refusé',
    'non_verifie' => 'Non vérifié — validation non aboutie',
    _ => 'Non évalué — aucune preuve CDA pour ce scénario',
  };
  @override
  Widget build(BuildContext context) {
    final a = archive;
    return Scaffold(
      appBar: AppBar(title: const Text('DMP — contrôles PDF/A et CDA isolés')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ARCHIVES NATIVES — documents synthétiques uniquement',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Aucun réseau, aucune CPS ni fonction INSi. Stockage réservé à cet écran, sans effet sur les lots réels.',
            ),
            const Text(
              'Résultats archivés du 17/10/2026 : veraPDF 1.30.3, PDF/A-1b et contrôles CDA locaux. Cet écran ne relance aucun validateur. PDF/A-1a non attesté.',
            ),
            if (busy) const LinearProgressIndicator(),
            if (failed)
              const Text(
                'Preuves ou stockage indisponibles ou altérés. Actions suspendues.',
                key: Key('failure'),
              ),
            if (a != null && !failed) ...[
              DropdownButton<String>(
                key: const Key('scenario'),
                isExpanded: true,
                value: a.selected,
                items: a.cases
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e['id'],
                        child: Text(e['label']),
                      ),
                    )
                    .toList(),
                onChanged: busy ? null : (v) => action(() => a.select(v!)),
              ),
              Text('PDF/A-1b : ${status(a.pdf)}', key: const Key('pdf-status')),
              Text('CDA : ${status(a.cda)}', key: const Key('cda-status')),
              if (a.pdf['status'] == 'non_verifie')
                const Text(
                  'Cette erreur ne permet pas de conclure à une conformité ou à une non-conformité PDF/A.',
                ),
              if (a.current['clinicalBlock'] == true)
                const Text(
                  'Contenu clinique absent dans ce témoin : validation bloquée malgré la conformité technique.',
                ),
              if (!a.conform)
                const Text(
                  'Contrôles techniques incomplets ou refusés : poursuite bloquée.',
                ),
              if (a.canRecord)
                const Text(
                  'Les contrôles techniques ne valent pas validation médicale. La revue du PDF final reste nécessaire dans le parcours dédié.',
                ),
              Text('Empreinte PDF : ${a.pdf['sha256']}'),
              Text(
                a.examined
                    ? 'Résultats techniques examinés — état conservé.'
                    : 'Résultats techniques à examiner.',
                key: const Key('review-state'),
              ),
              FilledButton(
                key: const Key('record'),
                onPressed: !busy && a.canRecord && !a.examined
                    ? () => action(a.record)
                    : null,
                child: const Text('Marquer les résultats techniques examinés'),
              ),
            ],
            const Text(
              'Retenue permanente. Aucun envoi possible depuis cet écran. Appels : 0.',
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

import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'final_pdf_bench.dart';
import 'pdf_demo.dart';

class PdfDemoScreen extends StatefulWidget {
  const PdfDemoScreen({
    super.key,
    this.simulationRoot,
    this.fixtureLoader,
    this.popplerBin,
  });
  final Directory? simulationRoot;
  final Future<Uint8List> Function(String)? fixtureLoader;
  final String? popplerBin;
  @override
  State<PdfDemoScreen> createState() => _PdfDemoScreenState();
}

class _PdfDemoScreenState extends State<PdfDemoScreen> {
  PdfDemo? demo;
  Directory? base;
  LocalPdfInspector? inspector;
  Map<String, dynamic>? data;
  bool busy = true, clinical = false, patient = false;
  int pageIndex = 0;
  Set<int> reviewed = {};
  String selected = 'rapport_final.pdf', message = '', outcome = 'accepted';
  Uint8List? preview;
  @override
  void initState() {
    super.initState();
    open();
  }

  void resetReview() {
    reviewed = {};
    clinical = false;
    patient = false;
    pageIndex = 0;
  }

  void refresh() {
    data = demo!.bench.state;
    final c = data!['current'];
    preview = c == null ? null : demo!.page(c, pageIndex);
  }

  Future<void> act(Future<void> Function() action) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      await action();
      refresh();
    } catch (e) {
      message = e is PdfBlocked
          ? e.message
          : 'Stockage ou outils locaux indisponibles. Actions suspendues.';
      try {
        data = demo?.bench.state;
      } catch (_) {
        data = null;
      }
      preview = null; // never approve a failed or stale preview
    }
    if (mounted) setState(() => busy = false);
  }

  Future<void> open({bool fresh = false}) async {
    try {
      base =
          widget.simulationRoot ??
          Directory(
            '${(await getApplicationSupportDirectory()).path}/dmp-pdf-demo-v1',
          );
      if (widget.popplerBin != null) {
        inspector = LocalPdfInspector(widget.popplerBin!);
      } else {
        final entries =
            jsonDecode(utf8.decode(await asset('manifest.json')))
                as Map<String, dynamic>;
        final images = <String, Uint8List>{};
        for (final entry in entries.values) {
          for (final image in (entry['images'] as Map).values) {
            final name = image['asset'] as String;
            if (!RegExp(r'^[a-z_]+-page-\d+\.png$').hasMatch(name)) {
              throw const PdfBlocked('Fixture invalide.');
            }
            images[name] = await asset(name);
          }
        }
        inspector = BundledPdfInspector(entries, images);
      }
      demo = PdfDemo.open(
        Directory('${base!.path}/exercises'),
        inspector!,
        fresh: fresh,
      );
      resetReview();
      refresh();
      message = 'Stockage fictif prêt. Aucun envoi réseau.';
    } catch (e) {
      data = null;
      preview = null;
      message = e is PdfBlocked ? e.message : 'Stockage isolé indisponible.';
    }
    if (mounted) setState(() => busy = false);
  }

  Future<Uint8List> asset(String name) async => widget.fixtureLoader != null
      ? await widget.fixtureLoader!(name)
      : (await rootBundle.load(
          'assets/dmp_local/pdf_demo/$name',
        )).buffer.asUint8List();
  Future<void> load() => act(() async {
    final bytes = await asset(selected);
    resetReview();
    demo!.importFixture(selected, bytes);
    message = 'PDF fictif importé. Examiner toutes les pages avant validation.';
  });
  Future<void> approve() async {
    if (data?['current']?['inspection']?['allWhite'] == true) return;
    final reviewedVersion = data?['current']?['id'];
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Valider cette version fictive ?'),
        content: const Text(
          'Confirmez la revue de toutes les pages, le contenu clinique et le patient SIM-A. Aucun traitement n’est lancé par cette validation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            key: const Key('confirm'),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmer la validation fictive'),
          ),
        ],
      ),
    );
    if (yes != true || !mounted) return;
    await act(() async {
      if (demo!.bench.state['current']?['id'] != reviewedVersion) {
        throw const PdfBlocked('Version modifiée : recommencer la revue.');
      }
      demo!.bench.approve(
        reviewedPages: reviewed,
        clinicalContent: clinical,
        reviewedPatient: patient ? 'SIM-A' : 'non-confirme',
        currentSourceRevision: 'source-fictive-1',
        consent: true,
      );
      message = 'Version fictive validée. La retenue reste inchangée.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = data?['current'] as Map<String, dynamic>?;
    final pages = c?['inspection']['pages'] as int? ?? 0;
    final approved = c?['approved'] == true, held = c?['held'] == true;
    final attempted = (data?['attempts'] as Map?)?.isNotEmpty ?? false;
    final ready = !busy && demo != null && data != null;
    final allWhite = c?['inspection']['allWhite'] == true;
    final canApprove =
        ready &&
        preview != null &&
        !approved &&
        !allWhite &&
        !attempted &&
        clinical &&
        patient &&
        reviewed.length == pages;
    return Scaffold(
      appBar: AppBar(title: const Text('DMP — PDF final simulé')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'SIMULATION LOCALE — aucun réseau, aucune CPS ni fonction INSi.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const Text(
                'Documents synthétiques uniquement. Stockage séparé des dossiers et lots réels. Cette démonstration ne valide pas la conformité DMP/PDF-A.',
              ),
              const SizedBox(height: 12),
              DropdownButton<String>(
                key: const Key('fixture'),
                value: selected,
                isExpanded: true,
                items: PdfDemo.fixtures.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: !ready ? null : (v) => setState(() => selected = v!),
              ),
              FilledButton(
                key: const Key('import'),
                onPressed: ready ? load : null,
                child: const Text('Importer le PDF synthétique'),
              ),
              if (busy) const LinearProgressIndicator(),
              Text(message, key: const Key('message')),
              if (c != null) ...[
                Text(
                  'Patient : SIM-A • épisode SIM-E1 • auteur SIM-KINE\nVersion : ${(c['digest'] as String).substring(0, 12)}',
                ),
                Text(
                  allWhite
                      ? 'Page blanche détectée : validation bloquée.'
                      : approved
                      ? 'Validation conservée pour cette version.'
                      : 'Cette version nécessite une validation.',
                  key: const Key('validationStatus'),
                ),
                Text(
                  'Appels fictifs cumulés : ${data!['calls']}',
                  key: const Key('calls'),
                ),
                if (attempted)
                  const Text(
                    'Tentative conservée : renvoi bloqué.',
                    key: Key('blocked'),
                  ),
                if (attempted)
                  Text(switch ((data!['attempts'] as Map)
                      .values
                      .last['outcome']) {
                    'accepted' => 'Résultat conservé : accepté en simulation.',
                    'metadataRejected' =>
                      'Résultat conservé : métadonnées rejetées.',
                    'signatureRejected' =>
                      'Résultat conservé : signature rejetée.',
                    _ => 'Résultat conservé : indéterminé, contrôle requis.',
                  }, key: const Key('storedOutcome')),
                Text(
                  'Page ${pageIndex + 1} sur $pages',
                  key: const Key('pageNumber'),
                ),
                if (preview != null)
                  SizedBox(
                    height: 420,
                    child: InteractiveViewer(
                      maxScale: 5,
                      child: Image.memory(
                        preview!,
                        key: ValueKey('${c['id']}-$pageIndex'),
                        fit: BoxFit.contain,
                        gaplessPlayback: false,
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      key: const Key('previous'),
                      onPressed: ready && pageIndex > 0
                          ? () => act(() async {
                              pageIndex--;
                            })
                          : null,
                      child: const Text('Page précédente'),
                    ),
                    TextButton(
                      key: const Key('next'),
                      onPressed: ready && pageIndex + 1 < pages
                          ? () => act(() async {
                              pageIndex++;
                            })
                          : null,
                      child: const Text('Page suivante'),
                    ),
                  ],
                ),
                CheckboxListTile(
                  key: const Key('reviewPage'),
                  title: const Text('J’ai examiné cette page'),
                  value: reviewed.contains(pageIndex + 1),
                  onChanged: ready && preview != null && !approved
                      ? (v) => setState(() {
                          if (v == true) {
                            reviewed.add(pageIndex + 1);
                          } else {
                            reviewed.remove(pageIndex + 1);
                          }
                        })
                      : null,
                ),
                CheckboxListTile(
                  key: const Key('clinical'),
                  title: const Text(
                    'Le document contient des informations cliniques fictives',
                  ),
                  value: clinical,
                  onChanged: ready && !approved
                      ? (v) => setState(() => clinical = v!)
                      : null,
                ),
                CheckboxListTile(
                  key: const Key('patient'),
                  title: const Text(
                    'Le document correspond au patient fictif SIM-A',
                  ),
                  value: patient,
                  onChanged: ready && !approved
                      ? (v) => setState(() => patient = v!)
                      : null,
                ),
                FilledButton(
                  key: const Key('validate'),
                  onPressed: canApprove ? approve : null,
                  child: const Text('Valider cette version fictive'),
                ),
                SwitchListTile(
                  key: const Key('held'),
                  title: const Text('Retenir le traitement fictif'),
                  value: held,
                  onChanged: ready && !attempted
                      ? (v) => act(() async {
                          demo!.bench.hold(v);
                          message = v
                              ? 'Traitement retenu. Aucun appel fictif.'
                              : 'Retenue levée. Vous pouvez lancer le traitement fictif.';
                        })
                      : null,
                ),
                DropdownButton<String>(
                  key: const Key('outcome'),
                  value: outcome,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(
                      value: 'accepted',
                      child: Text('Succès fictif'),
                    ),
                    DropdownMenuItem(
                      value: 'metadataRejected',
                      child: Text('Rejet fictif'),
                    ),
                    DropdownMenuItem(
                      value: 'timeout',
                      child: Text('Résultat indéterminé fictif'),
                    ),
                  ],
                  onChanged: ready && !attempted
                      ? (v) => setState(() => outcome = v!)
                      : null,
                ),
                FilledButton(
                  key: const Key('process'),
                  onPressed:
                      ready &&
                          preview != null &&
                          approved &&
                          !allWhite &&
                          !held &&
                          !attempted
                      ? () => act(() async {
                          final result = demo!.bench.simulate(
                            currentSourceRevision: 'source-fictive-1',
                            outcome: outcome,
                          );
                          message = switch (result) {
                            'accepted' =>
                              'Traitement fictif accepté. Renvoi bloqué.',
                            'metadataRejected' =>
                              'Métadonnées rejetées en simulation. Aucun réessai automatique.',
                            _ =>
                              'Résultat indéterminé en simulation. Renvoi bloqué.',
                          };
                        })
                      : null,
                  child: const Text('Lancer le traitement fictif'),
                ),
              ],
              const SizedBox(height: 12),
              OutlinedButton(
                key: const Key('fresh'),
                onPressed: !busy
                    ? () async {
                        setState(() => busy = true);
                        await open(fresh: true);
                      }
                    : null,
                child: const Text(
                  'Nouvel exercice isolé — conserver le précédent',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

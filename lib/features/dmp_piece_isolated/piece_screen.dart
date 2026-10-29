import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/settings/macos_directory_access_service.dart';
import '../dmp_pdf_isolated/final_pdf_bench.dart';
import 'piece_demo.dart';

class PieceScreen extends StatefulWidget {
  const PieceScreen({super.key, this.root});
  final Directory? root;
  @override
  State<PieceScreen> createState() => _PieceScreenState();
}

class _PieceScreenState extends State<PieceScreen> {
  PieceDemo? demo;
  MacosDirectoryAccess? access;
  Timer? timer;
  final previews = <Uint8List>[];
  final reviewed = <int>{};
  int page = 0;
  bool busy = false, clinical = false, identity = false;
  String error = '', reviewVersion = '', previewKey = '';
  static const modes = {
    'coherent': 'Pièce PDF conforme — SIM-DOC1',
    'second': 'Autre pièce, même PDF — SIM-DOC2',
    'wrong_patient': 'Pièce d’un autre patient',
    'wrong_episode': 'Pièce d’un autre épisode',
    'archived': 'Pièce archivée',
    'nia': 'Identité NIA',
    'unavailable': 'Fichier source indisponible',
    'blank': 'Page blanche',
    'header': 'En-tête sans contenu clinique',
    'changed_pdf': 'PDF modifiable',
    'changed_identity': 'Identité modifiable',
    'changed_link': 'Rattachement modifiable',
    'different': 'Identité CDA différente',
  };
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

  Future<File> pointer() async => File(
    '${(await getApplicationSupportDirectory()).path}/dmp-piece-demo-directory.txt',
  );
  void resetReview() {
    reviewed.clear();
    clinical = false;
    identity = false;
    page = 0;
  }

  void loadPreviews() {
    final d = demo!;
    final s = d.state;
    final current = '${s['binding']}:${s['pdfSha']}';
    if (reviewVersion != s['binding']) {
      resetReview();
      reviewVersion = s['binding'];
    }
    if (previewKey == current) return;
    previews.clear();
    for (final p in s['previews'] as List) {
      final f = d.file(p['path']);
      if (f.lengthSync() > 8 * 1024 * 1024) {
        throw StateError('Aperçu trop volumineux');
      }
      final bytes = f.readAsBytesSync();
      if (pdfDigest(bytes) != p['sha256']) {
        throw StateError('Aperçu altéré');
      }
      previews.add(bytes);
    }
    page = 0;
    previewKey = current;
  }

  Future<void> open({bool choose = false}) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      Directory? root = widget.root;
      if (root == null) {
        final p = await pointer();
        const service = MacosDirectoryAccessService();
        if (choose) {
          final a = await service.chooseDirectory(
            title: 'Choisir le dossier pièce PDF synthétique',
          );
          if (a == null) return;
          await access?.release();
          access = a;
          root = Directory(a.path);
        } else if (p.existsSync()) {
          access = await service.acquireDirectory(p.readAsStringSync());
          root = Directory(access!.path);
        }
        if (root == null) return;
      }
      demo = PieceDemo(root);
      previewKey = '';
      resetReview();
      loadPreviews();
      error = '';
      if (widget.root == null) {
        (await pointer()).writeAsStringSync(root.path, flush: true);
      }
      if (demo!.ready && demo!.pending.isEmpty && demo!.error.isEmpty) {
        demo!.send('refresh');
      }
    } catch (_) {
      demo = null;
      previews.clear();
      error = 'Dossier ou preuves indisponibles. Actions suspendues.';
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void poll() {
    if (busy || demo == null || error.isNotEmpty) return;
    try {
      demo!.read();
      loadPreviews();
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        setState(() => error = 'État ou aperçu altéré : actions suspendues.');
      }
    }
  }

  void send(String action, {String? mode}) {
    try {
      demo!.send(
        action,
        mode: mode,
        binding: reviewVersion,
        review: action == 'approve'
            ? {
                'pages': reviewed.toList()..sort(),
                'clinical': clinical,
                'patient': identity ? demo!.state['patient'] : '',
                'contextConfirmed': identity,
              }
            : null,
      );
      resetReview();
    } catch (_) {
      error = 'Commande bloquée : vérifier le service et la version.';
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final d = demo;
    final s = d?.state ?? {};
    final locked =
        busy ||
        error.isNotEmpty ||
        d == null ||
        !d.ready ||
        d.pending.isNotEmpty;
    final eligible =
        (s['binding'] ?? '').isNotEmpty &&
        s['clinicalCandidate'] == true &&
        s['status'] != 'bloque';
    final reviewable = !locked && eligible && s['approved'] != true;
    final c = s['context'] as Map? ?? {};
    return Scaffold(
      appBar: AppBar(title: const Text('DMP — pièce PDF et identité simulées')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SIMULATION LOCALE — pièces et identités synthétiques',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Aucun réseau, CPS ou INSi. Stockage dédié, aucun lot réel. Lancez le service pièce PDF hors réseau puis choisissez son dossier.',
            ),
            OutlinedButton(
              key: const Key('directory'),
              onPressed: busy ? null : () => open(choose: true),
              child: const Text('Choisir le dossier pièce PDF synthétique'),
            ),
            if (error.isNotEmpty) Text(error, key: const Key('error')),
            if (d != null) ...[
              Text(
                d.ready
                    ? 'Service local disponible.'
                    : 'Service absent ou occupé : nouvelles actions bloquées.',
              ),
              DropdownButton<String>(
                key: const Key('mode'),
                isExpanded: true,
                value: s['mode'],
                items: modes.entries
                    .map(
                      (e) =>
                          DropdownMenuItem(value: e.key, child: Text(e.value)),
                    )
                    .toList(),
                onChanged: locked ? null : (v) => send('select', mode: v),
              ),
              Text(
                'Pièce ${s['document']} · épisode ${s['episode']} · ${s['title']}',
                key: const Key('piece'),
              ),
              Text(
                'Patient ${s['patient']} · ${s['given']} ${s['family']} · naissance ${s['birthDate']}',
                key: const Key('identity'),
              ),
              if (c.isNotEmpty)
                Text(
                  'Contexte fictif : auteur ${c['author']} · structure ${c['structure']} · type ${c['type']} · classe ${c['class']} · confidentialité ${c['confidentiality']} · date ${c['date']}',
                ),
              Text(
                'Version de pièce et d’identité : ${s['binding']}',
                key: const Key('version'),
              ),
              if (previews.isNotEmpty) ...[
                Center(
                  child: Image.memory(
                    previews[page],
                    height: 260,
                    key: ValueKey('${s['pdfSha']}:$page'),
                  ),
                ),
                OutlinedButton(
                  key: const Key('zoom'),
                  onPressed: locked
                      ? null
                      : () {
                          final bytes = previews[page];
                          showDialog<void>(
                            context: context,
                            builder: (dialogContext) => AlertDialog(
                              title: Text(
                                'Pièce ${s['document']} — page ${page + 1}',
                              ),
                              content: SizedBox(
                                width: 1000,
                                height: MediaQuery.sizeOf(context).height * .7,
                                child: InteractiveViewer(
                                  minScale: 1,
                                  maxScale: 5,
                                  trackpadScrollCausesScale: true,
                                  child: Center(
                                    child: Image.memory(
                                      bytes,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                              actions: [
                                TextButton(
                                  key: const Key('close-preview'),
                                  onPressed: () =>
                                      Navigator.of(dialogContext).pop(),
                                  child: const Text('Fermer l’aperçu'),
                                ),
                              ],
                            ),
                          );
                        },
                  child: const Text('Agrandir l’aperçu — zoom disponible'),
                ),
                Row(
                  children: [
                    TextButton(
                      key: const Key('previous'),
                      onPressed: locked || page == 0
                          ? null
                          : () => setState(() => page--),
                      child: const Text('Page précédente'),
                    ),
                    Text('Page ${page + 1} sur ${previews.length}'),
                    TextButton(
                      key: const Key('next'),
                      onPressed: locked || page + 1 >= previews.length
                          ? null
                          : () => setState(() => page++),
                      child: const Text('Page suivante'),
                    ),
                  ],
                ),
                CheckboxListTile(
                  key: const Key('page-review'),
                  title: const Text('J’ai examiné cette page de la pièce PDF'),
                  value: reviewed.contains(page + 1),
                  onChanged: reviewable
                      ? (v) => setState(() {
                          if (v!) {
                            reviewed.add(page + 1);
                          } else {
                            reviewed.remove(page + 1);
                          }
                        })
                      : null,
                ),
              ],
              Text(
                s['approved'] == true
                    ? 'Confirmation conservée pour cette pièce et cette version.'
                    : 'Confirmation de cette pièce et de cette version requise.',
                key: const Key('approval'),
              ),
              CheckboxListTile(
                key: const Key('clinical'),
                title: const Text(
                  'La pièce contient des informations cliniques fictives',
                ),
                value: clinical,
                onChanged: reviewable
                    ? (v) => setState(() => clinical = v!)
                    : null,
              ),
              CheckboxListTile(
                key: const Key('confirm'),
                title: const Text(
                  'La pièce, l’épisode, l’identité affichée et le contexte documentaire correspondent',
                ),
                value: identity,
                onChanged: reviewable
                    ? (v) => setState(() => identity = v!)
                    : null,
              ),
              FilledButton(
                key: const Key('approve'),
                onPressed:
                    reviewable &&
                        clinical &&
                        identity &&
                        previews.isNotEmpty &&
                        reviewed.length == previews.length
                    ? () => send('approve')
                    : null,
                child: const Text('Confirmer cette pièce et cette version'),
              ),
              if ([
                'changed_pdf',
                'changed_identity',
                'changed_link',
              ].contains(s['mode']))
                OutlinedButton(
                  key: const Key('change'),
                  onPressed: locked ? null : () => send('change'),
                  child: Text(
                    s['mode'] == 'changed_pdf'
                        ? 'Simuler une modification du PDF'
                        : s['mode'] == 'changed_identity'
                        ? 'Simuler une modification de l’identité'
                        : 'Simuler un changement d’épisode',
                  ),
                ),
              FilledButton(
                key: const Key('run'),
                onPressed:
                    !locked &&
                        eligible &&
                        s['approved'] == true &&
                        s['status'] != 'conforme' &&
                        s['status'] != 'en_cours'
                    ? () => send('run')
                    : null,
                child: const Text('Contrôler le PDF et le CDA localement'),
              ),
              Text(switch (s['status']) {
                'conforme' => 'Contrôles PDF/A et CDA conformes',
                'bloque' => 'Préparation bloquée',
                'refuse' => 'Contrôles refusés',
                'validee' =>
                  'Confirmation enregistrée — contrôles non vérifiés',
                'en_cours' => 'Contrôles en cours',
                _ => 'Contrôles non vérifiés',
              }, key: const Key('status')),
              Text(s['message'] ?? '', key: const Key('message')),
              Text(
                'Contrôles natifs lancés : ${s['nativeJobs']}',
                key: const Key('native-count'),
              ),
              if (d.pending.isNotEmpty)
                const Text(
                  'Commande en cours. Aucune relance automatique.',
                  key: Key('pending'),
                ),
              if (d.error.isNotEmpty)
                Text(d.error, key: const Key('command-error')),
            ],
            const Text('Retenue permanente · appels de transport : 0.'),
            const FilledButton(
              key: Key('send'),
              onPressed: null,
              child: Text('Envoi indisponible — démonstration isolée'),
            ),
          ],
        ),
      ),
    );
  }
}

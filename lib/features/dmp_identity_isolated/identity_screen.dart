import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import '../../core/settings/macos_directory_access_service.dart';
import '../dmp_pdf_cda_unified/ui_assets_digest.dart';
import '../dmp_pdf_isolated/final_pdf_bench.dart';
import 'identity_demo.dart';

class IdentityScreen extends StatefulWidget {
  const IdentityScreen({super.key, this.root, this.loader});
  final Directory? root;
  final Future<Uint8List> Function(String)? loader;
  @override
  State<IdentityScreen> createState() => _IdentityScreenState();
}

class _IdentityScreenState extends State<IdentityScreen> {
  IdentityDemo? demo;
  MacosDirectoryAccess? access;
  Timer? timer;
  Uint8List? preview;
  bool busy = false, confirmed = false;
  String error = '', reviewVersion = '';
  static const modes = {
    'qualified': 'Identité qualifiée synthétique',
    'doubtful': 'Identité douteuse',
    'nia': 'Identifiant NIA',
    'missing': 'Identité incomplète',
    'changed': 'Identité modifiée',
    'different': 'Identité CDA différente',
    'unavailable': 'Source indisponible',
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

  Future<Uint8List> asset(String n) async => widget.loader != null
      ? widget.loader!(n)
      : (await rootBundle.load(
          'assets/dmp_local/pdf_cda_unified/$n',
        )).buffer.asUint8List();
  Future<File> pointer() async => File(
    '${(await getApplicationSupportDirectory()).path}/dmp-identity-demo-directory.txt',
  );
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
            title: 'Choisir le dossier identité synthétique',
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
      final d = IdentityDemo(root);
      final raw = await asset('manifest.json');
      if (pdfDigest(raw) != unifiedAssetsDigest) {
        throw StateError('Catalogue altéré');
      }
      final catalog = jsonDecode(utf8.decode(raw));
      final pdf = await asset(catalog['fixtures']['positif']['file']);
      if (pdfDigest(pdf) != d.state['pdfSha']) {
        throw StateError('PDF différent');
      }
      final images = catalog['entries'][d.state['pdfSha']]['images'] as Map;
      final image = images.values.first;
      final bytes = await asset(image['asset']);
      if (pdfDigest(bytes) != image['sha256']) {
        throw StateError('Aperçu altéré');
      }
      preview = bytes;
      demo = d;
      reviewVersion = d.state['binding'];
      confirmed = false;
      error = '';
      if (widget.root == null) {
        (await pointer()).writeAsStringSync(root.path, flush: true);
      }
      if (d.ready && d.pending.isEmpty && d.error.isEmpty) d.send('refresh');
    } catch (_) {
      demo = null;
      error = 'Dossier ou preuves indisponibles. Actions suspendues.';
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void poll() {
    if (busy || demo == null || error.isNotEmpty) return;
    try {
      demo!.read();
      if (reviewVersion != demo!.state['binding']) {
        confirmed = false;
        reviewVersion = demo!.state['binding'];
      }
      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) setState(() => error = 'État altéré : actions suspendues.');
    }
  }

  void send(String action, {String? mode}) {
    try {
      demo!.send(action, mode: mode, binding: reviewVersion);
      confirmed = false;
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
    final eligible = (s['binding'] ?? '').isNotEmpty && s['status'] != 'bloque';
    return Scaffold(
      appBar: AppBar(title: const Text('DMP — identité qualifiée simulée')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DONNÉES SYNTHÉTIQUES — aucune qualification INS officielle',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const Text(
              'Aucun réseau, CPS ou INSi. Stockage dédié, aucun lot réel. Lancez le service identité hors réseau puis choisissez son dossier.',
            ),
            OutlinedButton(
              key: const Key('directory'),
              onPressed: busy ? null : () => open(choose: true),
              child: const Text('Choisir le dossier identité synthétique'),
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
                'Patient ${s['patient']} · ${s['given']} ${s['family']} · naissance ${s['birthDate']}',
                key: const Key('identity'),
              ),
              Text(
                'Version liée au PDF et à l’identité : ${s['binding']}',
                key: const Key('version'),
              ),
              if (preview != null)
                Center(child: Image.memory(preview!, height: 240)),
              Text(
                s['approved'] == true
                    ? 'Confirmation conservée pour cette version.'
                    : 'Confirmation de cette version requise.',
                key: const Key('approval'),
              ),
              CheckboxListTile(
                key: const Key('confirm'),
                title: const Text(
                  'J’ai examiné le PDF, son contenu clinique et sa correspondance avec l’identité synthétique affichée',
                ),
                value: confirmed,
                onChanged: locked || !eligible || s['approved'] == true
                    ? null
                    : (v) => setState(() => confirmed = v!),
              ),
              FilledButton(
                key: const Key('approve'),
                onPressed:
                    !locked && eligible && confirmed && s['approved'] != true
                    ? () => send('approve')
                    : null,
                child: const Text('Confirmer cette version et cette identité'),
              ),
              if (s['mode'] == 'changed')
                OutlinedButton(
                  key: const Key('change'),
                  onPressed: locked ? null : () => send('change'),
                  child: const Text('Simuler une modification de l’identité'),
                ),
              FilledButton(
                key: const Key('run'),
                onPressed:
                    !locked &&
                        eligible &&
                        s['approved'] == true &&
                        s['status'] != 'conforme'
                    ? () => send('run')
                    : null,
                child: const Text('Contrôler le PDF et le CDA localement'),
              ),
              Text(switch (s['status']) {
                'conforme' => 'Contrôles conformes',
                'bloque' => 'Préparation bloquée',
                'validee' => 'Confirmation enregistrée',
                'en_cours' => 'Contrôles en cours',
                _ => 'Contrôles non vérifiés',
              }, key: const Key('status')),
              Text(s['message'] ?? '', key: const Key('message')),
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

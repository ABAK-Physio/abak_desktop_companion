import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:file_picker/file_picker.dart';
import 'body_map_adapter.dart';
import 'joint_map_adapter.dart';
import 'joint_regions.dart';
import 'regions.dart';
import 'pain_record.dart';
import 'bodymap_repository.dart';

class EpisodeBodymapScreen extends StatefulWidget {
  const EpisodeBodymapScreen({
    super.key,
    required this.careEpisodeId,
    required this.patientId,
    required this.patientName,
    required this.episodeLabel,
    this.repository,
  });
  final String careEpisodeId;
  final String patientId;
  final String patientName;
  final String episodeLabel;
  final BodymapRepository? repository;
  @override
  State<EpisodeBodymapScreen> createState() => _EpisodeBodymapScreenState();
}

class _EpisodeBodymapScreenState extends State<EpisodeBodymapScreen> {
  Map<String, PainEntry> entries = {};
  String? active;
  int view = 0;
  bool exporting = false;
  Map<String, String> get labels => {...regionLabels, ...jointLabels};
  Map<String, String> get viewLabels => view == 0 ? regionLabels : jointLabels;
  Map<String, PainEntry> get visibleEntries => Map.fromEntries(
    entries.entries.where(
      (e) =>
          view == 0 ? !e.key.startsWith('joint:') : e.key.startsWith('joint:'),
    ),
  );
  void switchView(int value) {
    setState(() {
      view = value;
      active = null;
      note.clear();
    });
  }

  late final BodymapRepository repository;
  bool loading = true;
  bool loadFailed = false;
  bool leaving = false;
  @override
  void initState() {
    super.initState();
    repository = widget.repository ?? BodymapRepository();
    load();
  }

  bool dirty = false;
  bool busy = false;
  String status = 'Chargement du relevé…';
  final note = TextEditingController();
  final captureKey = GlobalKey();
  @override
  void dispose() {
    note.dispose();
    super.dispose();
  }

  void select(String id) {
    if (!labels.containsKey(id)) return;
    setState(() {
      entries.putIfAbsent(id, () => PainEntry());
      active = id;
      note.text = entries[id]!.note;
      dirty = true;
    });
  }

  Future<void> guarded(Future<void> Function() action) async {
    setState(() => busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) setState(() => status = 'Échec : $e');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> save() => guarded(() async {
    if (loading || loadFailed) return;
    final record = PainRecord(entries);
    await repository.save(
      careEpisodeId: widget.careEpisodeId,
      patientId: widget.patientId,
      record: record,
    );
    if (mounted) {
      setState(() {
        dirty = false;
        status =
            'Carte enregistrée pour cet épisode · ${entries.length} zone(s).';
      });
    }
  });
  Future<void> load() async {
    setState(() {
      loading = true;
      loadFailed = false;
    });
    try {
      final record = await repository.load(
        careEpisodeId: widget.careEpisodeId,
        patientId: widget.patientId,
      );
      if (!mounted) return;
      setState(() {
        entries = record?.entries ?? {};
        dirty = false;
        status = record == null
            ? 'Aucune carte enregistrée pour cet épisode.'
            : 'Carte enregistrée le ${DateTime.parse(record.date).toLocal().toString().substring(0, 10)} · ${entries.length} zone(s).';
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          loadFailed = true;
          status = 'Impossible de charger la carte : $e';
        });
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> close() async {
    if (busy || loading || leaving) return;
    if (dirty) {
      final choice = await showDialog<String>(
        context: context,
        builder: (c) => AlertDialog(
          title: const Text('Enregistrer la carte des douleurs ?'),
          content: const Text(
            'Les modifications de cet épisode ne sont pas encore enregistrées.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: const Text('Continuer la saisie'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(c, 'discard'),
              child: const Text('Quitter sans enregistrer'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(c, 'save'),
              child: const Text('Enregistrer et fermer'),
            ),
          ],
        ),
      );
      if (choice == null || !mounted) return;
      if (choice == 'save') {
        await save();
        if (dirty || !mounted) return;
      }
    }
    if (!mounted) return;
    setState(() => leaving = true);
    await WidgetsBinding.instance.endOfFrame;
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> export() => guarded(() async {
    final location = await FilePicker.platform.saveFile(
      dialogTitle: 'Exporter la carte des douleurs',
      fileName: 'carte-douleurs.png',
      type: FileType.custom,
      allowedExtensions: ['png'],
    );
    if (location == null) return;
    if (!mounted) return;
    await precacheImage(
      const AssetImage('assets/bodymap/rheumatoid_man.png'),
      context,
    );
    if (!mounted) return;
    setState(() => exporting = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      await WidgetsBinding.instance.endOfFrame;
      final boundary =
          captureKey.currentContext!.findRenderObject()
              as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      await File(
        location,
      ).writeAsBytes(bytes!.buffer.asUint8List(), flush: true);
      if (mounted) setState(() => status = 'Deux cartes exportées : $location');
    } finally {
      if (mounted) setState(() => exporting = false);
    }
  });
  Widget chart(double width, int chartView) {
    final articular = chartView == 1;
    final subset = Map.fromEntries(
      entries.entries.where((e) => articular == e.key.startsWith('joint:')),
    );
    return ColoredBox(
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${widget.patientName} — ${widget.episodeLabel}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              articular
                  ? 'ARTICULATIONS / RACHIS'
                  : 'MUSCLES / RÉGIONS CORPORELLES',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              articular
                  ? 'Vue de face · Côtés du patient'
                  : 'Face à gauche · Dos à droite — côtés du patient',
              style: const TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 16),
            if (!articular)
              const Row(
                children: [
                  Expanded(
                    child: Text(
                      'D → FACE ← G',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'G → DOS ← D',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            if (!articular)
              const Text(
                'D : droite du patient · G : gauche du patient',
                style: TextStyle(fontSize: 11),
              ),
            if (articular)
              JointMapAdapter(
                selected: subset.keys.toSet(),
                width: width - 40,
                onSelect: busy ? null : select,
              )
            else
              BodyMapAdapter(
                selected: subset.keys.toSet(),
                width: width - 40,
                onSelect: busy ? null : select,
              ),
            const SizedBox(height: 12),
            Text(
              articular
                  ? 'Rheumatoid Man · Dr Blaine Vlantis, Université du Cap\nSource : github.com/ctsit/imagemap'
                  : 'bodyheatmap 1.0.0 · MIT',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Text(
              '${subset.length} zone(s) · Couleur = localisation uniquement',
            ),
            for (final e in subset.entries)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  '${labels[e.key]} : ${e.value.intensity == null ? 'intensité non renseignée' : '${e.value.intensity}/10'}${e.value.note.isEmpty ? '' : ' — ${e.value.note}'}',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            const SizedBox(height: 12),
            const Text(
              'Carte des douleurs · Version d’évaluation',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget charts(double width) => RepaintBoundary(
    key: captureKey,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (exporting) ...[
          chart(width, 0),
          const SizedBox(height: 20),
          chart(width, 1),
        ] else
          chart(width, view),
      ],
    ),
  );
  Widget editor() {
    final entry = entries[active];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Votre relevé',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cliquez sur une zone, puis précisez votre observation. Pour la retirer, utilisez la corbeille.',
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: ValueKey(view),
              initialValue: null,
              isExpanded: true,
              decoration: InputDecoration(
                labelText:
                    'Explorer les ${viewLabels.length} zones de cette vue',
                border: OutlineInputBorder(),
              ),
              items: viewLabels.entries
                  .map(
                    (e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(
                        e.value,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: busy
                  ? null
                  : (v) {
                      if (v != null) select(v);
                    },
            ),
            const SizedBox(height: 16),
            if (visibleEntries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text('Aucune zone sélectionnée.'),
              ),
            for (final e in visibleEntries.entries)
              ListTile(
                dense: true,
                selected: active == e.key,
                contentPadding: EdgeInsets.zero,
                title: Text(labels[e.key]!),
                subtitle: Text(
                  e.value.intensity == null
                      ? 'Intensité non renseignée'
                      : '${e.value.intensity}/10',
                ),
                onTap: busy
                    ? null
                    : () {
                        setState(() {
                          active = e.key;
                          note.text = e.value.note;
                        });
                      },
                trailing: IconButton(
                  tooltip: 'Retirer la zone',
                  onPressed: busy
                      ? null
                      : () {
                          setState(() {
                            entries.remove(e.key);
                            if (active == e.key) {
                              active = null;
                              note.clear();
                            }
                            dirty = true;
                          });
                        },
                  icon: const Icon(Icons.delete_outline),
                ),
              ),
            if (entry != null) ...[
              const Divider(height: 28),
              Text(
                labels[active]!,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                key: ValueKey('$active-${entry.intensity}'),
                initialValue: entry.intensity ?? -1,
                decoration: const InputDecoration(
                  labelText: 'Intensité facultative',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem(
                    value: -1,
                    child: Text('Non renseignée'),
                  ),
                  for (var i = 0; i <= 10; i++)
                    DropdownMenuItem(value: i, child: Text('$i / 10')),
                ],
                onChanged: busy
                    ? null
                    : (v) {
                        setState(() {
                          entry.intensity = v == -1 ? null : v;
                          dirty = true;
                        });
                      },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: note,
                enabled: !busy,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Commentaire sur cette zone',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) {
                  entry.note = v;
                  setState(() => dirty = true);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: leaving,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) close();
    },
    child: Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Retour aux bilans et rapports',
          icon: const Icon(Icons.arrow_back),
          onPressed: busy || loading ? null : close,
        ),
        title: Text('${widget.patientName} — Carte des douleurs'),
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : loadFailed
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(status),
                  const SizedBox(height: 16),
                  FilledButton(onPressed: load, child: const Text('Réessayer')),
                ],
              ),
            )
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text('${widget.episodeLabel} · Version d’évaluation'),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      FilledButton.icon(
                        onPressed: busy || !dirty ? null : save,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Enregistrer'),
                      ),
                      OutlinedButton.icon(
                        onPressed: busy ? null : export,
                        icon: const Icon(Icons.image_outlined),
                        label: const Text('Exporter les deux cartes'),
                      ),
                      Text(
                        dirty
                            ? 'Modifications non enregistrées'
                            : 'Relevé de cet épisode',
                      ),
                    ],
                  ),
                ),
                DefaultTabController(
                  length: 2,
                  child: IgnorePointer(
                    ignoring: busy,
                    child: TabBar(
                      onTap: switchView,
                      tabs: [
                        Tab(
                          text:
                              'Muscles (${entries.keys.where((k) => !k.startsWith('joint:')).length})',
                        ),
                        Tab(
                          text:
                              'Articulations / rachis (${entries.keys.where((k) => k.startsWith('joint:')).length})',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, c) {
                      final wide = c.maxWidth >= 950;
                      final w = wide
                          ? (c.maxWidth * .57).clamp(400.0, 850.0)
                          : c.maxWidth - 48;
                      return SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                        child: wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(width: w, child: charts(w)),
                                  const SizedBox(width: 20),
                                  Expanded(child: editor()),
                                ],
                              )
                            : Column(
                                children: [
                                  charts(w),
                                  const SizedBox(height: 16),
                                  editor(),
                                ],
                              ),
                      );
                    },
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  child: Text(status, style: const TextStyle(fontSize: 12)),
                ),
              ],
            ),
    ),
  );
}

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:printing/printing.dart';
import 'package:xml/xml.dart';
import 'consulted_document.dart';

/// No file, export, print, browser or persistent document cache is created.
class DmpConsultationViewer extends StatefulWidget {
  const DmpConsultationViewer({
    super.key,
    required this.document,
    this.checkContext,
  });
  final ConsultedDocument document;
  final VoidCallback? checkContext;
  @override
  State<DmpConsultationViewer> createState() => _DmpConsultationViewerState();
}

class _DmpConsultationViewerState extends State<DmpConsultationViewer>
    with WidgetsBindingObserver {
  final pages = <Uint8List>[];
  Timer? contextCheck;
  bool closing = false;
  bool ready = false, headerSeen = false;
  String? error;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    contextCheck = Timer.periodic(const Duration(seconds: 1), (_) {
      try {
        widget.checkContext?.call();
      } catch (_) {
        closeUnconfirmed();
      }
    });
    render();
  }

  void closeUnconfirmed() {
    if (mounted && !closing) {
      closing = true;
      Navigator.pop(context, false);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      closeUnconfirmed();
    }
  }

  Future<void> render() async {
    try {
      var data = widget.document.payload;
      final media = widget.document.mediaType;
      if (['image/tiff', 'application/rtf', 'text/rtf'].contains(media)) {
        final result = await const MethodChannel(
          'abak/dmp_consultation_display',
        ).invokeMethod<Uint8List>('pdf', {'bytes': data, 'mime': media});
        if (result == null) throw StateError('Conversion locale indisponible.');
        data = result;
      }
      if (media == 'application/pdf' ||
          ['image/tiff', 'application/rtf', 'text/rtf'].contains(media)) {
        await for (final p in Printing.raster(
          data!,
          dpi: 90,
        ).timeout(const Duration(seconds: 45))) {
          if (!mounted) return;
          if (pages.length >= 100 || p.width * p.height > 20000000) {
            throw StateError('Document trop volumineux pour cet afficheur.');
          }
          final png = await p.toPng();
          if (!mounted) {
            png.fillRange(0, png.length, 0);
            return;
          }
          pages.add(png);
        }
        if (pages.isEmpty) throw StateError('PDF sans page affichable.');
      } else if (media == 'image/jpeg') {
        // Decode before enabling the success confirmation.
        final image = await decodeImageFromList(data!);
        image.dispose();
        if (!mounted) return;
        pages.add(Uint8List.fromList(data));
      } else if (media == 'text/plain') {
        utf8.decode(
          data!,
        ); // Reject unsupported encodings, do not show corrupt text.
      }
      if (mounted) setState(() => ready = true);
    } catch (_) {
      if (mounted) {
        setState(
          () => error =
              'Affichage impossible ou format trop volumineux. PRE_CONS_CONS non validé.',
        );
      }
    }
  }

  @override
  void dispose() {
    contextCheck?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    for (final page in pages) {
      unawaited(
        MemoryImage(
          page,
        ).evict().then((_) => page.fillRange(0, page.length, 0)),
      );
    }
    pages.clear();
    super.dispose();
  }

  Widget narrative(XmlNode n, [int depth = 0]) {
    if (depth > 30) return const Text('Structure trop imbriquée.');
    if (n is XmlText) return Text(n.value);
    if (n is! XmlElement) return const SizedBox.shrink();
    if (n.namespaceUri != ConsultedDocument.ns) {
      return const Text('Contenu étranger non exécuté.');
    }
    if (['script', 'iframe', 'style'].contains(n.name.local)) {
      return const SizedBox.shrink();
    }
    if (n.name.local == 'table') {
      final rows = n.descendants
          .whereType<XmlElement>()
          .where((e) => e.name.local == 'tr')
          .toList();
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rows
              .map(
                (row) => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: row.childElements
                      .map(
                        (c) => Container(
                          width: 200,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Text(c.innerText),
                        ),
                      )
                      .toList(),
                ),
              )
              .toList(),
        ),
      );
    }
    if (n.name.local == 'renderMultiMedia') {
      return const Text(
        'Média de section : non affiché dans cette vue narrative.',
      );
    }
    if (n.childElements.isEmpty) return Text(n.innerText);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: n.children.map((c) => narrative(c, depth + 1)).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.document;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation temporaire — provenance DMP'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            d.metadata['title'] ?? '',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          Text(
            'Document ${d.metadata['uniqueId']}\nAucune copie permanente. Fermer termine la consultation.',
          ),
          for (final warning in d.warnings)
            Card(
              color: Colors.amber.shade100,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(warning),
              ),
            ),
          ExpansionTile(
            title: const Text(
              'En-tête CDA — patient, auteur, dates et contexte',
            ),
            onExpansionChanged: (v) {
              if (v) setState(() => headerSeen = true);
            },
            children: [SelectableText(d.header)],
          ),
          if (error != null) Text(error!),
          if (!ready && error == null) const LinearProgressIndicator(),
          for (final page in pages)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Image.memory(page),
            ),
          if (ready && d.mediaType == 'text/plain')
            SelectableText(utf8.decode(d.payload!)),
          if (d.sections.isNotEmpty)
            ExpansionTile(
              initiallyExpanded: d.payload == null,
              title: const Text('Contenu structuré CDA'),
              children: [
                for (final section in d.sections)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ConsultedDocument.children(
                            section,
                            'title',
                          ).map((e) => e.innerText).join(' '),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        for (final text in ConsultedDocument.children(
                          section,
                          'text',
                        ))
                          narrative(text),
                      ],
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: ready && headerSeen && error == null
                ? () => Navigator.pop(context, true)
                : null,
            child: const Text('Contenu et en-tête affichés — terminer le test'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Fermer sans valider le test'),
          ),
        ],
      ),
    );
  }
}

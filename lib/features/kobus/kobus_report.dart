import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../generated/l10n.dart';

String kobusStatusLabel(String status, S s) => switch (status) {
  'imported' => s.kobus_imported,
  'rejected' => s.kobus_rejected,
  'failed' => s.kobus_failed,
  'interrupted' => s.kobus_interrupted,
  'skipped' => s.kobus_skip,
  _ => s.kobus_unresolved,
};

String kobusReportText(
  Map<String, Object?> run,
  List<Map<String, Object?>> rows,
  String status,
  S s,
) {
  final selected = rows.where((r) => r['status'] == status).toList();
  return [
    '${s.kobus_title} — ${kobusStatusLabel(status, s)}',
    DateFormat.yMd().add_Hm().format(
      DateTime.fromMillisecondsSinceEpoch(run['started_at'] as int),
    ),
    '${run['zip_name']} • ${selected.length}',
    for (final row in selected)
      '\n${row['source_path']}\n${row['shared'] == 1 ? "${s.kobus_sharedOrigin} — ${row['practitioner']}" : s.kobus_ownOrigin}\n${row['identity_label']}\n${row['reason']}\n${row['warnings']}',
  ].join('\n');
}

Future<Uint8List> kobusReportPdf(String text, {ByteData? fontData}) async {
  final font = pw.Font.ttf(
    fontData ?? await rootBundle.load('assets/fonts/DejaVuSans.ttf'),
  );
  final document = pw.Document();
  // Split into bounded lines so a very long original path cannot create an
  // unbreakable paragraph. Preserve every character in the rendered report.
  final lines = <String>[];
  for (final line in text.split('\n')) {
    final characters = line.runes.toList();
    if (characters.isEmpty) lines.add(' ');
    for (var i = 0; i < characters.length; i += 85) {
      lines.add(String.fromCharCodes(characters.skip(i).take(85)));
    }
  }
  // Every bounded paragraph fits one page; this is a safe upper bound for
  // arbitrarily large reports, without MultiPage's default 20-page limit.
  document.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      maxPages: lines.length + 1,
      build: (_) => lines
          .map(
            (line) =>
                pw.Text(line, style: pw.TextStyle(font: font, fontSize: 9)),
          )
          .toList(),
    ),
  );
  return document.save();
}

class KobusReportScreen extends StatefulWidget {
  const KobusReportScreen({super.key, required this.run, required this.rows});
  final Map<String, Object?> run;
  final List<Map<String, Object?>> rows;
  @override
  State<KobusReportScreen> createState() => _KobusReportScreenState();
}

class _KobusReportScreenState extends State<KobusReportScreen> {
  String _status = 'rejected';
  bool _busy = false;
  Future<void> _pdf(bool print) async {
    setState(() => _busy = true);
    try {
      final bytes = await kobusReportPdf(
        kobusReportText(widget.run, widget.rows, _status, S.of(context)),
      );
      if (print) {
        await Printing.layoutPdf(
          onLayout: (_) async => bytes,
          name: 'KOBUS-$_status',
        );
      } else {
        await FilePicker.platform.saveFile(
          dialogTitle: S.current.kobus_savePdf,
          fileName: 'KOBUS-$_status.pdf',
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          bytes: bytes,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context), rows = widget.rows;
    final imported = rows.where((r) => r['status'] == 'imported').toList();
    final createdIds = imported
        .where((r) => r['created_patient'] == 1)
        .map((r) => r['patient_id'])
        .toSet();
    final existingIds = imported
        .map((r) => r['patient_id'])
        .toSet()
        .difference(createdIds);
    return Scaffold(
      appBar: AppBar(title: Text(s.kobus_history)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${s.kobus_creations}: ${createdIds.length} • ${s.kobus_existing}: ${existingIds.length} • ${s.kobus_archives}: ${imported.length}',
            ),
            Text(s.kobus_backupNotice),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                DropdownButton<String>(
                  value: _status,
                  onChanged: (v) => setState(() => _status = v!),
                  items: [
                    for (final status in [
                      'rejected',
                      'failed',
                      'skipped',
                      'interrupted',
                      'imported',
                    ])
                      DropdownMenuItem(
                        value: status,
                        child: Text(
                          '${kobusStatusLabel(status, s)} (${rows.where((r) => r['status'] == status).length})',
                        ),
                      ),
                  ],
                ),
                OutlinedButton(
                  onPressed: () => setState(() => _status = 'rejected'),
                  child: Text(s.kobus_editRejected),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => _pdf(false),
                  icon: const Icon(Icons.picture_as_pdf),
                  label: Text(s.kobus_savePdf),
                ),
                OutlinedButton.icon(
                  onPressed: _busy ? null : () => _pdf(true),
                  icon: const Icon(Icons.print),
                  label: Text(s.kobus_print),
                ),
              ],
            ),
            if (_busy) const LinearProgressIndicator(),
            Expanded(
              child: SingleChildScrollView(
                child: SelectableText(
                  kobusReportText(widget.run, rows, _status, s),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

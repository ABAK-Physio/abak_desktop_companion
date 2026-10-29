import 'dart:convert';
import 'dart:io';
import 'package:abak_desktop_companion/features/dmp_pdf_isolated/final_pdf_bench.dart';
void main(List<String> args) {
  final s = jsonDecode(File(args.single).readAsStringSync());
  final b = FinalPdfBench.create(Directory(s['parent']), LocalPdfInspector(s['poppler']));
  b.importPdf(File(s['pdf']), Map<String,String>.from(s['pdfContext']), s['revision']);
  final r = s['review'] as Map;
  if (r.isNotEmpty) {
    b.approve(reviewedPages:Set<int>.from(r['pages']), clinicalContent:r['clinical'],
      reviewedPatient:r['patient'],currentSourceRevision:s['revision'],consent:r['confirmed']);
  }
  b.exportNativeSnapshot(Directory(s['destination']),Map<String,String>.from(s['context']),
    currentSourceRevision:s['revision'],contextConfirmed:r['confirmed']==true);
  stdout.writeln(b.root.path);
}

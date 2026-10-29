import 'dart:convert';
import 'dart:io';
import 'package:abak_desktop_companion/features/dmp_pdf_isolated/final_pdf_bench.dart';
import 'package:abak_desktop_companion/features/dmp_pdf_cda_unified/snapshot_contract.dart';

void main(List<String> args) {
  if (args[0] == '--canonical') {
    final obj = jsonDecode(File(args[1]).readAsStringSync());
    stdout.write(snapshotHash(obj));
    return;
  }
  final spec = jsonDecode(File(args[0]).readAsStringSync());
  final b = FinalPdfBench.create(
    Directory(spec['parent']),
    LocalPdfInspector(spec['poppler']),
  );
  b.importPdf(File(spec['pdf']), b.context(), spec['revision']);
  if (spec['clinical'] == true) {
    b.approve(
      reviewedPages: {1},
      clinicalContent: true,
      reviewedPatient: 'SIM-A',
      currentSourceRevision: spec['revision'],
      consent: true,
    );
  }
  if (spec['alterPreview'] == true) {
    final c = b.state['current'];
    final name = (c['inspection']['previews'] as Map).keys.first;
    File('${b.root.path}/${c['preview']}/$name').writeAsStringSync('altéré');
  }
  b.exportNativeSnapshot(
    Directory(spec['destination']),
    Map<String, String>.from(spec['context']),
    currentSourceRevision: spec['revision'],
    contextConfirmed: true,
  );
  stdout.writeln(b.root.path);
}

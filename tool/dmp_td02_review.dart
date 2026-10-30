import 'dart:io';
import 'package:abak_desktop_companion/features/dmp_td02/td02_result.dart';

// Local-only adapter: the same reader used by the ABAK simulation screen.
void main(List<String> args) {
  if (args.length != 5) {stderr.writeln('Arguments de vérification incomplets'); exitCode=2; return;}
  final r=Td02Reader.read(request:File(args[0]).readAsStringSync(),
    response:File(args[1]).readAsStringSync(),httpStatus:int.parse(args[2]),
    context:Td02Context(ins:args[3],oid:'1.2.250.1.213.1.4.10',professional:args[4]));
  stdout.writeln(r.message);
  if(r.closureDetails.isNotEmpty) stdout.writeln(r.closureDetails);
  if(r.detail.isNotEmpty) stdout.writeln(r.detail);
  stdout.writeln('Aucun trait patientPerson affiché. Aucune autorisation modifiée. Aucun enchaînement documentaire.');
  if(r.state==DmpState.unknown || (r.state==DmpState.active && r.right==ConsultationRight.unknown)) exitCode=3;
}

// Local fixture utility. No card operation and no network transport.
import 'dart:io';
import 'package:xml/xml.dart';
import 'package:abak_desktop_companion/features/cps/cps_profile.dart';
import 'package:abak_desktop_companion/features/dmp_local/dmp_local_lot.dart';

void main(List<String> args) {
  if (args.length != 2 && args.length != 3) {
    throw ArgumentError(
      'Usage: certificate.pem output-directory [--replacement]',
    );
  }
  const situation = CpsSituation(
    number: 1,
    mode: 0,
    status: 1,
    structureName: 'CABINET M. MASSEUR0087059',
    structureId: '499700870597009',
    sector: 'SA07',
  );
  const profile = CpsProfile(
    nationalId: '899700870597',
    familyName: 'MASSAGE0087059',
    givenName: 'MICHEL',
    professionCode: 70,
    cardType: 0,
    situations: [situation],
  );
  final lot = DmpLocalLot.prepare(
    replacement: args.length == 3 && args[2] == '--replacement',
    profile: profile,
    situation: situation,
    certificateBase64: File(
      args[0],
    ).readAsStringSync().replaceAll(RegExp(r'-----[^\n]+-----|\s'), ''),
    cdaTemplate: File('assets/dmp_local/cda-example.xml').readAsStringSync(),
    registryTemplate: File(
      'assets/dmp_local/registry-example.xml',
    ).readAsStringSync(),
  );
  final output = Directory(args[1])..createSync(recursive: true);
  for (final file in lot.files.entries) {
    File('${output.path}/${file.key}').writeAsStringSync(file.value);
  }
  File('${output.path}/cda-canonical.xml').writeAsStringSync(
    DmpLocalLot.canonical(XmlDocument.parse(lot.cda).rootElement),
  );
  stdout.writeln(
    'Prepared local unsigned files. No card operation or network request.',
  );
}

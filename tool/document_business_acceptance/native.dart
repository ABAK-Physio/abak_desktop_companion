import 'dart:convert';
import 'dart:io';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/ports.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/bridge.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/wire/package.dart';
import 'package:abak_desktop_companion/features/cps/cps_profile.dart';
import '../document_chain_product/fakes.dart';

class NativeSimulation {
  NativeSimulation(this.repo, this.output, this.certificates, this.classes);
  final String repo, certificates, classes;
  final Directory output;
  final clock = DateTime.utc(2026, 10, 17, 12);
  int pinCalls = 0, profileCalls = 0, nativeIndex = 0;
  final traces = <String, File>{};
  late final manifest = jsonDecode(
    File('$certificates/manifest.json').readAsStringSync(),
  );

  DocumentDmpNativePorts ports(String scenario) {
    final signKind =
        ['expired', 'future', 'revoked', 'wrong', 'no_usage'].contains(scenario)
        ? scenario
        : 'sign';
    final trustKind = ['stale', 'revoked_auth', 'bad_crl'].contains(scenario)
        ? scenario
        : 'trust';
    final trace = File(
      '${output.path}/native-${++nativeIndex}-$scenario.trace',
    );
    traces[scenario] = trace;
    return DocumentDmpNativePorts(
      configuration: DmpNativeConfiguration(
        wire: const DmpWireConfiguration(
          endpoint: 'https://synthetic.invalid/DocumentRepository',
          sourceId: '2.25.1234567890123456789',
          lpsId: 'SYN-INSTALLATION',
          lpsName: 'ABAK SYNTHETIC',
          lpsVersion: 'SYN-1',
          homologationId: 'SYN-NOT-HOMOLOGATED',
        ),
        td02Endpoint: 'https://synthetic.invalid/td02',
        processingMode: 'T',
        libraryPath: '/NEVER-LOAD-CPS',
        trustPath: '$certificates/$trustKind.pem',
        trustHash: scenario == 'bad_trust_hash'
            ? 'a' * 64
            : manifest[trustKind],
        authenticationHash: manifest['auth'],
        signingHash: manifest[signKind],
        situationNumber: 1,
        situationMode: 1,
        situationStatus: 1,
        situationSector: 'SYN-SECTOR',
      ),
      bridge: DmpProcessBridge(
        executable:
            '/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home/bin/java',
        arguments: [
          '-cp',
          classes,
          'NativeTestBridge',
          certificates,
          repo,
          trace.path,
          scenario,
        ],
      ),
      requestPin: () async {
        pinCalls++;
        return scenario == 'cancelled' ? null : '1234';
      },
      readProfile: (pin, lease) async {
        profileCalls++;
        if (scenario == 'profile_error') {
          throw StateError('SECRET-NEVER-JOURNAL');
        }
        return CpsProfile(
          nationalId: scenario == 'wrong_professional'
              ? '99999999999'
              : '12345678901',
          familyName: 'SYNTHETIQUE',
          givenName: 'Kine',
          professionCode: scenario == 'wrong_profession' ? 10 : 70,
          cardType: 1,
          situations: [
            CpsSituation(
              number: scenario == 'wrong_situation' ? 2 : 1,
              mode: 1,
              status: 1,
              structureId: scenario == 'wrong_structure' ? 'OTHER' : 'SYN-CAB',
              sector: 'SYN-SECTOR',
            ),
          ],
        );
      },
      readPolicy: (snapshot) => Ports(repo, () => clock).policy(snapshot),
      now: () => clock,
    );
  }
}

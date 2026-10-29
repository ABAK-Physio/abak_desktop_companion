import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/cps/cps_operation_lease.dart';
import 'package:abak_desktop_companion/features/cps/cps_profile.dart';
import 'package:abak_desktop_companion/features/dmp_session/dmp_work_context.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/access_context.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/authentication_cache.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/bridge.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/ports.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/wire/package.dart';

void main() {
  final certs = Platform.environment['SYNTHETIC_CERTIFICATES'];
  final classes = Platform.environment['SYNTHETIC_NATIVE_CLASSES'];
  test(
    'two patient transactions reuse card authentication only, with independent evidence',
    () async {
      final dir = await Directory.systemTemp.createTemp(
        'abak-auth-reuse-test-',
      );
      final manifest = jsonDecode(
        File('$certs/manifest.json').readAsStringSync(),
      );
      final now = DateTime.utc(2026, 10, 17, 12);
      final cache = CpsAuthenticationCache(now: () => now);
      final context = DmpWorkContext()
        ..setEnabled(true)
        ..select('12345678901');
      var profileReads = 0, workers = 0;
      final traces = <String>[];
      Dv1AccessContext patient(String ins) => Dv1AccessContext(
        professional: '12345678901',
        structure: '123456789',
        sector: 'SA07',
        ins: ins,
        patientLabel: 'SYNTHETIQUE',
        source: 'synthetic-only',
        scenario: 'synthetic-only',
        confirmedAt: now,
        birthDate: '1980-01-01',
      );
      DocumentDmpNativePorts ports(Dv1AccessContext patient, String pin) {
        final trace = '${dir.path}/worker-${++workers}.trace';
        traces.add(trace);
        return DocumentDmpNativePorts(
          configuration: DmpNativeConfiguration(
            wire: const DmpWireConfiguration(
              endpoint:
                  'https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/repository',
              sourceId: '2.25.123456789',
              lpsId: 'SYNTHETIC',
              lpsName: 'SYNTHETIC',
              lpsVersion: '1',
              homologationId: 'SYNTHETIC',
            ),
            td02Endpoint: Dv1AccessContext.endpoint,
            processingMode: 'T',
            libraryPath: '/NEVER-LOAD-CPS',
            trustPath: '$certs/trust.pem',
            trustHash: manifest['trust'],
            authenticationHash: manifest['auth'],
            signingHash: manifest['sign'],
            situationNumber: 1,
            situationMode: 1,
            situationStatus: 1,
            situationSector: 'SA07',
          ),
          bridge: DmpProcessBridge(
            executable: '/usr/bin/sandbox-exec',
            arguments: [
              '-p',
              '(version 1)(allow default)(deny network*)',
              '/Library/Java/JavaVirtualMachines/temurin-17.jdk/Contents/Home/bin/java',
              '-cp',
              classes!,
              'NativeTestBridge',
              certs!,
              Directory.current.path,
              trace,
              'accepted',
            ],
          ),
          requestPin: () async => pin,
          readPolicy: (_) async =>
              throw StateError('Not needed in access test'),
          now: () => now,
          accessContext: patient,
          checkWorkContext: context.bind(patient.professional),
          authenticationCache: cache,
          authenticationKey: 'config:worker',
          readProfile: (_, _) async {
            profileReads++;
            return const CpsProfile(
              nationalId: '12345678901',
              familyName: 'SYNTHETIQUE',
              givenName: 'Kine',
              professionCode: 70,
              cardType: 1,
              situations: [
                CpsSituation(
                  number: 1,
                  mode: 1,
                  status: 1,
                  structureId: '123456789',
                  sector: 'SA07',
                ),
              ],
            );
          },
        );
      }

      try {
        final a = patient('180019912345601');
        final first = ports(a, '1234');
        final s1 = await first.authenticate(a.snapshot);
        final request1 = await first.prepareTd02(a.snapshot, s1, now);
        expect((await first.td02(request1, s1)).status, 200);
        first.retainAuthentication = true;
        await first.closeSession();
        expect(first.authenticationRetained, isTrue);
        expect(cache.canReuse('config:worker', '12345678901'), isTrue);
        final b = patient('280019912345602');
        final second = ports(b, ''); // explicit confirmation, no PIN
        final s2 = await second.authenticate(b.snapshot);
        expect(profileReads, 1);
        expect(s2.id, isNot(s1.id));
        expect(
          jsonDecode(s2.nativeEvidenceJson!)['authenticationReused'],
          isTrue,
        );
        await expectLater(
          second.prepareTd02(a.snapshot, s2, now),
          throwsA(isA<DmpNativeFailure>()),
        );
        final request2 = await second.prepareTd02(b.snapshot, s2, now);
        expect(request2, contains(b.ins));
        expect(request2, isNot(contains(a.ins)));
        expect((await second.td02(request2, s2)).status, 200);
        await expectLater(
          second.td02(request2, s2),
          throwsA(isA<DmpNativeFailure>()),
        );
        second.retainAuthentication = true;
        await second.closeSession();
        await CpsOperationLease.closeIdle();
        final trace = File(traces.first).readAsLinesSync();
        expect(trace.where((l) => l == 'identity_open').length, 1);
        expect(trace.where((l) => l == 'td').length, 2);
        expect(trace.where((l) => l == 'identity_close').length, 1);
        expect(
          File(traces.last).existsSync(),
          isFalse,
        ); // second worker never launched
      } finally {
        await CpsOperationLease.closeIdle();
        await dir.delete(recursive: true);
      }
    },
    skip: certs == null || classes == null
        ? 'Requires generated synthetic certificates and test-only Java classes'
        : false,
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_td02/access_identity.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/ports.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/bridge.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/access_context.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/contracts.dart';

class UntouchedConfiguration extends Fake implements DmpNativeConfiguration {
  int checks = 0;
  @override
  void check() {
    checks++;
    throw StateError('Configuration must not be reached');
  }
}

class UntouchedBridge implements DmpNativeBridge {
  int calls = 0, closes = 0;
  @override
  Future<Map<String, String>> call(
    String operation,
    Map<String, String> fields,
  ) async {
    calls++;
    throw StateError('Native worker must not be reached');
  }

  @override
  Future<void> close() async {
    closes++;
  }
}

void main() {
  test(
    'actual native authentication entry refuses NIA before PIN/profile/worker',
    () async {
      final bridge = UntouchedBridge();
      final configuration = UntouchedConfiguration();
      var pins = 0, profiles = 0, policies = 0;
      final ports = DocumentDmpNativePorts(
        configuration: configuration,
        bridge: bridge,
        requestPin: () async {
          pins++;
          return '0000';
        },
        readProfile: (_, __) async {
          profiles++;
          throw StateError('No CPS');
        },
        readPolicy: (_) async {
          policies++;
          throw StateError('No policy');
        },
        now: DateTime.now,
      );
      await expectLater(
        ports.authenticate({
          'identity': {
            'ins_number': '1090763220888',
            'ins_key': '35',
            'ins_oid': DmpAccessIdentity.niaOid,
          },
        }),
        throwsA(
          isA<DmpChainBlock>().having(
            (e) => e.message,
            'message',
            contains('NIA'),
          ),
        ),
      );
      expect(pins, 0);
      expect(profiles, 0);
      expect(policies, 0);
      expect(configuration.checks, 0);
      expect(bridge.calls, 0);
      expect(bridge.closes, 0);
    },
  );
  test(
    'context snapshots and secret choice cannot silently turn NIA into NIR',
    () {
      final now = DateTime.utc(2026, 11, 10);
      final c = Dv1AccessContext(
        professional: '899700870597',
        structure: '499700870597009',
        sector: 'SA07',
        ins: '109076322088835',
        insOid: DmpAccessIdentity.niaOid,
        patientLabel: 'PROVISOIRE MATRICULE',
        source: 'TEST_NIA.xml',
        scenario: '0.2-080',
        confirmedAt: now,
        birthDate: '2009-07-01',
        minorsEnabled: true,
      );
      expect(c.snapshot['identity']['ins_oid'], DmpAccessIdentity.niaOid);
      final other = c.withSecretConnection(true);
      expect(other.insOid, DmpAccessIdentity.niaOid);
      expect(() => c.check(now), throwsA(isA<DmpNiaBlocked>()));
      expect(() => other.check(now), throwsA(isA<DmpNiaBlocked>()));
    },
  );
}

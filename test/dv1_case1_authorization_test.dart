import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/case1_authorization_recipe.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/platform_support.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/expired_authorization_recipe.dart';
import 'package:abak_desktop_companion/features/dmp_td02/td02_result.dart';

import 'dv1_expired_authorization_test.dart' as synthetic;

void checkInputs({
  String scenario = Dv1Case1AuthorizationRecipe.scenario,
  String patient = Dv1Case1AuthorizationRecipe.patient,
  String ins = Dv1Case1AuthorizationRecipe.ins,
  String birth = Dv1Case1AuthorizationRecipe.birth,
  String professional = Dv1Case1AuthorizationRecipe.professional,
}) => Dv1Case1AuthorizationRecipe.checkInputs(
  scenario: scenario,
  patient: patient,
  ins: ins,
  birth: birth,
  professional: professional,
);

Td02Result read(
  String right, {
  String relates = synthetic.messageId,
  String ack = 'AA',
}) => Td02Reader.read(
  request: synthetic.request().replaceAll(
    Dv1ExpiredAuthorizationRecipe.ins,
    Dv1Case1AuthorizationRecipe.ins,
  ),
  response: synthetic.response(
    ins: Dv1Case1AuthorizationRecipe.ins,
    right: right,
    relates: relates,
    ack: ack,
  ),
  context: const Td02Context(
    ins: Dv1Case1AuthorizationRecipe.ins,
    oid: synthetic.oid,
    professional: Dv1Case1AuthorizationRecipe.professional,
  ),
);

void main() {
  test('Cas1 fixture is accepted in either name order', () {
    checkInputs();
    checkInputs(patient: ' ANNE-LOUIS   GIRODET DE ROUSSY-COEUR ');
    expect(Dv1Case1AuthorizationRecipe.source, contains('ligne 33'));
    expect(Dv1Case1AuthorizationRecipe.source, contains('ligne 19'));
  });
  test(
    'another fixture, professional, birth or scenario cannot mutate Cas1',
    () {
      for (final action in <void Function()>[
        () => checkInputs(patient: 'HUIT HENRI'),
        () => checkInputs(ins: '189018157057689'),
        () => checkInputs(birth: '1987-01-02'),
        () => checkInputs(professional: '899700854237'),
        () => checkInputs(scenario: '0.2-070'),
      ]) {
        expect(action, throwsStateError);
      }
    },
  );
  test('only an active DMP with NON_EXISTE can be an initial state', () {
    for (final state in DmpState.values) {
      for (final right in ConsultationRight.values) {
        final r = Td02Result(state, right: right);
        final expected =
            state == DmpState.active && right == ConsultationRight.absent;
        expect(Dv1Case1AuthorizationRecipe.initialReady(r), expected);
        if (expected) {
          Dv1Case1AuthorizationRecipe.requireInitial(r);
        } else {
          expect(
            () => Dv1Case1AuthorizationRecipe.requireInitial(r),
            throwsStateError,
          );
        }
      }
    }
  });
  test(
    'initial NON_EXISTE and DMPOk are insufficient without final VALIDE',
    () {
      const initial = Td02Result(
        DmpState.active,
        right: ConsultationRight.absent,
      );
      for (final state in DmpState.values) {
        for (final right in ConsultationRight.values) {
          expect(
            Dv1Case1AuthorizationRecipe.completed(
              initial,
              'DMPOk',
              Td02Result(state, right: right),
            ),
            state == DmpState.active && right == ConsultationRight.valid,
          );
        }
      }
    },
  );
  test(
    'already valid, expired or blocked initial rights never count as a new add',
    () {
      const after = Td02Result(DmpState.active, right: ConsultationRight.valid);
      for (final right in [
        ConsultationRight.valid,
        ConsultationRight.expired,
        ConsultationRight.blocked,
        ConsultationRight.unknown,
      ]) {
        expect(
          Dv1Case1AuthorizationRecipe.completed(
            Td02Result(DmpState.active, right: right),
            'DMPOk',
            after,
          ),
          isFalse,
        );
      }
    },
  );
  test('unconfirmed TD0.3 result cannot be replaced by final valid rights', () {
    final initial = read('NON_EXISTE'), after = read('VALIDE');
    for (final status in [
      '',
      'Failure',
      'DMPAccessForbidden',
      'DMPKO',
      'DMPOK',
    ]) {
      expect(
        Dv1Case1AuthorizationRecipe.completed(initial, status, after),
        isFalse,
      );
    }
    expect(
      Dv1Case1AuthorizationRecipe.completed(initial, 'DMPOk', after),
      isTrue,
    );
  });
  test(
    'initial and final TD0.2 responses must both remain correlated and AA',
    () {
      final initial = read('NON_EXISTE'), after = read('VALIDE');
      expect(Dv1Case1AuthorizationRecipe.initialReady(initial), isTrue);
      for (final bad in [
        read('NON_EXISTE', relates: 'other'),
        read('NON_EXISTE', ack: 'AE'),
      ]) {
        expect(
          Dv1Case1AuthorizationRecipe.completed(bad, 'DMPOk', after),
          isFalse,
        );
      }
      for (final bad in [
        read('VALIDE', relates: 'other'),
        read('VALIDE', ack: 'AE'),
      ]) {
        expect(
          Dv1Case1AuthorizationRecipe.completed(initial, 'DMPOk', bad),
          isFalse,
        );
      }
    },
  );
  test(
    'Windows add permission never enables mixed operations or other platforms',
    () {
      expect(
        dv1AccessPlatformSupported(platform: 'windows', authorizationAdd: true),
        isTrue,
      );
      expect(
        dv1AccessPlatformSupported(
          platform: 'windows',
          authorizationAdd: true,
          otherAction: true,
        ),
        isFalse,
      );
      expect(
        dv1AccessPlatformSupported(platform: 'windows', otherAction: true),
        isFalse,
      );
      expect(dv1AccessPlatformSupported(platform: 'windows'), isFalse);
      expect(
        dv1AccessPlatformSupported(platform: 'linux', authorizationAdd: true),
        isFalse,
      );
      expect(
        dv1AccessPlatformSupported(platform: 'macos', otherAction: true),
        isTrue,
      );
    },
  );
}

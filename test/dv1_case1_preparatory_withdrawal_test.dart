import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/case1_authorization_recipe.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/platform_support.dart';
import 'package:abak_desktop_companion/features/dmp_td02/td02_result.dart';

import 'dv1_case1_authorization_test.dart' as case1;

void main() {
  test(
    'only a fresh active and valid right permits preparatory withdrawal',
    () {
      for (final state in DmpState.values) {
        for (final right in ConsultationRight.values) {
          final result = Td02Result(state, right: right);
          final expected =
              state == DmpState.active && right == ConsultationRight.valid;
          expect(Dv1Case1AuthorizationRecipe.withdrawalReady(result), expected);
          if (expected) {
            Dv1Case1AuthorizationRecipe.requireWithdrawalInitial(result);
          } else {
            expect(
              () =>
                  Dv1Case1AuthorizationRecipe.requireWithdrawalInitial(result),
              throwsStateError,
            );
          }
        }
      }
    },
  );

  test(
    'withdrawal needs DMPOk and final active NON_EXISTE, never merely expired',
    () {
      final initial = case1.read('VALIDE');
      for (final state in DmpState.values) {
        for (final right in ConsultationRight.values) {
          expect(
            Dv1Case1AuthorizationRecipe.withdrawalCompleted(
              initial,
              'DMPOk',
              Td02Result(state, right: right),
            ),
            state == DmpState.active && right == ConsultationRight.absent,
          );
        }
      }
      final after = case1.read('NON_EXISTE');
      for (final status in ['', 'DMPOK', 'DMPKO', 'DMPAccessForbidden']) {
        expect(
          Dv1Case1AuthorizationRecipe.withdrawalCompleted(
            initial,
            status,
            after,
          ),
          isFalse,
        );
      }
      expect(
        Dv1Case1AuthorizationRecipe.withdrawalCompleted(
          initial,
          'DMPOk',
          after,
        ),
        isTrue,
      );
      expect(
        Dv1Case1AuthorizationRecipe.completed(initial, 'DMPOk', after),
        isFalse,
      );
    },
  );

  test(
    'already absent or changed initial right cannot count as a withdrawal',
    () {
      final after = case1.read('NON_EXISTE');
      for (final right in ConsultationRight.values) {
        if (right == ConsultationRight.valid) continue;
        expect(
          Dv1Case1AuthorizationRecipe.withdrawalCompleted(
            Td02Result(DmpState.active, right: right),
            'DMPOk',
            after,
          ),
          isFalse,
        );
      }
    },
  );

  test('both withdrawal TD0.2 replies must be correlated and AA', () {
    final initial = case1.read('VALIDE'), after = case1.read('NON_EXISTE');
    for (final bad in [
      case1.read('VALIDE', ack: 'AE'),
      case1.read('VALIDE', relates: 'other'),
    ]) {
      expect(
        Dv1Case1AuthorizationRecipe.withdrawalCompleted(bad, 'DMPOk', after),
        isFalse,
      );
    }
    for (final bad in [
      case1.read('NON_EXISTE', ack: 'AE'),
      case1.read('NON_EXISTE', relates: 'other'),
    ]) {
      expect(
        Dv1Case1AuthorizationRecipe.withdrawalCompleted(initial, 'DMPOk', bad),
        isFalse,
      );
    }
  });

  test('preparation never enables a withdrawal for Simone, Henri or a mixed action', () {
    for (final scenario in [
      '0.2-060',
      '0.2-070',
      '0.2-080',
      '0.3-080',
      'PRE_ALIM_RECH',
    ]) {
      expect(
        () => Dv1Case1AuthorizationRecipe.checkOperation(
          scenario: scenario,
          authorizationIntent: 'withdraw',
          preparatoryWithdrawal: true,
        ),
        throwsStateError,
      );
    }
    for (final intent in [null, 'consult', 'other']) {
      expect(
        () => Dv1Case1AuthorizationRecipe.checkOperation(
          scenario: '0.3-010',
          authorizationIntent: intent,
          preparatoryWithdrawal: true,
        ),
        throwsStateError,
      );
    }
    expect(
      () => Dv1Case1AuthorizationRecipe.checkOperation(
        scenario: '0.3-010',
        authorizationIntent: 'withdraw',
      ),
      throwsStateError,
    );
    expect(
      () => Dv1Case1AuthorizationRecipe.checkOperation(
        scenario: '0.3-010',
        authorizationIntent: 'withdraw',
        preparatoryWithdrawal: true,
        otherOperation: true,
      ),
      throwsStateError,
    );
    Dv1Case1AuthorizationRecipe.checkOperation(
      scenario: '0.3-010',
      authorizationIntent: 'withdraw',
      preparatoryWithdrawal: true,
    );
    Dv1Case1AuthorizationRecipe.checkOperation(scenario: '0.3-010');
    Dv1Case1AuthorizationRecipe.checkOperation(
      scenario: '0.3-010',
      authorizationIntent: 'consult',
    );
  });

  test(
    'Windows withdrawal permission remains scoped away from mixed operations',
    () {
      expect(
        dv1AccessPlatformSupported(
          platform: 'windows',
          authorizationWithdrawal: true,
        ),
        isTrue,
      );
      expect(
        dv1AccessPlatformSupported(
          platform: 'windows',
          authorizationWithdrawal: true,
          otherAction: true,
        ),
        isFalse,
      );
      expect(
        dv1AccessPlatformSupported(platform: 'windows', otherAction: true),
        isFalse,
      );
      expect(
        dv1AccessPlatformSupported(
          platform: 'linux',
          authorizationWithdrawal: true,
        ),
        isFalse,
      );
    },
  );
}

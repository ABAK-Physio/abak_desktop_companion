import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/case1_authorization_recipe.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/case1_withdrawal_recipe.dart';
import 'package:abak_desktop_companion/features/dmp_td02/td02_result.dart';

import 'dv1_case1_authorization_test.dart' as case1;
import 'dv1_nia_injection_test.dart' show recordHash;

const additionId = '15d790af-14fd-43bb-9281-f0bee170fc32';

Map<String, dynamic> addition() => {
  'id': additionId,
  'environment': 'DV1',
  'platform': 'windows',
  'testCode': '0.3-010',
  'testPhase': 'authorization_add',
  'testExpectedMatched': true,
  'state': 'authorization_verified',
  'authorizationAction': 'add',
  'dmpState': 'active',
  'consultationRight': 'absent',
  'td03Status': 'DMPOk',
  'afterDmpState': 'active',
  'afterConsultationRight': 'valid',
  'transactionClosed': true,
  'httpStatus': 200,
  'td03HttpStatus': 200,
  'afterHttpStatus': 200,
  'context': {
    'identity': {
      'ins_number': '2870191435960',
      'ins_key': '41',
      'ins_oid': '1.2.250.1.213.1.4.10',
    },
    'recipe': {
      'scenario': '0.3-010',
      'patient': Dv1Case1AuthorizationRecipe.patient,
      'birthDate': '1987-01-01',
    },
    'practice': {
      'data_json': jsonEncode({'identifier': '899700870597'}),
    },
  },
};

void main() {
  test('0.3-080 uses the exact Cas1 fixture and PDT row 35', () {
    Dv1Case1WithdrawalRecipe.checkInputs(
      scenario: '0.3-080',
      patient: Dv1Case1AuthorizationRecipe.patient,
      ins: '287019143596041',
      birth: '1987-01-01',
      professional: '899700870597',
    );
    for (final scenario in ['0.3-010', '0.2-060', '0.2-070']) {
      expect(
        () => Dv1Case1WithdrawalRecipe.checkInputs(
          scenario: scenario,
          patient: Dv1Case1AuthorizationRecipe.patient,
          ins: '287019143596041',
          birth: '1987-01-01',
          professional: '899700870597',
        ),
        throwsStateError,
      );
    }
    expect(
      () => Dv1Case1WithdrawalRecipe.checkInputs(
        scenario: '0.3-080',
        patient: 'HUIT HENRI',
        ins: '189018157057689',
        birth: '1989-01-01',
        professional: '899700870597',
      ),
      throwsStateError,
    );
    expect(Dv1Case1WithdrawalRecipe.source, contains('ligne 35'));
  });
  test(
    'read-only or explicit withdrawal only, never addition or preparatory mode',
    () {
      Dv1Case1WithdrawalRecipe.checkOperation();
      Dv1Case1WithdrawalRecipe.checkOperation(authorizationIntent: 'withdraw');
      for (final intent in ['consult', 'other']) {
        expect(
          () => Dv1Case1WithdrawalRecipe.checkOperation(
            authorizationIntent: intent,
          ),
          throwsStateError,
        );
      }
      expect(
        () => Dv1Case1WithdrawalRecipe.checkOperation(
          authorizationIntent: 'withdraw',
          otherOperation: true,
        ),
        throwsStateError,
      );
      expect(
        () => Dv1Case1WithdrawalRecipe.checkOperation(
          authorizationIntent: 'withdraw',
          preparatoryWithdrawal: true,
        ),
        throwsStateError,
      );
    },
  );
  test('fresh initial state must be active and VALIDE', () {
    for (final state in DmpState.values) {
      for (final right in ConsultationRight.values) {
        final result = Td02Result(state, right: right);
        final ready =
            state == DmpState.active && right == ConsultationRight.valid;
        expect(Dv1Case1WithdrawalRecipe.initialReady(result), ready);
        if (ready) {
          Dv1Case1WithdrawalRecipe.requireInitial(result);
        } else {
          expect(
            () => Dv1Case1WithdrawalRecipe.requireInitial(result),
            throwsStateError,
          );
        }
      }
    }
  });
  test('completion needs exact DMPOk and final active NON_EXISTE', () {
    final initial = case1.read('VALIDE');
    for (final state in DmpState.values) {
      for (final right in ConsultationRight.values) {
        expect(
          Dv1Case1WithdrawalRecipe.completed(
            initial,
            'DMPOk',
            Td02Result(state, right: right),
          ),
          state == DmpState.active && right == ConsultationRight.absent,
        );
      }
    }
    for (final status in ['', 'DMPOK', 'DMPKO', 'DMPAccessForbidden']) {
      expect(
        Dv1Case1WithdrawalRecipe.completed(
          initial,
          status,
          case1.read('NON_EXISTE'),
        ),
        isFalse,
      );
    }
    expect(
      Dv1Case1WithdrawalRecipe.completed(
        case1.read('NON_EXISTE'),
        'DMPOk',
        case1.read('NON_EXISTE'),
      ),
      isFalse,
    );
  });
  test('AA and correlation are still required on initial and final TD0.2', () {
    for (final bad in [
      case1.read('VALIDE', ack: 'AE'),
      case1.read('VALIDE', relates: 'wrong'),
    ]) {
      expect(
        Dv1Case1WithdrawalRecipe.completed(
          bad,
          'DMPOk',
          case1.read('NON_EXISTE'),
        ),
        isFalse,
      );
    }
    for (final bad in [
      case1.read('NON_EXISTE', ack: 'AE'),
      case1.read('NON_EXISTE', relates: 'wrong'),
    ]) {
      expect(
        Dv1Case1WithdrawalRecipe.completed(case1.read('VALIDE'), 'DMPOk', bad),
        isFalse,
      );
    }
  });
  test(
    'a preparatory or incomplete addition cannot be used as prior proof',
    () {
      expect(Dv1Case1WithdrawalRecipe.isAddition(addition()), isTrue);
      for (final change in <String, dynamic>{
        'preparationOnly': true,
        'testCode': '0.3-080',
        'testExpectedMatched': false,
        'td03Status': 'DMPKO',
        'afterConsultationRight': 'expired',
        'consultationRight': 'valid',
        'transactionClosed': false,
        'platform': 'macos',
        'testPhase': 'initial_check',
        'state': 'closure_failed',
        'td03HttpStatus': 500,
      }.entries) {
        expect(
          Dv1Case1WithdrawalRecipe.isAddition({
            ...addition(),
            change.key: change.value,
          }),
          isFalse,
          reason: change.key,
        );
      }
      final wrong = addition();
      ((wrong['context'] as Map)['identity'] as Map)['ins_oid'] =
          '1.2.250.1.213.1.4.9';
      expect(Dv1Case1WithdrawalRecipe.isAddition(wrong), isFalse);
      ((wrong['context'] as Map)['identity'] as Map)['ins_oid'] =
          '1.2.250.1.213.1.4.10';
      ((wrong['context'] as Map)['practice'] as Map)['data_json'] = jsonEncode({
        'identifier': '899700000000',
      });
      expect(Dv1Case1WithdrawalRecipe.isAddition(wrong), isFalse);
    },
  );

  group('read-only addition archive', () {
    late Directory root;
    late Directory directory;
    late Dv1Case1AdditionArchive archive;
    late Map<String, dynamic> record;
    Future<void> save() async =>
        File.fromUri(directory.uri.resolve('result.json')).writeAsString(
          jsonEncode({'record': record, 'sha256': recordHash(record)}),
        );
    setUp(() async {
      root = await Directory.systemTemp.createTemp('abak_080_');
      directory = await Directory.fromUri(root.uri.resolve('$additionId/'))
          .create();
      archive = Dv1Case1AdditionArchive(root, hash: recordHash);
      record = addition();
      for (final exchange in Dv1Case1AdditionArchive.exchanges.entries) {
        final text = '<synthetic exchange="${exchange.key}"/>';
        await File.fromUri(directory.uri.resolve(exchange.key))
            .writeAsString(text);
        record[exchange.value] = recordHash(text);
      }
      await save();
    });
    tearDown(() async => root.delete(recursive: true));
    test('links the envelope hash after checking all six exchanges', () async {
      final before = await File.fromUri(directory.uri.resolve('result.json'))
          .readAsBytes();
      final checked = await archive.verify(additionId);
      expect(checked['id'], additionId);
      expect(checked['additionEvidenceHash'], recordHash(record));
      expect(
        await File.fromUri(directory.uri.resolve('result.json')).readAsBytes(),
        before,
      );
    });
    test(
      'rejects changed metadata even when individual SOAP files remain',
      () async {
        final file = File.fromUri(directory.uri.resolve('result.json'));
        await file.writeAsString(
          jsonEncode({'record': record, 'sha256': 'wrong'}),
        );
        await expectLater(archive.verify(additionId), throwsStateError);
      },
    );
    test('rechecks changed or missing exchanges after preparation', () async {
      await archive.verify(additionId);
      final file = File.fromUri(directory.uri.resolve('td03-response.xml'));
      await file.writeAsString('<changed/>');
      await expectLater(archive.verify(additionId), throwsStateError);
      await file.delete();
      await expectLater(archive.verify(additionId), throwsStateError);
    });
    test(
      'rejects traversal, absent proofs and a recomputed wrong-patient summary',
      () async {
        await expectLater(archive.verify('../$additionId'), throwsStateError);
        await expectLater(
          archive.verify('00000000-0000-0000-0000-000000000000'),
          throwsStateError,
        );
        ((record['context'] as Map)['recipe'] as Map)['patient'] =
            'SARTRE SIMONE';
        await save();
        await expectLater(archive.verify(additionId), throwsStateError);
      },
    );
  });
}

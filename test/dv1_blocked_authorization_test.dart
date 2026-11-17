import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/blocked_authorization_recipe.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/expired_authorization_recipe.dart';
import 'package:abak_desktop_companion/features/dmp_td02/td02_result.dart';

import 'dv1_expired_authorization_test.dart' as synthetic;

String request() => synthetic.request().replaceAll(
  Dv1ExpiredAuthorizationRecipe.ins,
  Dv1BlockedAuthorizationRecipe.ins,
);
String response({
  String right = 'INTERDIT',
  String status = 'active',
  String ack = 'AA',
  String relates = synthetic.messageId,
  String ins = Dv1BlockedAuthorizationRecipe.ins,
}) => synthetic.response(
  right: right,
  status: status,
  ack: ack,
  relates: relates,
  ins: ins,
);
const context = Td02Context(
  ins: Dv1BlockedAuthorizationRecipe.ins,
  oid: synthetic.oid,
  professional: Dv1BlockedAuthorizationRecipe.professional,
);
Td02Result read(String xml, {String? outgoing, int httpStatus = 200}) =>
    Td02Reader.read(
      request: outgoing ?? request(),
      response: xml,
      context: context,
      httpStatus: httpStatus,
    );
void checkInputs({
  String scenario = Dv1BlockedAuthorizationRecipe.scenario,
  String patient = Dv1BlockedAuthorizationRecipe.patient,
  String ins = Dv1BlockedAuthorizationRecipe.ins,
  String birth = Dv1BlockedAuthorizationRecipe.birth,
  String professional = Dv1BlockedAuthorizationRecipe.professional,
}) => Dv1BlockedAuthorizationRecipe.checkInputs(
  scenario: scenario,
  patient: patient,
  ins: ins,
  birth: birth,
  professional: professional,
);

void main() {
  test('prepares Cas6 Henri HUIT in either name order', () {
    checkInputs();
    checkInputs(patient: '  Henri   Huit ');
    expect(Dv1BlockedAuthorizationRecipe.source, contains('ligne 31'));
    expect(Dv1BlockedAuthorizationRecipe.source, contains('ligne 26'));
  });
  test('rejects another patient, birth, INS, professional and test code', () {
    for (final action in <void Function()>[
      () => checkInputs(patient: 'SARTRE SIMONE'),
      () => checkInputs(ins: Dv1ExpiredAuthorizationRecipe.ins),
      () => checkInputs(birth: '1989-01-02'),
      () => checkInputs(professional: '899700854237'),
      () => checkInputs(scenario: Dv1ExpiredAuthorizationRecipe.scenario),
    ]) {
      expect(action, throwsStateError);
    }
  });
  test('correlated AA, active DMP and INTERDIT match 0.2-070 only', () {
    final result = read(response());
    expect(result.state, DmpState.active);
    expect(result.right, ConsultationRight.blocked);
    expect(Dv1BlockedAuthorizationRecipe.matches(result), isTrue);
    expect(Dv1ExpiredAuthorizationRecipe.matches(result), isFalse);
    expect(result.canSendNetworkRequest, isFalse);
    expect(
      result.allows(
        DmpAction.consult,
        opposition: false,
        functionalRights: true,
        authorRights: true,
        consultationConsent: true,
      ),
      isFalse,
    );
  });
  test('expired, absent, valid or unknown rights do not pass as blocked', () {
    for (final right in ['EXPIRE', 'NON_EXISTE', 'VALIDE', 'INCONNU']) {
      expect(
        Dv1BlockedAuthorizationRecipe.matches(read(response(right: right))),
        isFalse,
      );
    }
  });
  test('closed DMP cannot satisfy this test', () {
    expect(
      Dv1BlockedAuthorizationRecipe.matches(
        read(response(status: 'terminated')),
      ),
      isFalse,
    );
  });
  test('bad acknowledgement, correlation or patient invalidate INTERDIT', () {
    for (final xml in [
      response(ack: 'AE'),
      response(relates: 'other-request'),
      response(ins: Dv1ExpiredAuthorizationRecipe.ins),
    ]) {
      final result = read(xml);
      expect(result.state, DmpState.unknown);
      expect(Dv1BlockedAuthorizationRecipe.matches(result), isFalse);
    }
  });
  test('another professional in the request cannot pass', () {
    final outgoing = request().replaceAll(
      Dv1BlockedAuthorizationRecipe.professional,
      '899700854237',
    );
    final result = read(response(), outgoing: outgoing);
    expect(result.state, DmpState.unknown);
    expect(Dv1BlockedAuthorizationRecipe.matches(result), isFalse);
  });
  test(
    'malformed XML and HTTP failures never become blocked-right success',
    () {
      expect(Dv1BlockedAuthorizationRecipe.matches(read('<broken')), isFalse);
      expect(
        Dv1BlockedAuthorizationRecipe.matches(
          read(response(), httpStatus: 503),
        ),
        isFalse,
      );
    },
  );
  test(
    'Simone and Henri remain separate fixtures with distinct expectations',
    () {
      expect(
        Dv1BlockedAuthorizationRecipe.ins,
        isNot(Dv1ExpiredAuthorizationRecipe.ins),
      );
      final expired = synthetic.read(synthetic.response());
      expect(Dv1ExpiredAuthorizationRecipe.matches(expired), isTrue);
      expect(Dv1BlockedAuthorizationRecipe.matches(expired), isFalse);
    },
  );
}

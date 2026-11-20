import 'package:abak_vitale/abak_vitale.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/patients/services/patient_insi_retrieval_service.dart';

void main() {
  VitaleIdentity card({String serial = '123456789', int rank = 1,
    String firstName = 'RUTH', String rawDate = '01011990'}) => VitaleIdentity(
      cardSerial: serial,
      nir: '2900101000001',
      birthOrder: rank,
      birthDateRaw: rawDate,
      lastName: 'EXEMPLE',
      firstName: firstName,
    );

  test('accepts selected beneficiary from a fresh read with other beneficiaries', () {
    expect(() => PatientInsiRetrievalService.checkCurrentCard(card(), [
      card(rank: 2, firstName: 'AUTRE'), card(),
    ]), returnsNormally);
  });

  test('rejects absent or replaced card', () {
    expect(() => PatientInsiRetrievalService.checkCurrentCard(card(), []), throwsStateError);
    expect(() => PatientInsiRetrievalService.checkCurrentCard(card(), [card(serial: '999999999')]), throwsStateError);
  });

  test('rejects changed beneficiary data on the same card', () {
    for (final changed in [card(rank: 2), card(firstName: 'AUTRE'), card(rawDate: '02011990')]) {
      expect(() => PatientInsiRetrievalService.checkCurrentCard(card(), [changed]), throwsStateError);
    }
  });

  test('rejects duplicate or incomplete current readings', () {
    expect(() => PatientInsiRetrievalService.checkCurrentCard(card(), [card(), card()]), throwsStateError);
    expect(() => PatientInsiRetrievalService.checkCurrentCard(card(), [const VitaleIdentity()]), throwsStateError);
  });
}

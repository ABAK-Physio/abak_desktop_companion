import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:abak_desktop_companion/features/patients/services/document_medical_service.dart';

Future<Map<String, String>> seed(
  Database db,
  DocumentMedicalService medical,
) async {
  await db.insert('patients', {
    'patient_id': 'SYN-P',
    'last_name': 'SYNTHETIQUE',
    'first_name': 'Patient',
    'birth_date': '1980-01-01',
    'created_at': 1,
  });
  await db.insert('care_episodes', {
    'care_episode_id': 'SYN-E',
    'patient_id': 'SYN-P',
    'title': 'Synthétique',
    'pathology_label': 'Fictif',
    'created_at': 1,
  });
  await db.insert('patient_fr_health_identity', {
    'patient_id': 'SYN-P',
    'ins_number': '1800199123456',
    'ins_key': '01',
    'ins_oid': '1.2.250.1.213.1.4.10',
    'birth_last_name': 'SYNTHETIQUE',
    'birth_first_names': 'Patient',
    'birth_date': '1980-01-01',
    'sex_code': 'M',
    'birth_place_code': '99123',
    'identity_status': 'qualified',
    'identity_doubtful': 0,
    'identity_validation_method': 'synthetic',
    'identity_validated_at': 1,
    'identity_validated_by': 'SYN-A',
    'ins_retrieved_at': 1,
  });
  await db.insert('practitioners', {
    'practitioner_id': 'SYN-A',
    'display_name': 'KINE SYNTHETIQUE',
    'professional_id': '12345678901',
    'is_active': 1,
    'created_at': 1,
  });
  final context = await medical.saveContext(
    practitionerId: 'SYN-A',
    expectedRevision: 0,
    data: {
      'identifierType': 'RPPS',
      'identifier': '12345678901',
      'authority': '2.25.123456789',
      'professionCode': 'G15_70',
      'professionSystem': '1.2.250.1.213.1.1.4.5',
      'professionLabel': 'Masseur-kinésithérapeute',
      'situation': 'Exercice synthétique',
      'setting': 'Ambulatoire',
      'structureType': 'cabinet',
      'structureId': 'SYN-CAB',
      'structureAuthority': '1.2.250.1.71.4.2.2',
      'structureName': 'CABINET SYNTHETIQUE',
      'validFrom': '2020-01-01T00:00:00Z',
      'validUntil': '2027-01-01T00:00:00Z',
      'replacementFor': '',
      'facilityCode': 'SA07',
      'facilityLabel': 'Cabinet individuel',
      'familyName': 'SYNTHETIQUE',
      'givenNames': 'Kine',
    },
  );
  final draft = {
    'authorId': 'SYN-A',
    'validatorId': 'SYN-A',
    'contextId': context['context_id'] as String,
    'title': 'Rapport clinique SYNTHETIQUE',
    'clinicalDate': '2026-10-16T14:00:00+02:00',
    'language': 'fr-FR',
    'typeCode': '11506-3',
    'typeSystem': '2.16.840.1.113883.6.1',
    'typeLabel': 'CR ou fiche de suivi de soins par auxiliaire médical',
    'classCode': '10',
    'classSystem': '1.2.250.1.213.1.1.4.1',
    'classLabel': 'Compte rendu',
    'catalogReference': 'Référence synthétique',
    'patientVisibility': 'visible',
    'representativesVisibility': 'sans objet',
    'professionalVisibility': 'visible',
  };

  return draft;
}

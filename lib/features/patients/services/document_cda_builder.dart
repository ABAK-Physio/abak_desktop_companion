import 'dmp_chain/native/dv1_replacement.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:xml/xml.dart';
import 'document_medical_service.dart';
import 'cnda_patient_recipe.dart';

/// A local preparation profile, never an XDS submission or a CPS signature.
/// No template patient, default author or inferred authority is used.
class DocumentCdaBuilder {
  static const protocol = 'ABAK-CDA-PREPARATION-1';
  static String oid(Object? value) {
    final text = (value ?? '').toString();
    if (!RegExp(r'^[0-2](\.[0-9]+)+$').hasMatch(text)) {
      throw StateError('Autorité ou système de codage non défini comme OID.');
    }
    return text;
  }

  static String date(String value) =>
      '${DateTime.parse(value).toUtc().toIso8601String().substring(0, 19).replaceAll(RegExp('[-:T]'), '')}+0000';
  static String stableId(String value) => const Uuid()
      .v5(Namespace.url.value, 'urn:abak:document:$value')
      .toUpperCase();
  static String documentId(Map snapshot) =>
      '2.25.${BigInt.parse(stableId('${snapshot['version']['version_id']}:${medicalHash(snapshot)}').replaceAll('-', ''), radix: 16)}';
  static Uint8List build(Map snapshot, Uint8List pdf, int approvedAt) {
    CndaPatientRecipe.checkDocument(snapshot);
    final d = jsonDecode(snapshot['preparation']['data_json']) as Map;
    final c = jsonDecode(snapshot['practice']['data_json']) as Map;
    final i = snapshot['identity'] as Map;
    final v = snapshot['version'] as Map;
    if (d['authorId'] != d['validatorId']) {
      throw StateError(
        'CDA non vérifié : contexte identifié du validateur distinct encore requis.',
      );
    }
    if (d['patientVisibility'] != 'visible' ||
        d['professionalVisibility'] != 'visible' ||
        d['representativesVisibility'] != 'sans objet') {
      throw StateError(
        'CDA non vérifié : visibilité ou mineur hors du profil local courant.',
      );
    }
    if (c['setting'] != 'Ambulatoire' || (c['replacementFor'] ?? '') != '') {
      throw StateError(
        'CDA non vérifié : cadre ambulatoire explicite requis ; remplacement non pris en charge.',
      );
    }
    // The existing identity source has a list of given names, not a separate first given name.
    final given = (i['birth_first_names'] as String).trim();
    if (RegExp(r'\s|,|;').hasMatch(given)) {
      throw StateError(
        'CDA non vérifié : premier prénom de naissance distinct indisponible dans la source qualifiée.',
      );
    }
    final born = DateTime.tryParse(i['birth_date'] as String);
    final clinical = DateTime.parse(d['clinicalDate']);
    if (born == null ||
        born.toIso8601String().substring(0, 10) != i['birth_date'] ||
        clinical.isBefore(DateTime.utc(born.year + 18, born.month, born.day))) {
      throw StateError(
        'CDA non vérifié : date de naissance invalide ou parcours mineur non pris en charge.',
      );
    }
    if (!['M', 'F', 'UN'].contains(i['sex_code']) ||
        !RegExp(r'^\d{13}$').hasMatch(i['ins_number']) ||
        !RegExp(r'^\d{2}$').hasMatch(i['ins_key'])) {
      throw StateError(
        'CDA non vérifié : traits qualifiés non représentables.',
      );
    }
    if ((c['facilityCode'] ?? '').isEmpty ||
        (c['facilityLabel'] ?? '').isEmpty) {
      throw StateError(
        'CDA non vérifié : code et libellé du lieu de soins à compléter dans la situation professionnelle.',
      );
    }
    if ((c['familyName'] ?? '').trim().isEmpty ||
        (c['givenNames'] ?? '').trim().isEmpty) {
      throw StateError(
        'CDA non vérifié : nom et prénoms professionnels explicites requis. Le nom affiché dans l’annuaire ne permet pas de les déduire.',
      );
    }
    final b = XmlBuilder();
    void e(
      String n, {
      Map<String, String> a = const {},
      dynamic text,
      void Function()? children,
    }) => b.element(
      n,
      attributes: a,
      nest:
          children ??
          () {
            if (text != null) b.text(text.toString());
          },
    );
    void person() => e(
      'assignedPerson',
      children: () => e(
        'name',
        children: () {
          e('given', text: c['givenNames']);
          e('family', text: c['familyName']);
        },
      ),
    );
    void identifier() =>
        e('id', a: {'root': oid(c['authority']), 'extension': c['identifier']});
    void structure() {
      e(
        'id',
        a: {
          'root': oid(c['structureAuthority']),
          'extension': c['structureId'],
        },
      );
      e('name', text: c['structureName']);
    }

    final time = date(d['clinicalDate']);
    b.processing('xml', 'version="1.0" encoding="UTF-8"');
    e(
      'ClinicalDocument',
      a: {'xmlns': 'urn:hl7-org:v3'},
      children: () {
        e('realmCode', a: {'code': 'FR'});
        e(
          'typeId',
          a: {'root': '2.16.840.1.113883.1.3', 'extension': 'POCD_HD000040'},
        );
        for (final id in [
          '1.2.250.1.213.1.1.1.1',
          '2.16.840.1.113883.2.8.2.1',
          '1.3.6.1.4.1.19376.1.2.20',
        ]) {
          e('templateId', a: {'root': id});
        }
        e('id', a: {'root': documentId(snapshot)});
        e(
          'code',
          a: {
            'code': d['typeCode'],
            'codeSystem': oid(d['typeSystem']),
            'displayName': d['typeLabel'],
          },
        );
        e('title', text: d['title']);
        e('effectiveTime', a: {'value': time});
        e(
          'confidentialityCode',
          a: {
            'code': 'N',
            'codeSystem': '2.16.840.1.113883.5.25',
            'displayName': 'Normal',
          },
        );
        e('languageCode', a: {'code': d['language']});
        e('setId', a: {'root': stableId(v['document_id'])});
        e('versionNumber', a: {'value': '${v['sequence_number']}'});
        e(
          'recordTarget',
          children: () => e(
            'patientRole',
            children: () {
              e(
                'id',
                a: {
                  'root': oid(i['ins_oid']),
                  'extension': '${i['ins_number']}${i['ins_key']}',
                },
              );
              e(
                'patient',
                children: () {
                  e(
                    'name',
                    children: () {
                      e('given', a: {'qualifier': 'BR'}, text: given);
                      e('given', text: given);
                      e(
                        'family',
                        a: {'qualifier': 'BR'},
                        text: i['birth_last_name'],
                      );
                    },
                  );
                  e(
                    'administrativeGenderCode',
                    a: {
                      'code': i['sex_code'],
                      'codeSystem': '2.16.840.1.113883.5.1',
                    },
                  );
                  e(
                    'birthTime',
                    a: {
                      'value': (i['birth_date'] as String).replaceAll('-', ''),
                    },
                  );
                  e(
                    'birthplace',
                    children: () => e(
                      'place',
                      children: () => e(
                        'addr',
                        children: () =>
                            e('county', text: i['birth_place_code']),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        );
        e(
          'author',
          children: () {
            e('time', a: {'value': time});
            e(
              'assignedAuthor',
              children: () {
                identifier();
                e(
                  'code',
                  a: {
                    'code': c['professionCode'],
                    'codeSystem': oid(c['professionSystem']),
                    'displayName': c['professionLabel'],
                  },
                );
                person();
              },
            );
          },
        );
        e(
          'custodian',
          children: () => e(
            'assignedCustodian',
            children: () =>
                e('representedCustodianOrganization', children: structure),
          ),
        );
        e(
          'legalAuthenticator',
          children: () {
            e(
              'time',
              a: {
                'value': date(
                  DateTime.fromMillisecondsSinceEpoch(
                    approvedAt,
                    isUtc: true,
                  ).toIso8601String(),
                ),
              },
            );
            e('signatureCode', a: {'code': 'S'});
            e(
              'assignedEntity',
              children: () {
                identifier();
                person();
              },
            );
          },
        );
        e(
          'documentationOf',
          children: () => e(
            'serviceEvent',
            a: {'classCode': 'ACT'},
            children: () {
              e('code', a: {'nullFlavor': 'NA'});
              e(
                'effectiveTime',
                children: () {
                  e('low', a: {'value': time});
                  e('high', a: {'value': time});
                },
              );
              e(
                'performer',
                a: {'typeCode': 'PRF'},
                children: () => e(
                  'assignedEntity',
                  children: () {
                    identifier();
                    person();
                    e(
                      'representedOrganization',
                      children: () {
                        structure();
                        e(
                          'standardIndustryClassCode',
                          a: {
                            'code': 'AMBULATOIRE',
                            'codeSystem': '1.2.250.1.213.1.1.4.9',
                            'displayName': 'Ambulatoire',
                          },
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        );
        final replacement = Dv1Replacement.fromPreparation(d);
        if (replacement != null) {
          e(
            'relatedDocument',
            a: {'typeCode': 'RPLC'},
            children: () {
              e(
                'parentDocument',
                children: () {
                  e('id', a: {'root': replacement['uniqueId'] as String});
                },
              );
            },
          );
        }
        e(
          'componentOf',
          children: () => e(
            'encompassingEncounter',
            children: () {
              e('id', a: {'root': stableId('episode:${v['episode_id']}')});
              e('effectiveTime', children: () => e('low', a: {'value': time}));
              e(
                'location',
                children: () => e(
                  'healthCareFacility',
                  children: () {
                    e(
                      'code',
                      a: {
                        'code': c['facilityCode'],
                        'codeSystem': '1.2.250.1.71.4.2.4',
                        'displayName': c['facilityLabel'],
                      },
                    );
                    e(
                      'location',
                      children: () => e('name', text: c['structureName']),
                    );
                  },
                ),
              );
            },
          ),
        );
        e(
          'component',
          children: () => e(
            'nonXMLBody',
            children: () => e(
              'text',
              a: {'mediaType': 'application/pdf', 'representation': 'B64'},
              text: base64Encode(pdf),
            ),
          ),
        );
      },
    );
    return Uint8List.fromList(utf8.encode(b.buildDocument().toXmlString()));
  }
}

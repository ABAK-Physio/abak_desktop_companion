import 'package:uuid/uuid.dart';
import 'access_context.dart';
import '../../cnda_patient_recipe.dart';
import '../../document_medical_service.dart';
import '../contracts.dart';
import '../messages.dart';
import '../wire/package.dart';

/// PRPA_IN201307UV02 / TEST_EXST, SEL-MP-037 2.10 and archived HL7 schema.
/// All identifiers are fresh, and the INS comes only from the frozen snapshot.
class DmpNativeTd02 {
  static const action = 'urn:hl7-org:v3:PRPA_IN201307UV02';
  static String build(
    Map<String, dynamic> snapshot,
    DmpSession session,
    DmpWireMaterial material,
    DateTime time,
    String endpoint, {
    required String processingMode,
    Dv1AccessContext? accessContext,
  }) {
    material.check(session, time);
    final u = Uri.parse(endpoint);
    if (u.scheme != 'https' ||
        u.host.isEmpty ||
        u.path.isEmpty ||
        u.userInfo.isNotEmpty ||
        u.hasQuery ||
        u.hasFragment ||
        !['T', 'P'].contains(processingMode)) {
      throw const DmpChainBlock('Configuration TD0.2 incomplète.');
    }
    final identity = snapshot['identity'];
    final ins = DmpChainMessages.patient(snapshot);
    if (accessContext != null) {
      accessContext.check(time);
      if (endpoint != Dv1AccessContext.endpoint ||
          processingMode != 'T' ||
          medicalCanonical(snapshot) !=
              medicalCanonical(accessContext.snapshot)) {
        throw const DmpChainBlock('Contexte de recette DV1 différent.');
      }
    }
    final recipe = snapshot['cndaRecipe'] != null;
    if (recipe) {
      CndaPatientRecipe.checkDestination(snapshot, endpoint, accessOnly: true);
      if (endpoint != CndaPatientRecipe.patients || processingMode != 'T') {
        throw const DmpChainBlock(
          'Recette CNDA limitée à TD0.2 sur DV1 en mode test.',
        );
      }
    }
    if ((accessContext == null &&
            !recipe &&
            (identity['identity_status'] != 'qualified' ||
                identity['identity_doubtful'] != 0)) ||
        identity['ins_oid'] != '1.2.250.1.213.1.4.10' ||
        !RegExp(r'^\d{15}$').hasMatch(ins)) {
      throw const DmpChainBlock('Identité qualifiée NIR requise pour TD0.2.');
    }
    final tag = DmpWireDraft.tag, text = DmpWireDraft.text;
    final cfg = material.configuration;
    final timestamp = time
        .toUtc()
        .toIso8601String()
        .substring(0, 19)
        .replaceAll(RegExp('[-:T]'), '');
    String device(String name, String id, String software, String type) => tag(
      name,
      tag(
        'device',
        tag('id', '', {'root': id}) + text('softwareName', software),
        {'classCode': 'DEV', 'determinerCode': 'INSTANCE'},
      ),
      {'typeCode': type},
    );
    final body = tag(
      'PRPA_IN201307UV02',
      tag('id', '', {'root': cfg.sourceId, 'extension': const Uuid().v4()}) +
          tag('creationTime', '', {'value': timestamp}) +
          tag('interactionId', '', {
            'root': '2.16.840.1.113883.1.6',
            'extension': 'PRPA_IN201307UV02',
          }) +
          tag('processingCode', '', {'code': 'D'}) +
          tag('processingModeCode', '', {'code': processingMode}) +
          tag('acceptAckCode', '', {'code': 'AL'}) +
          device('receiver', '1.2.250.1.213.4.1.1.1', 'DMP', 'RCV') +
          device('sender', cfg.sourceId, cfg.lpsName, 'SND') +
          tag('attentionLine', '', {'xsi:nil': 'true'}) +
          tag(
            'controlActProcess',
            tag('reasonCode', '', {
                  'code': 'TEST_EXST',
                  'codeSystem': '1.2.250.1.213.1.1.4.11',
                  'displayName': "Test d'existence de dossier",
                }) +
                tag(
                  'queryByParameter',
                  tag('queryId', '', {
                        'root': cfg.sourceId,
                        'extension': const Uuid().v4(),
                      }) +
                      tag('statusCode', '', {'code': 'new'}) +
                      tag(
                        'parameterList',
                        tag('dataSource', '', {'xsi:nil': 'true'}) +
                            tag(
                              'patientIdentifier',
                              tag('value', '', {
                                    'root': identity['ins_oid'],
                                    'extension': ins,
                                  }) +
                                  text('semanticsText', 'Patient.id'),
                            ),
                      ),
                ),
            {'classCode': 'CACT', 'moodCode': 'EVN'},
          ),
      {
        'xmlns': 'urn:hl7-org:v3',
        'xmlns:xsi': 'http://www.w3.org/2001/XMLSchema-instance',
        'ITSVersion': 'XML_1.0',
      },
    );
    final vihf = DmpWireDraft.buildVihf(
      snapshot,
      session,
      material,
      time,
      const Uuid().v4(),
      secretConnection: accessContext?.secretConnection ?? false,
    );
    return tag(
      's:Envelope',
      tag(
            's:Header',
            text('w:MessageID', DmpChainMessages.id) +
                text('w:To', endpoint) +
                text('w:Action', action) +
                tag(
                  'w:ReplyTo',
                  text(
                    'w:Address',
                    'http://www.w3.org/2005/08/addressing/anonymous',
                  ),
                ) +
                tag('sec:Security', vihf, {
                  'xmlns:sec':
                      'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd',
                }),
          ) +
          tag('s:Body', body),
      {'xmlns:s': DmpChainMessages.soap, 'xmlns:w': DmpChainMessages.wsa},
    );
  }
}

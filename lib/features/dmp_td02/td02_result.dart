import 'package:xml/xml.dart';

enum DmpState { unknown, absent, closed, active, nia }

enum ConsultationRight { unknown, absent, valid, expired, blocked }

enum DmpAction { deposit, technicalSearch, replace, delete, consult }

class Td02Context {
  const Td02Context({
    required this.ins,
    required this.oid,
    required this.professional,
  });
  final String ins, oid, professional;
  bool get isNia => oid == '1.2.250.1.213.1.4.9';
}

/// Offline results cannot authorize a network operation.
class Td02Result {
  const Td02Result(
    this.state, {
    this.right = ConsultationRight.unknown,
    this.detail = '',
    this.closedAt = '',
    this.reasonCode = '',
    this.reason = '',
  });
  final DmpState state;
  final ConsultationRight right;
  final String detail, closedAt, reasonCode, reason;
  bool get canSendNetworkRequest => false;
  String get message => switch (state) {
    DmpState.unknown => 'Vérification du DMP impossible. Aucun envoi effectué.',
    DmpState.absent => 'Aucun DMP trouvé. Opérations DMP indisponibles.',
    DmpState.closed => 'DMP fermé. Envoi et consultation indisponibles.',
    DmpState.nia =>
      'Accès DMP indisponible : identité NIA. Un NIR utilisable comme INS est nécessaire.',
    DmpState.active => switch (right) {
      ConsultationRight.valid =>
        'DMP actif. Autorisation de consultation valide.',
      ConsultationRight.absent =>
        'DMP actif. Aucune autorisation de consultation enregistrée.',
      ConsultationRight.expired =>
        'DMP actif. Autorisation de consultation expirée.',
      ConsultationRight.blocked =>
        'DMP actif. Consultation bloquée pour ce professionnel.',
      ConsultationRight.unknown =>
        'DMP actif. Autorisation de consultation indéterminée. Opérations suspendues.',
    },
  };
  String get closureDetails => [
    if (closedAt.isNotEmpty) 'Date de fermeture : $closedAt',
    if (reasonCode.isNotEmpty)
      switch (reasonCode) {
        'FERMETURE_DEMANDE_PATIENT' =>
          'Motif : fermeture du DMP à la demande du patient.',
        'DECES' => 'Motif : fermeture du DMP suite au décès du patient.',
        _ => 'Motif non reconnu : $reasonCode',
      },
    if (reason.isNotEmpty) 'Raison transmise : $reason',
  ].join('\n');
  // These are eligibility rules for a local rehearsal, never an authorization to send.
  bool allows(
    DmpAction action, {
    required bool opposition,
    required bool functionalRights,
    required bool authorRights,
    required bool consultationConsent,
  }) {
    if (state != DmpState.active ||
        right == ConsultationRight.unknown ||
        !functionalRights) {
      return false;
    }
    if (action == DmpAction.consult) {
      return right == ConsultationRight.valid && consultationConsent;
    }
    if (action == DmpAction.deposit) return !opposition && authorRights;
    if (action == DmpAction.replace || action == DmpAction.delete) {
      return authorRights;
    }
    return true;
  }
}

class Td02Reader {
  static const soap = 'http://www.w3.org/2003/05/soap-envelope';
  static const hl7 = 'urn:hl7-org:v3';
  static const wsa = 'http://www.w3.org/2005/08/addressing';
  static const saml = 'urn:oasis:names:tc:SAML:2.0:assertion';
  static List<XmlElement> children(XmlNode n, String name, String ns) => n
      .children
      .whereType<XmlElement>()
      .where((e) => e.name.local == name && e.namespaceUri == ns)
      .toList();
  static XmlElement one(XmlNode n, String name, String ns) {
    final list = children(n, name, ns);
    if (list.length != 1) {
      throw FormatException('Champ absent ou dupliqué : $name');
    }
    return list.single;
  }

  static String attr(XmlElement e, String name) {
    final s = e.getAttribute(name);
    if (s == null || s.isEmpty) {
      throw FormatException('Attribut absent : $name');
    }
    return s;
  }

  static XmlElement parse(String s) {
    if (s.length > 2000000 ||
        s.contains('<!DOCTYPE') ||
        s.contains('<!ENTITY')) {
      throw const FormatException('XML interdit ou trop volumineux');
    }
    final root = XmlDocument.parse(s).rootElement;
    if (root.name.local != 'Envelope' || root.namespaceUri != soap) {
      throw const FormatException('Enveloppe SOAP inattendue');
    }
    return root;
  }

  static void check(bool ok, String why) {
    if (!ok) throw FormatException(why);
  }

  static void sameId(XmlElement a, XmlElement b) => check(
    attr(a, 'root') == attr(b, 'root') &&
        attr(a, 'extension') == attr(b, 'extension'),
    'Identifiants de corrélation différents',
  );
  static Td02Result read({
    required String request,
    required String response,
    required Td02Context context,
    int httpStatus = 200,
  }) {
    if (context.isNia) return const Td02Result(DmpState.nia);
    try {
      check(
        context.oid == '1.2.250.1.213.1.4.10',
        'Seuls les INS de test DV1 sont acceptés ici',
      );
      check(
        httpStatus == 200 || httpStatus == 500,
        'Service DMP indisponible (HTTP $httpStatus).',
      );
      final q = parse(request), r = parse(response);
      final responseBody = one(r, 'Body', soap);
      check(
        children(responseBody, 'Fault', soap).isEmpty,
        'Erreur SOAP : la vérification a échoué. Aucun état du DMP ne peut être confirmé.',
      );
      check(httpStatus == 200, 'Service DMP indisponible (HTTP $httpStatus).');
      final qh = one(q, 'Header', soap), rh = one(r, 'Header', soap);
      check(
        one(qh, 'Action', wsa).innerText == 'urn:hl7-org:v3:PRPA_IN201307UV02',
        'Action requête inattendue',
      );
      check(
        one(rh, 'Action', wsa).innerText == 'urn:hl7-org:v3:PRPA_IN201308UV02',
        'Action réponse inattendue',
      );
      check(
        one(rh, 'RelatesTo', wsa).innerText ==
            one(qh, 'MessageID', wsa).innerText,
        'Réponse destinée à une autre requête : résultat ignoré.',
      );
      final names = qh.descendants
          .whereType<XmlElement>()
          .where((e) => e.name.local == 'NameID' && e.namespaceUri == saml)
          .toList();
      check(
        names.length == 1 && names.single.innerText == context.professional,
        'Professionnel différent',
      );
      final qb = one(one(q, 'Body', soap), 'PRPA_IN201307UV02', hl7);
      final rb = one(r, 'Body', soap);
      check(children(rb, 'Fault', soap).isEmpty, 'Erreur SOAP');
      final body = one(rb, 'PRPA_IN201308UV02', hl7);
      final ack = one(body, 'acknowledgement', hl7);
      sameId(
        one(one(ack, 'targetMessage', hl7), 'id', hl7),
        one(qb, 'id', hl7),
      );
      check(attr(ack, 'typeCode') == 'AA', 'Erreur applicative HL7');
      final qca = one(qb, 'controlActProcess', hl7),
          ca = one(body, 'controlActProcess', hl7);
      final query = one(qca, 'queryByParameter', hl7),
          queryAck = one(ca, 'queryAck', hl7);
      sameId(one(query, 'queryId', hl7), one(queryAck, 'queryId', hl7));
      final identifier = one(
        one(one(query, 'parameterList', hl7), 'patientIdentifier', hl7),
        'value',
        hl7,
      );
      check(
        attr(identifier, 'extension') == context.ins &&
            attr(identifier, 'root') == context.oid,
        'Patient de la requête différent',
      );
      final code = attr(one(queryAck, 'queryResponseCode', hl7), 'code');
      final subjects = children(ca, 'subject', hl7);
      if (code == 'NF') {
        check(subjects.isEmpty, 'Réponse NF contradictoire');
        return const Td02Result(DmpState.absent);
      }
      check(
        code == 'OK' && subjects.length == 1,
        'Réponse inconnue ou patient ambigu',
      );
      final reg = one(subjects.single, 'registrationEvent', hl7);
      final patient = one(one(reg, 'subject1', hl7), 'patient', hl7);
      final id = one(patient, 'id', hl7);
      check(
        attr(id, 'extension') == context.ins && attr(id, 'root') == context.oid,
        'Patient de la réponse différent',
      );
      final status = attr(one(patient, 'statusCode', hl7), 'code');
      if (status == 'terminated') {
        final dates = children(reg, 'effectiveTime', hl7);
        check(dates.length <= 1, 'Dates de fermeture ambiguës');
        final reasons = children(ca, 'reasonOf', hl7);
        check(reasons.length <= 1, 'Motifs de fermeture ambigus');
        String reasonCode = '', reason = '';
        if (reasons.isNotEmpty) {
          final issue = one(reasons.single, 'detectedIssueEvent', hl7);
          final codes = children(issue, 'code', hl7),
              texts = children(issue, 'text', hl7);
          check(codes.length <= 1 && texts.length <= 1, 'Motif ambigu');
          reasonCode = codes.isEmpty
              ? ''
              : codes.single.getAttribute('code') ?? '';
          reason = texts.isEmpty ? '' : texts.single.innerText;
        }
        return Td02Result(
          DmpState.closed,
          closedAt: dates.isEmpty
              ? ''
              : dates.single.getAttribute('value') ?? '',
          reasonCode: reasonCode,
          reason: reason,
        );
      }
      check(status == 'active', 'Statut DMP inconnu : $status');
      final auth = children(body, 'attentionLine', hl7)
          .where(
            (e) => children(
              e,
              'keyWordText',
              hl7,
            ).any((k) => k.getAttribute('code') == 'AUTORISATION'),
          )
          .toList();
      if (auth.length != 1) {
        return const Td02Result(
          DmpState.active,
          detail: 'Autorisation absente ou dupliquée.',
        );
      }
      final value = attr(one(auth.single, 'value', hl7), 'code');
      final right = switch (value) {
        'VALIDE' => ConsultationRight.valid,
        'NON_EXISTE' => ConsultationRight.absent,
        'EXPIRE' => ConsultationRight.expired,
        'INTERDIT' => ConsultationRight.blocked,
        _ => ConsultationRight.unknown,
      };
      return Td02Result(DmpState.active, right: right);
    } catch (e) {
      return Td02Result(
        DmpState.unknown,
        detail: e is FormatException
            ? e.message.toString()
            : 'Réponse XML inexploitable.',
      );
    }
  }
}

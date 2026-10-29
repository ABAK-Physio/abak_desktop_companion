import 'dart:convert';
import 'package:xml/xml.dart';
import '../../../../dmp_td02/td02_result.dart';
import '../../../../dmp_transfer/archive_deposit_reader.dart';
import '../contracts.dart';
import '../wire/package.dart';
import 'access_context.dart';
import 'td03.dart';
import 'td31b.dart';

/// Explicit read-only FindDocuments, SEL-MP-037 §3.5.1 and IHE ITI-18.
class Dv1DocumentCriteria {
  const Dv1DocumentCriteria({
    this.archived = false,
    this.deprecated = false,
    this.uniqueIds = const [],
    this.typeCode = '',
    this.typeSystem = '2.16.840.1.113883.6.1',
  });
  final List<String> uniqueIds;
  final bool archived, deprecated;
  final String typeCode, typeSystem;
  static const approved = 'urn:oasis:names:tc:ebxml-regrep:StatusType:Approved';
  static const archivedStatus = 'urn:asip:ci-sis:2010:StatusType:Archived';
  static const deprecatedStatus =
      'urn:oasis:names:tc:ebxml-regrep:StatusType:Deprecated';
  List<String> get statuses => [
    approved,
    if (archived) archivedStatus,
    if (deprecated) deprecatedStatus,
  ];
  void check() {
    if (uniqueIds.isNotEmpty &&
        (uniqueIds.length > 4 ||
            uniqueIds.toSet().length != uniqueIds.length ||
            typeCode.isNotEmpty ||
            !archived ||
            !deprecated ||
            uniqueIds.any(
              (id) => !RegExp(r'^[0-2](\.[0-9]+)+$').hasMatch(id),
            ))) {
      throw StateError('Recherche par identifiants invalide.');
    }
    if (typeCode.isNotEmpty &&
        (!RegExp(r'^[A-Za-z0-9._-]{1,64}$').hasMatch(typeCode) ||
            !RegExp(r'^[0-2](\.[0-9]+)+$').hasMatch(typeSystem))) {
      throw StateError(
        'Indiquez un code de type documentaire et son OID de nomenclature valides.',
      );
    }
  }

  Map<String, dynamic> get data => {
    if (uniqueIds.isNotEmpty) 'uniqueIds': uniqueIds,
    'statuses': statuses,
    'typeCode': typeCode,
    'typeSystem': typeCode.isEmpty ? '' : typeSystem,
  };
  String get label => uniqueIds.isNotEmpty
      ? 'Recherche des identifiants ${uniqueIds.join(', ')} — actifs, archivés et remplacés ; métadonnées uniquement'
      : 'Documents actifs${archived ? ', archivés' : ''}${deprecated ? ', remplacés' : ''}'
            ' · ${typeCode.isEmpty ? 'tous types' : '$typeCode ($typeSystem)'}';
}

class DmpNativeTd31a {
  static const findDocuments = 'urn:uuid:14d4debf-8f97-4251-9a74-a90016b0af0d';
  static const patientScheme = 'urn:uuid:58a6f841-87b3-4a3e-92fd-a8ffeff98427';
  static const uniqueScheme = 'urn:uuid:2e82c1f6-a085-4c72-9da3-8640a32e42ab';
  static const typeScheme = 'urn:uuid:f0306f51-975f-434e-a61c-c59651d33983';
  static String patientId(String ins) => '$ins^^^&1.2.250.1.213.1.4.10&ISO^NH';

  /// Compare the identity-bearing CX components, accepting only the optional
  /// empty CX.6 and calendar date CX.7 observed in archived DV1 metadata.
  /// Never accept an arbitrary suffix, a different INS authority or type.
  static bool matchesPatientId(String value, String ins) {
    if (!RegExp(r'^\d{15}$').hasMatch(ins)) return false;
    final parts = value.split('^');
    if (parts.length != 5 && parts.length != 7) return false;
    if (parts.take(5).join('^') != patientId(ins)) return false;
    if (parts.length == 5) return true;
    if (parts[5].isNotEmpty || !RegExp(r'^\d{8}$').hasMatch(parts[6])) {
      return false;
    }
    final date = parts[6];
    final year = int.parse(date.substring(0, 4));
    final month = int.parse(date.substring(4, 6));
    final day = int.parse(date.substring(6, 8));
    final parsed = DateTime.utc(year, month, day);
    return year > 0 &&
        parsed.year == year &&
        parsed.month == month &&
        parsed.day == day;
  }

  static String build(
    Dv1AccessContext context,
    DmpSession session,
    DmpWireMaterial material,
    DateTime time,
    Dv1DocumentCriteria criteria,
  ) {
    criteria.check();
    if (!RegExp(r'^\d{15}$').hasMatch(context.ins)) {
      throw StateError('INS de test invalide.');
    }
    final envelope = Td02Reader.parse(
      DmpNativeTd31b.fromPatientRequest(
        DmpNativeTd03.build(context, session, material, time, add: true),
        '2.25.1',
      ),
    );
    final b = XmlBuilder();
    b.element(
      'AdhocQueryRequest',
      attributes: {'xmlns': DmpNativeTd31b.query},
      nest: () {
        b.element(
          'ResponseOption',
          attributes: {
            'returnType': 'LeafClass',
            'returnComposedObjects': 'true',
          },
        );
        b.element(
          'rim:AdhocQuery',
          attributes: {
            'xmlns:rim': DmpNativeTd31b.rim,
            'id': criteria.uniqueIds.isEmpty
                ? findDocuments
                : DmpNativeTd31b.getDocuments,
          },
          nest: () {
            void slot(String name, String value) => b.element(
              'rim:Slot',
              attributes: {'name': name},
              nest: () => b.element(
                'rim:ValueList',
                nest: () => b.element('rim:Value', nest: value),
              ),
            );
            if (criteria.uniqueIds.isNotEmpty) {
              slot(
                r'$XDSDocumentEntryUniqueId',
                "(${criteria.uniqueIds.map((id) => "'$id'").join(',')})",
              );
              return;
            }
            slot(r'$XDSDocumentEntryPatientId', "'${patientId(context.ins)}'");
            slot(
              r'$XDSDocumentEntryStatus',
              "(${criteria.statuses.map((s) => "'$s'").join(',')})",
            );
            if (criteria.typeCode.isNotEmpty) {
              slot(
                r'$XDSDocumentEntryTypeCode',
                "('${criteria.typeCode}^^${criteria.typeSystem}')",
              );
            }
          },
        );
      },
    );
    Td02Reader.one(envelope, 'Body', Td02Reader.soap).children
      ..clear()
      ..add(b.buildDocument().rootElement.copy());
    return envelope.toXmlString();
  }

  /// Shared strict HTTP, SOAP correlation and registry-success validation.
  static XmlElement registryObjects(String request, DmpTd02Reply reply) {
    final response = Td02Reader.parse(
      ArchiveDepositReader.extract(reply.headers ?? '', utf8.encode(reply.xml)),
    );
    final header = Td02Reader.one(response, 'Header', Td02Reader.soap);
    final sent = Td02Reader.one(
      Td02Reader.parse(request),
      'Header',
      Td02Reader.soap,
    );
    if (reply.status != 200 ||
        Td02Reader.one(header, 'RelatesTo', Td02Reader.wsa).innerText.trim() !=
            Td02Reader.one(
              sent,
              'MessageID',
              Td02Reader.wsa,
            ).innerText.trim() ||
        Td02Reader.one(header, 'Action', Td02Reader.wsa).innerText.trim() !=
            '${DmpNativeTd31b.action}Response') {
      throw StateError(
        'Réponse TD3.1 non confirmée : statut HTTP, action ou corrélation incorrects.',
      );
    }
    final body = Td02Reader.one(response, 'Body', Td02Reader.soap);
    final result = Td02Reader.one(
      body,
      'AdhocQueryResponse',
      DmpNativeTd31b.query,
    );
    if (body.childElements.length != 1 ||
        result.childElements.length != 1 ||
        result.getAttribute('status') !=
            'urn:oasis:names:tc:ebxml-regrep:ResponseStatusType:Success') {
      throw StateError(
        'Recherche refusée ou incomplète. Réponse conservée dans les preuves.',
      );
    }
    return Td02Reader.one(result, 'RegistryObjectList', DmpNativeTd31b.rim);
  }

  static List<Map<String, String>> read(
    String request,
    DmpTd02Reply reply,
    String ins,
    Dv1DocumentCriteria criteria,
  ) {
    criteria.check();
    final list = registryObjects(request, reply);
    final rows = <Map<String, String>>[];
    final ids = <String>{};
    for (final e in list.childElements) {
      final id = e.getAttribute('id') ?? '';
      if (e.namespaceUri != DmpNativeTd31b.rim ||
          !RegExp(
            r'^urn:uuid:[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$',
          ).hasMatch(id) ||
          !ids.add(id.toLowerCase())) {
        throw const FormatException('Objet de recherche invalide ou dupliqué.');
      }
      // Registry references accompanying LeafClass metadata are not documents.
      if (e.name.local == 'ObjectRef' && e.childElements.isEmpty) continue;
      if (e.name.local != 'ExtrinsicObject') {
        throw const FormatException(
          'Résultat autre que des métadonnées documentaires.',
        );
      }
      String external(String scheme) =>
          Td02Reader.children(e, 'ExternalIdentifier', DmpNativeTd31b.rim)
              .where((v) => v.getAttribute('identificationScheme') == scheme)
              .single
              .getAttribute('value') ??
          '';
      String slot(XmlElement parent, String name) {
        final values = Td02Reader.children(
          parent,
          'Slot',
          DmpNativeTd31b.rim,
        ).where((s) => s.getAttribute('name') == name);
        if (values.isEmpty) return '';
        return Td02Reader.one(
          Td02Reader.one(values.single, 'ValueList', DmpNativeTd31b.rim),
          'Value',
          DmpNativeTd31b.rim,
        ).innerText;
      }

      String label(XmlElement parent) {
        final names = Td02Reader.children(parent, 'Name', DmpNativeTd31b.rim);
        if (names.isEmpty) return '';
        return Td02Reader.children(
              names.single,
              'LocalizedString',
              DmpNativeTd31b.rim,
            ).first.getAttribute('value') ??
            '';
      }

      final patient = external(patientScheme);
      final status = e.getAttribute('status') ?? '';
      final type = Td02Reader.children(e, 'Classification', DmpNativeTd31b.rim)
          .where((c) => c.getAttribute('classificationScheme') == typeScheme)
          .single;
      final code = type.getAttribute('nodeRepresentation') ?? '';
      final system = slot(type, 'codingScheme');
      if (!matchesPatientId(patient, ins) ||
          !criteria.statuses.contains(status) ||
          (criteria.typeCode.isNotEmpty &&
              (code != criteria.typeCode || system != criteria.typeSystem))) {
        throw StateError(
          'Les métadonnées reçues ne correspondent pas au patient ou aux critères. Aucun résultat validé.',
        );
      }
      final uniqueId = external(uniqueScheme);
      if (criteria.uniqueIds.isNotEmpty &&
          !criteria.uniqueIds.contains(uniqueId)) {
        throw StateError('Identifiant retourné hors de la recherche demandée.');
      }
      if (uniqueId.isEmpty) {
        throw const FormatException('Identifiant documentaire absent.');
      }
      rows.add({
        'entryUUID': id,
        'uniqueId': uniqueId,
        'title': label(e),
        'status': status,
        'typeCode': code,
        'typeSystem': system,
        'typeLabel': label(type),
        'creationTime': slot(e, 'creationTime'),
        'mimeType': e.getAttribute('mimeType') ?? '',
        'repositoryUniqueId': slot(e, 'repositoryUniqueId'),
        'hash': slot(e, 'hash'),
        'size': slot(e, 'size'),
        'logicalId': e.getAttribute('lid') ?? '',
        'confidentiality':
            Td02Reader.children(e, 'Classification', DmpNativeTd31b.rim)
                .where(
                  (c) =>
                      c.getAttribute('classificationScheme') ==
                      'urn:uuid:f4f85eac-e6cb-4883-b524-f2705394840f',
                )
                .map((c) => c.getAttribute('nodeRepresentation') ?? '')
                .join('|'),
      });
    }
    return List.unmodifiable(rows);
  }
}

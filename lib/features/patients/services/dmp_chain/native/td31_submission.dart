import 'package:xml/xml.dart';
import '../../../../dmp_td02/td02_result.dart';
import '../contracts.dart';
import 'td31a.dart';
import 'td31b.dart';

/// UI dates are inclusive calendar days in the Mac's local timezone. Wire bounds
/// are UTC instants, lower inclusive and upper exclusive (ITI-18).
class Dv1SubmissionPeriod {
  Dv1SubmissionPeriod.days(String first, String last)
    : from = day(first).toUtc(),
      to = nextDay(day(last)).toUtc(),
      label = 'Dépôts du $first au $last inclus (fuseau de ce Mac)';
  final DateTime from, to;
  final String label;
  static DateTime nextDay(DateTime d) => DateTime(d.year, d.month, d.day + 1);
  static DateTime day(String s) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(s)) {
      throw StateError('Saisissez les dates de dépôt au format AAAA-MM-JJ.');
    }
    final d = DateTime.parse(s);
    if (d.year < 1900 || d.toIso8601String().substring(0, 10) != s) {
      throw StateError('Date de dépôt invalide.');
    }
    return d;
  }

  void check() {
    if (!from.isBefore(to)) {
      throw StateError('La fin doit être postérieure ou égale au début.');
    }
  }

  static String stamp(DateTime d) => d
      .toUtc()
      .toIso8601String()
      .substring(0, 19)
      .replaceAll(RegExp('[-:T]'), '');
  Map<String, dynamic> get data => {
    'fromInclusiveUtc': from.toIso8601String(),
    'toExclusiveUtc': to.toIso8601String(),
    'label': label,
  };
}

/// SEL-MP-037 §3.5.1.3: FindSubmissionSets -> GetAssociations -> GetDocuments.
/// exchange must archive each request/reply before returning; never retries.
class DmpSubmissionSearch {
  DmpSubmissionSearch({this.associationBatch = 1000, this.documentBatch = 88});
  final int associationBatch, documentBatch;
  static const find = 'urn:uuid:f26abbcb-ac74-4422-8a30-edb644bbc1a9';
  static const associations = 'urn:uuid:a7ae438b-4bc2-4642-93e9-be891f7bb155';
  static const documents = 'urn:uuid:5c4f972b-d56b-40ac-a5fc-c8ca9b40b9d4';
  static const patientScheme = 'urn:uuid:6b5aea1a-874d-4603-a4bc-96a0a7b38446';
  static final uuid = RegExp(
    r'^urn:uuid:[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$',
  );
  static String query(String envelope, String id, Map<String, String> slots) {
    // fromPatientRequest refreshes MessageID, destination and action each time.
    final doc = Td02Reader.parse(
      DmpNativeTd31b.fromPatientRequest(envelope, '2.25.1'),
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
          attributes: {'xmlns:rim': DmpNativeTd31b.rim, 'id': id},
          nest: () {
            for (final e in slots.entries) {
              b.element(
                'rim:Slot',
                attributes: {'name': e.key},
                nest: () => b.element(
                  'rim:ValueList',
                  nest: () => b.element('rim:Value', nest: e.value),
                ),
              );
            }
          },
        );
      },
    );
    Td02Reader.one(doc, 'Body', Td02Reader.soap).children
      ..clear()
      ..add(b.buildDocument().rootElement.copy());
    return doc.toXmlString();
  }

  static String slot(XmlElement e, String name) {
    final slots = Td02Reader.children(
      e,
      'Slot',
      DmpNativeTd31b.rim,
    ).where((s) => s.getAttribute('name') == name);
    if (slots.isEmpty) return '';
    return Td02Reader.one(
      Td02Reader.one(slots.single, 'ValueList', DmpNativeTd31b.rim),
      'Value',
      DmpNativeTd31b.rim,
    ).innerText;
  }

  static String ids(Iterable<String> values) =>
      "(${values.map((v) => "'$v'").join(',')})";
  static Iterable<List<String>> batches(Iterable<String> ids, int limit) sync* {
    final all = ids.toList();
    for (var i = 0; i < all.length; i += limit) {
      yield all.sublist(i, i + limit < all.length ? i + limit : all.length);
    }
  }

  Future<Map<String, dynamic>> run({
    required String envelope,
    required String ins,
    required Dv1SubmissionPeriod period,
    required Future<DmpTd02Reply> Function(String stage, String request)
    exchange,
  }) async {
    period.check();
    if (!RegExp(r'^\d{15}$').hasMatch(ins) ||
        associationBatch < 1 ||
        associationBatch > 1000 ||
        documentBatch < 1 ||
        documentBatch > 88) {
      throw StateError('Paramètres de recherche par dépôt invalides.');
    }
    final first = query(envelope, find, {
      r'$XDSSubmissionSetPatientId': "'${DmpNativeTd31a.patientId(ins)}'",
      r'$XDSSubmissionSetStatus': ids([Dv1DocumentCriteria.approved]),
      r'$XDSSubmissionSetSubmissionTimeFrom': Dv1SubmissionPeriod.stamp(
        period.from,
      ),
      r'$XDSSubmissionSetSubmissionTimeTo': Dv1SubmissionPeriod.stamp(
        period.to,
      ),
    });
    final list = DmpNativeTd31a.registryObjects(
      first,
      await exchange('submissions', first),
    );
    final lots = <String, String>{};
    final seen = <String>{};
    for (final e in list.childElements) {
      final id = e.getAttribute('id') ?? '';
      if (e.namespaceUri != DmpNativeTd31b.rim ||
          !uuid.hasMatch(id) ||
          !seen.add(id.toLowerCase())) {
        throw StateError('Lot de soumission invalide ou dupliqué.');
      }
      if (e.name.local == 'ObjectRef' && e.childElements.isEmpty) continue;
      // SubmissionSet classification may be returned beside RegistryPackage.
      if (e.name.local == 'Classification') continue;
      if (e.name.local != 'RegistryPackage' ||
          e.getAttribute('status') != Dv1DocumentCriteria.approved) {
        throw StateError('Objet inattendu dans la recherche des lots.');
      }
      final patient =
          Td02Reader.children(e, 'ExternalIdentifier', DmpNativeTd31b.rim)
              .where(
                (x) => x.getAttribute('identificationScheme') == patientScheme,
              )
              .single
              .getAttribute('value') ??
          '';
      final time = slot(e, 'submissionTime');
      if (!DmpNativeTd31a.matchesPatientId(patient, ins) ||
          !RegExp(r'^\d{14}$').hasMatch(time)) {
        throw StateError('Patient ou date du lot non conforme.');
      }
      final parsed = DateTime.tryParse(
        '${time.substring(0, 4)}-${time.substring(4, 6)}-${time.substring(6, 8)}T${time.substring(8, 10)}:${time.substring(10, 12)}:${time.substring(12, 14)}Z',
      );
      if (parsed == null ||
          Dv1SubmissionPeriod.stamp(parsed) != time ||
          parsed.isBefore(period.from) ||
          !parsed.isBefore(period.to)) {
        throw StateError('Lot hors période de dépôt ou date invalide.');
      }
      lots[id.toLowerCase()] = time;
    }
    final targets = <String, Set<String>>{};
    final signatureLots = <String, Set<String>>{};
    for (final batch in batches(lots.keys, associationBatch)) {
      final request = query(envelope, associations, {r'$uuid': ids(batch)});
      final result = DmpNativeTd31a.registryObjects(
        request,
        await exchange('associations', request),
      );
      final seenAssociations = <String>{};
      for (final e in result.childElements) {
        final id = e.getAttribute('id') ?? '';
        if (e.namespaceUri != DmpNativeTd31b.rim ||
            !uuid.hasMatch(id) ||
            !seenAssociations.add(id.toLowerCase())) {
          throw StateError('Association invalide ou dupliquée.');
        }
        if (e.name.local == 'ObjectRef' && e.childElements.isEmpty) continue;
        if (e.name.local != 'Association') {
          throw StateError('Objet autre qu’une association.');
        }
        final source = (e.getAttribute('sourceObject') ?? '').toLowerCase();
        final target = (e.getAttribute('targetObject') ?? '').toLowerCase();
        if (!batch.contains(source) && !batch.contains(target)) {
          throw StateError('Association sans lien avec les lots demandés.');
        }
        // A signature is exempt from missing clinical metadata only when an
        // Approved signs relation points to the SAME verified submission set
        // as its HasMember relation. Do not infer this from an absent response.
        if (e.getAttribute('associationType') ==
                'urn:ihe:iti:2007:AssociationType:signs' &&
            e.getAttribute('status') == Dv1DocumentCriteria.approved &&
            batch.contains(target) &&
            uuid.hasMatch(source)) {
          signatureLots.putIfAbsent(source, () => <String>{}).add(target);
        }
        if (e.getAttribute('associationType') !=
                'urn:oasis:names:tc:ebxml-regrep:AssociationType:HasMember' ||
            !batch.contains(source)) {
          continue;
        }
        // Only submission-to-document membership has SubmissionSetStatus.
        // Skip folders/association membership and status-update lots.
        final membership = slot(e, 'SubmissionSetStatus');
        if (membership.isEmpty) continue;
        if (!['Original', 'Reference'].contains(membership) ||
            !uuid.hasMatch(target)) {
          throw StateError('Membre de lot invalide.');
        }
        targets.putIfAbsent(target, () => <String>{}).add(source);
      }
    }
    final rows = <Map<String, String>>[];
    final missing = <String>[];
    for (final batch in batches(targets.keys, documentBatch)) {
      final request = query(envelope, documents, {
        r'$XDSDocumentEntryEntryUUID': ids(batch),
      });
      final reply = await exchange('documents', request);
      final docs = DmpNativeTd31a.read(
        request,
        reply,
        ins,
        const Dv1DocumentCriteria(archived: true, deprecated: true),
      );
      final returned = <String>{};
      for (final d in docs) {
        final id = d['entryUUID']!.toLowerCase();
        if (!batch.contains(id) || !returned.add(id)) {
          throw StateError('Document sans lien avec les lots demandés.');
        }
        rows.add({
          ...d,
          'submissionTime': targets[id]!
              .map((s) => lots[s]!)
              .toSet()
              .join(', '),
          'submissionSets': targets[id]!.join(', '),
        });
      }
      missing.addAll(batch.where((id) => !returned.contains(id)));
    }
    final omittedSignatures = missing
        .where(
          (id) =>
              signatureLots[id]?.isNotEmpty == true &&
              targets[id]!.every((lot) => signatureLots[id]!.contains(lot)),
        )
        .toList();
    return {
      'submissionSets': lots,
      'documents': rows,
      'unreturnedMemberIds': missing,
      'omittedSignatureIds': omittedSignatures,
      'signatureSubmissionSets': {
        for (final id in omittedSignatures) id: signatureLots[id]!.toList(),
      },
      'unreturnedDocumentIds': missing
          .where((id) => !omittedSignatures.contains(id))
          .toList(),
    };
  }
}

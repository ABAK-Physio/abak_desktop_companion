import 'package:xml/xml.dart';

/// Informational TD0.2 traits only. Never an INS identity or a patient update.
class DmpPatientPerson {
  DmpPatientPerson(Map<String, String> traits)
    : traits = Map.unmodifiable(traits);
  final Map<String, String> traits;

  static DmpPatientPerson? read(XmlElement patient) {
    const ns = 'urn:hl7-org:v3';
    List<XmlElement> children(XmlElement node, String name) => node.children
        .whereType<XmlElement>()
        .where((e) => e.name.local == name && e.namespaceUri == ns)
        .toList();
    final people = children(patient, 'patientPerson');
    if (people.length != 1 ||
        people.single.getAttribute('nullFlavor') != null) {
      return null;
    }
    final person = people.single;
    final traits = <String, String>{};
    String text(XmlElement e) =>
        e.getAttribute('nullFlavor') != null ? '' : e.innerText.trim();
    void add(String label, Iterable<String> values) {
      final value = values.where((v) => v.isNotEmpty).join(' · ');
      if (value.isNotEmpty) traits[label] = value;
    }

    for (final name in children(person, 'name')) {
      if (name.getAttribute('nullFlavor') != null) continue;
      for (final family in children(name, 'family')) {
        final qualifiers = (family.getAttribute('qualifier') ?? '').split(' ');
        final label = qualifiers.contains('BR')
            ? 'Nom de naissance'
            : qualifiers.contains('SP')
            ? 'Nom d’usage'
            : 'Nom';
        add(label, [
          if (traits.containsKey(label)) traits[label]!,
          text(family),
        ]);
      }
      add('Prénoms', [
        if (traits.containsKey('Prénoms')) traits['Prénoms']!,
        ...children(name, 'given').map(text),
      ]);
    }
    for (final field in {
      'administrativeGenderCode': 'Sexe',
      'birthTime': 'Date de naissance',
    }.entries) {
      final nodes = children(person, field.key);
      if (nodes.length == 1 &&
          nodes.single.getAttribute('nullFlavor') == null) {
        add(field.value, [
          nodes.single.getAttribute(
                field.key == 'birthTime' ? 'value' : 'code',
              ) ??
              '',
        ]);
      }
    }
    for (final place in children(person, 'birthPlace')) {
      for (final location in children(place, 'place')) {
        add('Lieu de naissance', children(location, 'name').map(text));
      }
    }
    return traits.isEmpty ? null : DmpPatientPerson(traits);
  }
}

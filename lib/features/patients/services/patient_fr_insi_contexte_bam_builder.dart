import 'package:xml/xml.dart';

class PatientFrInsiContexteBamBuilder {
  const PatientFrInsiContexteBamBuilder();

  String build({
    required String id,
    required DateTime time,
    String? emitter,
    DateTime? referenceDate,
    String version = '01_02',
  }) {
    final builder = XmlBuilder();

    builder.element(
      'ContexteBAM',
      attributes: {
        'xmlns': 'urn:siram:bam:ctxbam',
        'Version': version,
      },
      nest: () {
        builder.element(
          'Id',
          nest: id,
        );

        builder.element(
          'Temps',
          nest: time.toUtc().toIso8601String(),
        );

        if (emitter != null && emitter.trim().isNotEmpty) {
          builder.element(
            'Emetteur',
            nest: emitter.trim(),
          );
        }

        if (referenceDate != null) {
          builder.element(
            'DateRef',
            nest: referenceDate.toUtc().toIso8601String(),
          );
        }

        builder.element('COUVERTURE');
      },
    );

    return builder.buildDocument().rootElement.toXmlString();
  }
}
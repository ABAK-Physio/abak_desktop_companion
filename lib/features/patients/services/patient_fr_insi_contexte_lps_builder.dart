import 'package:xml/xml.dart';

class PatientFrInsiContexteLpsBuilder {
  const PatientFrInsiContexteLpsBuilder();

  String build({
    required String id,
    required DateTime time,
    String? emitter,
    String version = '01_00',
    String? idam,
    String? idamReference,
    String? lpsVersion,
    String? instance,
    String? name,
  }) {
    final builder = XmlBuilder();

    builder.element(
      'ContexteLPS',
      attributes: {
        'xmlns': 'urn:siram:lps:ctxlps',
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

        final hasLpsData =
            (idam != null && idam.trim().isNotEmpty) ||
                (lpsVersion != null && lpsVersion.trim().isNotEmpty) ||
                (instance != null && instance.trim().isNotEmpty) ||
                (name != null && name.trim().isNotEmpty);

        if (hasLpsData) {
          builder.element(
            'LPS',
            nest: () {
              if (idam != null && idam.trim().isNotEmpty) {
                builder.element(
                  'IDAM',
                  attributes: {
                    if (idamReference != null &&
                        idamReference.trim().isNotEmpty)
                      'R': idamReference.trim(),
                  },
                  nest: idam.trim(),
                );
              }

              if (lpsVersion != null &&
                  lpsVersion.trim().isNotEmpty) {
                builder.element(
                  'Version',
                  nest: lpsVersion.trim(),
                );
              }

              if (instance != null &&
                  instance.trim().isNotEmpty) {
                builder.element(
                  'Instance',
                  nest: instance.trim(),
                );
              }

              if (name != null && name.trim().isNotEmpty) {
                builder.element(
                  'Nom',
                  nest: name.trim(),
                );
              }
            },
          );
        }
      },
    );

    return builder.buildDocument().rootElement.toXmlString();
  }
}
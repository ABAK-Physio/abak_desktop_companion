/// Observed DV1 affinity-domain label; no change to the approved CDA or NOS.
class Dv1TypeLabel {
  static const profile = 'dv1-11490-type-label-1';
  static const corrected = 'Lettre de sortie';
  static const longLabel =
      "Lettre de liaison à la sortie d'un établissement de soins";
  static const curlyLongLabel =
      'Lettre de liaison à la sortie d’un établissement de soins';
  static const repository =
      'https://lps.dev1.dmp.gouv.fr/si-dmp-server/v2/services/repository';

  static bool applies(Map document, String endpoint) =>
      endpoint == repository &&
      document['typeSystem'] == '2.16.840.1.113883.6.1' &&
      document['typeCode'] == '11490-0' &&
      [longLabel, curlyLongLabel, corrected].contains(document['typeLabel']);
}

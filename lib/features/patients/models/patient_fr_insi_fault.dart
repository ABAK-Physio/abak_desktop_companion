enum PatientFrInsiFaultSeverity {
  error,
  fatal,
}

class PatientFrInsiFault {
  final String codeValue;
  final String subcode;
  final String code;
  final PatientFrInsiFaultSeverity severity;
  final String description;

  const PatientFrInsiFault({
    required this.codeValue,
    required this.subcode,
    required this.code,
    required this.severity,
    required this.description,
  });

  bool get isSender => codeValue == 'Sender';

  bool get isReceiver => codeValue == 'Receiver';

  bool get isFatal => severity == PatientFrInsiFaultSeverity.fatal;
}

PatientFrInsiFaultSeverity patientFrInsiFaultSeverityFromValue(
    String value,
    ) {
  switch (value.trim().toLowerCase()) {
    case 'erreur':
      return PatientFrInsiFaultSeverity.error;
    case 'fatale':
      return PatientFrInsiFaultSeverity.fatal;
    default:
      throw ArgumentError.value(
        value,
        'value',
        'Sévérité INSi non prise en charge',
      );
  }
}
import 'package:xml/xml.dart';

import '../models/patient_fr_insi_fault.dart';
import '../models/patient_fr_insi_result.dart';
import 'patient_fr_insi_fault_parser.dart';
import 'patient_fr_insi_result_parser.dart';

class PatientFrInsiResponse {
  final PatientFrInsiResult? result;
  final PatientFrInsiFault? fault;

  const PatientFrInsiResponse._({
    this.result,
    this.fault,
  });

  const PatientFrInsiResponse.result(
      PatientFrInsiResult result,
      ) : this._(result: result);

  const PatientFrInsiResponse.fault(
      PatientFrInsiFault fault,
      ) : this._(fault: fault);

  bool get isResult => result != null;

  bool get isFault => fault != null;
}

class PatientFrInsiResponseParser {
  final PatientFrInsiResultParser _resultParser;
  final PatientFrInsiFaultParser _faultParser;

  const PatientFrInsiResponseParser({
    this._resultParser =
    const PatientFrInsiResultParser(),
    this._faultParser =
    const PatientFrInsiFaultParser(),
  });

  PatientFrInsiResponse parseXml(String xml) {
    final document = XmlDocument.parse(xml);

    final hasFault = document.descendants
        .whereType<XmlElement>()
        .any((element) => element.name.local == 'Fault');

    if (hasFault) {
      return PatientFrInsiResponse.fault(
        _faultParser.parseXml(xml),
      );
    }

    final hasResult = document.descendants
        .whereType<XmlElement>()
        .any((element) => element.name.local == 'RESULTAT');

    if (hasResult) {
      return PatientFrInsiResponse.result(
        _resultParser.parseXml(xml),
      );
    }

    throw const FormatException(
      'Réponse INSi invalide : ni RESULTAT ni SoapFault',
    );
  }
}
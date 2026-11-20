import 'dart:convert';

import 'package:crypto/crypto.dart';

import '../models/patient_fr_insi_result.dart';
import 'patient_fr_insi_response_parser.dart';

/// Offline CNDA response. Contains no transport or identity update operation.
class PatientInsiCr01Injection {
  PatientInsiCr01Injection._(this.xml, this.result);

  static const fileHash =
      'f7ee47f0e24cfd5971febdf5dc3332bfe334a690566a76d4c1352ae9e6970456';
  final String xml;
  final PatientFrInsiResult result;

  static PatientInsiCr01Injection decode(List<int> bytes) {
    if (bytes.length > 65536 || sha256.convert(bytes).toString() != fileHash) {
      throw StateError('Choisissez REP_CR01.xml original du package CNDA INSi 05.00.00.');
    }
    final xml = utf8.decode(bytes);
    final response = const PatientFrInsiResponseParser().parseXml(xml);
    if (response.isFault || response.result?.isNotFound != true) {
      throw StateError('La réponse injectée ne correspond pas au CR 01 attendu.');
    }
    return PatientInsiCr01Injection._(xml, response.result!);
  }
}

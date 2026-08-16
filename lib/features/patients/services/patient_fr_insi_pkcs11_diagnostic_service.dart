import 'package:flutter/services.dart';

class PatientFrInsiPkcs11DiagnosticService {
  const PatientFrInsiPkcs11DiagnosticService();

  static const MethodChannel _channel =
  MethodChannel('abak_dmp_fr');

  Future<Map<String, dynamic>> diagnose() async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'diagnosePkcs11',
    );

    if (result == null) {
      throw StateError(
        'Diagnostic PKCS#11 absent',
      );
    }

    return result;
  }
}
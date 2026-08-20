import 'package:flutter/services.dart';

class PatientFrInsiPkcs11ObjectService {
  const PatientFrInsiPkcs11ObjectService();

  static const MethodChannel _channel =
  MethodChannel('abak_dmp_fr');

  Future<Map<String, dynamic>> listObjects({
    required String pin,
  }) async {
    final result =
    await _channel.invokeMapMethod<String, dynamic>(
      'listPkcs11Objects',
      {
        'pin': pin,
      },
    );

    if (result == null) {
      throw StateError(
        'Inventaire des objets PKCS#11 absent',
      );
    }

    return result;
  }
}
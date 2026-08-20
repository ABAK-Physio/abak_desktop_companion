import 'package:flutter/services.dart';

class PatientFrInsiPkcs11LoginService {
  const PatientFrInsiPkcs11LoginService();

  static const MethodChannel _channel =
  MethodChannel('abak_dmp_fr');

  Future<Map<String, dynamic>> login({
    required String pin,
  }) async {
    final result = await _channel.invokeMapMethod<String, dynamic>(
      'loginPkcs11User',
      {
        'pin': pin,
      },
    );

    if (result == null) {
      throw StateError(
        'Résultat C_Login absent',
      );
    }

    return result;
  }
}
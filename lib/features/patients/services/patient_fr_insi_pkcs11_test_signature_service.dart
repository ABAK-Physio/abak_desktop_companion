import 'package:flutter/services.dart';

class PatientFrInsiPkcs11TestSignatureService {
  const PatientFrInsiPkcs11TestSignatureService();

  static const MethodChannel _channel =
  MethodChannel('abak_dmp_fr');

  Future<Map<String, dynamic>> sign({
    required String pin,
  }) async {
    final result =
    await _channel.invokeMapMethod<String, dynamic>(
      'signPkcs11TestMessage',
      {
        'pin': pin,
      },
    );

    if (result == null) {
      throw StateError(
        'Résultat de signature CPS absent',
      );
    }

    return result;
  }
}
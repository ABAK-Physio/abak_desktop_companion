import 'package:flutter/services.dart';

class PatientFrInsiPkcs11SigningCertificateService {
  const PatientFrInsiPkcs11SigningCertificateService();

  static const MethodChannel _channel =
  MethodChannel('abak_dmp_fr');

  Future<Map<String, dynamic>> getCertificate({
    required String pin,
  }) async {
    final result =
    await _channel.invokeMapMethod<String, dynamic>(
      'getPkcs11SigningCertificate',
      {
        'pin': pin,
      },
    );

    if (result == null) {
      throw StateError(
        'Certificat CPS de signature absent',
      );
    }

    return result;
  }
}
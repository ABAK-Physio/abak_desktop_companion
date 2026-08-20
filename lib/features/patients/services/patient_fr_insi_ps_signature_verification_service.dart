import 'package:flutter/services.dart';

class PatientFrInsiPsSignatureVerificationService {
  const PatientFrInsiPsSignatureVerificationService();

  static const MethodChannel _channel =
  MethodChannel('abak_dmp_fr');

  Future<Map<String, dynamic>> verify({
    required String canonicalSignedInfo,
    required String signatureBase64,
    required String certificateBase64,
  }) async {
    final result =
    await _channel.invokeMapMethod<String, dynamic>(
      'verifyInsiPsSignature',
      {
        'canonicalSignedInfo': canonicalSignedInfo,
        'signatureBase64': signatureBase64,
        'certificateBase64': certificateBase64,
      },
    );

    if (result == null) {
      throw StateError(
        'Résultat de vérification de signature absent',
      );
    }

    return result;
  }
}
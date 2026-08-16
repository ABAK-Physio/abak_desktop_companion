abstract class PatientFrInsiPsSigner {
  const PatientFrInsiPsSigner();

  Future<String> sign({
    required String canonicalSignedInfo,
  });
}
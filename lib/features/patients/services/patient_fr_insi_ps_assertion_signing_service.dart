import '../models/patient_fr_insi_ps_assertion_data.dart';
import 'patient_fr_insi_ps_assertion_builder.dart';
import 'patient_fr_insi_ps_digest_service.dart';
import 'patient_fr_insi_ps_method_channel_signer.dart';
import 'patient_fr_insi_ps_signature_builder.dart';
import 'patient_fr_insi_ps_signature_inserter.dart';
import 'patient_fr_insi_ps_signed_info_builder.dart';
import 'patient_fr_insi_ps_signed_info_canonicalizer.dart';
import 'patient_fr_insi_ps_signer.dart';

class PatientFrInsiPsAssertionSigningService {
  const PatientFrInsiPsAssertionSigningService({
    this.assertionBuilder = const PatientFrInsiPsAssertionBuilder(),
    this.digestService = const PatientFrInsiPsDigestService(),
    this.signedInfoBuilder = const PatientFrInsiPsSignedInfoBuilder(),
    this.signedInfoCanonicalizer =
    const PatientFrInsiPsSignedInfoCanonicalizer(),
    this.signer = const PatientFrInsiPsMethodChannelSigner(),
    this.signatureBuilder = const PatientFrInsiPsSignatureBuilder(),
    this.signatureInserter = const PatientFrInsiPsSignatureInserter(),
  });

  final PatientFrInsiPsAssertionBuilder assertionBuilder;
  final PatientFrInsiPsDigestService digestService;
  final PatientFrInsiPsSignedInfoBuilder signedInfoBuilder;
  final PatientFrInsiPsSignedInfoCanonicalizer signedInfoCanonicalizer;
  final PatientFrInsiPsSigner signer;
  final PatientFrInsiPsSignatureBuilder signatureBuilder;
  final PatientFrInsiPsSignatureInserter signatureInserter;

  Future<String> buildSignedAssertion({
    required PatientFrInsiPsAssertionData data,
    required String x509Certificate,
  }) async {
    final unsignedAssertionXml = assertionBuilder.buildUnsigned(
      data,
    );

    final digestValue = digestService.computeDigestValue(
      unsignedAssertionXml,
    );

    final signedInfoXml = signedInfoBuilder.build(
      assertionId: data.assertionId,
      digestValue: digestValue,
    );

    final canonicalSignedInfo =
    signedInfoCanonicalizer.canonicalize(
      signedInfoXml,
    );

    final signatureValue = await signer.sign(
      canonicalSignedInfo: canonicalSignedInfo,
    );

    final signatureXml = signatureBuilder.build(
      signedInfoXml: signedInfoXml,
      signatureValue: signatureValue,
      x509Certificate: x509Certificate,
    );

    return signatureInserter.insert(
      assertionXml: unsignedAssertionXml,
      signatureXml: signatureXml,
    );
  }
}
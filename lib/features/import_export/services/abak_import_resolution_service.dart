import '../../patients/data/patient_repository.dart';
import '../abak_package.dart';
import '../data/mobile_case_repository.dart';
import '../models/abak_import_resolution.dart';
import '../models/mobile_case.dart';

class AbakImportResolutionService {
  AbakImportResolutionService({
    PatientRepository? patientRepository,
    MobileCaseRepository? mobileCaseRepository,
  })  : _patientRepository = patientRepository ?? PatientRepository(),
        _mobileCaseRepository =
            mobileCaseRepository ?? MobileCaseRepository();

  final PatientRepository _patientRepository;
  final MobileCaseRepository _mobileCaseRepository;

  Future<AbakImportResolution> resolve(
      AbakPackage package,
      ) async {
    final packagePatientId = package.patient?.localPatientId;
    final mobileCase = await _ensureMobileCase(package);

    if (packagePatientId != null && packagePatientId.isNotEmpty) {
      final patient = await _patientRepository.getPatientById(
        packagePatientId,
      );

      if (patient != null) {
        return AbakImportResolution(
          type: AbakImportResolutionType.automaticByPatientId,
          patient: patient,
          mobileCase: mobileCase,
        );
      }
    }

    if (mobileCase != null) {
      final linkedPatientId =
      await _mobileCaseRepository.getLinkedPatientIdForCase(
        mobileCase.caseId,
      );

      if (linkedPatientId != null) {
        final patient = await _patientRepository.getPatientById(
          linkedPatientId,
        );

        if (patient != null) {
          return AbakImportResolution(
            type: AbakImportResolutionType.automaticByCaseLink,
            patient: patient,
            mobileCase: mobileCase,
          );
        }
      }
    }

    return AbakImportResolution(
      type: AbakImportResolutionType.requiresPatientSelection,
      mobileCase: mobileCase,
    );
  }

  Future<void> linkMobileCaseToPatient({
    required MobileCase? mobileCase,
    required String patientId,
    String? practitionerId,
  }) async {
    if (mobileCase == null) {
      return;
    }

    await _mobileCaseRepository.linkCaseToPatient(
      caseId: mobileCase.caseId,
      patientId: patientId,
      practitionerId: practitionerId,
    );
  }

  Future<MobileCase?> _ensureMobileCase(
      AbakPackage package,
      ) async {
    final mobileSnapshot = package.mobileCase;
    final episodeSnapshot = package.clinicalEpisode;

    final caseId = mobileSnapshot?.caseId ?? episodeSnapshot?.episodeId;

    if (caseId == null || caseId.isEmpty) {
      return null;
    }

    final caseLabel = mobileSnapshot?.caseLabel ??
        episodeSnapshot?.label ??
        episodeSnapshot?.pathologyLabel ??
        'Dossier mobile';

    final pathologyCode =
        mobileSnapshot?.pathologyCode ?? episodeSnapshot?.pathologyCode;

    final now = DateTime.now().millisecondsSinceEpoch;

    final existing = await _mobileCaseRepository.getCaseById(
      caseId,
    );

    final mobileCase = MobileCase(
      caseId: caseId,
      caseLabel: caseLabel,
      pathologyCode: pathologyCode,
      sourceDeviceId: package.sourceDevice?.deviceId,
      createdAt: existing?.createdAt ?? now,
      importedAt: existing?.importedAt ?? now,
      updatedAt: now,
      archivedAt: existing?.archivedAt,
    );

    await _mobileCaseRepository.upsertMobileCase(
      mobileCase,
    );

    return mobileCase;
  }
}
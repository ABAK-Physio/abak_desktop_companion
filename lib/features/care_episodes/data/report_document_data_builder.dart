import 'package:abak_desktop_companion/core/settings/cabinet_identity_service.dart';
import 'package:abak_desktop_companion/features/care_episodes/data/care_episode_referring_practitioner_repository.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/care_episode.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/care_episode_report.dart';
import 'package:abak_desktop_companion/features/external_correspondents/data/external_correspondent_repository.dart';
import 'package:abak_desktop_companion/features/patients/data/patient_repository.dart';
import 'package:abak_desktop_companion/features/practitioners/data/practitioner_repository.dart';

import '../models/report_document_data.dart';

class ReportDocumentDataBuilder {
  final CabinetIdentityService _cabinetIdentityService =
  const CabinetIdentityService();

  final PatientRepository _patientRepository = PatientRepository();

  final PractitionerRepository _practitionerRepository =
  PractitionerRepository();

  final CareEpisodeReferringPractitionerRepository
  _referringPractitionerRepository =
  CareEpisodeReferringPractitionerRepository();

  final ExternalCorrespondentRepository _externalCorrespondentRepository =
  ExternalCorrespondentRepository();

  Future<ReportDocumentData> build({
    required CareEpisodeReport report,
    required CareEpisode episode,
  }) async {
    final patient = await _patientRepository.getPatientById(
      episode.patientId,
    );

    if (patient == null) {
      throw StateError(
        'Patient introuvable pour la prise en charge '
            '${episode.careEpisodeId}.',
      );
    }

    final reportDate = DateTime.fromMillisecondsSinceEpoch(
      report.reportDate,
    );

    final referringAssignment = await _referringPractitionerRepository
        .getCurrentReferringPractitioner(
      episode.careEpisodeId,
    );

    final referringPractitioner = referringAssignment == null
        ? null
        : await _practitionerRepository.getPractitionerById(
      referringAssignment.practitionerId,
    );

    final authorPractitioner = report.authorPractitionerId == null
        ? referringPractitioner
        : await _practitionerRepository.getPractitionerById(
      report.authorPractitionerId!,
    );

    final prescribingCorrespondent =
    episode.prescribingCorrespondentId == null
        ? null
        : await _externalCorrespondentRepository.getById(
      episode.prescribingCorrespondentId!,
    );

    return ReportDocumentData(
      establishmentName: _clean(
        await _cabinetIdentityService.getCabinetName(),
      ),
      reportDate: reportDate,
      printedAt: DateTime.now(),
      authorName: _clean(authorPractitioner?.displayName),
      patientLastName: patient.lastName,
      patientFirstName: patient.firstName,
      patientSex: _sexLabel(patient.sexCode),
      patientAgeYears: _calculateAge(
        patient.birthDate,
        reportDate,
      ),
      pathologyLabel: _clean(episode.pathologyLabel),
      careEpisodeOpenedAt: episode.openedAt == null
          ? null
          : DateTime.fromMillisecondsSinceEpoch(
        episode.openedAt!,
      ),
      referringPractitionerName: _clean(
        referringPractitioner?.displayName,
      ),
      prescribingCorrespondentName: _clean(
        prescribingCorrespondent?.displayName,
      ),
      prescribingCorrespondentProfession: _clean(
        prescribingCorrespondent?.profession,
      ),
      prescribingCorrespondentSpecialty: _clean(
        prescribingCorrespondent?.specialty,
      ),
      prescribingCorrespondentAddressLine1: _clean(
        prescribingCorrespondent?.addressLine1,
      ),
      prescribingCorrespondentAddressLine2: _clean(
        prescribingCorrespondent?.addressLine2,
      ),
      prescribingCorrespondentPostalCode: _clean(
        prescribingCorrespondent?.postalCode,
      ),
      prescribingCorrespondentCity: _clean(
        prescribingCorrespondent?.city,
      ),
      prescribingCorrespondentEmail: _clean(
        prescribingCorrespondent?.email,
      ),
      prescribingCorrespondentPhone: _clean(
        prescribingCorrespondent?.phone,
      ),
      reportTitle: report.title.trim(),
      reportText: report.contentJson.trim(),
    );
  }

  String? _clean(String? value) {
    final cleaned = value?.trim();

    if (cleaned == null || cleaned.isEmpty) {
      return null;
    }

    return cleaned;
  }

  String? _sexLabel(String? sexCode) {
    switch (sexCode?.trim().toUpperCase()) {
      case 'M':
        return 'Masculin';
      case 'F':
        return 'Féminin';
      default:
        return _clean(sexCode);
    }
  }

  int? _calculateAge(
      String? birthDate,
      DateTime referenceDate,
      ) {
    final cleanedBirthDate = _clean(birthDate);

    if (cleanedBirthDate == null) {
      return null;
    }

    final parsedBirthDate = DateTime.tryParse(cleanedBirthDate);

    if (parsedBirthDate == null) {
      return null;
    }

    var age = referenceDate.year - parsedBirthDate.year;

    final birthdayNotReached =
        referenceDate.month < parsedBirthDate.month ||
            (referenceDate.month == parsedBirthDate.month &&
                referenceDate.day < parsedBirthDate.day);

    if (birthdayNotReached) {
      age--;
    }

    return age >= 0 ? age : null;
  }
}
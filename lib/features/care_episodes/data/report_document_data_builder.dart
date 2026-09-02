import 'package:abak_desktop_companion/core/settings/cabinet_identity_service.dart';
import 'package:abak_desktop_companion/features/care_episodes/data/care_episode_referring_practitioner_repository.dart';
import 'package:abak_desktop_companion/features/care_episodes/data/care_episode_report_repository.dart';
import 'package:abak_desktop_companion/features/care_episodes/data/care_episode_repository.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/assessment_document_data.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/care_episode.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/care_episode_report.dart';
import 'package:abak_desktop_companion/features/external_correspondents/data/external_correspondent_repository.dart';
import 'package:abak_desktop_companion/features/patients/data/patient_attribute_repository.dart';
import 'package:abak_desktop_companion/features/patients/data/patient_repository.dart';
import 'package:abak_desktop_companion/features/practitioners/data/practitioner_repository.dart';
import 'package:abak_desktop_companion/features/results/data/desktop_result_repository.dart';
import 'package:abak_desktop_companion/features/results/desktop_result_grouping.dart';
import 'package:abak_desktop_companion/features/results/models/desktop_result.dart';
import 'package:abak_shared/abak_shared.dart';

import '../models/report_document_data.dart';

class ReportDocumentDataBuilder {
  final CabinetIdentityService _cabinetIdentityService =
  const CabinetIdentityService();

  final PatientRepository _patientRepository = PatientRepository();

  final PatientAttributeRepository _patientAttributeRepository =
  PatientAttributeRepository();

  final PractitionerRepository _practitionerRepository =
  PractitionerRepository();

  final CareEpisodeReferringPractitionerRepository
  _referringPractitionerRepository =
  CareEpisodeReferringPractitionerRepository();

  final ExternalCorrespondentRepository _externalCorrespondentRepository =
  ExternalCorrespondentRepository();

  final CareEpisodeReportRepository _reportRepository =
  CareEpisodeReportRepository();

  final DesktopResultRepository _desktopResultRepository =
  DesktopResultRepository();

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

    final attributes = await _patientAttributeRepository.getByPatientId(
      patient.patientId,
    );

    final attributesByKey = <String, String?>{
      for (final attribute in attributes)
        attribute.attributeKey: _clean(attribute.attributeValue),
    };

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

    final selectedNoteIds = await _reportRepository.getSelectedNoteIds(
      report.reportId,
    );

    final episodeNotes = await CareEpisodeRepository().getNotesForEpisode(
      episode.careEpisodeId,
    );

    final selectedNotes = episodeNotes
        .where((note) => selectedNoteIds.contains(note.noteId))
        .map(
          (note) => AssessmentDocumentNote(
        noteDate: DateTime.fromMillisecondsSinceEpoch(
          note.noteDate,
        ),
        title: note.title.trim(),
        content: note.content.trim(),
      ),
    )
        .toList();

    final selectedTestKeys =
    await _reportRepository.getSelectedTestExoIds(
      report.reportId,
    );

    final episodeResults =
    await _desktopResultRepository.getResultsForCareEpisode(
      episode.careEpisodeId,
    );

    final latestSelectedResults = <String, DesktopResult>{};

    for (final result in episodeResults) {
      final selectionKey = desktopResultSelectionKey(result);

      if (!selectedTestKeys.contains(selectionKey)) {
        continue;
      }

      latestSelectedResults.putIfAbsent(
        selectionKey,
            () => result,
      );
    }

    final selectedTests = latestSelectedResults.entries
        .map(
          (entry) {
        final result = entry.value;

        return AssessmentDocumentTest(
          selectionKey: entry.key,
          chartSeries: _buildChartSeries(
            selectionKey: entry.key,
            episodeResults: episodeResults,
          ),
          title: desktopResultDisplayLabel(result),
          testDate: DateTime.fromMillisecondsSinceEpoch(
            result.createdAt,
          ),
          resultText: _cleanResultText(result.exportSimpleText),
          declaredAgeYears: result.ageYears,
          pathologyLabel: _clean(
            result.mobilePathologyLabel,
          ),
        );
      },
    )
        .toList()
      ..sort(
            (a, b) => a.title.compareTo(b.title),
      );

    return ReportDocumentData(
      establishmentName: _clean(
        await _cabinetIdentityService.getCabinetName(),
      ),
      establishmentAddressLine1: _clean(
        await _cabinetIdentityService.getCabinetAddressLine1(),
      ),
      establishmentAddressLine2: _clean(
        await _cabinetIdentityService.getCabinetAddressLine2(),
      ),
      establishmentPostalCode: _clean(
        await _cabinetIdentityService.getCabinetPostalCode(),
      ),
      establishmentCity: _clean(
        await _cabinetIdentityService.getCabinetCity(),
      ),
      establishmentPhone: _clean(
        await _cabinetIdentityService.getCabinetPhone(),
      ),
      establishmentEmail: _clean(
        await _cabinetIdentityService.getCabinetEmail(),
      ),
      establishmentLogoPath: _clean(
        await _cabinetIdentityService.getCabinetLogoPath(),
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
      dominantSide: attributesByKey['dominant_side'],
      profession: attributesByKey['profession'],
      sport: attributesByKey['sport'],
      heightCm: attributesByKey['height_cm'],
      weightKg: attributesByKey['weight_kg'],
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
      tests: selectedTests,
      notes: selectedNotes,
    );
  }

  List<AssessmentDocumentChartSeries> _buildChartSeries({
    required String selectionKey,
    required List<DesktopResult> episodeResults,
  }) {
    final matchingResults = episodeResults
        .where(
          (result) =>
      desktopResultSelectionKey(result) == selectionKey,
    )
        .toList()
      ..sort(
            (a, b) => a.createdAt.compareTo(b.createdAt),
      );

    if (matchingResults.length < 2) {
      return const [];
    }

    final definition = ClinicalActivityCatalog.infoFor(
      matchingResults.first.exoId,
    );

    final chartMetrics = definition.metrics
        .where((metric) => metric.showOnEvolutionChart)
        .toList();

    final series = <AssessmentDocumentChartSeries>[];

    for (final metric in chartMetrics) {
      final points = <AssessmentDocumentChartPoint>[];

      for (final result in matchingResults) {
        final value = readDesktopResultMetricValueWithFallbacks(
          result,
          metric,
        );

        if (value == null) {
          continue;
        }

        points.add(
          AssessmentDocumentChartPoint(
            date: DateTime.fromMillisecondsSinceEpoch(
              result.createdAt,
            ),
            value: value,
          ),
        );
      }

      if (points.length < 2) {
        continue;
      }

      series.add(
        AssessmentDocumentChartSeries(
          label: metric.fallbackLabel,
          unit: _clean(metric.defaultUnit),
          points: points,
        ),
      );
    }

    return series;
  }

  String _cleanResultText(String value) {
    final lines = value.split('\n');

    final contentLines = lines.length > 2
        ? lines.skip(2)
        : <String>[];

    return contentLines
        .where(
          (line) => !line.trimLeft().startsWith('Date :'),
    )
        .join('\n')
        .trim();
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
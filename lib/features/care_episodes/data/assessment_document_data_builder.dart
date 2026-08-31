import 'package:abak_desktop_companion/core/settings/cabinet_identity_service.dart';
import 'package:abak_desktop_companion/features/care_episodes/data/care_episode_referring_practitioner_repository.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/assessment_document_data.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/care_episode.dart';
import 'package:abak_desktop_companion/features/care_episodes/models/care_episode_assessment.dart';
import 'package:abak_desktop_companion/features/patients/data/patient_attribute_repository.dart';
import 'package:abak_desktop_companion/features/patients/data/patient_repository.dart';
import 'package:abak_desktop_companion/features/practitioners/data/practitioner_repository.dart';
import 'package:abak_desktop_companion/features/care_episodes/data/care_episode_assessment_repository.dart';
import 'care_episode_repository.dart';
import 'package:abak_desktop_companion/features/results/data/desktop_result_repository.dart';
import 'package:abak_desktop_companion/features/results/desktop_result_grouping.dart';
import 'package:abak_shared/abak_shared.dart';
import 'package:abak_desktop_companion/features/results/models/desktop_result.dart';

class AssessmentDocumentDataBuilder {
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

  final CareEpisodeAssessmentRepository _assessmentRepository =
  CareEpisodeAssessmentRepository();

  final DesktopResultRepository _desktopResultRepository =
  DesktopResultRepository();

  Future<AssessmentDocumentData> build({
    required CareEpisodeAssessment assessment,
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

    final assessmentDate = DateTime.fromMillisecondsSinceEpoch(
      assessment.assessmentDate,
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

    final authorPractitioner = assessment.authorPractitionerId == null
        ? referringPractitioner
        : await _practitionerRepository.getPractitionerById(
      assessment.authorPractitionerId!,
    );

    final selectedNoteIds = await _assessmentRepository.getSelectedNoteIds(
      assessment.assessmentId,
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
    await _assessmentRepository.getSelectedTestExoIds(
      assessment.assessmentId,
    );

    final episodeResults =
    await _desktopResultRepository.getResultsForCareEpisode(
      episode.careEpisodeId,
    );

    final latestSelectedResults = <String, dynamic>{};

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

    return AssessmentDocumentData(
      establishmentName: _clean(
        await _cabinetIdentityService.getCabinetName(),
      ),
      assessmentDate: assessmentDate,
      printedAt: DateTime.now(),
      authorName: _clean(authorPractitioner?.displayName),
      recipientText: _clean(assessment.recipientText),
      patientLastName: patient.lastName,
      patientFirstName: patient.firstName,
      patientSex: _sexLabel(patient.sexCode),
      patientAgeYears: _calculateAge(
        patient.birthDate,
        assessmentDate,
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
      assessmentText: assessment.contentJson.trim(),
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

  String? _sexLabel(String sexCode) {
    switch (sexCode.trim().toUpperCase()) {
      case 'M':
        return 'Masculin';
      case 'F':
        return 'Féminin';
      default:
        return null;
    }
  }

  int? _calculateAge(
      String? birthDateText,
      DateTime referenceDate,
      ) {
    final cleaned = birthDateText?.trim();

    if (cleaned == null || cleaned.isEmpty) {
      return null;
    }

    try {
      final birthDate = DateTime.parse(cleaned);

      var age = referenceDate.year - birthDate.year;

      final birthdayNotReached =
          referenceDate.month < birthDate.month ||
              (referenceDate.month == birthDate.month &&
                  referenceDate.day < birthDate.day);

      if (birthdayNotReached) {
        age--;
      }

      return age >= 0 ? age : null;
    } catch (_) {
      return null;
    }
  }
}
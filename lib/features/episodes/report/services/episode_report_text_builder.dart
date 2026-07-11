import '../models/episode_report_section.dart';
import '../models/episode_report_text_document.dart';
import '../models/episode_report_view_model.dart';

class EpisodeReportTextBuilder {
  const EpisodeReportTextBuilder();

  EpisodeReportTextDocument build(EpisodeReportViewModel report) {
    final exportFileName = _buildExportFileName(report);

    return EpisodeReportTextDocument(
      title: 'Rapport clinique – ${report.patientDisplayName}',
      exportFileName: exportFileName,
      sections: [
        EpisodeReportSection(
          title: 'Patient',
          lines: [
            'Nom : ${report.patientDisplayName}',
            if (report.birthDate != null)
              'Date de naissance : ${report.birthDate}',
            if (report.sex != null) 'Sexe : ${report.sex}',
          ],
        ),
        EpisodeReportSection(
          title: 'Épisode',
          lines: [if (report.episodeTitle != null) report.episodeTitle!],
        ),
        EpisodeReportSection(
          title: 'Profil patient',
          lines: report.patientProfileFields
              .where((field) => !field.isEmpty)
              .map((field) => '${field.label} : ${field.value}')
              .toList(),
        ),
        EpisodeReportSection(
          title: 'Formulaires',
          lines: [
            for (final form in report.formSections) ...[
              form.title,
              for (final field in form.fields)
                if (!field.isEmpty) '${field.label} : ${field.value}',
              '',
            ],
          ],
        ),
        EpisodeReportSection(
          title: 'Résultats ABAK',
          lines: [
            for (final result in report.resultSections) ...[
              result.title,
              if (result.summary?.trim().isNotEmpty == true)
                result.summary!.trim(),
              for (final detail in result.details)
                if (detail.trim().isNotEmpty) detail.trim(),
              '',
            ],
          ],
        ),
        EpisodeReportSection(
          title: 'Documents associés',
          lines: [
            for (final document in report.documents)
              if (!document.isEmpty)
                document.mimeType?.trim().isNotEmpty == true
                    ? '${document.title} · ${document.mimeType!.trim()}'
                    : document.title,
          ],
        ),
        EpisodeReportSection(
          title: 'Notes du praticien',
          lines: [
            for (final note in report.notes) ...[
              if (!note.isEmpty) note.title,
              if (note.content.trim().isNotEmpty) note.content.trim(),
              '',
            ],
          ],
        ),
        EpisodeReportSection(
          title: 'Conclusion clinique',
          lines: [
            if (report.clinicalConclusion?.trim().isNotEmpty == true)
              report.clinicalConclusion!.trim()
            else
              'Aucune conclusion clinique renseignée.',
          ],
        ),
      ],
    );
  }

  String _buildExportFileName(EpisodeReportViewModel report) {
    final name = report.patientDisplayName.trim().replaceAll(
      RegExp(r'\s+'),
      '_',
    );

    final date = DateTime.now();

    final yyyy = date.year.toString();
    final mm = date.month.toString().padLeft(2, '0');
    final dd = date.day.toString().padLeft(2, '0');

    return 'Rapport_${name}_$yyyy-$mm-$dd';
  }
}

import '../data/patient_repository.dart';
import '../models/patient.dart';
import 'patient_archive_settings_service.dart';

class PatientPurgeResult {
  final int scannedPatients;
  final int deletedPatients;

  const PatientPurgeResult({
    required this.scannedPatients,
    required this.deletedPatients,
  });
}

class PatientPurgeService {
  final PatientRepository _repository = PatientRepository();
  final PatientArchiveSettingsService _settingsService =
  PatientArchiveSettingsService();

  Future<PatientPurgeResult> purgeArchivedPatients() async {
    final archivedPatients = await _repository.getArchivedPatients();
    final selectedRetentionDays = await _settingsService.getRetentionDays();

    final now = DateTime.now();

    int deleted = 0;

    for (final patient in archivedPatients) {
      final archivedAt = patient.archivedAt;

      if (archivedAt == null) continue;

      final archivedDate = DateTime.fromMillisecondsSinceEpoch(archivedAt);
      final difference = now.difference(archivedDate).inDays;

      if (difference >= selectedRetentionDays) {
        await _deletePatientPermanently(patient);
        deleted++;
      }
    }

    return PatientPurgeResult(
      scannedPatients: archivedPatients.length,
      deletedPatients: deleted,
    );
  }

  Future<void> _deletePatientPermanently(Patient patient) async {
    await _repository.deletePatientPermanently(patient.patientId);
  }

  Future<PatientPurgePreview> previewArchivedPatientsPurge() async {
    final archivedPatients = await _repository.getArchivedPatients();
    final selectedRetentionDays = await _settingsService.getRetentionDays();

    final now = DateTime.now();

    int purgeable = 0;

    for (final patient in archivedPatients) {
      final archivedAt = patient.archivedAt;

      if (archivedAt == null) continue;

      final archivedDate = DateTime.fromMillisecondsSinceEpoch(archivedAt);
      final difference = now.difference(archivedDate).inDays;

      if (difference >= selectedRetentionDays) {
        purgeable++;
      }
    }

    return PatientPurgePreview(
      archivedPatients: archivedPatients.length,
      purgeablePatients: purgeable,
      retentionDays: selectedRetentionDays,
    );
  }
}

class PatientPurgePreview {
  final int archivedPatients;
  final int purgeablePatients;
  final int retentionDays;

  const PatientPurgePreview({
    required this.archivedPatients,
    required this.purgeablePatients,
    required this.retentionDays,
  });

  bool get hasPurgeablePatients => purgeablePatients > 0;
}
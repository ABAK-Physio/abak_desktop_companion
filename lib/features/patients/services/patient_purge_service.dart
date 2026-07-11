import '../data/patient_repository.dart';
import '../models/patient.dart';

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

  /// Durée avant suppression définitive
  /// des patients archivés.
  static const int retentionDays = 30;

  Future<PatientPurgeResult> purgeArchivedPatients() async {
    final archivedPatients = await _repository.getArchivedPatients();

    final now = DateTime.now();

    int deleted = 0;

    for (final patient in archivedPatients) {
      final archivedAt = patient.archivedAt;

      if (archivedAt == null) continue;

      final archivedDate = DateTime.fromMillisecondsSinceEpoch(archivedAt);

      final difference = now.difference(archivedDate).inDays;

      if (difference >= retentionDays) {
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

    final now = DateTime.now();

    int purgeable = 0;

    for (final patient in archivedPatients) {
      final archivedAt = patient.archivedAt;

      if (archivedAt == null) continue;

      final archivedDate = DateTime.fromMillisecondsSinceEpoch(archivedAt);

      final difference = now.difference(archivedDate).inDays;

      if (difference >= retentionDays) {
        purgeable++;
      }
    }

    return PatientPurgePreview(
      archivedPatients: archivedPatients.length,
      purgeablePatients: purgeable,
      retentionDays: retentionDays,
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

import '../patients/models/patient.dart';

enum KobusDecision { create, attach, skip, unresolved }

enum KobusStatus { pending, imported, rejected, skipped, failed, interrupted }

class KobusIdentity {
  KobusIdentity(
    this.lastName,
    this.firstName,
    this.birthDate, {
    this.sex = 'U',
    this.nir,
    this.profession,
    this.warnings = const [],
  });
  final String lastName, firstName, sex;
  final String? birthDate;
  final String? nir, profession;
  final List<String> warnings;
  String get label =>
      '$lastName $firstName • ${birthDate ?? "Date de naissance non renseignée"}';
  Patient patient(String id) => Patient(
    patientId: id,
    lastName: lastName,
    firstName: firstName,
    birthDate: birthDate,
    sexCode: sex,
    nir: nir,
    createdAt: DateTime.now().millisecondsSinceEpoch,
  );
}

class KobusCandidate {
  KobusCandidate(
    this.patient,
    this.reason, {
    this.sourceItemId,
    this.sourcePath,
  });
  final Patient patient;
  final String reason;
  final String? sourceItemId, sourcePath;
  String get key => sourceItemId ?? patient.patientId;
}

class KobusFolder {
  KobusFolder({
    required this.id,
    required this.sourcePath,
    required this.shared,
    required this.directory,
    this.practitioner,
    this.identity,
    this.readableIdentity = '',
    required this.manifest,
  });
  final String id, sourcePath, directory;
  final bool shared;
  final String? practitioner;
  final Map<String, String> manifest;
  KobusIdentity? identity;
  String? _rejection;
  String? duplicateReason;
  String? get rejection => _rejection ?? duplicateReason;
  set rejection(String? value) => _rejection = value;
  String readableIdentity;
  final List<KobusCandidate> candidates = [];
  KobusDecision decision = KobusDecision.create;
  KobusCandidate? target;
  String get label => identity?.label ?? readableIdentity;
}

class KobusPreparation {
  KobusPreparation(this.zipName, this.temporaryPath, this.folders);
  final String zipName, temporaryPath;
  final List<KobusFolder> folders;
  bool get hasShared => folders.any((f) => f.shared);
}

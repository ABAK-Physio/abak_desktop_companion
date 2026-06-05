import '../../patients/models/patient.dart';
import 'mobile_case.dart';

enum AbakImportResolutionType {
  automaticByPatientId,
  automaticByCaseLink,
  requiresPatientSelection,
}

class AbakImportResolution {
  final AbakImportResolutionType type;
  final Patient? patient;
  final MobileCase? mobileCase;

  const AbakImportResolution({
    required this.type,
    this.patient,
    this.mobileCase,
  });

  bool get canImportAutomatically {
    return type == AbakImportResolutionType.automaticByPatientId ||
        type == AbakImportResolutionType.automaticByCaseLink;
  }

  String get displayLabel {
    switch (type) {
      case AbakImportResolutionType.automaticByPatientId:
        return 'Import automatique : patient reconnu';
      case AbakImportResolutionType.automaticByCaseLink:
        return 'Import automatique : dossier mobile déjà lié';
      case AbakImportResolutionType.requiresPatientSelection:
        return 'Rattachement manuel requis';
    }
  }
}
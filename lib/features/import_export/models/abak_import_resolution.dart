enum AbakImportResolutionType {
  requiresManualAssignment,
}

class AbakImportResolution {
  final AbakImportResolutionType type;

  const AbakImportResolution({
    required this.type,
  });

  bool get requiresManualAssignment {
    return type == AbakImportResolutionType.requiresManualAssignment;
  }

  String get displayLabel {
    return 'Rattachement manuel requis';
  }
}
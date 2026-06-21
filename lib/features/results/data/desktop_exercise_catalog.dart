class DesktopExerciseCatalog {
  const DesktopExerciseCatalog();

  String labelForExoId(String exoId) {
    switch (exoId) {
      case 'E1':
        return '3MBWT';
      default:
        return exoId;
    }
  }
}
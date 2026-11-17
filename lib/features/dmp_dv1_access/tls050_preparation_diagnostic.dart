import 'dart:io';

/// A bounded diagnostic without exception messages, inputs, paths or XML.
/// The caller supplies a fixed application stage, never user-entered text.
String tls050PreparationDiagnostic(
  Object error,
  StackTrace stack,
  String stage,
) {
  final category = error is FileSystemException
      ? 'accès à un fichier local'
      : error is FormatException
      ? 'format de données locales'
      : error is TypeError || error is NoSuchMethodError
      ? 'données ou état interne inattendus'
      : 'erreur interne';
  final type = error.runtimeType.toString();
  final safeType = RegExp(r'^[A-Za-z_][A-Za-z0-9_]{0,63}$').hasMatch(type)
      ? type
      : 'Object';
  final os = error is FileSystemException ? error.osError?.errorCode : null;
  // Retain only a source URI and line/column from this application package.
  // Do not copy the exception payload or the full stack into the UI or proof.
  final location = RegExp(
    r'\((package:abak_desktop_companion/[A-Za-z0-9_./-]+\.dart:\d+(?::\d+)?)\)',
  ).firstMatch(stack.toString())?.group(1);
  return 'Préparation impossible — étape : $stage. '
      'Diagnostic : $category ($safeType)'
      '${os == null ? '' : ', code système $os'}. '
      '${location == null ? '' : 'Repère : $location. '}'
      'Aucune relance automatique. Consultez les fichiers de la série avant tout nouvel essai.';
}

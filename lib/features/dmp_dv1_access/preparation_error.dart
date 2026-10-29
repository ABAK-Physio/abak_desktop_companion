import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../patients/services/dmp_chain/contracts.dart';

/// Never interpolate an exception payload: it may contain a path, XML or input.
String dv1PreparationError(Object error, String stage) {
  if (error is StateError) return error.message.toString();
  if (error is DmpChainBlock) return error.message;
  final category = error is FileSystemException
      ? 'accès à un fichier local'
      : error is FormatException
      ? 'format de données locales'
      : error is PlatformException
      ? 'service macOS'
      : error is FlutterError
      ? 'ressource ou interface Companion'
      : error is TypeError || error is NoSuchMethodError
      ? 'données ou état interne inattendus'
      : 'erreur interne';
  return 'Préparation impossible — étape : $stage. Diagnostic : $category (${error.runtimeType}). '
      'Aucune relance automatique. Transmettez ce message à l’assistance.';
}

import 'dart:convert';
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';

class ResultHashUtils {
  static String computeHash({
    required String resultId,
    required String exoId,
    required String exportSimpleText,
    required int createdAt,
    double? scoreTotal,
  }) {
    final canonical = jsonEncode({
      'result_id': resultId,
      'exoId': exoId,
      'createdAt': createdAt,
      'scoreTotal': scoreTotal,
      'exportSimpleText': exportSimpleText,
    });

    return sha256.convert(utf8.encode(canonical)).toString();
  }
}

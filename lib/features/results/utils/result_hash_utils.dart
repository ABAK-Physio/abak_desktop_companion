import 'dart:convert';
import '../models/result_walking_aid.dart';
// ignore: depend_on_referenced_packages
import 'package:crypto/crypto.dart';

class ResultHashUtils {
  static String computeHash({
    required String resultId,
    required String exoId,
    required String exportSimpleText,
    required int createdAt,
    double? scoreTotal,
    Object? structuredJson,
  }) {
    final walkingAid = ResultWalkingAid.fromStructuredJson(structuredJson);
    final canonical = jsonEncode({
      'result_id': resultId,
      'exoId': exoId,
      'createdAt': createdAt,
      'scoreTotal': scoreTotal,
      'exportSimpleText': exportSimpleText,
      if (walkingAid != null) 'walkingAid': walkingAid.toJson(),
    });

    return sha256.convert(utf8.encode(canonical)).toString();
  }
}

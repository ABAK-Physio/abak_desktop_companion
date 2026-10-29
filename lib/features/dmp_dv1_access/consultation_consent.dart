import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import '../dmp_td02/td02_result.dart';
import '../patients/services/document_medical_service.dart';

enum AuthorizationChange { none, add, remove }

/// SEL-MP-037 2.10: EX_0.3-1010, 1030, 1040. No emergency override.
AuthorizationChange authorizationChange(
  Td02Result state, {
  required bool granted,
  required bool consultationRequested,
}) {
  if (state.state != DmpState.active ||
      [
        ConsultationRight.unknown,
        ConsultationRight.blocked,
      ].contains(state.right)) {
    throw StateError(
      'Autorisation DMP non modifiable dans cet état. Aucune consultation.',
    );
  }
  if (!granted) {
    return state.right == ConsultationRight.valid
        ? AuthorizationChange.remove
        : AuthorizationChange.none;
  }
  if (!consultationRequested || state.right == ConsultationRight.valid) {
    return AuthorizationChange.none;
  }
  return AuthorizationChange.add;
}

/// Append-only DV1 decisions, separate from real patient identity and qualification.
class ConsultationConsentStore {
  ConsultationConsentStore(this.root);
  final Directory root;
  String key(String professional, String ins) => medicalHash({
    'environment': 'DV1',
    'professional': professional,
    'ins': ins,
  });

  Future<Map<String, dynamic>?> latest(String professional, String ins) async {
    final directory = Directory(p.join(root.path, key(professional, ins)));
    if (!await directory.exists()) return null;
    Map<String, dynamic>? last;
    await for (final file in directory.list(followLinks: false)) {
      if (file is! File) continue;
      // An interrupted write is deliberately not ignored.
      final envelope = jsonDecode(await file.readAsString());
      final value = Map<String, dynamic>.from(envelope['record']);
      if (medicalHash(value) != envelope['sha256'] ||
          value['professional'] != professional ||
          value['ins'] != ins ||
          value['environment'] != 'DV1') {
        throw StateError(
          'Historique des accords illisible. Consultation suspendue.',
        );
      }
      if (last == null ||
          (value['sequence'] as int) > (last['sequence'] as int)) {
        last = value;
      }
    }
    return last;
  }

  Future<Map<String, dynamic>> save(
    String professional,
    String ins, {
    required String patient,
    required String source,
    required bool granted,
    required bool pendingWithdrawal,
    required DateTime now,
    String? evidenceId,
  }) async {
    final previous = await latest(professional, ins);
    if (granted && previous?['pendingWithdrawal'] == true) {
      throw StateError(
        'Retrait précédent non confirmé. Terminez le retrait avant un nouvel accord.',
      );
    }
    final value = <String, dynamic>{
      'environment': 'DV1',
      'professional': professional,
      'ins': ins,
      'patient': patient,
      'source': source,
      'granted': granted,
      'pendingWithdrawal': pendingWithdrawal,
      'recordedAt': now.toUtc().toIso8601String(),
      'sequence': ((previous?['sequence'] as int?) ?? 0) + 1,
      'evidenceId': evidenceId,
    };
    final directory = Directory(p.join(root.path, key(professional, ins)));
    await directory.create(recursive: true);
    final file = File(p.join(directory.path, '${const Uuid().v4()}.pending'));
    await file.writeAsString(
      jsonEncode({'record': value, 'sha256': medicalHash(value)}),
      flush: true,
    );
    await file.rename(file.path.replaceAll('.pending', '.json'));
    return value;
  }
}

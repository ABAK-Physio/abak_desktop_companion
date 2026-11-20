/// Ordered WS_INS2 attempts; transport/signing and evidence stay with the caller.
class PatientInsiGivenNamesSearch {
  static List<String> plan(List<String> firstNames) {
    final names = firstNames.map((name) => name.trim()).toList();
    if (names.isEmpty || names.any((name) => name.isEmpty)) {
      throw ArgumentError('Saisissez au moins un prénom, un prénom par ligne.');
    }
    return List.unmodifiable([
      ...names,
      if (names.length > 1) names.join(' '),
    ]);
  }

  static Future<T> run<T>({
    required List<String> firstNames,
    required Future<T> Function(String firstName) attempt,
    required bool Function(T result) isSuccess,
  }) async {
    final attempts = plan(firstNames);
    for (var index = 0; index < attempts.length; index++) {
      // An exception (SOAP, timeout, CPS or archive failure) aborts the process.
      // Only an actual negative search result permits the next given name.
      final result = await attempt(attempts[index]);
      if (isSuccess(result) || index == attempts.length - 1) {
        return result;
      }
    }
    throw StateError('Aucun prénom à rechercher.');
  }
}

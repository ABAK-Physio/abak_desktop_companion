import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/preparation_error.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/native/bridge.dart';

void main() {
  test('known business failure retains actionable message', () {
    expect(
      dv1PreparationError(StateError('Configuration à vérifier'), 'local'),
      'Configuration à vérifier',
    );
    expect(
      dv1PreparationError(DmpNativeFailure('CONFIGURATION'), 'local'),
      DmpNativeFailure.messageFor('CONFIGURATION'),
    );
  });
  test(
    'diagnostic identifies stage without exception payload or file path',
    () {
      for (final e in [
        const FormatException('SECRET'),
        const FileSystemException('SECRET', '/private/SECRET'),
        PlatformException(code: 'SECRET', message: 'SECRET'),
        FlutterError('SECRET'),
      ]) {
        final message = dv1PreparationError(e, 'dates et critères');
        expect(message, contains('dates et critères'));
        expect(message, isNot(contains('SECRET')));
        expect(message, isNot(contains('/private/')));
      }
    },
  );
}

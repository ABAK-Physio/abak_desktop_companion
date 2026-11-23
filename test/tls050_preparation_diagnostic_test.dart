import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:abak_desktop_companion/features/dmp_dv1_access/tls050_preparation_diagnostic.dart';

void main() {
  test('file failure shows the stage and OS code without the payload', () {
    final result = tls050PreparationDiagnostic(
      const FileSystemException(
        'private input 654321',
        r'C:\private\654321.xml',
        OSError('private operating-system message', 5),
      ),
      StackTrace.empty,
      'préparation des fichiers du moteur',
    );
    expect(result, contains('préparation des fichiers du moteur'));
    expect(result, contains('FileSystemException'));
    expect(result, contains('code système 5'));
    expect(result, isNot(contains('654321')));
    expect(result, isNot(contains('private')));
  });

  test('format failure never repeats the data that failed parsing', () {
    final result = tls050PreparationDiagnostic(
      const FormatException('secret message', '<xml>654321</xml>'),
      StackTrace.empty,
      'lecture et contrôle des fichiers de la série',
    );
    expect(result, contains('FormatException'));
    expect(result, isNot(contains('secret')));
    expect(result, isNot(contains('654321')));
    expect(result, isNot(contains('<xml>')));
  });

  test('only the application source location is kept from the stack', () {
    final result = tls050PreparationDiagnostic(
      Exception('private payload'),
      StackTrace.fromString(
        '#0 worker (file:///private/654321.dart:5:1)\n'
        '#1 Tls050Service.execute '
        '(package:abak_desktop_companion/features/dmp_dv1_access/tls050_service.dart:221:7)\n'
        '#2 other (package:other/private.dart:5:1)',
      ),
      'ouverture du dialogue de confirmation',
    );
    expect(result, contains('tls050_service.dart:221:7'));
    expect(result, isNot(contains('654321')));
    expect(result, isNot(contains('private')));
    expect(result, isNot(contains('package:other')));
  });

  test('missing source locations do not produce a fabricated frame', () {
    final result = tls050PreparationDiagnostic(
      Exception(),
      StackTrace.empty,
      'contexte de recette',
    );
    expect(result, contains('contexte de recette'));
    expect(result, isNot(contains('Repère')));
    expect(result, contains('Aucune relance automatique'));
  });
}

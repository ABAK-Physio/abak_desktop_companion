import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:abak_desktop_companion/features/dmp_dv1_access/preparation_error.dart';
import 'package:abak_desktop_companion/features/patients/services/dmp_chain/contracts.dart';

void main() {
  const stage = 'vérification des preuves de signature CPS';

  test('format errors identify the preparation step without the payload', () {
    final message = dv1PreparationError(
      const FormatException('PRIVATE_DATA_CANARY'),
      stage,
    );
    expect(message, contains(stage));
    expect(message, contains('format de données locales'));
    expect(message, contains('FormatException'));
    expect(message, isNot(contains('PRIVATE_DATA_CANARY')));
  });

  test('file errors identify the step without disclosing a file path', () {
    final message = dv1PreparationError(
      const FileSystemException(
        'PRIVATE_DATA_CANARY',
        r'C:\PRIVATE_DATA_CANARY\document.xml',
      ),
      'préparation du PDF et du CDA',
    );
    expect(message, contains('préparation du PDF et du CDA'));
    expect(message, contains('accès à un fichier local'));
    expect(message, isNot(contains('PRIVATE_DATA_CANARY')));
  });

  test(
    'platform diagnostics apply to Windows and disclose no native payload',
    () {
      final message = dv1PreparationError(
        PlatformException(
          code: 'PRIVATE_DATA_CANARY',
          message: 'PRIVATE_DATA_CANARY',
        ),
        'vérification de la configuration DV1 et des fichiers CPS',
      );
      expect(message, contains('service de plateforme'));
      expect(message, isNot(contains('macOS')));
      expect(message, isNot(contains('PRIVATE_DATA_CANARY')));
    },
  );

  test('known business blocks keep their actionable explanation', () {
    expect(
      dv1PreparationError(
        const DmpChainBlock('Contrôles locaux requis.'),
        stage,
      ),
      'Contrôles locaux requis.',
    );
    expect(
      dv1PreparationError(StateError('Configuration à actualiser.'), stage),
      'Configuration à actualiser.',
    );
  });

  test('unexpected UI failures identify the step without exception text', () {
    final message = dv1PreparationError(
      FlutterError('PRIVATE_DATA_CANARY'),
      stage,
    );
    expect(message, contains(stage));
    expect(message, contains('ressource ou interface Companion'));
    expect(message, isNot(contains('PRIVATE_DATA_CANARY')));
  });
}

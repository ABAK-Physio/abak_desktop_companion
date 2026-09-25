import 'dart:io';

import 'package:abak_desktop_companion/core/database/database_service.dart';
import 'package:abak_desktop_companion/core/settings/cabinet_identity_service.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _TestPathProvider extends PathProviderPlatform {
  _TestPathProvider(this.directory);
  final String directory;

  @override
  Future<String?> getApplicationSupportPath() async => directory;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late Directory temporaryDirectory;
  late PathProviderPlatform previousProvider;
  const service = CabinetIdentityService();

  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'abak_logo_test_',
    );
    previousProvider = PathProviderPlatform.instance;
    PathProviderPlatform.instance = _TestPathProvider(
      '${temporaryDirectory.path}/support',
    );
  });

  tearDown(() async {
    await DatabaseService.closeDatabase();
    PathProviderPlatform.instance = previousProvider;
    await temporaryDirectory.delete(recursive: true);
  });

  test('logo survives loss of source and reopening the database', () async {
    final source = File('${temporaryDirectory.path}/selected.png');
    await source.writeAsBytes([1, 2, 3]);
    final savedPath = await service.setCabinetLogoPath(source.path);
    expect(savedPath, startsWith('${temporaryDirectory.path}/support/'));
    await source.delete();
    await DatabaseService.closeDatabase();

    final restoredPath = await const CabinetIdentityService()
        .getCabinetLogoPath();
    expect(restoredPath, savedPath);
    expect(await File(restoredPath!).readAsBytes(), [1, 2, 3]);
  });

  test(
    'replacement uses a new path and failed import preserves the logo',
    () async {
      final source = File('${temporaryDirectory.path}/selected.png');
      await source.writeAsBytes([1]);
      final firstPath = await service.setCabinetLogoPath(source.path);
      await source.writeAsBytes([2]);
      final secondPath = await service.setCabinetLogoPath(source.path);
      expect(secondPath, isNot(firstPath));
      expect(await File(secondPath).readAsBytes(), [2]);

      await expectLater(
        service.setCabinetLogoPath('${temporaryDirectory.path}/missing.png'),
        throwsA(isA<FileSystemException>()),
      );
      expect(await service.getCabinetLogoPath(), secondPath);
      expect(await File(secondPath).readAsBytes(), [2]);
      expect(await source.readAsBytes(), [2]);
    },
  );

  test('removing the logo persists without deleting the original', () async {
    final source = File('${temporaryDirectory.path}/selected.png');
    await source.writeAsBytes([1]);
    await service.setCabinetLogoPath(source.path);
    await service.clearCabinetLogoPath();
    await DatabaseService.closeDatabase();
    expect(await service.getCabinetLogoPath(), isNull);
    expect(await source.readAsBytes(), [1]);
  });
}

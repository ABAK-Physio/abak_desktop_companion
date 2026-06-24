import '../abak_package.dart';
import '../models/abak_import_resolution.dart';

class AbakImportResolutionService {
  Future<AbakImportResolution> resolve(AbakPackage package) async {
    return const AbakImportResolution(
      type: AbakImportResolutionType.requiresManualAssignment,
    );
  }
}
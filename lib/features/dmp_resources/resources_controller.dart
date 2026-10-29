import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'dmp_resources.dart';

class SimulatedResourceTransport implements ResourceTransport {
  String scenario = 'normal';
  int calls = 0;
  @override
  Future<ResourceReply> get(Uri uri, String? etag) async {
    calls++;
    if (scenario == 'unavailable') return const ResourceReply(503);
    if (scenario == 'invalid') {
      return const ResourceReply(200, body: '<invalid>');
    }
    final changed = scenario == 'changed';
    return ResourceReply(
      200,
      body:
          '''<dmp-parameters version="1.0"><parameter-list code="param-si-dmp">
<parameter code="fonctions-gestion-mineurs" value="true"/>
<parameter code="cumul-invisible_patient-masque_ps" value="${changed ? 'true' : 'false'}"/>
<parameter code="age-majorite" value="${changed ? 21 : 18}"/>
<parameter code="hr-periode-max-mois" value="24"/>
</parameter-list></dmp-parameters>''',
    );
  }
}

/// Lifecycle-owned scheduler. No global or background singleton.
class ResourcesController extends ChangeNotifier {
  ResourcesController(
    this.resources, {
    this.interval = const Duration(minutes: 1),
    this.advanceClock,
  });
  final DmpResources resources;
  final Duration interval;
  final VoidCallback? advanceClock;
  Timer? _timer;
  bool busy = false, _disposed = false;
  String? catalogueMessage;
  String parametersMessage = 'Paramètres non encore vérifiés.';
  void start() {
    if (_disposed || _timer != null) return;
    parametersMessage = resources.message;
    if (!resources.due) {
      parametersMessage =
          "Configuration valide restaurée depuis le stockage simulé.";
    }
    unawaited(check());
    _timer = Timer.periodic(interval, (_) => unawaited(check()));
  }

  Future<void> check({bool force = false}) async {
    if (_disposed || busy || (!force && !resources.due)) return;
    busy = true;
    notifyListeners();
    try {
      await resources.refresh();
      parametersMessage = resources.message;
    } finally {
      busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  Future<void> advanceWeek() async {
    if (busy || _disposed) return;
    advanceClock?.call();
    await check();
  }

  void installExampleCatalog({bool invalid = false}) {
    if (_disposed || busy) return;
    final body = invalid
        ? '{'
        : jsonEncode({
            'version': 'SIMULATION-2',
            'entries': [
              {
                'system': 'urn:abak:simulation',
                'code': 'TEST_A',
                'label': 'Valeur fictive actualisée',
                'active': true,
              },
            ],
          });
    resources.installCatalog(
      body,
      ticket: resources.beginCatalogUpdate(),
      expectedHash: DmpResources.digest(body),
      provenance: 'Simulation locale — aucun référentiel officiel',
    );
    catalogueMessage = resources.message;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    resources.cancelPendingRefresh();
    super.dispose();
  }
}

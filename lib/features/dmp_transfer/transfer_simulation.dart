import 'simulated_lot_store.dart';
import 'package:flutter/foundation.dart';

enum TlsFailure {
  trust,
  hostname,
  expired,
  future,
  revoked,
  staleCrl,
  identity,
  timeout,
  unavailable,
  unknown;

  String get message => switch (this) {
    trust => 'Certificat serveur non validé.',
    hostname => 'Le certificat ne correspond pas au serveur attendu.',
    expired => 'Certificat expiré.',
    future => 'Certificat non encore valide.',
    revoked => 'Certificat révoqué.',
    staleCrl => 'Liste de révocation périmée.',
    identity => 'Le certificat ne correspond pas au professionnel attendu.',
    timeout => 'Délai de connexion sécurisée dépassé.',
    unavailable => 'Connexion DMP indisponible.',
    unknown => 'Connexion sécurisée impossible : cause non déterminée.',
  };
}

enum DepositOutcome {
  accepted,
  signatureRejected,
  metadataRejected,
  rejected,
  indeterminate,
}

enum TransferPhase {
  ready,
  connecting,
  sending,
  tlsFailed,
  accepted,
  rejected,
  indeterminate,
}

/// Contract deliberately limited to local simulations: no real transport or CPS.
abstract interface class TransferSimulationService {
  Future<TlsFailure?> connect();
  Future<DepositOutcome> deposit();
}

abstract interface class TransferDiagnosticSource {
  String get detail;
}

class FixtureTransferService implements TransferSimulationService {
  FixtureTransferService({
    this.failure,
    this.outcome = DepositOutcome.accepted,
  });
  final TlsFailure? failure;
  final DepositOutcome outcome;
  @override
  Future<TlsFailure?> connect() async => failure;
  @override
  Future<DepositOutcome> deposit() async => outcome;
}

class TransferSimulation extends ChangeNotifier {
  TransferSimulation(
    this.service, {
    this.store,
    this.lotId = 'simulation-default',
  }) {
    if (store != null) {
      try {
        final saved = store!.read(lotId);
        if (saved == 'tlsFailed') {
          phase = TransferPhase.tlsFailed;
          message =
              'Échec TLS conservé. Aucune tentative de dépôt enregistrée pour ce lot simulé.';
        } else if (saved != null) {
          detail = store!.readDetail(lotId);
          _apply(DepositOutcome.values.byName(saved));
          message = 'État conservé après réouverture. $message';
        }
      } catch (_) {
        _storageError();
      }
    }
  }
  final SimulatedLotStore? store;
  final String lotId;
  final TransferSimulationService service;
  String detail = '';
  bool get isReplay => lotId.startsWith('simulation-archive-');
  TransferPhase phase = TransferPhase.ready;
  String message = 'Choisissez un scénario, puis lancez la simulation.';
  bool _disposed = false;
  bool get busy =>
      phase == TransferPhase.connecting || phase == TransferPhase.sending;
  bool get canStart => phase == TransferPhase.ready;
  bool get canPrepareCorrection => phase == TransferPhase.rejected;
  bool get canCheckResult => phase == TransferPhase.indeterminate;
  // A simulation result must never grant permission to send a real request.
  bool get canSendNetworkRequest => false;

  void _update(TransferPhase value, String text) {
    if (_disposed) return;
    phase = value;
    message = text;
    notifyListeners();
  }

  Future<void> start() async {
    if (!canStart || _disposed) return;
    _update(
      TransferPhase.connecting,
      isReplay
          ? 'Ouverture de la relecture locale…'
          : 'Vérification de la connexion sécurisée simulée…',
    );
    TlsFailure? failure;
    try {
      failure = await service.connect();
    } catch (_) {
      failure = TlsFailure.unknown;
    }
    if (_disposed) return;
    if (failure != null) {
      try {
        store?.tlsFailed(lotId);
      } catch (_) {
        _storageError();
        return;
      }
      _update(
        TransferPhase.tlsFailed,
        '${failure.message} Aucune requête DMP envoyée. Corrigez la connexion avant une nouvelle tentative.',
      );
      return;
    }
    try {
      if (store != null && !store!.begin(lotId)) {
        _update(
          TransferPhase.indeterminate,
          'Une tentative existe déjà pour ce lot simulé. Renvoi bloqué ; vérifiez son résultat.',
        );
        return;
      }
    } catch (_) {
      _storageError();
      return;
    }
    _update(
      TransferPhase.sending,
      isReplay ? 'Lecture de la réponse archivée…' : 'Dépôt simulé en cours…',
    );
    DepositOutcome result;
    try {
      result = await service.deposit();
    } catch (_) {
      result = DepositOutcome.indeterminate;
    }
    if (service is TransferDiagnosticSource) {
      detail = (service as TransferDiagnosticSource).detail;
    }
    // Save even if the screen closed while the response was pending.
    try {
      store?.finish(lotId, result.name, detail: detail);
    } catch (_) {
      _storageError();
      return;
    }
    if (_disposed) return;
    _apply(result);
  }

  void _storageError() {
    _update(
      TransferPhase.indeterminate,
      'État durable indisponible ou illisible. Toute tentative est bloquée ; vérifiez les traces avant de poursuivre.',
    );
  }

  void _apply(DepositOutcome result) {
    switch (result) {
      case DepositOutcome.accepted:
        _update(
          TransferPhase.accepted,
          isReplay
              ? 'Dépôt historique accepté selon cette archive. Aucun nouveau dépôt effectué ; ce résultat ne décrit pas le statut actuel du document.'
              : 'Dépôt accepté (simulation). Conservez la preuve. Ne renvoyez pas ce lot.',
        );
      case DepositOutcome.signatureRejected:
        _update(
          TransferPhase.rejected,
          'Document refusé : signature du lot non conforme. Code : DMPInvalidSignature. Préparez un nouveau lot corrigé avant signature.',
        );
      case DepositOutcome.metadataRejected:
        _update(
          TransferPhase.rejected,
          'Document refusé : métadonnées non conformes. Code : XDSRegistryMetadataError. Vérifiez authorSpecialty pour le lot et le document, puis préparez un nouveau lot corrigé.',
        );
      case DepositOutcome.rejected:
        _update(
          TransferPhase.rejected,
          'Document refusé : erreur XDS. Consultez les détails avant de préparer une correction.',
        );
      case DepositOutcome.indeterminate:
        _update(
          TransferPhase.indeterminate,
          'Résultat du dépôt indéterminé. Le document a peut-être été reçu. Vérification nécessaire avant toute reprise ; ne renvoyez pas ce lot.',
        );
    }
  }

  String? prepareCorrection() => canPrepareCorrection
      ? 'Simulation : nouveau lot à préparer et à signer. Le lot refusé reste bloqué ; aucun document créé.'
      : null;
  String? checkResult() => canCheckResult
      ? 'Simulation : consulter les traces et vérifier le document avant toute reprise. Aucun contrôle DV1 effectué ; résultat toujours indéterminé.'
      : null;
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

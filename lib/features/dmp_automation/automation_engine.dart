import 'dart:async';
import '../dmp_minors/minors_simulation.dart';
import '../dmp_resources/dmp_resources.dart';
import '../dmp_td02/td02_result.dart';
import 'automation_model.dart';
import 'automation_store.dart';

/// A closed, in-memory fake: no network/CPS implementation or URL is accepted.
final class AutoFakeService {
  AutoFakeService({
    this.tlsOk = true,
    this.outcome = 'accepted',
    this.connectionGate,
    this.resultGate,
    this.delay = Duration.zero,
  });
  final bool tlsOk;
  final String outcome;
  final Future<void>? connectionGate, resultGate;
  final Duration delay;
  int connections = 0;
  final sent = <AutoDocument>[];
  Future<bool> connect() async {
    connections++;
    if (connectionGate != null) await connectionGate;
    if (delay != Duration.zero) await Future<void>.delayed(delay);
    return tlsOk;
  }

  Future<String> deposit(AutoDocument doc) async {
    sent.add(doc);
    if (resultGate != null) await resultGate;
    if (delay != Duration.zero) await Future<void>.delayed(delay);
    return ['accepted', 'rejected', 'indeterminate'].contains(outcome)
        ? outcome
        : 'indeterminate';
  }
}

class AutoEngine {
  AutoEngine(
    this.store,
    this.service, {
    this._context = const AutoContext(),
    DateTime Function()? now,
  }) : now = now ?? (() => DateTime.utc(2026, 10, 16)) {
    refresh();
  }
  final AutoStore store;
  final AutoFakeService service;
  final DateTime Function() now;
  AutoContext _context;
  AutoContext get context => _context;
  int _contextRevision = 0;
  bool _closed = false, busy = false, reserved = false;
  void Function()? onChanged;
  AutoDecision status = decision('attente_validation');
  AutoRecord? record;
  void publish(AutoDecision value) {
    status = value;
    if (!_closed) onChanged?.call();
  }

  void refresh() {
    try {
      record = store.read();
      publish(evaluate(record!));
    } catch (_) {
      record = null;
      publish(decision('stockage_bloque'));
    }
  }

  void setContext(AutoContext value) {
    _context = value;
    _contextRevision++;
    refresh();
  }

  void updateDocument(AutoDocument value) {
    try {
      store.change((r) {
        r.document = value;
        r.validated = null;
      });
      refresh();
    } catch (_) {
      publish(decision('stockage_bloque'));
    }
  }

  void updateRule(AutoRule value) {
    try {
      store.change((r) => r.rule = value);
      refresh();
    } catch (_) {
      publish(decision('stockage_bloque'));
    }
  }

  void hold(bool value) {
    try {
      if (store.claim.existsSync()) {
        refresh();
        if (reserved) publish(decision('tentative_en_cours'));
        return;
      }
      store.change((r) => r.held = value);
      refresh();
    } catch (_) {
      publish(decision('stockage_bloque'));
    }
  }

  void validateOnly() {
    try {
      store.change((r) => r.validated = r.document.version);
      refresh();
    } catch (_) {
      publish(decision('stockage_bloque'));
    }
  }

  Future<void> validateAndRun() async {
    validateOnly();
    if (status.state != 'stockage_bloque') await process();
  }

  Future<void> releaseAndRun() async {
    hold(false);
    await process();
  }

  AutoDecision evaluate(AutoRecord r) {
    if (reserved) return decision('tentative_en_cours');
    if (r.outcome != null &&
        !(r.outcome == 'accepted' &&
            r.history != null &&
            r.document.version != r.history!.version)) {
      return decision(switch (r.outcome) {
        'accepted' => 'deja_accepte',
        'rejected' => 'rejete',
        'tlsFailed' => 'tls_echec',
        _ => 'a_verifier',
      });
    }
    if (r.held) return decision('retenu');
    if (r.validated != r.document.version) {
      return decision('attente_validation');
    }
    if (!r.rule.enabled || r.rule.type != r.document.type) {
      return decision('hors_regle');
    }
    if (r.document.empty) return decision('vide');
    final c = _context, d = r.document;
    if (c.patient != d.patient ||
        c.professional != d.professional ||
        c.structure != d.structure) {
      return decision('contexte_perime');
    }
    if (c.identity != SimIdentity.qualified) {
      return decision('identite_bloquee');
    }
    if (c.dmp != DmpState.active || c.right == ConsultationRight.unknown) {
      return decision('dmp_bloque');
    }
    if (!c.functionalRights || !c.authorRights) {
      return decision('droits_bloques');
    }
    if (!c.metadataValid ||
        d.title.trim().isEmpty ||
        d.type.trim().isEmpty ||
        DateTime.tryParse(d.clinicalDate) == null) {
      return decision('metadonnees_bloquees');
    }
    final minor = MinorSession(
      MinorContext.fromParameters(
        today: now(),
        patient: c.patient,
        professional: c.professional,
        parameters: DmpParameters(
          r.rule.minors,
          r.rule.majority,
          r.rule.cumulative,
          [],
        ),
      ),
    );
    if (!minor.context.valid) return decision('contexte_incomplet');
    if (minor.context.secretAvailable && c.secret == null) {
      return decision('contexte_incomplet');
    }
    if (c.secret != null) {
      try {
        minor.choose(c.secret!);
      } catch (_) {
        return decision('contexte_incomplet');
      }
    }
    final prior = r.history;
    if (prior != null &&
        (prior.patient != d.patient ||
            prior.structure != d.structure ||
            prior.professional != d.professional)) {
      return decision('contexte_perime');
    }
    try {
      minor.prepare(
        id: 'SIM-AUTO',
        rlVisible: d.rlVisible,
        patientVisible: d.patientVisible,
        maskedPs: d.maskedPs,
        replacing: prior == null
            ? null
            : SimDocument(
                id: 'SIM-AUTO',
                patient: prior.patient,
                rlVisible: prior.rlVisible,
                patientVisible: prior.patientVisible,
                maskedPs: prior.maskedPs,
              ),
        // Medical validation is bound to the exact visibility version. The UI
        // confirms visibility changes before validation of that version.
        confirmedVisibilityChange: true,
      );
    } catch (_) {
      return decision('confidentialite_bloquee');
    }
    if (prior != null) {
      if (prior.version == d.version) return decision('inchange');
      return decision(
        prior.sameClinicalContent(d)
            ? 'modification_a_preparer'
            : 'remplacement_a_preparer',
      );
    }
    final td = Td02Result(c.dmp, right: c.right);
    if (!td.allows(
      DmpAction.deposit,
      opposition: c.opposition,
      functionalRights: c.functionalRights,
      authorRights: c.authorRights,
      consultationConsent: false,
    )) {
      return decision('opposition');
    }
    return decision('pret');
  }

  Future<void> process() async {
    if (_closed || busy) return;
    busy = true;
    try {
      final before = store.read();
      final initial = evaluate(before);
      publish(initial);
      if (!initial.ready) return;
      final contextRevision = _contextRevision,
          ruleVersion = digest(before.rule.toJson());
      final date = now();
      final day = '${date.year}-${date.month}-${date.day}';
      final tlsOk = await service.connect();
      if (_closed) return;
      final current = store.read();
      record = current;
      final currentDate = now();
      if (contextRevision != _contextRevision ||
          day !=
              '${currentDate.year}-${currentDate.month}-${currentDate.day}') {
        publish(decision('contexte_perime'));
        return;
      }
      if (current.document.version != before.document.version ||
          current.validated != before.validated) {
        publish(decision('attente_validation'));
        return;
      }
      if (digest(current.rule.toJson()) != ruleVersion) {
        publish(decision('reevaluation'));
        return;
      }
      final checked = evaluate(current);
      publish(checked);
      if (!checked.ready) return;
      if (!tlsOk) {
        store.change((r) => r.outcome = 'tlsFailed');
        record = store.read();
        publish(decision('tls_echec'));
        return;
      }
      if (!store.reserve()) {
        refresh();
        return;
      }
      reserved = true;
      publish(decision('tentative_en_cours'));
      // Immutable snapshot, never the mutable editor state after the await.
      String result;
      try {
        result = await service.deposit(before.document);
      } catch (_) {
        result = 'indeterminate';
      }
      store.finish(result, before.document);
      reserved = false;
      record = store.read();
      publish(
        decision(switch (result) {
          'accepted' => 'accepte_simule',
          'rejected' => 'rejete',
          _ => 'a_verifier',
        }),
      );
    } catch (_) {
      reserved = false;
      publish(decision('stockage_bloque'));
    } finally {
      busy = false;
      if (!_closed) onChanged?.call();
    }
  }

  void close() {
    _closed = true;
    onChanged = null;
  }
}

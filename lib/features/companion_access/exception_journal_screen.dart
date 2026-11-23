import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'companion_access_service.dart';
import 'companion_session.dart';
import 'patient_access_service.dart';
import 'administrative_access_service.dart';

class ExceptionJournalScreen extends StatefulWidget {
  const ExceptionJournalScreen({super.key, this.service, this.session});
  final CompanionAccessService? service;
  final CompanionSession? session;
  @override
  State<ExceptionJournalScreen> createState() => _ExceptionJournalState();
}

class _ExceptionJournalState extends State<ExceptionJournalScreen> {
  late final service = widget.service ?? CompanionAccessService();
  late final session = widget.session ?? CompanionSession.current;
  final code = TextEditingController();
  List<AccessPractitioner> administrators = [];
  List<Map<String, Object?>>? rows;
  String? selected, error;
  bool loading = true, busy = false;
  int revision = 0;

  @override
  void initState() {
    super.initState();
    session.addListener(invalidate);
    CompanionAccessService.administratorChanges.addListener(invalidate);
    CompanionAccessService.recoveryCompleted.addListener(invalidate);
    loadAdministrators();
  }

  void invalidate() {
    revision++;
    code.clear();
    setState(() {
      rows = null;
      busy = false;
      error = null;
      loading = true;
    });
    loadAdministrators();
  }

  Future<void> loadAdministrators() async {
    final ticket = revision;
    try {
      final people = (await service.practitioners())
          .where((p) => p.isAdministrator)
          .toList();
      if (!mounted || ticket != revision) return;
      setState(() {
        administrators = people;
        selected = people.any((p) => p.id == session.practitionerId)
            ? session.practitionerId
            : people.length == 1
            ? people.single.id
            : null;
        loading = false;
      });
    } catch (e) {
      if (mounted && ticket == revision) {
        setState(() {
          error = '$e';
          loading = false;
        });
      }
    }
  }

  Future<void> consult() async {
    if (selected == null) return;
    final ticket = revision;
    final entered = code.text;
    code.clear();
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final result = await service.readExceptionJournal(
        administratorId: selected!,
        code: entered,
      );
      if (mounted && ticket == revision) setState(() => rows = result);
    } catch (e) {
      if (mounted && ticket == revision) setState(() => error = '$e');
    } finally {
      if (mounted && ticket == revision) setState(() => busy = false);
    }
  }

  String reason(Map<String, Object?> row) {
    if (row['action'] == 'patient_exception_granted') {
      for (final value in PatientAccessReason.values) {
        if (value.name == row['reason']) return value.label;
      }
    } else {
      for (final value in AdministrativeAccessReason.values) {
        if (value.name == row['reason']) return value.label;
      }
    }
    return row['reason'] as String? ?? 'Motif non renseigné';
  }

  String date(Object? stamp) {
    final d = DateTime.fromMillisecondsSinceEpoch(stamp as int);
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(d.day)}/${two(d.month)}/${d.year} à ${two(d.hour)}:${two(d.minute)}:${two(d.second)}';
  }

  @override
  void dispose() {
    session.removeListener(invalidate);
    CompanionAccessService.administratorChanges.removeListener(invalidate);
    CompanionAccessService.recoveryCompleted.removeListener(invalidate);
    code.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Journal des accès dérogatoires')),
    body: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1000),
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Autorisations dérogatoires accordées au cours des douze derniers mois, de la plus récente à la plus ancienne. '
                      'Les réouvertures d’un dossier pendant une même dérogation ne sont pas enregistrées ici.',
                    ),
                  ),
                  if (rows == null)
                    Expanded(
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          if (administrators.isEmpty)
                            const Text(
                              'Aucun administrateur disponible. Enregistrez ou récupérez un administrateur avant de consulter ce journal.',
                            )
                          else ...[
                            const Text(
                              'Saisissez le code Companion d’un administrateur. Un accès dérogatoire à Assistance ne suffit pas pour consulter ce journal.',
                            ),
                            const SizedBox(height: 16),
                            DropdownButtonFormField<String>(
                              initialValue: selected,
                              key: ValueKey('$revision:$selected'),
                              decoration: const InputDecoration(
                                labelText: 'Administrateur',
                              ),
                              items: administrators
                                  .map(
                                    (p) => DropdownMenuItem(
                                      value: p.id,
                                      child: Text(p.name),
                                    ),
                                  )
                                  .toList(),
                              onChanged: busy
                                  ? null
                                  : (id) => setState(() {
                                      selected = id;
                                      code.clear();
                                    }),
                            ),
                            TextField(
                              controller: code,
                              obscureText: true,
                              enabled: !busy,
                              decoration: const InputDecoration(
                                labelText: 'Code Companion',
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                              ],
                              onSubmitted: (_) {
                                if (!busy) consult();
                              },
                            ),
                            const SizedBox(height: 16),
                            FilledButton(
                              onPressed: busy || selected == null
                                  ? null
                                  : consult,
                              child: Text(
                                busy ? 'Vérification…' : 'Consulter le journal',
                              ),
                            ),
                          ],
                          if (error != null)
                            Text(
                              error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                        ],
                      ),
                    )
                  else ...[
                    Text('${rows!.length} autorisation(s) — lecture seule'),
                    if (rows!.isEmpty)
                      const Expanded(
                        child: Center(
                          child: Text(
                            'Aucun accès dérogatoire enregistré sur cette période.',
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.builder(
                          itemCount: rows!.length,
                          itemBuilder: (context, index) {
                            final row = rows![index];
                            final patient =
                                row['action'] == 'patient_exception_granted';
                            final name = row['patient_last_name'] == null
                                ? 'Patient indisponible (${row['patient_id'] ?? 'identifiant absent'})'
                                : '${row['patient_last_name']} ${row['patient_first_name'] ?? ''}';
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${date(row['occurred_at'])} — ${row['actor_name'] ?? row['actor_practitioner_id'] ?? 'Kiné inconnu'}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                    Text(
                                      patient
                                          ? 'Dossier patient : $name'
                                          : 'Paramètres et Assistance',
                                    ),
                                    if (patient)
                                      Text(
                                        'Référent lors de la dérogation : ${row['referrer_name'] ?? row['previous_practitioner_id'] ?? 'Non affecté'}',
                                      ),
                                    Text('Motif : ${reason(row)}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ],
              ),
      ),
    ),
  );
}

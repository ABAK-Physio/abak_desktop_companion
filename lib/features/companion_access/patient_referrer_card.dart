import 'package:flutter/material.dart';
import 'companion_access_service.dart';
import 'patient_access_boundary.dart';
import 'patient_access_service.dart';
import 'patient_referrer_picker.dart';

class PatientReferrerCard extends StatefulWidget {
  const PatientReferrerCard({super.key, required this.patientId});
  final String patientId;
  @override
  State<PatientReferrerCard> createState() => _PatientReferrerCardState();
}

class _PatientReferrerCardState extends State<PatientReferrerCard> {
  PatientAccessService? service;
  Future<PatientAccessState>? state;
  bool busy = false;
  String? error;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final next = PatientAccessBoundary.serviceOf(context);
    if (service == next) return;
    service?.removeListener(refresh);
    service = next..addListener(refresh);
    state = next.inspect(widget.patientId);
  }

  void refresh() {
    if (mounted) setState(() => state = service!.inspect(widget.patientId));
  }

  @override
  void dispose() {
    service?.removeListener(refresh);
    super.dispose();
  }

  Future<void> change() async {
    final id = await choosePatientReferrer(context);
    if (id == null || !mounted) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await service!.changeReferrer(
        patientId: widget.patientId,
        newReferrerId: id,
      );
    } catch (e) {
      if (mounted) {
        setState(
          () => error = e is CompanionAccessException
              ? e.message
              : 'Impossible de modifier le référent.',
        );
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: FutureBuilder<PatientAccessState>(
        future: state,
        builder: (context, snapshot) {
          final value = snapshot.data;
          final editable =
              value?.referrerId != null &&
              (value!.decision == PatientAccessDecision.referrer ||
                  value.decision == PatientAccessDecision.unrestricted);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kiné référent',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                snapshot.hasError
                    ? 'Information indisponible'
                    : value == null
                    ? 'Chargement…'
                    : value.referrerName ?? 'Non affecté',
              ),
              if (error != null) Text(error!),
              if (editable)
                TextButton(
                  onPressed: busy ? null : change,
                  child: const Text('Changer de référent'),
                ),
            ],
          );
        },
      ),
    ),
  );
}

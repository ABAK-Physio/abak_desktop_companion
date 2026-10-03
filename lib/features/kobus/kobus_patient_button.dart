import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../generated/l10n.dart';
import 'kobus_import_service.dart';

class KobusPatientButton extends StatefulWidget {
  const KobusPatientButton({super.key, required this.patientId});
  final String patientId;
  @override
  State<KobusPatientButton> createState() => _KobusPatientButtonState();
}

class _KobusPatientButtonState extends State<KobusPatientButton> {
  final _service = KobusImportService();
  late Future<List<Map<String, Object?>>> _archives;
  @override
  void initState() {
    super.initState();
    _archives = _service.archives(widget.patientId);
  }

  @override
  void didUpdateWidget(covariant KobusPatientButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.patientId != widget.patientId) {
      _archives = _service.archives(widget.patientId);
    }
  }

  Future<void> _open() async {
    try {
      final path = await _service.patientDirectory(widget.patientId);
      if (!await launchUrl(Uri.directory(path))) {
        throw StateError(S.current.kobus_unavailable);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${S.of(context).kobus_unavailable}\n$e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder(
    future: _archives,
    builder: (context, snapshot) {
      if (snapshot.hasError) return Text(S.of(context).kobus_unavailable);
      if (snapshot.data?.isNotEmpty != true) return const SizedBox.shrink();
      return OutlinedButton.icon(
        onPressed: _open,
        icon: const Icon(Icons.folder_open),
        label: Text(S.of(context).kobus_consult),
      );
    },
  );
}

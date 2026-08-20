import 'package:flutter/material.dart';
import '../../../core/utils/date_format_utils.dart';
import 'package:abak_vitale/abak_vitale.dart';
import '../../../generated/l10n.dart';
import '../widgets/vitale_beneficiary_selector.dart';

class VitaleIdentityScreen extends StatefulWidget {
  const VitaleIdentityScreen({super.key});

  @override
  State<VitaleIdentityScreen> createState() =>
      _VitaleIdentityScreenState();
}

class _VitaleIdentityScreenState extends State<VitaleIdentityScreen> {
  final VitaleIdentityService _service = VitaleIdentityService();

  bool _loading = false;
  VitaleIdentity? _identity;
  Map<String, dynamic>? _diagnostic;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _readIdentity();
    });
  }

  Future<void> _readIdentity() async {
    setState(() {
      _loading = true;
      _identity = null;
      _diagnostic = null;
    });

    final s = S.of(context);
    final identities = await _service.readVitaleIdentities();

    if (!mounted) return;

    VitaleIdentity? identity;

    if (identities.length == 1) {
      identity = identities.first;
    } else if (identities.length > 1) {
      identity = await VitaleBeneficiarySelector.show(
        context,
        identities,
      );
    }

    if (!mounted) return;

    setState(() {
      _loading = false;
      _identity = identity;
      _diagnostic = identities.isEmpty
          ? {
        'success': false,
        'message': s.vitaleIdentity_noIdentityAvailable,
        'beneficiaryCount': 0,
      }
          : {
        'success': true,
        'beneficiaryCount': identities.length,
      };
    });
  }

  String _formatBirthDate(
      BuildContext context,
      DateTime? birthDate,
      ) {
    if (birthDate == null) {
      return '';
    }

    return DateFormatUtils.formatDate(
      context,
      birthDate,
    );
  }

  String _sexLabel(String? sexCode, S s) {
    switch (sexCode?.trim().toUpperCase()) {
      case 'F':
        return s.vitaleIdentity_female;
      case 'M':
        return s.vitaleIdentity_male;
      case 'X':
        return s.vitaleIdentity_other;
      default:
        return s.vitaleIdentity_notProvided;
    }
  }

  bool _hasNir(VitaleIdentity identity) {
    return identity.nir?.trim().isNotEmpty == true;
  }

  String _formatDiagnostic(Map<String, dynamic> diagnostic) {
    final s=S.of(context);
    final lines = <String>[];

    for (final entry in diagnostic.entries) {
      if (entry.key == 'identity') {
        final identityRaw = entry.value;

        if (identityRaw is Map) {
          lines.add(
            s.vitaleIdentity_identityReceivedMasked,
          );
        } else {
          lines.add(s.vitaleIdentity_identityUnavailable);
        }

        continue;
      }

      if (entry.key.toLowerCase().contains('nir')) {
        lines.add('${entry.key} : ${s.vitaleIdentity_dataMasked}');
        continue;
      }

      lines.add('${entry.key} : ${entry.value}');
    }

    return lines.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    final s=S.of(context);
    final diagnostic = _diagnostic;
    final identity = _identity;

    return Scaffold(
      appBar: AppBar(
        title: Text(s.vitaleIdentity_title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.icon(
              onPressed: _loading ? null : _readIdentity,
              icon: const Icon(Icons.badge_outlined),
              label: Text(
                _loading
                    ? s.vitaleIdentity_reading
                    : s.vitaleIdentity_title,
              ),
            ),

            const SizedBox(height: 16),

            if (_loading)
              const Center(
                child: CircularProgressIndicator(),
              ),

            if (!_loading && identity != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.vitaleIdentity_identityRead,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        '${s.vitaleIdentity_lastName} ${identity.lastName ?? ''}',
                      ),
                      Text(
                        '${s.vitaleIdentity_firstName} ${identity.firstName ?? ''}',
                      ),
                      Text(
                        '${s.vitaleIdentity_birthDate} '
                            '${_formatBirthDate(context, identity.birthDate)}',
                      ),
                      Text(
                        '${s.vitaleIdentity_sex} ${_sexLabel(identity.sexCode, s)}',
                      ),
                      Text(
                        '${s.vitaleIdentity_nir}'
                            '${_hasNir(identity) ? s.vitaleIdentity_detected : s.vitaleIdentity_unavailable}',
                      ),
                      Text(
                        '${s.vitaleIdentity_source} ${identity.source}',
                      ),

                      const SizedBox(height: 16),

                      FilledButton.icon(
                        onPressed: identity.hasUsableIdentity
                            ? () {
                          Navigator.of(context).pop(identity);
                        }
                            : null,
                        icon: const Icon(
                          Icons.person_add_alt_1_outlined,
                        ),
                        label: Text(
                          s.vitaleIdentity_useForPatientCreation,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            if (!_loading &&
                diagnostic != null &&
                identity == null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    diagnostic['error']?.toString() ??
                        diagnostic['message']?.toString() ??
                        s.vitaleIdentity_noIdentityAvailable,
                  ),
                ),
              ),

            const SizedBox(height: 16),

            if (diagnostic != null)
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SingleChildScrollView(
                      child: Text(
                        _formatDiagnostic(diagnostic),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
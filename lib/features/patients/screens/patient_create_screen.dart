// Gestion du flux métier patient - épisode
import 'package:abak_vitale/abak_vitale.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/utils/date_format_utils.dart';
import '../../../generated/l10n.dart';
import '../data/patient_repository.dart';
import '../models/patient.dart';
import '../../smart_card/widgets/vitale_beneficiary_selector.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/services.dart';

import '../../../core/expert/expert_context_info.dart';
import '../../../core/expert/expert_info_button.dart';
import '../../../core/settings/application_settings_service.dart';

class PatientCreateScreen extends StatefulWidget {
  const PatientCreateScreen({super.key});

  @override
  State<PatientCreateScreen> createState() => _PatientCreateScreenState();
}

class _PatientCreateScreenState extends State<PatientCreateScreen> {

  ExpertContextInfo _expertInfo(S s) {
    return ExpertContextInfo(
      contextName: s.patientNew_contextName,
      sourceFile: 'lib/features/patients/screens/patient_create_screen.dart',
      arbPrefix: 'patientNew',
      comment: s.patientNew_contextComment,
    );
  }

  final PatientRepository _patientRepository = PatientRepository();
  final VitaleIdentityService _vitaleIdentityService =
  VitaleIdentityService();

  final ApiLecService _apiLecService = ApiLecService();


  final _formKey = GlobalKey<FormState>();

  final _lastNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _birthDateController = TextEditingController();
  String? _nir;
  String _sexCode = 'U';
  bool _saving = false;
  bool _loadingVitale = false;
  bool _identityReadFromVitale = false;
  DateTime? _vitaleReadAt;

  final ApplicationSettingsService _applicationSettingsService =
      const ApplicationSettingsService();

  bool _expertModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadExpertMode();
  }

  Future<void> _loadExpertMode() async {
    final expertModeEnabled =
    await _applicationSettingsService.isExpertModeEnabled();

    if (!mounted) return;

    setState(() {
      _expertModeEnabled = expertModeEnabled;
    });
  }

  @override
  void dispose() {
    _lastNameController.dispose();
    _firstNameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  DateFormat _birthDateDisplayFormat(BuildContext context) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMd(locale);
  }

  String _toIsoDate(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> _selectBirthDate() async {
    if (_saving) return;

    final now = DateTime.now();

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 30),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (selectedDate == null || !mounted) return;

    _birthDateController.text = _birthDateDisplayFormat(
      context,
    ).format(selectedDate);
  }

  String? _birthDateToIsoOrNull() {
    final text = _birthDateController.text.trim();
    if (text.isEmpty) return null;

    final parsedDate = _birthDateDisplayFormat(context).parseStrict(text);
    return _toIsoDate(parsedDate);
  }

  Future<Patient?> _selectMatchingPatient(
      List<Patient> patients,
      ) async {
    final s = S.of(context);

    if (patients.isEmpty) {
      return null;
    }

    if (patients.length == 1) {
      final patient = patients.first;

      final birthDate = patient.birthDate == null
          ? s.patientNew_notProvidedFemale
          : DateFormatUtils.formatIsoDateForDisplay(
        context,
        patient.birthDate!,
      );

      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(s.patientNew_existingPatientTitle),
            content: Text(
              '${s.patientNew_matchingPatientFound}\n\n'
                  '${patient.displayName}\n'
                  '${s.patientNew_birthDate} : $birthDate\n\n'
                  '${s.patientNew_attachVitaleQuestion}',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: Text(s.patientNew_no),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: Text(s.patientNew_attach),
              ),
            ],
          );
        },
      );

      return confirmed == true ? patient : null;
    }

    return showDialog<Patient>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(s.patientNew_choosePatient),
          content: SizedBox(
            width: 500,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: patients.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, index) {
                final patient = patients[index];

                final birthDate = patient.birthDate == null
                    ? s.patientNew_notProvidedFemale
                    : DateFormatUtils.formatIsoDateForDisplay(
                  context,
                  patient.birthDate,
                );

                return ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(patient.displayName),
                  subtitle: Text(
                    '${s.patientNew_birthDate} : $birthDate',
                  ),
                  onTap: () {
                    Navigator.of(dialogContext).pop(patient);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(s.patientNew_cancel),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmRestoreArchivedPatient(
      Patient patient, {
        required bool attachNir,
        String? nir,
      }) async {
    final s=S.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(s.patientNew_archivedPatientFound),
          content: Text(
            '${s.patientNew_archivedPatientMatch}\n\n'
                '${patient.displayName}\n'
                '${s.patientNew_birthDate} : '
                '${patient.birthDate ?? s.patientNew_notProvidedFemale}\n\n'
                '${s.patientNew_restoreInsteadOfCreate}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: Text(s.patientNew_cancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(s.patientNew_restore),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return false;
    }

    try {
      await _patientRepository.restorePatient(
        patient.patientId,
      );

      if (attachNir &&
          nir != null &&
          nir.trim().isNotEmpty &&
          patient.nir?.trim().isEmpty != false) {
        await _patientRepository.attachNirToPatient(
          patientId: patient.patientId,
          nir: nir,
        );
      }
    } catch (error) {
      if (!mounted) {
        return true;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${s.patientNew_restoreError} $error',
          ),
        ),
      );

      return true;
    }

    if (!mounted) {
      return true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          s.patientNew_restoreSuccess(patient.displayName),
        ),
      ),
    );

    Navigator.of(context).pop(true);

    return true;
  }

  Future<bool> _resolveExistingPatient(
      VitaleIdentity identity,
      ) async {
    final s=S.of(context);
    final lastName = identity.lastName?.trim();
    final firstName = identity.firstName?.trim();
    final birthDate = identity.birthDate;
    final nir = identity.nir?.trim();

    /*
   * Une comparaison fiable nécessite au minimum :
   * - le nom ;
   * - le prénom ;
   * - la date de naissance.
   *
   * Le NIR seul ne permet pas d’identifier un bénéficiaire,
   * car plusieurs bénéficiaires d’une même carte peuvent le partager.
   */
    if (lastName == null ||
        lastName.isEmpty ||
        firstName == null ||
        firstName.isEmpty ||
        birthDate == null) {
      return false;
    }

    final birthDateIso = _toIsoDate(birthDate);
    final hasNir = nir != null && nir.isNotEmpty;

    /*
   * Niveau 1 : recherche d’un patient actif par identité.
   */
    final identityMatches =
    await _patientRepository.findPatientsByIdentity(
      lastName: lastName,
      firstName: firstName,
      birthDate: birthDateIso,
    );

    if (!mounted) {
      return true;
    }

    if (identityMatches.isNotEmpty) {
      /*
     * L’identité et le NIR correspondent déjà.
     */
      final patientsWithSameNir = hasNir
          ? identityMatches.where((patient) {
        return patient.nir?.trim() == nir;
      }).toList()
          : <Patient>[];

      if (patientsWithSameNir.isNotEmpty) {
        final patient = patientsWithSameNir.first;

        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(s.patientNew_patientAlreadyRegistered),
              content: Text(
                '${s.patientNew_vitaleMatchesPatient}\n\n'
                    '${patient.displayName}\n'
                    '${s.patientNew_birthDate}'
                    '${patient.birthDate ?? s.patientNew_notProvidedFemale}\n\n'
                    '${s.patientNew_noNewPatientCreated}',
              ),
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: Text(s.patientNew_backToList),
                ),
              ],
            );
          },
        );

        if (mounted) {
          Navigator.of(context).pop(true);
        }

        return true;
      }

      /*
     * L’identité correspond à un patient qui ne possède pas encore de NIR.
     * On peut proposer de lui rattacher celui qui vient d’être lu.
     */
      final patientsWithoutNir = identityMatches.where((patient) {
        return patient.nir?.trim().isEmpty != false;
      }).toList();

      if (hasNir && patientsWithoutNir.isNotEmpty) {
        final selectedPatient = await _selectMatchingPatient(
          patientsWithoutNir,
        );

        if (!mounted) {
          return true;
        }

        if (selectedPatient != null) {
          try {
            await _patientRepository.attachNirToPatient(
              patientId: selectedPatient.patientId,
              nir: nir,
            );
          } catch (error) {
            if (!mounted) {
              return true;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '${s.patientNew_attachVitaleError} : $error',
                ),
              ),
            );

            return true;
          }

          if (!mounted) {
            return true;
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                s.patientNew_attachVitaleSuccess(selectedPatient.displayName),
              ),
            ),
          );

          Navigator.of(context).pop(true);

          return true;
        }

        /*
       * L’utilisateur refuse le rattachement :
       * la création d’un nouveau patient reste possible.
       */
        return false;
      }

      /*
     * L’identité correspond, mais le patient enregistré possède
     * un autre NIR, ou la carte n’en fournit pas.
     */
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(s.patientNew_matchToReview),
            content: Text(
              s.patientNew_matchToReviewMessage,
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: Text(s.patientNew_close),
              ),
            ],
          );
        },
      );

      return true;
    }

    /*
   * Niveau 2 : aucun patient actif trouvé.
   * Recherche d’un patient archivé par identité.
   */
    final archivedIdentityMatches =
    await _patientRepository.findArchivedPatientsByIdentity(
      lastName: lastName,
      firstName: firstName,
      birthDate: birthDateIso,
    );

    if (!mounted) {
      return true;
    }

    if (archivedIdentityMatches.isEmpty) {
      /*
     * Aucun patient ne possède cette identité.
     *
     * Un NIR identique éventuellement présent sur un autre dossier
     * ne doit pas empêcher la création de ce bénéficiaire.
     */
      return false;
    }

    /*
   * Sont restaurables :
   * - les patients sans NIR ;
   * - les patients possédant déjà le NIR lu ;
   * - tous les patients lorsque la carte ne fournit pas de NIR.
   */
    final archivedRestorablePatients =
    archivedIdentityMatches.where((patient) {
      if (!hasNir) {
        return true;
      }

      final patientNir = patient.nir?.trim();

      return patientNir == null ||
          patientNir.isEmpty ||
          patientNir == nir;
    }).toList();

    if (archivedRestorablePatients.isEmpty) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              s.patientNew_archivedMatchToReview,
            ),
            content: Text(
              s.patientNew_archivedMatchToReviewMessage,
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: Text(s.patientNew_close),
              ),
            ],
          );
        },
      );

      return true;
    }

    final archivedPatient = await _selectMatchingPatient(
      archivedRestorablePatients,
    );

    if (!mounted) {
      return true;
    }

    if (archivedPatient == null) {
      /*
     * L’utilisateur refuse la restauration.
     * La création d’un nouveau patient reste possible.
     */
      return false;
    }

    return _confirmRestoreArchivedPatient(
      archivedPatient,
      attachNir: hasNir &&
          archivedPatient.nir?.trim().isEmpty != false,
      nir: nir,
    );
  }

  Future<void> _showModuleNotInstalledDialog() async {
    final s=S.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(s.patientNew_vitaleModuleNotInstalled),
          content: Text(
            s.patientNew_vitaleModuleNotInstalledMessage,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(s.patientNew_close),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();

                final uri = Uri.parse(
                  'https://abak.care/demande-de-telechargement-du-module-abak-carte-vitale/',
                );

                await launchUrl(
                  uri,
                  mode: LaunchMode.externalApplication,
                );
              },
              child: Text(s.patientNew_download),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showReaderNotDetectedDialog() async {
    final s=S.of(context);
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            s.patientNew_readerNotDetected,
          ),
          content: Text(
            s.patientNew_readerNotDetectedMessage,
          ),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: Text(s.patientNew_close),
            ),
          ],
        );
      },
    );
  }

  Future<void> _readVitaleIdentity() async {
    final s=S.of(context);
    if (_saving || _loadingVitale) {
      return;
    }

    setState(() {
      _loadingVitale = true;
    });

    VitaleIdentity? identity;

    try {
      final moduleStatus = await _apiLecService.getModuleStatus();

      if (!mounted) {
        return;
      }

      if (!moduleStatus.installed) {
        await _showModuleNotInstalledDialog();
        return;
      }

      List<VitaleIdentity> identities;

      try {
        identities = await _vitaleIdentityService.readVitaleIdentities();
      } on PlatformException catch (error) {
        if (!mounted) {
          return;
        }

        final isReaderNotDetected =
            error.code == 'API_INIT_ERROR' &&
                (error.message?.contains('retour=13') ?? false);

        if (isReaderNotDetected) {
          await _showReaderNotDetectedDialog();
          return;
        }

        final message =
        error.code == 'API_INIT_ERROR' &&
            (error.message?.contains('retour=32') ?? false)
            ? s.patientNew_vitaleModuleConfigurationError
            : s.patientNew_vitaleReadFailed;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );

        return;
      }

      if (!mounted) {
        return;
      }

      if (identities.isEmpty) {
        identity = null;
      } else if (identities.length == 1) {
        identity = identities.first;
      } else {
        identity = await VitaleBeneficiarySelector.show(
          context,
          identities,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loadingVitale = false;
        });
      }
    }

    if (!mounted) {
      return;
    }

    if (identity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            s.patientNew_vitaleReadFailed,
          ),
        ),
      );
      return;
    }

    final existingPatientResolved =
    await _resolveExistingPatient(identity);

    if (!mounted || existingPatientResolved) {
      return;
    }

    setState(() {
      final lastName = identity!.lastName?.trim();
      if (lastName?.isNotEmpty == true) {
        _lastNameController.text = lastName!;
      }

      final firstName = identity.firstName?.trim();
      if (firstName?.isNotEmpty == true) {
        _firstNameController.text = firstName!;
      }

      final birthDate = identity.birthDate;
      if (birthDate != null) {
        _birthDateController.text = _birthDateDisplayFormat(
          context,
        ).format(birthDate);
      }

      final sexCode = identity.sexCode?.trim().toUpperCase();
      if (sexCode == 'M' || sexCode == 'F' || sexCode == 'X') {
        _sexCode = sexCode!;
      } else {
        _sexCode = 'U';
      }

      final nir = identity.nir?.trim();
      _nir = nir?.isNotEmpty == true ? nir : null;

      _identityReadFromVitale = true;
      _vitaleReadAt = DateTime.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          s.patientNew_vitalePrefilled,
        ),
      ),
    );
  }

  Future<void> _save() async {
    final s=S.of(context);
    if (_saving) return;

    final form = _formKey.currentState;
    if (form == null || !form.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await _patientRepository.createPatient(
        lastName: _lastNameController.text.trim(),
        firstName: _firstNameController.text.trim(),
        birthDate: _birthDateToIsoOrNull(),
        sexCode: _sexCode,
        nir: _nir,
      );

      if (!mounted) return;

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(('${s.patientNew_createError} $e')),
      ));

      setState(() {
        _saving = false;
      });
    }
  }

  String _sexLabel(String sexCode, S s) {
    switch (sexCode) {
      case 'F':
        return s.patientNew_female;
      case 'M':
        return s.patientNew_male;
      case 'X':
        return s.patientNew_other;
      default:
        return s.patientNew_notProvided;
    }
  }

  String _vitaleReadDateLabel(BuildContext context) {
    final readAt = _vitaleReadAt;

    if (readAt == null) {
      return '';
    }

    final locale = Localizations.localeOf(context).toString();

    return DateFormat.yMd(locale).add_Hm().format(readAt);
  }

  Widget _buildVitaleIdentityCard(BuildContext context) {
    final s=S.of(context);
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.verified_user_outlined,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    s.patientNew_vitaleIdentityRead,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${s.patientNew_lastName} ${_lastNameController.text.trim()}',
                  ),
                  Text(
                    '${s.patientNew_firstName} ${_firstNameController.text.trim()}',
                  ),
                  Text(
                    '${s.patientNew_birthDate}'
                    '${_birthDateController.text.trim().isEmpty ? s.patientNew_notProvidedFemale : _birthDateController.text.trim()}',
                  ),
                  Text(
                    '${s.patientList_sex} ${_sexLabel(_sexCode, s)}',
                  ),
                  Text(
                    '${s.patientNew_nir} ${_nir == null ? s.patientNew_nirUnavailable : s.patientNew_nirDetectedProtected}',
                  ),
                  if (_vitaleReadAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      '${s.patientNew_readOn}'
                      '${_vitaleReadDateLabel(context)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s=S.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(s.patientNew_contextName),
      actions: [
        if (_expertModeEnabled)
          ExpertInfoButton(
            info: _expertInfo(s),
          ),
      ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                s.patientNew_patientIdentity,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                            ),
                            OutlinedButton.icon(
                              onPressed:
                              _saving || _loadingVitale ? null : _readVitaleIdentity,
                              icon: _loadingVitale
                                  ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Icon(Icons.credit_card_outlined),
                              label: Text(
                                _loadingVitale
                                    ? s.patientNew_reading
                                    : s.patientNew_readVitale,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        if (_identityReadFromVitale) ...[
                          _buildVitaleIdentityCard(context),
                          const SizedBox(height: 24),
                        ] else
                          const SizedBox(height: 8),

                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: s.patientNew_lastName,
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return s.patientNew_lastNameRequired;
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: s.patientNew_firstName,
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return s.patientNew_firstNameRequired;
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _birthDateController,
                          decoration: InputDecoration(
                            labelText: s.patientNew_birthDate,
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          readOnly: true,
                          onTap: _selectBirthDate,
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          initialValue: _sexCode,
                          decoration: InputDecoration(
                            labelText: s.patientList_sex,
                            border: OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'U',
                              child: Text(s.patientNew_notProvidedFemale),
                            ),
                            DropdownMenuItem(
                              value: 'F',
                              child: Text(s.patientNew_female),
                            ),
                            DropdownMenuItem(
                              value: 'M',
                              child: Text(s.patientNew_male),
                            ),
                            DropdownMenuItem(value: 'X', child: Text(s.patientNew_other)),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() {
                              _sexCode = value;
                            });
                          },
                        ),

                        const SizedBox(height: 32),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: _saving
                                  ? null
                                  : () => Navigator.of(context).pop(false),
                              child: Text(s.patientNew_cancel),
                            ),
                            const SizedBox(width: 12),
                            FilledButton.icon(
                              onPressed: _saving ? null : _save,
                              icon: _saving
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.check),
                              label: Text(
                                _saving ? s.patientNew_creating : s.patientNew_createPatient,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

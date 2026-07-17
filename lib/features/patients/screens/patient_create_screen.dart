// Gestion du flux métier patient - épisode
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/patient_repository.dart';
import '../../smart_card/models/vitale_identity.dart';
import '../../smart_card/services/vitale_identity_service.dart';
import '../models/patient.dart';

class PatientCreateScreen extends StatefulWidget {
  const PatientCreateScreen({super.key});

  @override
  State<PatientCreateScreen> createState() => _PatientCreateScreenState();
}

class _PatientCreateScreenState extends State<PatientCreateScreen> {
  final PatientRepository _patientRepository = PatientRepository();
  final VitaleIdentityService _vitaleIdentityService =
  const VitaleIdentityService();


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
    if (patients.isEmpty) {
      return null;
    }

    if (patients.length == 1) {
      final patient = patients.first;

      final confirmed = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Patient déjà existant ?'),
            content: Text(
              'Un patient correspondant a été trouvé :\n\n'
                  '${patient.displayName}\n'
                  'Date de naissance : ${patient.birthDate ?? 'non renseignée'}\n\n'
                  'Voulez-vous rattacher les informations de la Carte Vitale '
                  'à ce patient ?',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Non'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('Rattacher'),
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
          title: const Text('Choisir le patient'),
          content: SizedBox(
            width: 500,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: patients.length,
              separatorBuilder: (_, _) => const Divider(),
              itemBuilder: (context, index) {
                final patient = patients[index];

                return ListTile(
                  leading: const Icon(Icons.person_outline),
                  title: Text(patient.displayName),
                  subtitle: Text(
                    'Date de naissance : '
                        '${patient.birthDate ?? 'non renseignée'}',
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
              child: const Text('Annuler'),
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
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Patient trouvé dans les archives'),
          content: Text(
            'Cette Carte Vitale correspond au patient archivé :\n\n'
                '${patient.displayName}\n'
                'Date de naissance : '
                '${patient.birthDate ?? 'non renseignée'}\n\n'
                'Souhaitez-vous restaurer ce dossier plutôt que créer '
                'un nouveau patient ?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Restaurer'),
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
            'Impossible de restaurer le patient : $error',
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
          'Le patient ${patient.displayName} a été restauré.',
        ),
      ),
    );

    Navigator.of(context).pop(true);

    return true;
  }

  Future<bool> _resolveExistingPatient(
      VitaleIdentity identity,
      ) async {
    final nir = identity.nir?.trim();

    if (nir == null || nir.isEmpty) {
      return false;
    }

    /*
   * Niveau 1 : recherche d’un patient actif par NIR.
   */
    final patientByNir =
    await _patientRepository.getPatientByNir(nir);

    if (!mounted) {
      return true;
    }

    if (patientByNir != null) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Patient déjà enregistré'),
            content: Text(
              'Cette Carte Vitale est déjà rattachée au patient :\n\n'
                  '${patientByNir.displayName}\n'
                  'Date de naissance : '
                  '${patientByNir.birthDate ?? 'non renseignée'}\n\n'
                  'Aucun nouveau patient ne sera créé.',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Retour à la liste'),
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
   * Niveau 2 : recherche d’un patient archivé par NIR.
   */
    final archivedPatientByNir =
    await _patientRepository.getArchivedPatientByNir(nir);

    if (!mounted) {
      return true;
    }

    if (archivedPatientByNir != null) {
      return _confirmRestoreArchivedPatient(
        archivedPatientByNir,
        attachNir: false,
      );
    }

    /*
   * Préparation de la recherche par identité.
   */
    final lastName = identity.lastName?.trim();
    final firstName = identity.firstName?.trim();
    final birthDate = identity.birthDate;

    if (lastName == null ||
        lastName.isEmpty ||
        firstName == null ||
        firstName.isEmpty ||
        birthDate == null) {
      return false;
    }

    final birthDateIso = _toIsoDate(birthDate);

    /*
   * Niveau 3 : recherche d’un patient actif par identité.
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
     * On ne propose le rattachement qu’aux patients actifs
     * ne possédant pas encore de NIR.
     */
      final attachablePatients = identityMatches.where((patient) {
        return patient.nir?.trim().isEmpty != false;
      }).toList();

      if (attachablePatients.isEmpty) {
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Correspondance à vérifier'),
              content: const Text(
                'Un patient ayant les mêmes nom, prénom et date de naissance '
                    'existe déjà, mais il possède un autre NIR.\n\n'
                    'Aucun rattachement automatique ne sera effectué. '
                    'Vérifiez les dossiers avant de poursuivre.',
              ),
              actions: [
                FilledButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();
                  },
                  child: const Text('Fermer'),
                ),
              ],
            );
          },
        );

        return true;
      }

      final selectedPatient = await _selectMatchingPatient(
        attachablePatients,
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
                'Impossible de rattacher la Carte Vitale : $error',
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
              'Carte Vitale rattachée au patient '
                  '${selectedPatient.displayName}.',
            ),
          ),
        );

        Navigator.of(context).pop(true);

        return true;
      }

      /*
     * L’utilisateur refuse le rattachement au patient actif.
     * On ne recherche pas alors un patient archivé ayant la même identité :
     * la correspondance active doit être vérifiée en priorité.
     */
      return false;
    }

    /*
   * Niveau 4 : aucun patient actif trouvé.
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
      return false;
    }

    /*
   * Sont restaurables :
   * - les patients sans NIR ;
   * - les patients possédant déjà le NIR lu.
   */
    final archivedAttachablePatients =
    archivedIdentityMatches.where((patient) {
      final patientNir = patient.nir?.trim();

      return patientNir == null ||
          patientNir.isEmpty ||
          patientNir == nir;
    }).toList();

    if (archivedAttachablePatients.isEmpty) {
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text(
              'Correspondance archivée à vérifier',
            ),
            content: const Text(
              'Un patient archivé ayant les mêmes nom, prénom et '
                  'date de naissance existe déjà, mais il possède un '
                  'autre NIR.\n\n'
                  'Aucune restauration automatique ne sera effectuée. '
                  'Vérifiez les dossiers avant de poursuivre.',
            ),
            actions: [
              FilledButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                },
                child: const Text('Fermer'),
              ),
            ],
          );
        },
      );

      return true;
    }

    final archivedPatient = await _selectMatchingPatient(
      archivedAttachablePatients,
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
      attachNir: archivedPatient.nir?.trim().isEmpty != false,
      nir: nir,
    );
  }

  Future<void> _readVitaleIdentity() async {
    if (_saving || _loadingVitale) {
      return;
    }

    setState(() {
      _loadingVitale = true;
    });

    VitaleIdentity? identity;

    try {
      identity = await _vitaleIdentityService.readVitaleIdentity();
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
        const SnackBar(
          content: Text(
            'La lecture de la Carte Vitale a échoué.',
          ),
        ),
      );
      return;
    }

    final vitaleIdentity = identity;

    final existingPatientResolved =
    await _resolveExistingPatient(vitaleIdentity);

    if (!mounted || existingPatientResolved) {
      return;
    }

    setState(() {
      final lastName = vitaleIdentity.lastName?.trim();
      if (lastName?.isNotEmpty == true) {
        _lastNameController.text = lastName!;
      }

      final firstName = vitaleIdentity.firstName?.trim();
      if (firstName?.isNotEmpty == true) {
        _firstNameController.text = firstName!;
      }

      final birthDate = vitaleIdentity.birthDate;
      if (birthDate != null) {
        _birthDateController.text = _birthDateDisplayFormat(
          context,
        ).format(birthDate);
      }

      final sexCode = vitaleIdentity.sexCode?.trim().toUpperCase();
      if (sexCode == 'M' || sexCode == 'F' || sexCode == 'X') {
        _sexCode = sexCode!;
      } else {
        _sexCode = 'U';
      }

      final nir = vitaleIdentity.nir?.trim();
      _nir = nir?.isNotEmpty == true ? nir : null;

      _identityReadFromVitale = true;
      _vitaleReadAt = DateTime.now();
    });


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
      const SnackBar(
        content: Text(
          'Informations patient préremplies depuis la Carte Vitale.',
        ),
      ),
    );
  }

  Future<void> _save() async {
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
        SnackBar(content: Text('Erreur lors de la création du patient : $e')),
      );

      setState(() {
        _saving = false;
      });
    }
  }

  String _sexLabel(String sexCode) {
    switch (sexCode) {
      case 'F':
        return 'Féminin';
      case 'M':
        return 'Masculin';
      case 'X':
        return 'Autre';
      default:
        return 'Non renseigné';
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
                    'Identité lue depuis la Carte Vitale',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nom : ${_lastNameController.text.trim()}',
                  ),
                  Text(
                    'Prénom : ${_firstNameController.text.trim()}',
                  ),
                  Text(
                    'Date de naissance : '
                        '${_birthDateController.text.trim().isEmpty ? 'Non renseignée' : _birthDateController.text.trim()}',
                  ),
                  Text(
                    'Sexe : ${_sexLabel(_sexCode)}',
                  ),
                  Text(
                    'NIR : ${_nir == null ? 'non disponible' : 'détecté et protégé'}',
                  ),
                  if (_vitaleReadAt != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Lecture effectuée le '
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
    return Scaffold(
      appBar: AppBar(title: const Text('Nouveau patient')),
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
                                'Identité du patient',
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
                                    ? 'Lecture en cours...'
                                    : 'Lire Carte Vitale',
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
                          decoration: const InputDecoration(
                            labelText: 'Nom',
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le nom est obligatoire';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'Prénom',
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.next,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Le prénom est obligatoire';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _birthDateController,
                          decoration: const InputDecoration(
                            labelText: 'Date de naissance',
                            hintText: 'JJ/MM/AAAA',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today_outlined),
                          ),
                          readOnly: true,
                          onTap: _selectBirthDate,
                        ),

                        const SizedBox(height: 16),

                        DropdownButtonFormField<String>(
                          initialValue: _sexCode,
                          decoration: const InputDecoration(
                            labelText: 'Sexe',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: 'U',
                              child: Text('Non renseigné'),
                            ),
                            DropdownMenuItem(
                              value: 'F',
                              child: Text('Féminin'),
                            ),
                            DropdownMenuItem(
                              value: 'M',
                              child: Text('Masculin'),
                            ),
                            DropdownMenuItem(value: 'X', child: Text('Autre')),
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
                              child: const Text('Annuler'),
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
                                _saving ? 'Création...' : 'Créer le patient',
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

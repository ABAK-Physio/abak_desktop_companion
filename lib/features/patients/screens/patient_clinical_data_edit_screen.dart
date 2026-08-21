import 'package:flutter/material.dart';
import '../../../generated/l10n.dart';
import '../data/patient_attribute_repository.dart';
import '../data/patient_identity_repository.dart';
import '../models/patient_attribute.dart';
import '../models/patient_identity.dart';

class PatientClinicalDataEditScreen extends StatefulWidget {
  final String patientId;

  const PatientClinicalDataEditScreen({super.key, required this.patientId});

  @override
  State<PatientClinicalDataEditScreen> createState() =>
      _PatientClinicalDataEditScreenState();
}

class _PatientClinicalDataEditScreenState
    extends State<PatientClinicalDataEditScreen> {
  final PatientIdentityRepository _identityRepository =
      PatientIdentityRepository();

  final PatientAttributeRepository _attributeRepository =
      PatientAttributeRepository();

  final _nationalHealthIdController = TextEditingController();
  final _professionController = TextEditingController();
  final _sportController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();

  bool _loading = true;
  bool _saving = false;

  String _dominantSide = 'non précisé';
  String _healthSystemCountry = 'FR';
  String _identitySource = 'saisie manuelle';

  @override
  void initState() {
    super.initState();
    _loadExistingData();
  }

  @override
  void dispose() {
    _nationalHealthIdController.dispose();
    _professionController.dispose();
    _sportController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingData() async {
    final identity = await _identityRepository.getByPatientId(widget.patientId);

    final attributes = await _attributeRepository.getByPatientId(
      widget.patientId,
    );

    _nationalHealthIdController.text = identity?.nationalHealthId ?? '';
    _healthSystemCountry =
        identity?.healthSystemCountry?.trim().isNotEmpty == true
        ? identity!.healthSystemCountry!
        : 'FR';

    _identitySource = identity?.identitySource?.trim().isNotEmpty == true
        ? identity!.identitySource!
        : 'saisie manuelle';
    _phoneController.text = identity?.phone ?? '';
    _emailController.text = identity?.email ?? '';
    _addressController.text = identity?.address ?? '';

    final dominantSide = _attributeValue(attributes, 'dominant_side');

    _dominantSide = _normalizeDominantSide(dominantSide);
    _professionController.text = _attributeValue(attributes, 'profession');
    _sportController.text = _attributeValue(attributes, 'sport');
    _heightController.text = _attributeValue(attributes, 'height_cm');
    _weightController.text = _attributeValue(attributes, 'weight_kg');

    if (!mounted) return;

    setState(() {
      _loading = false;
    });
  }

  String _attributeValue(List<PatientAttribute> attributes, String key) {
    final matching = attributes.where((a) => a.attributeKey == key);

    if (matching.isEmpty) return '';

    return matching.first.attributeValue ?? '';
  }

  String _normalizeDominantSide(String value) {
    final normalized = value.trim().toLowerCase();

    switch (normalized) {
      case 'droite':
      case 'droit':
        return 'droite';
      case 'gauche':
        return 'gauche';
      case 'ambidextre':
        return 'ambidextre';
      default:
        return 'non précisé';
    }
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> values,
    required String Function(String value) displayLabel,
    required ValueChanged<String?> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
        ),
        items: values
            .map(
              (e) => DropdownMenuItem(
            value: e,
            child: Text(displayLabel(e)),
          ),
        )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
    });

    final now = DateTime.now().millisecondsSinceEpoch;

    await _identityRepository.upsert(
      PatientIdentity(
        patientId: widget.patientId,
        nationalHealthId: _nationalHealthIdController.text.trim(),
        healthSystemCountry: _healthSystemCountry,
        identitySource: _identitySource,
        phone: _phoneController.text.trim(),
        email: _emailController.text.trim(),
        address: _addressController.text.trim(),
        updatedAt: now,
      ),
    );

    await _attributeRepository.upsertValue(
      patientId: widget.patientId,
      attributeKey: 'dominant_side',
      attributeValue: _dominantSide,
    );

    await _attributeRepository.upsertValue(
      patientId: widget.patientId,
      attributeKey: 'profession',
      attributeValue: _professionController.text.trim(),
    );

    await _attributeRepository.upsertValue(
      patientId: widget.patientId,
      attributeKey: 'sport',
      attributeValue: _sportController.text.trim(),
    );

    await _attributeRepository.upsertValue(
      patientId: widget.patientId,
      attributeKey: 'height_cm',
      attributeValue: _heightController.text.trim(),
    );

    await _attributeRepository.upsertValue(
      patientId: widget.patientId,
      attributeKey: 'weight_kg',
      attributeValue: _weightController.text.trim(),
    );

    if (!mounted) return;

    Navigator.of(context).pop(true);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? helperText,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          labelText: label,
          helperText: helperText,
        ),
      ),
    );
  }

  Widget _buildContent() {
    final s = S.of(context);
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(
          s.patientClinicalDataEdit_administrativeIdentity,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _nationalHealthIdController,
          label: s.patientClinicalDataEdit_nationalHealthId,
          helperText: s.patientClinicalDataEdit_nationalHealthIdHelper,
        ),
        _buildDropdownField(
          label: s.patientClinicalDataEdit_identitySource,
          value: _identitySource,
          values: const [
            'saisie manuelle',
            'Carte Vitale',
          ],
          displayLabel: (value) {
            switch (value) {
              case 'saisie manuelle':
                return s.patientClinicalDataEdit_manualEntry;
              case 'Carte Vitale':
                return s.patientClinicalDataEdit_vitaleCard;
              default:
                return value;
            }
          },
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _identitySource = value;
            });
          },
        ),
        _buildTextField(
          controller: _phoneController,
          label: s.patientClinicalDataEdit_phone,
          keyboardType: TextInputType.phone,
        ),

        _buildTextField(
          controller: _emailController,
          label: s.patientClinicalDataEdit_email,
          keyboardType: TextInputType.emailAddress,
        ),

        _buildTextField(
          controller: _addressController,
          label: s.patientClinicalDataEdit_address,
          keyboardType: TextInputType.multiline,
        ),
        const SizedBox(height: 24),
        Text(s.patientClinicalDataEdit_patientProfile, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        _buildDropdownField(
          label: s.patientClinicalDataEdit_dominantSide,
          value: _dominantSide,
          values: const [
            'droite',
            'gauche',
            'ambidextre',
            'non précisé',
          ],
          displayLabel: (value) {
            switch (value) {
              case 'droite':
                return s.patientClinicalDataEdit_right;
              case 'gauche':
                return s.patientClinicalDataEdit_left;
              case 'ambidextre':
                return s.patientClinicalDataEdit_ambidextrous;
              case 'non précisé':
                return s.patientClinicalDataEdit_unspecified;
              default:
                return value;
            }
          },
          onChanged: (value) {
            if (value == null) return;

            setState(() {
              _dominantSide = value;
            });
          },
        ),
        _buildTextField(controller: _professionController, label: s.patientClinicalDataEdit_profession),
        _buildTextField(
          controller: _sportController,
          label: s.patientClinicalDataEdit_sportActivity,
        ),
        _buildTextField(
          controller: _heightController,
          label: s.patientClinicalDataEdit_height,
          helperText: s.patientClinicalDataEdit_centimeters,
          keyboardType: TextInputType.number,
        ),
        _buildTextField(
          controller: _weightController,
          label: s.patientClinicalDataEdit_weight,
          helperText: s.patientClinicalDataEdit_kilograms,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.patientClinicalDataEdit_title),
        actions: [
          TextButton.icon(
            onPressed: _saving ? null : _save,
            icon: const Icon(Icons.save_outlined),
            label: Text(s.patientClinicalDataEdit_save),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _buildContent(),
    );
  }
}

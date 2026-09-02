import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/settings/cabinet_identity_service.dart';
import '../../generated/l10n.dart';

class OrganizationScreen extends StatefulWidget {
  const OrganizationScreen({super.key});

  @override
  State<OrganizationScreen> createState() => _OrganizationScreenState();
}

class _OrganizationScreenState extends State<OrganizationScreen> {
  final CabinetIdentityService _cabinetIdentityService =
  const CabinetIdentityService();

  final TextEditingController _cabinetNameController =
  TextEditingController();

  final TextEditingController _addressLine1Controller =
  TextEditingController();

  final TextEditingController _addressLine2Controller =
  TextEditingController();

  final TextEditingController _postalCodeController =
  TextEditingController();

  final TextEditingController _cityController =
  TextEditingController();

  final TextEditingController _phoneController =
  TextEditingController();

  final TextEditingController _emailController =
  TextEditingController();

  String? _cabinetLogoPath;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadOrganization();
  }

  @override
  void dispose() {
    _cabinetNameController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _postalCodeController.dispose();
    _cityController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadOrganization() async {
    final cabinetName = await _cabinetIdentityService.getCabinetName();
    final cabinetLogoPath =
    await _cabinetIdentityService.getCabinetLogoPath();
    final addressLine1 =
    await _cabinetIdentityService.getCabinetAddressLine1();
    final addressLine2 =
    await _cabinetIdentityService.getCabinetAddressLine2();
    final postalCode =
    await _cabinetIdentityService.getCabinetPostalCode();
    final city =
    await _cabinetIdentityService.getCabinetCity();
    final phone =
    await _cabinetIdentityService.getCabinetPhone();
    final email =
    await _cabinetIdentityService.getCabinetEmail();

    if (!mounted) return;

    setState(() {
      _cabinetNameController.text = cabinetName ?? '';
      _addressLine1Controller.text = addressLine1 ?? '';
      _addressLine2Controller.text = addressLine2 ?? '';
      _postalCodeController.text = postalCode ?? '';
      _cityController.text = city ?? '';
      _phoneController.text = phone ?? '';
      _emailController.text = email ?? '';
      _cabinetLogoPath = cabinetLogoPath;
      _loading = false;
    });
  }

  Future<void> _saveCabinetIdentity() async {
    final s = S.of(context);

    await _cabinetIdentityService.setCabinetName(
      _cabinetNameController.text,
    );

    await _cabinetIdentityService.setCabinetAddressLine1(
      _addressLine1Controller.text,
    );

    await _cabinetIdentityService.setCabinetAddressLine2(
      _addressLine2Controller.text,
    );

    await _cabinetIdentityService.setCabinetPostalCode(
      _postalCodeController.text,
    );

    await _cabinetIdentityService.setCabinetCity(
      _cityController.text,
    );

    await _cabinetIdentityService.setCabinetPhone(
      _phoneController.text,
    );

    await _cabinetIdentityService.setCabinetEmail(
      _emailController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.organization_nameSaved),
      ),
    );
  }

  Future<void> _chooseLogo() async {
    final s=S.of(context);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    final path = result?.files.single.path;
    if (path == null) return;

    await _cabinetIdentityService.setCabinetLogoPath(path);

    if (!mounted) return;

    setState(() {
      _cabinetLogoPath = path;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.organization_logoSaved),
      ),
    );
  }

  Future<void> _removeLogo() async {
    final s=S.of(context);
    await _cabinetIdentityService.clearCabinetLogoPath();

    if (!mounted) return;

    setState(() {
      _cabinetLogoPath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(s.organization_logoRemoved),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s=S.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.organization_title),
      ),
      body: Center(
        child: SizedBox(
          width: 760,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _loading
                  ? const Center(
                child: CircularProgressIndicator(),
              )
                  : ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    s.organization_identityTitle,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),

                  TextField(
                    controller: _cabinetNameController,
                    decoration: InputDecoration(
                      labelText: s.organization_nameLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _addressLine1Controller,
                    decoration: const InputDecoration(
                      labelText: 'Adresse',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  TextField(
                    controller: _addressLine2Controller,
                    decoration: const InputDecoration(
                      labelText: 'Complément d’adresse',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      SizedBox(
                        width: 180,
                        child: TextField(
                          controller: _postalCodeController,
                          decoration: const InputDecoration(
                            labelText: 'Code postal',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _cityController,
                          decoration: const InputDecoration(
                            labelText: 'Ville',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Téléphone',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            labelText: 'E-mail',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _saveCabinetIdentity,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text(
                        'Enregistrer les coordonnées',
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    children: [
                      _LogoPreview(path: _cabinetLogoPath),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            OutlinedButton.icon(
                              onPressed: _chooseLogo,
                              icon: const Icon(Icons.image_outlined),
                              label: Text(
                                s.organization_chooseLogo,
                              ),
                            ),
                            if (_cabinetLogoPath != null)
                              TextButton.icon(
                                onPressed: _removeLogo,
                                icon: const Icon(
                                  Icons.delete_outline,
                                ),
                                label: Text(
                                  s.organization_removeLogo,
                                ),
                              ),
                          ],
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
    );
  }
}

class _LogoPreview extends StatelessWidget {
  final String? path;

  const _LogoPreview({required this.path});

  @override
  Widget build(BuildContext context) {
    final logoFile = path == null ? null : File(path!);
    final hasLogo = logoFile != null && logoFile.existsSync();

    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: hasLogo
          ? ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          logoFile,
          fit: BoxFit.contain,
        ),
      )
          : const Icon(
        Icons.image_outlined,
        size: 40,
      ),
    );
  }
}
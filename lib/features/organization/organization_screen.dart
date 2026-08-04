import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/settings/cabinet_identity_service.dart';

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
    super.dispose();
  }

  Future<void> _loadOrganization() async {
    final cabinetName = await _cabinetIdentityService.getCabinetName();
    final cabinetLogoPath =
    await _cabinetIdentityService.getCabinetLogoPath();

    if (!mounted) return;

    setState(() {
      _cabinetNameController.text = cabinetName ?? '';
      _cabinetLogoPath = cabinetLogoPath;
      _loading = false;
    });
  }

  Future<void> _saveCabinetName() async {
    await _cabinetIdentityService.setCabinetName(
      _cabinetNameController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nom de l’établissement enregistré.'),
      ),
    );
  }

  Future<void> _chooseLogo() async {
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
      const SnackBar(
        content: Text('Logo de l’établissement enregistré.'),
      ),
    );
  }

  Future<void> _removeLogo() async {
    await _cabinetIdentityService.clearCabinetLogoPath();

    if (!mounted) return;

    setState(() {
      _cabinetLogoPath = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Logo de l’établissement supprimé.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Établissement'),
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
                    'Identité de l’établissement',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _cabinetNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom de l’établissement',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _saveCabinetName(),
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _saveCabinetName,
                      icon: const Icon(Icons.save_outlined),
                      label: const Text('Enregistrer le nom'),
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
                              label: const Text('Choisir un logo'),
                            ),
                            if (_cabinetLogoPath != null)
                              TextButton.icon(
                                onPressed: _removeLogo,
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Supprimer le logo'),
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
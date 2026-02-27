import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/app_theme.dart';
import '../../providers/app_providers.dart';

class EditProfileDialog extends ConsumerStatefulWidget {
  final Map<String, dynamic> currentUser;
  final Function(Map<String, dynamic>) onSave;

  const EditProfileDialog({
    Key? key,
    required this.currentUser,
    required this.onSave,
  }) : super(key: key);

  @override
  ConsumerState<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends ConsumerState<EditProfileDialog> {
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _cnibController;
  late final TextEditingController _cityController;
  late final TextEditingController _dateController;
  late String _selectedGender;

  @override
  void initState() {
    super.initState();
    _firstNameController = TextEditingController(
      text: widget.currentUser?['firstName'] ??
          widget.currentUser?['first_name'] ??
          '',
    );
    _lastNameController = TextEditingController(
      text: widget.currentUser?['lastName'] ??
          widget.currentUser?['last_name'] ??
          '',
    );
    _cnibController = TextEditingController(
      text: widget.currentUser?['cnib'] ?? '',
    );
    _cityController = TextEditingController(
      text: widget.currentUser?['city'] ?? '',
    );
    _dateController = TextEditingController(
      text:
          widget.currentUser?['dateOfBirth']?.toString().split('T').first ?? '',
    );
    _selectedGender = widget.currentUser?['gender'] ?? 'Masculin';
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _cnibController.dispose();
    _cityController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Modifier le profil'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(
                labelText: 'Prénom',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(
                labelText: 'Nom',
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _cnibController,
              decoration: const InputDecoration(
                labelText: 'CNIB',
                prefixIcon: Icon(Icons.badge),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(
                labelText: 'Sexe',
                prefixIcon: Icon(Icons.wc),
              ),
              items: const [
                DropdownMenuItem(value: 'Masculin', child: Text('Masculin')),
                DropdownMenuItem(value: 'Féminin', child: Text('Féminin')),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() => _selectedGender = value);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _dateController,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Date de naissance',
                prefixIcon: Icon(Icons.cake),
              ),
              onTap: () async {
                final now = DateTime.now();
                final initialDate = DateTime.tryParse(_dateController.text) ??
                    DateTime(now.year - 25, 1, 1);
                final picked = await showDatePicker(
                  context: context,
                  initialDate: initialDate,
                  firstDate: DateTime(1950, 1, 1),
                  lastDate: DateTime(now.year, now.month, now.day),
                );
                if (picked != null) {
                  setState(() {
                    _dateController.text =
                        picked.toIso8601String().split('T').first;
                  });
                }
              },
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                labelText: 'Ville',
                prefixIcon: Icon(Icons.location_city),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            widget.onSave({
              'firstName': _firstNameController.text.trim(),
              'lastName': _lastNameController.text.trim(),
              'cnib': _cnibController.text.trim(),
              'gender': _selectedGender,
              'dateOfBirth': _dateController.text.trim(),
              'city': _cityController.text.trim(),
            });
            Navigator.pop(context);
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}

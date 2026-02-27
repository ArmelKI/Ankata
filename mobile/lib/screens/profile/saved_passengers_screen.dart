import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../providers/app_providers.dart';

class SavedPassengersScreen extends ConsumerStatefulWidget {
  const SavedPassengersScreen({super.key});

  @override
  ConsumerState<SavedPassengersScreen> createState() =>
      _SavedPassengersScreenState();
}

class _SavedPassengersScreenState extends ConsumerState<SavedPassengersScreen> {
  bool _isLoading = false;
  List<dynamic> _passengers = [];

  @override
  void initState() {
    super.initState();
    _loadPassengers();
  }

  Future<void> _loadPassengers() async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      final passengers = await api.getSavedPassengers();
      setState(() => _passengers = passengers);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showAddEditDialog([Map<String, dynamic>? passenger]) {
    final isEditing = passenger != null;
    final firstNameController =
        TextEditingController(text: passenger?['first_name']);
    final lastNameController =
        TextEditingController(text: passenger?['last_name']);
    final phoneController =
        TextEditingController(text: passenger?['phone_number']);
    final idNumberController =
        TextEditingController(text: passenger?['id_number']);
    String? selectedIdType = passenger?['id_type'] ?? 'CNIB';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEditing ? 'Modifier le passager' : 'Nouveau passager'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'Prénom *'),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Nom *'),
                ),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Téléphone'),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedIdType,
                  decoration: const InputDecoration(labelText: 'Type de pièce'),
                  items: ['CNIB', 'Passport', 'Carte Militaire', 'Autre']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => setDialogState(() => selectedIdType = v),
                ),
                TextField(
                  controller: idNumberController,
                  decoration:
                      const InputDecoration(labelText: 'Numéro de pièce'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (firstNameController.text.isEmpty ||
                    lastNameController.text.isEmpty) {
                  return;
                }
                Navigator.pop(context);
                await _savePassenger(
                  id: passenger?['id'],
                  data: {
                    'firstName': firstNameController.text,
                    'lastName': lastNameController.text,
                    'phoneNumber': phoneController.text,
                    'idType': selectedIdType,
                    'idNumber': idNumberController.text,
                  },
                );
              },
              child: Text(isEditing ? 'Mettre à jour' : 'Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePassenger(
      {String? id, required Map<String, dynamic> data}) async {
    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      if (id != null) {
        await api.updateSavedPassenger(id, data);
      } else {
        await api.createSavedPassenger(data);
      }
      _loadPassengers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur: $e'), backgroundColor: AppColors.error),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deletePassenger(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer'),
        content: const Text('Voulez-vous vraiment supprimer ce passager ?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Non')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Oui')),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final api = ref.read(apiServiceProvider);
      await api.deleteSavedPassenger(id);
      _loadPassengers();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur: $e'), backgroundColor: AppColors.error),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Passagers enregistrés'),
        actions: [
          IconButton(
            onPressed: () => _showAddEditDialog(),
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _passengers.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _passengers.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final p = _passengers[index];
                    return _buildPassengerCard(p);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline,
              size: 80, color: AppColors.gray.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          const Text(
            'Aucun passager enregistré',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Enregistrez vos proches pour réserver plus vite.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.gray),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddEditDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Ajouter un passager'),
          ),
        ],
      ),
    );
  }

  Widget _buildPassengerCard(Map<String, dynamic> p) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gray.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: AppColors.primary.withValues(alpha: 0.1),
          child: Text(
            '${p['first_name'][0]}${p['last_name'][0]}',
            style: const TextStyle(
                color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text('${p['first_name']} ${p['last_name']}',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (p['phone_number'] != null && p['phone_number'].isNotEmpty)
              Text(p['phone_number']),
            if (p['id_number'] != null && p['id_number'].isNotEmpty)
              Text('${p['id_type']}: ${p['id_number']}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, size: 20, color: AppColors.primary),
              onPressed: () => _showAddEditDialog(p),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 20, color: AppColors.error),
              onPressed: () => _deletePassenger(p['id']),
            ),
          ],
        ),
      ),
    );
  }
}

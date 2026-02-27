import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../config/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _referralController = TextEditingController();
  final _securityA1Controller = TextEditingController();
  final _securityA2Controller = TextEditingController();

  String? _securityQ1;
  String? _securityQ2;
  bool _isLoading = false;
  bool _obscurePassword = true;

  final List<String> _questions = [
    "Quel est le nom de votre premier animal de compagnie ?",
    "Dans quelle ville êtes-vous né(e) ?",
    "Quel est le nom de jeune fille de votre mère ?",
    "Quel était le nom de votre premier professeur ?",
    "Quel est votre plat préféré ?",
  ];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _referralController.dispose();
    _securityA1Controller.dispose();
    _securityA2Controller.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_securityQ1 == null || _securityQ2 == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez choisir les deux questions de sécurité')),
      );
      return;
    }

    if (_securityQ1 == _securityQ2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Veuillez choisir deux questions différentes')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final data = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'phoneNumber': _phoneController.text.trim(),
        'password': _passwordController.text,
        'referralCode': _referralController.text.trim().toUpperCase(),
        'securityQ1': _securityQ1,
        'securityA1': _securityA1Controller.text.trim(),
        'securityQ2': _securityQ2,
        'securityA2': _securityA2Controller.text.trim(),
      };

      final response =
          await ref.read(apiServiceProvider).registerWithPassword(data);

      await ref.read(apiServiceProvider).setToken(response['token']);
      ref.read(currentUserProvider.notifier).state = response['user'];

      // Save phone number for next time
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('saved_phone', _phoneController.text.trim());

      if (mounted) context.go('/home');
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Erreur: ${error.toString()}'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Créer un compte')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Inscription', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text('Remplissez les informations ci-dessous',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                            labelText: 'Prénom',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12))),
                        validator: (v) => v!.isEmpty ? 'Requis' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                            labelText: 'Nom',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12))),
                        validator: (v) => v!.isEmpty ? 'Requis' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Numéro de téléphone',
                    prefixText: '+226 ',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) =>
                      v!.length < 6 ? 'Minimum 6 caractères' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _referralController,
                  decoration: InputDecoration(
                    labelText: 'Code de parrainage (Optionnel)',
                    prefixIcon: const Icon(Icons.card_giftcard),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                Text('Questions de sécurité', style: AppTextStyles.h3),
                const SizedBox(height: 8),
                Text(
                    'En cas d\'oubli de mot de passe, ces questions vous permettront de le réinitialiser.',
                    style: AppTextStyles.caption.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant)),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _securityQ1,
                  isExpanded: true,
                  decoration: InputDecoration(
                      labelText: 'Question 1',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                  items: _questions
                      .map((q) => DropdownMenuItem(
                          value: q,
                          child: Text(q,
                              maxLines: 2, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (val) => setState(() => _securityQ1 = val),
                  validator: (v) =>
                      v == null ? 'Veuillez choisir une question' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _securityA1Controller,
                  decoration: InputDecoration(
                      labelText: 'Réponse 1',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _securityQ2,
                  isExpanded: true,
                  decoration: InputDecoration(
                      labelText: 'Question 2',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                  items: _questions
                      .map((q) => DropdownMenuItem(
                          value: q,
                          child: Text(q,
                              maxLines: 2, overflow: TextOverflow.ellipsis)))
                      .toList(),
                  onChanged: (val) => setState(() => _securityQ2 = val),
                  validator: (v) =>
                      v == null ? 'Veuillez choisir une question' : null,
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _securityA2Controller,
                  decoration: InputDecoration(
                      labelText: 'Réponse 2',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                  validator: (v) => v!.isEmpty ? 'Requis' : null,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                        : const Text('S\'inscrire',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text("Vous avez déjà un compte ? "),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: const Text('Se connecter'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

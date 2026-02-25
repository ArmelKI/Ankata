import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_providers.dart';
import '../../config/app_theme.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _phoneController = TextEditingController();
  final _securityA1Controller = TextEditingController();
  final _securityA2Controller = TextEditingController();
  final _newPasswordController = TextEditingController();

  String? _q1;
  String? _q2;
  bool _isLoading = false;
  bool _obscurePassword = true;
  int _step = 1; // 1: Enter phone, 2: Answer questions & set password

  @override
  void dispose() {
    _phoneController.dispose();
    _securityA1Controller.dispose();
    _securityA2Controller.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchQuestions() async {
    final phone = _phoneController.text.trim();
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez entrer votre numéro.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res =
          await ref.read(apiServiceProvider).getSecurityQuestions(phone);
      setState(() {
        _q1 = res['securityQ1'];
        _q2 = res['securityQ2'];
        _step = 2;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resetPassword() async {
    final phone = _phoneController.text.trim();
    final a1 = _securityA1Controller.text.trim();
    final a2 = _securityA2Controller.text.trim();
    final pass = _newPasswordController.text;

    if (a1.isEmpty || a2.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Veuillez remplir tous les champs.')));
      return;
    }

    if (pass.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe trop court.')));
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ref.read(apiServiceProvider).resetPassword({
        'phoneNumber': phone,
        'securityA1': a1,
        'securityA2': a2,
        'newPassword': pass,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(res['message'] ?? 'Réinitialisation réussie'),
            backgroundColor: AppColors.success));
        context.go('/phone-auth'); // Return to login
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppColors.error));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mot de passe oublié')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Récupération', style: AppTextStyles.h2),
              const SizedBox(height: 8),
              Text(
                  _step == 1
                      ? 'Entrez votre numéro pour récupérer vos questions de sécurité.'
                      : 'Répondez aux questions pour définir un nouveau mot de passe.',
                  style:
                      AppTextStyles.bodyMedium.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
              const SizedBox(height: 24),
              if (_step == 1) ...[
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Numéro de téléphone',
                    prefixText: '+226 ',
                    prefixIcon: const Icon(Icons.phone),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _fetchQuestions,
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
                        : const Text('Continuer',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ],
              if (_step == 2) ...[
                Text(_q1 ?? '',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _securityA1Controller,
                  decoration: InputDecoration(
                      labelText: 'Réponse 1',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 16),
                Text(_q2 ?? '',
                    style: AppTextStyles.bodyMedium
                        .copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                TextField(
                  controller: _securityA2Controller,
                  decoration: InputDecoration(
                      labelText: 'Réponse 2',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12))),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _newPasswordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
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
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _resetPassword,
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
                        : const Text('Réinitialiser',
                            style:
                                TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

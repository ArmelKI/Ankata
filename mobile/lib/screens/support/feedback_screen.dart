import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../providers/app_providers.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import '../../services/xp_service.dart';

class FeedbackScreen extends ConsumerStatefulWidget {
  const FeedbackScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'suggestion';
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>> _getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return {
          'platform': 'android',
          'version': androidInfo.version.release,
          'model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return {
          'platform': 'ios',
          'version': iosInfo.systemVersion,
          'model': iosInfo.model,
          'name': iosInfo.name,
        };
      }
    } catch (e) {
      debugPrint('Error getting device info: $e');
    }
    return {'platform': Platform.operatingSystem};
  }

  Future<void> _submitFeedback() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final apiService = ref.read(apiServiceProvider);
      final deviceInfo = await _getDeviceInfo();

      await apiService.submitFeedback(
        type: _type,
        subject: _subjectController.text,
        message: _messageController.text,
        deviceInfo: deviceInfo,
      );

      // Award XP for feedback
      final xpAmount = XPService.xpActions['review'] ?? 5;
      await XPService.addXP(xpAmount, reason: 'Feedback envoyé');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Merci ! Votre retour a été envoyé (+ $xpAmount XP)'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur : ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        title: const Text('Support & Feedback'),
        elevation: 0,
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Comment pouvons-nous vous aider ?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Signalez un problème ou suggérez une amélioration pour nous aider à rendre Ankata encore meilleur.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('Nature du retour', style: AppTextStyles.bodyMedium),
              const SizedBox(height: AppSpacing.xs),
              DropdownButtonFormField<String>(
                value: _type,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'suggestion', child: Text('Suggestion / Idée')),
                  DropdownMenuItem(
                      value: 'bug', child: Text('Signalement de bug')),
                  DropdownMenuItem(value: 'question', child: Text('Question')),
                  DropdownMenuItem(value: 'other', child: Text('Autre')),
                ],
                onChanged: (value) => setState(() => _type = value!),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Sujet',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un sujet';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _messageController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  hintText: 'Détaillez votre demande ici...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre message';
                  }
                  if (value.length < 10) {
                    return 'Le message est trop court';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitFeedback,
                  style: ElevatedButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Envoyer le retour'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

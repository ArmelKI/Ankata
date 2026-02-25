import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  State<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends State<FeedbackScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  int _rating = 5;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Merci pour votre feedback !'),
        backgroundColor: AppColors.success,
      ),
    );

    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        title: Text('Feedback', style: AppTextStyles.h3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Votre note', style: AppTextStyles.bodyLarge),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: List.generate(5, (index) {
                  final value = index + 1;
                  return IconButton(
                    onPressed: () => setState(() => _rating = value),
                    icon: Icon(
                      value <= _rating ? Icons.star : Icons.star_border,
                      color: AppColors.star,
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                controller: _messageController,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Votre message',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Merci de remplir votre message';
                  }
                  return null;
                },
              ),
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  child: const Text('Envoyer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

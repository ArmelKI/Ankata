import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class LegalScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalScreen({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        title: Text(title, style: AppTextStyles.h3),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Text(
          content,
          style: AppTextStyles.bodyMedium,
        ),
      ),
    );
  }
}

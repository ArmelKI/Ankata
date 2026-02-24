import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGray,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 1,
        title: Text('FAQ', style: AppTextStyles.h3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: const [
          _FaqItem(
            question: 'Comment reserver un trajet ?',
            answer: 'Choisis la ville de depart, la destination, puis confirme ton trajet.',
          ),
          _FaqItem(
            question: 'Puis-je annuler gratuitement ?',
            answer: 'Oui, jusqu\'a 36h avant le depart. Apres, 500 FCFA de frais.',
          ),
          _FaqItem(
            question: 'Comment fonctionne SOTRACO ?',
            answer: 'SOTRACO est le transport urbain. Lignes, arrets et abonnements sont geres ici.',
          ),
        ],
      ),
    );
  }
}

class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({
    required this.question,
    required this.answer,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ExpansionTile(
        title: Text(question, style: AppTextStyles.bodyMedium),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Text(answer, style: AppTextStyles.bodySmall.copyWith(color: AppColors.gray)),
          ),
        ],
      ),
    );
  }
}

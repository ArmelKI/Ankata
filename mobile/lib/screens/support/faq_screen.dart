import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 1,
        title: Text('FAQ', style: AppTextStyles.h3),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: const [
          _FaqItem(
            question: 'Comment réserver un trajet interurbain ?',
            answer:
                'Depuis l\'écran d\'accueil, entrez votre ville de départ, la destination, la date prévue de votre voyage et le nombre de passagers. Parcourez ensuite les offres des différentes compagnies, choisissez celle qui vous convient, et confirmez votre réservation en payant en ligne.',
          ),
          _FaqItem(
            question: 'Quels sont les moyens de paiement acceptés ?',
            answer:
                'Vous pouvez payer vos billets de manière sécurisée via Orange Money, Moov Money, ou Coris Money. Le paiement est 100% numérique pour vous éviter les files d\'attente.',
          ),
          _FaqItem(
            question: 'Puis-je annuler ou modifier mon billet ?',
            answer:
                'L\'annulation est gratuite jusqu\'à 36 heures avant le départ prévu. Passé ce délai, des frais d\'annulation de 500 FCFA seront appliqués. Les modifications directes de billets ne sont pas encore supportées: il est préférable d\'annuler le billet et d\'en réserver un nouveau.',
          ),
          _FaqItem(
            question: 'Comment fonctionne le transport urbain SOTRACO ?',
            answer:
                'La section SOTRACO de l\'application vous permet de voir les lignes de bus urbains de Ouagadougou, de localiser les arrêts à proximité grâce à la carte interactive, et de consulter les horaires. À l\'avenir, vous pourrez également acheter vos abonnements SOTRACO directement.',
          ),
          _FaqItem(
            question: 'Où retrouver mes billets réservés ?',
            answer:
                'Tous vos billets sont centralisés dans l\'onglet "Mes Billets" situé dans la barre de navigation inférieure. Vous y trouverez vos billets à venir ainsi que l\'historique de vos trajets passés. Vous pouvez également les télécharger au format PDF.',
          ),
          _FaqItem(
            question: 'Faut-il imprimer le billet ?',
            answer:
                'Non, ce n\'est pas obligatoire. Il suffit de présenter le QR code de votre billet électronique depuis votre téléphone au personnel de la compagnie lors de l\'embarquement.',
          ),
          _FaqItem(
            question: 'Combien de bagages sont autorisés ?',
            answer:
                'Chaque compagnie a sa propre politique de bagages. En général, un bagage à main et un bagage en soute sont inclus. Tout excédent peut faire l\'objet de frais supplémentaires (par exemple 100 FCFA par Kg supplémentaire) à payer à la gare.',
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
            child: Text(answer,
                style: AppTextStyles.bodySmall.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }
}

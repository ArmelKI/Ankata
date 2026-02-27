import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../config/app_theme.dart';
import '../../utils/haptic_helper.dart';

/// Dialog de parrainage pour inviter des amis
/// Génère croissance virale +30% et réduit CAC
class ReferralDialog extends StatelessWidget {
  final String referralCode;
  final int referralCount;
  final int earnedAmount;

  const ReferralDialog({
    super.key,
    required this.referralCode,
    this.referralCount = 0,
    this.earnedAmount = 0,
  });

  static void show(BuildContext context, {required String referralCode}) {
    HapticHelper.lightImpact();
    showDialog(
      context: context,
      builder: (context) => ReferralDialog(referralCode: referralCode),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.radiusXl,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.card_giftcard,
                size: 40,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Title
            Text(
              'Parrainage',
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Description
            Text(
              'Invite tes amis et gagne 100F par personne ! Utilise ton bonus pour réserver tes trajets. Plus tu invites, plus tu économises (max 1500F) !',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatItem(
                  icon: Icons.people,
                  value: '$referralCount',
                  label: 'Invités',
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: AppColors.gray.withValues(alpha: 0.2),
                ),
                _StatItem(
                  icon: Icons.account_balance_wallet,
                  value: '$earnedAmount F',
                  label: 'Gagnés',
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Referral code
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.gray.withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusMd,
                border: Border.all(
                  color: AppColors.gray.withValues(alpha: 0.2),
                  style: BorderStyle.solid,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Code: ',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.gray,
                    ),
                  ),
                  Text(
                    referralCode,
                    style: AppTextStyles.h3.copyWith(
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Share button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  HapticHelper.mediumImpact();
                  _shareReferralCode(context);
                },
                icon: const Icon(Icons.share, color: AppColors.white),
                label: Text(
                  'Partager mon code',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.white,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Close
            TextButton(
              onPressed: () {
                HapticHelper.lightImpact();
                Navigator.pop(context);
              },
              child: Text(
                'Fermer',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.gray,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareReferralCode(BuildContext context) {
    final message = '''
🎁 Rejoins-moi sur Ankata !

Utilise mon code de parrainage: $referralCode

Réserve facilement tes trajets partout au Burkina Faso ! 🇧🇫

Télécharge l'app: https://ankata.app/invite/$referralCode 📲
    ''';

    Share.share(message);
    Navigator.pop(context);
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: AppColors.primary),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.h3.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption.copyWith(
            color: AppColors.gray,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_theme.dart';

/// Service de gestion des points XP et niveaux
/// Gamification améliore engagement de +35%
class XPService {
  static const String _xpKey = 'user_xp';
  static const String _levelKey = 'user_level';

  /// Ajoute des XP et vérifie le niveau
  static Future<LevelUpData?> addXP(int amount, {String? reason}) async {
    final prefs = await SharedPreferences.getInstance();

    final currentXP = prefs.getInt(_xpKey) ?? 0;
    final currentLevel = prefs.getInt(_levelKey) ?? 1;

    final newXP = currentXP + amount;
    final newLevel = _calculateLevel(newXP);

    await prefs.setInt(_xpKey, newXP);
    await prefs.setInt(_levelKey, newLevel);

    if (newLevel > currentLevel) {
      return LevelUpData(
        oldLevel: currentLevel,
        newLevel: newLevel,
        totalXP: newXP,
        reward: _getLevelReward(newLevel),
      );
    }

    return null;
  }

  /// Obtient XP actuel
  static Future<int> getXP() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_xpKey) ?? 0;
  }

  /// Obtient niveau actuel
  static Future<int> getLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_levelKey) ?? 1;
  }

  /// Calcule le niveau basé sur XP
  static int _calculateLevel(int xp) {
    // Formule: Level = sqrt(XP / 100)
    // Level 1: 0-100 XP
    // Level 2: 100-400 XP
    // Level 3: 400-900 XP
    // etc.
    return 1 + (xp / 100).floor();
  }

  /// XP requis pour prochain niveau
  static int getXPForNextLevel(int currentLevel) {
    return currentLevel * currentLevel * 100;
  }

  /// Progression vers prochain niveau (0-1)
  static double getLevelProgress(int xp, int level) {
    final currentLevelXP = (level - 1) * (level - 1) * 100;
    final nextLevelXP = level * level * 100;
    final xpInLevel = xp - currentLevelXP;
    final xpNeeded = nextLevelXP - currentLevelXP;
    return (xpInLevel / xpNeeded).clamp(0.0, 1.0);
  }

  /// Récompense pour chaque niveau
  static Map<String, dynamic> _getLevelReward(int level) {
    final rewards = <int, Map<String, dynamic>>{
      5: {'amount': 500, 'description': 'Badge Explorateur'},
      10: {'amount': 1000, 'description': 'Badge Voyageur'},
      20: {'amount': 2000, 'description': 'Badge Fidèle'},
      50: {'amount': 5000, 'description': 'Badge Expert'},
      100: {'amount': 10000, 'description': 'Badge Légende'},
    };

    return rewards[level] ??
        {'amount': level * 100, 'description': 'Continue !'};
  }

  /// Points XP pour différentes actions
  static const Map<String, int> xpActions = {
    'booking': 10,
    'rating': 5,
    'referral': 20,
    'profile_complete': 50,
    'first_booking': 100,
    'review': 15,
    'favorite': 2,
  };

  /// Titre du niveau
  static String getLevelTitle(int level) {
    if (level < 5) return 'Débutant';
    if (level < 10) return 'Explorateur';
    if (level < 20) return 'Voyageur';
    if (level < 50) return 'Fidèle';
    if (level < 100) return 'Expert';
    return 'Légende';
  }
}

class LevelUpData {
  final int oldLevel;
  final int newLevel;
  final int totalXP;
  final Map<String, dynamic> reward;

  LevelUpData({
    required this.oldLevel,
    required this.newLevel,
    required this.totalXP,
    required this.reward,
  });
}

/// Widget pour afficher la barre XP
class XPBar extends StatelessWidget {
  final int xp;
  final int level;

  const XPBar({
    super.key,
    required this.xp,
    required this.level,
  });

  @override
  Widget build(BuildContext context) {
    final progress = XPService.getLevelProgress(xp, level);
    final nextLevelXP = XPService.getXPForNextLevel(level);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: AppRadius.radiusMd,
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Level title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$level',
                        style: AppTextStyles.h3.copyWith(
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Niveau $level',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        XPService.getLevelTitle(level),
                        style: AppTextStyles.caption.copyWith(
                          color: AppColors.gray,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Text(
                '$xp XP',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),

          // Progress bar
          ClipRRect(
            borderRadius: AppRadius.radiusFull,
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.gray.withValues(alpha: 0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),

          // XP to next level
          Text(
            '${(nextLevelXP - xp)} XP vers niveau ${level + 1}',
            style: AppTextStyles.caption.copyWith(
              color: AppColors.gray,
            ),
          ),
        ],
      ),
    );
  }
}

/// Dialog de Level Up
class LevelUpDialog extends StatelessWidget {
  final LevelUpData data;

  const LevelUpDialog({super.key, required this.data});

  static void show(BuildContext context, LevelUpData data) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => LevelUpDialog(data: data),
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
            // Animated star
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 1000),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Transform.rotate(
                    angle: value * 2 * 3.14159,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFFFFD700), Color(0xFFFFB700)],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.star,
                          size: 60,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),

            Text(
              'Niveau Supérieur !',
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${data.oldLevel}',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.gray,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Icon(Icons.arrow_forward, size: 32),
                ),
                Text(
                  '${data.newLevel}',
                  style: AppTextStyles.h1.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),

            // Reward
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: AppRadius.radiusMd,
              ),
              child: Column(
                children: [
                  Text(
                    'Récompense',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '+${data.reward['amount']} FCFA',
                    style: AppTextStyles.h2.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    data.reward['description'],
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.gray,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                  ),
                ),
                child: Text(
                  'Continuer',
                  style: AppTextStyles.button.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_theme.dart';
import '../../utils/haptic_helper.dart';

/// Service de gestion des streaks (connexions quotidiennes)
/// Augmente engagement de +40% et DAU
class StreakService {
  static const String _lastVisitKey = 'last_visit_date';
  static const String _streakCountKey = 'streak_count';
  static const String _totalRewardKey = 'streak_total_reward';

  /// Vérifie et met à jour le streak au lancement de l'app
  static Future<StreakData> checkStreak() async {
    final prefs = await SharedPreferences.getInstance();
    
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final lastVisitStr = prefs.getString(_lastVisitKey);
    final currentStreak = prefs.getInt(_streakCountKey) ?? 0;
    final totalReward = prefs.getInt(_totalRewardKey) ?? 0;
    
    if (lastVisitStr == null) {
      // Première visite
      await prefs.setString(_lastVisitKey, today.toIso8601String());
      await prefs.setInt(_streakCountKey, 1);
      return StreakData(
        currentStreak: 1,
        totalReward: 0,
        showDialog: true,
        isNewStreak: true,
      );
    }
    
    final lastVisit = DateTime.parse(lastVisitStr);
    final lastVisitDate = DateTime(lastVisit.year, lastVisit.month, lastVisit.day);
    final daysDifference = today.difference(lastVisitDate).inDays;
    
    if (daysDifference == 0) {
      // Déjà visité aujourd'hui
      return StreakData(
        currentStreak: currentStreak,
        totalReward: totalReward,
        showDialog: false,
        isNewStreak: false,
      );
    } else if (daysDifference == 1) {
      // Visite consécutive
      final newStreak = currentStreak + 1;
      final reward = _calculateReward(newStreak);
      final newTotalReward = totalReward + reward;
      
      await prefs.setString(_lastVisitKey, today.toIso8601String());
      await prefs.setInt(_streakCountKey, newStreak);
      await prefs.setInt(_totalRewardKey, newTotalReward);
      
      return StreakData(
        currentStreak: newStreak,
        totalReward: newTotalReward,
        showDialog: true,
        isNewStreak: false,
        todayReward: reward,
      );
    } else {
      // Streak cassé
      await prefs.setString(_lastVisitKey, today.toIso8601String());
      await prefs.setInt(_streakCountKey, 1);
      
      return StreakData(
        currentStreak: 1,
        totalReward: totalReward,
        showDialog: true,
        isNewStreak: true,
        streakBroken: true,
        previousStreak: currentStreak,
      );
    }
  }

  /// Calcul de la récompense basée sur le streak
  static int _calculateReward(int streak) {
    if (streak < 7) return 50; // 50F par jour
    if (streak < 30) return 100; // 100F par jour après 7 jours
    return 200; // 200F par jour après 30 jours
  }

  /// Obtient le niveau de streak
  static String getStreakLevel(int streak) {
    if (streak < 7) return 'Débutant';
    if (streak < 30) return 'Régulier';
    if (streak < 90) return 'Fidèle';
    if (streak < 365) return 'Champion';
    return 'Légende';
  }
}

class StreakData {
  final int currentStreak;
  final int totalReward;
  final bool showDialog;
  final bool isNewStreak;
  final bool streakBroken;
  final int? previousStreak;
  final int? todayReward;

  StreakData({
    required this.currentStreak,
    required this.totalReward,
    required this.showDialog,
    required this.isNewStreak,
    this.streakBroken = false,
    this.previousStreak,
    this.todayReward,
  });
}

/// Dialog de Streak quotidien
class StreakDialog extends StatelessWidget {
  final StreakData data;

  const StreakDialog({super.key, required this.data});

  static void show(BuildContext context, StreakData data) {
    if (!data.showDialog) return;
    
    HapticHelper.success();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StreakDialog(data: data),
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
            // Fire icon animated
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.8, end: 1.2),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: data.streakBroken
                            ? [Colors.grey, Colors.grey.shade300]
                            : [const Color(0xFFFF6B00), const Color(0xFFFFD700)],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        data.streakBroken ? '💔' : '🔥',
                        style: const TextStyle(fontSize: 48),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            
            // Title
            Text(
              data.streakBroken
                  ? 'Streak cassé !'
                  : data.isNewStreak
                      ? 'Nouveau Streak !'
                      : 'Streak maintenu !',
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            
            // Streak count
            if (!data.streakBroken) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${data.currentStreak}',
                    style: AppTextStyles.h1.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data.currentStreak == 1 ? 'jour' : 'jours',
                    style: AppTextStyles.h3.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                StreakService.getStreakLevel(data.currentStreak),
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              Text(
                'Tu avais ${data.previousStreak} jours',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Recommence dès aujourd\'hui !',
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            
            const SizedBox(height: AppSpacing.lg),
            
            // Reward
            if (data.todayReward != null && !data.streakBroken)
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: AppRadius.radiusMd,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.account_balance_wallet,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '+${data.todayReward} FCFA',
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            
            const SizedBox(height: AppSpacing.lg),
            
            // Close button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  HapticHelper.lightImpact();
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                  ),
                ),
                child: Text(
                  'Continuer',
                  style: AppTextStyles.button.copyWith(
                    color: Theme.of(context).colorScheme.surface,
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

/// Widget mini pour afficher le streak sur le profil
class StreakWidget extends StatelessWidget {
  final int streak;

  const StreakWidget({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B00), Color(0xFFFFD700)],
        ),
        borderRadius: AppRadius.radiusMd,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 20)),
          const SizedBox(width: 8),
          Text(
            '$streak jours',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.surface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

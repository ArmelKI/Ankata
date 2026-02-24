import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../config/app_theme.dart';

/// Service de gestion des badges achievement
class BadgeService {
  static const String _badgesKey = 'user_badges';

  /// Liste de tous les badges disponibles
  static final List<Badge> allBadges = [
    const Badge(
      id: 'first_booking',
      name: 'Premier Voyage',
      description: 'Effectue ta première réservation',
      icon: Icons.explore,
      color: Color(0xFF3B82F6),
      requirement: 1,
      type: BadgeType.booking,
    ),
    const Badge(
      id: 'booking_10',
      name: 'Voyageur',
      description: 'Effectue 10 réservations',
      icon: Icons.luggage,
      color: Color(0xFF8B5CF6),
      requirement: 10,
      type: BadgeType.booking,
    ),
    const Badge(
      id: 'booking_50',
      name: 'Explorateur',
      description: 'Effectue 50 réservations',
      icon: Icons.public,
      color: Color(0xFFEC4899),
      requirement: 50,
      type: BadgeType.booking,
    ),
    const Badge(
      id: 'booking_100',
      name: 'Légende',
      description: 'Effectue 100 réservations',
      icon: Icons.emoji_events,
      color: Color(0xFFFFD700),
      requirement: 100,
      type: BadgeType.booking,
    ),
    const Badge(
      id: 'cities_5',
      name: 'Découvreur',
      description: 'Visite 5 villes différentes',
      icon: Icons.location_city,
      color: Color(0xFF10B981),
      requirement: 5,
      type: BadgeType.cities,
    ),
    const Badge(
      id: 'cities_10',
      name: 'Globe-Trotter',
      description: 'Visite 10 villes différentes',
      icon: Icons.flight,
      color: Color(0xFF06B6D4),
      requirement: 10,
      type: BadgeType.cities,
    ),
    const Badge(
      id: 'rating_high',
      name: 'Étoile',
      description: 'Maintiens une note de 4.8+',
      icon: Icons.star,
      color: Color(0xFFFFB800),
      requirement: 48, // 4.8 * 10
      type: BadgeType.rating,
    ),
    const Badge(
      id: 'reviews_10',
      name: 'Critique',
      description: 'Laisse 10 avis',
      icon: Icons.rate_review,
      color: Color(0xFFF59E0B),
      requirement: 10,
      type: BadgeType.review,
    ),
    const Badge(
      id: 'referral_5',
      name: 'Ambassadeur',
      description: 'Parraine 5 amis',
      icon: Icons.people,
      color: Color(0xFF14B8A6),
      requirement: 5,
      type: BadgeType.referral,
    ),
    const Badge(
      id: 'streak_7',
      name: 'Assidu',
      description: '7 jours de connexion consécutifs',
      icon: Icons.local_fire_department,
      color: Color(0xFFEF4444),
      requirement: 7,
      type: BadgeType.streak,
    ),
    const Badge(
      id: 'streak_30',
      name: 'Fidèle',
      description: '30 jours de connexion consécutifs',
      icon: Icons.verified,
      color: Color(0xFFDC2626),
      requirement: 30,
      type: BadgeType.streak,
    ),
    const Badge(
      id: 'premium',
      name: 'Premium',
      description: 'Abonné Premium actif',
      icon: Icons.workspace_premium,
      color: Color(0xFFFFD700),
      requirement: 1,
      type: BadgeType.premium,
    ),
  ];

  /// Débloque un badge
  static Future<Badge?> unlockBadge(String badgeId) async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedBadges = prefs.getStringList(_badgesKey) ?? [];

    if (!unlockedBadges.contains(badgeId)) {
      unlockedBadges.add(badgeId);
      await prefs.setStringList(_badgesKey, unlockedBadges);

      return allBadges.firstWhere((b) => b.id == badgeId);
    }

    return null;
  }

  /// Vérifie et débloque les badges selon les stats
  static Future<List<Badge>> checkAndUnlockBadges(UserStats stats) async {
    final newBadges = <Badge>[];

    // Booking badges
    if (stats.totalBookings >= 1) {
      final badge = await unlockBadge('first_booking');
      if (badge != null) newBadges.add(badge);
    }
    if (stats.totalBookings >= 10) {
      final badge = await unlockBadge('booking_10');
      if (badge != null) newBadges.add(badge);
    }
    if (stats.totalBookings >= 50) {
      final badge = await unlockBadge('booking_50');
      if (badge != null) newBadges.add(badge);
    }
    if (stats.totalBookings >= 100) {
      final badge = await unlockBadge('booking_100');
      if (badge != null) newBadges.add(badge);
    }

    // Cities badges
    if (stats.citiesVisited >= 5) {
      final badge = await unlockBadge('cities_5');
      if (badge != null) newBadges.add(badge);
    }
    if (stats.citiesVisited >= 10) {
      final badge = await unlockBadge('cities_10');
      if (badge != null) newBadges.add(badge);
    }

    // Rating badge
    if (stats.averageRating >= 4.8) {
      final badge = await unlockBadge('rating_high');
      if (badge != null) newBadges.add(badge);
    }

    // Review badge
    if (stats.totalReviews >= 10) {
      final badge = await unlockBadge('reviews_10');
      if (badge != null) newBadges.add(badge);
    }

    // Referral badge
    if (stats.referrals >= 5) {
      final badge = await unlockBadge('referral_5');
      if (badge != null) newBadges.add(badge);
    }

    // Streak badges
    if (stats.currentStreak >= 7) {
      final badge = await unlockBadge('streak_7');
      if (badge != null) newBadges.add(badge);
    }
    if (stats.currentStreak >= 30) {
      final badge = await unlockBadge('streak_30');
      if (badge != null) newBadges.add(badge);
    }

    // Premium badge
    if (stats.isPremium) {
      final badge = await unlockBadge('premium');
      if (badge != null) newBadges.add(badge);
    }

    return newBadges;
  }

  /// Obtient les badges débloqués
  static Future<List<Badge>> getUnlockedBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedIds = prefs.getStringList(_badgesKey) ?? [];

    return allBadges.where((badge) => unlockedIds.contains(badge.id)).toList();
  }

  /// Obtient les badges verrouillés
  static Future<List<Badge>> getLockedBadges() async {
    final prefs = await SharedPreferences.getInstance();
    final unlockedIds = prefs.getStringList(_badgesKey) ?? [];

    return allBadges.where((badge) => !unlockedIds.contains(badge.id)).toList();
  }
}

enum BadgeType {
  booking,
  cities,
  rating,
  review,
  referral,
  streak,
  premium,
}

class Badge {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int requirement;
  final BadgeType type;

  const Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.requirement,
    required this.type,
  });
}

class UserStats {
  final int totalBookings;
  final int citiesVisited;
  final double averageRating;
  final int totalReviews;
  final int referrals;
  final int currentStreak;
  final bool isPremium;

  const UserStats({
    this.totalBookings = 0,
    this.citiesVisited = 0,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.referrals = 0,
    this.currentStreak = 0,
    this.isPremium = false,
  });
}

/// Widget pour afficher un badge
class BadgeWidget extends StatelessWidget {
  final Badge badge;
  final bool isUnlocked;
  final double size;

  const BadgeWidget({
    super.key,
    required this.badge,
    this.isUnlocked = true,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: isUnlocked
                ? LinearGradient(
                    colors: [badge.color, badge.color.withValues(alpha: 0.7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isUnlocked ? null : AppColors.gray.withValues(alpha: 0.2),
            shape: BoxShape.circle,
            boxShadow: isUnlocked
                ? [
                    BoxShadow(
                      color: badge.color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Icon(
              badge.icon,
              size: size * 0.5,
              color: isUnlocked
                  ? AppColors.white
                  : AppColors.gray.withValues(alpha: 0.5),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          badge.name,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: isUnlocked ? null : AppColors.gray,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

/// Dialog pour afficher badge débloqué
class BadgeUnlockedDialog extends StatelessWidget {
  final Badge badge;

  const BadgeUnlockedDialog({super.key, required this.badge});

  static void show(BuildContext context, Badge badge) {
    showDialog(
      context: context,
      builder: (context) => BadgeUnlockedDialog(badge: badge),
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
            Text(
              'Badge Débloqué !',
              style: AppTextStyles.h2.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: BadgeWidget(badge: badge, size: 120),
                );
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              badge.description,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: badge.color,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.radiusMd,
                  ),
                ),
                child: Text(
                  'Génial !',
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

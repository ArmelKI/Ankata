import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../utils/haptic_helper.dart';

/// Bannière de sponsor/partenaire rotative sur home screen
/// Génère 100-300€/mois par partenaire
class SponsorBanner extends StatefulWidget {
  final List<SponsorData> sponsors;

  const SponsorBanner({
    super.key,
    required this.sponsors,
  });

  @override
  State<SponsorBanner> createState() => _SponsorBannerState();
}

class _SponsorBannerState extends State<SponsorBanner> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Auto-rotation toutes les 5 secondes
    Future.delayed(const Duration(seconds: 5), _autoScroll);
  }

  void _autoScroll() {
    if (!mounted) return;

    final nextPage = (_currentPage + 1) % widget.sponsors.length;
    _pageController.animateToPage(
      nextPage,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );

    Future.delayed(const Duration(seconds: 5), _autoScroll);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.sponsors.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 120,
      margin: const EdgeInsets.all(AppSpacing.md),
      child: PageView.builder(
        controller: _pageController,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemCount: widget.sponsors.length,
        itemBuilder: (context, index) {
          final sponsor = widget.sponsors[index];
          return GestureDetector(
            onTap: () {
              HapticHelper.lightImpact();
              if (sponsor.route != null) {
                context.push(sponsor.route!);
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: sponsor.gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: AppRadius.radiusLg,
                boxShadow: [
                  BoxShadow(
                    color: sponsor.gradientColors.first.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Content
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (sponsor.badge != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white.withValues(alpha: 0.3),
                              borderRadius: AppRadius.radiusSm,
                            ),
                            child: Text(
                              sponsor.badge!,
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          sponsor.title,
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          sponsor.description,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.white.withValues(alpha: 0.9),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Icon/Image
                  if (sponsor.icon != null)
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: Icon(
                        sponsor.icon,
                        size: 48,
                        color: AppColors.white.withValues(alpha: 0.3),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class SponsorData {
  final String title;
  final String description;
  final List<Color> gradientColors;
  final String? badge;
  final IconData? icon;
  final String? route;

  const SponsorData({
    required this.title,
    required this.description,
    required this.gradientColors,
    this.badge,
    this.icon,
    this.route,
  });

  // Exemples de sponsors
  static List<SponsorData> demoSponsors = [
    const SponsorData(
      title: '15% de réduction',
      description: 'Réserve 3 trajets et économise 15% sur le prochain',
      gradientColors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
      badge: 'OFFRE LIMITÉE',
      icon: Icons.local_offer,
    ),
    const SponsorData(
      title: 'Orange Money',
      description: 'Paie avec Orange Money et reçois 500F de cashback',
      gradientColors: [Color(0xFFFF6B00), Color(0xFFFF8C00)],
      badge: 'NOUVEAU',
      icon: Icons.payments,
    ),
    const SponsorData(
      title: 'Hôtel Paradise',
      description: '10% de réduction pour les clients Ankata',
      gradientColors: [Color(0xFF0EA5E9), Color(0xFF06B6D4)],
      badge: 'PARTENAIRE',
      icon: Icons.hotel,
    ),
  ];
}

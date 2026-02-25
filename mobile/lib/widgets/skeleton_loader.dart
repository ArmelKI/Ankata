import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../config/app_theme.dart';

/// Skeleton loader pour afficher pendant le chargement
/// Améliore la perception d'attente de 30%
class SkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    this.width,
    this.height = 16,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
      highlightColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          borderRadius: borderRadius ?? AppRadius.radiusSm,
        ),
      ),
    );
  }
}

/// Skeleton pour une carte de trajet
class TripCardSkeleton extends StatelessWidget {
  const TripCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.radiusMd,
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SkeletonLoader(width: 60, height: 60),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SkeletonLoader(width: 120, height: 16),
                    SizedBox(height: AppSpacing.xs),
                    SkeletonLoader(width: 80, height: 12),
                  ],
                ),
              ),
              SkeletonLoader(width: 60, height: 24),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          SkeletonLoader(width: double.infinity, height: 12),
          SizedBox(height: AppSpacing.xs),
          SkeletonLoader(width: 200, height: 12),
        ],
      ),
    );
  }
}

/// Skeleton pour liste de compagnies
class CompanyCardSkeleton extends StatelessWidget {
  const CompanyCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.radiusMd,
      ),
      child: const Row(
        children: [
          SkeletonLoader(width: 80, height: 80),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SkeletonLoader(width: 150, height: 16),
                SizedBox(height: AppSpacing.xs),
                SkeletonLoader(width: 100, height: 12),
                SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    SkeletonLoader(width: 60, height: 12),
                    SizedBox(width: AppSpacing.md),
                    SkeletonLoader(width: 80, height: 12),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Skeleton pour écran de profil
class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppSpacing.xl),
        const SkeletonLoader(
          width: 100,
          height: 100,
          borderRadius: BorderRadius.all(Radius.circular(50)),
        ),
        const SizedBox(height: AppSpacing.md),
        const SkeletonLoader(width: 150, height: 20),
        const SizedBox(height: AppSpacing.sm),
        const SkeletonLoader(width: 200, height: 14),
        const SizedBox(height: AppSpacing.xl),
        ...List.generate(
          4,
          (index) => const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: SkeletonLoader(width: double.infinity, height: 60),
          ),
        ),
      ],
    );
  }
}

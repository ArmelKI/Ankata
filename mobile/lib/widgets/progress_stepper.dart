import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// Indicateur de progression pour workflow de réservation
/// Recherche → Choix → Passagers → Paiement
class ProgressStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const ProgressStepper({
    super.key,
    required this.currentStep,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.charcoal.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(
          steps.length,
          (index) {
            final isActive = index <= currentStep;
            final isLast = index == steps.length - 1;

            return Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        // Circle indicator
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isActive
                                ? AppColors.primary
                                : AppColors.gray.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isActive
                                  ? AppColors.primary
                                  : AppColors.gray.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: index < currentStep
                                ? const Icon(
                                    Icons.check,
                                    color: AppColors.white,
                                    size: 16,
                                  )
                                : Text(
                                    '${index + 1}',
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: isActive
                                          ? AppColors.white
                                          : AppColors.gray,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        // Step label
                        Text(
                          steps[index],
                          style: AppTextStyles.caption.copyWith(
                            color:
                                isActive ? AppColors.primary : AppColors.gray,
                            fontWeight: index == currentStep
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Line connector
                  if (!isLast)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.only(bottom: 24),
                        color: index < currentStep
                            ? AppColors.primary
                            : AppColors.gray.withValues(alpha: 0.2),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

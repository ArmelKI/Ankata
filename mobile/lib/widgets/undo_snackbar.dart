import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../utils/haptic_helper.dart';

/// Snackbar avec possibilité d'annuler l'action (pattern Undo)
class UndoSnackbar {
  static void show(
    BuildContext context, {
    required String message,
    required VoidCallback onUndo,
    Duration duration = const Duration(seconds: 3),
  }) {
    HapticHelper.lightImpact();

    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.success,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'ANNULER',
        textColor: AppColors.white,
        onPressed: () {
          HapticHelper.mediumImpact();
          onUndo();
        },
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showError(
    BuildContext context, {
    required String message,
    VoidCallback? onRetry,
  }) {
    HapticHelper.error();

    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error, color: AppColors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.error,
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      action: onRetry != null
          ? SnackBarAction(
              label: 'RÉESSAYER',
              textColor: AppColors.white,
              onPressed: () {
                HapticHelper.mediumImpact();
                onRetry();
              },
            )
          : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showSuccess(
    BuildContext context, {
    required String message,
  }) {
    HapticHelper.success();

    final snackBar = SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: AppColors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
            ),
          ),
        ],
      ),
      backgroundColor: AppColors.success,
      duration: const Duration(seconds: 2),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

import 'package:flutter/services.dart';

/// Helper class for haptic feedback
/// Ajoute des vibrations pour améliorer l'expérience tactile
class HapticHelper {
  /// Light impact (touches légères: boutons, checkboxes)
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium impact (actions importantes: soumission, confirmation)
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy impact (actions critiques: paiement, suppression)
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection click (changements de sélection: tabs, radio)
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibration (erreur ou notification importante)
  static Future<void> vibrate() async {
    await HapticFeedback.vibrate();
  }

  /// Success feedback (action réussie)
  static Future<void> success() async {
    await HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// Error feedback (action échouée)
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }
}

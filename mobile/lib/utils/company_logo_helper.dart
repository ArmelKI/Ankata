import 'package:flutter/material.dart';
import '../config/app_constants.dart';
import '../config/app_theme.dart';

/// Helper centralisé pour afficher les logos des compagnies de transport
class CompanyLogoHelper {
  /// Map nom de compagnie → path de l'asset logo
  static const Map<String, String> _logos = {
    'TSR': 'assets/images/tsr_logo.png',
    'STAF': 'assets/images/staf_logo.png',
    'RAHIMO': 'assets/images/rahimo_logo.png',
    'RAKIETA': 'assets/images/rakieta_logo.png',
    'TCV': 'assets/images/tcv_logo.png',
    'SARAMAYA': 'assets/images/saramaya_logo.png',
    'SOTRACO': 'assets/images/sotraco_logo.png',
    'ELITIS EXPRESS': 'assets/images/elitis_logo.png',
    'ELITIS': 'assets/images/elitis_logo.png',
    'CTKE WAYS': 'assets/images/ctke_logo.png',
    'CTKE': 'assets/images/ctke_logo.png',
    'FTS': 'assets/images/fts_logo.png',
  };

  /// Retourne le path du logo pour un nom de compagnie donné
  static String? getLogoPath(String companyName) {
    // Essai exact d'abord
    if (_logos.containsKey(companyName.toUpperCase())) {
      return _logos[companyName.toUpperCase()];
    }
    // Essai partiel
    for (final entry in _logos.entries) {
      if (companyName.toUpperCase().contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  /// Construit un widget logo avec fallback sur initiale + couleur
  static Widget buildLogo(
    String companyName, {
    double size = 60,
    BorderRadius? borderRadius,
    bool showShadow = true,
  }) {
    final logoPath = getLogoPath(companyName);
    final color = CompanyColors.getCompanyColor(companyName);
    final radius = borderRadius ?? BorderRadius.circular(12);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: radius,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: logoPath != null
          ? Image.asset(
              logoPath,
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return _buildFallback(companyName, size, color);
              },
            )
          : _buildFallback(companyName, size, color),
    );
  }

  /// Construit un logo circulaire
  static Widget buildCircleLogo(
    String companyName, {
    double size = 50,
    bool showShadow = true,
  }) {
    final logoPath = getLogoPath(companyName);
    final color = CompanyColors.getCompanyColor(companyName);

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        shape: BoxShape.circle,
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.15),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: logoPath != null
          ? Padding(
              padding: EdgeInsets.all(size * 0.1),
              child: Image.asset(
                logoPath,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return _buildFallback(companyName, size, color);
                },
              ),
            )
          : _buildFallback(companyName, size, color),
    );
  }

  /// Fallback : initiale sur fond coloré
  static Widget _buildFallback(String name, double size, Color color) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Container(
      width: size,
      height: size,
      color: color,
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
          ),
        ),
      ),
    );
  }
}

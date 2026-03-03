import 'package:flutter/material.dart';
import '../services/company_logo_service.dart';

/// Helper centralisé pour afficher les logos des compagnies de transport
class CompanyLogoHelper {
  /// Map nom de compagnie → path de l'asset logo
  static const Map<String, String> _logos = {
    'TSR': 'assets/images/companies/tsr_logo.png',
    'STAF': 'assets/images/companies/staf_logo.png',
    'RAHIMO': 'assets/images/companies/rahimo_logo.png',
    'RAKIETA': 'assets/images/companies/rakieta_logo.png',
    'TCV': 'assets/images/companies/tcv_logo.png',
    'SARAMAYA': 'assets/images/companies/saramaya_logo.png',
    'SOTRACO': 'assets/images/companies/sotraco_logo.png',
    'ELITIS EXPRESS': 'assets/images/companies/elitis_logo.png',
    'ELITIS': 'assets/images/companies/elitis_logo.png',
    'CTKE WAYS': 'assets/images/companies/ctke_logo.png',
    'CTKE': 'assets/images/companies/ctke_logo.png',
    'FTS': 'assets/images/companies/fts_logo.png',
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
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

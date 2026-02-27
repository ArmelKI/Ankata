import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/app_theme.dart';

class CompanyLogoService {
  static const Map<String, String> companyLogoAssets = {
    'SOTRACO': 'assets/images/companies/sotraco_logo.png',
    'TSR': 'assets/images/companies/tsr_logo.png',
    'STAF': 'assets/images/companies/staf_logo.png',
    'T.C.V': 'assets/images/companies/tcv_logo.png',
    'TCV': 'assets/images/companies/tcv_logo.png',
    'Rakieta': 'assets/images/companies/rakieta_logo.png',
    'Saramaya': 'assets/images/companies/saramaya_logo.png',
    'Rahimo': 'assets/images/companies/rahimo_logo.png',
    'Elitis': 'assets/images/companies/elitis_logo.png',
    'FTS': 'assets/images/companies/fts_logo.png',
    'CTKE': 'assets/images/companies/ctke_logo.png',
  };

  static Widget getCompanyLogo({
    required String companyName,
    required double width,
    required double height,
    BoxFit fit = BoxFit.contain,
  }) {
    final assetPath = _getAssetPath(companyName);

    if (assetPath != null) {
      return Image.asset(
        assetPath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildSVGFallback(companyName, width, height);
        },
      );
    }

    return _buildSVGFallback(companyName, width, height);
  }

  static String? _getAssetPath(String companyName) {
    // Exact match
    if (companyLogoAssets.containsKey(companyName)) {
      return companyLogoAssets[companyName];
    }

    // Case insensitive match
    final upperName = companyName.toUpperCase();
    for (var entry in companyLogoAssets.entries) {
      if (entry.key.toUpperCase() == upperName) {
        return entry.value;
      }
    }

    // Partial match
    for (var entry in companyLogoAssets.entries) {
      if (upperName.contains(entry.key.toUpperCase()) ||
          entry.key.toUpperCase().contains(upperName)) {
        return entry.value;
      }
    }

    return null;
  }

  static Widget _buildSVGFallback(
      String companyName, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: CompanyColors.getCompanyColor(companyName),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          companyName.isNotEmpty ? companyName[0].toUpperCase() : 'C',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: width * 0.4,
          ),
        ),
      ),
    );
  }

  /// Network image with SVG fallback for remote URLs
  static Widget getCompanyLogoFromUrl({
    required String? logoUrl,
    required String companyName,
    required double width,
    required double height,
    BoxFit fit = BoxFit.contain,
  }) {
    if (logoUrl != null && logoUrl.isNotEmpty) {
      if (logoUrl.endsWith('.svg')) {
        return SvgPicture.network(
          logoUrl,
          width: width,
          height: height,
          fit: fit,
          placeholderBuilder: (context) =>
              _buildSVGFallback(companyName, width, height),
        );
      }

      return Image.network(
        logoUrl,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return _buildSVGFallback(companyName, width, height);
        },
      );
    }

    // Default to asset or SVG fallback if no URL provided
    return getCompanyLogo(
      companyName: companyName,
      width: width,
      height: height,
      fit: fit,
    );
  }
}

class CompanyColors {
  static const Map<String, Color> _colorMap = {
    'SOTRACO': Color(0xFF0066CC),
    'TSR': Color(0xFFE31E24),
    'STAF': Color(0xFF0091DA),
    'T.C.V': Color(0xFF00A651),
    'TCV': Color(0xFF00A651),
    'Rakieta': Color(0xFFF7941D),
    'Saramaya': Color(0xFFEE2D24),
    'Rahimo': Color(0xFF0054A6),
    'Elitis': Color(0xFF231F20),
  };

  static Color getCompanyColor(String companyName) {
    // Exact match
    if (_colorMap.containsKey(companyName)) {
      return _colorMap[companyName]!;
    }

    // partial match check
    final upperName = companyName.toUpperCase();
    for (var entry in _colorMap.entries) {
      if (upperName.contains(entry.key.toUpperCase())) {
        return entry.value;
      }
    }

    return AppColors.primary;
  }

  static String getCompanyTextColor(String companyName) {
    return '#FFFFFF';
  }
}

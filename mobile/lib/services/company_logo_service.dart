import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../config/app_theme.dart';

class CompanyLogoService {
  static const String _svgFallback = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">
  <g>
    <!-- Bus outline -->
    <rect x="10" y="20" width="80" height="50" rx="5" ry="5" fill="none" stroke="#4A90E2" stroke-width="2"/>
    <!-- Windows -->
    <rect x="15" y="25" width="15" height="12" fill="none" stroke="#4A90E2" stroke-width="1"/>
    <rect x="35" y="25" width="15" height="12" fill="none" stroke="#4A90E2" stroke-width="1"/>
    <rect x="55" y="25" width="15" height="12" fill="none" stroke="#4A90E2" stroke-width="1"/>
    <!-- Wheels -->
    <circle cx="25" cy="75" r="8" fill="none" stroke="#4A90E2" stroke-width="2"/>
    <circle cx="75" cy="75" r="8" fill="none" stroke="#4A90E2" stroke-width="2"/>
    <!-- Door -->
    <line x1="72" y1="70" x2="72" y2="20" stroke="#4A90E2" stroke-width="1"/>
  </g>
</svg>
  ''';

  static const Map<String, String> companyLogoAssets = {
    'SOTRACO': 'assets/logos/sotraco.png',
    'SOTRAMA': 'assets/logos/sotrama.png',
    'Tata': 'assets/logos/tata.png',
    'Rimbo': 'assets/logos/rimbo.png',
    'Azalaï': 'assets/logos/azalai.png',
    'Africacar': 'assets/logos/africacar.png',
  };

  static Widget getCompanyLogo({
    required String companyName,
    required double width,
    required double height,
    BoxFit fit = BoxFit.contain,
  }) {
    final assetPath = companyLogoAssets[companyName];

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

  static Widget _buildSVGFallback(
      String companyName, double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: CompanyColors.getCompanyColor(companyName),
        borderRadius: BorderRadius.circular(4),
      ),
      child: SvgPicture.string(
        _svgFallback,
        width: width * 0.7,
        height: height * 0.7,
        fit: BoxFit.contain,
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

    // Default to SVG fallback if no URL provided
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
    'SOTRAMA': Color(0xFFFF5722),
    'Tata': Color(0xFF4CAF50),
    'Rimbo': Color(0xFF9C27B0),
    'Azalaï': Color(0xFFFFC107),
    'Africacar': Color(0xFF00BCD4),
  };

  static Color getCompanyColor(String companyName) {
    return _colorMap[companyName] ?? AppColors.primary;
  }

  static String getCompanyTextColor(String companyName) {
    final color = getCompanyColor(companyName);
    // For light colors, use dark text; for dark colors, use white text
    if (companyName == 'Azalaï') {
      return '#000000';
    }
    return '#FFFFFF';
  }
}

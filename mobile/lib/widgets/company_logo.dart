import 'dart:io';
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../config/constants.dart';

/// Générateur de logos pour compagnies de transport
/// Utilise initiale + couleur de marque
class CompanyLogo extends StatelessWidget {
  final String companyName;
  final double size;
  final bool showBorder;

  const CompanyLogo({
    super.key,
    required this.companyName,
    this.size = 60,
    this.showBorder = false,
  });

  Color _getCompanyColor(String name) {
    // Couleurs réalistes pour compagnies de transport BF
    final companyColors = {
      'STAF': const Color(0xFFE74C3C), // Rouge
      'STAB': const Color(0xFF3498DB), // Bleu
      'TSR': const Color(0xFF2ECC71), // Vert
      'RAKIETA': const Color(0xFFF39C12), // Orange
      'TCV': const Color(0xFF9B59B6), // Violet
      'SONEF': const Color(0xFF1ABC9C), // Turquoise
      'TRANS EXPRESS': const Color(0xFFE67E22), // Orange foncé
    };

    // Match partiel sur le nom
    for (var entry in companyColors.entries) {
      if (name.toUpperCase().contains(entry.key)) {
        return entry.value;
      }
    }

    // Couleur par défaut basée sur hash du nom
    final hash = name.hashCode;
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCompanyColor(companyName);
    final initial = companyName.isNotEmpty ? companyName[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: AppRadius.radiusMd,
        border: showBorder
            ? Border.all(
                color: AppColors.white,
                width: 3,
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.w700,
            color: AppColors.white,
            letterSpacing: 0,
          ),
        ),
      ),
    );
  }
}

/// Avatar utilisateur avec initiales
class UserAvatar extends StatelessWidget {
  final String? name;
  final String? imageUrl;
  final double size;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    this.name,
    this.imageUrl,
    this.size = 40,
    this.backgroundColor,
  });

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return '?';

    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 1).toUpperCase();
  }

  Color _getColorFromName(String? name) {
    if (name == null || name.isEmpty) return AppColors.primary;

    final hash = name.hashCode;
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.6, 0.5).toColor();
  }

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      String finalUrl = imageUrl!;
      if (!finalUrl.startsWith('http') &&
          !finalUrl.startsWith('https') &&
          !finalUrl.startsWith('/') &&
          !File(finalUrl).existsSync()) {
        final baseUrl = AppConfig.apiBaseUrl;
        if (baseUrl.endsWith('/') && finalUrl.startsWith('/')) {
          finalUrl = baseUrl + finalUrl.substring(1);
        } else if (!baseUrl.endsWith('/') && !finalUrl.startsWith('/')) {
          finalUrl = '$baseUrl/$finalUrl';
        } else {
          finalUrl = baseUrl + finalUrl;
        }
      }

      if (imageUrl!.startsWith('/') && File(imageUrl!).existsSync()) {
        return CircleAvatar(
          radius: size / 2,
          backgroundImage: FileImage(File(imageUrl!)),
          backgroundColor: backgroundColor ?? _getColorFromName(name),
        );
      }
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(finalUrl),
        backgroundColor: backgroundColor ?? _getColorFromName(name),
      );
    }

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: backgroundColor ?? _getColorFromName(name),
      child: Text(
        _getInitials(name),
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.w600,
          color: AppColors.white,
        ),
      ),
    );
  }
}

/// Badge de vérification pour compagnies
class VerifiedBadge extends StatelessWidget {
  final double size;

  const VerifiedBadge({super.key, this.size = 16});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: const BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.check,
        size: size,
        color: AppColors.white,
      ),
    );
  }
}

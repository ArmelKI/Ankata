import 'dart:io';
import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

/// Company Logo Widget
/// Supports URL images, local assets, or initials with brand colors
class CompanyLogo extends StatelessWidget {
  final String companyName;
  final String? logoUrl;
  final double size;
  final bool showBorder;
  final bool cached;

  const CompanyLogo({
    super.key,
    required this.companyName,
    this.logoUrl,
    this.size = 60,
    this.showBorder = false,
    this.cached = true,
  });

  // Get brand color for company
  Color _getCompanyColor(String name) {
    final companyColors = {
      'TSR': const Color(0xFF2ECC71), // Vert
      'ELITIS': const Color(0xFF3498DB), // Bleu
      'ELITIS EXPRESS': const Color(0xFF3498DB), // Bleu
      'CTKE': const Color(0xFFE74C3C), // Rouge
      'CTKE WAYS': const Color(0xFFE74C3C),
      'RAKIETA': const Color(0xFFF39C12), // Orange
      'TCV': const Color(0xFF9B59B6), // Violet
      'SARAMAYA': const Color(0xFF1ABC9C), // Turquoise
      'FTS': const Color(0xFFE67E22), // Orange foncé
    };

    // Match company name
    for (var entry in companyColors.entries) {
      if (name.toUpperCase().contains(entry.key)) {
        return entry.value;
      }
    }

    // Default color based on hash
    final hash = name.hashCode;
    final hue = (hash % 360).toDouble();
    return HSLColor.fromAHSL(1.0, hue, 0.7, 0.5).toColor();
  }

  @override
  Widget build(BuildContext context) {
    // If logo URL provided, try to load it
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return _buildImageLogo();
    }

    // Fallback to initials + color
    return _buildInitialLogo();
  }

  Widget _buildImageLogo() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.2),
        border: showBorder
            ? Border.all(color: AppColors.white, width: 3)
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.2),
        child: Image.network(
          logoUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildInitialLogo();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              width: size,
              height: size,
              color: Colors.grey.shade200,
              child: Center(
                child: SizedBox(
                  width: size * 0.4,
                  height: size * 0.4,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    value: loadingProgress.expectedTotalBytes != null
                        ? loadingProgress.cumulativeBytesLoaded /
                            loadingProgress.expectedTotalBytes!
                        : null,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInitialLogo() {
    final color = _getCompanyColor(companyName);
    final initial = companyName.isNotEmpty ? companyName[0].toUpperCase() : '?';

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.2),
        border: showBorder
            ? Border.all(color: AppColors.white, width: 3)
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
      final isLocal = imageUrl!.startsWith('/') ||
          imageUrl!.startsWith('content://') ||
          imageUrl!.contains('/data/user/') ||
          imageUrl!.contains('/storage/');

      if (isLocal && File(imageUrl!).existsSync()) {
        return CircleAvatar(
          radius: size / 2,
          backgroundImage: FileImage(File(imageUrl!)),
          backgroundColor: backgroundColor ?? _getColorFromName(name),
        );
      }
      return CircleAvatar(
        radius: size / 2,
        backgroundImage: NetworkImage(imageUrl!),
        backgroundColor: backgroundColor ?? _getColorFromName(name),
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('Avatar image error: $exception');
        },
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

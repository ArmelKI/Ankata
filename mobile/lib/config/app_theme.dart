import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design System Ankata - Version 4.0
/// Tous les tokens de design centralisés

class AppColors {
  // Couleurs principales
  static const Color primary = Color(0xFF21808D); // Bleu-vert principal
  static const Color primaryDark = Color(0xFF1B6C75); // Variante foncée
  static const Color primaryLight = Color(0xFF4ECDC4); // Variante claire

  // Couleurs neutres
  static const Color charcoal = Color(0xFF1A1A1A); // Texte principal (clair)
  static const Color gray = Color(0xFF626C6C); // Texte secondaire
  static const Color lightGray = Color(0xFFF5F5F5); // Fond
  static const Color border = Color(0xFFE0E0E0); // Bordures
  static const Color white = Color(0xFFFFFFFF);

  // Couleurs dynamiques selon le thème
  static Color textPrimary = charcoal;
  static Color textSecondary = gray;
  static Color surface = white;

  static void configureForBrightness(Brightness brightness) {
    if (brightness == Brightness.dark) {
      textPrimary = const Color(0xFFF5F5F5);
      textSecondary = const Color(0xFFB0B0B0);
      surface = const Color(0xFF0F0F0F);
    } else {
      textPrimary = charcoal;
      textSecondary = gray;
      surface = white;
    }
  }

  // Couleurs sémantiques
  static const Color success = Color(0xFF00A859);
  static const Color error = Color(0xFFDC143C);
  static const Color warning = Color(0xFFFF6B00);
  static const Color info = Color(0xFF1E90FF);

  // Couleurs compagnies
  static const Color sotracoGreen = Color(0xFF00A859);
  static const Color tsrBlue = Color(0xFF1E90FF);
  static const Color stafOrange = Color(0xFFFF6B00);
  static const Color rahimoRed = Color(0xFFDC143C);
  static const Color rakietaBurgundy = Color(0xFF8B0000);
  static const Color tcvDarkGreen = Color(0xFF006400);

  // Couleurs étoiles/ratings
  static const Color star = Color(0xFFFFD700);
}

class AppSpacing {
  // Système d'espacement base 4px
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;
}

class AppRadius {
  // Border radius
  static const double sm = 6.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double full = 999.0;

  // Objets BorderRadius préconstruits
  static BorderRadius radiusSm = BorderRadius.circular(sm);
  static BorderRadius radiusMd = BorderRadius.circular(md);
  static BorderRadius radiusLg = BorderRadius.circular(lg);
  static BorderRadius radiusXl = BorderRadius.circular(xl);
  static BorderRadius radiusFull = BorderRadius.circular(full);
}

class AppShadows {
  // Niveaux d'ombres
  static List<BoxShadow> shadow0 = []; // Aucune ombre

  static List<BoxShadow> shadow1 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadow2 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.08),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  static List<BoxShadow> shadow3 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadow4 = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.16),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];
}

class AppGradients {
  // Gradient principal Ankata
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.primary, AppColors.primaryDark],
  );

  // Gradient pour overlays sombres sur images
  static const LinearGradient darkOverlay = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Colors.transparent, Color(0x99000000)],
  );

  // Gradient pour shimmer loading
  static const LinearGradient shimmer = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      Color(0xFFE0E0E0),
      Color(0xFFF5F5F5),
      Color(0xFFE0E0E0),
    ],
  );
}

class AppTextStyles {
  // Base font family
  static String get fontFamily => 'Poppins';

  // Titres
  static TextStyle h1 = GoogleFonts.poppins(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static TextStyle h2 = GoogleFonts.poppins(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static TextStyle h3 = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  static TextStyle h4 = GoogleFonts.poppins(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.4,
  );

  // Corps de texte
  static TextStyle bodyLarge = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  // Texte secondaire
  static TextStyle caption = GoogleFonts.poppins(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static TextStyle overline = GoogleFonts.poppins(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
    height: 1.5,
    letterSpacing: 0.5,
  );

  // Boutons
  static TextStyle button = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.5,
  );

  static TextStyle buttonSmall = GoogleFonts.poppins(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
    height: 1.5,
  );

  // Prix
  static TextStyle price = GoogleFonts.poppins(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    height: 1.2,
  );

  static TextStyle priceSmall = GoogleFonts.poppins(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.primary,
    height: 1.2,
  );
}

class AppTheme {
  static ThemeData lightTheme({Color? primaryColor}) {
    final effectivePrimary = primaryColor ?? AppColors.primary;
    final effectiveDark =
        primaryColor != null ? _darken(primaryColor) : AppColors.primaryDark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.light(
        primary: effectivePrimary,
        secondary: effectiveDark,
        error: AppColors.error,
        surface: AppColors.white,
        onPrimary: AppColors.white,
        onSecondary: AppColors.white,
        onSurface: AppColors.charcoal,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: AppColors.lightGray,
      fontFamily: AppTextStyles.fontFamily,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.charcoal,
        elevation: 1,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h3,
        iconTheme: const IconThemeData(color: AppColors.gray),
      ),

      // Boutons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMd,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMd,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),

      // Champs de formulaire
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.white,
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray),
        labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray),
      ),

      // Cartes
      cardTheme: CardThemeData(
        color: AppColors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMd,
          side: const BorderSide(color: AppColors.border),
        ),
        margin: const EdgeInsets.all(AppSpacing.sm),
      ),

      // Puces
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.lightGray,
        selectedColor: AppColors.primary,
        labelStyle: AppTextStyles.bodySmall,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusFull,
        ),
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: AppSpacing.lg,
      ),

      // Bottom Navigation Bar
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.gray,
        selectedLabelStyle:
            AppTextStyles.caption.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.caption,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
    );
  }

  static ThemeData darkTheme({Color? primaryColor}) {
    final effectivePrimary = primaryColor ?? const Color(0xFF4ECDC4);
    final effectiveDark =
        primaryColor != null ? _darken(primaryColor) : const Color(0xFF2FB7AE);

    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.dark(
        primary: effectivePrimary,
        secondary: effectiveDark,
        error: AppColors.error,
        surface: const Color(0xFF0F0F0F),
        onPrimary: const Color(0xFF0F0F0F),
        onSecondary: const Color(0xFF0F0F0F),
        onSurface: AppColors.white,
        onError: AppColors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF0F0F0F),
      fontFamily: AppTextStyles.fontFamily,
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF0F0F0F),
        foregroundColor: const Color(0xFFF5F5F5),
        elevation: 1,
        centerTitle: false,
        titleTextStyle: AppTextStyles.h3,
        iconTheme: const IconThemeData(color: Color(0xFFF5F5F5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4ECDC4),
          foregroundColor: const Color(0xFF0F0F0F),
          elevation: 0,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMd,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF4ECDC4),
          side: const BorderSide(color: Color(0xFF4ECDC4), width: 1.5),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.radiusMd,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF4ECDC4),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        contentPadding: const EdgeInsets.all(AppSpacing.md),
        border: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: Color(0xFF4ECDC4), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.radiusMd,
          borderSide: const BorderSide(color: AppColors.error),
        ),
        hintStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        labelStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1A1A1A),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusMd,
          side: const BorderSide(color: Color(0xFF2A2A2A)),
        ),
        margin: const EdgeInsets.all(AppSpacing.sm),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF1A1A1A),
        selectedColor: const Color(0xFF4ECDC4),
        labelStyle: AppTextStyles.bodySmall,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.radiusFull,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2A2A),
        thickness: 1,
        space: AppSpacing.lg,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: const Color(0xFF0F0F0F),
        selectedItemColor: const Color(0xFF4ECDC4),
        unselectedItemColor: AppColors.textSecondary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static Color _darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class KailiColors {
  // MedOpti Brand Colors
  static const Color primary = Color(0xFF1A6FBF);
  static const Color primaryLight = Color(0xFF1A6FBF);
  static const Color primaryDark = Color(0xFF1A6FBF);
  static const Color primarySurface = Color(0xFFE8F2FF);

  // Accent
  static const Color accent = Color(0xFF00C9A7);
  static const Color accentLight = Color(0xFFE0FAF5);

  // Neutrals
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF4F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF0F4F9);
  static const Color border = Color(0xFFE2E8F0);

  // Text
  static const Color textPrimary = Color(0xFF1A2744);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);

  // Semantic
  static const Color success = Color(0xFF22C55E);
  static const Color successSurface = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSurface = Color(0xFFFEF3C7);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSurface = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF3B82F6);
  static const Color infoSurface = Color(0xFFEFF6FF);

  // Shift type colors
  static const Color garde24h = Color(0xFF7C3AED);
  static const Color garde24hSurface = Color(0xFFF5F3FF);
  static const Color gardeNuit = Color.fromARGB(255, 32, 30, 175);
  static const Color gardeNuitSurface = Color.fromARGB(255, 32, 30, 175);
  static const Color gardeJour = Color.fromARGB(255, 119, 161, 3);
  static const Color gardeJourSurface = Color.fromARGB(255, 119, 161, 3);
  static const Color conge = Color(0xFF16A34A);
  static const Color congeSurface = Color(0xFFDCFCE7);
  static const Color repos = Color(0xFF64748B);
  static const Color reposSurface = Color(0xFFF1F5F9);
  static const Color formation = Color(0xFFD97706);
  static const Color formationSurface = Color(0xFFFEF3C7);
}

class KailiTheme {
  static ThemeData get theme {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      colorScheme: ColorScheme.fromSeed(
        seedColor: KailiColors.primary,
        brightness: Brightness.light,
        primary: KailiColors.primary,
        secondary: KailiColors.accent,
        background: KailiColors.background,
        surface: KailiColors.surface,
        error: KailiColors.error,
      ),
      scaffoldBackgroundColor: KailiColors.background,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: KailiColors.textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.plusJakartaSans(
          fontSize: 26,
          fontWeight: FontWeight.w700,
          color: KailiColors.textPrimary,
          letterSpacing: -0.3,
        ),
        headlineLarge: GoogleFonts.plusJakartaSans(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: KailiColors.textPrimary,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: KailiColors.textPrimary,
        ),
        headlineSmall: GoogleFonts.plusJakartaSans(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: KailiColors.textPrimary,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: KailiColors.textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: KailiColors.textPrimary,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: KailiColors.textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: KailiColors.textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: KailiColors.textTertiary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: KailiColors.textPrimary,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: KailiColors.textSecondary,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: KailiColors.textTertiary,
          letterSpacing: 0.5,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: KailiColors.white,
        foregroundColor: KailiColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: KailiColors.textPrimary,
        ),
      ),
      cardTheme: const CardThemeData(
      color: KailiColors.white, // Utilisé white au cas où surface n'existe pas
      elevation: 0,
      shape: RoundedRectangleBorder(
        // On utilise la vraie syntaxe constante pour les arrondis
        borderRadius: BorderRadius.all(Radius.circular(20)),
        side: BorderSide(color: KailiColors.border, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KailiColors.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: KailiColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: KailiColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: KailiColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: KailiColors.error),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        hintStyle: GoogleFonts.inter(
          fontSize: 14,
          color: KailiColors.textTertiary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KailiColors.primary,
          foregroundColor: KailiColors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KailiColors.primary,
          side: const BorderSide(color: KailiColors.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: KailiColors.surfaceVariant,
        selectedColor: KailiColors.primarySurface,
        labelStyle: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: KailiColors.white,
        selectedItemColor: KailiColors.primary,
        unselectedItemColor: KailiColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: KailiColors.border,
        thickness: 1,
        space: 1,
      ),
    );
  }
}

// Design system constants
class KailiSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class KailiRadius {
  static const double sm = 8;
  static const double md = 14;
  static const double lg = 20;
  static const double xl = 28;
  static const double pill = 100;
}

class KailiShadows {
  static List<BoxShadow> get card => [
        BoxShadow(
          color: const Color(0xFF1A2744).withOpacity(0.06),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: const Color(0xFF1A2744).withOpacity(0.03),
          blurRadius: 6,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get button => [
        BoxShadow(
          color: KailiColors.primary.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> get subtle => [
        BoxShadow(
          color: const Color(0xFF1A2744).withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];
}

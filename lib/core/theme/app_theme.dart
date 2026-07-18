import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_tokens.dart';

/// Paleta moderna y amigable — slate suave + menta + coral.
class AppColors {
  AppColors._();

  static const Color nightBackground = Color(0xFF0E1117);
  static const Color nightSurface = Color(0xFF151A24);
  static const Color nightCard = Color(0xFF1C2333);

  /// Menta fresca (primario / CTA).
  static const Color neonCyan = Color(0xFF5EEAD4);
  /// Coral cálido (secundario).
  static const Color neonAmber = Color(0xFFFB923C);
  static const Color neonRose = Color(0xFFFB7185);

  static const Color teamA = Color(0xFF5EEAD4);
  static const Color teamB = Color(0xFFFB923C);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static const Color capicua = Color(0xFFFBBF24);
  static const Color tranque = Color(0xFFFB7185);

  static const Color atmosphereTop = Color(0xFF1A2838);
  static const Color atmosphereBottom = Color(0xFF0A0C12);

  /// Texto sobre menta.
  static const Color ink = Color(0xFF0F172A);
  static const Color woodEdge = Color(0xFF2A3548);

  /// Acentos de ambiente (blobs).
  static const Color glowMint = Color(0x335EEAD4);
  static const Color glowCoral = Color(0x28FB923C);
}

class AppTheme {
  AppTheme._();

  static TextTheme _textTheme(TextTheme base) {
    return GoogleFonts.sourceSans3TextTheme(base).copyWith(
      displayLarge: GoogleFonts.bricolageGrotesque(
        fontSize: 64,
        fontWeight: FontWeight.w700,
        letterSpacing: -2,
        color: AppColors.textPrimary,
        height: 0.95,
      ),
      displayMedium: GoogleFonts.bricolageGrotesque(
        fontSize: 44,
        fontWeight: FontWeight.w700,
        letterSpacing: -1,
        color: AppColors.textPrimary,
      ),
      headlineLarge: GoogleFonts.bricolageGrotesque(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.4,
        color: AppColors.textPrimary,
      ),
      headlineMedium: GoogleFonts.bricolageGrotesque(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleLarge: GoogleFonts.bricolageGrotesque(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
      ),
      titleMedium: GoogleFonts.bricolageGrotesque(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: GoogleFonts.sourceSans3(
        fontSize: 16,
        height: 1.45,
        color: AppColors.textSecondary,
      ),
      bodyMedium: GoogleFonts.sourceSans3(
        fontSize: 14,
        height: 1.45,
        color: AppColors.textSecondary,
      ),
      bodySmall: GoogleFonts.sourceSans3(
        fontSize: 12,
        height: 1.4,
        color: AppColors.textMuted,
      ),
      labelLarge: GoogleFonts.bricolageGrotesque(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
      labelMedium: GoogleFonts.sourceSans3(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
      ),
    );
  }

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.neonCyan,
      onPrimary: AppColors.ink,
      secondary: AppColors.neonAmber,
      onSecondary: AppColors.ink,
      surface: AppColors.nightSurface,
      onSurface: AppColors.textPrimary,
      error: AppColors.neonRose,
      onError: AppColors.textPrimary,
      outline: AppColors.woodEdge,
    );

    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.nightBackground,
    );

    return base.copyWith(
      textTheme: _textTheme(base.textTheme),
      primaryTextTheme: _textTheme(base.primaryTextTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.bricolageGrotesque(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        iconTheme: const IconThemeData(color: AppColors.neonCyan, size: 22),
      ),
      cardTheme: CardThemeData(
        color: AppColors.nightCard,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadii.borderLg,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.neonCyan,
          foregroundColor: AppColors.ink,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
          textStyle: GoogleFonts.bricolageGrotesque(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.nightCard,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textSecondary,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: const Size.fromHeight(54),
          shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.neonCyan,
          textStyle: GoogleFonts.bricolageGrotesque(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.nightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        labelStyle: const TextStyle(color: AppColors.textSecondary),
        hintStyle: const TextStyle(color: AppColors.textMuted),
        border: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: const BorderSide(color: AppColors.neonCyan, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadii.borderMd,
          borderSide: const BorderSide(color: AppColors.neonRose),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.nightCard,
        selectedColor: AppColors.neonCyan.withValues(alpha: 0.2),
        labelStyle: GoogleFonts.bricolageGrotesque(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.08)),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.nightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderXl),
        titleTextStyle: GoogleFonts.bricolageGrotesque(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        contentTextStyle: GoogleFonts.sourceSans3(
          fontSize: 15,
          height: 1.45,
          color: AppColors.textSecondary,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.nightCard,
        contentTextStyle: GoogleFonts.sourceSans3(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.nightCard,
        modalBackgroundColor: AppColors.nightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.xl)),
        ),
        showDragHandle: true,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        thickness: 1,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.neonCyan,
        linearTrackColor: Colors.white.withValues(alpha: 0.08),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.nightSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.horizontal(right: Radius.circular(AppRadii.xl)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: AppColors.neonCyan,
        textColor: AppColors.textPrimary,
        titleTextStyle: GoogleFonts.bricolageGrotesque(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        subtitleTextStyle: GoogleFonts.sourceSans3(
          fontSize: 13,
          color: AppColors.textMuted,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderMd),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.neonCyan,
        foregroundColor: AppColors.ink,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: AppRadii.borderLg),
      ),
    );
  }
}

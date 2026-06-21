import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Paleta "Noche de Dominó" — mesa oscura con acentos neón sutiles.
class AppColors {
  AppColors._();

  // Fondo profundo tipo fieltro de mesa
  static const Color nightBackground = Color(0xFF0D1117);
  static const Color nightSurface = Color(0xFF161B22);
  static const Color nightCard = Color(0xFF1C2333);

  // Acentos neón elegantes
  static const Color neonAmber = Color(0xFFFFB020);
  static const Color neonCyan = Color(0xFF3DD6C6);
  static const Color neonRose = Color(0xFFFF6B8A);

  // Equipos
  static const Color teamA = Color(0xFF3DD6C6);
  static const Color teamB = Color(0xFFFFB020);

  // Texto
  static const Color textPrimary = Color(0xFFF0F3F8);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF484F58);

  // Eventos especiales
  static const Color capicua = Color(0xFFB388FF);
  static const Color chucho = Color(0xFFFF6B8A);
}

/// [ThemeData] centralizado: un solo lugar define la identidad visual.
class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.neonCyan,
      onPrimary: AppColors.nightBackground,
      secondary: AppColors.neonAmber,
      onSecondary: AppColors.nightBackground,
      surface: AppColors.nightSurface,
      onSurface: AppColors.textPrimary,
      error: AppColors.neonRose,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.nightBackground,
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: AppColors.textPrimary,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 72,
          fontWeight: FontWeight.w200,
          letterSpacing: -2,
          color: AppColors.textPrimary,
          height: 1,
        ),
        displayMedium: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w300,
          color: AppColors.textPrimary,
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: AppColors.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: AppColors.textSecondary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.nightCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.nightCard,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: Colors.white.withValues(alpha: 0.08),
        thickness: 1,
      ),
    );
  }
}

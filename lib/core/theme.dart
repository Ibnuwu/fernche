import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FerncheColors {
  static const matteBlack = Color(0xFF121212);
  static const softGray = Color(0xFF2C2C2C);
  static const terminalGreen = Color(0xFF00C853);
  static const white = Color(0xFFFFFFFF);
  static const dangerRed = Color(0xFFEF5350);
  static const surfaceLight = Color(0xFF1E1E1E);
  static const textSecondary = Color(0xFF9E9E9E);
  static const cardBorder = Color(0xFF3A3A3A);
}

class FerncheTheme {
  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: FerncheColors.matteBlack,
      colorScheme: const ColorScheme.dark(
        primary: FerncheColors.terminalGreen,
        onPrimary: FerncheColors.matteBlack,
        secondary: FerncheColors.terminalGreen,
        surface: FerncheColors.softGray,
        onSurface: FerncheColors.white,
        error: FerncheColors.dangerRed,
        onError: FerncheColors.white,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: FerncheColors.matteBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: FerncheColors.white,
        ),
        iconTheme: const IconThemeData(color: FerncheColors.white),
      ),
      cardTheme: CardThemeData(
        color: FerncheColors.softGray,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: FerncheColors.terminalGreen,
        foregroundColor: FerncheColors.matteBlack,
        elevation: 4,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: FerncheColors.softGray,
        selectedItemColor: FerncheColors.terminalGreen,
        unselectedItemColor: FerncheColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FerncheColors.surfaceLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: FerncheColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: FerncheColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(
            color: FerncheColors.terminalGreen,
            width: 1.5,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        hintStyle: const TextStyle(color: FerncheColors.textSecondary),
        labelStyle: const TextStyle(color: FerncheColors.textSecondary),
      ),
      textTheme: GoogleFonts.interTextTheme(base.textTheme).copyWith(
        headlineLarge: GoogleFonts.inter(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: FerncheColors.white,
        ),
        headlineMedium: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: FerncheColors.white,
        ),
        titleLarge: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: FerncheColors.white,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: FerncheColors.white,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          color: FerncheColors.white,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          color: FerncheColors.white,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          color: FerncheColors.textSecondary,
        ),
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: FerncheColors.white,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: FerncheColors.cardBorder,
        thickness: 0.5,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: FerncheColors.softGray,
        contentTextStyle: GoogleFonts.inter(color: FerncheColors.white),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      expansionTileTheme: const ExpansionTileThemeData(
        collapsedIconColor: FerncheColors.textSecondary,
        iconColor: FerncheColors.terminalGreen,
        tilePadding: EdgeInsets.symmetric(horizontal: 16),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: FerncheColors.softGray,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

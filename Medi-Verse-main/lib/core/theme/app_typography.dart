import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// MediVerse Enterprise Typography System
/// Powered by Google Fonts Poppins for ultra-clean, clinical-grade legibility across all form factors.
abstract class AppTypography {
  static TextStyle displayLarge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.poppins(
      fontSize: 32,
      height: 40 / 32,
      fontWeight: FontWeight.bold,
      letterSpacing: -0.5,
      color: isDark ? AppColors.neutral100 : AppColors.neutral900,
    );
  }

  static TextStyle displayMedium(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.poppins(
      fontSize: 28,
      height: 36 / 28,
      fontWeight: FontWeight.w600,
      letterSpacing: -0.25,
      color: isDark ? AppColors.neutral100 : AppColors.neutral900,
    );
  }

  static TextStyle headlineLarge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.poppins(
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.0,
      color: isDark ? AppColors.neutral100 : AppColors.neutral900,
    );
  }

  static TextStyle headlineMedium(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.poppins(
      fontSize: 20,
      height: 28 / 20,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.0,
      color: isDark ? AppColors.neutral100 : AppColors.neutral900,
    );
  }

  static TextStyle titleLarge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.poppins(
      fontSize: 18,
      height: 24 / 18,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      color: isDark ? AppColors.neutral100 : AppColors.neutral900,
    );
  }

  static TextStyle titleMedium(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.poppins(
      fontSize: 16,
      height: 22 / 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: isDark ? AppColors.neutral100 : AppColors.neutral900,
    );
  }

  static TextStyle bodyLarge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.poppins(
      fontSize: 16,
      height: 24 / 16,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.15,
      color: isDark ? AppColors.neutral100 : AppColors.neutral900,
    );
  }

  static TextStyle bodyMedium(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.poppins(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      color: isDark ? AppColors.neutral400 : AppColors.neutral600,
    );
  }

  static TextStyle bodySmall(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.poppins(
      fontSize: 12,
      height: 16 / 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.2,
      color: isDark ? AppColors.neutral400 : AppColors.neutral600,
    );
  }

  static TextStyle labelLarge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GoogleFonts.poppins(
      fontSize: 14,
      height: 20 / 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      color: isDark ? AppColors.neutral100 : AppColors.neutral900,
    );
  }

  static TextStyle labelCaption(BuildContext context) {
    return GoogleFonts.poppins(
      fontSize: 11,
      height: 14 / 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.5,
      color: AppColors.primary500,
    );
  }

  /// Builds a complete Material 3 TextTheme using Poppins font family
  static TextTheme getTextTheme({required bool isDark}) {
    final baseColor = isDark ? AppColors.neutral100 : AppColors.neutral900;
    final mutedColor = isDark ? AppColors.neutral400 : AppColors.neutral600;

    return GoogleFonts.poppinsTextTheme().copyWith(
      displayLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.bold, color: baseColor),
      displayMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600, color: baseColor),
      displaySmall: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: baseColor),
      headlineLarge: GoogleFonts.poppins(fontSize: 24, fontWeight: FontWeight.w600, color: baseColor),
      headlineMedium: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600, color: baseColor),
      headlineSmall: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: baseColor),
      titleLarge: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: baseColor),
      titleMedium: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: baseColor),
      titleSmall: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w500, color: baseColor),
      bodyLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500, color: baseColor),
      bodyMedium: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w400, color: mutedColor),
      bodySmall: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w400, color: mutedColor),
      labelLarge: GoogleFonts.poppins(fontSize: 14, fontWeight: FontWeight.w600, color: baseColor),
      labelMedium: GoogleFonts.poppins(fontSize: 12, fontWeight: FontWeight.w500, color: mutedColor),
      labelSmall: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary500),
    );
  }
}

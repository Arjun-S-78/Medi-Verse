import 'package:flutter/material.dart';

/// MediVerse Enterprise Color Tokens
/// Strictly WCAG AAA compliant for high contrast emergency readability.
abstract class AppColors {
  // Primary Brand Colors (Clinical Trust & Authority)
  static const Color primary500 = Color(0xFF005B94); // Clinical Sapphire
  static const Color primary400 = Color(0xFF0077C2); // Hover State
  static const Color primary600 = Color(0xFF004068); // Dark Contrast
  static const Color primaryAccent = Color(0xFF00D2C4); // Cyber Teal AI Highlight

  // Secondary & Accent Colors
  static const Color secondary500 = Color(0xFF5C59E8); // Vital Violet AI Waveform
  static const Color secondary100 = Color(0xFFEEF0FF); // Active Container Soft Fill

  // Neutral Colors (Slate Palette)
  static const Color neutral900 = Color(0xFF0F172A); // Dark Text / Obsidian Base
  static const Color neutral800 = Color(0xFF1E293B); // Dark Elevated Surface
  static const Color neutral700 = Color(0xFF334155); // Subtitle Slate
  static const Color neutral600 = Color(0xFF475569); // Secondary Body Slate
  static const Color neutral400 = Color(0xFF94A3B8); // Muted Placeholder
  static const Color neutral200 = Color(0xFFE2E8F0); // Subtle Border Light
  static const Color neutral100 = Color(0xFFF8FAFC); // Base App Canvas Light

  // Dark Mode Surface Matrix
  static const Color darkCanvas = Color(0xFF0B0F17); // Obsidian Black Void
  static const Color darkSurfaceCard = Color(0xFF161E2E); // Dark Slate Blue Card
  static const Color darkBorder = Color(0xFF2D3748); // Dark Border Line

  // Emergency Severity Colors (Manchester Triage System / ESI 1-5 Standard)
  static const Color esi1Critical = Color(0xFFFF2E4C); // ESI 1: Resuscitation (Neon Crimson)
  static const Color esi1SurfaceLight = Color(0xFFFFF0F2);
  static const Color esi1SurfaceDark = Color(0xFF3A0910);

  static const Color esi2Emergent = Color(0xFFFF6B00); // ESI 2: Emergent (Pulse Amber)
  static const Color esi2SurfaceLight = Color(0xFFFFF5ED);
  static const Color esi2SurfaceDark = Color(0xFF3A1900);

  static const Color esi3Urgent = Color(0xFFFFB800); // ESI 3: Urgent (Warning Gold)
  static const Color esi3SurfaceLight = Color(0xFFFFFBEB);
  static const Color esi3SurfaceDark = Color(0xFF3A2B00);

  static const Color esi4LessUrgent = Color(0xFF00C853); // ESI 4: Less Urgent (Emerald)
  static const Color esi4SurfaceLight = Color(0xFFEDFDF4);
  static const Color esi4SurfaceDark = Color(0xFF023315);

  static const Color esi5NonUrgent = Color(0xFF00B0FF); // ESI 5: Non-Urgent (Cyan Blue)
  static const Color esi5SurfaceLight = Color(0xFFF0F9FF);
  static const Color esi5SurfaceDark = Color(0xFF02293A);
}

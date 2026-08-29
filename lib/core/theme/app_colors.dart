import 'package:flutter/material.dart';

/// MediVerse Enterprise Color System Tokens
/// Strictly WCAG AAA compliant for clinical readability and emergency clarity.
abstract class AppColors {
  // Primary Brand Colors (Clinical Trust & Authority)
  static const Color primary500 = Color(0xFF005B94); // Deep Medical Sapphire
  static const Color primary400 = Color(0xFF0077C2); // Active Hover State
  static const Color primary600 = Color(0xFF004068); // Dark Contrast / Header
  static const Color primaryAccent = Color(0xFF00D2C4); // Cyber Teal AI Highlight
  static const Color primarySubtleLight = Color(0xFFEFF6FF); // Soft Primary Light Container
  static const Color primarySubtleDark = Color(0xFF0C243B); // Soft Primary Dark Container

  // Secondary & Accent Colors (MIRA AI Waveform & Highlights)
  static const Color secondary500 = Color(0xFF00A896); // Clinical Emerald Teal
  static const Color secondary100 = Color(0xFFE6F7F5); // Soft Active Container
  static const Color aiPulseGlow = Color(0xFF38BDF8); // Electric Sky Blue Pulse
  static const Color heroPurple = Color(0xFFA855F7); // Glowing AI Purple
  static const Color heroPurpleDark = Color(0xFF7E22CE);
  static const Color heroPink = Color(0xFFEC4899); // Glowing MIRA Magenta Pink
  static const Color heroCyan = Color(0xFF06B6D4); // Cyber Cyan Accent

  // Neutral Colors (Slate Palette - Clean & Uncluttered)
  static const Color neutral900 = Color(0xFF0F172A); // Obsidian Slate Body Text
  static const Color neutral800 = Color(0xFF1E293B); // Dark Elevated Surface
  static const Color neutral700 = Color(0xFF334155); // Subtitle Slate
  static const Color neutral600 = Color(0xFF475569); // Secondary Slate Body
  static const Color neutral400 = Color(0xFF94A3B8); // Muted Placeholder / Caption
  static const Color neutral300 = Color(0xFFCBD5E1); // Divider Light
  static const Color neutral200 = Color(0xFFE2E8F0); // Subtle Border Light
  static const Color neutral100 = Color(0xFFF8FAFC); // Base App Canvas Light

  // Dark Mode Surface Matrix (Navy Deep Void)
  static const Color darkCanvas = Color(0xFF0B0F17); // Obsidian Deep Navy Void
  static const Color darkSurfaceCard = Color(0xFF161E2E); // Elevated Navy Slate Card
  static const Color darkSurfaceCardHover = Color(0xFF1F2A3E); // Hover Card Surface
  static const Color darkBorder = Color(0xFF263346); // Dark Border Line

  // Emergency Severity Colors (Manchester Triage System / ESI 1-5 Standard)
  static const Color esi1Critical = Color(0xFFFF2E4C); // ESI 1: Resuscitation (Emergency Crimson)
  static const Color esi1SurfaceLight = Color(0xFFFFF0F2);
  static const Color esi1SurfaceDark = Color(0xFF3A0910);

  static const Color esi2Emergent = Color(0xFFFF6B00); // ESI 2: Emergent (Pulse Amber)
  static const Color esi2SurfaceLight = Color(0xFFFFF5ED);
  static const Color esi2SurfaceDark = Color(0xFF3A1900);

  static const Color esi3Urgent = Color(0xFFFFB800); // ESI 3: Urgent (Warning Gold)
  static const Color esi3SurfaceLight = Color(0xFFFFFBEB);
  static const Color esi3SurfaceDark = Color(0xFF3A2B00);

  static const Color esi4LessUrgent = Color(0xFF10B981); // ESI 4: Less Urgent (Emerald)
  static const Color esi4SurfaceLight = Color(0xFFECFDF5);
  static const Color esi4SurfaceDark = Color(0xFF023315);

  static const Color esi5NonUrgent = Color(0xFF0284C7); // ESI 5: Non-Urgent (Cyan Blue)
  static const Color esi5SurfaceLight = Color(0xFFF0F9FF);
  static const Color esi5SurfaceDark = Color(0xFF02293A);

  // Status & Feedback Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFA16207);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF0284C7);
}

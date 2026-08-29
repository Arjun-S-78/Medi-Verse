import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Prototype emergency priority level produced by the deterministic triage engine.
///
/// Priority levels range from LOW to CRITICAL.
enum PriorityLevel {
  low(
    code: 'LOW',
    label: 'Low Priority',
    description: 'Non-urgent condition. Standard clinical consultation recommended.',
    color: AppColors.esi5NonUrgent,
    surfaceColorLight: AppColors.esi5SurfaceLight,
    surfaceColorDark: AppColors.esi5SurfaceDark,
    minScore: 0,
    maxScore: 25,
  ),
  moderate(
    code: 'MODERATE',
    label: 'Moderate Priority',
    description: 'Urgent condition requiring prompt medical attention within standard care timeframe.',
    color: AppColors.esi3Urgent,
    surfaceColorLight: AppColors.esi3SurfaceLight,
    surfaceColorDark: AppColors.esi3SurfaceDark,
    minScore: 26,
    maxScore: 50,
  ),
  high(
    code: 'HIGH',
    label: 'High Priority',
    description: 'Emergent condition with significant risk. Requires urgent clinical evaluation.',
    color: AppColors.esi2Emergent,
    surfaceColorLight: AppColors.esi2SurfaceLight,
    surfaceColorDark: AppColors.esi2SurfaceDark,
    minScore: 51,
    maxScore: 75,
  ),
  critical(
    code: 'CRITICAL',
    label: 'Critical Priority',
    description: 'Immediate emergency risk or red flag override detected. Requires immediate intervention.',
    color: AppColors.esi1Critical,
    surfaceColorLight: AppColors.esi1SurfaceLight,
    surfaceColorDark: AppColors.esi1SurfaceDark,
    minScore: 76,
    maxScore: 100,
  );

  final String code;
  final String label;
  final String description;
  final Color color;
  final Color surfaceColorLight;
  final Color surfaceColorDark;
  final int minScore;
  final int maxScore;

  const PriorityLevel({
    required this.code,
    required this.label,
    required this.description,
    required this.color,
    required this.surfaceColorLight,
    required this.surfaceColorDark,
    required this.minScore,
    required this.maxScore,
  });

  /// Parse string code to PriorityLevel (defaults to LOW if unrecognized).
  static PriorityLevel fromCode(String? code) {
    if (code == null) return PriorityLevel.low;
    final normalized = code.trim().toUpperCase();
    return PriorityLevel.values.firstWhere(
      (p) => p.code == normalized,
      orElse: () => PriorityLevel.low,
    );
  }

  /// Classify score into a priority level (0 to 100+).
  static PriorityLevel fromScore(int score) {
    if (score >= 76) return PriorityLevel.critical;
    if (score >= 51) return PriorityLevel.high;
    if (score >= 26) return PriorityLevel.moderate;
    return PriorityLevel.low;
  }
}

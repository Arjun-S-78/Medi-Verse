import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Manchester Triage System & Emergency Severity Index (ESI Levels 1 to 5)
enum EsiSeverityLevel {
  esi1(
    level: 1,
    name: 'Resuscitation',
    description: 'Immediate life-threatening crisis (Cardiac Arrest, Severe Airway Compromise)',
    color: AppColors.esi1Critical,
    surfaceLight: AppColors.esi1SurfaceLight,
    surfaceDark: AppColors.esi1SurfaceDark,
  ),
  esi2(
    level: 2,
    name: 'Emergent',
    description: 'High risk, confused/lethargic, severe pain or respiratory distress',
    color: AppColors.esi2Emergent,
    surfaceLight: AppColors.esi2SurfaceLight,
    surfaceDark: AppColors.esi2SurfaceDark,
  ),
  esi3(
    level: 3,
    name: 'Urgent',
    description: 'Stable vitals, requires multiple resources (X-Ray, IV Fluids, Labs)',
    color: AppColors.esi3Urgent,
    surfaceLight: AppColors.esi3SurfaceLight,
    surfaceDark: AppColors.esi3SurfaceDark,
  ),
  esi4(
    level: 4,
    name: 'Less Urgent',
    description: 'Stable, requires single resource (Simple Laceration Sutures, X-Ray)',
    color: AppColors.esi4LessUrgent,
    surfaceLight: AppColors.esi4SurfaceLight,
    surfaceDark: AppColors.esi4SurfaceDark,
  ),
  esi5(
    level: 5,
    name: 'Non-Urgent',
    description: 'Routine clinical evaluation (Prescription refill, Minor Rash)',
    color: AppColors.esi5NonUrgent,
    surfaceLight: AppColors.esi5SurfaceLight,
    surfaceDark: AppColors.esi5SurfaceDark,
  );

  final int level;
  final String name;
  final String description;
  final Color color;
  final Color surfaceLight;
  final Color surfaceDark;

  const EsiSeverityLevel({
    required this.level,
    required this.name,
    required this.description,
    required this.color,
    required this.surfaceLight,
    required this.surfaceDark,
  });

  static EsiSeverityLevel fromLevel(int level) {
    return EsiSeverityLevel.values.firstWhere(
      (e) => e.level == level,
      orElse: () => EsiSeverityLevel.esi3,
    );
  }
}

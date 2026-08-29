import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// MIRA Modes state machine enum.
///
/// Dictates MIRA's active operational mode, avatar expression, voice tone, and service routing.
enum MiraMode {
  normal(
    code: 'NORMAL',
    title: 'Care Assistant',
    description: 'Friendly, welcoming AI care coordinator assistance.',
    avatarColor: AppColors.primary500,
    voiceTone: 'Friendly, warm and welcoming',
  ),
  reception(
    code: 'RECEPTION',
    title: 'AI Receptionist',
    description: 'Patient check-in, registration, and health passport queries.',
    avatarColor: AppColors.secondary500,
    voiceTone: 'Professional, clear and supportive',
  ),
  search(
    code: 'SEARCH',
    title: 'Search Assistant',
    description: 'Finding doctors by specialty and filtering nearby hospitals.',
    avatarColor: AppColors.primary400,
    voiceTone: 'Helpful, efficient and informative',
  ),
  appointment(
    code: 'APPOINTMENT',
    title: 'Appointment Assistant',
    description: 'Scheduling, confirming, or checking clinic consultations.',
    avatarColor: AppColors.esi3Urgent,
    voiceTone: 'Clear, precise and organizing',
  ),
  emergency(
    code: 'EMERGENCY',
    title: 'Emergency Response',
    description: 'Immediate alert & safety escalation mode for acute situations.',
    avatarColor: AppColors.esi1Critical,
    voiceTone: 'Calm, concise, steady and direct',
  ),
  triage(
    code: 'TRIAGE',
    title: 'Triage Nurse',
    description: 'Structured symptom collection and deterministic scoring.',
    avatarColor: AppColors.esi2Emergent,
    voiceTone: 'Compassionate, clinical and reassuring',
  ),
  tracking(
    code: 'TRACKING',
    title: 'Live Fleet Radar',
    description: 'Real-time ambulance dispatch tracking & hospital arrival ETA.',
    avatarColor: AppColors.esi4LessUrgent,
    voiceTone: 'Reassuring, clear and status-updating',
  );

  final String code;
  final String title;
  final String description;
  final Color avatarColor;
  final String voiceTone;

  const MiraMode({
    required this.code,
    required this.title,
    required this.description,
    required this.avatarColor,
    required this.voiceTone,
  });

  static MiraMode fromCode(String? code) {
    if (code == null) return MiraMode.normal;
    final normalized = code.trim().toUpperCase();
    return MiraMode.values.firstWhere(
      (m) => m.code == normalized,
      orElse: () => MiraMode.normal,
    );
  }
}

import 'priority_level.dart';

/// Result produced by the deterministic triage engine.
class TriageResult {
  final PriorityLevel priority;
  final int score;
  final List<String> reasons;
  final List<String> redFlags;
  final String recommendedAction;
  final bool isEmergencyOverride;
  final DateTime evaluatedAt;

  const TriageResult({
    required this.priority,
    required this.score,
    required this.reasons,
    required this.redFlags,
    required this.recommendedAction,
    this.isEmergencyOverride = false,
    required this.evaluatedAt,
  });

  factory TriageResult.fromJson(Map<String, dynamic> json) {
    return TriageResult(
      priority: PriorityLevel.fromCode(json['priority'] as String?),
      score: (json['score'] as num).toInt(),
      reasons: (json['reasons'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      redFlags: (json['redFlags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      recommendedAction: json['recommendedAction'] as String? ?? 'Seek immediate clinical assessment.',
      isEmergencyOverride: json['isEmergencyOverride'] as bool? ?? false,
      evaluatedAt: json['evaluatedAt'] != null
          ? DateTime.parse(json['evaluatedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'priority': priority.code,
      'score': score,
      'reasons': reasons,
      'redFlags': redFlags,
      'recommendedAction': recommendedAction,
      'isEmergencyOverride': isEmergencyOverride,
      'evaluatedAt': evaluatedAt.toIso8601String(),
    };
  }

  @override
  String toString() => 'TriageResult(${priority.code}, Score: $score, Override: $isEmergencyOverride)';
}

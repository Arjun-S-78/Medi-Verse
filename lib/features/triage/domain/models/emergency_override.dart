/// Represents an emergency red flag override triggered by critical safety rules.
class EmergencyOverride {
  final String ruleId;
  final String redFlagCode;
  final String reason;
  final DateTime triggeredAt;

  const EmergencyOverride({
    required this.ruleId,
    required this.redFlagCode,
    required this.reason,
    required this.triggeredAt,
  });

  factory EmergencyOverride.fromJson(Map<String, dynamic> json) {
    return EmergencyOverride(
      ruleId: json['ruleId'] as String,
      redFlagCode: json['redFlagCode'] as String,
      reason: json['reason'] as String,
      triggeredAt: DateTime.parse(json['triggeredAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ruleId': ruleId,
      'redFlagCode': redFlagCode,
      'reason': reason,
      'triggeredAt': triggeredAt.toIso8601String(),
    };
  }
}

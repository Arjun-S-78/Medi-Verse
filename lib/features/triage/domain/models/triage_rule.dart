/// Configurable triage scoring rule model for prototype evaluation.
class TriageRule {
  final String id;
  final String name;
  final String description;
  final String category; // CRITICAL, HIGH_RISK, MODERATE, RISK_MODIFIER
  final int scoreImpact;
  final bool isCriticalOverride;
  final String conditionCode;

  const TriageRule({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.scoreImpact,
    this.isCriticalOverride = false,
    required this.conditionCode,
  });

  factory TriageRule.fromJson(Map<String, dynamic> json) {
    return TriageRule(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      category: json['category'] as String,
      scoreImpact: (json['scoreImpact'] as num).toInt(),
      isCriticalOverride: json['isCriticalOverride'] as bool? ?? false,
      conditionCode: json['conditionCode'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'scoreImpact': scoreImpact,
      'isCriticalOverride': isCriticalOverride,
      'conditionCode': conditionCode,
    };
  }
}

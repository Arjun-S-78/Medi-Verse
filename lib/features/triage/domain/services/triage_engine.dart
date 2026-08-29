import '../models/emergency_override.dart';
import '../models/priority_level.dart';
import '../models/structured_triage_data.dart';
import '../models/triage_result.dart';
import '../models/triage_rule.dart';

/// Deterministic Triage Engine.
///
/// Evaluates structured triage data against configurable scoring rules and emergency overrides.
/// The conversational AI passes structured data to this engine, which makes the final priority decision.
class TriageEngine {
  /// Default prototype triage rules.
  static const List<TriageRule> defaultRules = [
    TriageRule(
      id: 'rule_unconscious',
      name: 'Unconsciousness',
      description: 'Patient is reported unconscious or unresponsive.',
      category: 'CRITICAL',
      scoreImpact: 80,
      isCriticalOverride: true,
      conditionCode: 'UNCONSCIOUS',
    ),
    TriageRule(
      id: 'rule_seizure',
      name: 'Active Seizure',
      description: 'Active seizure or convulsions reported.',
      category: 'CRITICAL',
      scoreImpact: 75,
      isCriticalOverride: true,
      conditionCode: 'SEIZURE',
    ),
    TriageRule(
      id: 'rule_airway',
      name: 'Severe Breathing Difficulty',
      description: 'Severe respiratory distress or gasp for air.',
      category: 'CRITICAL',
      scoreImpact: 40,
      isCriticalOverride: false,
      conditionCode: 'BREATHING_DIFFICULTY',
    ),
    TriageRule(
      id: 'rule_chest_pain',
      name: 'Severe Chest Pain',
      description: 'Chest pain or pressure suspicious of cardiac event.',
      category: 'HIGH_RISK',
      scoreImpact: 35,
      isCriticalOverride: false,
      conditionCode: 'CHEST_PAIN',
    ),
    TriageRule(
      id: 'rule_bleeding',
      name: 'Severe Bleeding',
      description: 'Uncontrolled or heavy bleeding reported.',
      category: 'HIGH_RISK',
      scoreImpact: 30,
      isCriticalOverride: false,
      conditionCode: 'SEVERE_BLEEDING',
    ),
    TriageRule(
      id: 'rule_trauma',
      name: 'Major Trauma',
      description: 'High impact collision, fall, or severe bodily trauma.',
      category: 'HIGH_RISK',
      scoreImpact: 25,
      isCriticalOverride: false,
      conditionCode: 'MAJOR_TRAUMA',
    ),
  ];

  /// Evaluates structured triage data and produces a deterministic TriageResult.
  static TriageResult evaluate(StructuredTriageData data) {
    final now = DateTime.now();
    final redFlags = <String>[];
    final reasons = <String>[];

    // 1. Emergency Override Layer
    EmergencyOverride? overrideTrigger;

    if (data.conscious == false) {
      overrideTrigger = EmergencyOverride(
        ruleId: 'rule_unconscious',
        redFlagCode: 'UNCONSCIOUSNESS',
        reason: 'Patient reported loss of consciousness or unresponsiveness.',
        triggeredAt: now,
      );
      redFlags.add('UNCONSCIOUSNESS');
      reasons.add('Loss of consciousness reported');
    }

    if (data.seizure == true) {
      overrideTrigger ??= EmergencyOverride(
        ruleId: 'rule_seizure',
        redFlagCode: 'ACTIVE_SEIZURE',
        reason: 'Active seizure or convulsive episode reported.',
        triggeredAt: now,
      );
      redFlags.add('ACTIVE_SEIZURE');
      reasons.add('Active seizure or convulsions reported');
    }

    if (overrideTrigger != null) {
      return TriageResult(
        priority: PriorityLevel.critical,
        score: 100,
        reasons: reasons,
        redFlags: redFlags,
        recommendedAction: 'IMMEDIATE EMERGENCY ESCALATION REQUIRED. Requesting urgent dispatch.',
        isEmergencyOverride: true,
        evaluatedAt: now,
      );
    }

    // 2. Score Calculation Layer
    int score = 0;

    if (data.chestPain == true) {
      score += 35;
      redFlags.add('CHEST_PAIN');
      reasons.add('Severe chest pain or cardiac pressure reported');
    }

    if (data.breathingDifficulty == true) {
      score += 30;
      redFlags.add('BREATHING_DIFFICULTY');
      reasons.add('Difficulty breathing or shortness of breath reported');
    }

    if (data.severeBleeding == true) {
      score += 30;
      redFlags.add('SEVERE_BLEEDING');
      reasons.add('Severe or heavy bleeding reported');
    }

    if (data.majorTrauma == true) {
      score += 25;
      redFlags.add('MAJOR_TRAUMA');
      reasons.add('Major physical trauma or high-impact injury reported');
    }

    if (data.neurologicalSymptoms.isNotEmpty) {
      score += 20;
      reasons.add('Neurological warning signs present (${data.neurologicalSymptoms.join(', ')})');
    }

    if (data.painLevel != null) {
      if (data.painLevel! >= 8) {
        score += 20;
        reasons.add('Unbearable pain intensity (${data.painLevel}/10)');
      } else if (data.painLevel! >= 5) {
        score += 10;
        reasons.add('Moderate pain intensity (${data.painLevel}/10)');
      }
    }

    // Risk modifiers
    if (data.age != null && data.age! >= 65) {
      score += 10;
      reasons.add('Advanced age risk factor (${data.age} years old)');
    }

    if (data.medicalConditions.isNotEmpty) {
      score += 10;
      reasons.add('Pre-existing medical condition(s): ${data.medicalConditions.join(', ')}');
    }

    // Determine final priority based on score
    final PriorityLevel priority = PriorityLevel.fromScore(score);

    String recommendedAction;
    switch (priority) {
      case PriorityLevel.critical:
        recommendedAction = 'Immediate emergency evaluation & ambulance dispatch recommended.';
        break;
      case PriorityLevel.high:
        recommendedAction = 'Urgent emergency room evaluation recommended within 15-30 minutes.';
        break;
      case PriorityLevel.moderate:
        recommendedAction = 'Urgent outpatient clinic evaluation recommended today.';
        break;
      case PriorityLevel.low:
        recommendedAction = 'Standard clinical consultation or primary care evaluation recommended.';
        break;
    }

    if (reasons.isEmpty) {
      reasons.add('Assessment based on reported symptoms and patient profile.');
    }

    return TriageResult(
      priority: priority,
      score: score,
      reasons: reasons,
      redFlags: redFlags,
      recommendedAction: recommendedAction,
      isEmergencyOverride: false,
      evaluatedAt: now,
    );
  }
}

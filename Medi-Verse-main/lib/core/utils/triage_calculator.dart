import '../../shared/models/severity_level.dart';

/// Clinical Triage Score Index Calculator
class TriageCalculator {
  static EsiSeverityLevel evaluateSymptoms({
    required bool isUnconscious,
    required bool hasSevereBreathingDifficulty,
    required bool hasChestPain,
    required bool hasSevereBleeding,
    required int heartRateBpm,
    required int spo2Percentage,
  }) {
    // ESI 1: Immediate Resuscitation
    if (isUnconscious || spo2Percentage < 88 || heartRateBpm > 140 || heartRateBpm < 40) {
      return EsiSeverityLevel.esi1;
    }

    // ESI 2: High Risk / Emergent
    if (hasSevereBreathingDifficulty || hasChestPain || hasSevereBleeding || spo2Percentage < 92) {
      return EsiSeverityLevel.esi2;
    }

    // ESI 3: Urgent
    if (heartRateBpm > 110 || spo2Percentage < 95) {
      return EsiSeverityLevel.esi3;
    }

    // ESI 4: Less Urgent
    if (heartRateBpm > 90) {
      return EsiSeverityLevel.esi4;
    }

    // ESI 5: Non-Urgent
    return EsiSeverityLevel.esi5;
  }
}

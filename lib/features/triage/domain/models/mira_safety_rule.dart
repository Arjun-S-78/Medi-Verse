/// Safety Evaluation Rule & Guardrail System for MIRA AI Nurse.
class MiraSafetyRule {
  static const List<String> emergencyIntents = [
    'ambulance',
    'chest_pain',
    'breathing_difficulty',
    'severe_bleeding',
    'unconscious',
    'seizure',
    'stroke_warning',
    'severe_allergic_reaction',
  ];

  static const List<String> emergencyKeywords = [
    'chest pain',
    'chest hurt',
    'chest hurts',
    'heart attack',
    'cannot breathe',
    'cant breathe',
    'can\'t breathe',
    'moochu',
    'struggling to breathe',
    'shortness of breath',
    'heavy bleeding',
    'severe bleeding',
    'unconscious',
    'passed out',
    'seizure',
    'stroke',
    'numbness',
    'anaphylaxis',
    'severe allergic',
    'ambulance',
    'sos',
    '108',
  ];

  /// Check if the intent key requires immediate clinical emergency escalation.
  static bool isEmergencyIntent(String intentKey) {
    return emergencyIntents.contains(intentKey.toLowerCase().trim());
  }

  /// Check if user text contains red-flag emergency keywords.
  static bool hasEmergencyKeyword(String text) {
    final lower = text.toLowerCase().trim();
    return emergencyKeywords.any((kw) => lower.contains(kw));
  }

  /// Standard nursing safety disclaimer added to triage & symptom guidance responses.
  static const String nursingDisclaimer =
      "I am MIRA, your AI Healthcare Assistant. I provide health guidance and care coordination, not a medical diagnosis. "
      "For a formal diagnosis or treatment plan, please consult a licensed healthcare professional.";

  /// Safety prompt for critical emergency responses.
  static const String emergencySafetyPrompt =
      "🚨 CRITICAL HEALTH ALERT: These symptoms require immediate medical evaluation. "
      "If you are experiencing a life-threatening emergency, please seek urgent emergency care or dispatch an ambulance immediately.";
}

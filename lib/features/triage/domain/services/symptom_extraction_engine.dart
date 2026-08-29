import '../models/structured_triage_data.dart';

/// Natural Language understanding & rule-based symptom extraction engine for MIRA.
///
/// Converts raw patient text into structured triage data fields.
class SymptomExtractionEngine {
  /// Extract or update structured triage data based on patient input text.
  static StructuredTriageData extractSymptoms({
    required String userText,
    required StructuredTriageData currentData,
    String? currentPromptKey,
  }) {
    final text = userText.trim();
    if (text.isEmpty) return currentData;

    final lower = text.toLowerCase();

    // Key phrase matches for symptoms
    final hasChestPain = lower.contains('chest') ||
        lower.contains('heart') ||
        lower.contains('angina') ||
        lower.contains('cardiac') ||
        lower.contains('sternum');

    final hasBreathing = lower.contains('breath') ||
        lower.contains('gasp') ||
        lower.contains('air') ||
        lower.contains('wheez') ||
        lower.contains('chok') ||
        lower.contains('suffocat') ||
        lower.contains('dyspnea');

    final hasBleeding = lower.contains('bleed') ||
        lower.contains('blood') ||
        lower.contains('gash') ||
        lower.contains('hemorrhag') ||
        lower.contains('wound');

    final hasTrauma = lower.contains('fall') ||
        lower.contains('crash') ||
        lower.contains('accident') ||
        lower.contains('hit') ||
        lower.contains('trauma') ||
        lower.contains('fracture') ||
        lower.contains('collision');

    final hasSeizure = lower.contains('seizure') ||
        lower.contains('convuls') ||
        lower.contains('fit') ||
        lower.contains('epilep');

    final hasUnconscious = lower.contains('unconscious') ||
        lower.contains('faint') ||
        lower.contains('passed out') ||
        lower.contains('blacked out') ||
        lower.contains('unresponsive');

    // Extract pain numeric level (1-10)
    int? extractedPain;
    final painMatch = RegExp(r'\b(10|[1-9])(?:\s*(?:out of 10|\/10))?\b').firstMatch(lower);
    if (painMatch != null) {
      extractedPain = int.tryParse(painMatch.group(1)!);
    }

    // Extract age if explicitly mentioned
    int? extractedAge;
    final ageMatch = RegExp(r'\b(\d{1,3})\s*(?:years old|yo|yr|yrs)\b').firstMatch(lower);
    if (ageMatch != null) {
      extractedAge = int.tryParse(ageMatch.group(1)!);
    }

    // Extract onset or duration keyword phrases
    String? extractedOnset;
    if (lower.contains('sudden') || lower.contains('abrupt') || lower.contains('just started')) {
      extractedOnset = 'Sudden onset';
    } else if (lower.contains('hour') || lower.contains('minute')) {
      extractedOnset = text;
    }

    // Neurological keywords
    final neuroList = <String>[];
    if (lower.contains('numb') || lower.contains('tingl')) neuroList.add('Numbness / Tingling');
    if (lower.contains('slur') || lower.contains('speech')) neuroList.add('Slurred Speech');
    if (lower.contains('droop') || lower.contains('face')) neuroList.add('Facial Droop');
    if (lower.contains('dizzy') || lower.contains('giddy')) neuroList.add('Dizziness');
    if (lower.contains('confus')) neuroList.add('Confusion');

    // Medical condition keywords
    final conditions = List<String>.from(currentData.medicalConditions);
    if (lower.contains('diabet')) conditions.add('Diabetes');
    if (lower.contains('hypertension') || lower.contains('high blood pressure')) conditions.add('Hypertension');
    if (lower.contains('asthma')) conditions.add('Asthma');
    if (lower.contains('heart disease') || lower.contains('cardiac history')) conditions.add('Cardiac History');

    // Build updated structured data
    return currentData.copyWith(
      chiefComplaint: currentData.chiefComplaint ?? (currentPromptKey == 'chiefComplaint' ? text : null),
      onset: currentData.onset ?? extractedOnset ?? (currentPromptKey == 'onset' ? text : null),
      duration: currentData.duration ?? (currentPromptKey == 'duration' ? text : null),
      painLevel: currentData.painLevel ?? extractedPain ?? (currentPromptKey == 'painLevel' ? extractedPain : null),
      conscious: hasUnconscious ? false : (currentData.conscious ?? (currentPromptKey == 'conscious' ? !lower.contains('no') : null)),
      breathingDifficulty: hasBreathing ? true : (currentData.breathingDifficulty ?? (currentPromptKey == 'breathingDifficulty' ? !lower.contains('no') : null)),
      chestPain: hasChestPain ? true : (currentData.chestPain ?? (currentPromptKey == 'chestPain' ? !lower.contains('no') : null)),
      severeBleeding: hasBleeding ? true : (currentData.severeBleeding ?? (currentPromptKey == 'severeBleeding' ? !lower.contains('no') : null)),
      majorTrauma: hasTrauma ? true : (currentData.majorTrauma ?? (currentPromptKey == 'majorTrauma' ? !lower.contains('no') : null)),
      seizure: hasSeizure ? true : (currentData.seizure ?? (currentPromptKey == 'seizure' ? !lower.contains('no') : null)),
      neurologicalSymptoms: neuroList.isNotEmpty ? neuroList : currentData.neurologicalSymptoms,
      age: extractedAge ?? currentData.age,
      medicalConditions: conditions.toSet().toList(),
    );
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/mira_conversation_state.dart';
import '../../domain/models/mira_message.dart';
import '../../domain/models/priority_level.dart';
import '../../domain/models/structured_triage_data.dart';
import '../../domain/models/triage_result.dart';
import '../../data/services/mira_api_service.dart';
import '../../domain/services/symptom_extraction_engine.dart';
import '../../domain/services/triage_engine.dart';

/// Riverpod StateNotifier managing MIRA's conversation lifecycle, message history,
/// natural-language extraction engine, and deterministic triage evaluation.
class MiraConversationNotifier extends StateNotifier<MiraConversationState> {
  MiraConversationNotifier([String? sessionId])
      : super(MiraConversationState.initial(sessionId ?? DateTime.now().millisecondsSinceEpoch.toString()));

  /// Process a patient's natural language input or option selection.
  void sendPatientMessage(String text) {
    if (text.trim().isEmpty || state.isProcessing) return;

    final userMessage = MiraMessage.patient(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
    );

    final updatedMessages = List<MiraMessage>.from(state.messages)..add(userMessage);

    // 1. Symptom Extraction via NLP / Regex Engine
    final updatedData = SymptomExtractionEngine.extractSymptoms(
      userText: text.trim(),
      currentData: state.structuredData,
      currentPromptKey: state.currentQuestionKey,
    );

    state = state.copyWith(
      messages: updatedMessages,
      structuredData: updatedData,
      isProcessing: true,
    );

    // 2. Async sync with Python FastAPI backend for database logging
    MiraApiService.sendTriageRequest(
      chiefComplaint: text.trim(),
      sessionId: state.sessionId,
      conversationHistory: state.messages.map((m) => {'speaker': m.sender == MiraSender.patient ? 'patient' : 'mira', 'text': m.text}).toList(),
    );

    // 3. Drive Conversation Turn & Triage Evaluation
    _processNextConversationTurn(updatedData);
  }

  /// Update a specific field directly (e.g. from UI sliders, switches, or form pickers).
  void answerFieldPrompt(String fieldKey, dynamic value) {
    StructuredTriageData newData = state.structuredData;

    switch (fieldKey) {
      case 'chiefComplaint':
        newData = newData.copyWith(chiefComplaint: value.toString());
        break;
      case 'onset':
        newData = newData.copyWith(onset: value.toString());
        break;
      case 'painLevel':
        newData = newData.copyWith(painLevel: (value as num).toInt());
        break;
      case 'conscious':
        newData = newData.copyWith(conscious: value as bool);
        break;
      case 'breathingDifficulty':
        newData = newData.copyWith(breathingDifficulty: value as bool);
        break;
      case 'chestPain':
        newData = newData.copyWith(chestPain: value as bool);
        break;
      case 'severeBleeding':
        newData = newData.copyWith(severeBleeding: value as bool);
        break;
      case 'majorTrauma':
        newData = newData.copyWith(majorTrauma: value as bool);
        break;
      case 'seizure':
        newData = newData.copyWith(seizure: value as bool);
        break;
      case 'age':
        newData = newData.copyWith(age: (value as num).toInt());
        break;
    }

    state = state.copyWith(structuredData: newData);
    _processNextConversationTurn(newData);
  }

  /// Update full structured data state directly.
  void updateStructuredData(StructuredTriageData newData) {
    state = state.copyWith(structuredData: newData);
  }

  /// Evaluate structured data against deterministic TriageEngine.
  void evaluateTriageEngine() {
    final result = TriageEngine.evaluate(state.structuredData);
    setTriageResult(result);
  }

  /// Apply triage engine result to state.
  void setTriageResult(TriageResult result) {
    state = state.copyWith(
      triageResult: result,
      phase: result.isEmergencyOverride
          ? MiraConversationPhase.emergencyEscalation
          : MiraConversationPhase.completed,
      isProcessing: false,
    );
  }

  /// Trigger emergency escalation directly.
  void triggerEmergencyEscalation(String reason) {
    final alertMessage = MiraMessage.mira(
      id: 'emergency_${DateTime.now().millisecondsSinceEpoch}',
      text: "🚨 CRITICAL RED FLAG DETECTED: $reason\n\n"
          "MIRA safety overrides have initiated immediate emergency response protocols. "
          "Please do not wait. You require urgent clinical emergency care.",
      requiresEmergencyAction: true,
    );

    final result = TriageEngine.evaluate(state.structuredData);

    state = state.copyWith(
      phase: MiraConversationPhase.emergencyEscalation,
      messages: List<MiraMessage>.from(state.messages)..add(alertMessage),
      triageResult: result,
      isProcessing: false,
    );
  }

  /// Reset to a fresh conversation session.
  void resetSession() {
    final newSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    state = MiraConversationState.initial(newSessionId);
  }

  // --- Internal Conversation Engine Mechanics ---

  void _processNextConversationTurn(StructuredTriageData data) {
    // Check critical red flags first (Emergency Override)
    if (data.conscious == false || data.seizure == true) {
      triggerEmergencyEscalation(
        data.conscious == false ? "Loss of consciousness reported." : "Active seizure reported.",
      );
      return;
    }

    MiraMessage nextMessage;
    MiraConversationPhase nextPhase = state.phase;
    String? nextKey;

    // Step 1: Onset question if missing
    if (data.onset == null || data.onset!.isEmpty) {
      nextPhase = MiraConversationPhase.collectingComplaint;
      nextKey = 'onset';
      nextMessage = MiraMessage.mira(
        id: 'msg_onset',
        text: "Understood. How long ago did these symptoms start?",
        quickReplies: ['Just started (< 15 mins)', '1-2 hours ago', 'Earlier today', 'Several days ago'],
        fieldPrompt: 'onset',
      );
    }
    // Step 2: Breathing difficulty if missing
    else if (data.breathingDifficulty == null) {
      nextPhase = MiraConversationPhase.collectingSymptoms;
      nextKey = 'breathingDifficulty';
      nextMessage = MiraMessage.mira(
        id: 'msg_breathing',
        text: "Are you experiencing any difficulty breathing, shortness of breath, or gasping for air?",
        quickReplies: ['Yes - Severe distress', 'Yes - Moderate shortness', 'No breathing difficulty'],
        fieldPrompt: 'breathingDifficulty',
      );
    }
    // Step 3: Chest pain if missing
    else if (data.chestPain == null) {
      nextPhase = MiraConversationPhase.collectingSymptoms;
      nextKey = 'chestPain';
      nextMessage = MiraMessage.mira(
        id: 'msg_chest',
        text: "Are you feeling any chest pain, tightness, or pressure radiating to your jaw or arm?",
        quickReplies: ['Yes - Severe chest pain', 'Yes - Mild pressure', 'No chest pain'],
        fieldPrompt: 'chestPain',
      );
    }
    // Step 4: Pain level if missing
    else if (data.painLevel == null) {
      nextPhase = MiraConversationPhase.followUpQuestions;
      nextKey = 'painLevel';
      nextMessage = MiraMessage.mira(
        id: 'msg_pain',
        text: "On a scale from 1 to 10 (where 10 is unbearable pain), how would you rate your current pain level?",
        quickReplies: ['1 - Mild', '4 - Moderate', '7 - Severe', '10 - Unbearable'],
        fieldPrompt: 'painLevel',
      );
    }
    // Step 5: Severe bleeding if missing
    else if (data.severeBleeding == null) {
      nextPhase = MiraConversationPhase.followUpQuestions;
      nextKey = 'severeBleeding';
      nextMessage = MiraMessage.mira(
        id: 'msg_bleeding',
        text: "Is there any severe or uncontrolled bleeding present?",
        quickReplies: ['Yes - Heavy bleeding', 'No severe bleeding'],
        fieldPrompt: 'severeBleeding',
      );
    }
    // Core questions answered -> Calculate deterministic TriageResult
    else {
      final triageResult = TriageEngine.evaluate(data);
      nextPhase = triageResult.isEmergencyOverride
          ? MiraConversationPhase.emergencyEscalation
          : MiraConversationPhase.completed;
      nextKey = null;
      nextMessage = MiraMessage.mira(
        id: 'msg_completed',
        text: "I have completed collecting your clinical information and evaluated your emergency priority level.\n\n"
            "Assigned Priority: ${triageResult.priority.label}\n"
            "Recommended Action: ${triageResult.recommendedAction}",
        requiresEmergencyAction: triageResult.priority == PriorityLevel.critical,
      );

      final updatedMessages = List<MiraMessage>.from(state.messages)..add(nextMessage);

      state = state.copyWith(
        messages: updatedMessages,
        phase: nextPhase,
        currentQuestionKey: null,
        triageResult: triageResult,
        isProcessing: false,
      );
      return;
    }

    final updatedMessages = List<MiraMessage>.from(state.messages)..add(nextMessage);

    state = state.copyWith(
      messages: updatedMessages,
      phase: nextPhase,
      currentQuestionKey: nextKey,
      isProcessing: false,
    );
  }
}

/// Global Riverpod provider for MIRA conversation state.
final miraConversationProvider =
    StateNotifierProvider.autoDispose<MiraConversationNotifier, MiraConversationState>((ref) {
  return MiraConversationNotifier();
});

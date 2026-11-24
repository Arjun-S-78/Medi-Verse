import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/mira_api_service.dart';
import '../../data/services/mira_dataset_repository.dart';
import '../../domain/models/mira_action_type.dart';
import '../../domain/models/mira_conversation_state.dart';
import '../../domain/models/mira_message.dart';
import '../../domain/models/structured_triage_data.dart';
import '../../domain/services/mira_intent_orchestrator.dart';
import '../../domain/services/symptom_extraction_engine.dart';
import '../../domain/services/triage_engine.dart';

/// Global Riverpod Provider for MiraConversationNotifier
final miraConversationProvider =
    StateNotifierProvider<MiraConversationNotifier, MiraConversationState>(
  (ref) => MiraConversationNotifier(),
);

/// Riverpod StateNotifier managing MIRA's AI Nurse conversation pipeline,
/// multi-turn context memory, dataset intent engine, and safety escalation rules.
class MiraConversationNotifier extends StateNotifier<MiraConversationState> {
  MiraConversationNotifier([String? sessionId])
      : super(MiraConversationState.initial(sessionId ?? DateTime.now().millisecondsSinceEpoch.toString())) {
    _initDataset();
  }

  /// Asynchronously load MIRA's 806-entry intent dataset.
  Future<void> _initDataset() async {
    await MiraDatasetRepository().loadDataset();
  }

  /// Process a patient's natural language message or option selection.
  Future<void> sendPatientMessage(String text) async {
    if (text.trim().isEmpty || state.isProcessing) return;

    final userText = text.trim();
    final userMessage = MiraMessage.patient(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      text: userText,
    );

    final updatedMessages = List<MiraMessage>.from(state.messages)..add(userMessage);

    // 1. Symptom Extraction via Local NLP Engine
    final updatedData = SymptomExtractionEngine.extractSymptoms(
      userText: userText,
      currentData: state.structuredData,
      currentPromptKey: state.currentQuestionKey,
    );

    state = state.copyWith(
      messages: updatedMessages,
      structuredData: updatedData,
      isProcessing: true,
    );

    // 2. MIRA Intent Engine Evaluation (Dataset + Rules + Safety)
    final intentResult = MiraIntentOrchestrator.parseIntent(
      userText,
      previousIntent: state.currentIntent,
    );

    // Update conversation context tracking
    final newEntities = Map<String, dynamic>.from(state.collectedEntities)
      ..addAll(intentResult.entities.toMap());

    state = state.copyWith(
      previousIntent: state.currentIntent,
      currentIntent: intentResult.intent,
      collectedEntities: newEntities,
      requiresEscalation: intentResult.requiresEscalation,
      pendingAction: intentResult.actionType,
    );

    // 3. EMERGENCY SAFETY PATHWAY (Immediate Override)
    if (intentResult.requiresEscalation) {
      final emergencyMsg = MiraMessage.mira(
        id: 'msg_emerg_${DateTime.now().millisecondsSinceEpoch}',
        text: intentResult.miraResponse,
        requiresEmergencyAction: true,
        quickReplies: [
          'Dispatch Ambulance (108)',
          'View Nearest Trauma Hospital',
          'I need urgent help',
        ],
      );

      state = state.copyWith(
        messages: List<MiraMessage>.from(state.messages)..add(emergencyMsg),
        phase: MiraConversationPhase.emergencyEscalation,
        isProcessing: false,
      );
      return;
    }

    // 4. Async sync with Python FastAPI backend if available
    final apiResponse = await MiraApiService.sendTriageRequest(
      chiefComplaint: userText,
      sessionId: state.sessionId,
      conversationHistory: state.messages
          .map((m) => {'speaker': m.sender == MiraSender.patient ? 'patient' : 'mira', 'text': m.text})
          .toList(),
    );

    String replyText = intentResult.miraResponse;
    bool isCritical = false;

    if (apiResponse != null && apiResponse['mira_reply'] != null) {
      replyText = apiResponse['mira_reply'];
      isCritical = apiResponse['priority_level'] == 'CRITICAL';
    }

    // Determine quick replies based on intent & action
    List<String>? quickReplies;
    if (intentResult.actionType == MiraActionType.searchHospital) {
      quickReplies = ['Open Hospital Radar', 'ICU Bed Availability', 'Trauma Centers'];
    } else if (intentResult.actionType == MiraActionType.bookDoctor) {
      quickReplies = ['Book Cardiologist', 'Book General Physician', 'Book Specialist'];
    } else if (intentResult.actionType == MiraActionType.symptomGuidance) {
      quickReplies = ['Pain is Severe', 'Pain is Moderate', 'Started Today', 'Since Yesterday'];
    } else {
      quickReplies = ['Check Symptoms', 'Find Hospital', 'Book Doctor'];
    }

    final miraResponseMsg = MiraMessage.mira(
      id: 'msg_mira_${DateTime.now().millisecondsSinceEpoch}',
      text: replyText,
      requiresEmergencyAction: isCritical,
      quickReplies: quickReplies,
    );

    state = state.copyWith(
      messages: List<MiraMessage>.from(state.messages)..add(miraResponseMsg),
      isProcessing: false,
      phase: isCritical ? MiraConversationPhase.emergencyEscalation : state.phase,
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
      quickReplies: ['Call Emergency 108', 'Alert Nearest Trauma Center'],
    );

    final result = TriageEngine.evaluate(state.structuredData);

    state = state.copyWith(
      phase: MiraConversationPhase.emergencyEscalation,
      messages: List<MiraMessage>.from(state.messages)..add(alertMessage),
      triageResult: result,
      requiresEscalation: true,
      isProcessing: false,
    );
  }

  /// Direct field prompt response handler for sliders, form pickers, or buttons.
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
    sendPatientMessage(value.toString());
  }

  /// Reset session to a fresh conversation.
  void resetSession() {
    final newSessionId = DateTime.now().millisecondsSinceEpoch.toString();
    state = MiraConversationState.initial(newSessionId);
  }

  /// Mark message streaming/typewriter animation as complete.
  void markMessageStreamingComplete(String messageId) {
    final updated = state.messages.map((m) {
      if (m.id == messageId && m.isStreaming) {
        return m.withStreamingComplete();
      }
      return m;
    }).toList();
    state = state.copyWith(messages: updated);
  }

  /// Evaluate triage engine deterministically.
  void evaluateTriageEngine() {
    final result = TriageEngine.evaluate(state.structuredData);
    state = state.copyWith(
      triageResult: result,
      phase: result.isEmergencyOverride
          ? MiraConversationPhase.emergencyEscalation
          : MiraConversationPhase.completed,
      isProcessing: false,
    );
  }
}

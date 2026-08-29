import 'mira_message.dart';
import 'structured_triage_data.dart';
import 'triage_result.dart';

enum MiraConversationPhase {
  welcome,
  collectingComplaint,
  collectingSymptoms,
  followUpQuestions,
  assessing,
  completed,
  emergencyEscalation,
}

/// Immutable state container representing MIRA's active conversation state.
class MiraConversationState {
  final String sessionId;
  final MiraConversationPhase phase;
  final List<MiraMessage> messages;
  final StructuredTriageData structuredData;
  final String? currentQuestionKey;
  final bool isProcessing;
  final String? errorMessage;
  final TriageResult? triageResult;
  final DateTime startedAt;

  const MiraConversationState({
    required this.sessionId,
    required this.phase,
    required this.messages,
    required this.structuredData,
    this.currentQuestionKey,
    required this.isProcessing,
    this.errorMessage,
    this.triageResult,
    required this.startedAt,
  });

  /// Factory for initial state when starting a new session.
  factory MiraConversationState.initial(String sessionId) {
    final now = DateTime.now();
    return MiraConversationState(
      sessionId: sessionId,
      phase: MiraConversationPhase.welcome,
      messages: [
        MiraMessage.mira(
          id: 'welcome_1',
          text: "Hello, I am MIRA — your AI-Assisted Emergency Triage Nurse.\n\n"
              "I am here to understand your symptoms and help evaluate your situation. "
              "I am an emergency support assistant, NOT a doctor, and I do not diagnose medical conditions.\n\n"
              "If this is a life-threatening medical emergency, call 911 or your local emergency number immediately.\n\n"
              "What main symptom or chief complaint brings you here today?",
          quickReplies: [
            'Chest pain or pressure',
            'Shortness of breath',
            'Severe bleeding / injury',
            'Sudden numbness / weakness',
            'Severe abdominal pain',
          ],
          fieldPrompt: 'chiefComplaint',
        ),
      ],
      structuredData: StructuredTriageData.empty(),
      currentQuestionKey: 'chiefComplaint',
      isProcessing: false,
      errorMessage: null,
      triageResult: null,
      startedAt: now,
    );
  }

  bool get isCompleted => phase == MiraConversationPhase.completed;
  bool get isEmergencyEscalation => phase == MiraConversationPhase.emergencyEscalation;
  MiraMessage? get lastMessage => messages.isNotEmpty ? messages.last : null;

  MiraConversationState copyWith({
    String? sessionId,
    MiraConversationPhase? phase,
    List<MiraMessage>? messages,
    StructuredTriageData? structuredData,
    String? currentQuestionKey,
    bool? isProcessing,
    String? errorMessage,
    TriageResult? triageResult,
    DateTime? startedAt,
  }) {
    return MiraConversationState(
      sessionId: sessionId ?? this.sessionId,
      phase: phase ?? this.phase,
      messages: messages ?? this.messages,
      structuredData: structuredData ?? this.structuredData,
      currentQuestionKey: currentQuestionKey ?? this.currentQuestionKey,
      isProcessing: isProcessing ?? this.isProcessing,
      errorMessage: errorMessage ?? this.errorMessage,
      triageResult: triageResult ?? this.triageResult,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}

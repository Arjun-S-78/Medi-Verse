import 'mira_action_type.dart';
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

  // Enhanced Context Memory attributes
  final String? currentIntent;
  final String? previousIntent;
  final Map<String, dynamic> collectedEntities;
  final String? severity;
  final bool requiresEscalation;
  final MiraActionType? pendingAction;
  final String? pendingQuestion;

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
    this.currentIntent,
    this.previousIntent,
    this.collectedEntities = const {},
    this.severity,
    this.requiresEscalation = false,
    this.pendingAction,
    this.pendingQuestion,
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
          text: "Hi! I'm your MediVerse Clinical Health Assistant.\n\n"
              "How can I help you today?",
          quickReplies: [
            'Find a Hospital',
            'I have chest pain',
            'I can\'t breathe',
            'Book a Doctor',
            'Call Ambulance',
          ],
          fieldPrompt: 'chiefComplaint',
          isStreaming: false,
        ),
      ],
      structuredData: StructuredTriageData.empty(),
      currentQuestionKey: 'chiefComplaint',
      isProcessing: false,
      errorMessage: null,
      triageResult: null,
      startedAt: now,
      currentIntent: 'greeting',
      previousIntent: null,
      collectedEntities: const {},
      requiresEscalation: false,
      pendingAction: null,
      pendingQuestion: null,
    );
  }

  bool get isCompleted => phase == MiraConversationPhase.completed;
  bool get isEmergencyEscalation => phase == MiraConversationPhase.emergencyEscalation || requiresEscalation;
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
    String? currentIntent,
    String? previousIntent,
    Map<String, dynamic>? collectedEntities,
    String? severity,
    bool? requiresEscalation,
    MiraActionType? pendingAction,
    String? pendingQuestion,
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
      currentIntent: currentIntent ?? this.currentIntent,
      previousIntent: previousIntent ?? this.previousIntent,
      collectedEntities: collectedEntities ?? this.collectedEntities,
      severity: severity ?? this.severity,
      requiresEscalation: requiresEscalation ?? this.requiresEscalation,
      pendingAction: pendingAction ?? this.pendingAction,
      pendingQuestion: pendingQuestion ?? this.pendingQuestion,
    );
  }
}

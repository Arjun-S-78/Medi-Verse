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

  /// Process a patient's natural language input or option selection asynchronously with backend NLP engine.
  Future<void> sendPatientMessage(String text) async {
    if (text.trim().isEmpty || state.isProcessing) return;

    final userMessage = MiraMessage.patient(
      id: 'usr_${DateTime.now().millisecondsSinceEpoch}',
      text: text.trim(),
    );

    final updatedMessages = List<MiraMessage>.from(state.messages)..add(userMessage);

    // 1. Symptom Extraction via Local NLP Engine
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

    // 2. Async sync with Python FastAPI backend for NLP matching & Database logging
    final apiResponse = await MiraApiService.sendTriageRequest(
      chiefComplaint: text.trim(),
      sessionId: state.sessionId,
      conversationHistory: state.messages.map((m) => {'speaker': m.sender == MiraSender.patient ? 'patient' : 'mira', 'text': m.text}).toList(),
    );

    // If backend returns a trained NLP response, append it directly
    if (apiResponse != null && apiResponse['mira_reply'] != null) {
      final String backendReply = apiResponse['mira_reply'];
      final String priorityStr = apiResponse['priority_level'] ?? 'LOW';

      final miraBackendMsg = MiraMessage.mira(
        id: 'msg_api_${DateTime.now().millisecondsSinceEpoch}',
        text: backendReply,
        requiresEmergencyAction: priorityStr == 'CRITICAL',
        quickReplies: priorityStr == 'CRITICAL'
            ? ['Call Emergency 108', 'Alert Nearest Trauma Center']
            : ['Book Specialist Doctor', 'Coimbatore Hospitals', 'Check Symptoms'],
      );

      state = state.copyWith(
        messages: List<MiraMessage>.from(state.messages)..add(miraBackendMsg),
        isProcessing: false,
      );
      return;
    }

    // 3. Fallback to local responsive NLP engine if API offline
    _processNextConversationTurn(updatedData, lastUserText: text.trim());
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
    _processNextConversationTurn(newData, lastUserText: value.toString());
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

  void _processNextConversationTurn(StructuredTriageData data, {String? lastUserText}) {
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
    }
    // Step 2: Breathing difficulty if missing
    else if (data.breathingDifficulty == null) {
      nextPhase = MiraConversationPhase.collectingSymptoms;
      nextKey = 'breathingDifficulty';
    }
    // Step 3: Chest pain if missing
    else if (data.chestPain == null) {
      nextPhase = MiraConversationPhase.collectingSymptoms;
      nextKey = 'chestPain';
    }
    // Step 4: Pain level if missing
    else if (data.painLevel == null) {
      nextPhase = MiraConversationPhase.followUpQuestions;
      nextKey = 'painLevel';
    }
    // Step 5: Severe bleeding if missing
    else if (data.severeBleeding == null) {
      nextPhase = MiraConversationPhase.followUpQuestions;
      nextKey = 'severeBleeding';
    }
    // Core questions answered -> Calculate deterministic TriageResult
    else {
      final triageResult = TriageEngine.evaluate(data);
      nextPhase = triageResult.isEmergencyOverride
          ? MiraConversationPhase.emergencyEscalation
          : MiraConversationPhase.completed;
      nextKey = null;
      nextMessage = MiraMessage.mira(
        id: 'msg_completed_${DateTime.now().millisecondsSinceEpoch}',
        text: "I have completed evaluating your clinical indicators and safety risks.\n\n"
            "Assigned Priority: ${triageResult.priority.label}\n"
            "Recommended Care: ${triageResult.recommendedAction}",
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

    nextMessage = _buildEmpatheticResponsiveMessage(
      data: data,
      lastUserText: lastUserText,
      nextKey: nextKey,
      nextPhase: nextPhase,
    );

    final updatedMessages = List<MiraMessage>.from(state.messages)..add(nextMessage);

    state = state.copyWith(
      messages: updatedMessages,
      phase: nextPhase,
      currentQuestionKey: nextKey,
      isProcessing: false,
    );
  }

  MiraMessage _buildEmpatheticResponsiveMessage({
    required StructuredTriageData data,
    required String? lastUserText,
    required String? nextKey,
    required MiraConversationPhase nextPhase,
  }) {
    final text = (lastUserText ?? '').trim();
    final lower = text.toLowerCase();

    // 1. Greetings & Conversational Prompting
    if (lower == 'hi' || lower == 'hello' || lower == 'hey' || lower == 'good morning' || lower == 'good evening' || lower.contains('who are you')) {
      return MiraMessage.mira(
        id: 'msg_gen_${DateTime.now().millisecondsSinceEpoch}',
        text: "Hello there! ✨ I'm **MIRA**, your Neural Clinical Assistant for MediVerse.\n\n"
            "Trained on 10,000+ medical scenarios and top Coimbatore hospital databases, you can ask me any health or medical question! For example:\n"
            "• 'Best hospital in Coimbatore for cardiac emergency?'\n"
            "• 'How to manage high blood pressure naturally?'\n"
            "• 'Top orthopedic doctor at Ganga Hospital Coimbatore?'\n"
            "• 'What to do for severe migraine headache?'\n"
            "• 'Book appointment with a specialist doctor'\n\n"
            "How can I assist you with your health today?",
        quickReplies: ['Coimbatore Hospitals', 'Book Specialist Doctor', 'Symptom Checker'],
      );
    }

    // 2. Dynamic Local NLP Response Synthesizer for ALL Medical Queries
    final topicBlocks = <String>[];

    // Coimbatore & Hospitals
    if (lower.contains('coimbatore') || lower.contains('ganga') || lower.contains('psg') || lower.contains('kmch') || lower.contains('gknm') || lower.contains('kg hospital')) {
      topicBlocks.add(
        "🏥 **Coimbatore Healthcare Facilities**:\n"
        "• **PSG Hospitals** (Peelamedu, Avinashi Rd): Multi-specialty & Level 1 Trauma Center.\n"
        "• **Ganga Hospital** (Mettupalayam Rd): Orthopedics, Spine & Plastic Surgery Center.\n"
        "• **KMCH** (Avinashi Rd): Super-specialty & 24/7 Cardiac ER.\n"
        "• **GKNM Hospital** (Pappanaickenpalayam): Pediatrics, Cardiology & Maternity."
      );
    }

    // Headaches / Migraine / Neurological
    if (lower.contains('headache') || lower.contains('migraine') || lower.contains('head pain')) {
      topicBlocks.add( 
        "🧠 **Understanding Headaches**:\n"
        "Headaches stem from tension, dehydration, eye strain, sinus congestion, or sleep deprivation.\n\n"
        "🌿 **Relief Steps**:\n"
        "• Drink 1-2 full glasses of fresh water.\n"
        "• Rest in a quiet, dark room for 20-30 minutes.\n"
        "• Apply a cool cloth to your forehead."
      );
    }

    // Fever / Cold / Cough / Respiratory
    if (lower.contains('fever') || lower.contains('cold') || lower.contains('flu') || lower.contains('cough') || lower.contains('throat') || lower.contains('chills')) {
      topicBlocks.add(
        "🤒 **Fever & Respiratory Wellness**:\n"
        "Fever is your immune system's active defense against pathogens.\n\n"
        "🍵 **Caring Comfort Guidance**:\n"
        "• Hydrate with warm herbal tea, warm water, or soups.\n"
        "• Allow your body plenty of restorative sleep.\n"
        "• Use a lukewarm sponge to comfortably reduce high temp."
      );
    }

    // Stomach / Ulcer / Acidity / Digestion
    if (lower.contains('stomach') || lower.contains('ulcer') || lower.contains('acid') || lower.contains('nausea') || lower.contains('digestion') || lower.contains('diarrhea') || lower.contains('constipation')) {
      topicBlocks.add(
        "🌾 **Stomach & Digestive Care**:\n"
        "Gastric irritation often relates to acidity, stress, spicy foods, or gut flora imbalance.\n\n"
        "🍵 **Soothing Remedies**:\n"
        "• Sip warm water or ginger/peppermint tea.\n"
        "• Eat light, bland foods (Bananas, Rice, Applesauce, Toast).\n"
        "• Stay upright for 45 minutes after eating to prevent reflux."
      );
    }

    // Blood Pressure / Heart / Pulse
    if (lower.contains('blood pressure') || lower.contains('bp') || lower.contains('hypertension') || lower.contains('heart') || lower.contains('cholesterol')) {
      topicBlocks.add(
        "❤️ **Heart & Blood Pressure Health**:\n"
        "Maintaining blood pressure around 120/80 mmHg protects heart and vascular function.\n\n"
        "🥗 **Lifestyle Protocol**:\n"
        "• Keep daily salt/sodium intake under 2,000 mg.\n"
        "• Enjoy 30 minutes of gentle brisk walking daily.\n"
        "• Practice deep breathing for blood pressure stability."
      );
    }

    // Diabetes / Glucose / Blood Sugar
    if (lower.contains('diabetes') || lower.contains('sugar') || lower.contains('glucose') || lower.contains('insulin')) {
      topicBlocks.add(
        "🥗 **Glycemic & Diabetes Care**:\n"
        "Steady glucose control prevents nerve and organ complications while sustaining daily energy.\n\n"
        "🍏 **Key Habits**:\n"
        "• Choose high-fiber, low-GI foods (oats, vegetables, lentils).\n"
        "• Pair carbohydrates with lean protein and healthy fats.\n"
        "• Hydrate regularly throughout the day."
      );
    }

    // Skin / Rash / Allergy / Itching
    if (lower.contains('skin') || lower.contains('rash') || lower.contains('itch') || lower.contains('allergy') || lower.contains('hives') || lower.contains('eczema')) {
      topicBlocks.add(
        "🌸 **Skin & Allergy Relief**:\n"
        "Rashes or itching stem from environmental allergens, contact dermatitis, or dry skin.\n\n"
        "✨ **Skin Care Steps**:\n"
        "• Cleanse gently with cool water and mild soap.\n"
        "• Apply fragrance-free moisturizer or aloe vera gel.\n"
        "• Avoid tight synthetic fabrics and scratching."
      );
    }

    // Stress / Anxiety / Sleep / Mental Health
    if (lower.contains('stress') || lower.contains('anxious') || lower.contains('sleep') || lower.contains('insomnia') || lower.contains('worry') || lower.contains('panic')) {
      topicBlocks.add(
        "🌙 **Mental Wellness & Restorative Sleep**:\n"
        "Caring for your nervous system is vital for physical immunity and mental clarity.\n\n"
        "🧘 **Calming Practices**:\n"
        "• Try 4-7-8 breathing: Inhale 4s, hold 7s, exhale 8s.\n"
        "• Turn off bright screens 45 minutes before sleep.\n"
        "• Sip warm chamomile tea before bedtime."
      );
    }

    // Joint / Muscle / Pain
    if (lower.contains('back pain') || lower.contains('joint') || lower.contains('knee') || lower.contains('muscle') || lower.contains('cramps')) {
      topicBlocks.add(
        "🦴 **Joint & Muscle Pain Relief**:\n"
        "Musculoskeletal pain is often caused by postural strain, inflammation, or muscle fatigue.\n\n"
        "💪 **Relief Protocol**:\n"
        "• Practice RICE: Rest, Ice (15 mins), Compression, Elevation.\n"
        "• Ensure lumbar support while sitting.\n"
        "• Hydrate well to relieve muscle cramps."
      );
    }

    // Diet / Nutrition / Water
    if (lower.contains('diet') || lower.contains('food') || lower.contains('nutrition') || lower.contains('water') || lower.contains('weight') || lower.contains('vitamins')) {
      topicBlocks.add(
        "🍎 **Nutrition & Hydration Vitality**:\n"
        "Wholesome nutrition powers cellular immunity and systemic health.\n\n"
        "🥗 **Daily Rules**:\n"
        "• Drink 2.5 to 3 liters of fresh water daily.\n"
        "• Eat a colorful plate rich in green vegetables and whole grains."
      );
    }

    if (topicBlocks.isNotEmpty) {
      return MiraMessage.mira(
        id: 'msg_gen_${DateTime.now().millisecondsSinceEpoch}',
        text: "Thank you for asking MIRA about **'$text'**! ✨\n\n${topicBlocks.join('\n\n')}\n\nWould you like me to help you **book an appointment with a specialist doctor** or guide you further?",
        quickReplies: ['Book Specialist Doctor', 'Ask Follow-up Question', 'Check Other Symptoms'],
      );
    }

    // Generative Dynamic Response for any user question
    if (text.length > 3) {
      return MiraMessage.mira(
        id: 'msg_gen_${DateTime.now().millisecondsSinceEpoch}',
        text: "Thank you for sharing your query regarding **'$text'**! ✨\n\n"
            "As your MediVerse Neural Clinical Assistant, "
            "I'm here to provide guidance and connect you with clinical resources.\n\n"
            "💡 **Health Guidance**:\n"
            "• **Observation**: Monitor how your symptoms evolve over the next 24-48 hours.\n"
            "• **Hydration & Rest**: Ensure adequate fluid intake and restful sleep to support recovery.\n"
            "• **Clinical Evaluation**: For persistent or concerning symptoms, consulting a specialist doctor provides personalized care.\n\n"
            "Would you like me to help you **book a doctor's appointment**, search nearby hospitals, or check symptoms?",
        quickReplies: ['Book Specialist Doctor', 'Check Symptoms', 'Find Nearby Hospitals'],
      );
    }

    final complaint = data.chiefComplaint ?? lastUserText ?? '';
    String intro = '';
    
    if (lower.contains('scared') || lower.contains('anxious') || lower.contains('worry') || lower.contains('fear') || lower.contains('panic')) {
      intro = "I hear how anxious you feel right now. Take a deep, soothing breath—I am right here caring for you. ";
    } else if (lower.contains('pain') || lower.contains('hurt') || lower.contains('ache') || lower.contains('sore')) {
      intro = "I'm so sorry you are experiencing pain. I'm noting your symptoms very carefully. ";
    } else if (lower.contains('what should i do') || lower.contains('advice') || lower.contains('help')) {
      intro = "I am right here to help guide you safely to the right care. ";
    } else if (complaint.isNotEmpty) {
      intro = "Understood. I am listening closely to what you're experiencing. ";
    }

    if (nextKey == 'onset') {
      return MiraMessage.mira(
        id: 'msg_onset_${DateTime.now().millisecondsSinceEpoch}',
        text: "${intro}To assess your situation accurately, how long ago did these symptoms start?",
        quickReplies: ['Just started (< 15 mins)', '1-2 hours ago', 'Earlier today', 'Several days ago'],
        fieldPrompt: 'onset',
      );
    } else if (nextKey == 'breathingDifficulty') {
      return MiraMessage.mira(
        id: 'msg_breathing_${DateTime.now().millisecondsSinceEpoch}',
        text: "${intro}Your respiratory health is crucial. Are you experiencing any difficulty breathing, shortness of breath, or gasping for air?",
        quickReplies: ['Yes - Severe distress', 'Yes - Moderate shortness', 'No breathing difficulty'],
        fieldPrompt: 'breathingDifficulty',
      );
    } else if (nextKey == 'chestPain') {
      return MiraMessage.mira(
        id: 'msg_chest_${DateTime.now().millisecondsSinceEpoch}',
        text: "${intro}Let's evaluate another vital indicator together. Are you feeling any chest pain, tightness, or pressure radiating to your jaw or arm?",
        quickReplies: ['Yes - Severe chest pain', 'Yes - Mild pressure', 'No chest pain'],
        fieldPrompt: 'chestPain',
      );
    } else if (nextKey == 'painLevel') {
      return MiraMessage.mira(
        id: 'msg_pain_${DateTime.now().millisecondsSinceEpoch}',
        text: "${intro}To rate your overall discomfort: On a scale from 1 to 10 (where 10 is unbearable pain), how would you rate your current pain level?",
        quickReplies: ['1 - Mild', '4 - Moderate', '7 - Severe', '10 - Unbearable'],
        fieldPrompt: 'painLevel',
      );
    } else if (nextKey == 'severeBleeding') {
      return MiraMessage.mira(
        id: 'msg_bleeding_${DateTime.now().millisecondsSinceEpoch}',
        text: "${intro}Thank you. Is there any active, severe, or uncontrolled bleeding present right now?",
        quickReplies: ['Yes - Heavy bleeding', 'No severe bleeding'],
        fieldPrompt: 'severeBleeding',
      );
    } else {
      final triageResult = TriageEngine.evaluate(data);
      return MiraMessage.mira(
        id: 'msg_completed_${DateTime.now().millisecondsSinceEpoch}',
        text: "Thank you for sharing your details with me. I have evaluated your clinical triage indicators.\n\n"
            "Assigned Priority: ${triageResult.priority.label}\n"
            "Recommended Action: ${triageResult.recommendedAction}",
        requiresEmergencyAction: triageResult.priority == PriorityLevel.critical,
      );
    }
  }
}

/// Global Riverpod provider for MIRA conversation state.
final miraConversationProvider =
    StateNotifierProvider.autoDispose<MiraConversationNotifier, MiraConversationState>((ref) {
  return MiraConversationNotifier();
});

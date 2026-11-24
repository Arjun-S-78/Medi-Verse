import '../../../../app/router/route_names.dart';
import '../../data/services/mira_dataset_repository.dart';
import '../models/mira_action_type.dart';
import '../models/mira_intent_record.dart';
import '../models/mira_mode.dart';
import '../models/mira_safety_rule.dart';
import 'mira_entity_extractor.dart';

/// Legacy enum provided for backwards compatibility across existing views & tests.
enum MiraIntentType {
  findDoctor,
  searchHospital,
  bookAppointment,
  emergencyTriage,
  trackAmbulance,
  receptionCheckIn,
  generalQuery,
}

/// Comprehensive Result produced by MIRA Intent Engine.
class MiraIntentResult {
  final String intent;
  final String category;
  final MiraMode targetMode;
  final String routeTarget;
  final MiraActionType actionType;
  final MiraExtractedEntities entities;
  final String miraResponse;
  final bool requiresEscalation;
  final String? safetyNote;

  const MiraIntentResult({
    required this.intent,
    required this.category,
    required this.targetMode,
    required this.routeTarget,
    required this.actionType,
    required this.entities,
    required this.miraResponse,
    required this.requiresEscalation,
    this.safetyNote,
  });

  /// Compatibility getter for legacy MiraIntentType.
  MiraIntentType get intentType {
    if (requiresEscalation || intent == 'ambulance' || intent == 'chest_pain' || intent == 'breathing_difficulty') {
      return MiraIntentType.emergencyTriage;
    }
    if (actionType == MiraActionType.searchDoctor || actionType == MiraActionType.bookDoctor) {
      return MiraIntentType.findDoctor;
    }
    if (actionType == MiraActionType.searchHospital || actionType == MiraActionType.searchClinic) {
      return MiraIntentType.searchHospital;
    }
    if (actionType == MiraActionType.callAmbulance) {
      return MiraIntentType.trackAmbulance;
    }
    if (actionType == MiraActionType.setMedicationReminder) {
      return MiraIntentType.receptionCheckIn;
    }
    return MiraIntentType.generalQuery;
  }

  /// Compatibility getter for extracted entity string.
  String? get extractedEntity => entities.specialty ?? entities.symptom ?? entities.city;
}

/// MIRA Intent Orchestrator & AI Nurse Processing Engine.
///
/// Orchestrates dataset reference matching, fuzzy intent detection,
/// entity extraction, emergency safety evaluation, and action selection.
class MiraIntentOrchestrator {
  /// Process patient prompt text through the full MIRA Intent Engine pipeline.
  static MiraIntentResult parseIntent(String prompt, {String? previousIntent}) {
    final text = prompt.trim();
    if (text.isEmpty) {
      return const MiraIntentResult(
        intent: 'greeting',
        category: 'conversation',
        targetMode: MiraMode.normal,
        routeTarget: RouteNames.home,
        actionType: MiraActionType.respondGreeting,
        entities: MiraExtractedEntities(),
        miraResponse: "Hi! I'm your MediVerse Clinical Assistant. How can I help you today?",
        requiresEscalation: false,
      );
    }

    final lower = text.toLowerCase();
    final entities = MiraEntityExtractor.extract(text);

    // 1. EMERGENCY SAFETY EVALUATION (Highest Priority Guardrail)
    final isEmergencyKeyword = MiraSafetyRule.hasEmergencyKeyword(text);

    if (isEmergencyKeyword) {
      String emergencyIntent = 'chest_pain';
      if (lower.contains('chest pain') || lower.contains('chest hurts') || lower.contains('heart attack')) {
        emergencyIntent = 'chest_pain';
      } else if (lower.contains('breathe') || lower.contains('breath') || lower.contains('moochu')) {
        emergencyIntent = 'breathing_difficulty';
      } else if (lower.contains('bleeding')) {
        emergencyIntent = 'severe_bleeding';
      } else if (lower.contains('unconscious') || lower.contains('passed out')) {
        emergencyIntent = 'unconscious';
      } else if (lower.contains('seizure')) {
        emergencyIntent = 'seizure';
      } else if (lower.contains('stroke') || lower.contains('numbness')) {
        emergencyIntent = 'stroke_warning';
      } else if (lower.contains('allergic') || lower.contains('anaphylaxis')) {
        emergencyIntent = 'severe_allergic_reaction';
      } else if (lower.contains('ambulance') || lower.contains('sos') || lower.contains('108')) {
        emergencyIntent = 'ambulance';
      }

      String emergencyResponse =
          "🚨 I'm detecting signs that could be a medical emergency. Are you able to speak normally right now?\n\n"
          "If you are severely struggling to breathe or having severe symptoms, please seek emergency medical help or dispatch an ambulance immediately.";

      if (emergencyIntent == 'ambulance') {
        emergencyResponse =
            "🚨 Dispatching MediVerse Ambulance Protocol. I am accessing your location to connect with the nearest emergency fleet.";
      }

      return MiraIntentResult(
        intent: emergencyIntent,
        category: 'emergency',
        targetMode: MiraMode.emergency,
        routeTarget: RouteNames.liveTracking,
        actionType: MiraActionType.callAmbulance,
        entities: entities,
        miraResponse: emergencyResponse,
        requiresEscalation: true,
        safetyNote: 'Emergency escalation protocol initiated.',
      );
    }

    // 2. IN-MEMORY DATASET SEARCH MATCHING (806 Reference Dataset Entries)
    final datasetMatch = MiraDatasetRepository().findBestMatch(text);
    if (datasetMatch != null) {
      return _buildResultFromDatasetRecord(datasetMatch, entities, text);
    }

    // 3. RULE-BASED FALLBACK INTENT CLASSIFICATION

    // Healthcare Services: Hospitals & Clinics
    if (lower.contains('hospital') || lower.contains('clinic') || lower.contains('icu') || lower.contains('er bed') || lower.contains('trauma')) {
      return MiraIntentResult(
        intent: 'find_hospital',
        category: 'healthcare_service',
        targetMode: MiraMode.search,
        routeTarget: RouteNames.hospitalSearch,
        actionType: MiraActionType.searchHospital,
        entities: entities,
        miraResponse: "Sure. I'll find nearby hospitals and emergency centers for you.",
        requiresEscalation: false,
      );
    }

    // Doctor Booking & Consultation
    if (lower.contains('doctor') || lower.contains('specialist') || lower.contains('consult') || lower.contains('appoint') || lower.contains('book')) {
      final spec = entities.specialty ?? 'General Physician';
      return MiraIntentResult(
        intent: 'book_doctor',
        category: 'appointment',
        targetMode: MiraMode.appointment,
        routeTarget: RouteNames.doctorBooking,
        actionType: MiraActionType.bookDoctor,
        entities: entities,
        miraResponse: "Sure. I'll help you find a top-rated $spec for appointment booking.",
        requiresEscalation: false,
      );
    }

    // Symptoms (Headache, Fever, Stomach pain, Cough, Dizziness)
    if (lower.contains('headache') || lower.contains('head pain')) {
      return MiraIntentResult(
        intent: 'headache',
        category: 'symptom',
        targetMode: MiraMode.normal,
        routeTarget: RouteNames.triageAssess,
        actionType: MiraActionType.symptomGuidance,
        entities: entities,
        miraResponse: "I can help you assess your headache. When did it start, and is the pain mild, moderate, or severe?",
        requiresEscalation: false,
      );
    }

    if (lower.contains('fever') || lower.contains('temperature') || lower.contains('chills')) {
      return MiraIntentResult(
        intent: 'fever',
        category: 'symptom',
        targetMode: MiraMode.normal,
        routeTarget: RouteNames.triageAssess,
        actionType: MiraActionType.symptomGuidance,
        entities: entities,
        miraResponse: "Got it. Have you measured your body temperature, and how many days have you had the fever?",
        requiresEscalation: false,
      );
    }

    if (lower.contains('stomach') || lower.contains('abdominal') || lower.contains('belly')) {
      return MiraIntentResult(
        intent: 'stomach_pain',
        category: 'symptom',
        targetMode: MiraMode.normal,
        routeTarget: RouteNames.triageAssess,
        actionType: MiraActionType.symptomGuidance,
        entities: entities,
        miraResponse: "I understand. Tell me where the stomach pain is located and whether you feel nauseous.",
        requiresEscalation: false,
      );
    }

    // Greetings & Identity
    if (lower.contains('hi') || lower.contains('hello') || lower.contains('hey') || lower.contains('mira')) {
      return const MiraIntentResult(
        intent: 'greeting',
        category: 'conversation',
        targetMode: MiraMode.normal,
        routeTarget: RouteNames.home,
        actionType: MiraActionType.respondGreeting,
        entities: MiraExtractedEntities(),
        miraResponse: "Hi! I'm your MediVerse Assistant. How can I help you today?",
        requiresEscalation: false,
      );
    }

    // Default General Guidance Response
    return MiraIntentResult(
      intent: 'unknown',
      category: 'fallback',
      targetMode: MiraMode.normal,
      routeTarget: RouteNames.home,
      actionType: MiraActionType.clarifyRequest,
      entities: entities,
      miraResponse: "I'm here to help you navigate MediVerse, check symptoms, find hospitals, or book doctor appointments. Tell me a bit more about what you need.",
      requiresEscalation: false,
    );
  }

  /// Construct MiraIntentResult from a matched MiraIntentRecord entry.
  static MiraIntentResult _buildResultFromDatasetRecord(
    MiraIntentRecord record,
    MiraExtractedEntities entities,
    String rawPrompt,
  ) {
    MiraMode mode = MiraMode.normal;
    String route = RouteNames.home;

    if (record.requiresEscalation || MiraSafetyRule.isEmergencyIntent(record.intent)) {
      mode = MiraMode.emergency;
      route = RouteNames.liveTracking;
    } else if (record.action == MiraActionType.searchHospital || record.action == MiraActionType.searchClinic) {
      mode = MiraMode.search;
      route = RouteNames.hospitalSearch;
    } else if (record.action == MiraActionType.bookDoctor || record.action == MiraActionType.searchDoctor) {
      mode = MiraMode.appointment;
      route = RouteNames.doctorBooking;
    } else if (record.action == MiraActionType.setMedicationReminder) {
      mode = MiraMode.reception;
      route = RouteNames.healthPassport;
    }

    return MiraIntentResult(
      intent: record.intent,
      category: record.category,
      targetMode: mode,
      routeTarget: route,
      actionType: record.action,
      entities: entities,
      miraResponse: record.exampleResponse.isNotEmpty
          ? record.exampleResponse
          : "Sure, I'll help you with that.",
      requiresEscalation: record.requiresEscalation,
      safetyNote: record.safetyNote,
    );
  }
}

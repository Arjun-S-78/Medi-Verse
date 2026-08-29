import '../../../../app/router/route_names.dart';
import '../models/mira_mode.dart';

enum MiraIntentType {
  findDoctor,
  searchHospital,
  bookAppointment,
  emergencyTriage,
  trackAmbulance,
  receptionCheckIn,
  generalQuery,
}

/// Result produced by MIRA Intent Orchestrator.
class MiraIntentResult {
  final MiraIntentType intentType;
  final MiraMode targetMode;
  final String routeTarget;
  final String? extractedEntity;
  final String miraResponse;

  const MiraIntentResult({
    required this.intentType,
    required this.targetMode,
    required this.routeTarget,
    this.extractedEntity,
    required this.miraResponse,
  });
}

/// MIRA Intent Orchestrator Service.
///
/// Classifies patient natural language input into application intents.
/// Orchestrates actions across existing MediVerse services without duplicating business logic.
class MiraIntentOrchestrator {
  /// Parse patient prompt text and generate an Intent Result.
  static MiraIntentResult parseIntent(String prompt) {
    final text = prompt.trim();
    if (text.isEmpty) {
      return const MiraIntentResult(
        intentType: MiraIntentType.generalQuery,
        targetMode: MiraMode.normal,
        routeTarget: RouteNames.home,
        miraResponse: "Hello! I am MIRA. How can I assist you with your health today?",
      );
    }

    final lower = text.toLowerCase();

    // 1. Emergency Intent Detection (Highest priority)
    final isEmergency = lower.contains('chest pain') ||
        lower.contains('cannot breathe') ||
        lower.contains('struggling to breathe') ||
        lower.contains('heavy bleeding') ||
        lower.contains('unconscious') ||
        lower.contains('seizure') ||
        lower.contains('stroke') ||
        lower.contains('heart attack') ||
        lower.contains('emergency') ||
        lower.contains('sos');

    if (isEmergency) {
      return MiraIntentResult(
        intentType: MiraIntentType.emergencyTriage,
        targetMode: MiraMode.emergency,
        routeTarget: RouteNames.triageAssess,
        extractedEntity: text,
        miraResponse: "🚨 Critical alert detected. Switching to Emergency Triage Mode immediately. "
            "Let's assess your symptoms to coordinate rapid care.",
      );
    }

    // 2. Doctor Search Intent
    if (lower.contains('doctor') ||
        lower.contains('specialist') ||
        lower.contains('cardiologist') ||
        lower.contains('pediatrician') ||
        lower.contains('dermatologist') ||
        lower.contains('physician') ||
        lower.contains('consultant')) {
      String specialty = 'General Physician';
      if (lower.contains('cardio')) specialty = 'Cardiologist';
      if (lower.contains('pedia')) specialty = 'Pediatrician';
      if (lower.contains('derma')) specialty = 'Dermatologist';

      return MiraIntentResult(
        intentType: MiraIntentType.findDoctor,
        targetMode: MiraMode.search,
        routeTarget: RouteNames.hospitalSearch,
        extractedEntity: specialty,
        miraResponse: "Sure, I'll search for top-rated $specialty specialists near your location.",
      );
    }

    // 3. Hospital Search Intent
    if (lower.contains('hospital') ||
        lower.contains('clinic') ||
        lower.contains('icu') ||
        lower.contains('er bed') ||
        lower.contains('trauma center')) {
      return const MiraIntentResult(
        intentType: MiraIntentType.searchHospital,
        targetMode: MiraMode.search,
        routeTarget: RouteNames.hospitalSearch,
        miraResponse: "Opening MediVerse Hospital Radar. Showing nearby trauma centers and live ICU bed availability.",
      );
    }

    // 4. Appointment Booking Intent
    if (lower.contains('appointment') ||
        lower.contains('book') ||
        lower.contains('schedule') ||
        lower.contains('visit') ||
        lower.contains('slot')) {
      return const MiraIntentResult(
        intentType: MiraIntentType.bookAppointment,
        targetMode: MiraMode.appointment,
        routeTarget: RouteNames.hospitalSearch,
        miraResponse: "I can help you schedule a clinic appointment. Let's select your preferred doctor and time slot.",
      );
    }

    // 5. Ambulance & Tracking Intent
    if (lower.contains('ambulance') ||
        lower.contains('tracking') ||
        lower.contains('eta') ||
        lower.contains('where is my driver') ||
        lower.contains('dispatch')) {
      return const MiraIntentResult(
        intentType: MiraIntentType.trackAmbulance,
        targetMode: MiraMode.tracking,
        routeTarget: RouteNames.liveTracking,
        miraResponse: "Accessing MediVerse Live Fleet GPS Radar. Displaying real-time ambulance location and arrival ETA.",
      );
    }

    // 6. Reception & Passport Check-In Intent
    if (lower.contains('passport') ||
        lower.contains('profile') ||
        lower.contains('records') ||
        lower.contains('allergies') ||
        lower.contains('blood group') ||
        lower.contains('history')) {
      return const MiraIntentResult(
        intentType: MiraIntentType.receptionCheckIn,
        targetMode: MiraMode.reception,
        routeTarget: RouteNames.healthPassport,
        miraResponse: "Opening your MediVerse Health Passport with medical records, emergency contacts, and allergies.",
      );
    }

    // Default General Query
    return MiraIntentResult(
      intentType: MiraIntentType.generalQuery,
      targetMode: MiraMode.normal,
      routeTarget: RouteNames.home,
      extractedEntity: text,
      miraResponse: "I understand. I am here to help you navigate MediVerse, book appointments, or start emergency triage.",
    );
  }
}

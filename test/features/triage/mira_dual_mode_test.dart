import 'package:flutter_test/flutter_test.dart';
import 'package:mediverse/app/router/route_names.dart';
import 'package:mediverse/features/triage/domain/models/mira_mode.dart';
import 'package:mediverse/features/triage/domain/services/mira_intent_orchestrator.dart';

void main() {
  group('MIRA Dual-Mode Architecture - MiraMode Enum Tests', () {
    test('fromCode parses string code into correct operational mode', () {
      expect(MiraMode.fromCode('NORMAL'), MiraMode.normal);
      expect(MiraMode.fromCode('reception'), MiraMode.reception);
      expect(MiraMode.fromCode('SEARCH'), MiraMode.search);
      expect(MiraMode.fromCode('APPOINTMENT'), MiraMode.appointment);
      expect(MiraMode.fromCode('EMERGENCY'), MiraMode.emergency);
      expect(MiraMode.fromCode('TRIAGE'), MiraMode.triage);
      expect(MiraMode.fromCode('TRACKING'), MiraMode.tracking);
      expect(MiraMode.fromCode('INVALID'), MiraMode.normal);
      expect(MiraMode.fromCode(null), MiraMode.normal);
    });
  });

  group('MIRA Dual-Mode Architecture - MiraIntentOrchestrator Tests', () {
    test('parses emergency symptoms and routes to emergency triage mode', () {
      final result = MiraIntentOrchestrator.parseIntent("I'm having severe chest pain and struggling to breathe");

      expect(result.intentType, MiraIntentType.emergencyTriage);
      expect(result.targetMode, MiraMode.emergency);
      expect(result.routeTarget, RouteNames.triageAssess);
      expect(result.miraResponse, contains('Emergency Triage Mode'));
    });

    test('parses doctor search prompt and extracts cardiologist specialty', () {
      final result = MiraIntentOrchestrator.parseIntent("Find me a top cardiologist near me");

      expect(result.intentType, MiraIntentType.findDoctor);
      expect(result.targetMode, MiraMode.search);
      expect(result.extractedEntity, 'Cardiologist');
      expect(result.routeTarget, RouteNames.hospitalSearch);
    });

    test('parses hospital search prompt and routes to search mode', () {
      final result = MiraIntentOrchestrator.parseIntent("Show nearby hospitals with ICU beds");

      expect(result.intentType, MiraIntentType.searchHospital);
      expect(result.targetMode, MiraMode.search);
      expect(result.routeTarget, RouteNames.hospitalSearch);
    });

    test('parses appointment booking prompt and routes to appointment mode', () {
      final result = MiraIntentOrchestrator.parseIntent("Book an appointment for tomorrow afternoon");

      expect(result.intentType, MiraIntentType.bookAppointment);
      expect(result.targetMode, MiraMode.appointment);
      expect(result.routeTarget, RouteNames.hospitalSearch);
    });

    test('parses ambulance tracking prompt and routes to live tracking mode', () {
      final result = MiraIntentOrchestrator.parseIntent("Where is my dispatched ambulance?");

      expect(result.intentType, MiraIntentType.trackAmbulance);
      expect(result.targetMode, MiraMode.tracking);
      expect(result.routeTarget, RouteNames.liveTracking);
    });

    test('parses reception check-in prompt and routes to health passport', () {
      final result = MiraIntentOrchestrator.parseIntent("Show my medical passport and allergies");

      expect(result.intentType, MiraIntentType.receptionCheckIn);
      expect(result.targetMode, MiraMode.reception);
      expect(result.routeTarget, RouteNames.healthPassport);
    });
  });
}

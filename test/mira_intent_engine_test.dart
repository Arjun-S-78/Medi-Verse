import 'package:flutter_test/flutter_test.dart';
import 'package:mediverse/features/triage/data/services/mira_dataset_repository.dart';
import 'package:mediverse/features/triage/domain/models/mira_action_type.dart';
import 'package:mediverse/features/triage/domain/services/mira_intent_orchestrator.dart';

void main() {
  setUp(() {
    // Populate in-memory dataset examples for test runner
    MiraDatasetRepository().initFromList([
      {
        'id': 1,
        'user_input': 'Find me a hospital nearby',
        'intent': 'find_hospital',
        'category': 'healthcare_service',
        'action': 'SEARCH_HOSPITAL',
        'response_style': 'DIRECT',
        'example_response': "Sure. I'll find hospitals near you.",
        'requires_escalation': false,
        'language': 'en',
      },
      {
        'id': 2,
        'user_input': 'I can not breathe',
        'intent': 'breathing_difficulty',
        'category': 'emergency',
        'action': 'CALL_AMBULANCE',
        'response_style': 'CALM_EMERGENCY',
        'example_response': "Difficulty breathing can be serious.",
        'requires_escalation': true,
        'language': 'en',
      },
      {
        'id': 3,
        'user_input': 'Book a doctor appointment for tomorrow',
        'intent': 'book_doctor',
        'category': 'appointment',
        'action': 'BOOK_DOCTOR',
        'response_style': 'DIRECT',
        'example_response': "Sure. I'll help you find a doctor.",
        'requires_escalation': false,
        'language': 'en',
      },
    ]);
  });

  group('MIRA Intent Engine Tests', () {
    test('Hospital Search Intent Detection', () {
      final result = MiraIntentOrchestrator.parseIntent('Find me a hospital nearby');
      expect(result.intent, equals('find_hospital'));
      expect(result.actionType, equals(MiraActionType.searchHospital));
      expect(result.requiresEscalation, isFalse);
    });

    test('Emergency Breathing Difficulty Intent & Escalation', () {
      final result = MiraIntentOrchestrator.parseIntent('I can\'t breathe');
      expect(result.intent, equals('breathing_difficulty'));
      expect(result.requiresEscalation, isTrue);
      expect(result.actionType, equals(MiraActionType.callAmbulance));
    });

    test('Emergency Chest Pain Intent & Escalation', () {
      final result = MiraIntentOrchestrator.parseIntent('My chest hurts severely');
      expect(result.intent, equals('chest_pain'));
      expect(result.requiresEscalation, isTrue);
    });

    test('Natural Variation - Bro I need a hospital', () {
      final result = MiraIntentOrchestrator.parseIntent('Bro I need a hospital');
      expect(result.intent, equals('find_hospital'));
      expect(result.actionType, equals(MiraActionType.searchHospital));
    });

    test('Natural Variation - Tanglish / Regional expression (Moochu vida kashtama irukku)', () {
      final result = MiraIntentOrchestrator.parseIntent('Moochu vida kashtama irukku');
      expect(result.requiresEscalation, isTrue);
      expect(result.intent, equals('breathing_difficulty'));
    });

    test('Doctor Booking & Entity Extraction', () {
      final result = MiraIntentOrchestrator.parseIntent('Book a cardiologist in Coimbatore tomorrow');
      expect(result.intent, equals('book_doctor'));
      expect(result.actionType, equals(MiraActionType.bookDoctor));
      expect(result.entities.specialty, equals('Cardiologist'));
      expect(result.entities.city, equals('Coimbatore'));
      expect(result.entities.date, equals('tomorrow'));
    });

    test('Headache Symptom Guidance', () {
      final result = MiraIntentOrchestrator.parseIntent('I have a bad headache for 2 days');
      expect(result.intent, equals('headache'));
      expect(result.entities.duration, equals('2 days'));
    });

    test('Greeting Intent', () {
      final result = MiraIntentOrchestrator.parseIntent('Hi MIRA');
      expect(result.intent, equals('greeting'));
      expect(result.requiresEscalation, isFalse);
    });
  });
}

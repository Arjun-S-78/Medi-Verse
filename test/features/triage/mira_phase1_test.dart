import 'package:flutter_test/flutter_test.dart';
import 'package:mediverse/features/triage/domain/models/mira_conversation_state.dart';
import 'package:mediverse/features/triage/domain/models/mira_message.dart';
import 'package:mediverse/features/triage/domain/models/priority_level.dart';
import 'package:mediverse/features/triage/domain/models/structured_triage_data.dart';
import 'package:mediverse/features/triage/domain/models/triage_assessment.dart';
import 'package:mediverse/features/triage/domain/models/triage_result.dart';
import 'package:mediverse/features/triage/domain/models/triage_rule.dart';
import 'package:mediverse/features/triage/presentation/providers/mira_conversation_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MIRA Phase 1 - PriorityLevel Domain Model', () {
    test('fromCode parses string code correctly', () {
      expect(PriorityLevel.fromCode('CRITICAL'), PriorityLevel.critical);
      expect(PriorityLevel.fromCode('HIGH'), PriorityLevel.high);
      expect(PriorityLevel.fromCode('MODERATE'), PriorityLevel.moderate);
      expect(PriorityLevel.fromCode('LOW'), PriorityLevel.low);
      expect(PriorityLevel.fromCode('UNKNOWN'), PriorityLevel.low);
    });

    test('fromScore maps numeric scores to correct PriorityLevel', () {
      expect(PriorityLevel.fromScore(85), PriorityLevel.critical);
      expect(PriorityLevel.fromScore(65), PriorityLevel.high);
      expect(PriorityLevel.fromScore(35), PriorityLevel.moderate);
      expect(PriorityLevel.fromScore(10), PriorityLevel.low);
    });
  });

  group('MIRA Phase 1 - StructuredTriageData Model', () {
    test('empty factory creates unpopulated object with nullable fields', () {
      final data = StructuredTriageData.empty();

      expect(data.chiefComplaint, isNull);
      expect(data.onset, isNull);
      expect(data.conscious, isNull);
      expect(data.breathingDifficulty, isNull);
      expect(data.chestPain, isNull);
      expect(data.painLevel, isNull);
      expect(data.severeBleeding, isNull);
      expect(data.majorTrauma, isNull);
      expect(data.seizure, isNull);
    });

    test('toJson and fromJson serialize symmetrically', () {
      final original = StructuredTriageData(
        chiefComplaint: 'Chest pain radiating to left arm',
        onset: '15 mins ago',
        conscious: true,
        breathingDifficulty: true,
        chestPain: true,
        painLevel: 8,
        severeBleeding: false,
        majorTrauma: false,
        seizure: false,
        age: 45,
        allergies: ['Penicillin'],
      );

      final json = original.toJson();
      final restored = StructuredTriageData.fromJson(json);

      expect(restored.chiefComplaint, original.chiefComplaint);
      expect(restored.onset, original.onset);
      expect(restored.conscious, original.conscious);
      expect(restored.breathingDifficulty, original.breathingDifficulty);
      expect(restored.chestPain, original.chestPain);
      expect(restored.painLevel, original.painLevel);
      expect(restored.age, original.age);
      expect(restored.allergies, contains('Penicillin'));
    });

    test('getMissingRequiredFields identifies incomplete fields', () {
      final incomplete = StructuredTriageData(
        chiefComplaint: 'Headache',
      );

      final missing = incomplete.getMissingRequiredFields();
      expect(missing, contains('onset'));
      expect(missing, contains('conscious'));
      expect(missing, contains('breathingDifficulty'));
    });

    test('hasCriticalRedFlags detects unconsciousness or seizure', () {
      final unconscious = StructuredTriageData(conscious: false);
      final seizure = StructuredTriageData(seizure: true);
      final normal = StructuredTriageData(conscious: true, seizure: false);

      expect(unconscious.hasCriticalRedFlags, isTrue);
      expect(seizure.hasCriticalRedFlags, isTrue);
      expect(normal.hasCriticalRedFlags, isFalse);
    });
  });

  group('MIRA Phase 1 - Triage Rule & Result Models', () {
    test('TriageRule serializes to JSON correctly', () {
      const rule = TriageRule(
        id: 'RULE_CHEST_PAIN',
        name: 'Severe Chest Pain',
        description: 'Severe chest pain radiating to arm',
        category: 'CRITICAL',
        scoreImpact: 35,
        isCriticalOverride: true,
        conditionCode: 'CHEST_PAIN_35',
      );

      final json = rule.toJson();
      expect(json['id'], 'RULE_CHEST_PAIN');
      expect(json['scoreImpact'], 35);
      expect(json['category'], 'CRITICAL');
    });

    test('TriageResult serializes correctly', () {
      final result = TriageResult(
        priority: PriorityLevel.high,
        score: 65,
        reasons: ['Severe chest discomfort'],
        redFlags: [],
        recommendedAction: 'Urgent Clinic Consultation',
        evaluatedAt: DateTime.parse('2026-09-02T12:00:00Z'),
      );

      final json = result.toJson();
      expect(json['score'], 65);
      expect(json['priority'], 'HIGH');
      expect(json['isEmergencyOverride'], isFalse);
    });

    test('TriageAssessment serializes whole domain entity', () {
      final assessment = TriageAssessment(
        id: 'ASSESS_123',
        patientId: 'P-GUEST',
        createdAt: DateTime.parse('2026-09-02T12:00:00Z'),
        structuredData: StructuredTriageData(chiefComplaint: 'Fever'),
        result: TriageResult(
          priority: PriorityLevel.low,
          score: 10,
          reasons: [],
          redFlags: [],
          recommendedAction: 'Self monitoring',
          evaluatedAt: DateTime.parse('2026-09-02T12:00:00Z'),
        ),
      );

      final json = assessment.toJson();
      expect(json['id'], 'ASSESS_123');
      expect(json['patientId'], 'P-GUEST');
    });
  });

  group('MIRA Phase 1 - MiraConversationNotifier State Management', () {
    test('Initial state starts in welcome phase with initial message', () {
      final notifier = MiraConversationNotifier('test_session');
      final state = notifier.state;

      expect(state.sessionId, 'test_session');
      expect(state.phase, MiraConversationPhase.welcome);
      expect(state.messages, hasLength(1));
      expect(state.messages.first.sender, MiraSender.mira);
      expect(state.currentQuestionKey, 'chiefComplaint');
      expect(state.isProcessing, isFalse);
    });

    test('sendPatientMessage updates chiefComplaint and moves to onset question', () async {
      final notifier = MiraConversationNotifier('test_session');
      await notifier.sendPatientMessage('Severe chest pain and tightness');

      final state = notifier.state;
      expect(state.messages.length, greaterThanOrEqualTo(2));
      expect(state.structuredData.chiefComplaint, 'Severe chest pain and tightness');
      expect(state.structuredData.chestPain, isTrue);
      expect(state.phase, MiraConversationPhase.collectingComplaint);
    });

    test('answerFieldPrompt updates structured field directly and advances state', () async {
      final notifier = MiraConversationNotifier('test_session');
      await notifier.sendPatientMessage('Shortness of breath');
      notifier.answerFieldPrompt('onset', '15 minutes ago');

      final state = notifier.state;
      expect(state.structuredData.onset, '15 minutes ago');
      expect(state.currentQuestionKey, 'chestPain');
    });

    test('triggerEmergencyEscalation transitions phase immediately to emergencyEscalation', () {
      final notifier = MiraConversationNotifier('test_session');
      notifier.triggerEmergencyEscalation('Patient reported loss of consciousness');

      final state = notifier.state;
      expect(state.phase, MiraConversationPhase.emergencyEscalation);
      expect(state.isEmergencyEscalation, isTrue);
      expect(state.messages.last.requiresEmergencyAction, isTrue);
    });
  });
}

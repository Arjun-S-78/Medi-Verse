import 'package:flutter_test/flutter_test.dart';
import 'package:mediverse/features/triage/domain/models/priority_level.dart';
import 'package:mediverse/features/triage/domain/models/structured_triage_data.dart';
import 'package:mediverse/features/triage/domain/models/triage_rule.dart';
import 'package:mediverse/features/triage/domain/models/emergency_override.dart';
import 'package:mediverse/features/triage/domain/models/triage_result.dart';
import 'package:mediverse/features/triage/domain/models/triage_assessment.dart';
import 'package:mediverse/features/triage/domain/models/mira_message.dart';
import 'package:mediverse/features/triage/domain/models/mira_conversation_state.dart';
import 'package:mediverse/features/triage/presentation/providers/mira_conversation_provider.dart';

void main() {
  group('MIRA Phase 1 - PriorityLevel Domain Model', () {
    test('fromCode parses string code correctly', () {
      expect(PriorityLevel.fromCode('CRITICAL'), PriorityLevel.critical);
      expect(PriorityLevel.fromCode('high'), PriorityLevel.high);
      expect(PriorityLevel.fromCode('MODERATE'), PriorityLevel.moderate);
      expect(PriorityLevel.fromCode('low'), PriorityLevel.low);
      expect(PriorityLevel.fromCode('UNKNOWN'), PriorityLevel.low);
      expect(PriorityLevel.fromCode(null), PriorityLevel.low);
    });

    test('fromScore maps numeric scores to correct PriorityLevel', () {
      expect(PriorityLevel.fromScore(95), PriorityLevel.critical);
      expect(PriorityLevel.fromScore(76), PriorityLevel.critical);
      expect(PriorityLevel.fromScore(75), PriorityLevel.high);
      expect(PriorityLevel.fromScore(51), PriorityLevel.high);
      expect(PriorityLevel.fromScore(50), PriorityLevel.moderate);
      expect(PriorityLevel.fromScore(26), PriorityLevel.moderate);
      expect(PriorityLevel.fromScore(25), PriorityLevel.low);
      expect(PriorityLevel.fromScore(0), PriorityLevel.low);
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
      expect(data.symptoms, isEmpty);
    });

    test('toJson and fromJson serialize symmetrically', () {
      final data = StructuredTriageData(
        chiefComplaint: 'Crushing chest pain',
        symptoms: const ['Sweating', 'Nausea'],
        onset: '30 mins ago',
        duration: 'Persistent for 30 minutes',
        painLevel: 9,
        conscious: true,
        breathingDifficulty: true,
        chestPain: true,
        severeBleeding: false,
        majorTrauma: false,
        seizure: false,
        age: 45,
        allergies: const ['Penicillin'],
      );

      final json = data.toJson();
      final restored = StructuredTriageData.fromJson(json);

      expect(restored.chiefComplaint, 'Crushing chest pain');
      expect(restored.symptoms, containsAll(['Sweating', 'Nausea']));
      expect(restored.duration, 'Persistent for 30 minutes');
      expect(restored.painLevel, 9);
      expect(restored.conscious, isTrue);
      expect(restored.breathingDifficulty, isTrue);
      expect(restored.chestPain, isTrue);
      expect(restored.age, 45);
      expect(restored.allergies, contains('Penicillin'));
    });

    test('getMissingRequiredFields identifies incomplete fields', () {
      final emptyData = StructuredTriageData.empty();
      expect(
        emptyData.getMissingRequiredFields(),
        containsAll(['chiefComplaint', 'onset', 'conscious', 'breathingDifficulty']),
      );

      final partialData = StructuredTriageData(
        chiefComplaint: 'Headache',
        onset: '1 hour ago',
        conscious: true,
        breathingDifficulty: false,
      );
      expect(partialData.getMissingRequiredFields(), isEmpty);
    });

    test('hasCriticalRedFlags detects unconsciousness or seizure', () {
      expect(const StructuredTriageData(conscious: false).hasCriticalRedFlags, isTrue);
      expect(const StructuredTriageData(seizure: true).hasCriticalRedFlags, isTrue);
      expect(const StructuredTriageData(breathingDifficulty: true).hasCriticalRedFlags, isTrue);
      expect(const StructuredTriageData(conscious: true, breathingDifficulty: false).hasCriticalRedFlags, isFalse);
    });
  });

  group('MIRA Phase 1 - Triage Rule & Result Models', () {
    test('TriageRule serializes to JSON correctly', () {
      const rule = TriageRule(
        id: 'rule_chest_pain',
        name: 'Severe Chest Pain',
        description: 'Chest pain suspicious of acute cardiac event',
        category: 'HIGH_RISK',
        scoreImpact: 35,
        isCriticalOverride: false,
        conditionCode: 'CHEST_PAIN',
      );

      final json = rule.toJson();
      final restored = TriageRule.fromJson(json);
      expect(restored.id, 'rule_chest_pain');
      expect(restored.scoreImpact, 35);
    });

    test('EmergencyOverride serializes correctly', () {
      final override = EmergencyOverride(
        ruleId: 'rule_airway',
        redFlagCode: 'BREATHING_DIFFICULTY',
        reason: 'Severe airway compromise detected',
        triggeredAt: DateTime(2026, 8, 23, 12, 0, 0),
      );

      final json = override.toJson();
      final restored = EmergencyOverride.fromJson(json);
      expect(restored.redFlagCode, 'BREATHING_DIFFICULTY');
      expect(restored.reason, contains('Severe airway compromise'));
    });

    test('TriageResult serializes correctly', () {
      final result = TriageResult(
        priority: PriorityLevel.critical,
        score: 85,
        reasons: const ['Severe chest pain', 'Breathing difficulty'],
        redFlags: const ['BREATHING_DIFFICULTY'],
        recommendedAction: 'Immediate emergency evaluation recommended',
        isEmergencyOverride: true,
        evaluatedAt: DateTime(2026, 8, 23, 12, 0, 0),
      );

      final json = result.toJson();
      final restored = TriageResult.fromJson(json);

      expect(restored.priority, PriorityLevel.critical);
      expect(restored.score, 85);
      expect(restored.reasons, hasLength(2));
      expect(restored.isEmergencyOverride, isTrue);
    });

    test('TriageAssessment serializes whole domain entity', () {
      final assessment = TriageAssessment(
        id: 'assess_123',
        patientId: 'pat_456',
        createdAt: DateTime(2026, 8, 23, 12, 0, 0),
        structuredData: const StructuredTriageData(chiefComplaint: 'Chest pain'),
      );

      final json = assessment.toJson();
      final restored = TriageAssessment.fromJson(json);
      expect(restored.id, 'assess_123');
      expect(restored.structuredData.chiefComplaint, 'Chest pain');
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

    test('sendPatientMessage updates chiefComplaint and moves to onset question', () {
      final notifier = MiraConversationNotifier('test_session');
      notifier.sendPatientMessage('Severe chest pain and tightness');

      final state = notifier.state;
      expect(state.messages, hasLength(3)); // Initial + Patient + Mira follow-up
      expect(state.structuredData.chiefComplaint, 'Severe chest pain and tightness');
      expect(state.structuredData.chestPain, isTrue);
      expect(state.currentQuestionKey, 'onset');
      expect(state.phase, MiraConversationPhase.collectingComplaint);
    });

    test('answerFieldPrompt updates structured field directly and advances state', () {
      final notifier = MiraConversationNotifier('test_session');
      notifier.sendPatientMessage('Shortness of breath');
      notifier.answerFieldPrompt('onset', '15 minutes ago');

      final state = notifier.state;
      expect(state.structuredData.onset, '15 minutes ago');
      // Breathing difficulty was auto-detected from chief complaint, so next question is chestPain
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

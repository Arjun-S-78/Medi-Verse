import 'package:flutter_test/flutter_test.dart';
import 'package:mediverse/features/triage/domain/models/priority_level.dart';
import 'package:mediverse/features/triage/domain/models/structured_triage_data.dart';
import 'package:mediverse/features/triage/domain/services/symptom_extraction_engine.dart';
import 'package:mediverse/features/triage/domain/services/triage_engine.dart';

void main() {
  group('MIRA SymptomExtractionEngine Tests', () {
    test('extracts chest pain, breathing difficulty, and sudden onset from free text', () {
      final initialData = StructuredTriageData.empty();
      final extracted = SymptomExtractionEngine.extractSymptoms(
        userText: "I suddenly have severe chest pain and I'm struggling to breathe.",
        currentData: initialData,
        currentPromptKey: 'chiefComplaint',
      );

      expect(extracted.chiefComplaint, contains('chest pain'));
      expect(extracted.chestPain, isTrue);
      expect(extracted.breathingDifficulty, isTrue);
      expect(extracted.onset, 'Sudden onset');
    });

    test('extracts unconsciousness and fainting keywords', () {
      final initialData = StructuredTriageData.empty();
      final extracted = SymptomExtractionEngine.extractSymptoms(
        userText: "My brother passed out and is unconscious on the floor.",
        currentData: initialData,
      );

      expect(extracted.conscious, isFalse);
    });

    test('extracts numeric pain scale from text', () {
      final initialData = StructuredTriageData.empty();
      final extracted = SymptomExtractionEngine.extractSymptoms(
        userText: "My pain is 8 out of 10",
        currentData: initialData,
      );

      expect(extracted.painLevel, 8);
    });

    test('extracts age and medical conditions', () {
      final initialData = StructuredTriageData.empty();
      final extracted = SymptomExtractionEngine.extractSymptoms(
        userText: "I am 72 years old with hypertension and diabetes",
        currentData: initialData,
      );

      expect(extracted.age, 72);
      expect(extracted.medicalConditions, containsAll(['Hypertension', 'Diabetes']));
    });
  });

  group('MIRA TriageEngine & Emergency Overrides Tests', () {
    test('Unconsciousness triggers critical emergency override regardless of score', () {
      const data = StructuredTriageData(conscious: false);
      final result = TriageEngine.evaluate(data);

      expect(result.priority, PriorityLevel.critical);
      expect(result.isEmergencyOverride, isTrue);
      expect(result.redFlags, contains('UNCONSCIOUSNESS'));
      expect(result.reasons.first, contains('Loss of consciousness'));
    });

    test('Active seizure triggers critical emergency override', () {
      const data = StructuredTriageData(seizure: true);
      final result = TriageEngine.evaluate(data);

      expect(result.priority, PriorityLevel.critical);
      expect(result.isEmergencyOverride, isTrue);
      expect(result.redFlags, contains('ACTIVE_SEIZURE'));
    });

    test('Adversarial case: past unconsciousness still triggers emergency override', () {
      final extracted = SymptomExtractionEngine.extractSymptoms(
        userText: "I feel okay now but I was unconscious for several minutes.",
        currentData: StructuredTriageData.empty(),
      );

      final result = TriageEngine.evaluate(extracted);

      expect(result.priority, PriorityLevel.critical);
      expect(result.isEmergencyOverride, isTrue);
    });

    test('High risk symptoms calculate correct prototype score and priority', () {
      const data = StructuredTriageData(
        chestPain: true,
        breathingDifficulty: true,
        painLevel: 9,
      );

      final result = TriageEngine.evaluate(data);

      expect(result.score, 85);
      expect(result.priority, PriorityLevel.critical);
      expect(result.isEmergencyOverride, isFalse);
      expect(result.redFlags, containsAll(['CHEST_PAIN', 'BREATHING_DIFFICULTY']));
    });

    test('Minor symptoms result in low priority level', () {
      const data = StructuredTriageData(
        painLevel: 3,
        chestPain: false,
        breathingDifficulty: false,
      );

      final result = TriageEngine.evaluate(data);

      expect(result.priority, PriorityLevel.low);
      expect(result.score, lessThanOrEqualTo(25));
    });
  });
}

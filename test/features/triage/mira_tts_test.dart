import 'package:flutter_test/flutter_test.dart';
import 'package:mediverse/features/triage/domain/models/mira_tts_settings.dart';
import 'package:mediverse/features/triage/domain/models/mira_tts_state.dart';
import 'package:mediverse/features/triage/domain/services/mira_kokoro_tts_service.dart';
import 'package:mediverse/features/triage/domain/services/mira_tts_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MIRA Voice System - MiraTtsSettings Unit Tests', () {
    test('default settings adhere to healthcare UX standards and Kokoro-82M model defaults', () {
      const settings = MiraTtsSettings();

      expect(settings.isEnabled, isTrue);
      expect(settings.autoPlay, isTrue);
      expect(settings.speechRate, 0.45); // Moderate calm speaking rate
      expect(settings.pitch, 1.08); // Warm natural pitch
      expect(settings.volume, 1.0);
      expect(settings.preferredLanguage, 'en-US');
      expect(settings.preferFemaleVoice, isTrue);
      expect(settings.useKokoroModel, isTrue);
      expect(settings.kokoroVoice, 'af_heart'); // Flagship Kokoro female voice
    });

    test('toJson and fromJson serialize symmetrically with Kokoro settings', () {
      const settings = MiraTtsSettings(
        isEnabled: false,
        autoPlay: false,
        speechRate: 0.5,
        pitch: 1.1,
        preferredLanguage: 'en-US',
        useKokoroModel: true,
        kokoroVoice: 'af_bella',
      );

      final json = settings.toJson();
      final restored = MiraTtsSettings.fromJson(json);

      expect(restored.isEnabled, isFalse);
      expect(restored.autoPlay, isFalse);
      expect(restored.speechRate, 0.5);
      expect(restored.pitch, 1.1);
      expect(restored.preferredLanguage, 'en-US');
      expect(restored.useKokoroModel, isTrue);
      expect(restored.kokoroVoice, 'af_bella');
    });

    test('copyWith updates specified fields correctly', () {
      const initial = MiraTtsSettings();
      final updated = initial.copyWith(
        speechRate: 0.6,
        kokoroVoice: 'af_sarah',
      );

      expect(updated.speechRate, 0.6);
      expect(updated.kokoroVoice, 'af_sarah');
      expect(updated.pitch, initial.pitch);
      expect(updated.isEnabled, initial.isEnabled);
    });
  });

  group('MIRA Voice System - Kokoro-82M Model Voice List Tests', () {
    test('exposes high-quality female Kokoro voices including af_heart', () {
      final voiceIds = MiraKokoroTtsService.kokoroFemaleVoices.map((v) => v['id']).toList();
      expect(voiceIds, contains('af_heart'));
      expect(voiceIds, contains('af_bella'));
      expect(voiceIds, contains('af_sarah'));
      expect(voiceIds, contains('af_sky'));
      expect(voiceIds.length, greaterThanOrEqualTo(4));
    });
  });

  group('MIRA Voice System - MiraTtsState Unit Tests', () {
    test('initial state defaults to idle status with standard settings', () {
      final state = MiraTtsState.initial();

      expect(state.status, MiraTtsStatus.idle);
      expect(state.settings.isEnabled, isTrue);
      expect(state.currentSpokenText, isNull);
      expect(state.errorMessage, isNull);
    });

    test('state getters reflect current status accurately', () {
      final idleState = MiraTtsState.initial();
      expect(idleState.isIdle, isTrue);
      expect(idleState.isSpeaking, isFalse);

      final speakingState = idleState.copyWith(
        status: MiraTtsStatus.speaking,
        currentSpokenText: 'Evaluating symptoms',
      );

      expect(speakingState.isSpeaking, isTrue);
      expect(speakingState.currentSpokenText, 'Evaluating symptoms');
    });
  });

  group('MIRA Voice System - MiraTtsService Helper Tests', () {
    test('service instantiates cleanly', () {
      final service = MiraTtsService();
      expect(service, isNotNull);
    });
  });
}

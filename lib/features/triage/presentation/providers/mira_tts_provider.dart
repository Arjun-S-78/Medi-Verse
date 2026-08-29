import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/mira_conversation_state.dart';
import '../../domain/models/mira_message.dart';
import '../../domain/models/mira_tts_settings.dart';
import '../../domain/models/mira_tts_state.dart';
import '../../domain/services/mira_tts_service.dart';
import 'mira_conversation_provider.dart';

/// Riverpod StateNotifier managing MIRA's Voice Interaction System (TTS).
/// Incorporates hexgrad/Kokoro-82M neural model as primary voice synthesizer.
class MiraTtsNotifier extends StateNotifier<MiraTtsState> {
  final MiraTtsService _ttsService = MiraTtsService();
  static const String _prefEnabledKey = 'mira_tts_enabled';
  static const String _prefAutoPlayKey = 'mira_tts_autoplay';
  static const String _prefKokoroVoiceKey = 'mira_kokoro_voice';

  MiraTtsNotifier() : super(MiraTtsState.initial()) {
    _initTts();
  }

  Future<void> _initTts() async {
    // Load local user preferences
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(_prefEnabledKey) ?? true;
      final autoPlay = prefs.getBool(_prefAutoPlayKey) ?? true;
      final kokoroVoice = prefs.getString(_prefKokoroVoiceKey) ?? 'af_heart';

      final updatedSettings = state.settings.copyWith(
        isEnabled: isEnabled,
        autoPlay: autoPlay,
        kokoroVoice: kokoroVoice,
      );

      state = state.copyWith(settings: updatedSettings);
    } catch (_) {}

    // Setup callbacks
    _ttsService.onStart = () {
      state = state.copyWith(status: MiraTtsStatus.speaking);
    };

    _ttsService.onCompletion = () {
      state = state.copyWith(
        status: MiraTtsStatus.idle,
        currentSpokenText: null,
        currentMessageId: null,
      );
    };

    _ttsService.onPause = () {
      state = state.copyWith(status: MiraTtsStatus.paused);
    };

    _ttsService.onError = (err) {
      state = state.copyWith(
        status: MiraTtsStatus.error,
        errorMessage: err,
      );
    };

    await _ttsService.initialize(state.settings);

    state = state.copyWith(
      activeVoiceName: state.settings.useKokoroModel
          ? 'Kokoro-82M (${state.settings.kokoroVoice})'
          : _ttsService.selectedVoice?['name'],
      activeLanguage: _ttsService.selectedLanguage,
    );
  }

  /// Speak a specific MIRA message.
  Future<void> speakMessage(MiraMessage message) async {
    if (!state.settings.isEnabled) return;
    if (message.sender == MiraSender.patient) return;

    state = state.copyWith(
      currentSpokenText: message.text,
      currentMessageId: message.id,
    );

    await _ttsService.speak(message.text, state.settings);
  }

  /// Automatically speak new MIRA message if voice and auto-play are enabled.
  void autoPlayNewMessage(MiraMessage message) {
    if (state.settings.isEnabled && state.settings.autoPlay) {
      if (message.sender == MiraSender.mira && message.id != state.currentMessageId) {
        speakMessage(message);
      }
    }
  }

  /// Speak arbitrary text response.
  Future<void> speakText(String text, [String? messageId]) async {
    if (!state.settings.isEnabled || text.trim().isEmpty) return;

    state = state.copyWith(
      currentSpokenText: text,
      currentMessageId: messageId,
    );

    await _ttsService.speak(text, state.settings);
  }

  /// Stop current active speech playback.
  Future<void> stop() async {
    await _ttsService.stop();
    state = state.copyWith(
      status: MiraTtsStatus.idle,
      currentSpokenText: null,
      currentMessageId: null,
    );
  }

  /// Pause current speech playback.
  Future<void> pause() async {
    await _ttsService.pause();
    state = state.copyWith(status: MiraTtsStatus.paused);
  }

  /// Toggle global mute / sound enabled setting.
  Future<void> toggleMute() async {
    final newEnabled = !state.settings.isEnabled;
    if (!newEnabled) {
      await stop();
    }
    final newSettings = state.settings.copyWith(isEnabled: newEnabled);
    state = state.copyWith(settings: newSettings);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefEnabledKey, newEnabled);
    } catch (_) {}
  }

  /// Toggle automatic speech playback on new message generation.
  Future<void> toggleAutoPlay() async {
    final newAutoPlay = !state.settings.autoPlay;
    final newSettings = state.settings.copyWith(autoPlay: newAutoPlay);
    state = state.copyWith(settings: newSettings);

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_prefAutoPlayKey, newAutoPlay);
    } catch (_) {}
  }

  /// Select Kokoro female voice variant ('af_heart', 'af_bella', 'af_sarah', 'af_sky').
  Future<void> setKokoroVoice(String voiceId) async {
    final newSettings = state.settings.copyWith(kokoroVoice: voiceId);
    state = state.copyWith(
      settings: newSettings,
      activeVoiceName: 'Kokoro-82M ($voiceId)',
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefKokoroVoiceKey, voiceId);
    } catch (_) {}
  }

  /// Update TTS settings (speech rate, pitch, volume).
  Future<void> updateSettings(MiraTtsSettings newSettings) async {
    state = state.copyWith(settings: newSettings);
    await _ttsService.setSpeechRate(newSettings.speechRate);
    await _ttsService.setPitch(newSettings.pitch);
    await _ttsService.setVolume(newSettings.volume);
  }

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }
}

/// Global Riverpod provider for MIRA TTS State.
final miraTtsProvider =
    StateNotifierProvider<MiraTtsNotifier, MiraTtsState>((ref) {
  final notifier = MiraTtsNotifier();

  // Listen to MIRA conversation state for automatic voice playback
  ref.listen<MiraConversationState>(miraConversationProvider, (previous, next) {
    final lastMsg = next.lastMessage;
    if (lastMsg != null) {
      notifier.autoPlayNewMessage(lastMsg);
    }
  });

  return notifier;
});

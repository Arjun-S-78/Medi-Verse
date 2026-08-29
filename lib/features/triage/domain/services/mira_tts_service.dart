import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../models/mira_tts_settings.dart';
import 'mira_kokoro_tts_service.dart';

/// Reusable Text-To-Speech Service for MIRA AI Nurse.
///
/// Combines the hexgrad/Kokoro-82M neural model (af_heart female voice) as the primary voice engine,
/// with dynamic browser/device female voice discovery as a fallback.
class MiraTtsService {
  final FlutterTts _flutterTts = FlutterTts();
  final MiraKokoroTtsService _kokoroTtsService = MiraKokoroTtsService();
  bool _isInitialized = false;
  Map<String, String>? _selectedVoice;
  String _selectedLanguage = 'en-US';

  VoidCallback? onStart;
  VoidCallback? onCompletion;
  VoidCallback? onPause;
  VoidCallback? onContinue;
  Function(String error)? onError;

  bool get isInitialized => _isInitialized;
  Map<String, String>? get selectedVoice => _selectedVoice;
  String get selectedLanguage => _selectedLanguage;

  /// Initialize TTS engine and discover best female voice.
  Future<void> initialize(MiraTtsSettings settings) async {
    if (_isInitialized) return;

    try {
      // Set handlers
      _flutterTts.setStartHandler(() {
        if (onStart != null) onStart!();
      });

      _flutterTts.setCompletionHandler(() {
        if (onCompletion != null) onCompletion!();
      });

      _flutterTts.setPauseHandler(() {
        if (onPause != null) onPause!();
      });

      _flutterTts.setContinueHandler(() {
        if (onContinue != null) onContinue!();
      });

      _flutterTts.setErrorHandler((msg) {
        if (onError != null) onError!(msg.toString());
      });

      // Configure speech parameters
      await setSpeechRate(settings.speechRate);
      await setPitch(settings.pitch);
      await setVolume(settings.volume);

      // Perform dynamic voice discovery
      await discoverBestVoice(
        preferredLanguage: settings.preferredLanguage,
        preferFemale: settings.preferFemaleVoice,
      );

      _isInitialized = true;
    } catch (e) {
      if (onError != null) onError!("TTS Initialization failed: $e");
    }
  }

  /// Query available TTS voices and discover best female voice with fallback hierarchy.
  Future<void> discoverBestVoice({
    String preferredLanguage = 'en-IN',
    bool preferFemale = true,
  }) async {
    try {
      final List<dynamic>? voices = await _flutterTts.getVoices;

      if (voices != null && voices.isNotEmpty) {
        final parsedVoices = voices
            .whereType<Map>()
            .map((v) => {
                  'name': v['name']?.toString() ?? '',
                  'locale': v['locale']?.toString() ?? v['lang']?.toString() ?? '',
                })
            .toList();

        Map<String, String>? chosen;

        if (preferFemale) {
          // Priority 1: Female en-IN
          chosen = _findVoice(parsedVoices, localeContains: 'en-in', nameContains: 'female');
          chosen ??= _findVoice(parsedVoices, localeContains: 'en-IN', nameContains: 'female');

          // Priority 2: Female en-US
          chosen ??= _findVoice(parsedVoices, localeContains: 'en-us', nameContains: 'female');
          chosen ??= _findVoice(parsedVoices, localeContains: 'en-US', nameContains: 'female');

          // Priority 3: Any female voice
          chosen ??= _findVoice(parsedVoices, nameContains: 'female');
          chosen ??= _findVoice(parsedVoices, nameContains: 'woman');
        }

        // Priority 4: Any en-IN
        chosen ??= _findVoice(parsedVoices, localeContains: 'en-in');
        chosen ??= _findVoice(parsedVoices, localeContains: 'en-IN');

        // Priority 5: Any en-US
        chosen ??= _findVoice(parsedVoices, localeContains: 'en-us');
        chosen ??= _findVoice(parsedVoices, localeContains: 'en-US');

        // Priority 6: First available voice
        chosen ??= parsedVoices.isNotEmpty ? parsedVoices.first : null;

        if (chosen != null && chosen['name']!.isNotEmpty) {
          _selectedVoice = chosen;
          _selectedLanguage = chosen['locale']!.isNotEmpty ? chosen['locale']! : preferredLanguage;

          try {
            await _flutterTts.setVoice(_selectedVoice!);
          } catch (_) {
            // Web / fallback platform override
          }
        }
      }

      // Set fallback language
      try {
        await _flutterTts.setLanguage(_selectedLanguage);
      } catch (_) {
        await _flutterTts.setLanguage('en-US');
        _selectedLanguage = 'en-US';
      }
    } catch (e) {
      debugPrint("Voice discovery fallback: $e");
      _selectedLanguage = 'en-US';
    }
  }

  Map<String, String>? _findVoice(
    List<Map<String, String>> voices, {
    String? localeContains,
    String? nameContains,
  }) {
    for (final v in voices) {
      final name = v['name']!.toLowerCase();
      final locale = v['locale']!.toLowerCase();

      final matchesLocale = localeContains == null || locale.contains(localeContains.toLowerCase());
      final matchesName = nameContains == null || name.contains(nameContains.toLowerCase());

      if (matchesLocale && matchesName) {
        return v;
      }
    }
    return null;
  }

  /// Speak text dynamically.
  /// First attempts Kokoro-82M neural model synthesis (af_heart).
  /// Falls back to flutter_tts female voice if Kokoro API is offline.
  Future<void> speak(String text, [MiraTtsSettings settings = const MiraTtsSettings()]) async {
    if (text.trim().isEmpty) return;

    final cleanedText = _cleanTextForSpeech(text);

    // 1. Primary Engine: Kokoro-82M Neural Synthesis
    if (settings.useKokoroModel) {
      final kokoroSuccess = await _kokoroTtsService.synthesizeAndPlay(
        text: cleanedText,
        settings: settings,
        onStart: () => onStart?.call(),
        onCompletion: () => onCompletion?.call(),
        onError: (err) => onError?.call(err),
      );

      if (kokoroSuccess) return;
    }

    // 2. Fallback Engine: FlutterTts Female System Voice
    try {
      await stop();
      await _flutterTts.speak(cleanedText);
    } catch (e) {
      if (onError != null) onError!("Speech playback error: $e");
    }
  }

  /// Stop active speech playback.
  Future<void> stop() async {
    try {
      await _flutterTts.stop();
    } catch (_) {}
  }

  /// Pause active speech.
  Future<void> pause() async {
    try {
      await _flutterTts.pause();
    } catch (_) {}
  }

  /// Resume paused speech.
  Future<void> resume() async {
    try {
      await _flutterTts.speak('');
    } catch (_) {}
  }

  Future<void> setSpeechRate(double rate) async {
    await _flutterTts.setSpeechRate(rate.clamp(0.0, 1.0));
  }

  Future<void> setVolume(double volume) async {
    await _flutterTts.setVolume(volume.clamp(0.0, 1.0));
  }

  Future<void> setPitch(double pitch) async {
    await _flutterTts.setPitch(pitch.clamp(0.5, 2.0));
  }

  Future<void> dispose() async {
    await stop();
  }

  /// Strip UI emojis, bullet markers, and markdown tags so TTS speaks naturally.
  String _cleanTextForSpeech(String rawText) {
    var cleaned = rawText
        .replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}\u{1F300}-\u{1F5FF}\u{1F680}-\u{1F6FF}\u{2600}-\u{26FF}\u{2700}-\u{27BF}]', unicode: true), '')
        .replaceAll(RegExp(r'[*#_~`]'), '')
        .replaceAll('🚨', '')
        .replaceAll('ℹ️', '')
        .replaceAll('🔊', '')
        .replaceAll('•', '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    return cleaned;
  }
}

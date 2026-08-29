import 'mira_tts_settings.dart';

enum MiraTtsStatus {
  idle,
  speaking,
  paused,
  stopped,
  error,
}

/// Immutable state object representing MIRA TTS engine status.
class MiraTtsState {
  final MiraTtsStatus status;
  final String? currentSpokenText;
  final String? currentMessageId;
  final String? activeVoiceName;
  final String? activeLanguage;
  final MiraTtsSettings settings;
  final String? errorMessage;

  const MiraTtsState({
    required this.status,
    this.currentSpokenText,
    this.currentMessageId,
    this.activeVoiceName,
    this.activeLanguage,
    required this.settings,
    this.errorMessage,
  });

  factory MiraTtsState.initial() {
    return const MiraTtsState(
      status: MiraTtsStatus.idle,
      settings: MiraTtsSettings(),
    );
  }

  bool get isSpeaking => status == MiraTtsStatus.speaking;
  bool get isPaused => status == MiraTtsStatus.paused;
  bool get isIdle => status == MiraTtsStatus.idle;

  MiraTtsState copyWith({
    MiraTtsStatus? status,
    String? currentSpokenText,
    String? currentMessageId,
    String? activeVoiceName,
    String? activeLanguage,
    MiraTtsSettings? settings,
    String? errorMessage,
  }) {
    return MiraTtsState(
      status: status ?? this.status,
      currentSpokenText: currentSpokenText ?? this.currentSpokenText,
      currentMessageId: currentMessageId ?? this.currentMessageId,
      activeVoiceName: activeVoiceName ?? this.activeVoiceName,
      activeLanguage: activeLanguage ?? this.activeLanguage,
      settings: settings ?? this.settings,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Configurable TTS Settings for MIRA AI Nurse featuring Kokoro-82M model integration.
class MiraTtsSettings {
  final bool isEnabled;
  final bool autoPlay;
  final double speechRate;
  final double pitch;
  final double volume;
  final String preferredLanguage;
  final bool preferFemaleVoice;

  // Kokoro-82M Neural Voice Model Settings (https://hf.co/hexgrad/Kokoro-82M)
  final bool useKokoroModel;
  final String kokoroVoice; // Flagship female voices: 'af_heart', 'af_bella', 'af_sarah', 'af_sky'
  final String kokoroEndpoint;

  const MiraTtsSettings({
    this.isEnabled = true,
    this.autoPlay = true,
    this.speechRate = 0.48, // Calm, moderate healthcare speaking speed
    this.pitch = 1.0, // Warm, natural tone
    this.volume = 1.0,
    this.preferredLanguage = 'en-IN',
    this.preferFemaleVoice = true,
    this.useKokoroModel = true,
    this.kokoroVoice = 'af_heart', // Kokoro-82M flagship female voice
    this.kokoroEndpoint = 'http://localhost:8880/v1/audio/speech',
  });

  MiraTtsSettings copyWith({
    bool? isEnabled,
    bool? autoPlay,
    double? speechRate,
    double? pitch,
    double? volume,
    String? preferredLanguage,
    bool? preferFemaleVoice,
    bool? useKokoroModel,
    String? kokoroVoice,
    String? kokoroEndpoint,
  }) {
    return MiraTtsSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      autoPlay: autoPlay ?? this.autoPlay,
      speechRate: speechRate ?? this.speechRate,
      pitch: pitch ?? this.pitch,
      volume: volume ?? this.volume,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      preferFemaleVoice: preferFemaleVoice ?? this.preferFemaleVoice,
      useKokoroModel: useKokoroModel ?? this.useKokoroModel,
      kokoroVoice: kokoroVoice ?? this.kokoroVoice,
      kokoroEndpoint: kokoroEndpoint ?? this.kokoroEndpoint,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isEnabled': isEnabled,
      'autoPlay': autoPlay,
      'speechRate': speechRate,
      'pitch': pitch,
      'volume': volume,
      'preferredLanguage': preferredLanguage,
      'preferFemaleVoice': preferFemaleVoice,
      'useKokoroModel': useKokoroModel,
      'kokoroVoice': kokoroVoice,
      'kokoroEndpoint': kokoroEndpoint,
    };
  }

  factory MiraTtsSettings.fromJson(Map<String, dynamic> json) {
    return MiraTtsSettings(
      isEnabled: json['isEnabled'] as bool? ?? true,
      autoPlay: json['autoPlay'] as bool? ?? true,
      speechRate: (json['speechRate'] as num?)?.toDouble() ?? 0.48,
      pitch: (json['pitch'] as num?)?.toDouble() ?? 1.0,
      volume: (json['volume'] as num?)?.toDouble() ?? 1.0,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en-IN',
      preferFemaleVoice: json['preferFemaleVoice'] as bool? ?? true,
      useKokoroModel: json['useKokoroModel'] as bool? ?? true,
      kokoroVoice: json['kokoroVoice'] as String? ?? 'af_heart',
      kokoroEndpoint: json['kokoroEndpoint'] as String? ?? 'http://localhost:8880/v1/audio/speech',
    );
  }
}

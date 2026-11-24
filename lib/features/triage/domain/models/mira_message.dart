enum MiraSender {
  mira,
  patient,
  system,
}

/// Represents an individual chat message in the MIRA triage conversation.
class MiraMessage {
  final String id;
  final MiraSender sender;
  final String text;
  final DateTime timestamp;
  final List<String>? quickReplies;
  final String? fieldPrompt;
  final bool requiresEmergencyAction;

  /// When true, the UI renders this message with a typewriter/streaming animation
  /// (like ChatGPT). Set to true on creation, false once animation completes.
  final bool isStreaming;

  const MiraMessage({
    required this.id,
    required this.sender,
    required this.text,
    required this.timestamp,
    this.quickReplies,
    this.fieldPrompt,
    this.requiresEmergencyAction = false,
    this.isStreaming = false,
  });

  factory MiraMessage.mira({
    required String id,
    required String text,
    List<String>? quickReplies,
    String? fieldPrompt,
    bool requiresEmergencyAction = false,
    bool isStreaming = true,
  }) {
    return MiraMessage(
      id: id,
      sender: MiraSender.mira,
      text: text,
      timestamp: DateTime.now(),
      quickReplies: quickReplies,
      fieldPrompt: fieldPrompt,
      requiresEmergencyAction: requiresEmergencyAction,
      isStreaming: isStreaming,
    );
  }

  factory MiraMessage.patient({
    required String id,
    required String text,
  }) {
    return MiraMessage(
      id: id,
      sender: MiraSender.patient,
      text: text,
      timestamp: DateTime.now(),
    );
  }

  factory MiraMessage.system({
    required String id,
    required String text,
    bool requiresEmergencyAction = false,
  }) {
    return MiraMessage(
      id: id,
      sender: MiraSender.system,
      text: text,
      timestamp: DateTime.now(),
      requiresEmergencyAction: requiresEmergencyAction,
    );
  }

  factory MiraMessage.fromJson(Map<String, dynamic> json) {
    return MiraMessage(
      id: json['id'] as String,
      sender: MiraSender.values.firstWhere(
        (s) => s.name == (json['sender'] as String),
        orElse: () => MiraSender.mira,
      ),
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      quickReplies: (json['quickReplies'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
      fieldPrompt: json['fieldPrompt'] as String?,
      requiresEmergencyAction: json['requiresEmergencyAction'] as bool? ?? false,
      isStreaming: json['isStreaming'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender.name,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'quickReplies': quickReplies,
      'fieldPrompt': fieldPrompt,
      'requiresEmergencyAction': requiresEmergencyAction,
      'isStreaming': isStreaming,
    };
  }

  /// Create a copy of this message with isStreaming set to false
  MiraMessage withStreamingComplete() {
    return MiraMessage(
      id: id,
      sender: sender,
      text: text,
      timestamp: timestamp,
      quickReplies: quickReplies,
      fieldPrompt: fieldPrompt,
      requiresEmergencyAction: requiresEmergencyAction,
      isStreaming: false,
    );
  }
}

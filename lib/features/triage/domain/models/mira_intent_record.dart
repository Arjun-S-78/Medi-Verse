import 'mira_action_type.dart';

/// Strongly-typed dataset record representing an entry from MIRA_Intent_Response_Dataset_v1.csv.
class MiraIntentRecord {
  final int id;
  final String userInput;
  final String intent;
  final String category;
  final String entities;
  final MiraActionType action;
  final String responseStyle;
  final String exampleResponse;
  final bool requiresEscalation;
  final String language;
  final String? safetyNote;

  const MiraIntentRecord({
    required this.id,
    required this.userInput,
    required this.intent,
    required this.category,
    required this.entities,
    required this.action,
    required this.responseStyle,
    required this.exampleResponse,
    required this.requiresEscalation,
    required this.language,
    this.safetyNote,
  });

  /// Factory constructor to parse JSON asset or map payload.
  factory MiraIntentRecord.fromJson(Map<String, dynamic> json) {
    return MiraIntentRecord(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      userInput: (json['user_input'] ?? '').toString(),
      intent: (json['intent'] ?? 'unknown').toString(),
      category: (json['category'] ?? 'conversation').toString(),
      entities: (json['entities'] ?? '').toString(),
      action: MiraActionType.fromString((json['action'] ?? '').toString()),
      responseStyle: (json['response_style'] ?? 'DIRECT').toString(),
      exampleResponse: (json['example_response'] ?? '').toString(),
      requiresEscalation: json['requires_escalation'] == true ||
          json['requires_escalation'].toString().toLowerCase() == 'true',
      language: (json['language'] ?? 'en').toString(),
      safetyNote: json['safety_note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_input': userInput,
      'intent': intent,
      'category': category,
      'entities': entities,
      'action': action.name,
      'response_style': responseStyle,
      'example_response': exampleResponse,
      'requires_escalation': requiresEscalation,
      'language': language,
      'safety_note': safetyNote,
    };
  }
}

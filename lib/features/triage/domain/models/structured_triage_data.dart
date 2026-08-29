/// Structured emergency triage data object collected during MIRA conversation.
///
/// Fields are nullable to represent unasked or unknown information cleanly.
/// Missing information MUST NOT be assumed to be false.
class StructuredTriageData {
  final String? chiefComplaint;
  final List<String> symptoms;
  final String? onset;
  final String? duration;
  final int? painLevel;
  final bool? conscious;
  final bool? breathingDifficulty;
  final bool? chestPain;
  final bool? severeBleeding;
  final bool? majorTrauma;
  final bool? seizure;
  final List<String> neurologicalSymptoms;
  final int? age;
  final List<String> medicalConditions;
  final List<String> medications;
  final List<String> allergies;
  final String? additionalContext;

  const StructuredTriageData({
    this.chiefComplaint,
    this.symptoms = const [],
    this.onset,
    this.duration,
    this.painLevel,
    this.conscious,
    this.breathingDifficulty,
    this.chestPain,
    this.severeBleeding,
    this.majorTrauma,
    this.seizure,
    this.neurologicalSymptoms = const [],
    this.age,
    this.medicalConditions = const [],
    this.medications = const [],
    this.allergies = const [],
    this.additionalContext,
  });

  /// Factory constructor for empty initial state.
  factory StructuredTriageData.empty() => const StructuredTriageData();

  /// Create instance from JSON map.
  factory StructuredTriageData.fromJson(Map<String, dynamic> json) {
    return StructuredTriageData(
      chiefComplaint: json['chiefComplaint'] as String?,
      symptoms: (json['symptoms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      onset: json['onset'] as String?,
      duration: json['duration'] as String?,
      painLevel: (json['painLevel'] as num?)?.toInt(),
      conscious: json['conscious'] as bool?,
      breathingDifficulty: json['breathingDifficulty'] as bool?,
      chestPain: json['chestPain'] as bool?,
      severeBleeding: json['severeBleeding'] as bool?,
      majorTrauma: json['majorTrauma'] as bool?,
      seizure: json['seizure'] as bool?,
      neurologicalSymptoms: (json['neurologicalSymptoms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      age: (json['age'] as num?)?.toInt(),
      medicalConditions: (json['medicalConditions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      medications: (json['medications'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      allergies: (json['allergies'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? const [],
      additionalContext: json['additionalContext'] as String?,
    );
  }

  /// Convert object to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'chiefComplaint': chiefComplaint,
      'symptoms': symptoms,
      'onset': onset,
      'duration': duration,
      'painLevel': painLevel,
      'conscious': conscious,
      'breathingDifficulty': breathingDifficulty,
      'chestPain': chestPain,
      'severeBleeding': severeBleeding,
      'majorTrauma': majorTrauma,
      'seizure': seizure,
      'neurologicalSymptoms': neurologicalSymptoms,
      'age': age,
      'medicalConditions': medicalConditions,
      'medications': medications,
      'allergies': allergies,
      'additionalContext': additionalContext,
    };
  }

  /// Immutable copy with updated fields.
  StructuredTriageData copyWith({
    String? chiefComplaint,
    List<String>? symptoms,
    String? onset,
    String? duration,
    int? painLevel,
    bool? conscious,
    bool? breathingDifficulty,
    bool? chestPain,
    bool? severeBleeding,
    bool? majorTrauma,
    bool? seizure,
    List<String>? neurologicalSymptoms,
    int? age,
    List<String>? medicalConditions,
    List<String>? medications,
    List<String>? allergies,
    String? additionalContext,
  }) {
    return StructuredTriageData(
      chiefComplaint: chiefComplaint ?? this.chiefComplaint,
      symptoms: symptoms ?? this.symptoms,
      onset: onset ?? this.onset,
      duration: duration ?? this.duration,
      painLevel: painLevel ?? this.painLevel,
      conscious: conscious ?? this.conscious,
      breathingDifficulty: breathingDifficulty ?? this.breathingDifficulty,
      chestPain: chestPain ?? this.chestPain,
      severeBleeding: severeBleeding ?? this.severeBleeding,
      majorTrauma: majorTrauma ?? this.majorTrauma,
      seizure: seizure ?? this.seizure,
      neurologicalSymptoms: neurologicalSymptoms ?? this.neurologicalSymptoms,
      age: age ?? this.age,
      medicalConditions: medicalConditions ?? this.medicalConditions,
      medications: medications ?? this.medications,
      allergies: allergies ?? this.allergies,
      additionalContext: additionalContext ?? this.additionalContext,
    );
  }

  /// Returns key identifiers of fields that are still missing/uncollected.
  List<String> getMissingRequiredFields() {
    final missing = <String>[];
    if (chiefComplaint == null || chiefComplaint!.trim().isEmpty) {
      missing.add('chiefComplaint');
    }
    if (onset == null || onset!.trim().isEmpty) {
      missing.add('onset');
    }
    if (conscious == null) {
      missing.add('conscious');
    }
    if (breathingDifficulty == null) {
      missing.add('breathingDifficulty');
    }
    return missing;
  }

  /// Checks if any critical red flag is explicitly set to true.
  bool get hasCriticalRedFlags {
    return (conscious == false) ||
        (breathingDifficulty == true) ||
        (severeBleeding == true) ||
        (seizure == true);
  }

  @override
  String toString() => 'StructuredTriageData(${toJson()})';
}

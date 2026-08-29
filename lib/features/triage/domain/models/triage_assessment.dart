import 'structured_triage_data.dart';
import 'triage_result.dart';

/// Comprehensive Triage Assessment entity linking patient session data and deterministic engine results.
class TriageAssessment {
  final String id;
  final String? patientId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final StructuredTriageData structuredData;
  final TriageResult? result;
  final String? emergencyDispatchId;

  const TriageAssessment({
    required this.id,
    this.patientId,
    required this.createdAt,
    this.completedAt,
    required this.structuredData,
    this.result,
    this.emergencyDispatchId,
  });

  factory TriageAssessment.fromJson(Map<String, dynamic> json) {
    return TriageAssessment(
      id: json['id'] as String,
      patientId: json['patientId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
      structuredData: json['structuredData'] != null
          ? StructuredTriageData.fromJson(json['structuredData'] as Map<String, dynamic>)
          : StructuredTriageData.empty(),
      result: json['result'] != null ? TriageResult.fromJson(json['result'] as Map<String, dynamic>) : null,
      emergencyDispatchId: json['emergencyDispatchId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patientId': patientId,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'structuredData': structuredData.toJson(),
      'result': result?.toJson(),
      'emergencyDispatchId': emergencyDispatchId,
    };
  }

  TriageAssessment copyWith({
    String? id,
    String? patientId,
    DateTime? createdAt,
    DateTime? completedAt,
    StructuredTriageData? structuredData,
    TriageResult? result,
    String? emergencyDispatchId,
  }) {
    return TriageAssessment(
      id: id ?? this.id,
      patientId: patientId ?? this.patientId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      structuredData: structuredData ?? this.structuredData,
      result: result ?? this.result,
      emergencyDispatchId: emergencyDispatchId ?? this.emergencyDispatchId,
    );
  }
}

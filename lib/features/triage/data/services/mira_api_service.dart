import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service for communicating with the Python FastAPI MIRA Triage & Synthetic Data Engine backend.
class MiraApiService {
  static const String baseUrl = 'http://localhost:8000/api/v1/mira';

  /// Sends patient chief complaint and conversation to FastAPI server for structured triage.
  static Future<Map<String, dynamic>?> sendTriageRequest({
    required String chiefComplaint,
    required String sessionId,
    List<Map<String, String>> conversationHistory = const [],
  }) async {
    try {
      final url = Uri.parse('$baseUrl/triage');
      final body = jsonEncode({
        'session_id': sessionId,
        'patient_id': 'P-GUEST',
        'chief_complaint': chiefComplaint,
        'conversation_history': conversationHistory,
      });

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        if (kDebugMode) {
          print('MIRA API Server returned error status: ${response.statusCode}');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('MIRA API Server connection error (Using Local Engine Fallback): $e');
      }
    }
    return null;
  }

  /// Fetches latest synthetic dataset metrics from FastAPI backend
  static Future<Map<String, dynamic>?> fetchLatestMetrics() async {
    try {
      final url = Uri.parse('$baseUrl/evaluation/metrics');
      final response = await http.get(url).timeout(const Duration(seconds: 3));
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }
}

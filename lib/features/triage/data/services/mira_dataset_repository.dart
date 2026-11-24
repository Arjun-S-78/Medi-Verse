import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../domain/models/mira_intent_record.dart';

/// Dataset Repository managing the 806 reference entries from MIRA_Intent_Response_Dataset_v1.csv.
class MiraDatasetRepository {
  static final MiraDatasetRepository _instance = MiraDatasetRepository._internal();
  factory MiraDatasetRepository() => _instance;
  MiraDatasetRepository._internal();

  List<MiraIntentRecord> _records = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;
  List<MiraIntentRecord> get allRecords => List.unmodifiable(_records);

  /// Load dataset JSON asset into memory.
  Future<void> loadDataset() async {
    if (_isLoaded) return;
    try {
      final jsonString = await rootBundle.loadString('assets/data/mira_dataset.json');
      final List<dynamic> jsonList = jsonDecode(jsonString);
      _records = jsonList.map((item) => MiraIntentRecord.fromJson(item as Map<String, dynamic>)).toList();
      _isLoaded = true;
    } catch (e) {
      // Fallback: If asset loading fails in test mode or unbuilt state
      _records = [];
    }
  }

  /// Initialize dataset synchronously from raw JSON list (useful for tests & offline loading).
  void initFromList(List<Map<String, dynamic>> rawList) {
    _records = rawList.map((item) => MiraIntentRecord.fromJson(item)).toList();
    _isLoaded = true;
  }

  /// Find best dataset record matching the user's natural language input.
  MiraIntentRecord? findBestMatch(String userQuery) {
    if (_records.isEmpty) return null;

    final cleanedQuery = _normalizeText(userQuery);
    if (cleanedQuery.isEmpty) return null;

    MiraIntentRecord? bestRecord;
    double highestScore = 0.0;

    for (final record in _records) {
      final sample = _normalizeText(record.userInput);

      // Exact match
      if (cleanedQuery == sample) {
        return record;
      }

      // Substring match
      if (cleanedQuery.contains(sample) || sample.contains(cleanedQuery)) {
        final score = 0.85 + (0.15 * (sample.length / (cleanedQuery.length + 1)));
        if (score > highestScore) {
          highestScore = score;
          bestRecord = record;
        }
        continue;
      }

      // Jaccard Token Overlap score
      final queryTokens = cleanedQuery.split(' ').where((t) => t.length > 2).toSet();
      final sampleTokens = sample.split(' ').where((t) => t.length > 2).toSet();

      if (queryTokens.isEmpty || sampleTokens.isEmpty) continue;

      final intersection = queryTokens.intersection(sampleTokens).length;
      final union = queryTokens.union(sampleTokens).length;
      final jaccardScore = intersection / union;

      if (jaccardScore > highestScore) {
        highestScore = jaccardScore;
        bestRecord = record;
      }
    }

    // Require minimum similarity threshold
    if (highestScore >= 0.35) {
      return bestRecord;
    }

    return null;
  }

  /// Retrieve records matching a given intent.
  List<MiraIntentRecord> getRecordsByIntent(String intent) {
    final target = intent.toLowerCase().trim();
    return _records.where((r) => r.intent.toLowerCase() == target).toList();
  }

  /// Text normalization helper.
  String _normalizeText(String input) {
    return input
        .toLowerCase()
        .replaceAll(RegExp(r"[^\w\s]"), "")
        .replaceAll(RegExp(r"\s+"), " ")
        .trim();
  }
}

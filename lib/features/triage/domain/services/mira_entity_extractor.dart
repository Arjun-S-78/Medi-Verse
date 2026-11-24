/// Reusable entity extraction model.
class MiraExtractedEntities {
  final String? symptom;
  final String? duration;
  final String? specialty;
  final String? radius;
  final String? date;
  final String? severity;
  final String? city;
  final Map<String, dynamic> extra;

  const MiraExtractedEntities({
    this.symptom,
    this.duration,
    this.specialty,
    this.radius,
    this.date,
    this.severity,
    this.city,
    this.extra = const {},
  });

  bool get isEmpty =>
      symptom == null &&
      duration == null &&
      specialty == null &&
      radius == null &&
      date == null &&
      severity == null &&
      city == null &&
      extra.isEmpty;

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{};
    if (symptom != null) map['symptom'] = symptom;
    if (duration != null) map['duration'] = duration;
    if (specialty != null) map['specialty'] = specialty;
    if (radius != null) map['radius'] = radius;
    if (date != null) map['date'] = date;
    if (severity != null) map['severity'] = severity;
    if (city != null) map['city'] = city;
    map.addAll(extra);
    return map;
  }
}

/// Reusable Entity Extractor for MIRA AI Nurse.
class MiraEntityExtractor {
  static final RegExp _durationRegex = RegExp(
    r'(\d+\s*(?:days|day|hours|hour|hrs|hr|minutes|minute|mins|min|weeks|week|months|month)|since\s+\w+|yesterday|today)',
    caseSensitive: false,
  );

  static final RegExp _radiusRegex = RegExp(
    r'(\d+\s*(?:km|kms|kilometer|kilometers|mile|miles)|near\s+me|nearby)',
    caseSensitive: false,
  );

  static final RegExp _dateRegex = RegExp(
    r'(today|tomorrow|next\s+\w+|monday|tuesday|wednesday|thursday|friday|saturday|sunday|\d{1,2}(?:st|nd|rd|th)?\s+\w+)',
    caseSensitive: false,
  );

  static final Map<String, String> _specialtyMap = {
    'cardio': 'Cardiologist',
    'heart': 'Cardiologist',
    'pedia': 'Pediatrician',
    'child': 'Pediatrician',
    'kid': 'Pediatrician',
    'derma': 'Dermatologist',
    'skin': 'Dermatologist',
    'ortho': 'Orthopedist',
    'bone': 'Orthopedist',
    'neuro': 'Neurologist',
    'brain': 'Neurologist',
    'oncology': 'Oncologist',
    'cancer': 'Oncologist',
    'physician': 'General Physician',
    'general': 'General Physician',
    'doctor': 'General Physician',
  };

  static final Map<String, String> _cityList = {
    'coimbatore': 'Coimbatore',
    'chennai': 'Chennai',
    'tirupur': 'Tirupur',
    'bangalore': 'Bangalore',
    'bengaluru': 'Bangalore',
    'madurai': 'Madurai',
    'salem': 'Salem',
    'trichy': 'Trichy',
  };

  /// Extract structured entities from user prompt text.
  static MiraExtractedEntities extract(String text) {
    if (text.trim().isEmpty) return const MiraExtractedEntities();

    final lower = text.toLowerCase();

    // 1. Duration Extraction
    String? duration;
    final durationMatch = _durationRegex.firstMatch(lower);
    if (durationMatch != null) {
      duration = durationMatch.group(1);
    }

    // 2. Radius Extraction
    String? radius;
    final radiusMatch = _radiusRegex.firstMatch(lower);
    if (radiusMatch != null) {
      radius = radiusMatch.group(1);
    }

    // 3. Date Extraction
    String? date;
    final dateMatch = _dateRegex.firstMatch(lower);
    if (dateMatch != null) {
      date = dateMatch.group(1);
    }

    // 4. Specialty Extraction
    String? specialty;
    for (final entry in _specialtyMap.entries) {
      if (lower.contains(entry.key)) {
        specialty = entry.value;
        break;
      }
    }

    // 5. City Extraction
    String? city;
    for (final entry in _cityList.entries) {
      if (lower.contains(entry.key)) {
        city = entry.value;
        break;
      }
    }

    // 6. Severity Extraction
    String? severity;
    if (lower.contains('very severe') || lower.contains('worst') || lower.contains('unbearable') || lower.contains('10/10')) {
      severity = 'severe';
    } else if (lower.contains('moderate') || lower.contains('medium')) {
      severity = 'moderate';
    } else if (lower.contains('mild') || lower.contains('slight')) {
      severity = 'mild';
    }

    return MiraExtractedEntities(
      duration: duration,
      radius: radius,
      date: date,
      specialty: specialty,
      city: city,
      severity: severity,
    );
  }
}

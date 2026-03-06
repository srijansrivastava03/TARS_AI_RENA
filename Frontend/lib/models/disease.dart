/// Treatment information for a disease
class Treatment {
  final List<String> organic;
  final List<String> chemical;
  final List<String> cultural;

  const Treatment({
    this.organic = const [],
    this.chemical = const [],
    this.cultural = const [],
  });

  factory Treatment.fromJson(Map<String, dynamic> json) {
    return Treatment(
      organic: _parseStringList(json['organic']),
      chemical: _parseStringList(json['chemical']),
      cultural: _parseStringList(json['cultural']),
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  /// All treatments combined
  List<String> get all => [...organic, ...chemical, ...cultural];
}

/// Full disease diagnosis information
class Disease {
  final String name;
  final String? scientificName;
  final String? description;
  final List<String> symptoms;
  final Treatment treatment;
  final List<String> prevention;
  final List<String> careRecommendations;
  final String severity;
  final List<String> affectedPlants;

  const Disease({
    required this.name,
    this.scientificName,
    this.description,
    this.symptoms = const [],
    this.treatment = const Treatment(),
    this.prevention = const [],
    this.careRecommendations = const [],
    this.severity = 'medium',
    this.affectedPlants = const [],
  });

  factory Disease.fromJson(Map<String, dynamic> json) {
    return Disease(
      name: json['name'] as String? ?? 'Unknown',
      scientificName: json['scientific_name'] as String?,
      description: json['description'] as String?,
      symptoms: _parseStringList(json['symptoms']),
      treatment: json['treatment'] is Map<String, dynamic>
          ? Treatment.fromJson(json['treatment'])
          : const Treatment(),
      prevention: _parseStringList(json['prevention']),
      careRecommendations: _parseStringList(json['care_recommendations']),
      severity: json['severity'] as String? ?? 'medium',
      affectedPlants: _parseStringList(json['affected_plants']),
    );
  }

  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) return value.map((e) => e.toString()).toList();
    return [];
  }

  /// Severity as a normalized value (0.0 = none, 1.0 = high)
  double get severityValue {
    switch (severity.toLowerCase()) {
      case 'none':
        return 0.0;
      case 'low':
        return 0.3;
      case 'medium':
        return 0.6;
      case 'high':
        return 1.0;
      default:
        return 0.5;
    }
  }

  /// Whether this represents a healthy plant
  bool get isHealthy => severity.toLowerCase() == 'none';
}

/// Diagnosis response wrapper
class DiagnosisResult {
  final bool success;
  final Disease? disease;
  final String? source;
  final String? language;
  final String? error;

  const DiagnosisResult({
    required this.success,
    this.disease,
    this.source,
    this.language,
    this.error,
  });

  factory DiagnosisResult.fromJson(Map<String, dynamic> json) {
    return DiagnosisResult(
      success: json['success'] as bool,
      disease: json['disease'] != null
          ? Disease.fromJson(json['disease'] as Map<String, dynamic>)
          : null,
      source: json['source'] as String?,
      language: json['language'] as String?,
      error: json['error'] as String?,
    );
  }
}

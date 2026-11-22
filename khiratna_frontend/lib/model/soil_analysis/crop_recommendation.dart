class CropRecommendation {
  final String cropId;
  final String cropName;
  final double suitability; // 0-100
  final String season;
  final String waterRequirement;

  CropRecommendation({
    required this.cropId,
    required this.cropName,
    required this.suitability,
    required this.season,
    required this.waterRequirement,
  });

  static const _info = <String, (String season, String water)>{
    'rice': ('Summer', 'High'),
    'maize': ('Summer', 'Medium'),
    'chickpea': ('Winter', 'Low'),
    'kidneybeans': ('Summer', 'Medium'),
    'pigeonpeas': ('Summer', 'Low'),
    'mothbeans': ('Summer', 'Low'),
    'mungbean': ('Summer', 'Low'),
    'blackgram': ('Summer', 'Medium'),
    'lentil': ('Winter', 'Low'),
    'pomegranate': ('Year-round', 'Medium'),
    'banana': ('Year-round', 'High'),
    'mango': ('Summer', 'Medium'),
    'grapes': ('Summer', 'Medium'),
    'watermelon': ('Summer', 'Medium'),
    'muskmelon': ('Summer', 'Medium'),
    'apple': ('Autumn', 'Medium'),
    'orange': ('Winter', 'Medium'),
    'papaya': ('Year-round', 'High'),
    'coconut': ('Year-round', 'High'),
    'cotton': ('Summer', 'Medium'),
    'jute': ('Summer', 'High'),
    'coffee': ('Year-round', 'Medium'),
  };

  factory CropRecommendation.fromJson(Map<String, dynamic> json) {
    final id = (json['crop'] as String).toLowerCase();
    final info = _info[id];
    return CropRecommendation(
      cropId: id,
      cropName: json['name'] as String,
      suitability: (json['percent'] as num).toDouble(),
      season: info?.$1 ?? 'N/A',
      waterRequirement: info?.$2 ?? 'N/A',
    );
  }
}

class CropPredictionResult {
  final List<CropRecommendation> crops;
  final List<String> warnings;
  final double modelAccuracy;

  CropPredictionResult({
    required this.crops,
    required this.warnings,
    required this.modelAccuracy,
  });

  factory CropPredictionResult.fromJson(Map<String, dynamic> json) {
    return CropPredictionResult(
      crops: (json['crops'] as List)
          .map((e) => CropRecommendation.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      warnings: (json['warnings'] as List? ?? []).map((e) => e.toString()).toList(),
      modelAccuracy: (json['model_accuracy'] as num?)?.toDouble() ?? 0,
    );
  }
}
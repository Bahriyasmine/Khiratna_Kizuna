import 'package:khiratna_frontend/core/network/api_client.dart';
import '../model/soil_analysis/crop_recommendation.dart';
import '../model/soil_analysis/soil_analysis_request.dart';

class SoilAnalysisService {
  Future<CropPredictionResult> predictCrops(SoilAnalysisRequest r) async {
    final res = await ApiClient.dio.get('/farm/crops', queryParameters: {
      'N': r.nitrogen,
      'P': r.phosphorus,
      'K': r.potassium,
      'temperature': r.temperature,
      'humidity': r.humidity,
      'ph': r.ph,
      'rainfall': r.rainfall,
    });
    return CropPredictionResult.fromJson(Map<String, dynamic>.from(res.data as Map));
  }
}
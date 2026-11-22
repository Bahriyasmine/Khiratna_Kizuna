import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../model/soil_analysis/crop_recommendation.dart';
import '../../model/soil_analysis/soil_analysis_request.dart';
import '../../services/soil_analysis_service.dart';

class SoilAnalysisViewModel extends ChangeNotifier {
  final _service = SoilAnalysisService();

  final nitrogenController = TextEditingController();
  final phosphorusController = TextEditingController();
  final potassiumController = TextEditingController();
  final temperatureController = TextEditingController();
  final humidityController = TextEditingController();
  final phController = TextEditingController();
  final rainfallController = TextEditingController();

  List<CropRecommendation> recommendations = [];
  List<String> warnings = [];
  double modelAccuracy = 0;
  bool loading = false;
  String? error;

  double? _num(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.'));

  Future<void> analyze() async {
    final n = _num(nitrogenController);
    final p = _num(phosphorusController);
    final k = _num(potassiumController);
    final t = _num(temperatureController);
    final h = _num(humidityController);
    final ph = _num(phController);
    final r = _num(rainfallController);

    if ([n, p, k, t, h, ph, r].contains(null)) {
      error = 'Please fill all fields with valid numbers.';
      notifyListeners();
      return;
    }

    loading = true;
    error = null;
    notifyListeners();

    try {
      final result = await _service.predictCrops(
        SoilAnalysisRequest(
          nitrogen: n!,
          phosphorus: p!,
          potassium: k!,
          temperature: t!,
          humidity: h!,
          ph: ph!,
          rainfall: r!,
        ),
      );
      recommendations = result.crops.take(5).toList(); // remove take(5) to show all
      warnings = result.warnings;
      modelAccuracy = result.modelAccuracy;
    } on DioException catch (e) {
      final data = e.response?.data;
      error = (data is Map ? data['message']?.toString() : null) ??
          'Could not reach the server.';
    } catch (_) {
      error = 'Unexpected error. Please try again.';
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    for (final c in [
      nitrogenController,
      phosphorusController,
      potassiumController,
      temperatureController,
      humidityController,
      phController,
      rainfallController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }
}
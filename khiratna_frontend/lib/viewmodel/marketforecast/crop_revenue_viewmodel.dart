import 'package:flutter/foundation.dart';
import 'package:khiratna_frontend/model/marketforecast/crop_revenue.dart';
import 'package:khiratna_frontend/services/market_forecast_service.dart';

class CropRevenueViewModel extends ChangeNotifier {
  final MarketForecastService _service = MarketForecastService();

  final List<String> governorates = MarketForecastService.governorates;
  final List<String> months = MarketForecastService.months;

  String? governorate;
  String? month;

  bool isLoading = false;
  bool hasCalculated = false;
  String? errorMessage;

  List<CropRevenue> results = []; // plantable now, best TND per m³ first
  List<CropRevenue> greenhouseOnly = [];
  List<String> notInSeason = [];
  List<String> frostRisk = [];

  bool _disposed = false;

  bool get canCalculate => governorate != null && month != null && !isLoading;

  void setGovernorate(String value) {
    governorate = value;
    notifyListeners();
  }

  void setMonth(String value) {
    month = value;
    notifyListeners();
  }

  Future<void> calculate() async {
    if (!canCalculate) return;

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final data = await _service.getCropRevenue(
        governorate: governorate!,
        month: month!,
      );

      results = List<CropRevenue>.from(data.plantNow)
        ..sort((a, b) => b.dinarsPerM3.compareTo(a.dinarsPerM3));
      greenhouseOnly = List<CropRevenue>.from(data.greenhouseOnly)
        ..sort((a, b) => b.dinarsPerM3.compareTo(a.dinarsPerM3));
      notInSeason = data.notInSeason;
      frostRisk = data.frostRisk;
      hasCalculated = true;
    } catch (e) {
      debugPrint('Crop revenue error: $e');
      errorMessage = MarketForecastService.errorText(
        e,
        'Could not calculate. Please try again.',
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  @override
  void notifyListeners() {
    if (!_disposed) super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
import 'package:flutter/foundation.dart';
import 'package:khiratna_frontend/model/marketforecast/market_backtest.dart';
import 'package:khiratna_frontend/model/marketforecast/product_forecast.dart';
import 'package:khiratna_frontend/model/marketforecast/product_series.dart';
import 'package:khiratna_frontend/services/market_forecast_service.dart';

class TunisiaLackViewModel extends ChangeNotifier {
  final MarketForecastService _service = MarketForecastService();

  bool isLoading = false;
  bool isChartLoading = false;
  bool hasLoaded = false;
  String? errorMessage;
  String? chartError;

  List<ProductForecast> products = [];
  String? selectedProduct; // display name
  ProductSeries? series;
  MarketBacktest? backtest; // null if it could not be loaded

  bool _disposed = false;

  String? _idOf(String name) {
    for (final p in products) {
      if (p.name == name) return p.id;
    }
    return null;
  }

  Future<void> showForecast() async {
    if (isLoading) return;

    isLoading = true;
    errorMessage = null;
    chartError = null;
    notifyListeners();

    try {
      products = await _service.getLackForecast();
      if (products.isNotEmpty) {
        selectedProduct = products.first.name;
        series = await _service.getProductSeries(products.first.id);
      }
      hasLoaded = true;

      // optional: forecast reliability note, never blocks the screen
      try {
        backtest = await _service.getBacktest();
      } catch (e) {
        debugPrint('Backtest error: $e');
      }
    } catch (e) {
      debugPrint('Lack forecast error: $e');
      errorMessage = MarketForecastService.errorText(
        e,
        'Could not load the forecast. Please try again.',
      );
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selectProduct(String name) async {
    final id = _idOf(name);
    if (id == null) return;

    selectedProduct = name;
    isChartLoading = true;
    chartError = null;
    notifyListeners();

    try {
      series = await _service.getProductSeries(id);
    } catch (e) {
      debugPrint('Series error: $e');
      chartError = MarketForecastService.errorText(
        e,
        'Could not load the chart for $name.',
      );
    } finally {
      isChartLoading = false;
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